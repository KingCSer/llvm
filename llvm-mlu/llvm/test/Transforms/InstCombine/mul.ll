; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

declare i32 @llvm.abs.i32(i32, i1)

define i32 @pow2_multiplier(i32 %A) {
; CHECK-LABEL: @pow2_multiplier(
; CHECK-NEXT:    [[B:%.*]] = shl i32 [[A:%.*]], 1
; CHECK-NEXT:    ret i32 [[B]]
;
  %B = mul i32 %A, 2
  ret i32 %B
}

define <2 x i32> @pow2_multiplier_vec(<2 x i32> %A) {
; CHECK-LABEL: @pow2_multiplier_vec(
; CHECK-NEXT:    [[B:%.*]] = shl <2 x i32> [[A:%.*]], <i32 3, i32 3>
; CHECK-NEXT:    ret <2 x i32> [[B]]
;
  %B = mul <2 x i32> %A, <i32 8, i32 8>
  ret <2 x i32> %B
}

define i8 @combine_shl(i8 %A) {
; CHECK-LABEL: @combine_shl(
; CHECK-NEXT:    [[C:%.*]] = shl i8 [[A:%.*]], 6
; CHECK-NEXT:    ret i8 [[C]]
;
  %B = mul i8 %A, 8
  %C = mul i8 %B, 8
  ret i8 %C
}

define i32 @neg(i32 %i) {
; CHECK-LABEL: @neg(
; CHECK-NEXT:    [[T:%.*]] = sub i32 0, [[I:%.*]]
; CHECK-NEXT:    ret i32 [[T]]
;
  %t = mul i32 %i, -1
  ret i32 %t
}

; Use the sign-bit as a mask:
; (zext (A < 0)) * B --> (A >> 31) & B

define i32 @test10(i32 %a, i32 %b) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[TMP1:%.*]] = ashr i32 [[A:%.*]], 31
; CHECK-NEXT:    [[E:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[E]]
;
  %c = icmp slt i32 %a, 0
  %d = zext i1 %c to i32
  %e = mul i32 %d, %b
  ret i32 %e
}

define i32 @test11(i32 %a, i32 %b) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    [[TMP1:%.*]] = ashr i32 [[A:%.*]], 31
; CHECK-NEXT:    [[E:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[E]]
;
  %c = icmp sle i32 %a, -1
  %d = zext i1 %c to i32
  %e = mul i32 %d, %b
  ret i32 %e
}

declare void @use32(i32)

define i32 @test12(i32 %a, i32 %b) {
; CHECK-LABEL: @test12(
; CHECK-NEXT:    [[A_LOBIT:%.*]] = lshr i32 [[A:%.*]], 31
; CHECK-NEXT:    [[TMP1:%.*]] = ashr i32 [[A]], 31
; CHECK-NEXT:    [[E:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[A_LOBIT]])
; CHECK-NEXT:    ret i32 [[E]]
;
  %c = icmp ugt i32 %a, 2147483647
  %d = zext i1 %c to i32
  %e = mul i32 %d, %b
  call void @use32(i32 %d)
  ret i32 %e
}

; rdar://7293527
define i32 @test15(i32 %A, i32 %B) {
; CHECK-LABEL: @test15(
; CHECK-NEXT:    [[M:%.*]] = shl i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[M]]
;
  %shl = shl i32 1, %B
  %m = mul i32 %shl, %A
  ret i32 %m
}

; X * Y (when Y is a boolean) --> Y ? X : 0

define i32 @mul_bool(i32 %x, i1 %y) {
; CHECK-LABEL: @mul_bool(
; CHECK-NEXT:    [[M:%.*]] = select i1 [[Y:%.*]], i32 [[X:%.*]], i32 0
; CHECK-NEXT:    ret i32 [[M]]
;
  %z = zext i1 %y to i32
  %m = mul i32 %x, %z
  ret i32 %m
}

; Commute and test vector type.

define <2 x i32> @mul_bool_vec(<2 x i32> %x, <2 x i1> %y) {
; CHECK-LABEL: @mul_bool_vec(
; CHECK-NEXT:    [[M:%.*]] = select <2 x i1> [[Y:%.*]], <2 x i32> [[X:%.*]], <2 x i32> zeroinitializer
; CHECK-NEXT:    ret <2 x i32> [[M]]
;
  %z = zext <2 x i1> %y to <2 x i32>
  %m = mul <2 x i32> %x, %z
  ret <2 x i32> %m
}

define <2 x i32> @mul_bool_vec_commute(<2 x i32> %x, <2 x i1> %y) {
; CHECK-LABEL: @mul_bool_vec_commute(
; CHECK-NEXT:    [[M:%.*]] = select <2 x i1> [[Y:%.*]], <2 x i32> [[X:%.*]], <2 x i32> zeroinitializer
; CHECK-NEXT:    ret <2 x i32> [[M]]
;
  %z = zext <2 x i1> %y to <2 x i32>
  %m = mul <2 x i32> %z, %x
  ret <2 x i32> %m
}

define <3 x i7> @mul_bools(<3 x i1> %x, <3 x i1> %y) {
; CHECK-LABEL: @mul_bools(
; CHECK-NEXT:    [[MULBOOL:%.*]] = and <3 x i1> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = zext <3 x i1> [[MULBOOL]] to <3 x i7>
; CHECK-NEXT:    ret <3 x i7> [[R]]
;
  %zx = zext <3 x i1> %x to <3 x i7>
  %zy = zext <3 x i1> %y to <3 x i7>
  %r = mul <3 x i7> %zx, %zy
  ret <3 x i7> %r
}

define i32 @mul_bools_use1(i1 %x, i1 %y) {
; CHECK-LABEL: @mul_bools_use1(
; CHECK-NEXT:    [[ZY:%.*]] = zext i1 [[Y:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[ZY]])
; CHECK-NEXT:    [[MULBOOL:%.*]] = and i1 [[X:%.*]], [[Y]]
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[MULBOOL]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %zx = zext i1 %x to i32
  %zy = zext i1 %y to i32
  call void @use32(i32 %zy)
  %r = mul i32 %zx, %zy
  ret i32 %r
}

define i32 @mul_bools_use2(i1 %x, i1 %y) {
; CHECK-LABEL: @mul_bools_use2(
; CHECK-NEXT:    [[ZY:%.*]] = zext i1 [[Y:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[ZY]])
; CHECK-NEXT:    [[MULBOOL:%.*]] = and i1 [[Y]], [[X:%.*]]
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[MULBOOL]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %zx = zext i1 %x to i32
  %zy = zext i1 %y to i32
  call void @use32(i32 %zy)
  %r = mul i32 %zy, %zx
  ret i32 %r
}

define i32 @mul_bools_use3(i1 %x, i1 %y) {
; CHECK-LABEL: @mul_bools_use3(
; CHECK-NEXT:    [[ZX:%.*]] = zext i1 [[X:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[ZX]])
; CHECK-NEXT:    [[ZY:%.*]] = zext i1 [[Y:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[ZY]])
; CHECK-NEXT:    [[R:%.*]] = select i1 [[X]], i32 [[ZY]], i32 0
; CHECK-NEXT:    ret i32 [[R]]
;
  %zx = zext i1 %x to i32
  call void @use32(i32 %zx)
  %zy = zext i1 %y to i32
  call void @use32(i32 %zy)
  %r = mul i32 %zx, %zy
  ret i32 %r
}

define <3 x i32> @mul_bools_sext(<3 x i1> %x, <3 x i1> %y) {
; CHECK-LABEL: @mul_bools_sext(
; CHECK-NEXT:    [[MULBOOL:%.*]] = and <3 x i1> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = zext <3 x i1> [[MULBOOL]] to <3 x i32>
; CHECK-NEXT:    ret <3 x i32> [[R]]
;
  %sx = sext <3 x i1> %x to <3 x i32>
  %sy = sext <3 x i1> %y to <3 x i32>
  %r = mul <3 x i32> %sx, %sy
  ret <3 x i32> %r
}

define i32 @mul_bools_sext_use1(i1 %x, i1 %y) {
; CHECK-LABEL: @mul_bools_sext_use1(
; CHECK-NEXT:    [[SY:%.*]] = sext i1 [[Y:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[SY]])
; CHECK-NEXT:    [[MULBOOL:%.*]] = and i1 [[X:%.*]], [[Y]]
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[MULBOOL]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %sx = sext i1 %x to i32
  %sy = sext i1 %y to i32
  call void @use32(i32 %sy)
  %r = mul i32 %sx, %sy
  ret i32 %r
}

define i32 @mul_bools_sext_use2(i1 %x, i1 %y) {
; CHECK-LABEL: @mul_bools_sext_use2(
; CHECK-NEXT:    [[SY:%.*]] = sext i1 [[Y:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[SY]])
; CHECK-NEXT:    [[MULBOOL:%.*]] = and i1 [[Y]], [[X:%.*]]
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[MULBOOL]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %sx = sext i1 %x to i32
  %sy = sext i1 %y to i32
  call void @use32(i32 %sy)
  %r = mul i32 %sy, %sx
  ret i32 %r
}

define i32 @mul_bools_sext_use3(i1 %x, i1 %y) {
; CHECK-LABEL: @mul_bools_sext_use3(
; CHECK-NEXT:    [[SX:%.*]] = sext i1 [[X:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[SX]])
; CHECK-NEXT:    [[SY:%.*]] = sext i1 [[Y:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[SY]])
; CHECK-NEXT:    [[R:%.*]] = mul nsw i32 [[SY]], [[SX]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %sx = sext i1 %x to i32
  call void @use32(i32 %sx)
  %sy = sext i1 %y to i32
  call void @use32(i32 %sy)
  %r = mul i32 %sy, %sx
  ret i32 %r
}

define i32 @mul_bools_sext_one_use_per_op(i1 %x, i1 %y) {
; CHECK-LABEL: @mul_bools_sext_one_use_per_op(
; CHECK-NEXT:    [[MULBOOL:%.*]] = and i1 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[MULBOOL]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %sx = sext i1 %x to i32
  %sy = sext i1 %y to i32
  %r = mul i32 %sx, %sy
  ret i32 %r
}

define i32 @mul_bool_sext_one_user(i1 %x) {
; CHECK-LABEL: @mul_bool_sext_one_user(
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[X:%.*]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %sx = sext i1 %x to i32
  %r = mul i32 %sx, %sx
  ret i32 %r
}

define i32 @mul_bools_zext_one_use_per_op(i1 %x, i1 %y) {
; CHECK-LABEL: @mul_bools_zext_one_use_per_op(
; CHECK-NEXT:    [[MULBOOL:%.*]] = and i1 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[MULBOOL]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %zx = zext i1 %x to i32
  %zy = zext i1 %y to i32
  %r = mul i32 %zx, %zy
  ret i32 %r
}

define i32 @mul_bool_zext_one_user(i1 %x) {
; CHECK-LABEL: @mul_bool_zext_one_user(
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[X:%.*]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %sx = zext i1 %x to i32
  %r = mul i32 %sx, %sx
  ret i32 %r
}

define i32 @mul_bool_sext_one_extra_user(i1 %x) {
; CHECK-LABEL: @mul_bool_sext_one_extra_user(
; CHECK-NEXT:    [[SX:%.*]] = sext i1 [[X:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[SX]])
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[X]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %sx = sext i1 %x to i32
  call void @use32(i32 %sx)
  %r = mul i32 %sx, %sx
  ret i32 %r
}

define i32 @mul_bool_zext_one_extra_user(i1 %x) {
; CHECK-LABEL: @mul_bool_zext_one_extra_user(
; CHECK-NEXT:    [[SX:%.*]] = zext i1 [[X:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[SX]])
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[X]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %sx = zext i1 %x to i32
  call void @use32(i32 %sx)
  %r = mul i32 %sx, %sx
  ret i32 %r
}

define <3 x i32> @mul_bools_mixed_ext(<3 x i1> %x, <3 x i1> %y) {
; CHECK-LABEL: @mul_bools_mixed_ext(
; CHECK-NEXT:    [[MULBOOL:%.*]] = and <3 x i1> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = sext <3 x i1> [[MULBOOL]] to <3 x i32>
; CHECK-NEXT:    ret <3 x i32> [[R]]
;
  %zx = zext <3 x i1> %x to <3 x i32>
  %sy = sext <3 x i1> %y to <3 x i32>
  %r = mul <3 x i32> %zx, %sy
  ret <3 x i32> %r
}

define i32 @mul_bools_mixed_ext_use1(i1 %x, i1 %y) {
; CHECK-LABEL: @mul_bools_mixed_ext_use1(
; CHECK-NEXT:    [[ZY:%.*]] = zext i1 [[Y:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[ZY]])
; CHECK-NEXT:    [[MULBOOL:%.*]] = and i1 [[X:%.*]], [[Y]]
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[MULBOOL]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %sx = sext i1 %x to i32
  %zy = zext i1 %y to i32
  call void @use32(i32 %zy)
  %r = mul i32 %sx, %zy
  ret i32 %r
}

define i32 @mul_bools_mixed_ext_use2(i1 %x, i1 %y) {
; CHECK-LABEL: @mul_bools_mixed_ext_use2(
; CHECK-NEXT:    [[SY:%.*]] = sext i1 [[Y:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[SY]])
; CHECK-NEXT:    [[MULBOOL:%.*]] = and i1 [[Y]], [[X:%.*]]
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[MULBOOL]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %zx = zext i1 %x to i32
  %sy = sext i1 %y to i32
  call void @use32(i32 %sy)
  %r = mul i32 %sy, %zx
  ret i32 %r
}

define i32 @mul_bools_mixed_ext_use3(i1 %x, i1 %y) {
; CHECK-LABEL: @mul_bools_mixed_ext_use3(
; CHECK-NEXT:    [[SX:%.*]] = sext i1 [[X:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[SX]])
; CHECK-NEXT:    [[ZY:%.*]] = zext i1 [[Y:%.*]] to i32
; CHECK-NEXT:    call void @use32(i32 [[ZY]])
; CHECK-NEXT:    [[R:%.*]] = select i1 [[Y]], i32 [[SX]], i32 0
; CHECK-NEXT:    ret i32 [[R]]
;
  %sx = sext i1 %x to i32
  call void @use32(i32 %sx)
  %zy = zext i1 %y to i32
  call void @use32(i32 %zy)
  %r = mul i32 %zy, %sx
  ret i32 %r
}

; (A >>u 31) * B --> (A >>s 31) & B

define i32 @signbit_mul(i32 %a, i32 %b) {
; CHECK-LABEL: @signbit_mul(
; CHECK-NEXT:    [[TMP1:%.*]] = ashr i32 [[A:%.*]], 31
; CHECK-NEXT:    [[E:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[E]]
;
  %d = lshr i32 %a, 31
  %e = mul i32 %d, %b
  ret i32 %e
}

define i32 @signbit_mul_commute_extra_use(i32 %a, i32 %b) {
; CHECK-LABEL: @signbit_mul_commute_extra_use(
; CHECK-NEXT:    [[D:%.*]] = lshr i32 [[A:%.*]], 31
; CHECK-NEXT:    [[TMP1:%.*]] = ashr i32 [[A]], 31
; CHECK-NEXT:    [[E:%.*]] = and i32 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[D]])
; CHECK-NEXT:    ret i32 [[E]]
;
  %d = lshr i32 %a, 31
  %e = mul i32 %b, %d
  call void @use32(i32 %d)
  ret i32 %e
}

; (A >>u 31)) * B --> (A >>s 31) & B

define <2 x i32> @signbit_mul_vec(<2 x i32> %a, <2 x i32> %b) {
; CHECK-LABEL: @signbit_mul_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = ashr <2 x i32> [[A:%.*]], <i32 31, i32 31>
; CHECK-NEXT:    [[E:%.*]] = and <2 x i32> [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret <2 x i32> [[E]]
;
  %d = lshr <2 x i32> %a, <i32 31, i32 31>
  %e = mul <2 x i32> %d, %b
  ret <2 x i32> %e
}

define <2 x i32> @signbit_mul_vec_commute(<2 x i32> %a, <2 x i32> %b) {
; CHECK-LABEL: @signbit_mul_vec_commute(
; CHECK-NEXT:    [[TMP1:%.*]] = ashr <2 x i32> [[A:%.*]], <i32 31, i32 31>
; CHECK-NEXT:    [[E:%.*]] = and <2 x i32> [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret <2 x i32> [[E]]
;
  %d = lshr <2 x i32> %a, <i32 31, i32 31>
  %e = mul <2 x i32> %b, %d
  ret <2 x i32> %e
}

define i32 @test18(i32 %A, i32 %B) {
; CHECK-LABEL: @test18(
; CHECK-NEXT:    ret i32 0
;
  %C = and i32 %A, 1
  %D = and i32 %B, 1
  %E = mul i32 %C, %D
  %F = and i32 %E, 16
  ret i32 %F
}

declare {i32, i1} @llvm.smul.with.overflow.i32(i32, i32)
declare void @use(i1)

define i32 @test19(i32 %A, i32 %B) {
; CHECK-LABEL: @test19(
; CHECK-NEXT:    call void @use(i1 false)
; CHECK-NEXT:    ret i32 0
;
  %C = and i32 %A, 1
  %D = and i32 %B, 1

; It would be nice if we also started proving that this doesn't overflow.
  %E = call {i32, i1} @llvm.smul.with.overflow.i32(i32 %C, i32 %D)
  %F = extractvalue {i32, i1} %E, 0
  %G = extractvalue {i32, i1} %E, 1
  call void @use(i1 %G)
  %H = and i32 %F, 16
  ret i32 %H
}

define <2 x i64> @test20(<2 x i64> %A) {
; CHECK-LABEL: @test20(
; CHECK-NEXT:    [[TMP1:%.*]] = mul <2 x i64> [[A:%.*]], <i64 3, i64 2>
; CHECK-NEXT:    [[C:%.*]] = add <2 x i64> [[TMP1]], <i64 36, i64 28>
; CHECK-NEXT:    ret <2 x i64> [[C]]
;
  %B = add <2 x i64> %A, <i64 12, i64 14>
  %C = mul <2 x i64> %B, <i64 3, i64 2>
  ret <2 x i64> %C
}

define <2 x i1> @test21(<2 x i1> %A, <2 x i1> %B) {
; CHECK-LABEL: @test21(
; CHECK-NEXT:    [[C:%.*]] = and <2 x i1> [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %C = mul <2 x i1> %A, %B
  ret <2 x i1> %C
}

define i32 @test22(i32 %A) {
; CHECK-LABEL: @test22(
; CHECK-NEXT:    [[B:%.*]] = sub nsw i32 0, [[A:%.*]]
; CHECK-NEXT:    ret i32 [[B]]
;
  %B = mul nsw i32 %A, -1
  ret i32 %B
}

define i32 @test23(i32 %A) {
; CHECK-LABEL: @test23(
; CHECK-NEXT:    [[C:%.*]] = mul nuw i32 [[A:%.*]], 6
; CHECK-NEXT:    ret i32 [[C]]
;
  %B = shl nuw i32 %A, 1
  %C = mul nuw i32 %B, 3
  ret i32 %C
}

define i32 @test24(i32 %A) {
; CHECK-LABEL: @test24(
; CHECK-NEXT:    [[C:%.*]] = mul nsw i32 [[A:%.*]], 6
; CHECK-NEXT:    ret i32 [[C]]
;
  %B = shl nsw i32 %A, 1
  %C = mul nsw i32 %B, 3
  ret i32 %C
}

define i32 @neg_neg_mul(i32 %A, i32 %B) {
; CHECK-LABEL: @neg_neg_mul(
; CHECK-NEXT:    [[E:%.*]] = mul i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[E]]
;
  %C = sub i32 0, %A
  %D = sub i32 0, %B
  %E = mul i32 %C, %D
  ret i32 %E
}

define i32 @neg_neg_mul_nsw(i32 %A, i32 %B) {
; CHECK-LABEL: @neg_neg_mul_nsw(
; CHECK-NEXT:    [[E:%.*]] = mul nsw i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[E]]
;
  %C = sub nsw i32 0, %A
  %D = sub nsw i32 0, %B
  %E = mul nsw i32 %C, %D
  ret i32 %E
}

define i124 @neg_neg_mul_apint(i124 %A, i124 %B) {
; CHECK-LABEL: @neg_neg_mul_apint(
; CHECK-NEXT:    [[E:%.*]] = mul i124 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    ret i124 [[E]]
;
  %C = sub i124 0, %A
  %D = sub i124 0, %B
  %E = mul i124 %C, %D
  ret i124 %E
}

define i32 @neg_mul_constant(i32 %A) {
; CHECK-LABEL: @neg_mul_constant(
; CHECK-NEXT:    [[E:%.*]] = mul i32 [[A:%.*]], -7
; CHECK-NEXT:    ret i32 [[E]]
;
  %C = sub i32 0, %A
  %E = mul i32 %C, 7
  ret i32 %E
}

define i55 @neg_mul_constant_apint(i55 %A) {
; CHECK-LABEL: @neg_mul_constant_apint(
; CHECK-NEXT:    [[E:%.*]] = mul i55 [[A:%.*]], -7
; CHECK-NEXT:    ret i55 [[E]]
;
  %C = sub i55 0, %A
  %E = mul i55 %C, 7
  ret i55 %E
}

define <3 x i8> @neg_mul_constant_vec(<3 x i8> %a) {
; CHECK-LABEL: @neg_mul_constant_vec(
; CHECK-NEXT:    [[B:%.*]] = mul <3 x i8> [[A:%.*]], <i8 -5, i8 -5, i8 -5>
; CHECK-NEXT:    ret <3 x i8> [[B]]
;
  %A = sub <3 x i8> zeroinitializer, %a
  %B = mul <3 x i8> %A, <i8 5, i8 5, i8 5>
  ret <3 x i8> %B
}

define <3 x i4> @neg_mul_constant_vec_weird(<3 x i4> %a) {
; CHECK-LABEL: @neg_mul_constant_vec_weird(
; CHECK-NEXT:    [[B:%.*]] = mul <3 x i4> [[A:%.*]], <i4 -5, i4 -5, i4 -5>
; CHECK-NEXT:    ret <3 x i4> [[B]]
;
  %A = sub <3 x i4> zeroinitializer, %a
  %B = mul <3 x i4> %A, <i4 5, i4 5, i4 5>
  ret <3 x i4> %B
}

define i32 @test26(i32 %A, i32 %B) {
; CHECK-LABEL: @test26(
; CHECK-NEXT:    [[D:%.*]] = shl nsw i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %C = shl nsw i32 1, %B
  %D = mul nsw i32 %A, %C
  ret i32 %D
}

define i32 @test27(i32 %A, i32 %B) {
; CHECK-LABEL: @test27(
; CHECK-NEXT:    [[D:%.*]] = shl nuw i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %C = shl i32 1, %B
  %D = mul nuw i32 %A, %C
  ret i32 %D
}

define i32 @test28(i32 %A) {
; CHECK-LABEL: @test28(
; CHECK-NEXT:    [[B:%.*]] = shl i32 1, [[A:%.*]]
; CHECK-NEXT:    [[C:%.*]] = shl i32 [[B]], [[A]]
; CHECK-NEXT:    ret i32 [[C]]
;
  %B = shl i32 1, %A
  %C = mul nsw i32 %B, %B
  ret i32 %C
}

define i64 @test29(i31 %A, i31 %B) {
; CHECK-LABEL: @test29(
; CHECK-NEXT:    [[C:%.*]] = sext i31 [[A:%.*]] to i64
; CHECK-NEXT:    [[D:%.*]] = sext i31 [[B:%.*]] to i64
; CHECK-NEXT:    [[E:%.*]] = mul nsw i64 [[C]], [[D]]
; CHECK-NEXT:    ret i64 [[E]]
;
  %C = sext i31 %A to i64
  %D = sext i31 %B to i64
  %E = mul i64 %C, %D
  ret i64 %E
}

define i64 @test30(i32 %A, i32 %B) {
; CHECK-LABEL: @test30(
; CHECK-NEXT:    [[C:%.*]] = zext i32 [[A:%.*]] to i64
; CHECK-NEXT:    [[D:%.*]] = zext i32 [[B:%.*]] to i64
; CHECK-NEXT:    [[E:%.*]] = mul nuw i64 [[C]], [[D]]
; CHECK-NEXT:    ret i64 [[E]]
;
  %C = zext i32 %A to i64
  %D = zext i32 %B to i64
  %E = mul i64 %C, %D
  ret i64 %E
}

@PR22087 = external global i32
define i32 @test31(i32 %V) {
; CHECK-LABEL: @test31(
; CHECK-NEXT:    [[MUL:%.*]] = shl i32 [[V:%.*]], zext (i1 icmp ne (i32* inttoptr (i64 1 to i32*), i32* @PR22087) to i32)
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %mul = mul i32 %V, shl (i32 1, i32 zext (i1 icmp ne (i32* inttoptr (i64 1 to i32*), i32* @PR22087) to i32))
  ret i32 %mul
}

define i32 @test32(i32 %X) {
; CHECK-LABEL: @test32(
; CHECK-NEXT:    [[MUL:%.*]] = shl i32 [[X:%.*]], 31
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %mul = mul nsw i32 %X, -2147483648
  ret i32 %mul
}

define <2 x i32> @test32vec(<2 x i32> %X) {
; CHECK-LABEL: @test32vec(
; CHECK-NEXT:    [[MUL:%.*]] = shl <2 x i32> [[X:%.*]], <i32 31, i32 31>
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %mul = mul nsw <2 x i32> %X, <i32 -2147483648, i32 -2147483648>
  ret <2 x i32> %mul
}

define i32 @test33(i32 %X) {
; CHECK-LABEL: @test33(
; CHECK-NEXT:    [[MUL:%.*]] = shl nsw i32 [[X:%.*]], 30
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %mul = mul nsw i32 %X, 1073741824
  ret i32 %mul
}

define <2 x i32> @test33vec(<2 x i32> %X) {
; CHECK-LABEL: @test33vec(
; CHECK-NEXT:    [[MUL:%.*]] = shl nsw <2 x i32> [[X:%.*]], <i32 30, i32 30>
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %mul = mul nsw <2 x i32> %X, <i32 1073741824, i32 1073741824>
  ret <2 x i32> %mul
}

define i128 @test34(i128 %X) {
; CHECK-LABEL: @test34(
; CHECK-NEXT:    [[MUL:%.*]] = shl nsw i128 [[X:%.*]], 1
; CHECK-NEXT:    ret i128 [[MUL]]
;
  %mul = mul nsw i128 %X, 2
  ret i128 %mul
}

define i32 @test_mul_canonicalize_op0(i32 %x, i32 %y) {
; CHECK-LABEL: @test_mul_canonicalize_op0(
; CHECK-NEXT:    [[TMP1:%.*]] = mul i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = sub i32 0, [[TMP1]]
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %neg = sub i32 0, %x
  %mul = mul i32 %neg, %y
  ret i32 %mul
}

define i32 @test_mul_canonicalize_op1(i32 %x, i32 %z) {
; CHECK-LABEL: @test_mul_canonicalize_op1(
; CHECK-NEXT:    [[Y_NEG:%.*]] = mul i32 [[Z:%.*]], -3
; CHECK-NEXT:    [[DOTNEG:%.*]] = mul i32 [[Y_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i32 [[DOTNEG]]
;
  %y = mul i32 %z, 3
  %neg = sub i32 0, %x
  %mul = mul i32 %y, %neg
  ret i32 %mul
}

define i32 @test_mul_canonicalize_nsw(i32 %x, i32 %y) {
; CHECK-LABEL: @test_mul_canonicalize_nsw(
; CHECK-NEXT:    [[TMP1:%.*]] = mul i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = sub i32 0, [[TMP1]]
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %neg = sub nsw i32 0, %x
  %mul = mul nsw i32 %neg, %y
  ret i32 %mul
}

define <2 x i32> @test_mul_canonicalize_vec(<2 x i32> %x, <2 x i32> %y) {
; CHECK-LABEL: @test_mul_canonicalize_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = mul <2 x i32> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = sub <2 x i32> zeroinitializer, [[TMP1]]
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %neg = sub <2 x i32> <i32 0, i32 0>, %x
  %mul = mul <2 x i32> %neg, %y
  ret <2 x i32> %mul
}

define i32 @test_mul_canonicalize_multiple_uses(i32 %x, i32 %y) {
; CHECK-LABEL: @test_mul_canonicalize_multiple_uses(
; CHECK-NEXT:    [[NEG:%.*]] = sub i32 0, [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = mul i32 [[NEG]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL2:%.*]] = mul i32 [[MUL]], [[NEG]]
; CHECK-NEXT:    ret i32 [[MUL2]]
;
  %neg = sub i32 0, %x
  %mul = mul i32 %neg, %y
  %mul2 = mul i32 %mul, %neg
  ret i32 %mul2
}

@X = global i32 5

define i64 @test_mul_canonicalize_neg_is_not_undone(i64 %L1) {
; Check we do not undo the canonicalization of 0 - (X * Y), if Y is a constant
; expr.
; CHECK-LABEL: @test_mul_canonicalize_neg_is_not_undone(
; CHECK-NEXT:    [[TMP1:%.*]] = mul i64 [[L1:%.*]], ptrtoint (i32* @X to i64)
; CHECK-NEXT:    [[B4:%.*]] = sub i64 0, [[TMP1]]
; CHECK-NEXT:    ret i64 [[B4]]
;
  %v1 = ptrtoint i32* @X to i64
  %B8 = sub i64 0, %v1
  %B4 = mul i64 %B8, %L1
  ret i64 %B4
}

define i32 @negate_if_true(i32 %x, i1 %cond) {
; CHECK-LABEL: @negate_if_true(
; CHECK-NEXT:    [[TMP1:%.*]] = sub i32 0, [[X:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[COND:%.*]], i32 [[TMP1]], i32 [[X]]
; CHECK-NEXT:    ret i32 [[TMP2]]
;
  %sel = select i1 %cond, i32 -1, i32 1
  %r = mul i32 %sel, %x
  ret i32 %r
}

define i32 @negate_if_false(i32 %x, i1 %cond) {
; CHECK-LABEL: @negate_if_false(
; CHECK-NEXT:    [[TMP1:%.*]] = sub i32 0, [[X:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[COND:%.*]], i32 [[X]], i32 [[TMP1]]
; CHECK-NEXT:    ret i32 [[TMP2]]
;
  %sel = select i1 %cond, i32 1, i32 -1
  %r = mul i32 %sel, %x
  ret i32 %r
}

define <2 x i8> @negate_if_true_commute(<2 x i8> %px, i1 %cond) {
; CHECK-LABEL: @negate_if_true_commute(
; CHECK-NEXT:    [[X:%.*]] = sdiv <2 x i8> <i8 42, i8 42>, [[PX:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = sub nsw <2 x i8> zeroinitializer, [[X]]
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[COND:%.*]], <2 x i8> [[TMP1]], <2 x i8> [[X]]
; CHECK-NEXT:    ret <2 x i8> [[TMP2]]
;
  %x = sdiv <2 x i8> <i8 42, i8 42>, %px  ; thwart complexity-based canonicalization
  %sel = select i1 %cond, <2 x i8> <i8 -1, i8 -1>, <2 x i8> <i8 1, i8 1>
  %r = mul <2 x i8> %x, %sel
  ret <2 x i8> %r
}

define <2 x i8> @negate_if_false_commute(<2 x i8> %px, <2 x i1> %cond) {
; CHECK-LABEL: @negate_if_false_commute(
; CHECK-NEXT:    [[X:%.*]] = sdiv <2 x i8> <i8 42, i8 5>, [[PX:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = sub <2 x i8> zeroinitializer, [[X]]
; CHECK-NEXT:    [[TMP2:%.*]] = select <2 x i1> [[COND:%.*]], <2 x i8> [[X]], <2 x i8> [[TMP1]]
; CHECK-NEXT:    ret <2 x i8> [[TMP2]]
;
  %x = sdiv <2 x i8> <i8 42, i8 5>, %px  ; thwart complexity-based canonicalization
  %sel = select <2 x i1> %cond, <2 x i8> <i8 1, i8 undef>, <2 x i8> <i8 -1, i8 -1>
  %r = mul <2 x i8> %x, %sel
  ret <2 x i8> %r
}

; Negative test

define i32 @negate_if_true_extra_use(i32 %x, i1 %cond) {
; CHECK-LABEL: @negate_if_true_extra_use(
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[COND:%.*]], i32 -1, i32 1
; CHECK-NEXT:    call void @use32(i32 [[SEL]])
; CHECK-NEXT:    [[R:%.*]] = mul i32 [[SEL]], [[X:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %sel = select i1 %cond, i32 -1, i32 1
  call void @use32(i32 %sel)
  %r = mul i32 %sel, %x
  ret i32 %r
}

; Negative test

define <2 x i8> @negate_if_true_wrong_constant(<2 x i8> %px, i1 %cond) {
; CHECK-LABEL: @negate_if_true_wrong_constant(
; CHECK-NEXT:    [[X:%.*]] = sdiv <2 x i8> <i8 42, i8 42>, [[PX:%.*]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[COND:%.*]], <2 x i8> <i8 -1, i8 0>, <2 x i8> <i8 1, i8 1>
; CHECK-NEXT:    [[R:%.*]] = mul <2 x i8> [[X]], [[SEL]]
; CHECK-NEXT:    ret <2 x i8> [[R]]
;
  %x = sdiv <2 x i8> <i8 42, i8 42>, %px  ; thwart complexity-based canonicalization
  %sel = select i1 %cond, <2 x i8> <i8 -1, i8 0>, <2 x i8> <i8 1, i8 1>
  %r = mul <2 x i8> %x, %sel
  ret <2 x i8> %r
}

; (C ? (X /exact Y) : 1) * Y -> C ? X : Y
define i32 @mul_div_select(i32 %x, i32 %y, i1 %c) {
; CHECK-LABEL: @mul_div_select(
; CHECK-NEXT:    [[MUL:%.*]] = select i1 [[C:%.*]], i32 [[X:%.*]], i32 [[Y:%.*]]
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %div = udiv exact i32 %x, %y
  %sel = select i1 %c, i32 %div, i32 1
  %mul = mul i32 %sel, %y
  ret i32 %mul
}

; fold mul(abs(x),abs(x)) -> mul(x,x)
define i31 @combine_mul_abs_i31(i31 %0) {
; CHECK-LABEL: @combine_mul_abs_i31(
; CHECK-NEXT:    [[M:%.*]] = mul i31 [[TMP0:%.*]], [[TMP0]]
; CHECK-NEXT:    ret i31 [[M]]
;
  %c = icmp slt i31 %0, 0
  %s = sub nsw i31 0, %0
  %r = select i1 %c, i31 %s, i31 %0
  %m = mul i31 %r, %r
  ret i31 %m
}

define i32 @combine_mul_abs_i32(i32 %0) {
; CHECK-LABEL: @combine_mul_abs_i32(
; CHECK-NEXT:    [[M:%.*]] = mul i32 [[TMP0:%.*]], [[TMP0]]
; CHECK-NEXT:    ret i32 [[M]]
;
  %c = icmp slt i32 %0, 0
  %s = sub nsw i32 0, %0
  %r = select i1 %c, i32 %s, i32 %0
  %m = mul i32 %r, %r
  ret i32 %m
}

define <4 x i32> @combine_mul_abs_v4i32(<4 x i32> %0) {
; CHECK-LABEL: @combine_mul_abs_v4i32(
; CHECK-NEXT:    [[M:%.*]] = mul <4 x i32> [[TMP0:%.*]], [[TMP0]]
; CHECK-NEXT:    ret <4 x i32> [[M]]
;
  %c = icmp slt <4 x i32> %0, zeroinitializer
  %s = sub nsw <4 x i32> zeroinitializer, %0
  %r = select <4 x i1> %c, <4 x i32> %s, <4 x i32> %0
  %m = mul <4 x i32> %r, %r
  ret <4 x i32> %m
}

; fold mul(nabs(x),nabs(x)) -> mul(x,x)
define i31 @combine_mul_nabs_i31(i31 %0) {
; CHECK-LABEL: @combine_mul_nabs_i31(
; CHECK-NEXT:    [[M:%.*]] = mul i31 [[TMP0:%.*]], [[TMP0]]
; CHECK-NEXT:    ret i31 [[M]]
;
  %c = icmp slt i31 %0, 0
  %s = sub nsw i31 0, %0
  %r = select i1 %c, i31 %0, i31 %s
  %m = mul i31 %r, %r
  ret i31 %m
}

define i32 @combine_mul_nabs_i32(i32 %0) {
; CHECK-LABEL: @combine_mul_nabs_i32(
; CHECK-NEXT:    [[M:%.*]] = mul i32 [[TMP0:%.*]], [[TMP0]]
; CHECK-NEXT:    ret i32 [[M]]
;
  %c = icmp slt i32 %0, 0
  %s = sub nsw i32 0, %0
  %r = select i1 %c, i32 %0, i32 %s
  %m = mul i32 %r, %r
  ret i32 %m
}

define <4 x i32> @combine_mul_nabs_v4i32(<4 x i32> %0) {
; CHECK-LABEL: @combine_mul_nabs_v4i32(
; CHECK-NEXT:    [[M:%.*]] = mul <4 x i32> [[TMP0:%.*]], [[TMP0]]
; CHECK-NEXT:    ret <4 x i32> [[M]]
;
  %c = icmp slt <4 x i32> %0, zeroinitializer
  %s = sub nsw <4 x i32> zeroinitializer, %0
  %r = select <4 x i1> %c, <4 x i32> %0, <4 x i32> %s
  %m = mul <4 x i32> %r, %r
  ret <4 x i32> %m
}

define i32 @combine_mul_abs_intrin(i32 %x) {
; CHECK-LABEL: @combine_mul_abs_intrin(
; CHECK-NEXT:    [[MUL:%.*]] = mul i32 [[X:%.*]], [[X]]
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %abs = call i32 @llvm.abs.i32(i32 %x, i1 false)
  %mul = mul i32 %abs, %abs
  ret i32 %mul
}

define i32 @combine_mul_nabs_intrin(i32 %x) {
; CHECK-LABEL: @combine_mul_nabs_intrin(
; CHECK-NEXT:    [[MUL:%.*]] = mul i32 [[X:%.*]], [[X]]
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %abs = call i32 @llvm.abs.i32(i32 %x, i1 false)
  %neg = sub i32 0, %abs
  %mul = mul i32 %neg, %neg
  ret i32 %mul
}

; z * splat(0) = splat(0), even for scalable vectors
define <vscale x 2 x i64> @mul_scalable_splat_zero(<vscale x 2 x i64> %z) {
; CHECK-LABEL: @mul_scalable_splat_zero(
; CHECK-NEXT:    ret <vscale x 2 x i64> zeroinitializer
;
  %shuf = shufflevector <vscale x 2 x i64> insertelement (<vscale x 2 x i64> undef, i64 0, i32 0), <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %t3 = mul <vscale x 2 x i64> %shuf, %z
  ret <vscale x 2 x i64> %t3
}

;
; fold mul(sub(x,y),negpow2) -> shl(sub(y,x),log2(pow2))
;

define i32 @mulsub1(i32 %a0, i32 %a1) {
; CHECK-LABEL: @mulsub1(
; CHECK-NEXT:    [[SUB_NEG:%.*]] = sub i32 [[A0:%.*]], [[A1:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = shl i32 [[SUB_NEG]], 2
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %sub = sub i32 %a1, %a0
  %mul = mul i32 %sub, -4
  ret i32 %mul
}

define <2 x i32> @mulsub1_vec(<2 x i32> %a0, <2 x i32> %a1) {
; CHECK-LABEL: @mulsub1_vec(
; CHECK-NEXT:    [[SUB_NEG:%.*]] = sub <2 x i32> [[A0:%.*]], [[A1:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = shl <2 x i32> [[SUB_NEG]], <i32 2, i32 2>
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %sub = sub <2 x i32> %a1, %a0
  %mul = mul <2 x i32> %sub, <i32 -4, i32 -4>
  ret <2 x i32> %mul
}

define <2 x i32> @mulsub1_vec_nonuniform(<2 x i32> %a0, <2 x i32> %a1) {
; CHECK-LABEL: @mulsub1_vec_nonuniform(
; CHECK-NEXT:    [[SUB_NEG:%.*]] = sub <2 x i32> [[A0:%.*]], [[A1:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = shl <2 x i32> [[SUB_NEG]], <i32 2, i32 3>
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %sub = sub <2 x i32> %a1, %a0
  %mul = mul <2 x i32> %sub, <i32 -4, i32 -8>
  ret <2 x i32> %mul
}

define <2 x i32> @mulsub1_vec_nonuniform_undef(<2 x i32> %a0, <2 x i32> %a1) {
; CHECK-LABEL: @mulsub1_vec_nonuniform_undef(
; CHECK-NEXT:    [[SUB_NEG:%.*]] = sub <2 x i32> [[A0:%.*]], [[A1:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = shl <2 x i32> [[SUB_NEG]], <i32 2, i32 0>
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %sub = sub <2 x i32> %a1, %a0
  %mul = mul <2 x i32> %sub, <i32 -4, i32 undef>
  ret <2 x i32> %mul
}

define i32 @mulsub2(i32 %a0) {
; CHECK-LABEL: @mulsub2(
; CHECK-NEXT:    [[SUB_NEG:%.*]] = shl i32 [[A0:%.*]], 2
; CHECK-NEXT:    [[MUL:%.*]] = add i32 [[SUB_NEG]], -64
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %sub = sub i32 16, %a0
  %mul = mul i32 %sub, -4
  ret i32 %mul
}

define <2 x i32> @mulsub2_vec(<2 x i32> %a0) {
; CHECK-LABEL: @mulsub2_vec(
; CHECK-NEXT:    [[SUB_NEG:%.*]] = shl <2 x i32> [[A0:%.*]], <i32 2, i32 2>
; CHECK-NEXT:    [[MUL:%.*]] = add <2 x i32> [[SUB_NEG]], <i32 -64, i32 -64>
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %sub = sub <2 x i32> <i32 16, i32 16>, %a0
  %mul = mul <2 x i32> %sub, <i32 -4, i32 -4>
  ret <2 x i32> %mul
}

define <2 x i32> @mulsub2_vec_nonuniform(<2 x i32> %a0) {
; CHECK-LABEL: @mulsub2_vec_nonuniform(
; CHECK-NEXT:    [[SUB_NEG:%.*]] = add <2 x i32> [[A0:%.*]], <i32 -16, i32 -32>
; CHECK-NEXT:    [[MUL:%.*]] = shl <2 x i32> [[SUB_NEG]], <i32 2, i32 3>
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %sub = sub <2 x i32> <i32 16, i32 32>, %a0
  %mul = mul <2 x i32> %sub, <i32 -4, i32 -8>
  ret <2 x i32> %mul
}

define <2 x i32> @mulsub2_vec_nonuniform_undef(<2 x i32> %a0) {
; CHECK-LABEL: @mulsub2_vec_nonuniform_undef(
; CHECK-NEXT:    [[SUB_NEG:%.*]] = add <2 x i32> [[A0:%.*]], <i32 -16, i32 -32>
; CHECK-NEXT:    [[MUL:%.*]] = shl <2 x i32> [[SUB_NEG]], <i32 2, i32 0>
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %sub = sub <2 x i32> <i32 16, i32 32>, %a0
  %mul = mul <2 x i32> %sub, <i32 -4, i32 undef>
  ret <2 x i32> %mul
}

define i32 @muladd2(i32 %a0) {
; CHECK-LABEL: @muladd2(
; CHECK-NEXT:    [[ADD_NEG_NEG:%.*]] = mul i32 [[A0:%.*]], -4
; CHECK-NEXT:    [[MUL:%.*]] = add i32 [[ADD_NEG_NEG]], -64
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %add = add i32 %a0, 16
  %mul = mul i32 %add, -4
  ret i32 %mul
}

define <2 x i32> @muladd2_vec(<2 x i32> %a0) {
; CHECK-LABEL: @muladd2_vec(
; CHECK-NEXT:    [[ADD_NEG_NEG:%.*]] = mul <2 x i32> [[A0:%.*]], <i32 -4, i32 -4>
; CHECK-NEXT:    [[MUL:%.*]] = add <2 x i32> [[ADD_NEG_NEG]], <i32 -64, i32 -64>
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %add = add <2 x i32> %a0, <i32 16, i32 16>
  %mul = mul <2 x i32> %add, <i32 -4, i32 -4>
  ret <2 x i32> %mul
}

define <2 x i32> @muladd2_vec_nonuniform(<2 x i32> %a0) {
; CHECK-LABEL: @muladd2_vec_nonuniform(
; CHECK-NEXT:    [[ADD_NEG:%.*]] = sub <2 x i32> <i32 -16, i32 -32>, [[A0:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = shl <2 x i32> [[ADD_NEG]], <i32 2, i32 3>
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %add = add <2 x i32> %a0, <i32 16, i32 32>
  %mul = mul <2 x i32> %add, <i32 -4, i32 -8>
  ret <2 x i32> %mul
}

define <2 x i32> @muladd2_vec_nonuniform_undef(<2 x i32> %a0) {
; CHECK-LABEL: @muladd2_vec_nonuniform_undef(
; CHECK-NEXT:    [[ADD_NEG:%.*]] = sub <2 x i32> <i32 -16, i32 -32>, [[A0:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = shl <2 x i32> [[ADD_NEG]], <i32 2, i32 0>
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %add = add <2 x i32> %a0, <i32 16, i32 32>
  %mul = mul <2 x i32> %add, <i32 -4, i32 undef>
  ret <2 x i32> %mul
}

define i32 @mulmuladd2(i32 %a0, i32 %a1) {
; CHECK-LABEL: @mulmuladd2(
; CHECK-NEXT:    [[ADD_NEG:%.*]] = sub i32 -16, [[A0:%.*]]
; CHECK-NEXT:    [[MUL1_NEG:%.*]] = mul i32 [[ADD_NEG]], [[A1:%.*]]
; CHECK-NEXT:    [[MUL2:%.*]] = shl i32 [[MUL1_NEG]], 2
; CHECK-NEXT:    ret i32 [[MUL2]]
;
  %add = add i32 %a0, 16
  %mul1 = mul i32 %add, %a1
  %mul2 = mul i32 %mul1, -4
  ret i32 %mul2
}
define i32 @mulmuladd2_extrause0(i32 %a0, i32 %a1) {
; CHECK-LABEL: @mulmuladd2_extrause0(
; CHECK-NEXT:    [[ADD:%.*]] = add i32 [[A0:%.*]], 16
; CHECK-NEXT:    [[MUL1:%.*]] = mul i32 [[ADD]], [[A1:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[MUL1]])
; CHECK-NEXT:    [[MUL2:%.*]] = mul i32 [[MUL1]], -4
; CHECK-NEXT:    ret i32 [[MUL2]]
;
  %add = add i32 %a0, 16
  %mul1 = mul i32 %add, %a1
  call void @use32(i32 %mul1)
  %mul2 = mul i32 %mul1, -4
  ret i32 %mul2
}
define i32 @mulmuladd2_extrause1(i32 %a0, i32 %a1) {
; CHECK-LABEL: @mulmuladd2_extrause1(
; CHECK-NEXT:    [[ADD:%.*]] = add i32 [[A0:%.*]], 16
; CHECK-NEXT:    call void @use32(i32 [[ADD]])
; CHECK-NEXT:    [[MUL1:%.*]] = mul i32 [[ADD]], [[A1:%.*]]
; CHECK-NEXT:    [[MUL2:%.*]] = mul i32 [[MUL1]], -4
; CHECK-NEXT:    ret i32 [[MUL2]]
;
  %add = add i32 %a0, 16
  call void @use32(i32 %add)
  %mul1 = mul i32 %add, %a1
  %mul2 = mul i32 %mul1, -4
  ret i32 %mul2
}
define i32 @mulmuladd2_extrause2(i32 %a0, i32 %a1) {
; CHECK-LABEL: @mulmuladd2_extrause2(
; CHECK-NEXT:    [[ADD:%.*]] = add i32 [[A0:%.*]], 16
; CHECK-NEXT:    call void @use32(i32 [[ADD]])
; CHECK-NEXT:    [[MUL1:%.*]] = mul i32 [[ADD]], [[A1:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[MUL1]])
; CHECK-NEXT:    [[MUL2:%.*]] = mul i32 [[MUL1]], -4
; CHECK-NEXT:    ret i32 [[MUL2]]
;
  %add = add i32 %a0, 16
  call void @use32(i32 %add)
  %mul1 = mul i32 %add, %a1
  call void @use32(i32 %mul1)
  %mul2 = mul i32 %mul1, -4
  ret i32 %mul2
}

define i32 @mulnot(i32 %a0) {
; CHECK-LABEL: @mulnot(
; CHECK-NEXT:    [[ADD_NEG:%.*]] = shl i32 [[A0:%.*]], 2
; CHECK-NEXT:    [[MUL:%.*]] = add i32 [[ADD_NEG]], 4
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %add = xor i32 %a0, -1
  %mul = mul i32 %add, -4
  ret i32 %mul
}
define i32 @mulnot_extrause(i32 %a0) {
; CHECK-LABEL: @mulnot_extrause(
; CHECK-NEXT:    [[NOT:%.*]] = xor i32 [[A0:%.*]], -1
; CHECK-NEXT:    call void @use32(i32 [[NOT]])
; CHECK-NEXT:    [[MUL:%.*]] = mul i32 [[NOT]], -4
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %not = xor i32 %a0, -1
  call void @use32(i32 %not)
  %mul = mul i32 %not, -4
  ret i32 %mul
}
