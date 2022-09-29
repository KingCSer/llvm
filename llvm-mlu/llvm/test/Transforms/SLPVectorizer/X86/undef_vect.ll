; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -slp-vectorizer -slp-vectorize-hor -slp-vectorize-hor-store -S < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=bdver2 | FileCheck %s

%"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76" = type { i32, i32 }

define void @_Z2azv() local_unnamed_addr {
; CHECK-LABEL: @_Z2azv(
; CHECK-NEXT:  for.body.lr.ph:
; CHECK-NEXT:    [[DOTSROA_CAST_4:%.*]] = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 4, i32 0
; CHECK-NEXT:    [[DOTSROA_RAW_IDX_4:%.*]] = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 4, i32 1
; CHECK-NEXT:    [[DOTSROA_CAST_5:%.*]] = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 5, i32 0
; CHECK-NEXT:    [[DOTSROA_RAW_IDX_5:%.*]] = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 5, i32 1
; CHECK-NEXT:    [[DOTSROA_CAST_6:%.*]] = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 6, i32 0
; CHECK-NEXT:    [[DOTSROA_RAW_IDX_6:%.*]] = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 6, i32 1
; CHECK-NEXT:    [[DOTSROA_CAST_7:%.*]] = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 7, i32 0
; CHECK-NEXT:    [[DOTSROA_RAW_IDX_7:%.*]] = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 7, i32 1
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast i32* [[DOTSROA_CAST_4]] to <8 x i32>*
; CHECK-NEXT:    [[TMP1:%.*]] = load <8 x i32>, <8 x i32>* [[TMP0]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = call i32 @llvm.vector.reduce.smax.v8i32(<8 x i32> [[TMP1]])
; CHECK-NEXT:    [[TMP3:%.*]] = icmp sgt i32 [[TMP2]], undef
; CHECK-NEXT:    [[OP_EXTRA:%.*]] = select i1 [[TMP3]], i32 [[TMP2]], i32 undef
; CHECK-NEXT:    [[TMP4:%.*]] = icmp sgt i32 [[OP_EXTRA]], undef
; CHECK-NEXT:    [[OP_EXTRA1:%.*]] = select i1 [[TMP4]], i32 [[OP_EXTRA]], i32 undef
; CHECK-NEXT:    [[DOTSROA_SPECULATED_9:%.*]] = select i1 undef, i32 undef, i32 [[OP_EXTRA1]]
; CHECK-NEXT:    [[CMP_I1_10:%.*]] = icmp slt i32 [[DOTSROA_SPECULATED_9]], undef
; CHECK-NEXT:    ret void
;
for.body.lr.ph:
  %.sroa_cast.4 = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 4, i32 0
  %retval.sroa.0.0.copyload.i5.4 = load i32, i32* %.sroa_cast.4, align 4
  %.sroa_raw_idx.4 = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 4, i32 1
  %retval.sroa.0.0.copyload.i7.4 = load i32, i32* %.sroa_raw_idx.4, align 4
  %cmp.i2.4 = icmp slt i32 %retval.sroa.0.0.copyload.i5.4, %retval.sroa.0.0.copyload.i7.4
  %0 = select i1 %cmp.i2.4, i32 %retval.sroa.0.0.copyload.i7.4, i32 %retval.sroa.0.0.copyload.i5.4
  %cmp.i1.4 = icmp slt i32 undef, %0
  %.sroa.speculated.4 = select i1 %cmp.i1.4, i32 %0, i32 undef
  %.sroa_cast.5 = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 5, i32 0
  %retval.sroa.0.0.copyload.i5.5 = load i32, i32* %.sroa_cast.5, align 4
  %.sroa_raw_idx.5 = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 5, i32 1
  %retval.sroa.0.0.copyload.i7.5 = load i32, i32* %.sroa_raw_idx.5, align 4
  %cmp.i2.5 = icmp slt i32 %retval.sroa.0.0.copyload.i5.5, %retval.sroa.0.0.copyload.i7.5
  %1 = select i1 %cmp.i2.5, i32 %retval.sroa.0.0.copyload.i7.5, i32 %retval.sroa.0.0.copyload.i5.5
  %cmp.i1.5 = icmp slt i32 %.sroa.speculated.4, %1
  %.sroa.speculated.5 = select i1 %cmp.i1.5, i32 %1, i32 %.sroa.speculated.4
  %.sroa_cast.6 = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 6, i32 0
  %retval.sroa.0.0.copyload.i5.6 = load i32, i32* %.sroa_cast.6, align 4
  %.sroa_raw_idx.6 = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 6, i32 1
  %retval.sroa.0.0.copyload.i7.6 = load i32, i32* %.sroa_raw_idx.6, align 4
  %cmp.i2.6 = icmp slt i32 %retval.sroa.0.0.copyload.i5.6, %retval.sroa.0.0.copyload.i7.6
  %2 = select i1 %cmp.i2.6, i32 %retval.sroa.0.0.copyload.i7.6, i32 %retval.sroa.0.0.copyload.i5.6
  %cmp.i1.6 = icmp slt i32 %.sroa.speculated.5, %2
  %.sroa.speculated.6 = select i1 %cmp.i1.6, i32 %2, i32 %.sroa.speculated.5
  %.sroa_cast.7 = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 7, i32 0
  %retval.sroa.0.0.copyload.i5.7 = load i32, i32* %.sroa_cast.7, align 4
  %.sroa_raw_idx.7 = getelementptr inbounds %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76", %"struct.std::h.0.4.8.12.16.20.24.28.248.0.1.2.3.76"* undef, i64 7, i32 1
  %retval.sroa.0.0.copyload.i7.7 = load i32, i32* %.sroa_raw_idx.7, align 4
  %cmp.i2.7 = icmp slt i32 %retval.sroa.0.0.copyload.i5.7, %retval.sroa.0.0.copyload.i7.7
  %3 = select i1 %cmp.i2.7, i32 %retval.sroa.0.0.copyload.i7.7, i32 %retval.sroa.0.0.copyload.i5.7
  %cmp.i1.7 = icmp slt i32 %.sroa.speculated.6, %3
  %.sroa.speculated.7 = select i1 %cmp.i1.7, i32 %3, i32 %.sroa.speculated.6
  %cmp.i1.8 = icmp slt i32 %.sroa.speculated.7, undef
  %.sroa.speculated.8 = select i1 %cmp.i1.8, i32 undef, i32 %.sroa.speculated.7
  %.sroa.speculated.9 = select i1 undef, i32 undef, i32 %.sroa.speculated.8
  %cmp.i1.10 = icmp slt i32 %.sroa.speculated.9, undef
  ret void
}

