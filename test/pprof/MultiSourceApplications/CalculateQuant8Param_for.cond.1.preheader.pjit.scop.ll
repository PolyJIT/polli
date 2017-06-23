
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli-process-unprofitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/JM/ldecod/macroblock.c.CalculateQuant8Param_for.cond.1.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @CalculateQuant8Param_for.cond.1.preheader.pjit.scop(i32*, i32*, [6 x [8 x [8 x i32]]]* nonnull %dequant_coef8, [6 x [8 x [8 x i32]]]* nonnull %InvLevelScale8x8Luma_Intra, [6 x [8 x [8 x i32]]]* nonnull %InvLevelScale8x8Luma_Inter)  {
newFuncRoot:
  br label %for.cond.1.preheader

for.end.39.exitStub:                              ; preds = %for.inc.37
  ret void

for.cond.1.preheader:                             ; preds = %for.inc.37, %newFuncRoot
  %indvars.iv70 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next71, %for.inc.37 ]
  br label %for.body.6

for.body.6:                                       ; preds = %for.body.6, %for.cond.1.preheader
  %indvars.iv67 = phi i64 [ 0, %for.cond.1.preheader ], [ %indvars.iv.next68, %for.body.6 ]
  %arrayidx10 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %dequant_coef8, i64 0, i64 %indvars.iv70, i64 %indvars.iv67, i64 0
  %2 = load i32, i32* %arrayidx10, align 16, !tbaa !0
  %arrayidx12 = getelementptr inbounds i32, i32* %0, i64 %indvars.iv67
  %3 = load i32, i32* %arrayidx12, align 4, !tbaa !0
  %mul = mul nsw i32 %3, %2
  %arrayidx18 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Intra, i64 0, i64 %indvars.iv70, i64 0, i64 %indvars.iv67
  store i32 %mul, i32* %arrayidx18, align 4, !tbaa !0
  %arrayidx26 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv67
  %4 = load i32, i32* %arrayidx26, align 4, !tbaa !0
  %mul27 = mul nsw i32 %4, %2
  %arrayidx33 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Inter, i64 0, i64 %indvars.iv70, i64 0, i64 %indvars.iv67
  store i32 %mul27, i32* %arrayidx33, align 4, !tbaa !0
  %5 = add nuw nsw i64 %indvars.iv67, 8
  %arrayidx10.1 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %dequant_coef8, i64 0, i64 %indvars.iv70, i64 %indvars.iv67, i64 1
  %6 = load i32, i32* %arrayidx10.1, align 4, !tbaa !0
  %arrayidx12.1 = getelementptr inbounds i32, i32* %0, i64 %5
  %7 = load i32, i32* %arrayidx12.1, align 4, !tbaa !0
  %mul.1 = mul nsw i32 %7, %6
  %arrayidx18.1 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Intra, i64 0, i64 %indvars.iv70, i64 1, i64 %indvars.iv67
  store i32 %mul.1, i32* %arrayidx18.1, align 4, !tbaa !0
  %arrayidx26.1 = getelementptr inbounds i32, i32* %1, i64 %5
  %8 = load i32, i32* %arrayidx26.1, align 4, !tbaa !0
  %mul27.1 = mul nsw i32 %8, %6
  %arrayidx33.1 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Inter, i64 0, i64 %indvars.iv70, i64 1, i64 %indvars.iv67
  store i32 %mul27.1, i32* %arrayidx33.1, align 4, !tbaa !0
  %9 = add nuw nsw i64 %indvars.iv67, 16
  %arrayidx10.2 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %dequant_coef8, i64 0, i64 %indvars.iv70, i64 %indvars.iv67, i64 2
  %10 = load i32, i32* %arrayidx10.2, align 8, !tbaa !0
  %arrayidx12.2 = getelementptr inbounds i32, i32* %0, i64 %9
  %11 = load i32, i32* %arrayidx12.2, align 4, !tbaa !0
  %mul.2 = mul nsw i32 %11, %10
  %arrayidx18.2 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Intra, i64 0, i64 %indvars.iv70, i64 2, i64 %indvars.iv67
  store i32 %mul.2, i32* %arrayidx18.2, align 4, !tbaa !0
  %arrayidx26.2 = getelementptr inbounds i32, i32* %1, i64 %9
  %12 = load i32, i32* %arrayidx26.2, align 4, !tbaa !0
  %mul27.2 = mul nsw i32 %12, %10
  %arrayidx33.2 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Inter, i64 0, i64 %indvars.iv70, i64 2, i64 %indvars.iv67
  store i32 %mul27.2, i32* %arrayidx33.2, align 4, !tbaa !0
  %13 = add nuw nsw i64 %indvars.iv67, 24
  %arrayidx10.3 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %dequant_coef8, i64 0, i64 %indvars.iv70, i64 %indvars.iv67, i64 3
  %14 = load i32, i32* %arrayidx10.3, align 4, !tbaa !0
  %arrayidx12.3 = getelementptr inbounds i32, i32* %0, i64 %13
  %15 = load i32, i32* %arrayidx12.3, align 4, !tbaa !0
  %mul.3 = mul nsw i32 %15, %14
  %arrayidx18.3 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Intra, i64 0, i64 %indvars.iv70, i64 3, i64 %indvars.iv67
  store i32 %mul.3, i32* %arrayidx18.3, align 4, !tbaa !0
  %arrayidx26.3 = getelementptr inbounds i32, i32* %1, i64 %13
  %16 = load i32, i32* %arrayidx26.3, align 4, !tbaa !0
  %mul27.3 = mul nsw i32 %16, %14
  %arrayidx33.3 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Inter, i64 0, i64 %indvars.iv70, i64 3, i64 %indvars.iv67
  store i32 %mul27.3, i32* %arrayidx33.3, align 4, !tbaa !0
  %17 = add nuw nsw i64 %indvars.iv67, 32
  %arrayidx10.4 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %dequant_coef8, i64 0, i64 %indvars.iv70, i64 %indvars.iv67, i64 4
  %18 = load i32, i32* %arrayidx10.4, align 16, !tbaa !0
  %arrayidx12.4 = getelementptr inbounds i32, i32* %0, i64 %17
  %19 = load i32, i32* %arrayidx12.4, align 4, !tbaa !0
  %mul.4 = mul nsw i32 %19, %18
  %arrayidx18.4 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Intra, i64 0, i64 %indvars.iv70, i64 4, i64 %indvars.iv67
  store i32 %mul.4, i32* %arrayidx18.4, align 4, !tbaa !0
  %arrayidx26.4 = getelementptr inbounds i32, i32* %1, i64 %17
  %20 = load i32, i32* %arrayidx26.4, align 4, !tbaa !0
  %mul27.4 = mul nsw i32 %20, %18
  %arrayidx33.4 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Inter, i64 0, i64 %indvars.iv70, i64 4, i64 %indvars.iv67
  store i32 %mul27.4, i32* %arrayidx33.4, align 4, !tbaa !0
  %21 = add nuw nsw i64 %indvars.iv67, 40
  %arrayidx10.5 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %dequant_coef8, i64 0, i64 %indvars.iv70, i64 %indvars.iv67, i64 5
  %22 = load i32, i32* %arrayidx10.5, align 4, !tbaa !0
  %arrayidx12.5 = getelementptr inbounds i32, i32* %0, i64 %21
  %23 = load i32, i32* %arrayidx12.5, align 4, !tbaa !0
  %mul.5 = mul nsw i32 %23, %22
  %arrayidx18.5 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Intra, i64 0, i64 %indvars.iv70, i64 5, i64 %indvars.iv67
  store i32 %mul.5, i32* %arrayidx18.5, align 4, !tbaa !0
  %arrayidx26.5 = getelementptr inbounds i32, i32* %1, i64 %21
  %24 = load i32, i32* %arrayidx26.5, align 4, !tbaa !0
  %mul27.5 = mul nsw i32 %24, %22
  %arrayidx33.5 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Inter, i64 0, i64 %indvars.iv70, i64 5, i64 %indvars.iv67
  store i32 %mul27.5, i32* %arrayidx33.5, align 4, !tbaa !0
  %25 = add nuw nsw i64 %indvars.iv67, 48
  %arrayidx10.6 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %dequant_coef8, i64 0, i64 %indvars.iv70, i64 %indvars.iv67, i64 6
  %26 = load i32, i32* %arrayidx10.6, align 8, !tbaa !0
  %arrayidx12.6 = getelementptr inbounds i32, i32* %0, i64 %25
  %27 = load i32, i32* %arrayidx12.6, align 4, !tbaa !0
  %mul.6 = mul nsw i32 %27, %26
  %arrayidx18.6 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Intra, i64 0, i64 %indvars.iv70, i64 6, i64 %indvars.iv67
  store i32 %mul.6, i32* %arrayidx18.6, align 4, !tbaa !0
  %arrayidx26.6 = getelementptr inbounds i32, i32* %1, i64 %25
  %28 = load i32, i32* %arrayidx26.6, align 4, !tbaa !0
  %mul27.6 = mul nsw i32 %28, %26
  %arrayidx33.6 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Inter, i64 0, i64 %indvars.iv70, i64 6, i64 %indvars.iv67
  store i32 %mul27.6, i32* %arrayidx33.6, align 4, !tbaa !0
  %29 = add nuw nsw i64 %indvars.iv67, 56
  %arrayidx10.7 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %dequant_coef8, i64 0, i64 %indvars.iv70, i64 %indvars.iv67, i64 7
  %30 = load i32, i32* %arrayidx10.7, align 4, !tbaa !0
  %arrayidx12.7 = getelementptr inbounds i32, i32* %0, i64 %29
  %31 = load i32, i32* %arrayidx12.7, align 4, !tbaa !0
  %mul.7 = mul nsw i32 %31, %30
  %arrayidx18.7 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Intra, i64 0, i64 %indvars.iv70, i64 7, i64 %indvars.iv67
  store i32 %mul.7, i32* %arrayidx18.7, align 4, !tbaa !0
  %arrayidx26.7 = getelementptr inbounds i32, i32* %1, i64 %29
  %32 = load i32, i32* %arrayidx26.7, align 4, !tbaa !0
  %mul27.7 = mul nsw i32 %32, %30
  %arrayidx33.7 = getelementptr inbounds [6 x [8 x [8 x i32]]], [6 x [8 x [8 x i32]]]* %InvLevelScale8x8Luma_Inter, i64 0, i64 %indvars.iv70, i64 7, i64 %indvars.iv67
  store i32 %mul27.7, i32* %arrayidx33.7, align 4, !tbaa !0
  %indvars.iv.next68 = add nuw nsw i64 %indvars.iv67, 1
  %exitcond69 = icmp eq i64 %indvars.iv.next68, 8
  br i1 %exitcond69, label %for.inc.37, label %for.body.6

for.inc.37:                                       ; preds = %for.body.6
  %indvars.iv.next71 = add nuw nsw i64 %indvars.iv70, 1
  %exitcond72 = icmp eq i64 %indvars.iv.next71, 6
  br i1 %exitcond72, label %for.end.39.exitStub, label %for.cond.1.preheader
}

attributes #0 = { nounwind "polyjit-global-count"="3" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
