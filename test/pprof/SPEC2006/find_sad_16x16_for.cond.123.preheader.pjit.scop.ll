
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli-process-unprofitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/464.h264ref/src/macroblock.c.find_sad_16x16_for.cond.123.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @find_sad_16x16_for.cond.123.preheader.pjit.scop([4 x [4 x [4 x [4 x i32]]]]* %M0, [4 x [4 x i32]]* %M4, i32 %best_intra_sad2.0781, i64 %indvars.iv825, i32* %intra_mode, i32* %add533.3.lcssa.out)  {
newFuncRoot:
  br label %for.cond.123.preheader

for.inc.545.exitStub:                             ; preds = %if.then.542, %for.end.539
  store i32 %add533.3.lcssa, i32* %add533.3.lcssa.out
  ret void

for.cond.123.preheader:                           ; preds = %for.inc.373, %newFuncRoot
  %indvars.iv807 = phi i64 [ %indvars.iv.next808, %for.inc.373 ], [ 0, %newFuncRoot ]
  %current_intra_sad_2.0773 = phi i32 [ %current_intra_sad_2.4.3.lcssa.lcssa, %for.inc.373 ], [ 0, %newFuncRoot ]
  br label %for.body.130

for.body.130:                                     ; preds = %for.inc.370, %for.cond.123.preheader
  %indvars.iv804 = phi i64 [ 0, %for.cond.123.preheader ], [ %indvars.iv.next805, %for.inc.370 ]
  %current_intra_sad_2.1771 = phi i32 [ %current_intra_sad_2.0773, %for.cond.123.preheader ], [ %current_intra_sad_2.4.3.lcssa, %for.inc.370 ]
  %arrayidx137 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 %indvars.iv804, i64 0, i64 %indvars.iv807
  %0 = load i32, i32* %arrayidx137, align 4, !tbaa !0
  %arrayidx144 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 3, i64 %indvars.iv804, i64 0, i64 %indvars.iv807
  %1 = load i32, i32* %arrayidx144, align 4, !tbaa !0
  %add145 = add nsw i32 %1, %0
  %arrayidx153 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 1, i64 %indvars.iv804, i64 0, i64 %indvars.iv807
  %2 = load i32, i32* %arrayidx153, align 4, !tbaa !0
  %arrayidx160 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 2, i64 %indvars.iv804, i64 0, i64 %indvars.iv807
  %3 = load i32, i32* %arrayidx160, align 4, !tbaa !0
  %add161 = add nsw i32 %3, %2
  %sub177 = sub nsw i32 %2, %3
  %sub193 = sub nsw i32 %0, %1
  %add197 = add nsw i32 %add161, %add145
  store i32 %add197, i32* %arrayidx137, align 4, !tbaa !0
  %sub207 = sub nsw i32 %add145, %add161
  store i32 %sub207, i32* %arrayidx160, align 4, !tbaa !0
  %add217 = add nsw i32 %sub177, %sub193
  store i32 %add217, i32* %arrayidx153, align 4, !tbaa !0
  %sub227 = sub nsw i32 %sub193, %sub177
  store i32 %sub227, i32* %arrayidx144, align 4, !tbaa !0
  %arrayidx137.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 %indvars.iv804, i64 1, i64 %indvars.iv807
  %4 = load i32, i32* %arrayidx137.1, align 4, !tbaa !0
  %arrayidx144.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 3, i64 %indvars.iv804, i64 1, i64 %indvars.iv807
  %5 = load i32, i32* %arrayidx144.1, align 4, !tbaa !0
  %add145.1 = add nsw i32 %5, %4
  %arrayidx153.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 1, i64 %indvars.iv804, i64 1, i64 %indvars.iv807
  %6 = load i32, i32* %arrayidx153.1, align 4, !tbaa !0
  %arrayidx160.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 2, i64 %indvars.iv804, i64 1, i64 %indvars.iv807
  %7 = load i32, i32* %arrayidx160.1, align 4, !tbaa !0
  %add161.1 = add nsw i32 %7, %6
  %sub177.1 = sub nsw i32 %6, %7
  %sub193.1 = sub nsw i32 %4, %5
  %add197.1 = add nsw i32 %add161.1, %add145.1
  store i32 %add197.1, i32* %arrayidx137.1, align 4, !tbaa !0
  %sub207.1 = sub nsw i32 %add145.1, %add161.1
  store i32 %sub207.1, i32* %arrayidx160.1, align 4, !tbaa !0
  %add217.1 = add nsw i32 %sub177.1, %sub193.1
  store i32 %add217.1, i32* %arrayidx153.1, align 4, !tbaa !0
  %sub227.1 = sub nsw i32 %sub193.1, %sub177.1
  store i32 %sub227.1, i32* %arrayidx144.1, align 4, !tbaa !0
  %arrayidx137.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 %indvars.iv804, i64 2, i64 %indvars.iv807
  %8 = load i32, i32* %arrayidx137.2, align 4, !tbaa !0
  %arrayidx144.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 3, i64 %indvars.iv804, i64 2, i64 %indvars.iv807
  %9 = load i32, i32* %arrayidx144.2, align 4, !tbaa !0
  %add145.2 = add nsw i32 %9, %8
  %arrayidx153.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 1, i64 %indvars.iv804, i64 2, i64 %indvars.iv807
  %10 = load i32, i32* %arrayidx153.2, align 4, !tbaa !0
  %arrayidx160.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 2, i64 %indvars.iv804, i64 2, i64 %indvars.iv807
  %11 = load i32, i32* %arrayidx160.2, align 4, !tbaa !0
  %add161.2 = add nsw i32 %11, %10
  %sub177.2 = sub nsw i32 %10, %11
  %sub193.2 = sub nsw i32 %8, %9
  %add197.2 = add nsw i32 %add161.2, %add145.2
  store i32 %add197.2, i32* %arrayidx137.2, align 4, !tbaa !0
  %sub207.2 = sub nsw i32 %add145.2, %add161.2
  store i32 %sub207.2, i32* %arrayidx160.2, align 4, !tbaa !0
  %add217.2 = add nsw i32 %sub177.2, %sub193.2
  store i32 %add217.2, i32* %arrayidx153.2, align 4, !tbaa !0
  %sub227.2 = sub nsw i32 %sub193.2, %sub177.2
  store i32 %sub227.2, i32* %arrayidx144.2, align 4, !tbaa !0
  %arrayidx137.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 %indvars.iv804, i64 3, i64 %indvars.iv807
  %12 = load i32, i32* %arrayidx137.3, align 4, !tbaa !0
  %arrayidx144.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 3, i64 %indvars.iv804, i64 3, i64 %indvars.iv807
  %13 = load i32, i32* %arrayidx144.3, align 4, !tbaa !0
  %add145.3 = add nsw i32 %13, %12
  %arrayidx153.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 1, i64 %indvars.iv804, i64 3, i64 %indvars.iv807
  %14 = load i32, i32* %arrayidx153.3, align 4, !tbaa !0
  %arrayidx160.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 2, i64 %indvars.iv804, i64 3, i64 %indvars.iv807
  %15 = load i32, i32* %arrayidx160.3, align 4, !tbaa !0
  %add161.3 = add nsw i32 %15, %14
  %sub177.3 = sub nsw i32 %14, %15
  %sub193.3 = sub nsw i32 %12, %13
  %add197.3 = add nsw i32 %add161.3, %add145.3
  store i32 %add197.3, i32* %arrayidx137.3, align 4, !tbaa !0
  %sub207.3 = sub nsw i32 %add145.3, %add161.3
  store i32 %sub207.3, i32* %arrayidx160.3, align 4, !tbaa !0
  %add217.3 = add nsw i32 %sub177.3, %sub193.3
  store i32 %add217.3, i32* %arrayidx153.3, align 4, !tbaa !0
  %sub227.3 = sub nsw i32 %sub193.3, %sub177.3
  store i32 %sub227.3, i32* %arrayidx144.3, align 4, !tbaa !0
  br label %for.body.241

for.body.241:                                     ; preds = %for.inc.364.3, %for.body.130
  %indvars.iv801 = phi i64 [ 0, %for.body.130 ], [ %indvars.iv.next802, %for.inc.364.3 ]
  %current_intra_sad_2.2769 = phi i32 [ %current_intra_sad_2.1771, %for.body.130 ], [ %current_intra_sad_2.4.3, %for.inc.364.3 ]
  %arrayidx248 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv801, i64 %indvars.iv804, i64 0, i64 %indvars.iv807
  %16 = load i32, i32* %arrayidx248, align 4, !tbaa !0
  %arrayidx255 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv801, i64 %indvars.iv804, i64 3, i64 %indvars.iv807
  %17 = load i32, i32* %arrayidx255, align 4, !tbaa !0
  %add256 = add nsw i32 %17, %16
  %arrayidx264 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv801, i64 %indvars.iv804, i64 1, i64 %indvars.iv807
  %18 = load i32, i32* %arrayidx264, align 4, !tbaa !0
  %arrayidx271 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv801, i64 %indvars.iv804, i64 2, i64 %indvars.iv807
  %19 = load i32, i32* %arrayidx271, align 4, !tbaa !0
  %add272 = add nsw i32 %19, %18
  %sub288 = sub nsw i32 %18, %19
  %sub304 = sub nsw i32 %16, %17
  %add308 = add nsw i32 %add272, %add256
  store i32 %add308, i32* %arrayidx248, align 4, !tbaa !0
  %sub318 = sub nsw i32 %add256, %add272
  store i32 %sub318, i32* %arrayidx271, align 4, !tbaa !0
  %add328 = add nsw i32 %sub288, %sub304
  store i32 %add328, i32* %arrayidx264, align 4, !tbaa !0
  %sub338 = sub nsw i32 %sub304, %sub288
  store i32 %sub338, i32* %arrayidx255, align 4, !tbaa !0
  %cmp351 = icmp eq i64 %indvars.iv801, 0
  br i1 %cmp351, label %for.inc.364, label %if.then.353

for.inc.364:                                      ; preds = %if.then.353, %for.body.241
  %current_intra_sad_2.4 = phi i32 [ %add362, %if.then.353 ], [ %current_intra_sad_2.2769, %for.body.241 ]
  br i1 false, label %for.inc.364.1, label %if.then.353.1

for.inc.364.1:                                    ; preds = %if.then.353.1, %for.inc.364
  %current_intra_sad_2.4.1 = phi i32 [ %add362.1, %if.then.353.1 ], [ %current_intra_sad_2.4, %for.inc.364 ]
  br i1 false, label %for.inc.364.2, label %if.then.353.2

for.inc.364.2:                                    ; preds = %if.then.353.2, %for.inc.364.1
  %current_intra_sad_2.4.2 = phi i32 [ %add362.2, %if.then.353.2 ], [ %current_intra_sad_2.4.1, %for.inc.364.1 ]
  br i1 false, label %for.inc.364.3, label %if.then.353.3

for.inc.364.3:                                    ; preds = %if.then.353.3, %for.inc.364.2
  %current_intra_sad_2.4.3 = phi i32 [ %add362.3, %if.then.353.3 ], [ %current_intra_sad_2.4.2, %for.inc.364.2 ]
  %indvars.iv.next802 = add nuw nsw i64 %indvars.iv801, 1
  %exitcond803 = icmp eq i64 %indvars.iv.next802, 4
  br i1 %exitcond803, label %for.inc.370, label %for.body.241

for.inc.370:                                      ; preds = %for.inc.364.3
  %current_intra_sad_2.4.3.lcssa = phi i32 [ %current_intra_sad_2.4.3, %for.inc.364.3 ]
  %indvars.iv.next805 = add nuw nsw i64 %indvars.iv804, 1
  %exitcond806 = icmp eq i64 %indvars.iv.next805, 4
  br i1 %exitcond806, label %for.inc.373, label %for.body.130

for.inc.373:                                      ; preds = %for.inc.370
  %current_intra_sad_2.4.3.lcssa.lcssa = phi i32 [ %current_intra_sad_2.4.3.lcssa, %for.inc.370 ]
  %indvars.iv.next808 = add nuw nsw i64 %indvars.iv807, 1
  %exitcond809 = icmp eq i64 %indvars.iv.next808, 4
  br i1 %exitcond809, label %for.body.383, label %for.cond.123.preheader

for.body.383:                                     ; preds = %for.inc.373
  %current_intra_sad_2.4.3.lcssa.lcssa.lcssa = phi i32 [ %current_intra_sad_2.4.3.lcssa.lcssa, %for.inc.373 ]
  %arrayidx389 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 0, i64 0, i64 0
  %20 = load i32, i32* %arrayidx389, align 16, !tbaa !0
  %div390 = sdiv i32 %20, 4
  %arrayidx394 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 0, i64 0
  store i32 %div390, i32* %arrayidx394, align 16, !tbaa !0
  %arrayidx389.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 1, i64 0, i64 0
  %21 = load i32, i32* %arrayidx389.1, align 16, !tbaa !0
  %div390.1 = sdiv i32 %21, 4
  %arrayidx394.1 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 1, i64 0
  store i32 %div390.1, i32* %arrayidx394.1, align 16, !tbaa !0
  %arrayidx389.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 2, i64 0, i64 0
  %22 = load i32, i32* %arrayidx389.2, align 16, !tbaa !0
  %div390.2 = sdiv i32 %22, 4
  %arrayidx394.2 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 2, i64 0
  store i32 %div390.2, i32* %arrayidx394.2, align 16, !tbaa !0
  %arrayidx389.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 3, i64 0, i64 0
  %23 = load i32, i32* %arrayidx389.3, align 16, !tbaa !0
  %div390.3 = sdiv i32 %23, 4
  %arrayidx394.3 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 3, i64 0
  store i32 %div390.3, i32* %arrayidx394.3, align 16, !tbaa !0
  %arrayidx389.1.835 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 0, i64 0, i64 1
  %24 = load i32, i32* %arrayidx389.1.835, align 4, !tbaa !0
  %div390.1.836 = sdiv i32 %24, 4
  %arrayidx394.1.837 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 0, i64 1
  store i32 %div390.1.836, i32* %arrayidx394.1.837, align 4, !tbaa !0
  %arrayidx389.1.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 1, i64 0, i64 1
  %25 = load i32, i32* %arrayidx389.1.1, align 4, !tbaa !0
  %div390.1.1 = sdiv i32 %25, 4
  %arrayidx394.1.1 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 1, i64 1
  store i32 %div390.1.1, i32* %arrayidx394.1.1, align 4, !tbaa !0
  %arrayidx389.2.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 2, i64 0, i64 1
  %26 = load i32, i32* %arrayidx389.2.1, align 4, !tbaa !0
  %div390.2.1 = sdiv i32 %26, 4
  %arrayidx394.2.1 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 2, i64 1
  store i32 %div390.2.1, i32* %arrayidx394.2.1, align 4, !tbaa !0
  %arrayidx389.3.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 3, i64 0, i64 1
  %27 = load i32, i32* %arrayidx389.3.1, align 4, !tbaa !0
  %div390.3.1 = sdiv i32 %27, 4
  %arrayidx394.3.1 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 3, i64 1
  store i32 %div390.3.1, i32* %arrayidx394.3.1, align 4, !tbaa !0
  %arrayidx389.2.838 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 0, i64 0, i64 2
  %28 = load i32, i32* %arrayidx389.2.838, align 8, !tbaa !0
  %div390.2.839 = sdiv i32 %28, 4
  %arrayidx394.2.840 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 0, i64 2
  store i32 %div390.2.839, i32* %arrayidx394.2.840, align 8, !tbaa !0
  %arrayidx389.1.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 1, i64 0, i64 2
  %29 = load i32, i32* %arrayidx389.1.2, align 8, !tbaa !0
  %div390.1.2 = sdiv i32 %29, 4
  %arrayidx394.1.2 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 1, i64 2
  store i32 %div390.1.2, i32* %arrayidx394.1.2, align 8, !tbaa !0
  %arrayidx389.2.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 2, i64 0, i64 2
  %30 = load i32, i32* %arrayidx389.2.2, align 8, !tbaa !0
  %div390.2.2 = sdiv i32 %30, 4
  %arrayidx394.2.2 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 2, i64 2
  store i32 %div390.2.2, i32* %arrayidx394.2.2, align 8, !tbaa !0
  %arrayidx389.3.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 3, i64 0, i64 2
  %31 = load i32, i32* %arrayidx389.3.2, align 8, !tbaa !0
  %div390.3.2 = sdiv i32 %31, 4
  %arrayidx394.3.2 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 3, i64 2
  store i32 %div390.3.2, i32* %arrayidx394.3.2, align 8, !tbaa !0
  %arrayidx389.3.841 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 0, i64 0, i64 3
  %32 = load i32, i32* %arrayidx389.3.841, align 4, !tbaa !0
  %div390.3.842 = sdiv i32 %32, 4
  %arrayidx394.3.843 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 0, i64 3
  store i32 %div390.3.842, i32* %arrayidx394.3.843, align 4, !tbaa !0
  %arrayidx389.1.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 1, i64 0, i64 3
  %33 = load i32, i32* %arrayidx389.1.3, align 4, !tbaa !0
  %div390.1.3 = sdiv i32 %33, 4
  %arrayidx394.1.3 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 1, i64 3
  store i32 %div390.1.3, i32* %arrayidx394.1.3, align 4, !tbaa !0
  %arrayidx389.2.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 2, i64 0, i64 3
  %34 = load i32, i32* %arrayidx389.2.3, align 4, !tbaa !0
  %div390.2.3 = sdiv i32 %34, 4
  %arrayidx394.2.3 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 2, i64 3
  store i32 %div390.2.3, i32* %arrayidx394.2.3, align 4, !tbaa !0
  %arrayidx389.3.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 3, i64 0, i64 3
  %35 = load i32, i32* %arrayidx389.3.3, align 4, !tbaa !0
  %div390.3.3 = sdiv i32 %35, 4
  %arrayidx394.3.3 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 3, i64 3
  store i32 %div390.3.3, i32* %arrayidx394.3.3, align 4, !tbaa !0
  %arrayidx407 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 0, i64 0
  %36 = load i32, i32* %arrayidx407, align 16, !tbaa !0
  %arrayidx410 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 3, i64 0
  %37 = load i32, i32* %arrayidx410, align 16, !tbaa !0
  %add411 = add nsw i32 %37, %36
  %arrayidx415 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 1, i64 0
  %38 = load i32, i32* %arrayidx415, align 16, !tbaa !0
  %arrayidx418 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 2, i64 0
  %39 = load i32, i32* %arrayidx418, align 16, !tbaa !0
  %add419 = add nsw i32 %39, %38
  %sub427 = sub nsw i32 %38, %39
  %sub435 = sub nsw i32 %36, %37
  %add439 = add nsw i32 %add419, %add411
  store i32 %add439, i32* %arrayidx407, align 16, !tbaa !0
  %sub445 = sub nsw i32 %add411, %add419
  store i32 %sub445, i32* %arrayidx418, align 16, !tbaa !0
  %add451 = add nsw i32 %sub427, %sub435
  store i32 %add451, i32* %arrayidx415, align 16, !tbaa !0
  %sub457 = sub nsw i32 %sub435, %sub427
  store i32 %sub457, i32* %arrayidx410, align 16, !tbaa !0
  %arrayidx407.1 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 0, i64 1
  %40 = load i32, i32* %arrayidx407.1, align 4, !tbaa !0
  %arrayidx410.1 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 3, i64 1
  %41 = load i32, i32* %arrayidx410.1, align 4, !tbaa !0
  %add411.1 = add nsw i32 %41, %40
  %arrayidx415.1 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 1, i64 1
  %42 = load i32, i32* %arrayidx415.1, align 4, !tbaa !0
  %arrayidx418.1 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 2, i64 1
  %43 = load i32, i32* %arrayidx418.1, align 4, !tbaa !0
  %add419.1 = add nsw i32 %43, %42
  %sub427.1 = sub nsw i32 %42, %43
  %sub435.1 = sub nsw i32 %40, %41
  %add439.1 = add nsw i32 %add419.1, %add411.1
  store i32 %add439.1, i32* %arrayidx407.1, align 4, !tbaa !0
  %sub445.1 = sub nsw i32 %add411.1, %add419.1
  store i32 %sub445.1, i32* %arrayidx418.1, align 4, !tbaa !0
  %add451.1 = add nsw i32 %sub427.1, %sub435.1
  store i32 %add451.1, i32* %arrayidx415.1, align 4, !tbaa !0
  %sub457.1 = sub nsw i32 %sub435.1, %sub427.1
  store i32 %sub457.1, i32* %arrayidx410.1, align 4, !tbaa !0
  %arrayidx407.2 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 0, i64 2
  %44 = load i32, i32* %arrayidx407.2, align 8, !tbaa !0
  %arrayidx410.2 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 3, i64 2
  %45 = load i32, i32* %arrayidx410.2, align 8, !tbaa !0
  %add411.2 = add nsw i32 %45, %44
  %arrayidx415.2 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 1, i64 2
  %46 = load i32, i32* %arrayidx415.2, align 8, !tbaa !0
  %arrayidx418.2 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 2, i64 2
  %47 = load i32, i32* %arrayidx418.2, align 8, !tbaa !0
  %add419.2 = add nsw i32 %47, %46
  %sub427.2 = sub nsw i32 %46, %47
  %sub435.2 = sub nsw i32 %44, %45
  %add439.2 = add nsw i32 %add419.2, %add411.2
  store i32 %add439.2, i32* %arrayidx407.2, align 8, !tbaa !0
  %sub445.2 = sub nsw i32 %add411.2, %add419.2
  store i32 %sub445.2, i32* %arrayidx418.2, align 8, !tbaa !0
  %add451.2 = add nsw i32 %sub427.2, %sub435.2
  store i32 %add451.2, i32* %arrayidx415.2, align 8, !tbaa !0
  %sub457.2 = sub nsw i32 %sub435.2, %sub427.2
  store i32 %sub457.2, i32* %arrayidx410.2, align 8, !tbaa !0
  %arrayidx407.3 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 0, i64 3
  %48 = load i32, i32* %arrayidx407.3, align 4, !tbaa !0
  %arrayidx410.3 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 3, i64 3
  %49 = load i32, i32* %arrayidx410.3, align 4, !tbaa !0
  %add411.3 = add nsw i32 %49, %48
  %arrayidx415.3 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 1, i64 3
  %50 = load i32, i32* %arrayidx415.3, align 4, !tbaa !0
  %arrayidx418.3 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 2, i64 3
  %51 = load i32, i32* %arrayidx418.3, align 4, !tbaa !0
  %add419.3 = add nsw i32 %51, %50
  %sub427.3 = sub nsw i32 %50, %51
  %sub435.3 = sub nsw i32 %48, %49
  %add439.3 = add nsw i32 %add419.3, %add411.3
  store i32 %add439.3, i32* %arrayidx407.3, align 4, !tbaa !0
  %sub445.3 = sub nsw i32 %add411.3, %add419.3
  store i32 %sub445.3, i32* %arrayidx418.3, align 4, !tbaa !0
  %add451.3 = add nsw i32 %sub427.3, %sub435.3
  store i32 %add451.3, i32* %arrayidx415.3, align 4, !tbaa !0
  %sub457.3 = sub nsw i32 %sub435.3, %sub427.3
  store i32 %sub457.3, i32* %arrayidx410.3, align 4, !tbaa !0
  br label %for.body.467

for.body.467:                                     ; preds = %for.body.467, %for.body.383
  %indvars.iv822 = phi i64 [ 0, %for.body.383 ], [ %indvars.iv.next823, %for.body.467 ]
  %current_intra_sad_2.5780 = phi i32 [ %current_intra_sad_2.4.3.lcssa.lcssa.lcssa, %for.body.383 ], [ %add533.3, %for.body.467 ]
  %arrayidx470 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 %indvars.iv822, i64 0
  %52 = load i32, i32* %arrayidx470, align 16, !tbaa !0
  %arrayidx473 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 %indvars.iv822, i64 3
  %53 = load i32, i32* %arrayidx473, align 4, !tbaa !0
  %add474 = add nsw i32 %53, %52
  %arrayidx478 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 %indvars.iv822, i64 1
  %54 = load i32, i32* %arrayidx478, align 4, !tbaa !0
  %arrayidx481 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 %indvars.iv822, i64 2
  %55 = load i32, i32* %arrayidx481, align 8, !tbaa !0
  %add482 = add nsw i32 %55, %54
  %sub490 = sub nsw i32 %54, %55
  %sub498 = sub nsw i32 %52, %53
  %add502 = add nsw i32 %add482, %add474
  store i32 %add502, i32* %arrayidx470, align 16, !tbaa !0
  %sub508 = sub nsw i32 %add474, %add482
  store i32 %sub508, i32* %arrayidx481, align 8, !tbaa !0
  %add514 = add nsw i32 %sub490, %sub498
  store i32 %add514, i32* %arrayidx478, align 4, !tbaa !0
  %sub520 = sub nsw i32 %sub498, %sub490
  store i32 %sub520, i32* %arrayidx473, align 4, !tbaa !0
  %arrayidx531 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 %indvars.iv822, i64 0
  %56 = load i32, i32* %arrayidx531, align 16, !tbaa !0
  %ispos = icmp sgt i32 %56, -1
  %neg = sub i32 0, %56
  %57 = select i1 %ispos, i32 %56, i32 %neg
  %add533 = add nsw i32 %57, %current_intra_sad_2.5780
  %arrayidx531.1 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 %indvars.iv822, i64 1
  %58 = load i32, i32* %arrayidx531.1, align 4, !tbaa !0
  %ispos.1 = icmp sgt i32 %58, -1
  %neg.1 = sub i32 0, %58
  %59 = select i1 %ispos.1, i32 %58, i32 %neg.1
  %add533.1 = add nsw i32 %add533, %59
  %arrayidx531.2 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 %indvars.iv822, i64 2
  %60 = load i32, i32* %arrayidx531.2, align 8, !tbaa !0
  %ispos.2 = icmp sgt i32 %60, -1
  %neg.2 = sub i32 0, %60
  %61 = select i1 %ispos.2, i32 %60, i32 %neg.2
  %add533.2 = add nsw i32 %add533.1, %61
  %arrayidx531.3 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %M4, i64 0, i64 %indvars.iv822, i64 3
  %62 = load i32, i32* %arrayidx531.3, align 4, !tbaa !0
  %ispos.3 = icmp sgt i32 %62, -1
  %neg.3 = sub i32 0, %62
  %63 = select i1 %ispos.3, i32 %62, i32 %neg.3
  %add533.3 = add nsw i32 %add533.2, %63
  %indvars.iv.next823 = add nuw nsw i64 %indvars.iv822, 1
  %exitcond824 = icmp eq i64 %indvars.iv.next823, 4
  br i1 %exitcond824, label %for.end.539, label %for.body.467

for.end.539:                                      ; preds = %for.body.467
  %add533.3.lcssa = phi i32 [ %add533.3, %for.body.467 ]
  %cmp540 = icmp slt i32 %add533.3.lcssa, %best_intra_sad2.0781
  br i1 %cmp540, label %if.then.542, label %for.inc.545.exitStub

if.then.542:                                      ; preds = %for.end.539
  %64 = trunc i64 %indvars.iv825 to i32
  store i32 %64, i32* %intra_mode, align 4, !tbaa !0
  br label %for.inc.545.exitStub

if.then.353.3:                                    ; preds = %for.inc.364.2
  %arrayidx361.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv801, i64 %indvars.iv804, i64 3, i64 %indvars.iv807
  %65 = load i32, i32* %arrayidx361.3, align 4, !tbaa !0
  %ispos761.3 = icmp sgt i32 %65, -1
  %neg762.3 = sub i32 0, %65
  %66 = select i1 %ispos761.3, i32 %65, i32 %neg762.3
  %add362.3 = add nsw i32 %66, %current_intra_sad_2.4.2
  br label %for.inc.364.3

if.then.353.2:                                    ; preds = %for.inc.364.1
  %arrayidx361.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv801, i64 %indvars.iv804, i64 2, i64 %indvars.iv807
  %67 = load i32, i32* %arrayidx361.2, align 4, !tbaa !0
  %ispos761.2 = icmp sgt i32 %67, -1
  %neg762.2 = sub i32 0, %67
  %68 = select i1 %ispos761.2, i32 %67, i32 %neg762.2
  %add362.2 = add nsw i32 %68, %current_intra_sad_2.4.1
  br label %for.inc.364.2

if.then.353.1:                                    ; preds = %for.inc.364
  %arrayidx361.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv801, i64 %indvars.iv804, i64 1, i64 %indvars.iv807
  %69 = load i32, i32* %arrayidx361.1, align 4, !tbaa !0
  %ispos761.1 = icmp sgt i32 %69, -1
  %neg762.1 = sub i32 0, %69
  %70 = select i1 %ispos761.1, i32 %69, i32 %neg762.1
  %add362.1 = add nsw i32 %70, %current_intra_sad_2.4
  br label %for.inc.364.1

if.then.353:                                      ; preds = %for.body.241
  %arrayidx361 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv801, i64 %indvars.iv804, i64 0, i64 %indvars.iv807
  %71 = load i32, i32* %arrayidx361, align 4, !tbaa !0
  %ispos761 = icmp sgt i32 %71, -1
  %neg762 = sub i32 0, %71
  %72 = select i1 %ispos761, i32 %71, i32 %neg762
  %add362 = add nsw i32 %72, %current_intra_sad_2.2769
  br label %for.inc.364
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
