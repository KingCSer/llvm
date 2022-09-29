; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=pwr8 -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr \
; RUN:   -mtriple=powerpc64le-unknown-unknown < %s | FileCheck %s
; RUN: llc -mcpu=pwr9 -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr \
; RUN:   -mtriple=powerpc64le-unknown-unknown < %s | FileCheck %s \
; RUN:   -check-prefix=CHECK-P9

define void @julia__typed_vcat_20() #0 {
; CHECK-LABEL: julia__typed_vcat_20:
; CHECK:       # %bb.0: # %bb
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -48(r1)
; CHECK-NEXT:    li r3, 1
; CHECK-NEXT:    li r30, 0
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  .LBB0_1: # %bb3
; CHECK-NEXT:    #
; CHECK-NEXT:    addi r3, r3, -1
; CHECK-NEXT:    mtfprd f0, r3
; CHECK-NEXT:    xscvsxdsp f1, f0
; CHECK-NEXT:    bl __gnu_f2h_ieee
; CHECK-NEXT:    nop
; CHECK-NEXT:    clrldi r3, r3, 48
; CHECK-NEXT:    bl __gnu_h2f_ieee
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r30, r30, -1
; CHECK-NEXT:    li r3, 0
; CHECK-NEXT:    cmpldi r30, 0
; CHECK-NEXT:    bne+ cr0, .LBB0_1
; CHECK-NEXT:  # %bb.2: # %bb11
; CHECK-NEXT:    bl __gnu_f2h_ieee
; CHECK-NEXT:    nop
; CHECK-NEXT:    sth r3, 0(r3)
;
; CHECK-P9-LABEL: julia__typed_vcat_20:
; CHECK-P9:       # %bb.0: # %bb
; CHECK-P9-NEXT:    li r3, 0
; CHECK-P9-NEXT:    mtctr r3
; CHECK-P9-NEXT:    li r3, 1
; CHECK-P9-NEXT:    .p2align 4
; CHECK-P9-NEXT:  .LBB0_1: # %bb3
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    addi r3, r3, -1
; CHECK-P9-NEXT:    mtfprd f0, r3
; CHECK-P9-NEXT:    xscvsxdsp f0, f0
; CHECK-P9-NEXT:    xscvdphp f0, f0
; CHECK-P9-NEXT:    mffprwz r3, f0
; CHECK-P9-NEXT:    clrlwi r3, r3, 16
; CHECK-P9-NEXT:    mtfprwz f0, r3
; CHECK-P9-NEXT:    li r3, 0
; CHECK-P9-NEXT:    xscvhpdp f0, f0
; CHECK-P9-NEXT:    bdnz .LBB0_1
; CHECK-P9-NEXT:  # %bb.2: # %bb11
; CHECK-P9-NEXT:    xscvdphp f0, f0
; CHECK-P9-NEXT:    stxsihx f0, 0, r3
bb:
  %i = load i64, i64 addrspace(11)* null, align 8
  %i1 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %i, i64 0)
  %i2 = extractvalue { i64, i1 } %i1, 0
  br label %bb3

bb3:                                              ; preds = %bb3, %bb
  %i4 = phi i64 [ %i10, %bb3 ], [ 1, %bb ]
  %i5 = phi i64 [ 0, %bb3 ], [ 1, %bb ]
  %i6 = add nsw i64 %i5, -1
  %i7 = add i64 %i6, 0
  %i8 = sitofp i64 %i7 to half
  store half %i8, half addrspace(13)* undef, align 2
  %i9 = icmp eq i64 %i4, 0
  %i10 = add i64 %i4, 1
  br i1 %i9, label %bb11, label %bb3

bb11:                                             ; preds = %bb3
  unreachable
}

declare { i64, i1 } @llvm.ssub.with.overflow.i64(i64, i64) #0

define void @julia__hypot_17() #0 {
; CHECK-LABEL: julia__hypot_17:
; CHECK:       # %bb.0: # %bb
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -48(r1)
; CHECK-NEXT:    li r30, 3
; CHECK-NEXT:    .p2align 5
; CHECK-NEXT:  .LBB1_1: # %bb1
; CHECK-NEXT:    #
; CHECK-NEXT:    addi r30, r30, -1
; CHECK-NEXT:    cmpldi r30, 0
; CHECK-NEXT:    beq cr0, .LBB1_3
; CHECK-NEXT:  # %bb.2: # %bb3
; CHECK-NEXT:    #
; CHECK-NEXT:    lhz r3, 0(0)
; CHECK-NEXT:    bl __gnu_h2f_ieee
; CHECK-NEXT:    nop
; CHECK-NEXT:    fcmpu cr0, f1, f1
; CHECK-NEXT:    bun cr0, .LBB1_1
; CHECK-NEXT:  .LBB1_3: # %bb9
; CHECK-NEXT:    addi r1, r1, 48
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P9-LABEL: julia__hypot_17:
; CHECK-P9:       # %bb.0: # %bb
; CHECK-P9-NEXT:    li r3, 3
; CHECK-P9-NEXT:    mtctr r3
; CHECK-P9-NEXT:    li r3, 0
; CHECK-P9-NEXT:    .p2align 5
; CHECK-P9-NEXT:  .LBB1_1: # %bb1
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    bdzlr
; CHECK-P9-NEXT:  # %bb.2: # %bb3
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    lxsihzx f0, 0, r3
; CHECK-P9-NEXT:    xscvhpdp f0, f0
; CHECK-P9-NEXT:    fcmpu cr0, f0, f0
; CHECK-P9-NEXT:    bun cr0, .LBB1_1
; CHECK-P9-NEXT:  # %bb.3: # %bb9
; CHECK-P9-NEXT:    blr
bb:
  br label %bb1

bb1:                                              ; preds = %bb3, %bb
  %i = phi i64 [ %i4, %bb3 ], [ 2, %bb ]
  %i2 = icmp eq i64 %i, 4
  br i1 %i2, label %bb9, label %bb3

bb3:                                              ; preds = %bb1
  %i4 = add nuw nsw i64 %i, 1
  %i5 = load half, half* null, align 2
  %i6 = fpext half %i5 to float
  %i7 = fcmp uno float %i6, 0.000000e+00
  %i8 = or i1 %i7, false
  br i1 %i8, label %bb1, label %bb9

bb9:                                              ; preds = %bb3, %bb1
  ret void
}

define void @func_48786() #0 {
; CHECK-LABEL: func_48786:
; CHECK:       # %bb.0: # %bb
; CHECK-NEXT:    mfocrf r12, 32
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stw r12, 8(r1)
; CHECK-NEXT:    stdu r1, -48(r1)
; CHECK-NEXT:    ld r3, 0(r3)
; CHECK-NEXT:    std r30, 32(r1) # 8-byte Folded Spill
; CHECK-NEXT:    # implicit-def: $x30
; CHECK-NEXT:    cmpdi r3, 0
; CHECK-NEXT:    crnot 4*cr2+lt, eq
; CHECK-NEXT:    bc 12, 4*cr5+lt, .LBB2_3
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  .LBB2_1: # %bb4
; CHECK-NEXT:    lhz r3, 0(r3)
; CHECK-NEXT:    bl __gnu_h2f_ieee
; CHECK-NEXT:    nop
; CHECK-NEXT:    bc 4, 4*cr2+lt, .LBB2_6
; CHECK-NEXT:  # %bb.2: # %bb8
; CHECK-NEXT:    bl __gnu_f2h_ieee
; CHECK-NEXT:    nop
; CHECK-NEXT:    sth r3, 0(0)
; CHECK-NEXT:  .LBB2_3: # %bb10
; CHECK-NEXT:    #
; CHECK-NEXT:    cmpldi r30, 0
; CHECK-NEXT:    beq cr0, .LBB2_5
; CHECK-NEXT:  # %bb.4: # %bb12
; CHECK-NEXT:    #
; CHECK-NEXT:    addi r30, r30, 1
; CHECK-NEXT:    bc 4, 4*cr5+lt, .LBB2_1
; CHECK-NEXT:    b .LBB2_3
; CHECK-NEXT:  .LBB2_5: # %bb14
; CHECK-NEXT:    ld r30, 32(r1) # 8-byte Folded Reload
; CHECK-NEXT:    addi r1, r1, 48
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    lwz r12, 8(r1)
; CHECK-NEXT:    mtocrf 32, r12
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
; CHECK-NEXT:  .LBB2_6: # %bb15
;
; CHECK-P9-LABEL: func_48786:
; CHECK-P9:       # %bb.0: # %bb
; CHECK-P9-NEXT:    ld r3, 0(r3)
; CHECK-P9-NEXT:    cmpdi r3, 0
; CHECK-P9-NEXT:    mtctr r3
; CHECK-P9-NEXT:    li r3, 0
; CHECK-P9-NEXT:    crnot 4*cr5+lt, eq
; CHECK-P9-NEXT:    b .LBB2_2
; CHECK-P9-NEXT:    .p2align 5
; CHECK-P9-NEXT:  .LBB2_1: # %bb10
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    bdzlr
; CHECK-P9-NEXT:  .LBB2_2: # %bb2
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    bc 12, 4*cr5+lt, .LBB2_1
; CHECK-P9-NEXT:  # %bb.3: # %bb4
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    lxsihzx f0, 0, r3
; CHECK-P9-NEXT:    xscvhpdp f0, f0
; CHECK-P9-NEXT:    bc 4, 4*cr5+lt, .LBB2_5
; CHECK-P9-NEXT:  # %bb.4: # %bb8
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    xscvdphp f0, f0
; CHECK-P9-NEXT:    stxsihx f0, 0, r3
; CHECK-P9-NEXT:    b .LBB2_1
; CHECK-P9-NEXT:  .LBB2_5: # %bb15
bb:
  %i = load i64, i64 addrspace(11)* undef, align 8
  %i1 = load i64, i64 addrspace(11)* undef, align 8
  br label %bb2

bb2:                                              ; preds = %bb12, %bb
  %i3 = phi i64 [ undef, %bb ], [ %i13, %bb12 ]
  br i1 undef, label %bb10, label %bb4

bb4:                                              ; preds = %bb2
  switch i32 undef, label %bb9 [
    i32 1426063360, label %bb5
    i32 1275068416, label %bb5
  ]

bb5:                                              ; preds = %bb4, %bb4
  %i6 = load half, half addrspace(13)* undef, align 2
  %i7 = icmp ult i64 0, %i1
  br i1 %i7, label %bb8, label %bb15

bb8:                                              ; preds = %bb5
  store half %i6, half addrspace(13)* null, align 2
  br label %bb10

bb9:                                              ; preds = %bb4
  unreachable

bb10:                                             ; preds = %bb8, %bb2
  %i11 = icmp eq i64 %i3, 0
  br i1 %i11, label %bb14, label %bb12

bb12:                                             ; preds = %bb10
  %i13 = add i64 %i3, 1
  br label %bb2

bb14:                                             ; preds = %bb10
  ret void

bb15:                                             ; preds = %bb5
  unreachable
}

define void @func_48785(half %arg) #0 {
; CHECK-LABEL: func_48785:
; CHECK:       # %bb.0: # %bb
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r29, -32(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r30, -24(r1) # 8-byte Folded Spill
; CHECK-NEXT:    stfd f31, -8(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -64(r1)
; CHECK-NEXT:    fmr f31, f1
; CHECK-NEXT:    li r30, 0
; CHECK-NEXT:    li r29, 0
; CHECK-NEXT:    .p2align 5
; CHECK-NEXT:  .LBB3_1: # %bb1
; CHECK-NEXT:    #
; CHECK-NEXT:    fmr f1, f31
; CHECK-NEXT:    bl __gnu_f2h_ieee
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r29, r29, -12
; CHECK-NEXT:    sth r3, 0(r30)
; CHECK-NEXT:    addi r30, r30, 24
; CHECK-NEXT:    cmpldi r29, 0
; CHECK-NEXT:    bne+ cr0, .LBB3_1
; CHECK-NEXT:  # %bb.2: # %bb5
;
; CHECK-P9-LABEL: func_48785:
; CHECK-P9:       # %bb.0: # %bb
; CHECK-P9-NEXT:    li r3, 1
; CHECK-P9-NEXT:    rldic r3, r3, 62, 1
; CHECK-P9-NEXT:    mtctr r3
; CHECK-P9-NEXT:    li r3, 0
; CHECK-P9-NEXT:    .p2align 4
; CHECK-P9-NEXT:  .LBB3_1: # %bb1
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    xscvdphp f0, f1
; CHECK-P9-NEXT:    stxsihx f0, 0, r3
; CHECK-P9-NEXT:    addi r3, r3, 24
; CHECK-P9-NEXT:    bdnz .LBB3_1
; CHECK-P9-NEXT:  # %bb.2: # %bb5
bb:
  br label %bb1

bb1:                                              ; preds = %bb1, %bb
  %i = phi i64 [ 0, %bb ], [ %i3, %bb1 ]
  %i2 = getelementptr inbounds half, half addrspace(13)* null, i64 %i
  store half %arg, half addrspace(13)* %i2, align 2
  %i3 = add i64 %i, 12
  %i4 = icmp eq i64 %i3, 0
  br i1 %i4, label %bb5, label %bb1

bb5:                                              ; preds = %bb1
  unreachable
}
attributes #0 = { nounwind }
