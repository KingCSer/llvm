; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -simplifycfg -simplifycfg-require-and-preserve-domtree=1 -S | FileCheck %s
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"

declare i32 @__gxx_personality_v0(...)
declare void @__cxa_call_unexpected(i8*)
declare void @purefn() nounwind readnone
declare i32 @read_only() nounwind readonly
declare i32 @nounwind_fn() nounwind
declare i32 @fn()


define i8* @f1() nounwind uwtable ssp personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: @f1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void @llvm.trap()
; CHECK-NEXT:    unreachable
;
entry:
  %call = invoke noalias i8* undef()
  to label %invoke.cont unwind label %lpad

invoke.cont:
  ret i8* %call

lpad:
  %0 = landingpad { i8*, i32 }
  filter [0 x i8*] zeroinitializer
  %1 = extractvalue { i8*, i32 } %0, 0
  tail call void @__cxa_call_unexpected(i8* %1) noreturn nounwind
  unreachable
}

define i8* @f2() nounwind uwtable ssp personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: @f2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void @llvm.trap()
; CHECK-NEXT:    unreachable
;
entry:
  %call = invoke noalias i8* null()
  to label %invoke.cont unwind label %lpad

invoke.cont:
  ret i8* %call

lpad:
  %0 = landingpad { i8*, i32 }
  filter [0 x i8*] zeroinitializer
  %1 = extractvalue { i8*, i32 } %0, 0
  tail call void @__cxa_call_unexpected(i8* %1) noreturn nounwind
  unreachable
}

define i8* @f2_no_null_opt() nounwind uwtable ssp #0 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: @f2_no_null_opt(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CALL:%.*]] = invoke noalias i8* null()
; CHECK-NEXT:    to label [[INVOKE_CONT:%.*]] unwind label [[LPAD:%.*]]
; CHECK:       invoke.cont:
; CHECK-NEXT:    ret i8* [[CALL]]
; CHECK:       lpad:
; CHECK-NEXT:    [[TMP0:%.*]] = landingpad { i8*, i32 }
; CHECK-NEXT:    filter [0 x i8*] zeroinitializer
; CHECK-NEXT:    [[TMP1:%.*]] = extractvalue { i8*, i32 } [[TMP0]], 0
; CHECK-NEXT:    tail call void @__cxa_call_unexpected(i8* [[TMP1]]) #[[ATTR6:[0-9]+]]
; CHECK-NEXT:    unreachable
;
entry:
  %call = invoke noalias i8* null()
  to label %invoke.cont unwind label %lpad

invoke.cont:
  ret i8* %call

lpad:
  %0 = landingpad { i8*, i32 }
  filter [0 x i8*] zeroinitializer
  %1 = extractvalue { i8*, i32 } %0, 0
  tail call void @__cxa_call_unexpected(i8* %1) noreturn nounwind
  unreachable
}

define i32 @f3() nounwind uwtable ssp personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: @f3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i32 3
;
entry:
  %call = invoke i32 @read_only()
  to label %invoke.cont unwind label %lpad

invoke.cont:
  ret i32 3

lpad:
  %0 = landingpad { i8*, i32 }
  filter [0 x i8*] zeroinitializer
  %1 = extractvalue { i8*, i32 } %0, 0
  tail call void @__cxa_call_unexpected(i8* %1) noreturn nounwind
  unreachable
}

define i32 @f4() nounwind uwtable ssp personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: @f4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @read_only()
; CHECK-NEXT:    ret i32 [[CALL]]
;
entry:
  %call = invoke i32 @read_only()
  to label %invoke.cont unwind label %lpad

invoke.cont:
  ret i32 %call

lpad:
  %0 = landingpad { i8*, i32 }
  filter [0 x i8*] zeroinitializer
  %1 = extractvalue { i8*, i32 } %0, 0
  tail call void @__cxa_call_unexpected(i8* %1) noreturn nounwind
  unreachable
}

define i32 @f5(i1 %cond, i8* %a, i8* %b) personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: @f5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[X:%.*]], label [[Y:%.*]]
; CHECK:       x:
; CHECK-NEXT:    [[CALL:%.*]] = invoke i32 @fn()
; CHECK-NEXT:    to label [[CONT:%.*]] unwind label [[LPAD:%.*]]
; CHECK:       y:
; CHECK-NEXT:    [[CALL2:%.*]] = call i32 @nounwind_fn()
; CHECK-NEXT:    br label [[CONT]]
; CHECK:       cont:
; CHECK-NEXT:    [[PHI:%.*]] = phi i32 [ [[CALL]], [[X]] ], [ [[CALL2]], [[Y]] ]
; CHECK-NEXT:    ret i32 [[PHI]]
; CHECK:       lpad:
; CHECK-NEXT:    [[TMP0:%.*]] = landingpad { i8*, i32 }
; CHECK-NEXT:    filter [0 x i8*] zeroinitializer
; CHECK-NEXT:    tail call void @__cxa_call_unexpected(i8* [[A:%.*]]) #[[ATTR6]]
; CHECK-NEXT:    unreachable
;
entry:
  br i1 %cond, label %x, label %y

x:
  %call = invoke i32 @fn()
  to label %cont unwind label %lpad

y:
  %call2 = invoke i32 @nounwind_fn()
  to label %cont unwind label %lpad

cont:
  %phi = phi i32 [%call, %x], [%call2, %y]
  ret i32 %phi

lpad:
  %phi2 = phi i8* [%a, %x], [%b, %y]
  %0 = landingpad { i8*, i32 }
  filter [0 x i8*] zeroinitializer
  tail call void @__cxa_call_unexpected(i8* %phi2) noreturn nounwind
  unreachable
}

define void @f6() personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
; CHECK-LABEL: @f6(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[FOO:%.*]] = invoke i32 @fn()
; CHECK-NEXT:    to label [[INVOKE_CONT2:%.*]] unwind label [[LPAD:%.*]]
; CHECK:       invoke.cont2:
; CHECK-NEXT:    ret void
; CHECK:       lpad:
; CHECK-NEXT:    [[TMP0:%.*]] = landingpad { i8*, i32 }
; CHECK-NEXT:    cleanup
; CHECK-NEXT:    ret void
;
entry:
  invoke void @purefn()
  to label %invoke.cont1 unwind label %lpad

invoke.cont1:
  %foo = invoke i32 @fn()
  to label %invoke.cont2 unwind label %lpad

invoke.cont2:
  ret void

lpad:
  %tmp = phi i8* [ null, %invoke.cont1 ], [ null, %entry ]
  landingpad { i8*, i32 }
  cleanup
  ret void
}

attributes #0 = { null_pointer_is_valid }
