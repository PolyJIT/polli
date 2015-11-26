
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-process-unprofitable -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/JM/lencod/macroblock.c.find_sad_16x16_for.cond.124.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @find_sad_16x16_for.cond.124.preheader.pjit.scop([4 x [4 x [4 x [4 x i32]]]]* %M0, i32* %current_intra_sad_2.4.3.lcssa.lcssa.out)  {
newFuncRoot:
  br label %for.cond.124.preheader

for.body.384.exitStub:                            ; preds = %for.inc.374
  store i32 %current_intra_sad_2.4.3.lcssa.lcssa, i32* %current_intra_sad_2.4.3.lcssa.lcssa.out
  ret void

for.cond.124.preheader:                           ; preds = %for.inc.374, %newFuncRoot
  %indvars.iv809 = phi i64 [ %indvars.iv.next810, %for.inc.374 ], [ 0, %newFuncRoot ]
  %current_intra_sad_2.0775 = phi i32 [ %current_intra_sad_2.4.3.lcssa.lcssa, %for.inc.374 ], [ 0, %newFuncRoot ]
  br label %for.body.131

for.body.131:                                     ; preds = %for.inc.371, %for.cond.124.preheader
  %indvars.iv806 = phi i64 [ 0, %for.cond.124.preheader ], [ %indvars.iv.next807, %for.inc.371 ]
  %current_intra_sad_2.1773 = phi i32 [ %current_intra_sad_2.0775, %for.cond.124.preheader ], [ %current_intra_sad_2.4.3.lcssa, %for.inc.371 ]
  %arrayidx138 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 %indvars.iv806, i64 0, i64 %indvars.iv809
  %0 = load i32, i32* %arrayidx138, align 4, !tbaa !0
  %arrayidx145 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 3, i64 %indvars.iv806, i64 0, i64 %indvars.iv809
  %1 = load i32, i32* %arrayidx145, align 4, !tbaa !0
  %add146 = add nsw i32 %1, %0
  %arrayidx154 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 1, i64 %indvars.iv806, i64 0, i64 %indvars.iv809
  %2 = load i32, i32* %arrayidx154, align 4, !tbaa !0
  %arrayidx161 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 2, i64 %indvars.iv806, i64 0, i64 %indvars.iv809
  %3 = load i32, i32* %arrayidx161, align 4, !tbaa !0
  %add162 = add nsw i32 %3, %2
  %sub178 = sub nsw i32 %2, %3
  %sub194 = sub nsw i32 %0, %1
  %add198 = add nsw i32 %add162, %add146
  store i32 %add198, i32* %arrayidx138, align 4, !tbaa !0
  %sub208 = sub nsw i32 %add146, %add162
  store i32 %sub208, i32* %arrayidx161, align 4, !tbaa !0
  %add218 = add nsw i32 %sub178, %sub194
  store i32 %add218, i32* %arrayidx154, align 4, !tbaa !0
  %sub228 = sub nsw i32 %sub194, %sub178
  store i32 %sub228, i32* %arrayidx145, align 4, !tbaa !0
  %arrayidx138.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 %indvars.iv806, i64 1, i64 %indvars.iv809
  %4 = load i32, i32* %arrayidx138.1, align 4, !tbaa !0
  %arrayidx145.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 3, i64 %indvars.iv806, i64 1, i64 %indvars.iv809
  %5 = load i32, i32* %arrayidx145.1, align 4, !tbaa !0
  %add146.1 = add nsw i32 %5, %4
  %arrayidx154.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 1, i64 %indvars.iv806, i64 1, i64 %indvars.iv809
  %6 = load i32, i32* %arrayidx154.1, align 4, !tbaa !0
  %arrayidx161.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 2, i64 %indvars.iv806, i64 1, i64 %indvars.iv809
  %7 = load i32, i32* %arrayidx161.1, align 4, !tbaa !0
  %add162.1 = add nsw i32 %7, %6
  %sub178.1 = sub nsw i32 %6, %7
  %sub194.1 = sub nsw i32 %4, %5
  %add198.1 = add nsw i32 %add162.1, %add146.1
  store i32 %add198.1, i32* %arrayidx138.1, align 4, !tbaa !0
  %sub208.1 = sub nsw i32 %add146.1, %add162.1
  store i32 %sub208.1, i32* %arrayidx161.1, align 4, !tbaa !0
  %add218.1 = add nsw i32 %sub178.1, %sub194.1
  store i32 %add218.1, i32* %arrayidx154.1, align 4, !tbaa !0
  %sub228.1 = sub nsw i32 %sub194.1, %sub178.1
  store i32 %sub228.1, i32* %arrayidx145.1, align 4, !tbaa !0
  %arrayidx138.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 %indvars.iv806, i64 2, i64 %indvars.iv809
  %8 = load i32, i32* %arrayidx138.2, align 4, !tbaa !0
  %arrayidx145.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 3, i64 %indvars.iv806, i64 2, i64 %indvars.iv809
  %9 = load i32, i32* %arrayidx145.2, align 4, !tbaa !0
  %add146.2 = add nsw i32 %9, %8
  %arrayidx154.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 1, i64 %indvars.iv806, i64 2, i64 %indvars.iv809
  %10 = load i32, i32* %arrayidx154.2, align 4, !tbaa !0
  %arrayidx161.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 2, i64 %indvars.iv806, i64 2, i64 %indvars.iv809
  %11 = load i32, i32* %arrayidx161.2, align 4, !tbaa !0
  %add162.2 = add nsw i32 %11, %10
  %sub178.2 = sub nsw i32 %10, %11
  %sub194.2 = sub nsw i32 %8, %9
  %add198.2 = add nsw i32 %add162.2, %add146.2
  store i32 %add198.2, i32* %arrayidx138.2, align 4, !tbaa !0
  %sub208.2 = sub nsw i32 %add146.2, %add162.2
  store i32 %sub208.2, i32* %arrayidx161.2, align 4, !tbaa !0
  %add218.2 = add nsw i32 %sub178.2, %sub194.2
  store i32 %add218.2, i32* %arrayidx154.2, align 4, !tbaa !0
  %sub228.2 = sub nsw i32 %sub194.2, %sub178.2
  store i32 %sub228.2, i32* %arrayidx145.2, align 4, !tbaa !0
  %arrayidx138.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 0, i64 %indvars.iv806, i64 3, i64 %indvars.iv809
  %12 = load i32, i32* %arrayidx138.3, align 4, !tbaa !0
  %arrayidx145.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 3, i64 %indvars.iv806, i64 3, i64 %indvars.iv809
  %13 = load i32, i32* %arrayidx145.3, align 4, !tbaa !0
  %add146.3 = add nsw i32 %13, %12
  %arrayidx154.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 1, i64 %indvars.iv806, i64 3, i64 %indvars.iv809
  %14 = load i32, i32* %arrayidx154.3, align 4, !tbaa !0
  %arrayidx161.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 2, i64 %indvars.iv806, i64 3, i64 %indvars.iv809
  %15 = load i32, i32* %arrayidx161.3, align 4, !tbaa !0
  %add162.3 = add nsw i32 %15, %14
  %sub178.3 = sub nsw i32 %14, %15
  %sub194.3 = sub nsw i32 %12, %13
  %add198.3 = add nsw i32 %add162.3, %add146.3
  store i32 %add198.3, i32* %arrayidx138.3, align 4, !tbaa !0
  %sub208.3 = sub nsw i32 %add146.3, %add162.3
  store i32 %sub208.3, i32* %arrayidx161.3, align 4, !tbaa !0
  %add218.3 = add nsw i32 %sub178.3, %sub194.3
  store i32 %add218.3, i32* %arrayidx154.3, align 4, !tbaa !0
  %sub228.3 = sub nsw i32 %sub194.3, %sub178.3
  store i32 %sub228.3, i32* %arrayidx145.3, align 4, !tbaa !0
  br label %for.body.242

for.body.242:                                     ; preds = %for.inc.365.3, %for.body.131
  %indvars.iv803 = phi i64 [ 0, %for.body.131 ], [ %indvars.iv.next804, %for.inc.365.3 ]
  %current_intra_sad_2.2771 = phi i32 [ %current_intra_sad_2.1773, %for.body.131 ], [ %current_intra_sad_2.4.3, %for.inc.365.3 ]
  %arrayidx249 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv803, i64 %indvars.iv806, i64 0, i64 %indvars.iv809
  %16 = load i32, i32* %arrayidx249, align 4, !tbaa !0
  %arrayidx256 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv803, i64 %indvars.iv806, i64 3, i64 %indvars.iv809
  %17 = load i32, i32* %arrayidx256, align 4, !tbaa !0
  %add257 = add nsw i32 %17, %16
  %arrayidx265 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv803, i64 %indvars.iv806, i64 1, i64 %indvars.iv809
  %18 = load i32, i32* %arrayidx265, align 4, !tbaa !0
  %arrayidx272 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv803, i64 %indvars.iv806, i64 2, i64 %indvars.iv809
  %19 = load i32, i32* %arrayidx272, align 4, !tbaa !0
  %add273 = add nsw i32 %19, %18
  %sub289 = sub nsw i32 %18, %19
  %sub305 = sub nsw i32 %16, %17
  %add309 = add nsw i32 %add273, %add257
  store i32 %add309, i32* %arrayidx249, align 4, !tbaa !0
  %sub319 = sub nsw i32 %add257, %add273
  store i32 %sub319, i32* %arrayidx272, align 4, !tbaa !0
  %add329 = add nsw i32 %sub289, %sub305
  store i32 %add329, i32* %arrayidx265, align 4, !tbaa !0
  %sub339 = sub nsw i32 %sub305, %sub289
  store i32 %sub339, i32* %arrayidx256, align 4, !tbaa !0
  %cmp352 = icmp eq i64 %indvars.iv803, 0
  br i1 %cmp352, label %for.inc.365, label %if.then.354

for.inc.365:                                      ; preds = %if.then.354, %for.body.242
  %current_intra_sad_2.4 = phi i32 [ %add363, %if.then.354 ], [ %current_intra_sad_2.2771, %for.body.242 ]
  br i1 false, label %for.inc.365.1, label %if.then.354.1

for.inc.365.1:                                    ; preds = %if.then.354.1, %for.inc.365
  %current_intra_sad_2.4.1 = phi i32 [ %add363.1, %if.then.354.1 ], [ %current_intra_sad_2.4, %for.inc.365 ]
  br i1 false, label %for.inc.365.2, label %if.then.354.2

for.inc.365.2:                                    ; preds = %if.then.354.2, %for.inc.365.1
  %current_intra_sad_2.4.2 = phi i32 [ %add363.2, %if.then.354.2 ], [ %current_intra_sad_2.4.1, %for.inc.365.1 ]
  br i1 false, label %for.inc.365.3, label %if.then.354.3

for.inc.365.3:                                    ; preds = %if.then.354.3, %for.inc.365.2
  %current_intra_sad_2.4.3 = phi i32 [ %add363.3, %if.then.354.3 ], [ %current_intra_sad_2.4.2, %for.inc.365.2 ]
  %indvars.iv.next804 = add nuw nsw i64 %indvars.iv803, 1
  %exitcond805 = icmp eq i64 %indvars.iv.next804, 4
  br i1 %exitcond805, label %for.inc.371, label %for.body.242

for.inc.371:                                      ; preds = %for.inc.365.3
  %current_intra_sad_2.4.3.lcssa = phi i32 [ %current_intra_sad_2.4.3, %for.inc.365.3 ]
  %indvars.iv.next807 = add nuw nsw i64 %indvars.iv806, 1
  %exitcond808 = icmp eq i64 %indvars.iv.next807, 4
  br i1 %exitcond808, label %for.inc.374, label %for.body.131

for.inc.374:                                      ; preds = %for.inc.371
  %current_intra_sad_2.4.3.lcssa.lcssa = phi i32 [ %current_intra_sad_2.4.3.lcssa, %for.inc.371 ]
  %indvars.iv.next810 = add nuw nsw i64 %indvars.iv809, 1
  %exitcond811 = icmp eq i64 %indvars.iv.next810, 4
  br i1 %exitcond811, label %for.body.384.exitStub, label %for.cond.124.preheader

if.then.354.3:                                    ; preds = %for.inc.365.2
  %arrayidx362.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv803, i64 %indvars.iv806, i64 3, i64 %indvars.iv809
  %20 = load i32, i32* %arrayidx362.3, align 4, !tbaa !0
  %cmp.i.3 = icmp slt i32 %20, 0
  %sub.i.3 = sub nsw i32 0, %20
  %cond.i.3 = select i1 %cmp.i.3, i32 %sub.i.3, i32 %20
  %add363.3 = add nsw i32 %cond.i.3, %current_intra_sad_2.4.2
  br label %for.inc.365.3

if.then.354.2:                                    ; preds = %for.inc.365.1
  %arrayidx362.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv803, i64 %indvars.iv806, i64 2, i64 %indvars.iv809
  %21 = load i32, i32* %arrayidx362.2, align 4, !tbaa !0
  %cmp.i.2 = icmp slt i32 %21, 0
  %sub.i.2 = sub nsw i32 0, %21
  %cond.i.2 = select i1 %cmp.i.2, i32 %sub.i.2, i32 %21
  %add363.2 = add nsw i32 %cond.i.2, %current_intra_sad_2.4.1
  br label %for.inc.365.2

if.then.354.1:                                    ; preds = %for.inc.365
  %arrayidx362.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv803, i64 %indvars.iv806, i64 1, i64 %indvars.iv809
  %22 = load i32, i32* %arrayidx362.1, align 4, !tbaa !0
  %cmp.i.1 = icmp slt i32 %22, 0
  %sub.i.1 = sub nsw i32 0, %22
  %cond.i.1 = select i1 %cmp.i.1, i32 %sub.i.1, i32 %22
  %add363.1 = add nsw i32 %cond.i.1, %current_intra_sad_2.4
  br label %for.inc.365.1

if.then.354:                                      ; preds = %for.body.242
  %arrayidx362 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %M0, i64 0, i64 %indvars.iv803, i64 %indvars.iv806, i64 0, i64 %indvars.iv809
  %23 = load i32, i32* %arrayidx362, align 4, !tbaa !0
  %cmp.i = icmp slt i32 %23, 0
  %sub.i = sub nsw i32 0, %23
  %cond.i = select i1 %cmp.i, i32 %sub.i, i32 %23
  %add363 = add nsw i32 %cond.i, %current_intra_sad_2.2771
  br label %for.inc.365
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
