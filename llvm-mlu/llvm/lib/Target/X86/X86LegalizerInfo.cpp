//===- X86LegalizerInfo.cpp --------------------------------------*- C++ -*-==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the targeting of the Machinelegalizer class for X86.
/// \todo This should be generated by TableGen.
//===----------------------------------------------------------------------===//

#include "X86LegalizerInfo.h"
#include "X86Subtarget.h"
#include "X86TargetMachine.h"
#include "llvm/CodeGen/GlobalISel/LegalizerHelper.h"
#include "llvm/CodeGen/TargetOpcodes.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Type.h"

using namespace llvm;
using namespace TargetOpcode;
using namespace LegalizeActions;

/// FIXME: The following static functions are SizeChangeStrategy functions
/// that are meant to temporarily mimic the behaviour of the old legalization
/// based on doubling/halving non-legal types as closely as possible. This is
/// not entirly possible as only legalizing the types that are exactly a power
/// of 2 times the size of the legal types would require specifying all those
/// sizes explicitly.
/// In practice, not specifying those isn't a problem, and the below functions
/// should disappear quickly as we add support for legalizing non-power-of-2
/// sized types further.
static void addAndInterleaveWithUnsupported(
    LegacyLegalizerInfo::SizeAndActionsVec &result,
    const LegacyLegalizerInfo::SizeAndActionsVec &v) {
  for (unsigned i = 0; i < v.size(); ++i) {
    result.push_back(v[i]);
    if (i + 1 < v[i].first && i + 1 < v.size() &&
        v[i + 1].first != v[i].first + 1)
      result.push_back({v[i].first + 1, LegacyLegalizeActions::Unsupported});
  }
}

static LegacyLegalizerInfo::SizeAndActionsVec
widen_1(const LegacyLegalizerInfo::SizeAndActionsVec &v) {
  assert(v.size() >= 1);
  assert(v[0].first > 1);
  LegacyLegalizerInfo::SizeAndActionsVec result = {
      {1, LegacyLegalizeActions::WidenScalar},
      {2, LegacyLegalizeActions::Unsupported}};
  addAndInterleaveWithUnsupported(result, v);
  auto Largest = result.back().first;
  result.push_back({Largest + 1, LegacyLegalizeActions::Unsupported});
  return result;
}

X86LegalizerInfo::X86LegalizerInfo(const X86Subtarget &STI,
                                   const X86TargetMachine &TM)
    : Subtarget(STI), TM(TM) {

  setLegalizerInfo32bit();
  setLegalizerInfo64bit();
  setLegalizerInfoSSE1();
  setLegalizerInfoSSE2();
  setLegalizerInfoSSE41();
  setLegalizerInfoAVX();
  setLegalizerInfoAVX2();
  setLegalizerInfoAVX512();
  setLegalizerInfoAVX512DQ();
  setLegalizerInfoAVX512BW();

  getActionDefinitionsBuilder(G_INTRINSIC_ROUNDEVEN)
    .scalarize(0)
    .minScalar(0, LLT::scalar(32))
    .libcall();

  auto &LegacyInfo = getLegacyLegalizerInfo();
  LegacyInfo.setLegalizeScalarToDifferentSizeStrategy(G_PHI, 0, widen_1);
  for (unsigned BinOp : {G_SUB, G_MUL, G_AND, G_OR, G_XOR})
    LegacyInfo.setLegalizeScalarToDifferentSizeStrategy(BinOp, 0, widen_1);
  for (unsigned MemOp : {G_LOAD, G_STORE})
    LegacyInfo.setLegalizeScalarToDifferentSizeStrategy(
        MemOp, 0, LegacyLegalizerInfo::narrowToSmallerAndWidenToSmallest);
  LegacyInfo.setLegalizeScalarToDifferentSizeStrategy(
      G_PTR_ADD, 1,
      LegacyLegalizerInfo::widenToLargerTypesUnsupportedOtherwise);
  LegacyInfo.setLegalizeScalarToDifferentSizeStrategy(
      G_CONSTANT, 0,
      LegacyLegalizerInfo::widenToLargerTypesAndNarrowToLargest);

  getActionDefinitionsBuilder({G_MEMCPY, G_MEMMOVE, G_MEMSET}).libcall();

  LegacyInfo.computeTables();
  verify(*STI.getInstrInfo());
}

bool X86LegalizerInfo::legalizeIntrinsic(LegalizerHelper &Helper,
                                         MachineInstr &MI) const {
  return true;
}

void X86LegalizerInfo::setLegalizerInfo32bit() {

  const LLT p0 = LLT::pointer(0, TM.getPointerSizeInBits(0));
  const LLT s1 = LLT::scalar(1);
  const LLT s8 = LLT::scalar(8);
  const LLT s16 = LLT::scalar(16);
  const LLT s32 = LLT::scalar(32);
  const LLT s64 = LLT::scalar(64);
  const LLT s128 = LLT::scalar(128);

  auto &LegacyInfo = getLegacyLegalizerInfo();

  for (auto Ty : {p0, s1, s8, s16, s32})
    LegacyInfo.setAction({G_IMPLICIT_DEF, Ty}, LegacyLegalizeActions::Legal);

  for (auto Ty : {s8, s16, s32, p0})
    LegacyInfo.setAction({G_PHI, Ty}, LegacyLegalizeActions::Legal);

  for (unsigned BinOp : {G_ADD, G_SUB, G_MUL, G_AND, G_OR, G_XOR})
    for (auto Ty : {s8, s16, s32})
      LegacyInfo.setAction({BinOp, Ty}, LegacyLegalizeActions::Legal);

  for (unsigned Op : {G_UADDE}) {
    LegacyInfo.setAction({Op, s32}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({Op, 1, s1}, LegacyLegalizeActions::Legal);
  }

  for (unsigned MemOp : {G_LOAD, G_STORE}) {
    for (auto Ty : {s8, s16, s32, p0})
      LegacyInfo.setAction({MemOp, Ty}, LegacyLegalizeActions::Legal);

    // And everything's fine in addrspace 0.
    LegacyInfo.setAction({MemOp, 1, p0}, LegacyLegalizeActions::Legal);
  }

  // Pointer-handling
  LegacyInfo.setAction({G_FRAME_INDEX, p0}, LegacyLegalizeActions::Legal);
  LegacyInfo.setAction({G_GLOBAL_VALUE, p0}, LegacyLegalizeActions::Legal);

  LegacyInfo.setAction({G_PTR_ADD, p0}, LegacyLegalizeActions::Legal);
  LegacyInfo.setAction({G_PTR_ADD, 1, s32}, LegacyLegalizeActions::Legal);

  if (!Subtarget.is64Bit()) {
    getActionDefinitionsBuilder(G_PTRTOINT)
        .legalForCartesianProduct({s1, s8, s16, s32}, {p0})
        .maxScalar(0, s32)
        .widenScalarToNextPow2(0, /*Min*/ 8);
    getActionDefinitionsBuilder(G_INTTOPTR).legalFor({{p0, s32}});

    // Shifts and SDIV
    getActionDefinitionsBuilder(
        {G_SDIV, G_SREM, G_UDIV, G_UREM})
      .legalFor({s8, s16, s32})
      .clampScalar(0, s8, s32);

    getActionDefinitionsBuilder(
        {G_SHL, G_LSHR, G_ASHR})
      .legalFor({{s8, s8}, {s16, s8}, {s32, s8}})
      .clampScalar(0, s8, s32)
      .clampScalar(1, s8, s8);

    // Comparison
    getActionDefinitionsBuilder(G_ICMP)
        .legalForCartesianProduct({s8}, {s8, s16, s32, p0})
        .clampScalar(0, s8, s8);
  }

  // Control-flow
  LegacyInfo.setAction({G_BRCOND, s1}, LegacyLegalizeActions::Legal);

  // Constants
  for (auto Ty : {s8, s16, s32, p0})
    LegacyInfo.setAction({TargetOpcode::G_CONSTANT, Ty},
                         LegacyLegalizeActions::Legal);

  // Extensions
  for (auto Ty : {s8, s16, s32}) {
    LegacyInfo.setAction({G_ZEXT, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_SEXT, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_ANYEXT, Ty}, LegacyLegalizeActions::Legal);
  }
  LegacyInfo.setAction({G_ANYEXT, s128}, LegacyLegalizeActions::Legal);
  getActionDefinitionsBuilder(G_SEXT_INREG).lower();

  // Merge/Unmerge
  for (const auto &Ty : {s16, s32, s64}) {
    LegacyInfo.setAction({G_MERGE_VALUES, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_UNMERGE_VALUES, 1, Ty},
                         LegacyLegalizeActions::Legal);
  }
  for (const auto &Ty : {s8, s16, s32}) {
    LegacyInfo.setAction({G_MERGE_VALUES, 1, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_UNMERGE_VALUES, Ty}, LegacyLegalizeActions::Legal);
  }
}

void X86LegalizerInfo::setLegalizerInfo64bit() {

  if (!Subtarget.is64Bit())
    return;

  const LLT p0 = LLT::pointer(0, TM.getPointerSizeInBits(0));
  const LLT s1 = LLT::scalar(1);
  const LLT s8 = LLT::scalar(8);
  const LLT s16 = LLT::scalar(16);
  const LLT s32 = LLT::scalar(32);
  const LLT s64 = LLT::scalar(64);
  const LLT s128 = LLT::scalar(128);

  auto &LegacyInfo = getLegacyLegalizerInfo();

  LegacyInfo.setAction({G_IMPLICIT_DEF, s64}, LegacyLegalizeActions::Legal);
  // Need to have that, as tryFoldImplicitDef will create this pattern:
  // s128 = EXTEND (G_IMPLICIT_DEF s32/s64) -> s128 = G_IMPLICIT_DEF
  LegacyInfo.setAction({G_IMPLICIT_DEF, s128}, LegacyLegalizeActions::Legal);

  LegacyInfo.setAction({G_PHI, s64}, LegacyLegalizeActions::Legal);

  for (unsigned BinOp : {G_ADD, G_SUB, G_MUL, G_AND, G_OR, G_XOR})
    LegacyInfo.setAction({BinOp, s64}, LegacyLegalizeActions::Legal);

  for (unsigned MemOp : {G_LOAD, G_STORE})
    LegacyInfo.setAction({MemOp, s64}, LegacyLegalizeActions::Legal);

  // Pointer-handling
  LegacyInfo.setAction({G_PTR_ADD, 1, s64}, LegacyLegalizeActions::Legal);
  getActionDefinitionsBuilder(G_PTRTOINT)
      .legalForCartesianProduct({s1, s8, s16, s32, s64}, {p0})
      .maxScalar(0, s64)
      .widenScalarToNextPow2(0, /*Min*/ 8);
  getActionDefinitionsBuilder(G_INTTOPTR).legalFor({{p0, s64}});

  // Constants
  LegacyInfo.setAction({TargetOpcode::G_CONSTANT, s64},
                       LegacyLegalizeActions::Legal);

  // Extensions
  for (unsigned extOp : {G_ZEXT, G_SEXT, G_ANYEXT}) {
    LegacyInfo.setAction({extOp, s64}, LegacyLegalizeActions::Legal);
  }

  getActionDefinitionsBuilder(G_SITOFP)
    .legalForCartesianProduct({s32, s64})
      .clampScalar(1, s32, s64)
      .widenScalarToNextPow2(1)
      .clampScalar(0, s32, s64)
      .widenScalarToNextPow2(0);

  getActionDefinitionsBuilder(G_FPTOSI)
      .legalForCartesianProduct({s32, s64})
      .clampScalar(1, s32, s64)
      .widenScalarToNextPow2(0)
      .clampScalar(0, s32, s64)
      .widenScalarToNextPow2(1);

  // Comparison
  getActionDefinitionsBuilder(G_ICMP)
      .legalForCartesianProduct({s8}, {s8, s16, s32, s64, p0})
      .clampScalar(0, s8, s8);

  getActionDefinitionsBuilder(G_FCMP)
      .legalForCartesianProduct({s8}, {s32, s64})
      .clampScalar(0, s8, s8)
      .clampScalar(1, s32, s64)
      .widenScalarToNextPow2(1);

  // Divisions
  getActionDefinitionsBuilder(
      {G_SDIV, G_SREM, G_UDIV, G_UREM})
      .legalFor({s8, s16, s32, s64})
      .clampScalar(0, s8, s64);

  // Shifts
  getActionDefinitionsBuilder(
    {G_SHL, G_LSHR, G_ASHR})
    .legalFor({{s8, s8}, {s16, s8}, {s32, s8}, {s64, s8}})
    .clampScalar(0, s8, s64)
    .clampScalar(1, s8, s8);

  // Merge/Unmerge
  LegacyInfo.setAction({G_MERGE_VALUES, s128}, LegacyLegalizeActions::Legal);
  LegacyInfo.setAction({G_UNMERGE_VALUES, 1, s128},
                       LegacyLegalizeActions::Legal);
  LegacyInfo.setAction({G_MERGE_VALUES, 1, s128}, LegacyLegalizeActions::Legal);
  LegacyInfo.setAction({G_UNMERGE_VALUES, s128}, LegacyLegalizeActions::Legal);
}

void X86LegalizerInfo::setLegalizerInfoSSE1() {
  if (!Subtarget.hasSSE1())
    return;

  const LLT s32 = LLT::scalar(32);
  const LLT s64 = LLT::scalar(64);
  const LLT v4s32 = LLT::vector(4, 32);
  const LLT v2s64 = LLT::vector(2, 64);

  auto &LegacyInfo = getLegacyLegalizerInfo();

  for (unsigned BinOp : {G_FADD, G_FSUB, G_FMUL, G_FDIV})
    for (auto Ty : {s32, v4s32})
      LegacyInfo.setAction({BinOp, Ty}, LegacyLegalizeActions::Legal);

  for (unsigned MemOp : {G_LOAD, G_STORE})
    for (auto Ty : {v4s32, v2s64})
      LegacyInfo.setAction({MemOp, Ty}, LegacyLegalizeActions::Legal);

  // Constants
  LegacyInfo.setAction({TargetOpcode::G_FCONSTANT, s32},
                       LegacyLegalizeActions::Legal);

  // Merge/Unmerge
  for (const auto &Ty : {v4s32, v2s64}) {
    LegacyInfo.setAction({G_CONCAT_VECTORS, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_UNMERGE_VALUES, 1, Ty},
                         LegacyLegalizeActions::Legal);
  }
  LegacyInfo.setAction({G_MERGE_VALUES, 1, s64}, LegacyLegalizeActions::Legal);
  LegacyInfo.setAction({G_UNMERGE_VALUES, s64}, LegacyLegalizeActions::Legal);
}

void X86LegalizerInfo::setLegalizerInfoSSE2() {
  if (!Subtarget.hasSSE2())
    return;

  const LLT s32 = LLT::scalar(32);
  const LLT s64 = LLT::scalar(64);
  const LLT v16s8 = LLT::vector(16, 8);
  const LLT v8s16 = LLT::vector(8, 16);
  const LLT v4s32 = LLT::vector(4, 32);
  const LLT v2s64 = LLT::vector(2, 64);

  const LLT v32s8 = LLT::vector(32, 8);
  const LLT v16s16 = LLT::vector(16, 16);
  const LLT v8s32 = LLT::vector(8, 32);
  const LLT v4s64 = LLT::vector(4, 64);

  auto &LegacyInfo = getLegacyLegalizerInfo();

  for (unsigned BinOp : {G_FADD, G_FSUB, G_FMUL, G_FDIV})
    for (auto Ty : {s64, v2s64})
      LegacyInfo.setAction({BinOp, Ty}, LegacyLegalizeActions::Legal);

  for (unsigned BinOp : {G_ADD, G_SUB})
    for (auto Ty : {v16s8, v8s16, v4s32, v2s64})
      LegacyInfo.setAction({BinOp, Ty}, LegacyLegalizeActions::Legal);

  LegacyInfo.setAction({G_MUL, v8s16}, LegacyLegalizeActions::Legal);

  LegacyInfo.setAction({G_FPEXT, s64}, LegacyLegalizeActions::Legal);
  LegacyInfo.setAction({G_FPEXT, 1, s32}, LegacyLegalizeActions::Legal);

  LegacyInfo.setAction({G_FPTRUNC, s32}, LegacyLegalizeActions::Legal);
  LegacyInfo.setAction({G_FPTRUNC, 1, s64}, LegacyLegalizeActions::Legal);

  // Constants
  LegacyInfo.setAction({TargetOpcode::G_FCONSTANT, s64},
                       LegacyLegalizeActions::Legal);

  // Merge/Unmerge
  for (const auto &Ty :
       {v16s8, v32s8, v8s16, v16s16, v4s32, v8s32, v2s64, v4s64}) {
    LegacyInfo.setAction({G_CONCAT_VECTORS, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_UNMERGE_VALUES, 1, Ty},
                         LegacyLegalizeActions::Legal);
  }
  for (const auto &Ty : {v16s8, v8s16, v4s32, v2s64}) {
    LegacyInfo.setAction({G_CONCAT_VECTORS, 1, Ty},
                         LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_UNMERGE_VALUES, Ty}, LegacyLegalizeActions::Legal);
  }
}

void X86LegalizerInfo::setLegalizerInfoSSE41() {
  if (!Subtarget.hasSSE41())
    return;

  const LLT v4s32 = LLT::vector(4, 32);

  auto &LegacyInfo = getLegacyLegalizerInfo();

  LegacyInfo.setAction({G_MUL, v4s32}, LegacyLegalizeActions::Legal);
}

void X86LegalizerInfo::setLegalizerInfoAVX() {
  if (!Subtarget.hasAVX())
    return;

  const LLT v16s8 = LLT::vector(16, 8);
  const LLT v8s16 = LLT::vector(8, 16);
  const LLT v4s32 = LLT::vector(4, 32);
  const LLT v2s64 = LLT::vector(2, 64);

  const LLT v32s8 = LLT::vector(32, 8);
  const LLT v64s8 = LLT::vector(64, 8);
  const LLT v16s16 = LLT::vector(16, 16);
  const LLT v32s16 = LLT::vector(32, 16);
  const LLT v8s32 = LLT::vector(8, 32);
  const LLT v16s32 = LLT::vector(16, 32);
  const LLT v4s64 = LLT::vector(4, 64);
  const LLT v8s64 = LLT::vector(8, 64);

  auto &LegacyInfo = getLegacyLegalizerInfo();

  for (unsigned MemOp : {G_LOAD, G_STORE})
    for (auto Ty : {v8s32, v4s64})
      LegacyInfo.setAction({MemOp, Ty}, LegacyLegalizeActions::Legal);

  for (auto Ty : {v32s8, v16s16, v8s32, v4s64}) {
    LegacyInfo.setAction({G_INSERT, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_EXTRACT, 1, Ty}, LegacyLegalizeActions::Legal);
  }
  for (auto Ty : {v16s8, v8s16, v4s32, v2s64}) {
    LegacyInfo.setAction({G_INSERT, 1, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_EXTRACT, Ty}, LegacyLegalizeActions::Legal);
  }
  // Merge/Unmerge
  for (const auto &Ty :
       {v32s8, v64s8, v16s16, v32s16, v8s32, v16s32, v4s64, v8s64}) {
    LegacyInfo.setAction({G_CONCAT_VECTORS, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_UNMERGE_VALUES, 1, Ty},
                         LegacyLegalizeActions::Legal);
  }
  for (const auto &Ty :
       {v16s8, v32s8, v8s16, v16s16, v4s32, v8s32, v2s64, v4s64}) {
    LegacyInfo.setAction({G_CONCAT_VECTORS, 1, Ty},
                         LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_UNMERGE_VALUES, Ty}, LegacyLegalizeActions::Legal);
  }
}

void X86LegalizerInfo::setLegalizerInfoAVX2() {
  if (!Subtarget.hasAVX2())
    return;

  const LLT v32s8 = LLT::vector(32, 8);
  const LLT v16s16 = LLT::vector(16, 16);
  const LLT v8s32 = LLT::vector(8, 32);
  const LLT v4s64 = LLT::vector(4, 64);

  const LLT v64s8 = LLT::vector(64, 8);
  const LLT v32s16 = LLT::vector(32, 16);
  const LLT v16s32 = LLT::vector(16, 32);
  const LLT v8s64 = LLT::vector(8, 64);

  auto &LegacyInfo = getLegacyLegalizerInfo();

  for (unsigned BinOp : {G_ADD, G_SUB})
    for (auto Ty : {v32s8, v16s16, v8s32, v4s64})
      LegacyInfo.setAction({BinOp, Ty}, LegacyLegalizeActions::Legal);

  for (auto Ty : {v16s16, v8s32})
    LegacyInfo.setAction({G_MUL, Ty}, LegacyLegalizeActions::Legal);

  // Merge/Unmerge
  for (const auto &Ty : {v64s8, v32s16, v16s32, v8s64}) {
    LegacyInfo.setAction({G_CONCAT_VECTORS, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_UNMERGE_VALUES, 1, Ty},
                         LegacyLegalizeActions::Legal);
  }
  for (const auto &Ty : {v32s8, v16s16, v8s32, v4s64}) {
    LegacyInfo.setAction({G_CONCAT_VECTORS, 1, Ty},
                         LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_UNMERGE_VALUES, Ty}, LegacyLegalizeActions::Legal);
  }
}

void X86LegalizerInfo::setLegalizerInfoAVX512() {
  if (!Subtarget.hasAVX512())
    return;

  const LLT v16s8 = LLT::vector(16, 8);
  const LLT v8s16 = LLT::vector(8, 16);
  const LLT v4s32 = LLT::vector(4, 32);
  const LLT v2s64 = LLT::vector(2, 64);

  const LLT v32s8 = LLT::vector(32, 8);
  const LLT v16s16 = LLT::vector(16, 16);
  const LLT v8s32 = LLT::vector(8, 32);
  const LLT v4s64 = LLT::vector(4, 64);

  const LLT v64s8 = LLT::vector(64, 8);
  const LLT v32s16 = LLT::vector(32, 16);
  const LLT v16s32 = LLT::vector(16, 32);
  const LLT v8s64 = LLT::vector(8, 64);

  auto &LegacyInfo = getLegacyLegalizerInfo();

  for (unsigned BinOp : {G_ADD, G_SUB})
    for (auto Ty : {v16s32, v8s64})
      LegacyInfo.setAction({BinOp, Ty}, LegacyLegalizeActions::Legal);

  LegacyInfo.setAction({G_MUL, v16s32}, LegacyLegalizeActions::Legal);

  for (unsigned MemOp : {G_LOAD, G_STORE})
    for (auto Ty : {v16s32, v8s64})
      LegacyInfo.setAction({MemOp, Ty}, LegacyLegalizeActions::Legal);

  for (auto Ty : {v64s8, v32s16, v16s32, v8s64}) {
    LegacyInfo.setAction({G_INSERT, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_EXTRACT, 1, Ty}, LegacyLegalizeActions::Legal);
  }
  for (auto Ty : {v32s8, v16s16, v8s32, v4s64, v16s8, v8s16, v4s32, v2s64}) {
    LegacyInfo.setAction({G_INSERT, 1, Ty}, LegacyLegalizeActions::Legal);
    LegacyInfo.setAction({G_EXTRACT, Ty}, LegacyLegalizeActions::Legal);
  }

  /************ VLX *******************/
  if (!Subtarget.hasVLX())
    return;

  for (auto Ty : {v4s32, v8s32})
    LegacyInfo.setAction({G_MUL, Ty}, LegacyLegalizeActions::Legal);
}

void X86LegalizerInfo::setLegalizerInfoAVX512DQ() {
  if (!(Subtarget.hasAVX512() && Subtarget.hasDQI()))
    return;

  const LLT v8s64 = LLT::vector(8, 64);

  auto &LegacyInfo = getLegacyLegalizerInfo();

  LegacyInfo.setAction({G_MUL, v8s64}, LegacyLegalizeActions::Legal);

  /************ VLX *******************/
  if (!Subtarget.hasVLX())
    return;

  const LLT v2s64 = LLT::vector(2, 64);
  const LLT v4s64 = LLT::vector(4, 64);

  for (auto Ty : {v2s64, v4s64})
    LegacyInfo.setAction({G_MUL, Ty}, LegacyLegalizeActions::Legal);
}

void X86LegalizerInfo::setLegalizerInfoAVX512BW() {
  if (!(Subtarget.hasAVX512() && Subtarget.hasBWI()))
    return;

  const LLT v64s8 = LLT::vector(64, 8);
  const LLT v32s16 = LLT::vector(32, 16);

  auto &LegacyInfo = getLegacyLegalizerInfo();

  for (unsigned BinOp : {G_ADD, G_SUB})
    for (auto Ty : {v64s8, v32s16})
      LegacyInfo.setAction({BinOp, Ty}, LegacyLegalizeActions::Legal);

  LegacyInfo.setAction({G_MUL, v32s16}, LegacyLegalizeActions::Legal);

  /************ VLX *******************/
  if (!Subtarget.hasVLX())
    return;

  const LLT v8s16 = LLT::vector(8, 16);
  const LLT v16s16 = LLT::vector(16, 16);

  for (auto Ty : {v8s16, v16s16})
    LegacyInfo.setAction({G_MUL, Ty}, LegacyLegalizeActions::Legal);
}
