; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -slp-vectorizer -S | FileCheck %s --check-prefix=DEFAULT
; RUN: opt < %s -slp-schedule-budget=0 -slp-min-tree-size=0 -slp-threshold=-30 -slp-vectorizer -S | FileCheck %s --check-prefix=GATHER
; RUN: opt < %s -slp-schedule-budget=0 -slp-threshold=-30 -slp-vectorizer -S | FileCheck %s --check-prefix=MAX-COST

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64--linux-gnu"

@a = common global [80 x i8] zeroinitializer, align 16

define void @PR28330(i32 %n) {
; DEFAULT-LABEL: @PR28330(
; DEFAULT-NEXT:  entry:
; DEFAULT-NEXT:    [[TMP0:%.*]] = load <8 x i8>, <8 x i8>* bitcast (i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 1) to <8 x i8>*), align 1
; DEFAULT-NEXT:    [[TMP1:%.*]] = icmp eq <8 x i8> [[TMP0]], zeroinitializer
; DEFAULT-NEXT:    br label [[FOR_BODY:%.*]]
; DEFAULT:       for.body:
; DEFAULT-NEXT:    [[P17:%.*]] = phi i32 [ [[OP_EXTRA:%.*]], [[FOR_BODY]] ], [ 0, [[ENTRY:%.*]] ]
; DEFAULT-NEXT:    [[TMP2:%.*]] = select <8 x i1> [[TMP1]], <8 x i32> <i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720>, <8 x i32> <i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80>
; DEFAULT-NEXT:    [[TMP3:%.*]] = call i32 @llvm.vector.reduce.add.v8i32(<8 x i32> [[TMP2]])
; DEFAULT-NEXT:    [[OP_EXTRA]] = add i32 [[TMP3]], [[P17]]
; DEFAULT-NEXT:    br label [[FOR_BODY]]
;
; GATHER-LABEL: @PR28330(
; GATHER-NEXT:  entry:
; GATHER-NEXT:    [[TMP0:%.*]] = load <8 x i8>, <8 x i8>* bitcast (i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 1) to <8 x i8>*), align 1
; GATHER-NEXT:    [[TMP1:%.*]] = icmp eq <8 x i8> [[TMP0]], zeroinitializer
; GATHER-NEXT:    br label [[FOR_BODY:%.*]]
; GATHER:       for.body:
; GATHER-NEXT:    [[P17:%.*]] = phi i32 [ [[OP_EXTRA:%.*]], [[FOR_BODY]] ], [ 0, [[ENTRY:%.*]] ]
; GATHER-NEXT:    [[TMP2:%.*]] = extractelement <8 x i1> [[TMP1]], i32 7
; GATHER-NEXT:    [[TMP3:%.*]] = select <8 x i1> [[TMP1]], <8 x i32> <i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720>, <8 x i32> <i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80>
; GATHER-NEXT:    [[TMP4:%.*]] = extractelement <8 x i1> [[TMP1]], i32 6
; GATHER-NEXT:    [[TMP5:%.*]] = extractelement <8 x i1> [[TMP1]], i32 5
; GATHER-NEXT:    [[TMP6:%.*]] = extractelement <8 x i1> [[TMP1]], i32 4
; GATHER-NEXT:    [[TMP7:%.*]] = extractelement <8 x i1> [[TMP1]], i32 3
; GATHER-NEXT:    [[TMP8:%.*]] = extractelement <8 x i1> [[TMP1]], i32 2
; GATHER-NEXT:    [[TMP9:%.*]] = extractelement <8 x i1> [[TMP1]], i32 1
; GATHER-NEXT:    [[TMP10:%.*]] = extractelement <8 x i1> [[TMP1]], i32 0
; GATHER-NEXT:    [[TMP11:%.*]] = extractelement <8 x i32> [[TMP3]], i32 0
; GATHER-NEXT:    [[TMP12:%.*]] = extractelement <8 x i32> [[TMP3]], i32 1
; GATHER-NEXT:    [[TMP13:%.*]] = extractelement <8 x i32> [[TMP3]], i32 2
; GATHER-NEXT:    [[TMP14:%.*]] = extractelement <8 x i32> [[TMP3]], i32 3
; GATHER-NEXT:    [[TMP15:%.*]] = extractelement <8 x i32> [[TMP3]], i32 4
; GATHER-NEXT:    [[TMP16:%.*]] = extractelement <8 x i32> [[TMP3]], i32 5
; GATHER-NEXT:    [[TMP17:%.*]] = extractelement <8 x i32> [[TMP3]], i32 6
; GATHER-NEXT:    [[TMP18:%.*]] = call i32 @llvm.vector.reduce.add.v8i32(<8 x i32> [[TMP3]])
; GATHER-NEXT:    [[OP_EXTRA]] = add i32 [[TMP18]], [[P17]]
; GATHER-NEXT:    [[TMP19:%.*]] = extractelement <8 x i32> [[TMP3]], i32 7
; GATHER-NEXT:    br label [[FOR_BODY]]
;
; MAX-COST-LABEL: @PR28330(
; MAX-COST-NEXT:  entry:
; MAX-COST-NEXT:    [[P0:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 1), align 1
; MAX-COST-NEXT:    [[P1:%.*]] = icmp eq i8 [[P0]], 0
; MAX-COST-NEXT:    [[P2:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 2), align 2
; MAX-COST-NEXT:    [[P3:%.*]] = icmp eq i8 [[P2]], 0
; MAX-COST-NEXT:    [[P4:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 3), align 1
; MAX-COST-NEXT:    [[P5:%.*]] = icmp eq i8 [[P4]], 0
; MAX-COST-NEXT:    [[P6:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 4), align 4
; MAX-COST-NEXT:    [[P7:%.*]] = icmp eq i8 [[P6]], 0
; MAX-COST-NEXT:    [[P8:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 5), align 1
; MAX-COST-NEXT:    [[P9:%.*]] = icmp eq i8 [[P8]], 0
; MAX-COST-NEXT:    [[P10:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 6), align 2
; MAX-COST-NEXT:    [[P11:%.*]] = icmp eq i8 [[P10]], 0
; MAX-COST-NEXT:    [[P12:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 7), align 1
; MAX-COST-NEXT:    [[P13:%.*]] = icmp eq i8 [[P12]], 0
; MAX-COST-NEXT:    [[P14:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 8), align 8
; MAX-COST-NEXT:    [[P15:%.*]] = icmp eq i8 [[P14]], 0
; MAX-COST-NEXT:    br label [[FOR_BODY:%.*]]
; MAX-COST:       for.body:
; MAX-COST-NEXT:    [[P17:%.*]] = phi i32 [ [[P34:%.*]], [[FOR_BODY]] ], [ 0, [[ENTRY:%.*]] ]
; MAX-COST-NEXT:    [[P19:%.*]] = select i1 [[P1]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[P20:%.*]] = add i32 [[P17]], [[P19]]
; MAX-COST-NEXT:    [[P21:%.*]] = select i1 [[P3]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[P22:%.*]] = add i32 [[P20]], [[P21]]
; MAX-COST-NEXT:    [[P23:%.*]] = select i1 [[P5]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[P24:%.*]] = add i32 [[P22]], [[P23]]
; MAX-COST-NEXT:    [[P25:%.*]] = select i1 [[P7]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[P26:%.*]] = add i32 [[P24]], [[P25]]
; MAX-COST-NEXT:    [[P27:%.*]] = select i1 [[P9]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[P28:%.*]] = add i32 [[P26]], [[P27]]
; MAX-COST-NEXT:    [[P29:%.*]] = select i1 [[P11]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[P30:%.*]] = add i32 [[P28]], [[P29]]
; MAX-COST-NEXT:    [[P31:%.*]] = select i1 [[P13]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[P32:%.*]] = add i32 [[P30]], [[P31]]
; MAX-COST-NEXT:    [[P33:%.*]] = select i1 [[P15]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[P34]] = add i32 [[P32]], [[P33]]
; MAX-COST-NEXT:    br label [[FOR_BODY]]
;
entry:
  %p0 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 1), align 1
  %p1 = icmp eq i8 %p0, 0
  %p2 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 2), align 2
  %p3 = icmp eq i8 %p2, 0
  %p4 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 3), align 1
  %p5 = icmp eq i8 %p4, 0
  %p6 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 4), align 4
  %p7 = icmp eq i8 %p6, 0
  %p8 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 5), align 1
  %p9 = icmp eq i8 %p8, 0
  %p10 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 6), align 2
  %p11 = icmp eq i8 %p10, 0
  %p12 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 7), align 1
  %p13 = icmp eq i8 %p12, 0
  %p14 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 8), align 8
  %p15 = icmp eq i8 %p14, 0
  br label %for.body

for.body:
  %p17 = phi i32 [ %p34, %for.body ], [ 0, %entry ]
  %p19 = select i1 %p1, i32 -720, i32 -80
  %p20 = add i32 %p17, %p19
  %p21 = select i1 %p3, i32 -720, i32 -80
  %p22 = add i32 %p20, %p21
  %p23 = select i1 %p5, i32 -720, i32 -80
  %p24 = add i32 %p22, %p23
  %p25 = select i1 %p7, i32 -720, i32 -80
  %p26 = add i32 %p24, %p25
  %p27 = select i1 %p9, i32 -720, i32 -80
  %p28 = add i32 %p26, %p27
  %p29 = select i1 %p11, i32 -720, i32 -80
  %p30 = add i32 %p28, %p29
  %p31 = select i1 %p13, i32 -720, i32 -80
  %p32 = add i32 %p30, %p31
  %p33 = select i1 %p15, i32 -720, i32 -80
  %p34 = add i32 %p32, %p33
  br label %for.body
}

define void @PR32038(i32 %n) {
; DEFAULT-LABEL: @PR32038(
; DEFAULT-NEXT:  entry:
; DEFAULT-NEXT:    [[TMP0:%.*]] = load <8 x i8>, <8 x i8>* bitcast (i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 1) to <8 x i8>*), align 1
; DEFAULT-NEXT:    [[TMP1:%.*]] = icmp eq <8 x i8> [[TMP0]], zeroinitializer
; DEFAULT-NEXT:    br label [[FOR_BODY:%.*]]
; DEFAULT:       for.body:
; DEFAULT-NEXT:    [[P17:%.*]] = phi i32 [ [[OP_EXTRA:%.*]], [[FOR_BODY]] ], [ 0, [[ENTRY:%.*]] ]
; DEFAULT-NEXT:    [[TMP2:%.*]] = select <8 x i1> [[TMP1]], <8 x i32> <i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720>, <8 x i32> <i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80>
; DEFAULT-NEXT:    [[TMP3:%.*]] = call i32 @llvm.vector.reduce.add.v8i32(<8 x i32> [[TMP2]])
; DEFAULT-NEXT:    [[OP_EXTRA]] = add i32 [[TMP3]], -5
; DEFAULT-NEXT:    br label [[FOR_BODY]]
;
; GATHER-LABEL: @PR32038(
; GATHER-NEXT:  entry:
; GATHER-NEXT:    [[TMP0:%.*]] = load <8 x i8>, <8 x i8>* bitcast (i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 1) to <8 x i8>*), align 1
; GATHER-NEXT:    [[TMP1:%.*]] = icmp eq <8 x i8> [[TMP0]], zeroinitializer
; GATHER-NEXT:    br label [[FOR_BODY:%.*]]
; GATHER:       for.body:
; GATHER-NEXT:    [[P17:%.*]] = phi i32 [ [[OP_EXTRA:%.*]], [[FOR_BODY]] ], [ 0, [[ENTRY:%.*]] ]
; GATHER-NEXT:    [[TMP2:%.*]] = extractelement <8 x i1> [[TMP1]], i32 7
; GATHER-NEXT:    [[TMP3:%.*]] = select <8 x i1> [[TMP1]], <8 x i32> <i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720, i32 -720>, <8 x i32> <i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80, i32 -80>
; GATHER-NEXT:    [[TMP4:%.*]] = extractelement <8 x i1> [[TMP1]], i32 6
; GATHER-NEXT:    [[TMP5:%.*]] = extractelement <8 x i1> [[TMP1]], i32 5
; GATHER-NEXT:    [[TMP6:%.*]] = extractelement <8 x i1> [[TMP1]], i32 4
; GATHER-NEXT:    [[TMP7:%.*]] = extractelement <8 x i1> [[TMP1]], i32 3
; GATHER-NEXT:    [[TMP8:%.*]] = extractelement <8 x i1> [[TMP1]], i32 2
; GATHER-NEXT:    [[TMP9:%.*]] = extractelement <8 x i1> [[TMP1]], i32 1
; GATHER-NEXT:    [[TMP10:%.*]] = extractelement <8 x i1> [[TMP1]], i32 0
; GATHER-NEXT:    [[TMP11:%.*]] = extractelement <8 x i32> [[TMP3]], i32 0
; GATHER-NEXT:    [[TMP12:%.*]] = extractelement <8 x i32> [[TMP3]], i32 1
; GATHER-NEXT:    [[TMP13:%.*]] = extractelement <8 x i32> [[TMP3]], i32 2
; GATHER-NEXT:    [[TMP14:%.*]] = extractelement <8 x i32> [[TMP3]], i32 3
; GATHER-NEXT:    [[TMP15:%.*]] = extractelement <8 x i32> [[TMP3]], i32 4
; GATHER-NEXT:    [[TMP16:%.*]] = extractelement <8 x i32> [[TMP3]], i32 5
; GATHER-NEXT:    [[TMP17:%.*]] = extractelement <8 x i32> [[TMP3]], i32 6
; GATHER-NEXT:    [[TMP18:%.*]] = call i32 @llvm.vector.reduce.add.v8i32(<8 x i32> [[TMP3]])
; GATHER-NEXT:    [[OP_EXTRA]] = add i32 [[TMP18]], -5
; GATHER-NEXT:    [[TMP19:%.*]] = extractelement <8 x i32> [[TMP3]], i32 7
; GATHER-NEXT:    br label [[FOR_BODY]]
;
; MAX-COST-LABEL: @PR32038(
; MAX-COST-NEXT:  entry:
; MAX-COST-NEXT:    [[TMP0:%.*]] = load <2 x i8>, <2 x i8>* bitcast (i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 1) to <2 x i8>*), align 1
; MAX-COST-NEXT:    [[TMP1:%.*]] = icmp eq <2 x i8> [[TMP0]], zeroinitializer
; MAX-COST-NEXT:    [[TMP2:%.*]] = load <2 x i8>, <2 x i8>* bitcast (i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 3) to <2 x i8>*), align 1
; MAX-COST-NEXT:    [[TMP3:%.*]] = icmp eq <2 x i8> [[TMP2]], zeroinitializer
; MAX-COST-NEXT:    [[P8:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 5), align 1
; MAX-COST-NEXT:    [[P9:%.*]] = icmp eq i8 [[P8]], 0
; MAX-COST-NEXT:    [[P10:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 6), align 2
; MAX-COST-NEXT:    [[P11:%.*]] = icmp eq i8 [[P10]], 0
; MAX-COST-NEXT:    [[P12:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 7), align 1
; MAX-COST-NEXT:    [[P13:%.*]] = icmp eq i8 [[P12]], 0
; MAX-COST-NEXT:    [[P14:%.*]] = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 8), align 8
; MAX-COST-NEXT:    [[P15:%.*]] = icmp eq i8 [[P14]], 0
; MAX-COST-NEXT:    br label [[FOR_BODY:%.*]]
; MAX-COST:       for.body:
; MAX-COST-NEXT:    [[P17:%.*]] = phi i32 [ [[P34:%.*]], [[FOR_BODY]] ], [ 0, [[ENTRY:%.*]] ]
; MAX-COST-NEXT:    [[TMP4:%.*]] = extractelement <2 x i1> [[TMP3]], i32 1
; MAX-COST-NEXT:    [[TMP5:%.*]] = shufflevector <2 x i1> [[TMP1]], <2 x i1> poison, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
; MAX-COST-NEXT:    [[TMP6:%.*]] = shufflevector <4 x i1> poison, <4 x i1> [[TMP5]], <4 x i32> <i32 4, i32 5, i32 2, i32 3>
; MAX-COST-NEXT:    [[TMP7:%.*]] = shufflevector <2 x i1> [[TMP3]], <2 x i1> poison, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
; MAX-COST-NEXT:    [[TMP8:%.*]] = shufflevector <4 x i1> [[TMP6]], <4 x i1> [[TMP7]], <4 x i32> <i32 0, i32 1, i32 4, i32 5>
; MAX-COST-NEXT:    [[TMP9:%.*]] = select <4 x i1> [[TMP8]], <4 x i32> <i32 -720, i32 -720, i32 -720, i32 -720>, <4 x i32> <i32 -80, i32 -80, i32 -80, i32 -80>
; MAX-COST-NEXT:    [[TMP10:%.*]] = extractelement <2 x i1> [[TMP3]], i32 0
; MAX-COST-NEXT:    [[TMP11:%.*]] = extractelement <2 x i1> [[TMP1]], i32 1
; MAX-COST-NEXT:    [[TMP12:%.*]] = extractelement <2 x i1> [[TMP1]], i32 0
; MAX-COST-NEXT:    [[P27:%.*]] = select i1 [[P9]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[P29:%.*]] = select i1 [[P11]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[TMP13:%.*]] = call i32 @llvm.vector.reduce.add.v4i32(<4 x i32> [[TMP9]])
; MAX-COST-NEXT:    [[TMP14:%.*]] = add i32 [[TMP13]], [[P27]]
; MAX-COST-NEXT:    [[TMP15:%.*]] = add i32 [[TMP14]], [[P29]]
; MAX-COST-NEXT:    [[OP_EXTRA:%.*]] = add i32 [[TMP15]], -5
; MAX-COST-NEXT:    [[P31:%.*]] = select i1 [[P13]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[P32:%.*]] = add i32 [[OP_EXTRA]], [[P31]]
; MAX-COST-NEXT:    [[P33:%.*]] = select i1 [[P15]], i32 -720, i32 -80
; MAX-COST-NEXT:    [[P34]] = add i32 [[P32]], [[P33]]
; MAX-COST-NEXT:    br label [[FOR_BODY]]
;
entry:
  %p0 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 1), align 1
  %p1 = icmp eq i8 %p0, 0
  %p2 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 2), align 2
  %p3 = icmp eq i8 %p2, 0
  %p4 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 3), align 1
  %p5 = icmp eq i8 %p4, 0
  %p6 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 4), align 4
  %p7 = icmp eq i8 %p6, 0
  %p8 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 5), align 1
  %p9 = icmp eq i8 %p8, 0
  %p10 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 6), align 2
  %p11 = icmp eq i8 %p10, 0
  %p12 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 7), align 1
  %p13 = icmp eq i8 %p12, 0
  %p14 = load i8, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @a, i64 0, i64 8), align 8
  %p15 = icmp eq i8 %p14, 0
  br label %for.body

for.body:
  %p17 = phi i32 [ %p34, %for.body ], [ 0, %entry ]
  %p19 = select i1 %p1, i32 -720, i32 -80
  %p20 = add i32 -5, %p19
  %p21 = select i1 %p3, i32 -720, i32 -80
  %p22 = add i32 %p20, %p21
  %p23 = select i1 %p5, i32 -720, i32 -80
  %p24 = add i32 %p22, %p23
  %p25 = select i1 %p7, i32 -720, i32 -80
  %p26 = add i32 %p24, %p25
  %p27 = select i1 %p9, i32 -720, i32 -80
  %p28 = add i32 %p26, %p27
  %p29 = select i1 %p11, i32 -720, i32 -80
  %p30 = add i32 %p28, %p29
  %p31 = select i1 %p13, i32 -720, i32 -80
  %p32 = add i32 %p30, %p31
  %p33 = select i1 %p15, i32 -720, i32 -80
  %p34 = add i32 %p32, %p33
  br label %for.body
}
