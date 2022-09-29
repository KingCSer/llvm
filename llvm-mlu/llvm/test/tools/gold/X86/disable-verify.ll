; RUN: llvm-as %s -o %t.o
; REQUIRES: asserts

; RUN: %gold -m elf_x86_64 -plugin %llvmshlibdir/LLVMgold%shlibext \
; RUN:    --plugin-opt=disable-verify --plugin-opt=legacy-pass-manager \
; RUN:    --plugin-opt=-debug-pass=Arguments \
; RUN:    -shared %t.o -o %t2.o 2>&1 | FileCheck %s

; RUN: %gold -m elf_x86_64 -plugin %llvmshlibdir/LLVMgold%shlibext \
; RUN:    --plugin-opt=-debug-pass=Arguments --plugin-opt=legacy-pass-manager \
; RUN:    -shared %t.o -o %t2.o 2>&1 | FileCheck %s -check-prefix=VERIFY

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; -disable-verify should disable output verification from the optimization
; pipeline.
; CHECK: Pass Arguments: {{.*}} -verify -
; CHECK-NOT: -verify

; VERIFY: Pass Arguments: {{.*}} -verify {{.*}} -verify

define void @f() {
entry:
  ret void
}
