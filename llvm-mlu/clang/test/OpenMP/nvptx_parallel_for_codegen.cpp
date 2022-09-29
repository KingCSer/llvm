// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs --replace-value-regex "__omp_offloading_[0-9a-z]+_[0-9a-z]+" "reduction_size[.].+[.]" "pl_cond[.].+[.|,]" --prefix-filecheck-ir-name _
// Test target codegen - host bc file has to be created first.
// RUN: %clang_cc1 -verify -fopenmp -x c++ -triple powerpc64le-unknown-unknown -fopenmp-targets=nvptx64-nvidia-cuda -emit-llvm-bc %s -o %t-ppc-host.bc
// RUN: %clang_cc1 -verify -fopenmp -x c++ -triple nvptx64-unknown-unknown -fopenmp-targets=nvptx64-nvidia-cuda -emit-llvm %s -fopenmp-is-device -fopenmp-host-ir-file-path %t-ppc-host.bc -o - -disable-llvm-optzns | FileCheck %s --check-prefix=CHECK1
// RUN: %clang_cc1 -verify -fopenmp -x c++ -triple nvptx64-unknown-unknown -fopenmp-targets=nvptx64-nvidia-cuda -emit-llvm %s -fopenmp-is-device -fopenmp-host-ir-file-path %t-ppc-host.bc -o - -disable-llvm-optzns -fopenmp-cuda-parallel-target-regions | FileCheck %s --check-prefix=CHECK2
// expected-no-diagnostics
#ifndef HEADER
#define HEADER

template<typename tx>
tx ftemplate(int n) {
  tx b[10];

  #pragma omp target
  {
    tx d = n;
    #pragma omp parallel for
    for(int i=0; i<10; i++) {
      b[i] += d;
    }
    b[3] += 1;
  }

  return b[3];
}

int bar(int n){
  int a = 0;

  a += ftemplate<int>(n);

  return a;
}

#endif
// CHECK1-LABEL: define {{[^@]+}}@{{__omp_offloading_[0-9a-z]+_[0-9a-z]+}}__Z9ftemplateIiET_i_l14_worker
// CHECK1-SAME: () #[[ATTR0:[0-9]+]] {
// CHECK1-NEXT:  entry:
// CHECK1-NEXT:    [[WORK_FN:%.*]] = alloca i8*, align 8
// CHECK1-NEXT:    [[EXEC_STATUS:%.*]] = alloca i8, align 1
// CHECK1-NEXT:    store i8* null, i8** [[WORK_FN]], align 8
// CHECK1-NEXT:    store i8 0, i8* [[EXEC_STATUS]], align 1
// CHECK1-NEXT:    br label [[DOTAWAIT_WORK:%.*]]
// CHECK1:       .await.work:
// CHECK1-NEXT:    call void @__kmpc_barrier_simple_spmd(%struct.ident_t* null, i32 0)
// CHECK1-NEXT:    [[TMP0:%.*]] = call i1 @__kmpc_kernel_parallel(i8** [[WORK_FN]])
// CHECK1-NEXT:    [[TMP1:%.*]] = zext i1 [[TMP0]] to i8
// CHECK1-NEXT:    store i8 [[TMP1]], i8* [[EXEC_STATUS]], align 1
// CHECK1-NEXT:    [[TMP2:%.*]] = load i8*, i8** [[WORK_FN]], align 8
// CHECK1-NEXT:    [[SHOULD_TERMINATE:%.*]] = icmp eq i8* [[TMP2]], null
// CHECK1-NEXT:    br i1 [[SHOULD_TERMINATE]], label [[DOTEXIT:%.*]], label [[DOTSELECT_WORKERS:%.*]]
// CHECK1:       .select.workers:
// CHECK1-NEXT:    [[TMP3:%.*]] = load i8, i8* [[EXEC_STATUS]], align 1
// CHECK1-NEXT:    [[IS_ACTIVE:%.*]] = icmp ne i8 [[TMP3]], 0
// CHECK1-NEXT:    br i1 [[IS_ACTIVE]], label [[DOTEXECUTE_PARALLEL:%.*]], label [[DOTBARRIER_PARALLEL:%.*]]
// CHECK1:       .execute.parallel:
// CHECK1-NEXT:    [[TMP4:%.*]] = call i32 @__kmpc_global_thread_num(%struct.ident_t* @[[GLOB2:[0-9]+]])
// CHECK1-NEXT:    [[TMP5:%.*]] = load i8*, i8** [[WORK_FN]], align 8
// CHECK1-NEXT:    [[WORK_MATCH:%.*]] = icmp eq i8* [[TMP5]], bitcast (void (i16, i32)* @__omp_outlined___wrapper to i8*)
// CHECK1-NEXT:    br i1 [[WORK_MATCH]], label [[DOTEXECUTE_FN:%.*]], label [[DOTCHECK_NEXT:%.*]]
// CHECK1:       .execute.fn:
// CHECK1-NEXT:    call void @__omp_outlined___wrapper(i16 0, i32 [[TMP4]]) #[[ATTR3:[0-9]+]]
// CHECK1-NEXT:    br label [[DOTTERMINATE_PARALLEL:%.*]]
// CHECK1:       .check.next:
// CHECK1-NEXT:    [[TMP6:%.*]] = bitcast i8* [[TMP2]] to void (i16, i32)*
// CHECK1-NEXT:    call void [[TMP6]](i16 0, i32 [[TMP4]])
// CHECK1-NEXT:    br label [[DOTTERMINATE_PARALLEL]]
// CHECK1:       .terminate.parallel:
// CHECK1-NEXT:    call void @__kmpc_kernel_end_parallel()
// CHECK1-NEXT:    br label [[DOTBARRIER_PARALLEL]]
// CHECK1:       .barrier.parallel:
// CHECK1-NEXT:    call void @__kmpc_barrier_simple_spmd(%struct.ident_t* null, i32 0)
// CHECK1-NEXT:    br label [[DOTAWAIT_WORK]]
// CHECK1:       .exit:
// CHECK1-NEXT:    ret void
//
//
// CHECK1-LABEL: define {{[^@]+}}@{{__omp_offloading_[0-9a-z]+_[0-9a-z]+}}__Z9ftemplateIiET_i_l14
// CHECK1-SAME: (i64 [[N:%.*]], [10 x i32]* nonnull align 4 dereferenceable(40) [[B:%.*]]) #[[ATTR1:[0-9]+]] {
// CHECK1-NEXT:  entry:
// CHECK1-NEXT:    [[N_ADDR:%.*]] = alloca i64, align 8
// CHECK1-NEXT:    [[B_ADDR:%.*]] = alloca [10 x i32]*, align 8
// CHECK1-NEXT:    [[CAPTURED_VARS_ADDRS:%.*]] = alloca [2 x i8*], align 8
// CHECK1-NEXT:    store i64 [[N]], i64* [[N_ADDR]], align 8
// CHECK1-NEXT:    store [10 x i32]* [[B]], [10 x i32]** [[B_ADDR]], align 8
// CHECK1-NEXT:    [[CONV:%.*]] = bitcast i64* [[N_ADDR]] to i32*
// CHECK1-NEXT:    [[TMP0:%.*]] = load [10 x i32]*, [10 x i32]** [[B_ADDR]], align 8
// CHECK1-NEXT:    [[NVPTX_TID:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.tid.x()
// CHECK1-NEXT:    [[NVPTX_NUM_THREADS:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
// CHECK1-NEXT:    [[NVPTX_WARP_SIZE:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.warpsize()
// CHECK1-NEXT:    [[THREAD_LIMIT:%.*]] = sub nuw i32 [[NVPTX_NUM_THREADS]], [[NVPTX_WARP_SIZE]]
// CHECK1-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[NVPTX_TID]], [[THREAD_LIMIT]]
// CHECK1-NEXT:    br i1 [[TMP1]], label [[DOTWORKER:%.*]], label [[DOTMASTERCHECK:%.*]]
// CHECK1:       .worker:
// CHECK1-NEXT:    call void @{{__omp_offloading_[0-9a-z]+_[0-9a-z]+}}__Z9ftemplateIiET_i_l14_worker() #[[ATTR3]]
// CHECK1-NEXT:    br label [[DOTEXIT:%.*]]
// CHECK1:       .mastercheck:
// CHECK1-NEXT:    [[NVPTX_TID1:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.tid.x()
// CHECK1-NEXT:    [[NVPTX_NUM_THREADS2:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
// CHECK1-NEXT:    [[NVPTX_WARP_SIZE3:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.warpsize()
// CHECK1-NEXT:    [[TMP2:%.*]] = sub nuw i32 [[NVPTX_WARP_SIZE3]], 1
// CHECK1-NEXT:    [[TMP3:%.*]] = sub nuw i32 [[NVPTX_NUM_THREADS2]], 1
// CHECK1-NEXT:    [[TMP4:%.*]] = xor i32 [[TMP2]], -1
// CHECK1-NEXT:    [[MASTER_TID:%.*]] = and i32 [[TMP3]], [[TMP4]]
// CHECK1-NEXT:    [[TMP5:%.*]] = icmp eq i32 [[NVPTX_TID1]], [[MASTER_TID]]
// CHECK1-NEXT:    br i1 [[TMP5]], label [[DOTMASTER:%.*]], label [[DOTEXIT]]
// CHECK1:       .master:
// CHECK1-NEXT:    [[NVPTX_NUM_THREADS4:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
// CHECK1-NEXT:    [[NVPTX_WARP_SIZE5:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.warpsize()
// CHECK1-NEXT:    [[THREAD_LIMIT6:%.*]] = sub nuw i32 [[NVPTX_NUM_THREADS4]], [[NVPTX_WARP_SIZE5]]
// CHECK1-NEXT:    call void @__kmpc_kernel_init(i32 [[THREAD_LIMIT6]], i16 1)
// CHECK1-NEXT:    call void @__kmpc_data_sharing_init_stack()
// CHECK1-NEXT:    [[TMP6:%.*]] = load i16, i16* @"_openmp_static_kernel$is_shared", align 2
// CHECK1-NEXT:    [[TMP7:%.*]] = load i64, i64* @"_openmp_static_kernel$size", align 8
// CHECK1-NEXT:    call void @__kmpc_get_team_static_memory(i16 0, i8* addrspacecast (i8 addrspace(3)* getelementptr inbounds (%"union._shared_openmp_static_memory_type_$_", %"union._shared_openmp_static_memory_type_$_" addrspace(3)* @"_openmp_shared_static_glob_rd_$_", i32 0, i32 0, i32 0) to i8*), i64 [[TMP7]], i16 [[TMP6]], i8** addrspacecast (i8* addrspace(3)* @"_openmp_kernel_static_glob_rd$ptr" to i8**))
// CHECK1-NEXT:    [[TMP8:%.*]] = load i8*, i8* addrspace(3)* @"_openmp_kernel_static_glob_rd$ptr", align 8
// CHECK1-NEXT:    [[TMP9:%.*]] = getelementptr inbounds i8, i8* [[TMP8]], i64 0
// CHECK1-NEXT:    [[TMP10:%.*]] = bitcast i8* [[TMP9]] to %struct._globalized_locals_ty*
// CHECK1-NEXT:    [[D:%.*]] = getelementptr inbounds [[STRUCT__GLOBALIZED_LOCALS_TY:%.*]], %struct._globalized_locals_ty* [[TMP10]], i32 0, i32 0
// CHECK1-NEXT:    [[TMP11:%.*]] = call i32 @__kmpc_global_thread_num(%struct.ident_t* @[[GLOB2]])
// CHECK1-NEXT:    [[TMP12:%.*]] = load i32, i32* [[CONV]], align 8
// CHECK1-NEXT:    store i32 [[TMP12]], i32* [[D]], align 4
// CHECK1-NEXT:    [[TMP13:%.*]] = getelementptr inbounds [2 x i8*], [2 x i8*]* [[CAPTURED_VARS_ADDRS]], i64 0, i64 0
// CHECK1-NEXT:    [[TMP14:%.*]] = bitcast [10 x i32]* [[TMP0]] to i8*
// CHECK1-NEXT:    store i8* [[TMP14]], i8** [[TMP13]], align 8
// CHECK1-NEXT:    [[TMP15:%.*]] = getelementptr inbounds [2 x i8*], [2 x i8*]* [[CAPTURED_VARS_ADDRS]], i64 0, i64 1
// CHECK1-NEXT:    [[TMP16:%.*]] = bitcast i32* [[D]] to i8*
// CHECK1-NEXT:    store i8* [[TMP16]], i8** [[TMP15]], align 8
// CHECK1-NEXT:    [[TMP17:%.*]] = bitcast [2 x i8*]* [[CAPTURED_VARS_ADDRS]] to i8**
// CHECK1-NEXT:    call void @__kmpc_parallel_51(%struct.ident_t* @[[GLOB2]], i32 [[TMP11]], i32 1, i32 -1, i32 -1, i8* bitcast (void (i32*, i32*, [10 x i32]*, i32*)* @__omp_outlined__ to i8*), i8* bitcast (void (i16, i32)* @__omp_outlined___wrapper to i8*), i8** [[TMP17]], i64 2)
// CHECK1-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [10 x i32], [10 x i32]* [[TMP0]], i64 0, i64 3
// CHECK1-NEXT:    [[TMP18:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
// CHECK1-NEXT:    [[ADD:%.*]] = add nsw i32 [[TMP18]], 1
// CHECK1-NEXT:    store i32 [[ADD]], i32* [[ARRAYIDX]], align 4
// CHECK1-NEXT:    [[TMP19:%.*]] = load i16, i16* @"_openmp_static_kernel$is_shared", align 2
// CHECK1-NEXT:    call void @__kmpc_restore_team_static_memory(i16 0, i16 [[TMP19]])
// CHECK1-NEXT:    br label [[DOTTERMINATION_NOTIFIER:%.*]]
// CHECK1:       .termination.notifier:
// CHECK1-NEXT:    call void @__kmpc_kernel_deinit(i16 1)
// CHECK1-NEXT:    call void @__kmpc_barrier_simple_spmd(%struct.ident_t* null, i32 0)
// CHECK1-NEXT:    br label [[DOTEXIT]]
// CHECK1:       .exit:
// CHECK1-NEXT:    ret void
//
//
// CHECK1-LABEL: define {{[^@]+}}@__omp_outlined__
// CHECK1-SAME: (i32* noalias [[DOTGLOBAL_TID_:%.*]], i32* noalias [[DOTBOUND_TID_:%.*]], [10 x i32]* nonnull align 4 dereferenceable(40) [[B:%.*]], i32* nonnull align 4 dereferenceable(4) [[D:%.*]]) #[[ATTR1]] {
// CHECK1-NEXT:  entry:
// CHECK1-NEXT:    [[DOTGLOBAL_TID__ADDR:%.*]] = alloca i32*, align 8
// CHECK1-NEXT:    [[DOTBOUND_TID__ADDR:%.*]] = alloca i32*, align 8
// CHECK1-NEXT:    [[B_ADDR:%.*]] = alloca [10 x i32]*, align 8
// CHECK1-NEXT:    [[D_ADDR:%.*]] = alloca i32*, align 8
// CHECK1-NEXT:    [[DOTOMP_IV:%.*]] = alloca i32, align 4
// CHECK1-NEXT:    [[TMP:%.*]] = alloca i32, align 4
// CHECK1-NEXT:    [[DOTOMP_LB:%.*]] = alloca i32, align 4
// CHECK1-NEXT:    [[DOTOMP_UB:%.*]] = alloca i32, align 4
// CHECK1-NEXT:    [[DOTOMP_STRIDE:%.*]] = alloca i32, align 4
// CHECK1-NEXT:    [[DOTOMP_IS_LAST:%.*]] = alloca i32, align 4
// CHECK1-NEXT:    [[I:%.*]] = alloca i32, align 4
// CHECK1-NEXT:    store i32* [[DOTGLOBAL_TID_]], i32** [[DOTGLOBAL_TID__ADDR]], align 8
// CHECK1-NEXT:    store i32* [[DOTBOUND_TID_]], i32** [[DOTBOUND_TID__ADDR]], align 8
// CHECK1-NEXT:    store [10 x i32]* [[B]], [10 x i32]** [[B_ADDR]], align 8
// CHECK1-NEXT:    store i32* [[D]], i32** [[D_ADDR]], align 8
// CHECK1-NEXT:    [[TMP0:%.*]] = load [10 x i32]*, [10 x i32]** [[B_ADDR]], align 8
// CHECK1-NEXT:    [[TMP1:%.*]] = load i32*, i32** [[D_ADDR]], align 8
// CHECK1-NEXT:    store i32 0, i32* [[DOTOMP_LB]], align 4
// CHECK1-NEXT:    store i32 9, i32* [[DOTOMP_UB]], align 4
// CHECK1-NEXT:    store i32 1, i32* [[DOTOMP_STRIDE]], align 4
// CHECK1-NEXT:    store i32 0, i32* [[DOTOMP_IS_LAST]], align 4
// CHECK1-NEXT:    [[TMP2:%.*]] = load i32*, i32** [[DOTGLOBAL_TID__ADDR]], align 8
// CHECK1-NEXT:    [[TMP3:%.*]] = load i32, i32* [[TMP2]], align 4
// CHECK1-NEXT:    call void @__kmpc_for_static_init_4(%struct.ident_t* @[[GLOB1:[0-9]+]], i32 [[TMP3]], i32 33, i32* [[DOTOMP_IS_LAST]], i32* [[DOTOMP_LB]], i32* [[DOTOMP_UB]], i32* [[DOTOMP_STRIDE]], i32 1, i32 1)
// CHECK1-NEXT:    br label [[OMP_DISPATCH_COND:%.*]]
// CHECK1:       omp.dispatch.cond:
// CHECK1-NEXT:    [[TMP4:%.*]] = load i32, i32* [[DOTOMP_UB]], align 4
// CHECK1-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[TMP4]], 9
// CHECK1-NEXT:    br i1 [[CMP]], label [[COND_TRUE:%.*]], label [[COND_FALSE:%.*]]
// CHECK1:       cond.true:
// CHECK1-NEXT:    br label [[COND_END:%.*]]
// CHECK1:       cond.false:
// CHECK1-NEXT:    [[TMP5:%.*]] = load i32, i32* [[DOTOMP_UB]], align 4
// CHECK1-NEXT:    br label [[COND_END]]
// CHECK1:       cond.end:
// CHECK1-NEXT:    [[COND:%.*]] = phi i32 [ 9, [[COND_TRUE]] ], [ [[TMP5]], [[COND_FALSE]] ]
// CHECK1-NEXT:    store i32 [[COND]], i32* [[DOTOMP_UB]], align 4
// CHECK1-NEXT:    [[TMP6:%.*]] = load i32, i32* [[DOTOMP_LB]], align 4
// CHECK1-NEXT:    store i32 [[TMP6]], i32* [[DOTOMP_IV]], align 4
// CHECK1-NEXT:    [[TMP7:%.*]] = load i32, i32* [[DOTOMP_IV]], align 4
// CHECK1-NEXT:    [[TMP8:%.*]] = load i32, i32* [[DOTOMP_UB]], align 4
// CHECK1-NEXT:    [[CMP1:%.*]] = icmp sle i32 [[TMP7]], [[TMP8]]
// CHECK1-NEXT:    br i1 [[CMP1]], label [[OMP_DISPATCH_BODY:%.*]], label [[OMP_DISPATCH_END:%.*]]
// CHECK1:       omp.dispatch.body:
// CHECK1-NEXT:    br label [[OMP_INNER_FOR_COND:%.*]]
// CHECK1:       omp.inner.for.cond:
// CHECK1-NEXT:    [[TMP9:%.*]] = load i32, i32* [[DOTOMP_IV]], align 4
// CHECK1-NEXT:    [[TMP10:%.*]] = load i32, i32* [[DOTOMP_UB]], align 4
// CHECK1-NEXT:    [[CMP2:%.*]] = icmp sle i32 [[TMP9]], [[TMP10]]
// CHECK1-NEXT:    br i1 [[CMP2]], label [[OMP_INNER_FOR_BODY:%.*]], label [[OMP_INNER_FOR_END:%.*]]
// CHECK1:       omp.inner.for.body:
// CHECK1-NEXT:    [[TMP11:%.*]] = load i32, i32* [[DOTOMP_IV]], align 4
// CHECK1-NEXT:    [[MUL:%.*]] = mul nsw i32 [[TMP11]], 1
// CHECK1-NEXT:    [[ADD:%.*]] = add nsw i32 0, [[MUL]]
// CHECK1-NEXT:    store i32 [[ADD]], i32* [[I]], align 4
// CHECK1-NEXT:    [[TMP12:%.*]] = load i32, i32* [[TMP1]], align 4
// CHECK1-NEXT:    [[TMP13:%.*]] = load i32, i32* [[I]], align 4
// CHECK1-NEXT:    [[IDXPROM:%.*]] = sext i32 [[TMP13]] to i64
// CHECK1-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [10 x i32], [10 x i32]* [[TMP0]], i64 0, i64 [[IDXPROM]]
// CHECK1-NEXT:    [[TMP14:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
// CHECK1-NEXT:    [[ADD3:%.*]] = add nsw i32 [[TMP14]], [[TMP12]]
// CHECK1-NEXT:    store i32 [[ADD3]], i32* [[ARRAYIDX]], align 4
// CHECK1-NEXT:    br label [[OMP_BODY_CONTINUE:%.*]]
// CHECK1:       omp.body.continue:
// CHECK1-NEXT:    br label [[OMP_INNER_FOR_INC:%.*]]
// CHECK1:       omp.inner.for.inc:
// CHECK1-NEXT:    [[TMP15:%.*]] = load i32, i32* [[DOTOMP_IV]], align 4
// CHECK1-NEXT:    [[ADD4:%.*]] = add nsw i32 [[TMP15]], 1
// CHECK1-NEXT:    store i32 [[ADD4]], i32* [[DOTOMP_IV]], align 4
// CHECK1-NEXT:    br label [[OMP_INNER_FOR_COND]]
// CHECK1:       omp.inner.for.end:
// CHECK1-NEXT:    br label [[OMP_DISPATCH_INC:%.*]]
// CHECK1:       omp.dispatch.inc:
// CHECK1-NEXT:    [[TMP16:%.*]] = load i32, i32* [[DOTOMP_LB]], align 4
// CHECK1-NEXT:    [[TMP17:%.*]] = load i32, i32* [[DOTOMP_STRIDE]], align 4
// CHECK1-NEXT:    [[ADD5:%.*]] = add nsw i32 [[TMP16]], [[TMP17]]
// CHECK1-NEXT:    store i32 [[ADD5]], i32* [[DOTOMP_LB]], align 4
// CHECK1-NEXT:    [[TMP18:%.*]] = load i32, i32* [[DOTOMP_UB]], align 4
// CHECK1-NEXT:    [[TMP19:%.*]] = load i32, i32* [[DOTOMP_STRIDE]], align 4
// CHECK1-NEXT:    [[ADD6:%.*]] = add nsw i32 [[TMP18]], [[TMP19]]
// CHECK1-NEXT:    store i32 [[ADD6]], i32* [[DOTOMP_UB]], align 4
// CHECK1-NEXT:    br label [[OMP_DISPATCH_COND]]
// CHECK1:       omp.dispatch.end:
// CHECK1-NEXT:    call void @__kmpc_for_static_fini(%struct.ident_t* @[[GLOB1]], i32 [[TMP3]])
// CHECK1-NEXT:    ret void
//
//
// CHECK1-LABEL: define {{[^@]+}}@__omp_outlined___wrapper
// CHECK1-SAME: (i16 zeroext [[TMP0:%.*]], i32 [[TMP1:%.*]]) #[[ATTR0]] {
// CHECK1-NEXT:  entry:
// CHECK1-NEXT:    [[DOTADDR:%.*]] = alloca i16, align 2
// CHECK1-NEXT:    [[DOTADDR1:%.*]] = alloca i32, align 4
// CHECK1-NEXT:    [[DOTZERO_ADDR:%.*]] = alloca i32, align 4
// CHECK1-NEXT:    [[GLOBAL_ARGS:%.*]] = alloca i8**, align 8
// CHECK1-NEXT:    store i32 0, i32* [[DOTZERO_ADDR]], align 4
// CHECK1-NEXT:    store i16 [[TMP0]], i16* [[DOTADDR]], align 2
// CHECK1-NEXT:    store i32 [[TMP1]], i32* [[DOTADDR1]], align 4
// CHECK1-NEXT:    call void @__kmpc_get_shared_variables(i8*** [[GLOBAL_ARGS]])
// CHECK1-NEXT:    [[TMP2:%.*]] = load i8**, i8*** [[GLOBAL_ARGS]], align 8
// CHECK1-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i8*, i8** [[TMP2]], i64 0
// CHECK1-NEXT:    [[TMP4:%.*]] = bitcast i8** [[TMP3]] to [10 x i32]**
// CHECK1-NEXT:    [[TMP5:%.*]] = load [10 x i32]*, [10 x i32]** [[TMP4]], align 8
// CHECK1-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i8*, i8** [[TMP2]], i64 1
// CHECK1-NEXT:    [[TMP7:%.*]] = bitcast i8** [[TMP6]] to i32**
// CHECK1-NEXT:    [[TMP8:%.*]] = load i32*, i32** [[TMP7]], align 8
// CHECK1-NEXT:    call void @__omp_outlined__(i32* [[DOTADDR1]], i32* [[DOTZERO_ADDR]], [10 x i32]* [[TMP5]], i32* [[TMP8]]) #[[ATTR3]]
// CHECK1-NEXT:    ret void
//
//
// CHECK2-LABEL: define {{[^@]+}}@{{__omp_offloading_[0-9a-z]+_[0-9a-z]+}}__Z9ftemplateIiET_i_l14_worker
// CHECK2-SAME: () #[[ATTR0:[0-9]+]] {
// CHECK2-NEXT:  entry:
// CHECK2-NEXT:    [[WORK_FN:%.*]] = alloca i8*, align 8
// CHECK2-NEXT:    [[EXEC_STATUS:%.*]] = alloca i8, align 1
// CHECK2-NEXT:    store i8* null, i8** [[WORK_FN]], align 8
// CHECK2-NEXT:    store i8 0, i8* [[EXEC_STATUS]], align 1
// CHECK2-NEXT:    br label [[DOTAWAIT_WORK:%.*]]
// CHECK2:       .await.work:
// CHECK2-NEXT:    call void @__kmpc_barrier_simple_spmd(%struct.ident_t* null, i32 0)
// CHECK2-NEXT:    [[TMP0:%.*]] = call i1 @__kmpc_kernel_parallel(i8** [[WORK_FN]])
// CHECK2-NEXT:    [[TMP1:%.*]] = zext i1 [[TMP0]] to i8
// CHECK2-NEXT:    store i8 [[TMP1]], i8* [[EXEC_STATUS]], align 1
// CHECK2-NEXT:    [[TMP2:%.*]] = load i8*, i8** [[WORK_FN]], align 8
// CHECK2-NEXT:    [[SHOULD_TERMINATE:%.*]] = icmp eq i8* [[TMP2]], null
// CHECK2-NEXT:    br i1 [[SHOULD_TERMINATE]], label [[DOTEXIT:%.*]], label [[DOTSELECT_WORKERS:%.*]]
// CHECK2:       .select.workers:
// CHECK2-NEXT:    [[TMP3:%.*]] = load i8, i8* [[EXEC_STATUS]], align 1
// CHECK2-NEXT:    [[IS_ACTIVE:%.*]] = icmp ne i8 [[TMP3]], 0
// CHECK2-NEXT:    br i1 [[IS_ACTIVE]], label [[DOTEXECUTE_PARALLEL:%.*]], label [[DOTBARRIER_PARALLEL:%.*]]
// CHECK2:       .execute.parallel:
// CHECK2-NEXT:    [[TMP4:%.*]] = call i32 @__kmpc_global_thread_num(%struct.ident_t* @[[GLOB2:[0-9]+]])
// CHECK2-NEXT:    [[TMP5:%.*]] = load i8*, i8** [[WORK_FN]], align 8
// CHECK2-NEXT:    [[WORK_MATCH:%.*]] = icmp eq i8* [[TMP5]], bitcast (void (i16, i32)* @__omp_outlined___wrapper to i8*)
// CHECK2-NEXT:    br i1 [[WORK_MATCH]], label [[DOTEXECUTE_FN:%.*]], label [[DOTCHECK_NEXT:%.*]]
// CHECK2:       .execute.fn:
// CHECK2-NEXT:    call void @__omp_outlined___wrapper(i16 0, i32 [[TMP4]]) #[[ATTR3:[0-9]+]]
// CHECK2-NEXT:    br label [[DOTTERMINATE_PARALLEL:%.*]]
// CHECK2:       .check.next:
// CHECK2-NEXT:    [[TMP6:%.*]] = bitcast i8* [[TMP2]] to void (i16, i32)*
// CHECK2-NEXT:    call void [[TMP6]](i16 0, i32 [[TMP4]])
// CHECK2-NEXT:    br label [[DOTTERMINATE_PARALLEL]]
// CHECK2:       .terminate.parallel:
// CHECK2-NEXT:    call void @__kmpc_kernel_end_parallel()
// CHECK2-NEXT:    br label [[DOTBARRIER_PARALLEL]]
// CHECK2:       .barrier.parallel:
// CHECK2-NEXT:    call void @__kmpc_barrier_simple_spmd(%struct.ident_t* null, i32 0)
// CHECK2-NEXT:    br label [[DOTAWAIT_WORK]]
// CHECK2:       .exit:
// CHECK2-NEXT:    ret void
//
//
// CHECK2-LABEL: define {{[^@]+}}@{{__omp_offloading_[0-9a-z]+_[0-9a-z]+}}__Z9ftemplateIiET_i_l14
// CHECK2-SAME: (i64 [[N:%.*]], [10 x i32]* nonnull align 4 dereferenceable(40) [[B:%.*]]) #[[ATTR1:[0-9]+]] {
// CHECK2-NEXT:  entry:
// CHECK2-NEXT:    [[N_ADDR:%.*]] = alloca i64, align 8
// CHECK2-NEXT:    [[B_ADDR:%.*]] = alloca [10 x i32]*, align 8
// CHECK2-NEXT:    [[CAPTURED_VARS_ADDRS:%.*]] = alloca [2 x i8*], align 8
// CHECK2-NEXT:    store i64 [[N]], i64* [[N_ADDR]], align 8
// CHECK2-NEXT:    store [10 x i32]* [[B]], [10 x i32]** [[B_ADDR]], align 8
// CHECK2-NEXT:    [[CONV:%.*]] = bitcast i64* [[N_ADDR]] to i32*
// CHECK2-NEXT:    [[TMP0:%.*]] = load [10 x i32]*, [10 x i32]** [[B_ADDR]], align 8
// CHECK2-NEXT:    [[NVPTX_TID:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.tid.x()
// CHECK2-NEXT:    [[NVPTX_NUM_THREADS:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
// CHECK2-NEXT:    [[NVPTX_WARP_SIZE:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.warpsize()
// CHECK2-NEXT:    [[THREAD_LIMIT:%.*]] = sub nuw i32 [[NVPTX_NUM_THREADS]], [[NVPTX_WARP_SIZE]]
// CHECK2-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[NVPTX_TID]], [[THREAD_LIMIT]]
// CHECK2-NEXT:    br i1 [[TMP1]], label [[DOTWORKER:%.*]], label [[DOTMASTERCHECK:%.*]]
// CHECK2:       .worker:
// CHECK2-NEXT:    call void @{{__omp_offloading_[0-9a-z]+_[0-9a-z]+}}__Z9ftemplateIiET_i_l14_worker() #[[ATTR3]]
// CHECK2-NEXT:    br label [[DOTEXIT:%.*]]
// CHECK2:       .mastercheck:
// CHECK2-NEXT:    [[NVPTX_TID1:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.tid.x()
// CHECK2-NEXT:    [[NVPTX_NUM_THREADS2:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
// CHECK2-NEXT:    [[NVPTX_WARP_SIZE3:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.warpsize()
// CHECK2-NEXT:    [[TMP2:%.*]] = sub nuw i32 [[NVPTX_WARP_SIZE3]], 1
// CHECK2-NEXT:    [[TMP3:%.*]] = sub nuw i32 [[NVPTX_NUM_THREADS2]], 1
// CHECK2-NEXT:    [[TMP4:%.*]] = xor i32 [[TMP2]], -1
// CHECK2-NEXT:    [[MASTER_TID:%.*]] = and i32 [[TMP3]], [[TMP4]]
// CHECK2-NEXT:    [[TMP5:%.*]] = icmp eq i32 [[NVPTX_TID1]], [[MASTER_TID]]
// CHECK2-NEXT:    br i1 [[TMP5]], label [[DOTMASTER:%.*]], label [[DOTEXIT]]
// CHECK2:       .master:
// CHECK2-NEXT:    [[NVPTX_NUM_THREADS4:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
// CHECK2-NEXT:    [[NVPTX_WARP_SIZE5:%.*]] = call i32 @llvm.nvvm.read.ptx.sreg.warpsize()
// CHECK2-NEXT:    [[THREAD_LIMIT6:%.*]] = sub nuw i32 [[NVPTX_NUM_THREADS4]], [[NVPTX_WARP_SIZE5]]
// CHECK2-NEXT:    call void @__kmpc_kernel_init(i32 [[THREAD_LIMIT6]], i16 1)
// CHECK2-NEXT:    call void @__kmpc_data_sharing_init_stack()
// CHECK2-NEXT:    [[TMP6:%.*]] = call i8* @__kmpc_data_sharing_push_stack(i64 4, i16 1)
// CHECK2-NEXT:    [[TMP7:%.*]] = bitcast i8* [[TMP6]] to %struct._globalized_locals_ty*
// CHECK2-NEXT:    [[D:%.*]] = getelementptr inbounds [[STRUCT__GLOBALIZED_LOCALS_TY:%.*]], %struct._globalized_locals_ty* [[TMP7]], i32 0, i32 0
// CHECK2-NEXT:    [[TMP8:%.*]] = call i32 @__kmpc_global_thread_num(%struct.ident_t* @[[GLOB2]])
// CHECK2-NEXT:    [[TMP9:%.*]] = load i32, i32* [[CONV]], align 8
// CHECK2-NEXT:    store i32 [[TMP9]], i32* [[D]], align 4
// CHECK2-NEXT:    [[TMP10:%.*]] = getelementptr inbounds [2 x i8*], [2 x i8*]* [[CAPTURED_VARS_ADDRS]], i64 0, i64 0
// CHECK2-NEXT:    [[TMP11:%.*]] = bitcast [10 x i32]* [[TMP0]] to i8*
// CHECK2-NEXT:    store i8* [[TMP11]], i8** [[TMP10]], align 8
// CHECK2-NEXT:    [[TMP12:%.*]] = getelementptr inbounds [2 x i8*], [2 x i8*]* [[CAPTURED_VARS_ADDRS]], i64 0, i64 1
// CHECK2-NEXT:    [[TMP13:%.*]] = bitcast i32* [[D]] to i8*
// CHECK2-NEXT:    store i8* [[TMP13]], i8** [[TMP12]], align 8
// CHECK2-NEXT:    [[TMP14:%.*]] = bitcast [2 x i8*]* [[CAPTURED_VARS_ADDRS]] to i8**
// CHECK2-NEXT:    call void @__kmpc_parallel_51(%struct.ident_t* @[[GLOB2]], i32 [[TMP8]], i32 1, i32 -1, i32 -1, i8* bitcast (void (i32*, i32*, [10 x i32]*, i32*)* @__omp_outlined__ to i8*), i8* bitcast (void (i16, i32)* @__omp_outlined___wrapper to i8*), i8** [[TMP14]], i64 2)
// CHECK2-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [10 x i32], [10 x i32]* [[TMP0]], i64 0, i64 3
// CHECK2-NEXT:    [[TMP15:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
// CHECK2-NEXT:    [[ADD:%.*]] = add nsw i32 [[TMP15]], 1
// CHECK2-NEXT:    store i32 [[ADD]], i32* [[ARRAYIDX]], align 4
// CHECK2-NEXT:    call void @__kmpc_data_sharing_pop_stack(i8* [[TMP6]])
// CHECK2-NEXT:    br label [[DOTTERMINATION_NOTIFIER:%.*]]
// CHECK2:       .termination.notifier:
// CHECK2-NEXT:    call void @__kmpc_kernel_deinit(i16 1)
// CHECK2-NEXT:    call void @__kmpc_barrier_simple_spmd(%struct.ident_t* null, i32 0)
// CHECK2-NEXT:    br label [[DOTEXIT]]
// CHECK2:       .exit:
// CHECK2-NEXT:    ret void
//
//
// CHECK2-LABEL: define {{[^@]+}}@__omp_outlined__
// CHECK2-SAME: (i32* noalias [[DOTGLOBAL_TID_:%.*]], i32* noalias [[DOTBOUND_TID_:%.*]], [10 x i32]* nonnull align 4 dereferenceable(40) [[B:%.*]], i32* nonnull align 4 dereferenceable(4) [[D:%.*]]) #[[ATTR1]] {
// CHECK2-NEXT:  entry:
// CHECK2-NEXT:    [[DOTGLOBAL_TID__ADDR:%.*]] = alloca i32*, align 8
// CHECK2-NEXT:    [[DOTBOUND_TID__ADDR:%.*]] = alloca i32*, align 8
// CHECK2-NEXT:    [[B_ADDR:%.*]] = alloca [10 x i32]*, align 8
// CHECK2-NEXT:    [[D_ADDR:%.*]] = alloca i32*, align 8
// CHECK2-NEXT:    [[DOTOMP_IV:%.*]] = alloca i32, align 4
// CHECK2-NEXT:    [[TMP:%.*]] = alloca i32, align 4
// CHECK2-NEXT:    [[DOTOMP_LB:%.*]] = alloca i32, align 4
// CHECK2-NEXT:    [[DOTOMP_UB:%.*]] = alloca i32, align 4
// CHECK2-NEXT:    [[DOTOMP_STRIDE:%.*]] = alloca i32, align 4
// CHECK2-NEXT:    [[DOTOMP_IS_LAST:%.*]] = alloca i32, align 4
// CHECK2-NEXT:    [[I:%.*]] = alloca i32, align 4
// CHECK2-NEXT:    store i32* [[DOTGLOBAL_TID_]], i32** [[DOTGLOBAL_TID__ADDR]], align 8
// CHECK2-NEXT:    store i32* [[DOTBOUND_TID_]], i32** [[DOTBOUND_TID__ADDR]], align 8
// CHECK2-NEXT:    store [10 x i32]* [[B]], [10 x i32]** [[B_ADDR]], align 8
// CHECK2-NEXT:    store i32* [[D]], i32** [[D_ADDR]], align 8
// CHECK2-NEXT:    [[TMP0:%.*]] = load [10 x i32]*, [10 x i32]** [[B_ADDR]], align 8
// CHECK2-NEXT:    [[TMP1:%.*]] = load i32*, i32** [[D_ADDR]], align 8
// CHECK2-NEXT:    store i32 0, i32* [[DOTOMP_LB]], align 4
// CHECK2-NEXT:    store i32 9, i32* [[DOTOMP_UB]], align 4
// CHECK2-NEXT:    store i32 1, i32* [[DOTOMP_STRIDE]], align 4
// CHECK2-NEXT:    store i32 0, i32* [[DOTOMP_IS_LAST]], align 4
// CHECK2-NEXT:    [[TMP2:%.*]] = load i32*, i32** [[DOTGLOBAL_TID__ADDR]], align 8
// CHECK2-NEXT:    [[TMP3:%.*]] = load i32, i32* [[TMP2]], align 4
// CHECK2-NEXT:    call void @__kmpc_for_static_init_4(%struct.ident_t* @[[GLOB1:[0-9]+]], i32 [[TMP3]], i32 33, i32* [[DOTOMP_IS_LAST]], i32* [[DOTOMP_LB]], i32* [[DOTOMP_UB]], i32* [[DOTOMP_STRIDE]], i32 1, i32 1)
// CHECK2-NEXT:    br label [[OMP_DISPATCH_COND:%.*]]
// CHECK2:       omp.dispatch.cond:
// CHECK2-NEXT:    [[TMP4:%.*]] = load i32, i32* [[DOTOMP_UB]], align 4
// CHECK2-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[TMP4]], 9
// CHECK2-NEXT:    br i1 [[CMP]], label [[COND_TRUE:%.*]], label [[COND_FALSE:%.*]]
// CHECK2:       cond.true:
// CHECK2-NEXT:    br label [[COND_END:%.*]]
// CHECK2:       cond.false:
// CHECK2-NEXT:    [[TMP5:%.*]] = load i32, i32* [[DOTOMP_UB]], align 4
// CHECK2-NEXT:    br label [[COND_END]]
// CHECK2:       cond.end:
// CHECK2-NEXT:    [[COND:%.*]] = phi i32 [ 9, [[COND_TRUE]] ], [ [[TMP5]], [[COND_FALSE]] ]
// CHECK2-NEXT:    store i32 [[COND]], i32* [[DOTOMP_UB]], align 4
// CHECK2-NEXT:    [[TMP6:%.*]] = load i32, i32* [[DOTOMP_LB]], align 4
// CHECK2-NEXT:    store i32 [[TMP6]], i32* [[DOTOMP_IV]], align 4
// CHECK2-NEXT:    [[TMP7:%.*]] = load i32, i32* [[DOTOMP_IV]], align 4
// CHECK2-NEXT:    [[TMP8:%.*]] = load i32, i32* [[DOTOMP_UB]], align 4
// CHECK2-NEXT:    [[CMP1:%.*]] = icmp sle i32 [[TMP7]], [[TMP8]]
// CHECK2-NEXT:    br i1 [[CMP1]], label [[OMP_DISPATCH_BODY:%.*]], label [[OMP_DISPATCH_END:%.*]]
// CHECK2:       omp.dispatch.body:
// CHECK2-NEXT:    br label [[OMP_INNER_FOR_COND:%.*]]
// CHECK2:       omp.inner.for.cond:
// CHECK2-NEXT:    [[TMP9:%.*]] = load i32, i32* [[DOTOMP_IV]], align 4
// CHECK2-NEXT:    [[TMP10:%.*]] = load i32, i32* [[DOTOMP_UB]], align 4
// CHECK2-NEXT:    [[CMP2:%.*]] = icmp sle i32 [[TMP9]], [[TMP10]]
// CHECK2-NEXT:    br i1 [[CMP2]], label [[OMP_INNER_FOR_BODY:%.*]], label [[OMP_INNER_FOR_END:%.*]]
// CHECK2:       omp.inner.for.body:
// CHECK2-NEXT:    [[TMP11:%.*]] = load i32, i32* [[DOTOMP_IV]], align 4
// CHECK2-NEXT:    [[MUL:%.*]] = mul nsw i32 [[TMP11]], 1
// CHECK2-NEXT:    [[ADD:%.*]] = add nsw i32 0, [[MUL]]
// CHECK2-NEXT:    store i32 [[ADD]], i32* [[I]], align 4
// CHECK2-NEXT:    [[TMP12:%.*]] = load i32, i32* [[TMP1]], align 4
// CHECK2-NEXT:    [[TMP13:%.*]] = load i32, i32* [[I]], align 4
// CHECK2-NEXT:    [[IDXPROM:%.*]] = sext i32 [[TMP13]] to i64
// CHECK2-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [10 x i32], [10 x i32]* [[TMP0]], i64 0, i64 [[IDXPROM]]
// CHECK2-NEXT:    [[TMP14:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
// CHECK2-NEXT:    [[ADD3:%.*]] = add nsw i32 [[TMP14]], [[TMP12]]
// CHECK2-NEXT:    store i32 [[ADD3]], i32* [[ARRAYIDX]], align 4
// CHECK2-NEXT:    br label [[OMP_BODY_CONTINUE:%.*]]
// CHECK2:       omp.body.continue:
// CHECK2-NEXT:    br label [[OMP_INNER_FOR_INC:%.*]]
// CHECK2:       omp.inner.for.inc:
// CHECK2-NEXT:    [[TMP15:%.*]] = load i32, i32* [[DOTOMP_IV]], align 4
// CHECK2-NEXT:    [[ADD4:%.*]] = add nsw i32 [[TMP15]], 1
// CHECK2-NEXT:    store i32 [[ADD4]], i32* [[DOTOMP_IV]], align 4
// CHECK2-NEXT:    br label [[OMP_INNER_FOR_COND]]
// CHECK2:       omp.inner.for.end:
// CHECK2-NEXT:    br label [[OMP_DISPATCH_INC:%.*]]
// CHECK2:       omp.dispatch.inc:
// CHECK2-NEXT:    [[TMP16:%.*]] = load i32, i32* [[DOTOMP_LB]], align 4
// CHECK2-NEXT:    [[TMP17:%.*]] = load i32, i32* [[DOTOMP_STRIDE]], align 4
// CHECK2-NEXT:    [[ADD5:%.*]] = add nsw i32 [[TMP16]], [[TMP17]]
// CHECK2-NEXT:    store i32 [[ADD5]], i32* [[DOTOMP_LB]], align 4
// CHECK2-NEXT:    [[TMP18:%.*]] = load i32, i32* [[DOTOMP_UB]], align 4
// CHECK2-NEXT:    [[TMP19:%.*]] = load i32, i32* [[DOTOMP_STRIDE]], align 4
// CHECK2-NEXT:    [[ADD6:%.*]] = add nsw i32 [[TMP18]], [[TMP19]]
// CHECK2-NEXT:    store i32 [[ADD6]], i32* [[DOTOMP_UB]], align 4
// CHECK2-NEXT:    br label [[OMP_DISPATCH_COND]]
// CHECK2:       omp.dispatch.end:
// CHECK2-NEXT:    call void @__kmpc_for_static_fini(%struct.ident_t* @[[GLOB1]], i32 [[TMP3]])
// CHECK2-NEXT:    ret void
//
//
// CHECK2-LABEL: define {{[^@]+}}@__omp_outlined___wrapper
// CHECK2-SAME: (i16 zeroext [[TMP0:%.*]], i32 [[TMP1:%.*]]) #[[ATTR0]] {
// CHECK2-NEXT:  entry:
// CHECK2-NEXT:    [[DOTADDR:%.*]] = alloca i16, align 2
// CHECK2-NEXT:    [[DOTADDR1:%.*]] = alloca i32, align 4
// CHECK2-NEXT:    [[DOTZERO_ADDR:%.*]] = alloca i32, align 4
// CHECK2-NEXT:    [[GLOBAL_ARGS:%.*]] = alloca i8**, align 8
// CHECK2-NEXT:    store i32 0, i32* [[DOTZERO_ADDR]], align 4
// CHECK2-NEXT:    store i16 [[TMP0]], i16* [[DOTADDR]], align 2
// CHECK2-NEXT:    store i32 [[TMP1]], i32* [[DOTADDR1]], align 4
// CHECK2-NEXT:    call void @__kmpc_get_shared_variables(i8*** [[GLOBAL_ARGS]])
// CHECK2-NEXT:    [[TMP2:%.*]] = load i8**, i8*** [[GLOBAL_ARGS]], align 8
// CHECK2-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i8*, i8** [[TMP2]], i64 0
// CHECK2-NEXT:    [[TMP4:%.*]] = bitcast i8** [[TMP3]] to [10 x i32]**
// CHECK2-NEXT:    [[TMP5:%.*]] = load [10 x i32]*, [10 x i32]** [[TMP4]], align 8
// CHECK2-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i8*, i8** [[TMP2]], i64 1
// CHECK2-NEXT:    [[TMP7:%.*]] = bitcast i8** [[TMP6]] to i32**
// CHECK2-NEXT:    [[TMP8:%.*]] = load i32*, i32** [[TMP7]], align 8
// CHECK2-NEXT:    call void @__omp_outlined__(i32* [[DOTADDR1]], i32* [[DOTZERO_ADDR]], [10 x i32]* [[TMP5]], i32* [[TMP8]]) #[[ATTR3]]
// CHECK2-NEXT:    ret void
//
