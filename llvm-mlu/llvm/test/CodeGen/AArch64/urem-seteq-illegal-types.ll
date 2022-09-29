; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=aarch64-unknown-linux-gnu < %s | FileCheck %s

define i1 @test_urem_odd(i13 %X) nounwind {
; CHECK-LABEL: test_urem_odd:
; CHECK:       // %bb.0:
; CHECK-NEXT:    mov w8, #3277
; CHECK-NEXT:    mul w8, w0, w8
; CHECK-NEXT:    and w8, w8, #0x1fff
; CHECK-NEXT:    cmp w8, #1639 // =1639
; CHECK-NEXT:    cset w0, lo
; CHECK-NEXT:    ret
  %urem = urem i13 %X, 5
  %cmp = icmp eq i13 %urem, 0
  ret i1 %cmp
}

define i1 @test_urem_even(i27 %X) nounwind {
; CHECK-LABEL: test_urem_even:
; CHECK:       // %bb.0:
; CHECK-NEXT:    mov w8, #28087
; CHECK-NEXT:    movk w8, #1755, lsl #16
; CHECK-NEXT:    mul w8, w0, w8
; CHECK-NEXT:    lsl w9, w8, #26
; CHECK-NEXT:    bfxil w9, w8, #1, #26
; CHECK-NEXT:    and w8, w9, #0x7ffffff
; CHECK-NEXT:    mov w9, #18725
; CHECK-NEXT:    movk w9, #146, lsl #16
; CHECK-NEXT:    cmp w8, w9
; CHECK-NEXT:    cset w0, lo
; CHECK-NEXT:    ret
  %urem = urem i27 %X, 14
  %cmp = icmp eq i27 %urem, 0
  ret i1 %cmp
}

define i1 @test_urem_odd_setne(i4 %X) nounwind {
; CHECK-LABEL: test_urem_odd_setne:
; CHECK:       // %bb.0:
; CHECK-NEXT:    mov w8, #13
; CHECK-NEXT:    mul w8, w0, w8
; CHECK-NEXT:    and w8, w8, #0xf
; CHECK-NEXT:    cmp w8, #3 // =3
; CHECK-NEXT:    cset w0, hi
; CHECK-NEXT:    ret
  %urem = urem i4 %X, 5
  %cmp = icmp ne i4 %urem, 0
  ret i1 %cmp
}

define i1 @test_urem_negative_odd(i9 %X) nounwind {
; CHECK-LABEL: test_urem_negative_odd:
; CHECK:       // %bb.0:
; CHECK-NEXT:    mov w8, #307
; CHECK-NEXT:    mul w8, w0, w8
; CHECK-NEXT:    and w8, w8, #0x1ff
; CHECK-NEXT:    cmp w8, #1 // =1
; CHECK-NEXT:    cset w0, hi
; CHECK-NEXT:    ret
  %urem = urem i9 %X, -5
  %cmp = icmp ne i9 %urem, 0
  ret i1 %cmp
}

define <3 x i1> @test_urem_vec(<3 x i11> %X) nounwind {
; CHECK-LABEL: test_urem_vec:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp x8, .LCPI4_0
; CHECK-NEXT:    ldr d1, [x8, :lo12:.LCPI4_0]
; CHECK-NEXT:    fmov s0, w0
; CHECK-NEXT:    adrp x9, .LCPI4_1
; CHECK-NEXT:    mov v0.h[1], w1
; CHECK-NEXT:    ldr d3, [x9, :lo12:.LCPI4_1]
; CHECK-NEXT:    adrp x8, .LCPI4_2
; CHECK-NEXT:    mov v0.h[2], w2
; CHECK-NEXT:    sub v0.4h, v0.4h, v1.4h
; CHECK-NEXT:    ldr d1, [x8, :lo12:.LCPI4_2]
; CHECK-NEXT:    mul v0.4h, v0.4h, v3.4h
; CHECK-NEXT:    adrp x8, .LCPI4_3
; CHECK-NEXT:    shl v3.4h, v0.4h, #1
; CHECK-NEXT:    movi d2, #0x0000000000ffff
; CHECK-NEXT:    ushl v1.4h, v3.4h, v1.4h
; CHECK-NEXT:    ldr d3, [x8, :lo12:.LCPI4_3]
; CHECK-NEXT:    bic v0.4h, #248, lsl #8
; CHECK-NEXT:    ushl v0.4h, v0.4h, v2.4h
; CHECK-NEXT:    orr v0.8b, v0.8b, v1.8b
; CHECK-NEXT:    bic v0.4h, #248, lsl #8
; CHECK-NEXT:    cmhi v0.4h, v0.4h, v3.4h
; CHECK-NEXT:    umov w0, v0.h[0]
; CHECK-NEXT:    umov w1, v0.h[1]
; CHECK-NEXT:    umov w2, v0.h[2]
; CHECK-NEXT:    ret
  %urem = urem <3 x i11> %X, <i11 6, i11 7, i11 -5>
  %cmp = icmp ne <3 x i11> %urem, <i11 0, i11 1, i11 2>
  ret <3 x i1> %cmp
}
