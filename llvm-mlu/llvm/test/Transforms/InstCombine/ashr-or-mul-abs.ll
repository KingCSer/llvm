; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; ((ashr X, 31) | 1 ) * X --> abs(X)
; X * ((ashr X, 31) | 1 ) --> abs(X)

define i32 @ashr_or_mul_to_abs(i32 %X) {
; CHECK-LABEL: @ashr_or_mul_to_abs(
; CHECK-NEXT:    [[I2:%.*]] = call i32 @llvm.abs.i32(i32 [[X:%.*]], i1 true)
; CHECK-NEXT:    ret i32 [[I2]]
;
  %i = ashr i32 %X, 31
  %i1 = or i32 %i, 1
  %i2 = mul nsw i32 %i1, %X
  ret i32 %i2
}

define i32 @ashr_or_mul_to_abs2(i32 %X) {
; CHECK-LABEL: @ashr_or_mul_to_abs2(
; CHECK-NEXT:    [[I2:%.*]] = call i32 @llvm.abs.i32(i32 [[X:%.*]], i1 false)
; CHECK-NEXT:    ret i32 [[I2]]
;
  %i = ashr i32 %X, 31
  %i1 = or i32 %i, 1
  %i2 = mul i32 %i1, %X
  ret i32 %i2
}

define i32 @ashr_or_mul_to_abs3(i32 %PX) {
; CHECK-LABEL: @ashr_or_mul_to_abs3(
; CHECK-NEXT:    [[X:%.*]] = sdiv i32 42, [[PX:%.*]]
; CHECK-NEXT:    [[I2:%.*]] = call i32 @llvm.abs.i32(i32 [[X]], i1 false)
; CHECK-NEXT:    ret i32 [[I2]]
;
  %X = sdiv i32 42, %PX ; thwart complexity-based canonicalization
  %i = ashr i32 %X, 31
  %i1 = or i32 %i, 1
  %i2 = mul i32 %X, %i1
  ret i32 %i2
}


define <4 x i32> @ashr_or_mul_to_abs_vec(<4 x i32> %X) {
; CHECK-LABEL: @ashr_or_mul_to_abs_vec(
; CHECK-NEXT:    [[I2:%.*]] = call <4 x i32> @llvm.abs.v4i32(<4 x i32> [[X:%.*]], i1 false)
; CHECK-NEXT:    ret <4 x i32> [[I2]]
;
  %i = ashr <4 x i32> %X, <i32 31, i32 31, i32 31, i32 31>
  %i1 = or <4 x i32> %i, <i32 1, i32 1, i32 1, i32 1>
  %i2 = mul <4 x i32> %i1, %X
  ret <4 x i32> %i2
}

define <4 x i32> @ashr_or_mul_to_abs_vec2(<4 x i32> %X) {
; CHECK-LABEL: @ashr_or_mul_to_abs_vec2(
; CHECK-NEXT:    [[I2:%.*]] = call <4 x i32> @llvm.abs.v4i32(<4 x i32> [[X:%.*]], i1 true)
; CHECK-NEXT:    ret <4 x i32> [[I2]]
;
  %i = ashr <4 x i32> %X, <i32 31, i32 31, i32 31, i32 31>
  %i1 = or <4 x i32> %i, <i32 1, i32 1, i32 1, i32 1>
  %i2 = mul nsw <4 x i32> %i1, %X
  ret <4 x i32> %i2
}

define <4 x i32> @ashr_or_mul_to_abs_vec3_undef(<4 x i32> %X) {
; CHECK-LABEL: @ashr_or_mul_to_abs_vec3_undef(
; CHECK-NEXT:    [[I2:%.*]] = call <4 x i32> @llvm.abs.v4i32(<4 x i32> [[X:%.*]], i1 false)
; CHECK-NEXT:    ret <4 x i32> [[I2]]
;
  %i = ashr <4 x i32> %X, <i32 31, i32 undef, i32 31, i32 31>
  %i1 = or <4 x i32> %i, <i32 1, i32 1, i32 1, i32 undef>
  %i2 = mul <4 x i32> %i1, %X
  ret <4 x i32> %i2
}

; Negative tests

define i32 @ashr_or_mul_to_abs_neg(i32 %X) {
; CHECK-LABEL: @ashr_or_mul_to_abs_neg(
; CHECK-NEXT:    [[I:%.*]] = ashr i32 [[X:%.*]], 30
; CHECK-NEXT:    [[I1:%.*]] = or i32 [[I]], 1
; CHECK-NEXT:    [[I2:%.*]] = mul nsw i32 [[I1]], [[X]]
; CHECK-NEXT:    ret i32 [[I2]]
;
  %i = ashr i32 %X, 30
  %i1 = or i32 %i, 1
  %i2 = mul nsw i32 %i1, %X
  ret i32 %i2
}

define i32 @ashr_or_mul_to_abs_neg2(i32 %X) {
; CHECK-LABEL: @ashr_or_mul_to_abs_neg2(
; CHECK-NEXT:    [[I:%.*]] = ashr i32 [[X:%.*]], 31
; CHECK-NEXT:    [[I1:%.*]] = or i32 [[I]], 2
; CHECK-NEXT:    [[I2:%.*]] = mul nsw i32 [[I1]], [[X]]
; CHECK-NEXT:    ret i32 [[I2]]
;
  %i = ashr i32 %X, 31
  %i1 = or i32 %i, 2
  %i2 = mul nsw i32 %i1, %X
  ret i32 %i2
}

define i32 @ashr_or_mul_to_abs_neg3(i32 %X, i32 %Y) {
; CHECK-LABEL: @ashr_or_mul_to_abs_neg3(
; CHECK-NEXT:    [[I:%.*]] = ashr i32 [[X:%.*]], 31
; CHECK-NEXT:    [[I1:%.*]] = or i32 [[I]], 1
; CHECK-NEXT:    [[I2:%.*]] = mul nsw i32 [[I1]], [[Y:%.*]]
; CHECK-NEXT:    ret i32 [[I2]]
;
  %i = ashr i32 %X, 31
  %i1 = or i32 %i, 1
  %i2 = mul nsw i32 %i1, %Y
  ret i32 %i2
}
