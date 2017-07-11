
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output < %s 2>&1 | FileCheck %s

; CHECK: 2 regions require runtime support:

; ModuleID = 'common/deblock.c.deblock_strength_c_for.body.6.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @deblock_strength_c_for.body.6.pjit.scop(i1 %tobool62, i8* %nnz, i64, [40 x i8]* %ref, [40 x [2 x i16]]* %mv, [8 x [4 x i8]]* %bs, i64 %indvars.iv, i64, i32 %cond2, i32 %mvy_limit, i64, i64)  {
newFuncRoot:
  br label %for.body.6

for.cond.cleanup.5.exitStub:                      ; preds = %for.cond.cleanup.9
  ret void

for.body.6:                                       ; preds = %for.cond.cleanup.9, %newFuncRoot
  %indvars.iv201 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next202, %for.cond.cleanup.9 ]
  %indvars.iv193 = phi i32 [ 12, %newFuncRoot ], [ %indvars.iv.next194, %for.cond.cleanup.9 ]
  %4 = sext i32 %indvars.iv193 to i64
  br i1 %tobool62, label %for.body.10.us.preheader, label %for.body.10.preheader

for.body.10.us.preheader:                         ; preds = %for.body.6
  br label %for.body.10.us

for.body.10.us:                                   ; preds = %if.end.117.us, %for.body.10.us.preheader
  %indvars.iv198 = phi i64 [ %indvars.iv.next199, %if.end.117.us ], [ 0, %for.body.10.us.preheader ]
  %indvars.iv195 = phi i64 [ %indvars.iv.next196, %if.end.117.us ], [ %4, %for.body.10.us.preheader ]
  %arrayidx.us = getelementptr inbounds i8, i8* %nnz, i64 %indvars.iv195
  %5 = load i8, i8* %arrayidx.us, align 1, !tbaa !0
  %tobool11.us = icmp eq i8 %5, 0
  br i1 %tobool11.us, label %lor.lhs.false.us, label %if.then.us

lor.lhs.false.us:                                 ; preds = %for.body.10.us
  %6 = sub nsw i64 %indvars.iv195, %0
  %arrayidx13.us = getelementptr inbounds i8, i8* %nnz, i64 %6
  %7 = load i8, i8* %arrayidx13.us, align 1, !tbaa !0
  %tobool15.us = icmp eq i8 %7, 0
  br i1 %tobool15.us, label %if.else.us, label %if.then.us

if.else.us:                                       ; preds = %lor.lhs.false.us
  %arrayidx24.us = getelementptr inbounds [40 x i8], [40 x i8]* %ref, i64 0, i64 %indvars.iv195
  %8 = load i8, i8* %arrayidx24.us, align 1, !tbaa !0
  %arrayidx28.us = getelementptr inbounds [40 x i8], [40 x i8]* %ref, i64 0, i64 %6
  %9 = load i8, i8* %arrayidx28.us, align 1, !tbaa !0
  %cmp30.us = icmp eq i8 %8, %9
  br i1 %cmp30.us, label %lor.lhs.false.32.us, label %if.then.103.us

lor.lhs.false.32.us:                              ; preds = %if.else.us
  %arrayidx36.us = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 0, i64 %indvars.iv195, i64 0
  %10 = load i16, i16* %arrayidx36.us, align 2, !tbaa !3
  %conv37.us = sext i16 %10 to i32
  %arrayidx41.us = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 0, i64 %6, i64 0
  %11 = load i16, i16* %arrayidx41.us, align 2, !tbaa !3
  %conv42.us = sext i16 %11 to i32
  %sub43.us = sub nsw i32 %conv37.us, %conv42.us
  %ispos.us = icmp sgt i32 %sub43.us, -1
  %neg.us = sub nsw i32 0, %sub43.us
  %12 = select i1 %ispos.us, i32 %sub43.us, i32 %neg.us
  %cmp44.us = icmp sgt i32 %12, 3
  br i1 %cmp44.us, label %if.then.103.us, label %lor.lhs.false.46.us

if.then.103.us:                                   ; preds = %lor.lhs.false.46.us, %lor.lhs.false.32.us, %if.else.us
  %arrayidx109.us = getelementptr inbounds [8 x [4 x i8]], [8 x [4 x i8]]* %bs, i64 %indvars.iv, i64 %indvars.iv201, i64 %indvars.iv198
  store i8 1, i8* %arrayidx109.us, align 1, !tbaa !0
  br label %if.end.117.us

if.end.117.us:                                    ; preds = %if.then.us, %if.else.110.us, %if.then.103.us
  %indvars.iv.next199 = add nuw nsw i64 %indvars.iv198, 1
  %indvars.iv.next196 = add i64 %indvars.iv195, %1
  %exitcond200 = icmp eq i64 %indvars.iv.next199, 4
  br i1 %exitcond200, label %for.cond.cleanup.9.loopexit, label %for.body.10.us

for.cond.cleanup.9.loopexit:                      ; preds = %if.end.117.us
  br label %for.cond.cleanup.9

for.cond.cleanup.9:                               ; preds = %for.cond.cleanup.9.loopexit205, %for.cond.cleanup.9.loopexit
  %indvars.iv.next202 = add nuw nsw i64 %indvars.iv201, 1
  %indvars.iv.next194 = add i32 %indvars.iv193, %cond2
  %exitcond203 = icmp eq i64 %indvars.iv.next202, 4
  br i1 %exitcond203, label %for.cond.cleanup.5.exitStub, label %for.body.6

lor.lhs.false.46.us:                              ; preds = %lor.lhs.false.32.us
  %arrayidx50.us = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 0, i64 %indvars.iv195, i64 1
  %13 = load i16, i16* %arrayidx50.us, align 2, !tbaa !3
  %conv51.us = sext i16 %13 to i32
  %arrayidx55.us = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 0, i64 %6, i64 1
  %14 = load i16, i16* %arrayidx55.us, align 2, !tbaa !3
  %conv56.us = sext i16 %14 to i32
  %sub57.us = sub nsw i32 %conv51.us, %conv56.us
  %ispos176.us = icmp sgt i32 %sub57.us, -1
  %neg177.us = sub nsw i32 0, %sub57.us
  %15 = select i1 %ispos176.us, i32 %sub57.us, i32 %neg177.us
  %cmp59.us = icmp slt i32 %15, %mvy_limit
  br i1 %cmp59.us, label %if.else.110.us, label %if.then.103.us

if.else.110.us:                                   ; preds = %lor.lhs.false.46.us
  %arrayidx116.us = getelementptr inbounds [8 x [4 x i8]], [8 x [4 x i8]]* %bs, i64 %indvars.iv, i64 %indvars.iv201, i64 %indvars.iv198
  store i8 0, i8* %arrayidx116.us, align 1, !tbaa !0
  br label %if.end.117.us

if.then.us:                                       ; preds = %lor.lhs.false.us, %for.body.10.us
  %arrayidx21.us = getelementptr inbounds [8 x [4 x i8]], [8 x [4 x i8]]* %bs, i64 %indvars.iv, i64 %indvars.iv201, i64 %indvars.iv198
  store i8 2, i8* %arrayidx21.us, align 1, !tbaa !0
  br label %if.end.117.us

for.body.10.preheader:                            ; preds = %for.body.6
  br label %for.body.10

for.body.10:                                      ; preds = %if.end.117, %for.body.10.preheader
  %indvars.iv191 = phi i64 [ %indvars.iv.next192, %if.end.117 ], [ 0, %for.body.10.preheader ]
  %indvars.iv188 = phi i64 [ %indvars.iv.next189, %if.end.117 ], [ %4, %for.body.10.preheader ]
  %arrayidx = getelementptr inbounds i8, i8* %nnz, i64 %indvars.iv188
  %16 = load i8, i8* %arrayidx, align 1, !tbaa !0
  %tobool11 = icmp eq i8 %16, 0
  br i1 %tobool11, label %lor.lhs.false, label %if.then

lor.lhs.false:                                    ; preds = %for.body.10
  %17 = sub nsw i64 %indvars.iv188, %2
  %arrayidx13 = getelementptr inbounds i8, i8* %nnz, i64 %17
  %18 = load i8, i8* %arrayidx13, align 1, !tbaa !0
  %tobool15 = icmp eq i8 %18, 0
  br i1 %tobool15, label %if.else, label %if.then

if.else:                                          ; preds = %lor.lhs.false
  %arrayidx24 = getelementptr inbounds [40 x i8], [40 x i8]* %ref, i64 0, i64 %indvars.iv188
  %19 = load i8, i8* %arrayidx24, align 1, !tbaa !0
  %arrayidx28 = getelementptr inbounds [40 x i8], [40 x i8]* %ref, i64 0, i64 %17
  %20 = load i8, i8* %arrayidx28, align 1, !tbaa !0
  %cmp30 = icmp eq i8 %19, %20
  br i1 %cmp30, label %lor.lhs.false.32, label %if.then.103

lor.lhs.false.32:                                 ; preds = %if.else
  %arrayidx36 = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 0, i64 %indvars.iv188, i64 0
  %21 = load i16, i16* %arrayidx36, align 2, !tbaa !3
  %conv37 = sext i16 %21 to i32
  %arrayidx41 = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 0, i64 %17, i64 0
  %22 = load i16, i16* %arrayidx41, align 2, !tbaa !3
  %conv42 = sext i16 %22 to i32
  %sub43 = sub nsw i32 %conv37, %conv42
  %ispos = icmp sgt i32 %sub43, -1
  %neg = sub nsw i32 0, %sub43
  %23 = select i1 %ispos, i32 %sub43, i32 %neg
  %cmp44 = icmp sgt i32 %23, 3
  br i1 %cmp44, label %if.then.103, label %lor.lhs.false.46

if.then.103:                                      ; preds = %lor.lhs.false.88, %lor.lhs.false.73, %land.lhs.true, %lor.lhs.false.46, %lor.lhs.false.32, %if.else
  %arrayidx109 = getelementptr inbounds [8 x [4 x i8]], [8 x [4 x i8]]* %bs, i64 %indvars.iv, i64 %indvars.iv201, i64 %indvars.iv191
  store i8 1, i8* %arrayidx109, align 1, !tbaa !0
  br label %if.end.117

if.end.117:                                       ; preds = %if.then, %if.else.110, %if.then.103
  %indvars.iv.next192 = add nuw nsw i64 %indvars.iv191, 1
  %indvars.iv.next189 = add i64 %indvars.iv188, %3
  %exitcond = icmp eq i64 %indvars.iv.next192, 4
  br i1 %exitcond, label %for.cond.cleanup.9.loopexit205, label %for.body.10

for.cond.cleanup.9.loopexit205:                   ; preds = %if.end.117
  br label %for.cond.cleanup.9

lor.lhs.false.46:                                 ; preds = %lor.lhs.false.32
  %arrayidx50 = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 0, i64 %indvars.iv188, i64 1
  %24 = load i16, i16* %arrayidx50, align 2, !tbaa !3
  %conv51 = sext i16 %24 to i32
  %arrayidx55 = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 0, i64 %17, i64 1
  %25 = load i16, i16* %arrayidx55, align 2, !tbaa !3
  %conv56 = sext i16 %25 to i32
  %sub57 = sub nsw i32 %conv51, %conv56
  %ispos176 = icmp sgt i32 %sub57, -1
  %neg177 = sub nsw i32 0, %sub57
  %26 = select i1 %ispos176, i32 %sub57, i32 %neg177
  %cmp59 = icmp slt i32 %26, %mvy_limit
  br i1 %cmp59, label %land.lhs.true, label %if.then.103

land.lhs.true:                                    ; preds = %lor.lhs.false.46
  %arrayidx65 = getelementptr inbounds [40 x i8], [40 x i8]* %ref, i64 1, i64 %indvars.iv188
  %27 = load i8, i8* %arrayidx65, align 1, !tbaa !0
  %arrayidx69 = getelementptr inbounds [40 x i8], [40 x i8]* %ref, i64 1, i64 %17
  %28 = load i8, i8* %arrayidx69, align 1, !tbaa !0
  %cmp71 = icmp eq i8 %27, %28
  br i1 %cmp71, label %lor.lhs.false.73, label %if.then.103

lor.lhs.false.73:                                 ; preds = %land.lhs.true
  %arrayidx77 = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 1, i64 %indvars.iv188, i64 0
  %29 = load i16, i16* %arrayidx77, align 2, !tbaa !3
  %conv78 = sext i16 %29 to i32
  %arrayidx82 = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 1, i64 %17, i64 0
  %30 = load i16, i16* %arrayidx82, align 2, !tbaa !3
  %conv83 = sext i16 %30 to i32
  %sub84 = sub nsw i32 %conv78, %conv83
  %ispos178 = icmp sgt i32 %sub84, -1
  %neg179 = sub nsw i32 0, %sub84
  %31 = select i1 %ispos178, i32 %sub84, i32 %neg179
  %cmp86 = icmp sgt i32 %31, 3
  br i1 %cmp86, label %if.then.103, label %lor.lhs.false.88

lor.lhs.false.88:                                 ; preds = %lor.lhs.false.73
  %arrayidx92 = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 1, i64 %indvars.iv188, i64 1
  %32 = load i16, i16* %arrayidx92, align 2, !tbaa !3
  %conv93 = sext i16 %32 to i32
  %arrayidx97 = getelementptr inbounds [40 x [2 x i16]], [40 x [2 x i16]]* %mv, i64 1, i64 %17, i64 1
  %33 = load i16, i16* %arrayidx97, align 2, !tbaa !3
  %conv98 = sext i16 %33 to i32
  %sub99 = sub nsw i32 %conv93, %conv98
  %ispos180 = icmp sgt i32 %sub99, -1
  %neg181 = sub nsw i32 0, %sub99
  %34 = select i1 %ispos180, i32 %sub99, i32 %neg181
  %cmp101 = icmp slt i32 %34, %mvy_limit
  br i1 %cmp101, label %if.else.110, label %if.then.103

if.else.110:                                      ; preds = %lor.lhs.false.88
  %arrayidx116 = getelementptr inbounds [8 x [4 x i8]], [8 x [4 x i8]]* %bs, i64 %indvars.iv, i64 %indvars.iv201, i64 %indvars.iv191
  store i8 0, i8* %arrayidx116, align 1, !tbaa !0
  br label %if.end.117

if.then:                                          ; preds = %lor.lhs.false, %for.body.10
  %arrayidx21 = getelementptr inbounds [8 x [4 x i8]], [8 x [4 x i8]]* %bs, i64 %indvars.iv, i64 %indvars.iv201, i64 %indvars.iv191
  store i8 2, i8* %arrayidx21, align 1, !tbaa !0
  br label %if.end.117
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
!3 = !{!4, !4, i64 0}
!4 = !{!"short", !1, i64 0}
