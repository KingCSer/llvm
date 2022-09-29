//===-- llvm-lto2: test harness for the resolution-based LTO interface ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This program takes in a list of bitcode files, links them and performs
// link-time optimization according to the provided symbol resolutions using the
// resolution-based LTO interface, and outputs one or more object files.
//
// This program is intended to eventually replace llvm-lto which uses the legacy
// LTO interface.
//
//===----------------------------------------------------------------------===//

#include "llvm/Bitcode/BitcodeReader.h"
#include "llvm/CodeGen/CommandFlags.h"
#include "llvm/Config/llvm-config.h"
#include "llvm/IR/DiagnosticPrinter.h"
#include "llvm/LTO/Caching.h"
#include "llvm/LTO/LTO.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Remarks/HotnessThresholdParser.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/PluginLoader.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/Threading.h"

using namespace llvm;
using namespace lto;

static codegen::RegisterCodeGenFlags CGF;

static cl::opt<char>
    OptLevel("O", cl::desc("Optimization level. [-O0, -O1, -O2, or -O3] "
                           "(default = '-O2')"),
             cl::Prefix, cl::ZeroOrMore, cl::init('2'));

static cl::opt<char> CGOptLevel(
    "cg-opt-level",
    cl::desc("Codegen optimization level (0, 1, 2 or 3, default = '2')"),
    cl::init('2'));

static cl::list<std::string> InputFilenames(cl::Positional, cl::OneOrMore,
                                            cl::desc("<input bitcode files>"));

static cl::opt<std::string> OutputFilename("o", cl::Required,
                                           cl::desc("Output filename"),
                                           cl::value_desc("filename"));

static cl::opt<std::string> CacheDir("cache-dir", cl::desc("Cache Directory"),
                                     cl::value_desc("directory"));

static cl::opt<std::string> OptPipeline("opt-pipeline",
                                        cl::desc("Optimizer Pipeline"),
                                        cl::value_desc("pipeline"));

static cl::opt<std::string> AAPipeline("aa-pipeline",
                                       cl::desc("Alias Analysis Pipeline"),
                                       cl::value_desc("aapipeline"));

static cl::opt<bool> SaveTemps("save-temps", cl::desc("Save temporary files"));

static cl::opt<bool>
    ThinLTODistributedIndexes("thinlto-distributed-indexes", cl::init(false),
                              cl::desc("Write out individual index and "
                                       "import files for the "
                                       "distributed backend case"));

// Default to using all available threads in the system, but using only one
// thread per core (no SMT).
// Use -thinlto-threads=all to use hardware_concurrency() instead, which means
// to use all hardware threads or cores in the system.
static cl::opt<std::string> Threads("thinlto-threads");

static cl::list<std::string> SymbolResolutions(
    "r",
    cl::desc("Specify a symbol resolution: filename,symbolname,resolution\n"
             "where \"resolution\" is a sequence (which may be empty) of the\n"
             "following characters:\n"
             " p - prevailing: the linker has chosen this definition of the\n"
             "     symbol\n"
             " l - local: the definition of this symbol is unpreemptable at\n"
             "     runtime and is known to be in this linkage unit\n"
             " x - externally visible: the definition of this symbol is\n"
             "     visible outside of the LTO unit\n"
             "A resolution for each symbol must be specified."),
    cl::ZeroOrMore);

static cl::opt<std::string> OverrideTriple(
    "override-triple",
    cl::desc("Replace target triples in input files with this triple"));

static cl::opt<std::string> DefaultTriple(
    "default-triple",
    cl::desc(
        "Replace unspecified target triples in input files with this triple"));

static cl::opt<bool> RemarksWithHotness(
    "pass-remarks-with-hotness",
    cl::desc("With PGO, include profile count in optimization remarks"),
    cl::Hidden);

cl::opt<Optional<uint64_t>, false, remarks::HotnessThresholdParser>
    RemarksHotnessThreshold(
        "pass-remarks-hotness-threshold",
        cl::desc("Minimum profile count required for an "
                 "optimization remark to be output."
                 " Use 'auto' to apply the threshold from profile summary."),
        cl::value_desc("uint or 'auto'"), cl::init(0), cl::Hidden);

static cl::opt<std::string>
    RemarksFilename("pass-remarks-output",
                    cl::desc("Output filename for pass remarks"),
                    cl::value_desc("filename"));

static cl::opt<std::string>
    RemarksPasses("pass-remarks-filter",
                  cl::desc("Only record optimization remarks from passes whose "
                           "names match the given regular expression"),
                  cl::value_desc("regex"));

static cl::opt<std::string> RemarksFormat(
    "pass-remarks-format",
    cl::desc("The format used for serializing remarks (default: YAML)"),
    cl::value_desc("format"), cl::init("yaml"));

static cl::opt<std::string>
    SamplePGOFile("lto-sample-profile-file",
                  cl::desc("Specify a SamplePGO profile file"));

static cl::opt<std::string>
    CSPGOFile("lto-cspgo-profile-file",
              cl::desc("Specify a context sensitive PGO profile file"));

static cl::opt<bool>
    RunCSIRInstr("lto-cspgo-gen",
                 cl::desc("Run PGO context sensitive IR instrumentation"),
                 cl::init(false), cl::Hidden);

static cl::opt<bool>
    UseNewPM("use-new-pm",
             cl::desc("Run LTO passes using the new pass manager"),
             cl::init(LLVM_ENABLE_NEW_PASS_MANAGER), cl::Hidden);

static cl::opt<bool>
    DebugPassManager("debug-pass-manager", cl::init(false), cl::Hidden,
                     cl::desc("Print pass management debugging information"));

static cl::opt<std::string>
    StatsFile("stats-file", cl::desc("Filename to write statistics to"));

static cl::list<std::string>
    PassPlugins("load-pass-plugin",
                cl::desc("Load passes from plugin library"));

static cl::opt<bool> EnableFreestanding(
    "lto-freestanding",
    cl::desc("Enable Freestanding (disable builtins / TLI) during LTO"),
    cl::init(false), cl::Hidden);

static void check(Error E, std::string Msg) {
  if (!E)
    return;
  handleAllErrors(std::move(E), [&](ErrorInfoBase &EIB) {
    errs() << "llvm-lto2: " << Msg << ": " << EIB.message().c_str() << '\n';
  });
  exit(1);
}

template <typename T> static T check(Expected<T> E, std::string Msg) {
  if (E)
    return std::move(*E);
  check(E.takeError(), Msg);
  return T();
}

static void check(std::error_code EC, std::string Msg) {
  check(errorCodeToError(EC), Msg);
}

template <typename T> static T check(ErrorOr<T> E, std::string Msg) {
  if (E)
    return std::move(*E);
  check(E.getError(), Msg);
  return T();
}

static int usage() {
  errs() << "Available subcommands: dump-symtab run\n";
  return 1;
}

static int run(int argc, char **argv) {
  cl::ParseCommandLineOptions(argc, argv, "Resolution-based LTO test harness");

  // FIXME: Workaround PR30396 which means that a symbol can appear
  // more than once if it is defined in module-level assembly and
  // has a GV declaration. We allow (file, symbol) pairs to have multiple
  // resolutions and apply them in the order observed.
  std::map<std::pair<std::string, std::string>, std::list<SymbolResolution>>
      CommandLineResolutions;
  for (std::string R : SymbolResolutions) {
    StringRef Rest = R;
    StringRef FileName, SymbolName;
    std::tie(FileName, Rest) = Rest.split(',');
    if (Rest.empty()) {
      llvm::errs() << "invalid resolution: " << R << '\n';
      return 1;
    }
    std::tie(SymbolName, Rest) = Rest.split(',');
    SymbolResolution Res;
    for (char C : Rest) {
      if (C == 'p')
        Res.Prevailing = true;
      else if (C == 'l')
        Res.FinalDefinitionInLinkageUnit = true;
      else if (C == 'x')
        Res.VisibleToRegularObj = true;
      else if (C == 'r')
        Res.LinkerRedefined = true;
      else {
        llvm::errs() << "invalid character " << C << " in resolution: " << R
                     << '\n';
        return 1;
      }
    }
    CommandLineResolutions[{std::string(FileName), std::string(SymbolName)}]
        .push_back(Res);
  }

  std::vector<std::unique_ptr<MemoryBuffer>> MBs;

  Config Conf;
  Conf.DiagHandler = [](const DiagnosticInfo &DI) {
    DiagnosticPrinterRawOStream DP(errs());
    DI.print(DP);
    errs() << '\n';
    if (DI.getSeverity() == DS_Error)
      exit(1);
  };

  Conf.CPU = codegen::getMCPU();
  Conf.Options = codegen::InitTargetOptionsFromCodeGenFlags(Triple());
  Conf.MAttrs = codegen::getMAttrs();
  if (auto RM = codegen::getExplicitRelocModel())
    Conf.RelocModel = RM.getValue();
  Conf.CodeModel = codegen::getExplicitCodeModel();

  Conf.DebugPassManager = DebugPassManager;

  if (SaveTemps)
    check(Conf.addSaveTemps(OutputFilename + "."),
          "Config::addSaveTemps failed");

  // Optimization remarks.
  Conf.RemarksFilename = RemarksFilename;
  Conf.RemarksPasses = RemarksPasses;
  Conf.RemarksWithHotness = RemarksWithHotness;
  Conf.RemarksHotnessThreshold = RemarksHotnessThreshold;
  Conf.RemarksFormat = RemarksFormat;

  Conf.SampleProfile = SamplePGOFile;
  Conf.CSIRProfile = CSPGOFile;
  Conf.RunCSIRInstr = RunCSIRInstr;

  // Run a custom pipeline, if asked for.
  Conf.OptPipeline = OptPipeline;
  Conf.AAPipeline = AAPipeline;

  Conf.OptLevel = OptLevel - '0';
  Conf.UseNewPM = UseNewPM;
  Conf.Freestanding = EnableFreestanding;
  for (auto &PluginFN : PassPlugins)
    Conf.PassPlugins.push_back(PluginFN);
  switch (CGOptLevel) {
  case '0':
    Conf.CGOptLevel = CodeGenOpt::None;
    break;
  case '1':
    Conf.CGOptLevel = CodeGenOpt::Less;
    break;
  case '2':
    Conf.CGOptLevel = CodeGenOpt::Default;
    break;
  case '3':
    Conf.CGOptLevel = CodeGenOpt::Aggressive;
    break;
  default:
    llvm::errs() << "invalid cg optimization level: " << CGOptLevel << '\n';
    return 1;
  }

  if (auto FT = codegen::getExplicitFileType())
    Conf.CGFileType = FT.getValue();

  Conf.OverrideTriple = OverrideTriple;
  Conf.DefaultTriple = DefaultTriple;
  Conf.StatsFile = StatsFile;
  Conf.PTO.LoopVectorization = Conf.OptLevel > 1;
  Conf.PTO.SLPVectorization = Conf.OptLevel > 1;

  ThinBackend Backend;
  if (ThinLTODistributedIndexes)
    Backend = createWriteIndexesThinBackend(/* OldPrefix */ "",
                                            /* NewPrefix */ "",
                                            /* ShouldEmitImportsFiles */ true,
                                            /* LinkedObjectsFile */ nullptr,
                                            /* OnWrite */ {});
  else
    Backend = createInProcessThinBackend(
        llvm::heavyweight_hardware_concurrency(Threads));
  LTO Lto(std::move(Conf), std::move(Backend));

  bool HasErrors = false;
  for (std::string F : InputFilenames) {
    std::unique_ptr<MemoryBuffer> MB = check(MemoryBuffer::getFile(F), F);
    std::unique_ptr<InputFile> Input =
        check(InputFile::create(MB->getMemBufferRef()), F);

    std::vector<SymbolResolution> Res;
    for (const InputFile::Symbol &Sym : Input->symbols()) {
      auto I = CommandLineResolutions.find({F, std::string(Sym.getName())});
      // If it isn't found, look for ".", which would have been added
      // (followed by a hash) when the symbol was promoted during module
      // splitting if it was defined in one part and used in the other.
      // Try looking up the symbol name before the suffix.
      if (I == CommandLineResolutions.end()) {
        auto SplitName = Sym.getName().rsplit(".");
        I = CommandLineResolutions.find({F, std::string(SplitName.first)});
      }
      if (I == CommandLineResolutions.end()) {
        llvm::errs() << argv[0] << ": missing symbol resolution for " << F
                     << ',' << Sym.getName() << '\n';
        HasErrors = true;
      } else {
        Res.push_back(I->second.front());
        I->second.pop_front();
        if (I->second.empty())
          CommandLineResolutions.erase(I);
      }
    }

    if (HasErrors)
      continue;

    MBs.push_back(std::move(MB));
    check(Lto.add(std::move(Input), Res), F);
  }

  if (!CommandLineResolutions.empty()) {
    HasErrors = true;
    for (auto UnusedRes : CommandLineResolutions)
      llvm::errs() << argv[0] << ": unused symbol resolution for "
                   << UnusedRes.first.first << ',' << UnusedRes.first.second
                   << '\n';
  }
  if (HasErrors)
    return 1;

  auto AddStream =
      [&](size_t Task) -> std::unique_ptr<lto::NativeObjectStream> {
    std::string Path = OutputFilename + "." + utostr(Task);

    std::error_code EC;
    auto S = std::make_unique<raw_fd_ostream>(Path, EC, sys::fs::OF_None);
    check(EC, Path);
    return std::make_unique<lto::NativeObjectStream>(std::move(S));
  };

  auto AddBuffer = [&](size_t Task, std::unique_ptr<MemoryBuffer> MB) {
    *AddStream(Task)->OS << MB->getBuffer();
  };

  NativeObjectCache Cache;
  if (!CacheDir.empty())
    Cache = check(localCache(CacheDir, AddBuffer), "failed to create cache");

  check(Lto.run(AddStream, Cache), "LTO::run failed");
  return 0;
}

static int dumpSymtab(int argc, char **argv) {
  for (StringRef F : make_range(argv + 1, argv + argc)) {
    std::unique_ptr<MemoryBuffer> MB =
        check(MemoryBuffer::getFile(F), std::string(F));
    BitcodeFileContents BFC =
        check(getBitcodeFileContents(*MB), std::string(F));

    if (BFC.Symtab.size() >= sizeof(irsymtab::storage::Header)) {
      auto *Hdr = reinterpret_cast<const irsymtab::storage::Header *>(
          BFC.Symtab.data());
      outs() << "version: " << Hdr->Version << '\n';
      if (Hdr->Version == irsymtab::storage::Header::kCurrentVersion)
        outs() << "producer: " << Hdr->Producer.get(BFC.StrtabForSymtab)
               << '\n';
    }

    std::unique_ptr<InputFile> Input =
        check(InputFile::create(MB->getMemBufferRef()), std::string(F));

    outs() << "target triple: " << Input->getTargetTriple() << '\n';
    Triple TT(Input->getTargetTriple());

    outs() << "source filename: " << Input->getSourceFileName() << '\n';

    if (TT.isOSBinFormatCOFF())
      outs() << "linker opts: " << Input->getCOFFLinkerOpts() << '\n';

    if (TT.isOSBinFormatELF()) {
      outs() << "dependent libraries:";
      for (auto L : Input->getDependentLibraries())
        outs() << " \"" << L << "\"";
      outs() << '\n';
    }

    std::vector<StringRef> ComdatTable = Input->getComdatTable();
    for (const InputFile::Symbol &Sym : Input->symbols()) {
      switch (Sym.getVisibility()) {
      case GlobalValue::HiddenVisibility:
        outs() << 'H';
        break;
      case GlobalValue::ProtectedVisibility:
        outs() << 'P';
        break;
      case GlobalValue::DefaultVisibility:
        outs() << 'D';
        break;
      }

      auto PrintBool = [&](char C, bool B) { outs() << (B ? C : '-'); };
      PrintBool('U', Sym.isUndefined());
      PrintBool('C', Sym.isCommon());
      PrintBool('W', Sym.isWeak());
      PrintBool('I', Sym.isIndirect());
      PrintBool('O', Sym.canBeOmittedFromSymbolTable());
      PrintBool('T', Sym.isTLS());
      PrintBool('X', Sym.isExecutable());
      outs() << ' ' << Sym.getName() << '\n';

      if (Sym.isCommon())
        outs() << "         size " << Sym.getCommonSize() << " align "
               << Sym.getCommonAlignment() << '\n';

      int Comdat = Sym.getComdatIndex();
      if (Comdat != -1)
        outs() << "         comdat " << ComdatTable[Comdat] << '\n';

      if (TT.isOSBinFormatCOFF() && Sym.isWeak() && Sym.isIndirect())
        outs() << "         fallback " << Sym.getCOFFWeakExternalFallback() << '\n';

      if (!Sym.getSectionName().empty())
        outs() << "         section " << Sym.getSectionName() << "\n";
    }

    outs() << '\n';
  }

  return 0;
}

int main(int argc, char **argv) {
  InitLLVM X(argc, argv);
  InitializeAllTargets();
  InitializeAllTargetMCs();
  InitializeAllAsmPrinters();
  InitializeAllAsmParsers();

  // FIXME: This should use llvm::cl subcommands, but it isn't currently
  // possible to pass an argument not associated with a subcommand to a
  // subcommand (e.g. -use-new-pm).
  if (argc < 2)
    return usage();

  StringRef Subcommand = argv[1];
  // Ensure that argv[0] is correct after adjusting argv/argc.
  argv[1] = argv[0];
  if (Subcommand == "dump-symtab")
    return dumpSymtab(argc - 1, argv + 1);
  if (Subcommand == "run")
    return run(argc - 1, argv + 1);
  return usage();
}
