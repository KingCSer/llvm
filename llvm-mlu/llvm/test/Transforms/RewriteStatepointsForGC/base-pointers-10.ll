; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -rewrite-statepoints-for-gc -S 2>&1 | FileCheck %s
; RUN: opt < %s -passes=rewrite-statepoints-for-gc -S 2>&1 | FileCheck %s

declare i1 @runtime_value() "gc-leaf-function"

declare void @do_safepoint()

define void @select_of_phi(i64 addrspace(1)* %base_obj_x, i64 addrspace(1)* %base_obj_y) gc "statepoint-example" {
; CHECK-LABEL: @select_of_phi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[DOT01:%.*]] = phi i64 addrspace(1)* [ [[BASE_OBJ_X:%.*]], [[ENTRY:%.*]] ], [ [[BASE_OBJ_X_RELOCATED_CASTED:%.*]], [[MERGE:%.*]] ]
; CHECK-NEXT:    [[DOT0:%.*]] = phi i64 addrspace(1)* [ [[BASE_OBJ_Y:%.*]], [[ENTRY]] ], [ [[BASE_OBJ_Y_RELOCATED_CASTED:%.*]], [[MERGE]] ]
; CHECK-NEXT:    [[CURRENT_X:%.*]] = phi i64 addrspace(1)* [ [[BASE_OBJ_X]], [[ENTRY]] ], [ [[NEXT_X_RELOCATED_CASTED:%.*]], [[MERGE]] ]
; CHECK-NEXT:    [[CURRENT_Y:%.*]] = phi i64 addrspace(1)* [ [[BASE_OBJ_Y]], [[ENTRY]] ], [ [[NEXT_Y_RELOCATED_CASTED:%.*]], [[MERGE]] ]
; CHECK-NEXT:    [[CURRENT:%.*]] = phi i64 addrspace(1)* [ null, [[ENTRY]] ], [ [[NEXT_RELOCATED_CASTED:%.*]], [[MERGE]] ]
; CHECK-NEXT:    [[CONDITION:%.*]] = call i1 @runtime_value()
; CHECK-NEXT:    [[NEXT_X:%.*]] = getelementptr i64, i64 addrspace(1)* [[CURRENT_X]], i32 1
; CHECK-NEXT:    [[NEXT_Y:%.*]] = getelementptr i64, i64 addrspace(1)* [[CURRENT_Y]], i32 1
; CHECK-NEXT:    br i1 [[CONDITION]], label [[TRUE:%.*]], label [[FALSE:%.*]]
; CHECK:       true:
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       false:
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    [[NEXT_BASE:%.*]] = phi i64 addrspace(1)* [ [[DOT01]], [[TRUE]] ], [ [[DOT0]], [[FALSE]] ], !is_base_value !0
; CHECK-NEXT:    [[NEXT:%.*]] = phi i64 addrspace(1)* [ [[NEXT_X]], [[TRUE]] ], [ [[NEXT_Y]], [[FALSE]] ]
; CHECK-NEXT:    [[STATEPOINT_TOKEN:%.*]] = call token (i64, i32, void ()*, i32, i32, ...) @llvm.experimental.gc.statepoint.p0f_isVoidf(i64 2882400000, i32 0, void ()* @do_safepoint, i32 0, i32 0, i32 0, i32 0) [ "deopt"(i32 0, i32 -1, i32 0, i32 0, i32 0), "gc-live"(i64 addrspace(1)* [[NEXT_X]], i64 addrspace(1)* [[NEXT_Y]], i64 addrspace(1)* [[NEXT]], i64 addrspace(1)* [[DOT01]], i64 addrspace(1)* [[DOT0]], i64 addrspace(1)* [[NEXT_BASE]]) ]
; CHECK-NEXT:    [[NEXT_X_RELOCATED:%.*]] = call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token [[STATEPOINT_TOKEN]], i32 3, i32 0)
; CHECK-NEXT:    [[NEXT_X_RELOCATED_CASTED]] = bitcast i8 addrspace(1)* [[NEXT_X_RELOCATED]] to i64 addrspace(1)*
; CHECK-NEXT:    [[NEXT_Y_RELOCATED:%.*]] = call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token [[STATEPOINT_TOKEN]], i32 4, i32 1)
; CHECK-NEXT:    [[NEXT_Y_RELOCATED_CASTED]] = bitcast i8 addrspace(1)* [[NEXT_Y_RELOCATED]] to i64 addrspace(1)*
; CHECK-NEXT:    [[NEXT_RELOCATED:%.*]] = call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token [[STATEPOINT_TOKEN]], i32 5, i32 2)
; CHECK-NEXT:    [[NEXT_RELOCATED_CASTED]] = bitcast i8 addrspace(1)* [[NEXT_RELOCATED]] to i64 addrspace(1)*
; CHECK-NEXT:    [[BASE_OBJ_X_RELOCATED:%.*]] = call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token [[STATEPOINT_TOKEN]], i32 3, i32 3)
; CHECK-NEXT:    [[BASE_OBJ_X_RELOCATED_CASTED]] = bitcast i8 addrspace(1)* [[BASE_OBJ_X_RELOCATED]] to i64 addrspace(1)*
; CHECK-NEXT:    [[BASE_OBJ_Y_RELOCATED:%.*]] = call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token [[STATEPOINT_TOKEN]], i32 4, i32 4)
; CHECK-NEXT:    [[BASE_OBJ_Y_RELOCATED_CASTED]] = bitcast i8 addrspace(1)* [[BASE_OBJ_Y_RELOCATED]] to i64 addrspace(1)*
; CHECK-NEXT:    [[NEXT_BASE_RELOCATED:%.*]] = call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token [[STATEPOINT_TOKEN]], i32 5, i32 5)
; CHECK-NEXT:    [[NEXT_BASE_RELOCATED_CASTED:%.*]] = bitcast i8 addrspace(1)* [[NEXT_BASE_RELOCATED]] to i64 addrspace(1)*
; CHECK-NEXT:    br label [[LOOP]]
;
entry:
  br label %loop

loop:                                             ; preds = %merge, %entry
  %current_x = phi i64 addrspace(1)* [ %base_obj_x, %entry ], [ %next_x, %merge ]
  %current_y = phi i64 addrspace(1)* [ %base_obj_y, %entry ], [ %next_y, %merge ]
  %current = phi i64 addrspace(1)* [ null, %entry ], [ %next, %merge ]
  %condition = call i1 @runtime_value()
  %next_x = getelementptr i64, i64 addrspace(1)* %current_x, i32 1
  %next_y = getelementptr i64, i64 addrspace(1)* %current_y, i32 1
  br i1 %condition, label %true, label %false

true:                                             ; preds = %loop
  br label %merge

false:                                            ; preds = %loop
  br label %merge

merge:                                            ; preds = %false, %true
  %next = phi i64 addrspace(1)* [ %next_x, %true ], [ %next_y, %false ]
  call void @do_safepoint() [ "deopt"(i32 0, i32 -1, i32 0, i32 0, i32 0) ]
  br label %loop
}
