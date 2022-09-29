; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown | FileCheck %s

; These tests use adc/sbb in place of set+add/sub. Should this transform
; be enabled by micro-architecture rather than as part of generic lowering/isel?

; <rdar://problem/8449754>

define i32 @test1(i32 %sum, i32 %x) nounwind readnone ssp {
; CHECK-LABEL: test1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    addl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    adcl $0, %eax
; CHECK-NEXT:    retl
  %add4 = add i32 %x, %sum
  %cmp = icmp ult i32 %add4, %x
  %inc = zext i1 %cmp to i32
  %z.0 = add i32 %add4, %inc
  ret i32 %z.0
}

; <rdar://problem/12579915>

define i32 @test2(i32 %x, i32 %y, i32 %res) nounwind uwtable readnone ssp {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    cmpl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    sbbl $0, %eax
; CHECK-NEXT:    retl
  %cmp = icmp ugt i32 %x, %y
  %dec = sext i1 %cmp to i32
  %dec.res = add nsw i32 %dec, %res
  ret i32 %dec.res
}

