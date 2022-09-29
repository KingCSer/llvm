; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basic-aa -slp-vectorizer -S -mtriple=aarch64-unknown-unknown -mcpu=cortex-a53 | FileCheck %s

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"

; This test is reduced from the matrix multiplication benchmark in the test-suite:
; https://github.com/llvm/llvm-test-suite/tree/main/SingleSource/Benchmarks/Misc/matmul_f64_4x4.c
; The operations here are expected to be vectorized to <2 x double>.
; Otherwise, performance will suffer on Cortex-A53.

define void @wrap_mul4(double* nocapture %Out, [2 x double]* nocapture readonly %A, [4 x double]* nocapture readonly %B) {
; CHECK-LABEL: @wrap_mul4(
; CHECK-NEXT:    [[ARRAYIDX1_I:%.*]] = getelementptr inbounds [2 x double], [2 x double]* [[A:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[TEMP:%.*]] = load double, double* [[ARRAYIDX1_I]], align 8
; CHECK-NEXT:    [[ARRAYIDX3_I:%.*]] = getelementptr inbounds [4 x double], [4 x double]* [[B:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[ARRAYIDX5_I:%.*]] = getelementptr inbounds [2 x double], [2 x double]* [[A]], i64 0, i64 1
; CHECK-NEXT:    [[TEMP2:%.*]] = load double, double* [[ARRAYIDX5_I]], align 8
; CHECK-NEXT:    [[ARRAYIDX7_I:%.*]] = getelementptr inbounds [4 x double], [4 x double]* [[B]], i64 1, i64 0
; CHECK-NEXT:    [[ARRAYIDX13_I:%.*]] = getelementptr inbounds [4 x double], [4 x double]* [[B]], i64 0, i64 1
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast double* [[ARRAYIDX3_I]] to <2 x double>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x double>, <2 x double>* [[TMP1]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x double> poison, double [[TEMP]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x double> [[TMP3]], double [[TEMP]], i32 1
; CHECK-NEXT:    [[TMP5:%.*]] = fmul <2 x double> [[TMP4]], [[TMP2]]
; CHECK-NEXT:    [[ARRAYIDX18_I:%.*]] = getelementptr inbounds [4 x double], [4 x double]* [[B]], i64 1, i64 1
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast double* [[ARRAYIDX7_I]] to <2 x double>*
; CHECK-NEXT:    [[TMP7:%.*]] = load <2 x double>, <2 x double>* [[TMP6]], align 8
; CHECK-NEXT:    [[TMP8:%.*]] = insertelement <2 x double> poison, double [[TEMP2]], i32 0
; CHECK-NEXT:    [[TMP9:%.*]] = insertelement <2 x double> [[TMP8]], double [[TEMP2]], i32 1
; CHECK-NEXT:    [[TMP10:%.*]] = fmul <2 x double> [[TMP9]], [[TMP7]]
; CHECK-NEXT:    [[TMP11:%.*]] = fadd <2 x double> [[TMP5]], [[TMP10]]
; CHECK-NEXT:    [[ARRAYIDX25_I:%.*]] = getelementptr inbounds [4 x double], [4 x double]* [[B]], i64 0, i64 2
; CHECK-NEXT:    [[ARRAYIDX30_I:%.*]] = getelementptr inbounds [4 x double], [4 x double]* [[B]], i64 1, i64 2
; CHECK-NEXT:    [[ARRAYIDX37_I:%.*]] = getelementptr inbounds [4 x double], [4 x double]* [[B]], i64 0, i64 3
; CHECK-NEXT:    [[TMP12:%.*]] = bitcast double* [[ARRAYIDX25_I]] to <2 x double>*
; CHECK-NEXT:    [[TMP13:%.*]] = load <2 x double>, <2 x double>* [[TMP12]], align 8
; CHECK-NEXT:    [[TMP14:%.*]] = fmul <2 x double> [[TMP4]], [[TMP13]]
; CHECK-NEXT:    [[ARRAYIDX42_I:%.*]] = getelementptr inbounds [4 x double], [4 x double]* [[B]], i64 1, i64 3
; CHECK-NEXT:    [[TMP15:%.*]] = bitcast double* [[ARRAYIDX30_I]] to <2 x double>*
; CHECK-NEXT:    [[TMP16:%.*]] = load <2 x double>, <2 x double>* [[TMP15]], align 8
; CHECK-NEXT:    [[TMP17:%.*]] = fmul <2 x double> [[TMP9]], [[TMP16]]
; CHECK-NEXT:    [[TMP18:%.*]] = fadd <2 x double> [[TMP14]], [[TMP17]]
; CHECK-NEXT:    [[ARRAYIDX47_I:%.*]] = getelementptr inbounds [2 x double], [2 x double]* [[A]], i64 1, i64 0
; CHECK-NEXT:    [[TEMP10:%.*]] = load double, double* [[ARRAYIDX47_I]], align 8
; CHECK-NEXT:    [[ARRAYIDX52_I:%.*]] = getelementptr inbounds [2 x double], [2 x double]* [[A]], i64 1, i64 1
; CHECK-NEXT:    [[TEMP11:%.*]] = load double, double* [[ARRAYIDX52_I]], align 8
; CHECK-NEXT:    [[TMP19:%.*]] = insertelement <2 x double> poison, double [[TEMP10]], i32 0
; CHECK-NEXT:    [[TMP20:%.*]] = insertelement <2 x double> [[TMP19]], double [[TEMP10]], i32 1
; CHECK-NEXT:    [[TMP21:%.*]] = fmul <2 x double> [[TMP2]], [[TMP20]]
; CHECK-NEXT:    [[TMP22:%.*]] = insertelement <2 x double> poison, double [[TEMP11]], i32 0
; CHECK-NEXT:    [[TMP23:%.*]] = insertelement <2 x double> [[TMP22]], double [[TEMP11]], i32 1
; CHECK-NEXT:    [[TMP24:%.*]] = fmul <2 x double> [[TMP7]], [[TMP23]]
; CHECK-NEXT:    [[TMP25:%.*]] = fadd <2 x double> [[TMP21]], [[TMP24]]
; CHECK-NEXT:    [[TMP26:%.*]] = fmul <2 x double> [[TMP13]], [[TMP20]]
; CHECK-NEXT:    [[TMP27:%.*]] = fmul <2 x double> [[TMP16]], [[TMP23]]
; CHECK-NEXT:    [[TMP28:%.*]] = fadd <2 x double> [[TMP26]], [[TMP27]]
; CHECK-NEXT:    [[RES_I_SROA_4_0_OUT2_I_SROA_IDX2:%.*]] = getelementptr inbounds double, double* [[OUT:%.*]], i64 1
; CHECK-NEXT:    [[TMP29:%.*]] = bitcast double* [[OUT]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP11]], <2 x double>* [[TMP29]], align 8
; CHECK-NEXT:    [[RES_I_SROA_5_0_OUT2_I_SROA_IDX4:%.*]] = getelementptr inbounds double, double* [[OUT]], i64 2
; CHECK-NEXT:    [[RES_I_SROA_6_0_OUT2_I_SROA_IDX6:%.*]] = getelementptr inbounds double, double* [[OUT]], i64 3
; CHECK-NEXT:    [[TMP30:%.*]] = bitcast double* [[RES_I_SROA_5_0_OUT2_I_SROA_IDX4]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP18]], <2 x double>* [[TMP30]], align 8
; CHECK-NEXT:    [[RES_I_SROA_7_0_OUT2_I_SROA_IDX8:%.*]] = getelementptr inbounds double, double* [[OUT]], i64 4
; CHECK-NEXT:    [[RES_I_SROA_8_0_OUT2_I_SROA_IDX10:%.*]] = getelementptr inbounds double, double* [[OUT]], i64 5
; CHECK-NEXT:    [[TMP31:%.*]] = bitcast double* [[RES_I_SROA_7_0_OUT2_I_SROA_IDX8]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP25]], <2 x double>* [[TMP31]], align 8
; CHECK-NEXT:    [[RES_I_SROA_9_0_OUT2_I_SROA_IDX12:%.*]] = getelementptr inbounds double, double* [[OUT]], i64 6
; CHECK-NEXT:    [[RES_I_SROA_10_0_OUT2_I_SROA_IDX14:%.*]] = getelementptr inbounds double, double* [[OUT]], i64 7
; CHECK-NEXT:    [[TMP32:%.*]] = bitcast double* [[RES_I_SROA_9_0_OUT2_I_SROA_IDX12]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP28]], <2 x double>* [[TMP32]], align 8
; CHECK-NEXT:    ret void
;
  %arrayidx1.i = getelementptr inbounds [2 x double], [2 x double]* %A, i64 0, i64 0
  %temp = load double, double* %arrayidx1.i, align 8
  %arrayidx3.i = getelementptr inbounds [4 x double], [4 x double]* %B, i64 0, i64 0
  %temp1 = load double, double* %arrayidx3.i, align 8
  %mul.i = fmul double %temp, %temp1
  %arrayidx5.i = getelementptr inbounds [2 x double], [2 x double]* %A, i64 0, i64 1
  %temp2 = load double, double* %arrayidx5.i, align 8
  %arrayidx7.i = getelementptr inbounds [4 x double], [4 x double]* %B, i64 1, i64 0
  %temp3 = load double, double* %arrayidx7.i, align 8
  %mul8.i = fmul double %temp2, %temp3
  %add.i = fadd double %mul.i, %mul8.i
  %arrayidx13.i = getelementptr inbounds [4 x double], [4 x double]* %B, i64 0, i64 1
  %temp4 = load double, double* %arrayidx13.i, align 8
  %mul14.i = fmul double %temp, %temp4
  %arrayidx18.i = getelementptr inbounds [4 x double], [4 x double]* %B, i64 1, i64 1
  %temp5 = load double, double* %arrayidx18.i, align 8
  %mul19.i = fmul double %temp2, %temp5
  %add20.i = fadd double %mul14.i, %mul19.i
  %arrayidx25.i = getelementptr inbounds [4 x double], [4 x double]* %B, i64 0, i64 2
  %temp6 = load double, double* %arrayidx25.i, align 8
  %mul26.i = fmul double %temp, %temp6
  %arrayidx30.i = getelementptr inbounds [4 x double], [4 x double]* %B, i64 1, i64 2
  %temp7 = load double, double* %arrayidx30.i, align 8
  %mul31.i = fmul double %temp2, %temp7
  %add32.i = fadd double %mul26.i, %mul31.i
  %arrayidx37.i = getelementptr inbounds [4 x double], [4 x double]* %B, i64 0, i64 3
  %temp8 = load double, double* %arrayidx37.i, align 8
  %mul38.i = fmul double %temp, %temp8
  %arrayidx42.i = getelementptr inbounds [4 x double], [4 x double]* %B, i64 1, i64 3
  %temp9 = load double, double* %arrayidx42.i, align 8
  %mul43.i = fmul double %temp2, %temp9
  %add44.i = fadd double %mul38.i, %mul43.i
  %arrayidx47.i = getelementptr inbounds [2 x double], [2 x double]* %A, i64 1, i64 0
  %temp10 = load double, double* %arrayidx47.i, align 8
  %mul50.i = fmul double %temp1, %temp10
  %arrayidx52.i = getelementptr inbounds [2 x double], [2 x double]* %A, i64 1, i64 1
  %temp11 = load double, double* %arrayidx52.i, align 8
  %mul55.i = fmul double %temp3, %temp11
  %add56.i = fadd double %mul50.i, %mul55.i
  %mul62.i = fmul double %temp4, %temp10
  %mul67.i = fmul double %temp5, %temp11
  %add68.i = fadd double %mul62.i, %mul67.i
  %mul74.i = fmul double %temp6, %temp10
  %mul79.i = fmul double %temp7, %temp11
  %add80.i = fadd double %mul74.i, %mul79.i
  %mul86.i = fmul double %temp8, %temp10
  %mul91.i = fmul double %temp9, %temp11
  %add92.i = fadd double %mul86.i, %mul91.i
  store double %add.i, double* %Out, align 8
  %Res.i.sroa.4.0.Out2.i.sroa_idx2 = getelementptr inbounds double, double* %Out, i64 1
  store double %add20.i, double* %Res.i.sroa.4.0.Out2.i.sroa_idx2, align 8
  %Res.i.sroa.5.0.Out2.i.sroa_idx4 = getelementptr inbounds double, double* %Out, i64 2
  store double %add32.i, double* %Res.i.sroa.5.0.Out2.i.sroa_idx4, align 8
  %Res.i.sroa.6.0.Out2.i.sroa_idx6 = getelementptr inbounds double, double* %Out, i64 3
  store double %add44.i, double* %Res.i.sroa.6.0.Out2.i.sroa_idx6, align 8
  %Res.i.sroa.7.0.Out2.i.sroa_idx8 = getelementptr inbounds double, double* %Out, i64 4
  store double %add56.i, double* %Res.i.sroa.7.0.Out2.i.sroa_idx8, align 8
  %Res.i.sroa.8.0.Out2.i.sroa_idx10 = getelementptr inbounds double, double* %Out, i64 5
  store double %add68.i, double* %Res.i.sroa.8.0.Out2.i.sroa_idx10, align 8
  %Res.i.sroa.9.0.Out2.i.sroa_idx12 = getelementptr inbounds double, double* %Out, i64 6
  store double %add80.i, double* %Res.i.sroa.9.0.Out2.i.sroa_idx12, align 8
  %Res.i.sroa.10.0.Out2.i.sroa_idx14 = getelementptr inbounds double, double* %Out, i64 7
  store double %add92.i, double* %Res.i.sroa.10.0.Out2.i.sroa_idx14, align 8
  ret void
}

