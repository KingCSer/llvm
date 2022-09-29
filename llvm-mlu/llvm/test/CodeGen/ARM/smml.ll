; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=arm-eabi %s -o - | FileCheck %s --check-prefixes=CHECK-V4
; RUN: llc -mtriple=armv6-eabi %s -o - | FileCheck %s --check-prefixes=CHECK-V6
; RUN: llc -mtriple=armv7-eabi %s -o - | FileCheck %s --check-prefixes=CHECK-V6
; RUN: llc -mtriple=thumb-eabi %s -o - | FileCheck %s --check-prefixes=CHECK-THUMB
; RUN: llc -mtriple=thumbv6-eabi %s -o - | FileCheck %s --check-prefixes=CHECK-THUMBV6
; RUN: llc -mtriple=thumbv6t2-eabi %s -o - | FileCheck %s --check-prefixes=CHECK-THUMBV6T2
; RUN: llc -mtriple=thumbv7-eabi %s -o - | FileCheck %s --check-prefixes=CHECK-THUMBV6T2
; RUN: llc -mtriple=thumbv7m-eabi %s -o - | FileCheck %s --check-prefixes=CHECK-V4-THUMBV7M
; RUN: llc -mtriple=thumbv7em-eabi %s -o - | FileCheck %s --check-prefixes=CHECK-THUMBV6T2

; Next test would previously trigger an assertion responsible for verification of
; call site info state.
; RUN: llc -stop-after=if-converter -debug-entry-values -mtriple=thumbv6t2-eabi %s -o -| FileCheck %s -check-prefix=CHECK-CALLSITE
; CHECK-CALLSITE: name:  test_used_flags
; CHECK-CALLSITE: callSites:

define i32 @Test0(i32 %a, i32 %b, i32 %c) nounwind readnone ssp {
; CHECK-V4-LABEL: Test0:
; CHECK-V4:       @ %bb.0: @ %entry
; CHECK-V4-NEXT:    smull r3, r12, r2, r1
; CHECK-V4-NEXT:    sub r0, r0, r12
; CHECK-V4-NEXT:    mov pc, lr
;
; CHECK-V6-LABEL: Test0:
; CHECK-V6:       @ %bb.0: @ %entry
; CHECK-V6-NEXT:    smmul r1, r2, r1
; CHECK-V6-NEXT:    sub r0, r0, r1
; CHECK-V6-NEXT:    bx lr
;
; CHECK-THUMB-LABEL: Test0:
; CHECK-THUMB:       @ %bb.0: @ %entry
; CHECK-THUMB-NEXT:    .save {r4, r5, r7, lr}
; CHECK-THUMB-NEXT:    push {r4, r5, r7, lr}
; CHECK-THUMB-NEXT:    movs r5, r1
; CHECK-THUMB-NEXT:    movs r4, r0
; CHECK-THUMB-NEXT:    asrs r1, r2, #31
; CHECK-THUMB-NEXT:    asrs r3, r5, #31
; CHECK-THUMB-NEXT:    movs r0, r2
; CHECK-THUMB-NEXT:    movs r2, r5
; CHECK-THUMB-NEXT:    bl __aeabi_lmul
; CHECK-THUMB-NEXT:    subs r0, r4, r1
; CHECK-THUMB-NEXT:    pop {r4, r5, r7}
; CHECK-THUMB-NEXT:    pop {r1}
; CHECK-THUMB-NEXT:    bx r1
;
; CHECK-THUMBV6-LABEL: Test0:
; CHECK-THUMBV6:       @ %bb.0: @ %entry
; CHECK-THUMBV6-NEXT:    .save {r4, r5, r7, lr}
; CHECK-THUMBV6-NEXT:    push {r4, r5, r7, lr}
; CHECK-THUMBV6-NEXT:    mov r5, r1
; CHECK-THUMBV6-NEXT:    mov r4, r0
; CHECK-THUMBV6-NEXT:    asrs r1, r2, #31
; CHECK-THUMBV6-NEXT:    asrs r3, r5, #31
; CHECK-THUMBV6-NEXT:    mov r0, r2
; CHECK-THUMBV6-NEXT:    mov r2, r5
; CHECK-THUMBV6-NEXT:    bl __aeabi_lmul
; CHECK-THUMBV6-NEXT:    subs r0, r4, r1
; CHECK-THUMBV6-NEXT:    pop {r4, r5, r7, pc}
;
; CHECK-THUMBV6T2-LABEL: Test0:
; CHECK-THUMBV6T2:       @ %bb.0: @ %entry
; CHECK-THUMBV6T2-NEXT:    smmul r1, r2, r1
; CHECK-THUMBV6T2-NEXT:    subs r0, r0, r1
; CHECK-THUMBV6T2-NEXT:    bx lr
;
; CHECK-V4-THUMBV7M-LABEL: Test0:
; CHECK-V4-THUMBV7M:       @ %bb.0: @ %entry
; CHECK-V4-THUMBV7M-NEXT:    smull r1, r2, r2, r1
; CHECK-V4-THUMBV7M-NEXT:    subs r0, r0, r2
; CHECK-V4-THUMBV7M-NEXT:    bx lr
entry:
  %conv4 = zext i32 %a to i64
  %conv1 = sext i32 %b to i64
  %conv2 = sext i32 %c to i64
  %mul = mul nsw i64 %conv2, %conv1
  %shr5 = lshr i64 %mul, 32
  %sub = sub nsw i64 %conv4, %shr5
  %conv3 = trunc i64 %sub to i32
  ret i32 %conv3
}

define i32 @Test1(i32 %a, i32 %b, i32 %c) {
; CHECK-V4-LABEL: Test1:
; CHECK-V4:       @ %bb.0: @ %entry
; CHECK-V4-NEXT:    smull r3, r12, r2, r1
; CHECK-V4-NEXT:    rsbs r1, r3, #0
; CHECK-V4-NEXT:    sbc r0, r0, r12
; CHECK-V4-NEXT:    mov pc, lr
;
; CHECK-V6-LABEL: Test1:
; CHECK-V6:       @ %bb.0: @ %entry
; CHECK-V6-NEXT:    smmls r0, r2, r1, r0
; CHECK-V6-NEXT:    bx lr
;
; CHECK-THUMB-LABEL: Test1:
; CHECK-THUMB:       @ %bb.0: @ %entry
; CHECK-THUMB-NEXT:    .save {r4, r5, r7, lr}
; CHECK-THUMB-NEXT:    push {r4, r5, r7, lr}
; CHECK-THUMB-NEXT:    movs r5, r1
; CHECK-THUMB-NEXT:    movs r4, r0
; CHECK-THUMB-NEXT:    asrs r1, r2, #31
; CHECK-THUMB-NEXT:    asrs r3, r5, #31
; CHECK-THUMB-NEXT:    movs r0, r2
; CHECK-THUMB-NEXT:    movs r2, r5
; CHECK-THUMB-NEXT:    bl __aeabi_lmul
; CHECK-THUMB-NEXT:    rsbs r0, r0, #0
; CHECK-THUMB-NEXT:    sbcs r4, r1
; CHECK-THUMB-NEXT:    movs r0, r4
; CHECK-THUMB-NEXT:    pop {r4, r5, r7}
; CHECK-THUMB-NEXT:    pop {r1}
; CHECK-THUMB-NEXT:    bx r1
;
; CHECK-THUMBV6-LABEL: Test1:
; CHECK-THUMBV6:       @ %bb.0: @ %entry
; CHECK-THUMBV6-NEXT:    .save {r4, r5, r7, lr}
; CHECK-THUMBV6-NEXT:    push {r4, r5, r7, lr}
; CHECK-THUMBV6-NEXT:    mov r5, r1
; CHECK-THUMBV6-NEXT:    mov r4, r0
; CHECK-THUMBV6-NEXT:    asrs r1, r2, #31
; CHECK-THUMBV6-NEXT:    asrs r3, r5, #31
; CHECK-THUMBV6-NEXT:    mov r0, r2
; CHECK-THUMBV6-NEXT:    mov r2, r5
; CHECK-THUMBV6-NEXT:    bl __aeabi_lmul
; CHECK-THUMBV6-NEXT:    rsbs r0, r0, #0
; CHECK-THUMBV6-NEXT:    sbcs r4, r1
; CHECK-THUMBV6-NEXT:    mov r0, r4
; CHECK-THUMBV6-NEXT:    pop {r4, r5, r7, pc}
;
; CHECK-THUMBV6T2-LABEL: Test1:
; CHECK-THUMBV6T2:       @ %bb.0: @ %entry
; CHECK-THUMBV6T2-NEXT:    smmls r0, r2, r1, r0
; CHECK-THUMBV6T2-NEXT:    bx lr
;
; CHECK-V4-THUMBV7M-LABEL: Test1:
; CHECK-V4-THUMBV7M:       @ %bb.0: @ %entry
; CHECK-V4-THUMBV7M-NEXT:    smull r1, r2, r2, r1
; CHECK-V4-THUMBV7M-NEXT:    rsbs r1, r1, #0
; CHECK-V4-THUMBV7M-NEXT:    sbcs r0, r2
; CHECK-V4-THUMBV7M-NEXT:    bx lr
entry:
  %conv = sext i32 %b to i64
  %conv1 = sext i32 %c to i64
  %mul = mul nsw i64 %conv1, %conv
  %conv26 = zext i32 %a to i64
  %shl = shl nuw i64 %conv26, 32
  %sub = sub nsw i64 %shl, %mul
  %shr7 = lshr i64 %sub, 32
  %conv3 = trunc i64 %shr7 to i32
  ret i32 %conv3
}

declare void @opaque(i32)
define void @test_used_flags(i32 %in1, i32 %in2) {
; CHECK-V4-LABEL: test_used_flags:
; CHECK-V4:       @ %bb.0:
; CHECK-V4-NEXT:    .save {r11, lr}
; CHECK-V4-NEXT:    push {r11, lr}
; CHECK-V4-NEXT:    smull r2, r3, r0, r1
; CHECK-V4-NEXT:    rsbs r0, r2, #0
; CHECK-V4-NEXT:    rscs r0, r3, #0
; CHECK-V4-NEXT:    movge r0, #42
; CHECK-V4-NEXT:    movlt r0, #56
; CHECK-V4-NEXT:    bl opaque
; CHECK-V4-NEXT:    pop {r11, lr}
; CHECK-V4-NEXT:    mov pc, lr
;
; CHECK-V6-LABEL: test_used_flags:
; CHECK-V6:       @ %bb.0:
; CHECK-V6-NEXT:    .save {r11, lr}
; CHECK-V6-NEXT:    push {r11, lr}
; CHECK-V6-NEXT:    smull r0, r1, r0, r1
; CHECK-V6-NEXT:    rsbs r0, r0, #0
; CHECK-V6-NEXT:    rscs r0, r1, #0
; CHECK-V6-NEXT:    bge .LBB2_2
; CHECK-V6-NEXT:  @ %bb.1: @ %false
; CHECK-V6-NEXT:    mov r0, #56
; CHECK-V6-NEXT:    bl opaque
; CHECK-V6-NEXT:    pop {r11, pc}
; CHECK-V6-NEXT:  .LBB2_2: @ %true
; CHECK-V6-NEXT:    mov r0, #42
; CHECK-V6-NEXT:    bl opaque
; CHECK-V6-NEXT:    pop {r11, pc}
;
; CHECK-THUMB-LABEL: test_used_flags:
; CHECK-THUMB:       @ %bb.0:
; CHECK-THUMB-NEXT:    .save {r7, lr}
; CHECK-THUMB-NEXT:    push {r7, lr}
; CHECK-THUMB-NEXT:    movs r2, r1
; CHECK-THUMB-NEXT:    asrs r1, r0, #31
; CHECK-THUMB-NEXT:    asrs r3, r2, #31
; CHECK-THUMB-NEXT:    bl __aeabi_lmul
; CHECK-THUMB-NEXT:    movs r2, #0
; CHECK-THUMB-NEXT:    rsbs r0, r0, #0
; CHECK-THUMB-NEXT:    sbcs r2, r1
; CHECK-THUMB-NEXT:    bge .LBB2_2
; CHECK-THUMB-NEXT:  @ %bb.1: @ %false
; CHECK-THUMB-NEXT:    movs r0, #56
; CHECK-THUMB-NEXT:    b .LBB2_3
; CHECK-THUMB-NEXT:  .LBB2_2: @ %true
; CHECK-THUMB-NEXT:    movs r0, #42
; CHECK-THUMB-NEXT:  .LBB2_3: @ %true
; CHECK-THUMB-NEXT:    bl opaque
; CHECK-THUMB-NEXT:    pop {r7}
; CHECK-THUMB-NEXT:    pop {r0}
; CHECK-THUMB-NEXT:    bx r0
;
; CHECK-THUMBV6-LABEL: test_used_flags:
; CHECK-THUMBV6:       @ %bb.0:
; CHECK-THUMBV6-NEXT:    .save {r7, lr}
; CHECK-THUMBV6-NEXT:    push {r7, lr}
; CHECK-THUMBV6-NEXT:    mov r2, r1
; CHECK-THUMBV6-NEXT:    asrs r1, r0, #31
; CHECK-THUMBV6-NEXT:    asrs r3, r2, #31
; CHECK-THUMBV6-NEXT:    bl __aeabi_lmul
; CHECK-THUMBV6-NEXT:    movs r2, #0
; CHECK-THUMBV6-NEXT:    rsbs r0, r0, #0
; CHECK-THUMBV6-NEXT:    sbcs r2, r1
; CHECK-THUMBV6-NEXT:    bge .LBB2_2
; CHECK-THUMBV6-NEXT:  @ %bb.1: @ %false
; CHECK-THUMBV6-NEXT:    movs r0, #56
; CHECK-THUMBV6-NEXT:    bl opaque
; CHECK-THUMBV6-NEXT:    pop {r7, pc}
; CHECK-THUMBV6-NEXT:  .LBB2_2: @ %true
; CHECK-THUMBV6-NEXT:    movs r0, #42
; CHECK-THUMBV6-NEXT:    bl opaque
; CHECK-THUMBV6-NEXT:    pop {r7, pc}
;
; CHECK-THUMBV6T2-LABEL: test_used_flags:
; CHECK-THUMBV6T2:       @ %bb.0:
; CHECK-THUMBV6T2-NEXT:    .save {r7, lr}
; CHECK-THUMBV6T2-NEXT:    push {r7, lr}
; CHECK-THUMBV6T2-NEXT:    smull r0, r1, r0, r1
; CHECK-THUMBV6T2-NEXT:    movs r2, #0
; CHECK-THUMBV6T2-NEXT:    rsbs r0, r0, #0
; CHECK-THUMBV6T2-NEXT:    sbcs.w r0, r2, r1
; CHECK-THUMBV6T2-NEXT:    ite lt
; CHECK-THUMBV6T2-NEXT:    movlt r0, #56
; CHECK-THUMBV6T2-NEXT:    movge r0, #42
; CHECK-THUMBV6T2-NEXT:    bl opaque
; CHECK-THUMBV6T2-NEXT:    pop {r7, pc}
;
; CHECK-V4-THUMBV7M-LABEL: test_used_flags:
; CHECK-V4-THUMBV7M:       @ %bb.0:
; CHECK-V4-THUMBV7M-NEXT:    .save {r7, lr}
; CHECK-V4-THUMBV7M-NEXT:    push {r7, lr}
; CHECK-V4-THUMBV7M-NEXT:    smull r0, r1, r0, r1
; CHECK-V4-THUMBV7M-NEXT:    movs r2, #0
; CHECK-V4-THUMBV7M-NEXT:    rsbs r0, r0, #0
; CHECK-V4-THUMBV7M-NEXT:    sbcs.w r0, r2, r1
; CHECK-V4-THUMBV7M-NEXT:    ite lt
; CHECK-V4-THUMBV7M-NEXT:    movlt r0, #56
; CHECK-V4-THUMBV7M-NEXT:    movge r0, #42
; CHECK-V4-THUMBV7M-NEXT:    bl opaque
; CHECK-V4-THUMBV7M-NEXT:    pop {r7, pc}
  %in1.64 = sext i32 %in1 to i64
  %in2.64 = sext i32 %in2 to i64
  %mul = mul nsw i64 %in1.64, %in2.64
  %tst = icmp slt i64 %mul, 1
  br i1 %tst, label %true, label %false

true:
  call void @opaque(i32 42)
  ret void

false:
  call void @opaque(i32 56)
  ret void
}
