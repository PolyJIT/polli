; RUN: opt -load LLVMPolyJIT.so -O3  -polli-process-unprofitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 9 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/JM/ldecod/erc_do_i.c.ercPixConcealIMB_for.body.6.lr.ph.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @ercPixConcealIMB_for.body.6.lr.ph.i.pjit.scop(i64, i16* %src.sroa.13.0, i16* %src.sroa.9.0, i64 %idx.ext23.i, i64, i1 %cmp7.i, i1 %cmp15.i, i1 %cmp31.i, i1 %cmp44.i, i16* %add.ptr106, i32, i32* %cond.in.i, i16* %src.sroa.11.0, i16* %add.ptr.i, i32 %add41.us.160.i, i32 %mul107)  {
newFuncRoot:
  br label %for.body.6.lr.ph.i

pixMeanInterpolateBlock.exit.loopexit.exitStub:   ; preds = %for.end.i
  ret void

for.body.6.lr.ph.i:                               ; preds = %for.end.i, %newFuncRoot
  %indvars.iv219.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next220.i, %for.end.i ]
  %indvars.iv213.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next214.i, %for.end.i ]
  %3 = mul nsw i64 %indvars.iv213.i, %0
  %add.ptr51.i = getelementptr inbounds i16, i16* %src.sroa.13.0, i64 %3
  %4 = add nuw nsw i64 %indvars.iv213.i, 1
  %add.ptr22.i = getelementptr inbounds i16, i16* %src.sroa.9.0, i64 %3
  %add.ptr24.i = getelementptr inbounds i16, i16* %add.ptr22.i, i64 %idx.ext23.i
  %5 = sub nsw i64 %1, %indvars.iv213.i
  br i1 %cmp7.i, label %if.end.us.i.preheader, label %for.body.6.lr.ph.split.i

if.end.us.i.preheader:                            ; preds = %for.body.6.lr.ph.i
  %6 = trunc i64 %4 to i32
  br i1 %cmp15.i, label %if.end.29.us.i.us.preheader, label %if.end.us.i.preheader.split

if.end.29.us.i.us.preheader:                      ; preds = %if.end.us.i.preheader
  br label %if.end.29.us.i.us

if.end.29.us.i.us:                                ; preds = %for.inc.us.i.us, %if.end.29.us.i.us.preheader
  %indvars.iv205.i.us = phi i64 [ %indvars.iv.next206.i.us, %for.inc.us.i.us ], [ 0, %if.end.29.us.i.us.preheader ]
  br i1 %cmp31.i, label %if.end.42.us.i.us, label %if.then.33.us.i.us

if.end.42.us.i.us:                                ; preds = %if.then.33.us.i.us, %if.end.29.us.i.us
  %tmp.2.us.i.us = phi i32 [ %mul39.us.i.us, %if.then.33.us.i.us ], [ 0, %if.end.29.us.i.us ]
  %srcCounter.2.us.i.us = phi i32 [ %6, %if.then.33.us.i.us ], [ 0, %if.end.29.us.i.us ]
  br i1 %cmp44.i, label %if.end.56.us.i.us, label %if.then.46.us.i.us

if.end.56.us.i.us:                                ; preds = %if.then.46.us.i.us, %if.end.42.us.i.us
  %tmp.3.us.i.us = phi i32 [ %add54.us.i.us, %if.then.46.us.i.us ], [ %tmp.2.us.i.us, %if.end.42.us.i.us ]
  %srcCounter.3.us.i.us = phi i32 [ %add55.us.i.us, %if.then.46.us.i.us ], [ %srcCounter.2.us.i.us, %if.end.42.us.i.us ]
  %cmp57.us.i.us = icmp sgt i32 %srcCounter.3.us.i.us, 0
  br i1 %cmp57.us.i.us, label %if.then.59.us.i.us, label %if.else.us.i.us

if.then.59.us.i.us:                               ; preds = %if.end.56.us.i.us
  %div.us.i.us = sdiv i32 %tmp.3.us.i.us, %srcCounter.3.us.i.us
  %conv60.us.i.us = trunc i32 %div.us.i.us to i16
  %conv61.us.i.us = and i16 %conv60.us.i.us, 255
  %7 = add nsw i64 %indvars.iv205.i.us, %indvars.iv219.i
  %arrayidx63.us.i.us = getelementptr inbounds i16, i16* %add.ptr106, i64 %7
  store i16 %conv61.us.i.us, i16* %arrayidx63.us.i.us, align 2, !tbaa !0
  br label %for.inc.us.i.us

for.inc.us.i.us:                                  ; preds = %if.else.us.i.us, %if.then.59.us.i.us
  %indvars.iv.next206.i.us = add nuw nsw i64 %indvars.iv205.i.us, 1
  %lftr.wideiv339 = trunc i64 %indvars.iv.next206.i.us to i32
  %exitcond340 = icmp eq i32 %lftr.wideiv339, %2
  br i1 %exitcond340, label %for.end.i.loopexit, label %if.end.29.us.i.us

for.end.i.loopexit:                               ; preds = %for.inc.us.i.us
  br label %for.end.i

for.end.i:                                        ; preds = %for.end.i.loopexit324, %for.end.i.loopexit322, %for.end.i.loopexit321, %for.end.i.loopexit320, %for.end.i.loopexit318, %for.end.i.loopexit317, %for.end.i.loopexit316, %for.end.i.loopexit315, %for.end.i.loopexit
  %indvars.iv.next220.i = add i64 %indvars.iv219.i, %0
  %indvars.iv.next214.i = add nuw nsw i64 %indvars.iv213.i, 1
  %lftr.wideiv341 = trunc i64 %indvars.iv.next214.i to i32
  %exitcond342 = icmp eq i32 %lftr.wideiv341, %2
  br i1 %exitcond342, label %pixMeanInterpolateBlock.exit.loopexit.exitStub, label %for.body.6.lr.ph.i

if.else.us.i.us:                                  ; preds = %if.end.56.us.i.us
  %cond.us.i.us = load i32, i32* %cond.in.i, align 4, !tbaa !4
  %conv66.us.i.us = trunc i32 %cond.us.i.us to i16
  %8 = add nsw i64 %indvars.iv205.i.us, %indvars.iv219.i
  %arrayidx69.us.i.us = getelementptr inbounds i16, i16* %add.ptr106, i64 %8
  store i16 %conv66.us.i.us, i16* %arrayidx69.us.i.us, align 2, !tbaa !0
  br label %for.inc.us.i.us

if.then.46.us.i.us:                               ; preds = %if.end.42.us.i.us
  %9 = add nuw nsw i64 %indvars.iv205.i.us, 1
  %10 = load i16, i16* %add.ptr51.i, align 2, !tbaa !0
  %conv52.us.i.us = zext i16 %10 to i32
  %11 = trunc i64 %9 to i32
  %mul53.us.i.us = mul nsw i32 %conv52.us.i.us, %11
  %add54.us.i.us = add nsw i32 %mul53.us.i.us, %tmp.2.us.i.us
  %add55.us.i.us = add nsw i32 %srcCounter.2.us.i.us, %11
  br label %if.end.56.us.i.us

if.then.33.us.i.us:                               ; preds = %if.end.29.us.i.us
  %add.ptr37.us.i.us = getelementptr inbounds i16, i16* %src.sroa.11.0, i64 %indvars.iv205.i.us
  %12 = load i16, i16* %add.ptr37.us.i.us, align 2, !tbaa !0
  %conv38.us.i.us = zext i16 %12 to i32
  %mul39.us.i.us = mul nsw i32 %conv38.us.i.us, %6
  br label %if.end.42.us.i.us

if.end.us.i.preheader.split:                      ; preds = %if.end.us.i.preheader
  br i1 %cmp31.i, label %if.then.17.us.i.us250.preheader, label %if.then.17.us.i.preheader

if.then.17.us.i.us250.preheader:                  ; preds = %if.end.us.i.preheader.split
  br label %if.then.17.us.i.us250

if.then.17.us.i.us250:                            ; preds = %for.inc.us.i.us283, %if.then.17.us.i.us250.preheader
  %indvars.iv205.i.us.249 = phi i64 [ %indvars.iv.next206.i.us.284, %for.inc.us.i.us283 ], [ 0, %if.then.17.us.i.us250.preheader ]
  %13 = sub nsw i64 %1, %indvars.iv205.i.us.249
  %14 = load i16, i16* %add.ptr24.i, align 2, !tbaa !0
  %conv25.us.i.us.251 = zext i16 %14 to i32
  %15 = trunc i64 %13 to i32
  %mul26.us.i.us.252 = mul nsw i32 %conv25.us.i.us.251, %15
  br i1 %cmp44.i, label %if.end.56.us.i.us270, label %if.then.46.us.i.us265

if.end.56.us.i.us270:                             ; preds = %if.then.46.us.i.us265, %if.then.17.us.i.us250
  %tmp.3.us.i.us.271 = phi i32 [ %add54.us.i.us.268, %if.then.46.us.i.us265 ], [ %mul26.us.i.us.252, %if.then.17.us.i.us250 ]
  %srcCounter.3.us.i.us.272 = phi i32 [ %add55.us.i.us.269, %if.then.46.us.i.us265 ], [ %15, %if.then.17.us.i.us250 ]
  %cmp57.us.i.us.273 = icmp sgt i32 %srcCounter.3.us.i.us.272, 0
  br i1 %cmp57.us.i.us.273, label %if.then.59.us.i.us278, label %if.else.us.i.us274

if.then.59.us.i.us278:                            ; preds = %if.end.56.us.i.us270
  %div.us.i.us.279 = sdiv i32 %tmp.3.us.i.us.271, %srcCounter.3.us.i.us.272
  %conv60.us.i.us.280 = trunc i32 %div.us.i.us.279 to i16
  %conv61.us.i.us.281 = and i16 %conv60.us.i.us.280, 255
  %16 = add nsw i64 %indvars.iv205.i.us.249, %indvars.iv219.i
  %arrayidx63.us.i.us.282 = getelementptr inbounds i16, i16* %add.ptr106, i64 %16
  store i16 %conv61.us.i.us.281, i16* %arrayidx63.us.i.us.282, align 2, !tbaa !0
  br label %for.inc.us.i.us283

for.inc.us.i.us283:                               ; preds = %if.else.us.i.us274, %if.then.59.us.i.us278
  %indvars.iv.next206.i.us.284 = add nuw nsw i64 %indvars.iv205.i.us.249, 1
  %lftr.wideiv337 = trunc i64 %indvars.iv.next206.i.us.284 to i32
  %exitcond338 = icmp eq i32 %lftr.wideiv337, %2
  br i1 %exitcond338, label %for.end.i.loopexit315, label %if.then.17.us.i.us250

for.end.i.loopexit315:                            ; preds = %for.inc.us.i.us283
  br label %for.end.i

if.else.us.i.us274:                               ; preds = %if.end.56.us.i.us270
  %cond.us.i.us.275 = load i32, i32* %cond.in.i, align 4, !tbaa !4
  %conv66.us.i.us.276 = trunc i32 %cond.us.i.us.275 to i16
  %17 = add nsw i64 %indvars.iv205.i.us.249, %indvars.iv219.i
  %arrayidx69.us.i.us.277 = getelementptr inbounds i16, i16* %add.ptr106, i64 %17
  store i16 %conv66.us.i.us.276, i16* %arrayidx69.us.i.us.277, align 2, !tbaa !0
  br label %for.inc.us.i.us283

if.then.46.us.i.us265:                            ; preds = %if.then.17.us.i.us250
  %18 = add nuw nsw i64 %indvars.iv205.i.us.249, 1
  %19 = load i16, i16* %add.ptr51.i, align 2, !tbaa !0
  %conv52.us.i.us.266 = zext i16 %19 to i32
  %20 = trunc i64 %18 to i32
  %mul53.us.i.us.267 = mul nsw i32 %conv52.us.i.us.266, %20
  %add54.us.i.us.268 = add nsw i32 %mul53.us.i.us.267, %mul26.us.i.us.252
  %add55.us.i.us.269 = add nsw i32 %15, %20
  br label %if.end.56.us.i.us270

if.then.17.us.i.preheader:                        ; preds = %if.end.us.i.preheader.split
  br label %if.then.17.us.i

if.then.17.us.i:                                  ; preds = %for.inc.us.i, %if.then.17.us.i.preheader
  %indvars.iv205.i = phi i64 [ %indvars.iv.next206.i, %for.inc.us.i ], [ 0, %if.then.17.us.i.preheader ]
  %21 = sub nsw i64 %1, %indvars.iv205.i
  %22 = load i16, i16* %add.ptr24.i, align 2, !tbaa !0
  %conv25.us.i = zext i16 %22 to i32
  %23 = trunc i64 %21 to i32
  %mul26.us.i = mul nsw i32 %conv25.us.i, %23
  %add.ptr37.us.i = getelementptr inbounds i16, i16* %src.sroa.11.0, i64 %indvars.iv205.i
  %24 = load i16, i16* %add.ptr37.us.i, align 2, !tbaa !0
  %conv38.us.i = zext i16 %24 to i32
  %mul39.us.i = mul nsw i32 %conv38.us.i, %6
  %add40.us.i = add nsw i32 %mul39.us.i, %mul26.us.i
  %add41.us.i = add nsw i32 %23, %6
  br i1 %cmp44.i, label %if.end.56.us.i, label %if.then.46.us.i

if.end.56.us.i:                                   ; preds = %if.then.46.us.i, %if.then.17.us.i
  %tmp.3.us.i = phi i32 [ %add54.us.i, %if.then.46.us.i ], [ %add40.us.i, %if.then.17.us.i ]
  %srcCounter.3.us.i = phi i32 [ %add55.us.i, %if.then.46.us.i ], [ %add41.us.i, %if.then.17.us.i ]
  %cmp57.us.i = icmp sgt i32 %srcCounter.3.us.i, 0
  br i1 %cmp57.us.i, label %if.then.59.us.i, label %if.else.us.i

if.then.59.us.i:                                  ; preds = %if.end.56.us.i
  %div.us.i = sdiv i32 %tmp.3.us.i, %srcCounter.3.us.i
  %conv60.us.i = trunc i32 %div.us.i to i16
  %conv61.us.i = and i16 %conv60.us.i, 255
  %25 = add nsw i64 %indvars.iv205.i, %indvars.iv219.i
  %arrayidx63.us.i = getelementptr inbounds i16, i16* %add.ptr106, i64 %25
  store i16 %conv61.us.i, i16* %arrayidx63.us.i, align 2, !tbaa !0
  br label %for.inc.us.i

for.inc.us.i:                                     ; preds = %if.else.us.i, %if.then.59.us.i
  %indvars.iv.next206.i = add nuw nsw i64 %indvars.iv205.i, 1
  %lftr.wideiv335 = trunc i64 %indvars.iv.next206.i to i32
  %exitcond336 = icmp eq i32 %lftr.wideiv335, %2
  br i1 %exitcond336, label %for.end.i.loopexit316, label %if.then.17.us.i

for.end.i.loopexit316:                            ; preds = %for.inc.us.i
  br label %for.end.i

if.else.us.i:                                     ; preds = %if.end.56.us.i
  %cond.us.i = load i32, i32* %cond.in.i, align 4, !tbaa !4
  %conv66.us.i = trunc i32 %cond.us.i to i16
  %26 = add nsw i64 %indvars.iv205.i, %indvars.iv219.i
  %arrayidx69.us.i = getelementptr inbounds i16, i16* %add.ptr106, i64 %26
  store i16 %conv66.us.i, i16* %arrayidx69.us.i, align 2, !tbaa !0
  br label %for.inc.us.i

if.then.46.us.i:                                  ; preds = %if.then.17.us.i
  %27 = add nuw nsw i64 %indvars.iv205.i, 1
  %28 = load i16, i16* %add.ptr51.i, align 2, !tbaa !0
  %conv52.us.i = zext i16 %28 to i32
  %29 = trunc i64 %27 to i32
  %mul53.us.i = mul nsw i32 %conv52.us.i, %29
  %add54.us.i = add nsw i32 %mul53.us.i, %add40.us.i
  %add55.us.i = add nsw i32 %add41.us.i, %29
  br label %if.end.56.us.i

for.body.6.lr.ph.split.i:                         ; preds = %for.body.6.lr.ph.i
  %30 = trunc i64 %5 to i32
  %31 = trunc i64 %4 to i32
  br i1 %cmp15.i, label %if.then.us137.i.preheader, label %if.then.i.preheader

if.then.us137.i.preheader:                        ; preds = %for.body.6.lr.ph.split.i
  br i1 %cmp31.i, label %if.then.us137.i.us.preheader, label %if.then.us137.i.preheader.split

if.then.us137.i.us.preheader:                     ; preds = %if.then.us137.i.preheader
  br label %if.then.us137.i.us

if.then.us137.i.us:                               ; preds = %for.inc.us187.i.us, %if.then.us137.i.us.preheader
  %indvars.iv198.i.us = phi i64 [ %indvars.iv.next199.i.us, %for.inc.us187.i.us ], [ 0, %if.then.us137.i.us.preheader ]
  %add.ptr11.us.139.i.us = getelementptr inbounds i16, i16* %add.ptr.i, i64 %indvars.iv198.i.us
  %32 = load i16, i16* %add.ptr11.us.139.i.us, align 2, !tbaa !0
  %conv.us.140.i.us = zext i16 %32 to i32
  %mul12.us.141.i.us = mul nsw i32 %conv.us.140.i.us, %30
  br i1 %cmp44.i, label %if.end.56.us170.i.us, label %if.then.46.us164.i.us

if.end.56.us170.i.us:                             ; preds = %if.then.46.us164.i.us, %if.then.us137.i.us
  %tmp.3.us.171.i.us = phi i32 [ %add54.us.168.i.us, %if.then.46.us164.i.us ], [ %mul12.us.141.i.us, %if.then.us137.i.us ]
  %srcCounter.3.us.172.i.us = phi i32 [ %add55.us.169.i.us, %if.then.46.us164.i.us ], [ %30, %if.then.us137.i.us ]
  %cmp57.us.173.i.us = icmp sgt i32 %srcCounter.3.us.172.i.us, 0
  br i1 %cmp57.us.173.i.us, label %if.then.59.us180.i.us, label %if.else.us174.i.us

if.then.59.us180.i.us:                            ; preds = %if.end.56.us170.i.us
  %div.us.181.i.us = sdiv i32 %tmp.3.us.171.i.us, %srcCounter.3.us.172.i.us
  %conv60.us.182.i.us = trunc i32 %div.us.181.i.us to i16
  %conv61.us.183.i.us = and i16 %conv60.us.182.i.us, 255
  %33 = add nsw i64 %indvars.iv198.i.us, %indvars.iv219.i
  %arrayidx63.us.186.i.us = getelementptr inbounds i16, i16* %add.ptr106, i64 %33
  store i16 %conv61.us.183.i.us, i16* %arrayidx63.us.186.i.us, align 2, !tbaa !0
  br label %for.inc.us187.i.us

for.inc.us187.i.us:                               ; preds = %if.else.us174.i.us, %if.then.59.us180.i.us
  %indvars.iv.next199.i.us = add nuw nsw i64 %indvars.iv198.i.us, 1
  %lftr.wideiv333 = trunc i64 %indvars.iv.next199.i.us to i32
  %exitcond334 = icmp eq i32 %lftr.wideiv333, %2
  br i1 %exitcond334, label %for.end.i.loopexit317, label %if.then.us137.i.us

for.end.i.loopexit317:                            ; preds = %for.inc.us187.i.us
  br label %for.end.i

if.else.us174.i.us:                               ; preds = %if.end.56.us170.i.us
  %cond.us.175.i.us = load i32, i32* %cond.in.i, align 4, !tbaa !4
  %conv66.us.176.i.us = trunc i32 %cond.us.175.i.us to i16
  %34 = add nsw i64 %indvars.iv198.i.us, %indvars.iv219.i
  %arrayidx69.us.179.i.us = getelementptr inbounds i16, i16* %add.ptr106, i64 %34
  store i16 %conv66.us.176.i.us, i16* %arrayidx69.us.179.i.us, align 2, !tbaa !0
  br label %for.inc.us187.i.us

if.then.46.us164.i.us:                            ; preds = %if.then.us137.i.us
  %35 = add nuw nsw i64 %indvars.iv198.i.us, 1
  %36 = load i16, i16* %add.ptr51.i, align 2, !tbaa !0
  %conv52.us.166.i.us = zext i16 %36 to i32
  %37 = trunc i64 %35 to i32
  %mul53.us.167.i.us = mul nsw i32 %conv52.us.166.i.us, %37
  %add54.us.168.i.us = add nsw i32 %mul53.us.167.i.us, %mul12.us.141.i.us
  %add55.us.169.i.us = add nsw i32 %37, %30
  br label %if.end.56.us170.i.us

if.then.us137.i.preheader.split:                  ; preds = %if.then.us137.i.preheader
  br i1 %cmp44.i, label %if.then.us137.i.us213.preheader, label %if.then.us137.i.preheader319

if.then.us137.i.us213.preheader:                  ; preds = %if.then.us137.i.preheader.split
  br label %if.then.us137.i.us213

if.then.us137.i.us213:                            ; preds = %for.inc.us187.i.us244, %if.then.us137.i.us213.preheader
  %indvars.iv198.i.us.214 = phi i64 [ %indvars.iv.next199.i.us.245, %for.inc.us187.i.us244 ], [ 0, %if.then.us137.i.us213.preheader ]
  %cmp57.us.173.i.us.234 = icmp sgt i32 %add41.us.160.i, 0
  br i1 %cmp57.us.173.i.us.234, label %if.then.59.us180.i.us239, label %if.else.us174.i.us235

if.then.59.us180.i.us239:                         ; preds = %if.then.us137.i.us213
  %add.ptr37.us.156.i.us.219 = getelementptr inbounds i16, i16* %src.sroa.11.0, i64 %indvars.iv198.i.us.214
  %38 = load i16, i16* %add.ptr37.us.156.i.us.219, align 2, !tbaa !0
  %conv38.us.157.i.us.220 = zext i16 %38 to i32
  %mul39.us.158.i.us.221 = mul nsw i32 %conv38.us.157.i.us.220, %31
  %add.ptr11.us.139.i.us.215 = getelementptr inbounds i16, i16* %add.ptr.i, i64 %indvars.iv198.i.us.214
  %39 = load i16, i16* %add.ptr11.us.139.i.us.215, align 2, !tbaa !0
  %conv.us.140.i.us.216 = zext i16 %39 to i32
  %mul12.us.141.i.us.217 = mul nsw i32 %conv.us.140.i.us.216, %30
  %add40.us.159.i.us.222 = add nsw i32 %mul12.us.141.i.us.217, %mul39.us.158.i.us.221
  %div.us.181.i.us.240 = sdiv i32 %add40.us.159.i.us.222, %add41.us.160.i
  %conv60.us.182.i.us.241 = trunc i32 %div.us.181.i.us.240 to i16
  %conv61.us.183.i.us.242 = and i16 %conv60.us.182.i.us.241, 255
  %40 = add nsw i64 %indvars.iv198.i.us.214, %indvars.iv219.i
  %arrayidx63.us.186.i.us.243 = getelementptr inbounds i16, i16* %add.ptr106, i64 %40
  store i16 %conv61.us.183.i.us.242, i16* %arrayidx63.us.186.i.us.243, align 2, !tbaa !0
  br label %for.inc.us187.i.us244

for.inc.us187.i.us244:                            ; preds = %if.else.us174.i.us235, %if.then.59.us180.i.us239
  %indvars.iv.next199.i.us.245 = add nuw nsw i64 %indvars.iv198.i.us.214, 1
  %lftr.wideiv331 = trunc i64 %indvars.iv.next199.i.us.245 to i32
  %exitcond332 = icmp eq i32 %lftr.wideiv331, %2
  br i1 %exitcond332, label %for.end.i.loopexit318, label %if.then.us137.i.us213

for.end.i.loopexit318:                            ; preds = %for.inc.us187.i.us244
  br label %for.end.i

if.else.us174.i.us235:                            ; preds = %if.then.us137.i.us213
  %cond.us.175.i.us.236 = load i32, i32* %cond.in.i, align 4, !tbaa !4
  %conv66.us.176.i.us.237 = trunc i32 %cond.us.175.i.us.236 to i16
  %41 = add nsw i64 %indvars.iv198.i.us.214, %indvars.iv219.i
  %arrayidx69.us.179.i.us.238 = getelementptr inbounds i16, i16* %add.ptr106, i64 %41
  store i16 %conv66.us.176.i.us.237, i16* %arrayidx69.us.179.i.us.238, align 2, !tbaa !0
  br label %for.inc.us187.i.us244

if.then.us137.i.preheader319:                     ; preds = %if.then.us137.i.preheader.split
  br label %if.then.us137.i

if.then.us137.i:                                  ; preds = %for.inc.us187.i, %if.then.us137.i.preheader319
  %indvars.iv198.i = phi i64 [ %indvars.iv.next199.i, %for.inc.us187.i ], [ 0, %if.then.us137.i.preheader319 ]
  %42 = add nuw nsw i64 %indvars.iv198.i, 1
  %43 = trunc i64 %42 to i32
  %add55.us.169.i = add nsw i32 %43, %add41.us.160.i
  %cmp57.us.173.i = icmp sgt i32 %add55.us.169.i, 0
  br i1 %cmp57.us.173.i, label %if.then.59.us180.i, label %if.else.us174.i

if.then.59.us180.i:                               ; preds = %if.then.us137.i
  %44 = load i16, i16* %add.ptr51.i, align 2, !tbaa !0
  %conv52.us.166.i = zext i16 %44 to i32
  %mul53.us.167.i = mul nsw i32 %conv52.us.166.i, %43
  %add.ptr37.us.156.i = getelementptr inbounds i16, i16* %src.sroa.11.0, i64 %indvars.iv198.i
  %45 = load i16, i16* %add.ptr37.us.156.i, align 2, !tbaa !0
  %conv38.us.157.i = zext i16 %45 to i32
  %mul39.us.158.i = mul nsw i32 %conv38.us.157.i, %31
  %add.ptr11.us.139.i = getelementptr inbounds i16, i16* %add.ptr.i, i64 %indvars.iv198.i
  %46 = load i16, i16* %add.ptr11.us.139.i, align 2, !tbaa !0
  %conv.us.140.i = zext i16 %46 to i32
  %mul12.us.141.i = mul nsw i32 %conv.us.140.i, %30
  %add40.us.159.i = add i32 %mul39.us.158.i, %mul53.us.167.i
  %add54.us.168.i = add i32 %add40.us.159.i, %mul12.us.141.i
  %div.us.181.i = sdiv i32 %add54.us.168.i, %add55.us.169.i
  %conv60.us.182.i = trunc i32 %div.us.181.i to i16
  %conv61.us.183.i = and i16 %conv60.us.182.i, 255
  %47 = add nsw i64 %indvars.iv198.i, %indvars.iv219.i
  %arrayidx63.us.186.i = getelementptr inbounds i16, i16* %add.ptr106, i64 %47
  store i16 %conv61.us.183.i, i16* %arrayidx63.us.186.i, align 2, !tbaa !0
  br label %for.inc.us187.i

for.inc.us187.i:                                  ; preds = %if.else.us174.i, %if.then.59.us180.i
  %indvars.iv.next199.i = add nuw nsw i64 %indvars.iv198.i, 1
  %lftr.wideiv329 = trunc i64 %indvars.iv.next199.i to i32
  %exitcond330 = icmp eq i32 %lftr.wideiv329, %2
  br i1 %exitcond330, label %for.end.i.loopexit320, label %if.then.us137.i

for.end.i.loopexit320:                            ; preds = %for.inc.us187.i
  br label %for.end.i

if.else.us174.i:                                  ; preds = %if.then.us137.i
  %cond.us.175.i = load i32, i32* %cond.in.i, align 4, !tbaa !4
  %conv66.us.176.i = trunc i32 %cond.us.175.i to i16
  %48 = add nsw i64 %indvars.iv198.i, %indvars.iv219.i
  %arrayidx69.us.179.i = getelementptr inbounds i16, i16* %add.ptr106, i64 %48
  store i16 %conv66.us.176.i, i16* %arrayidx69.us.179.i, align 2, !tbaa !0
  br label %for.inc.us187.i

if.then.i.preheader:                              ; preds = %for.body.6.lr.ph.split.i
  %sub18.i = add i32 %30, %mul107
  %add28.i = add i32 %sub18.i, %31
  br i1 %cmp31.i, label %if.then.i.us.preheader, label %if.then.i.preheader.split

if.then.i.us.preheader:                           ; preds = %if.then.i.preheader
  br label %if.then.i.us

if.then.i.us:                                     ; preds = %for.inc.i.us, %if.then.i.us.preheader
  %indvars.iv.i.us = phi i64 [ %indvars.iv.next.i.us, %for.inc.i.us ], [ 0, %if.then.i.us.preheader ]
  %add.ptr11.i.us = getelementptr inbounds i16, i16* %add.ptr.i, i64 %indvars.iv.i.us
  %49 = load i16, i16* %add.ptr11.i.us, align 2, !tbaa !0
  %conv.i.us = zext i16 %49 to i32
  %mul12.i.us = mul nsw i32 %conv.i.us, %30
  %50 = sub nsw i64 %1, %indvars.iv.i.us
  %51 = load i16, i16* %add.ptr24.i, align 2, !tbaa !0
  %conv25.i.us = zext i16 %51 to i32
  %52 = trunc i64 %50 to i32
  %mul26.i.us = mul nsw i32 %conv25.i.us, %52
  %add27.i.us = add nsw i32 %mul26.i.us, %mul12.i.us
  %53 = add nsw i64 %50, %5
  %54 = trunc i64 %53 to i32
  br i1 %cmp44.i, label %if.end.56.i.us, label %if.then.46.i.us

if.end.56.i.us:                                   ; preds = %if.then.46.i.us, %if.then.i.us
  %tmp.3.i.us = phi i32 [ %add54.i.us, %if.then.46.i.us ], [ %add27.i.us, %if.then.i.us ]
  %srcCounter.3.i.us = phi i32 [ %add55.i.us, %if.then.46.i.us ], [ %54, %if.then.i.us ]
  %cmp57.i.us = icmp sgt i32 %srcCounter.3.i.us, 0
  br i1 %cmp57.i.us, label %if.then.59.i.us, label %if.else.i.us

if.then.59.i.us:                                  ; preds = %if.end.56.i.us
  %div.i.us = sdiv i32 %tmp.3.i.us, %srcCounter.3.i.us
  %conv60.i.us = trunc i32 %div.i.us to i16
  %conv61.i.us = and i16 %conv60.i.us, 255
  %55 = add nsw i64 %indvars.iv.i.us, %indvars.iv219.i
  %arrayidx63.i.us = getelementptr inbounds i16, i16* %add.ptr106, i64 %55
  store i16 %conv61.i.us, i16* %arrayidx63.i.us, align 2, !tbaa !0
  br label %for.inc.i.us

for.inc.i.us:                                     ; preds = %if.else.i.us, %if.then.59.i.us
  %indvars.iv.next.i.us = add nuw nsw i64 %indvars.iv.i.us, 1
  %lftr.wideiv327 = trunc i64 %indvars.iv.next.i.us to i32
  %exitcond328 = icmp eq i32 %lftr.wideiv327, %2
  br i1 %exitcond328, label %for.end.i.loopexit321, label %if.then.i.us

for.end.i.loopexit321:                            ; preds = %for.inc.i.us
  br label %for.end.i

if.else.i.us:                                     ; preds = %if.end.56.i.us
  %cond.i.us = load i32, i32* %cond.in.i, align 4, !tbaa !4
  %conv66.i.us = trunc i32 %cond.i.us to i16
  %56 = add nsw i64 %indvars.iv.i.us, %indvars.iv219.i
  %arrayidx69.i.us = getelementptr inbounds i16, i16* %add.ptr106, i64 %56
  store i16 %conv66.i.us, i16* %arrayidx69.i.us, align 2, !tbaa !0
  br label %for.inc.i.us

if.then.46.i.us:                                  ; preds = %if.then.i.us
  %57 = add nuw nsw i64 %indvars.iv.i.us, 1
  %58 = load i16, i16* %add.ptr51.i, align 2, !tbaa !0
  %conv52.i.us = zext i16 %58 to i32
  %59 = trunc i64 %57 to i32
  %mul53.i.us = mul nsw i32 %conv52.i.us, %59
  %add54.i.us = add nsw i32 %mul53.i.us, %add27.i.us
  %add55.i.us = add nsw i32 %54, %59
  br label %if.end.56.i.us

if.then.i.preheader.split:                        ; preds = %if.then.i.preheader
  br i1 %cmp44.i, label %if.then.i.us171.preheader, label %if.then.i.preheader323

if.then.i.us171.preheader:                        ; preds = %if.then.i.preheader.split
  br label %if.then.i.us171

if.then.i.us171:                                  ; preds = %for.inc.i.us208, %if.then.i.us171.preheader
  %indvars.iv.i.us.172 = phi i64 [ %indvars.iv.next.i.us.209, %for.inc.i.us208 ], [ 0, %if.then.i.us171.preheader ]
  %column.0130.i.us.173 = phi i32 [ %inc.i.us.210, %for.inc.i.us208 ], [ 0, %if.then.i.us171.preheader ]
  %add41.i.us.186 = sub i32 %add28.i, %column.0130.i.us.173
  %cmp57.i.us.198 = icmp sgt i32 %add41.i.us.186, 0
  br i1 %cmp57.i.us.198, label %if.then.59.i.us203, label %if.else.i.us199

if.then.59.i.us203:                               ; preds = %if.then.i.us171
  %add.ptr37.i.us.181 = getelementptr inbounds i16, i16* %src.sroa.11.0, i64 %indvars.iv.i.us.172
  %60 = load i16, i16* %add.ptr37.i.us.181, align 2, !tbaa !0
  %conv38.i.us.182 = zext i16 %60 to i32
  %mul39.i.us.183 = mul nsw i32 %conv38.i.us.182, %31
  %61 = load i16, i16* %add.ptr24.i, align 2, !tbaa !0
  %conv25.i.us.177 = zext i16 %61 to i32
  %62 = sub nsw i64 %1, %indvars.iv.i.us.172
  %63 = trunc i64 %62 to i32
  %mul26.i.us.178 = mul nsw i32 %conv25.i.us.177, %63
  %add.ptr11.i.us.174 = getelementptr inbounds i16, i16* %add.ptr.i, i64 %indvars.iv.i.us.172
  %64 = load i16, i16* %add.ptr11.i.us.174, align 2, !tbaa !0
  %conv.i.us.175 = zext i16 %64 to i32
  %mul12.i.us.176 = mul nsw i32 %conv.i.us.175, %30
  %add27.i.us.179 = add i32 %mul26.i.us.178, %mul39.i.us.183
  %add40.i.us.184 = add i32 %add27.i.us.179, %mul12.i.us.176
  %div.i.us.204 = sdiv i32 %add40.i.us.184, %add41.i.us.186
  %conv60.i.us.205 = trunc i32 %div.i.us.204 to i16
  %conv61.i.us.206 = and i16 %conv60.i.us.205, 255
  %65 = add nsw i64 %indvars.iv.i.us.172, %indvars.iv219.i
  %arrayidx63.i.us.207 = getelementptr inbounds i16, i16* %add.ptr106, i64 %65
  store i16 %conv61.i.us.206, i16* %arrayidx63.i.us.207, align 2, !tbaa !0
  br label %for.inc.i.us208

for.inc.i.us208:                                  ; preds = %if.else.i.us199, %if.then.59.i.us203
  %indvars.iv.next.i.us.209 = add nuw nsw i64 %indvars.iv.i.us.172, 1
  %inc.i.us.210 = add nuw nsw i32 %column.0130.i.us.173, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next.i.us.209 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %2
  br i1 %exitcond, label %for.end.i.loopexit322, label %if.then.i.us171

for.end.i.loopexit322:                            ; preds = %for.inc.i.us208
  br label %for.end.i

if.else.i.us199:                                  ; preds = %if.then.i.us171
  %cond.i.us.200 = load i32, i32* %cond.in.i, align 4, !tbaa !4
  %conv66.i.us.201 = trunc i32 %cond.i.us.200 to i16
  %66 = add nsw i64 %indvars.iv.i.us.172, %indvars.iv219.i
  %arrayidx69.i.us.202 = getelementptr inbounds i16, i16* %add.ptr106, i64 %66
  store i16 %conv66.i.us.201, i16* %arrayidx69.i.us.202, align 2, !tbaa !0
  br label %for.inc.i.us208

if.then.i.preheader323:                           ; preds = %if.then.i.preheader.split
  br label %if.then.i

if.then.i:                                        ; preds = %for.inc.i, %if.then.i.preheader323
  %indvars.iv.i = phi i64 [ %indvars.iv.next.i, %for.inc.i ], [ 0, %if.then.i.preheader323 ]
  %column.0130.i = phi i32 [ %inc.i, %for.inc.i ], [ 0, %if.then.i.preheader323 ]
  %add41.i = sub i32 %add28.i, %column.0130.i
  %67 = add nuw nsw i64 %indvars.iv.i, 1
  %68 = trunc i64 %67 to i32
  %add55.i = add nsw i32 %add41.i, %68
  %cmp57.i = icmp sgt i32 %add55.i, 0
  br i1 %cmp57.i, label %if.then.59.i, label %if.else.i

if.then.59.i:                                     ; preds = %if.then.i
  %69 = load i16, i16* %add.ptr51.i, align 2, !tbaa !0
  %conv52.i = zext i16 %69 to i32
  %mul53.i = mul nsw i32 %conv52.i, %68
  %add.ptr37.i = getelementptr inbounds i16, i16* %src.sroa.11.0, i64 %indvars.iv.i
  %70 = load i16, i16* %add.ptr37.i, align 2, !tbaa !0
  %conv38.i = zext i16 %70 to i32
  %mul39.i = mul nsw i32 %conv38.i, %31
  %71 = load i16, i16* %add.ptr24.i, align 2, !tbaa !0
  %conv25.i = zext i16 %71 to i32
  %72 = sub nsw i64 %1, %indvars.iv.i
  %73 = trunc i64 %72 to i32
  %mul26.i = mul nsw i32 %conv25.i, %73
  %add.ptr11.i = getelementptr inbounds i16, i16* %add.ptr.i, i64 %indvars.iv.i
  %74 = load i16, i16* %add.ptr11.i, align 2, !tbaa !0
  %conv.i = zext i16 %74 to i32
  %mul12.i = mul nsw i32 %conv.i, %30
  %add27.i = add i32 %mul39.i, %mul53.i
  %add40.i = add i32 %add27.i, %mul26.i
  %add54.i = add i32 %add40.i, %mul12.i
  %div.i = sdiv i32 %add54.i, %add55.i
  %conv60.i = trunc i32 %div.i to i16
  %conv61.i = and i16 %conv60.i, 255
  %75 = add nsw i64 %indvars.iv.i, %indvars.iv219.i
  %arrayidx63.i = getelementptr inbounds i16, i16* %add.ptr106, i64 %75
  store i16 %conv61.i, i16* %arrayidx63.i, align 2, !tbaa !0
  br label %for.inc.i

for.inc.i:                                        ; preds = %if.else.i, %if.then.59.i
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %inc.i = add nuw nsw i32 %column.0130.i, 1
  %lftr.wideiv325 = trunc i64 %indvars.iv.next.i to i32
  %exitcond326 = icmp eq i32 %lftr.wideiv325, %2
  br i1 %exitcond326, label %for.end.i.loopexit324, label %if.then.i

for.end.i.loopexit324:                            ; preds = %for.inc.i
  br label %for.end.i

if.else.i:                                        ; preds = %if.then.i
  %cond.i = load i32, i32* %cond.in.i, align 4, !tbaa !4
  %conv66.i = trunc i32 %cond.i to i16
  %76 = add nsw i64 %indvars.iv.i, %indvars.iv219.i
  %arrayidx69.i = getelementptr inbounds i16, i16* %add.ptr106, i64 %76
  store i16 %conv66.i, i16* %arrayidx69.i, align 2, !tbaa !0
  br label %for.inc.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"short", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !2, i64 0}
