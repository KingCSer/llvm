### Build LLVM Command//from kang
1. python3 ../buildbot/configure.py -t Debug --bang
2. python3 ../buildbot/compile.py


### Build example Command //from kang
This project is based on llvm-13 for supporting cambricon mlu

- source env-cnrt.sh
- clang++ -fsycl -fsycl-targets=mlisa-cambricon-bang samples/wram.cpp -o samples/wram
