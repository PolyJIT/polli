
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polli-process-unprofitable -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/JM/ldecod/block.c.CalculateQuantParam_for.cond.1.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @CalculateQuantParam_for.cond.1.preheader.pjit.scop(i32*, i32*, i32*, i32*, i32*, i32*, [6 x [4 x [4 x i32]]]* nonnull %dequant_coef, [6 x [4 x [4 x i32]]]* nonnull %InvLevelScale4x4Luma_Intra, [2 x [6 x [4 x [4 x i32]]]]* nonnull %InvLevelScale4x4Chroma_Intra, [6 x [4 x [4 x i32]]]* nonnull %InvLevelScale4x4Luma_Inter, [2 x [6 x [4 x [4 x i32]]]]* nonnull %InvLevelScale4x4Chroma_Inter)  {
newFuncRoot:
  br label %for.cond.1.preheader

for.end.99.exitStub:                              ; preds = %for.inc.97
  ret void

for.cond.1.preheader:                             ; preds = %for.inc.97, %newFuncRoot
  %indvars.iv158 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next159, %for.inc.97 ]
  br label %for.body.6

for.body.6:                                       ; preds = %for.body.6, %for.cond.1.preheader
  %indvars.iv155 = phi i64 [ 0, %for.cond.1.preheader ], [ %indvars.iv.next156, %for.body.6 ]
  %arrayidx10 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %dequant_coef, i64 0, i64 %indvars.iv158, i64 %indvars.iv155, i64 0
  %6 = load i32, i32* %arrayidx10, align 16, !tbaa !0
  %arrayidx12 = getelementptr inbounds i32, i32* %0, i64 %indvars.iv155
  %7 = load i32, i32* %arrayidx12, align 4, !tbaa !0
  %mul = mul nsw i32 %7, %6
  %arrayidx18 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %InvLevelScale4x4Luma_Intra, i64 0, i64 %indvars.iv158, i64 0, i64 %indvars.iv155
  store i32 %mul, i32* %arrayidx18, align 4, !tbaa !0
  %arrayidx26 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv155
  %8 = load i32, i32* %arrayidx26, align 4, !tbaa !0
  %mul27 = mul nsw i32 %8, %6
  %arrayidx33 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Intra, i64 0, i64 0, i64 %indvars.iv158, i64 0, i64 %indvars.iv155
  store i32 %mul27, i32* %arrayidx33, align 4, !tbaa !0
  %arrayidx41 = getelementptr inbounds i32, i32* %2, i64 %indvars.iv155
  %9 = load i32, i32* %arrayidx41, align 4, !tbaa !0
  %mul42 = mul nsw i32 %9, %6
  %arrayidx48 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Intra, i64 0, i64 1, i64 %indvars.iv158, i64 0, i64 %indvars.iv155
  store i32 %mul42, i32* %arrayidx48, align 4, !tbaa !0
  %10 = load i32, i32* %arrayidx10, align 16, !tbaa !0
  %arrayidx56 = getelementptr inbounds i32, i32* %3, i64 %indvars.iv155
  %11 = load i32, i32* %arrayidx56, align 4, !tbaa !0
  %mul57 = mul nsw i32 %11, %10
  %arrayidx63 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %InvLevelScale4x4Luma_Inter, i64 0, i64 %indvars.iv158, i64 0, i64 %indvars.iv155
  store i32 %mul57, i32* %arrayidx63, align 4, !tbaa !0
  %arrayidx71 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv155
  %12 = load i32, i32* %arrayidx71, align 4, !tbaa !0
  %mul72 = mul nsw i32 %12, %10
  %arrayidx78 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Inter, i64 0, i64 0, i64 %indvars.iv158, i64 0, i64 %indvars.iv155
  store i32 %mul72, i32* %arrayidx78, align 4, !tbaa !0
  %13 = load i32, i32* %arrayidx10, align 16, !tbaa !0
  %arrayidx86 = getelementptr inbounds i32, i32* %5, i64 %indvars.iv155
  %14 = load i32, i32* %arrayidx86, align 4, !tbaa !0
  %mul87 = mul nsw i32 %14, %13
  %arrayidx93 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Inter, i64 0, i64 1, i64 %indvars.iv158, i64 0, i64 %indvars.iv155
  store i32 %mul87, i32* %arrayidx93, align 4, !tbaa !0
  %15 = add nuw nsw i64 %indvars.iv155, 4
  %arrayidx10.1 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %dequant_coef, i64 0, i64 %indvars.iv158, i64 %indvars.iv155, i64 1
  %16 = load i32, i32* %arrayidx10.1, align 4, !tbaa !0
  %arrayidx12.1 = getelementptr inbounds i32, i32* %0, i64 %15
  %17 = load i32, i32* %arrayidx12.1, align 4, !tbaa !0
  %mul.1 = mul nsw i32 %17, %16
  %arrayidx18.1 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %InvLevelScale4x4Luma_Intra, i64 0, i64 %indvars.iv158, i64 1, i64 %indvars.iv155
  store i32 %mul.1, i32* %arrayidx18.1, align 4, !tbaa !0
  %arrayidx26.1 = getelementptr inbounds i32, i32* %1, i64 %15
  %18 = load i32, i32* %arrayidx26.1, align 4, !tbaa !0
  %mul27.1 = mul nsw i32 %18, %16
  %arrayidx33.1 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Intra, i64 0, i64 0, i64 %indvars.iv158, i64 1, i64 %indvars.iv155
  store i32 %mul27.1, i32* %arrayidx33.1, align 4, !tbaa !0
  %arrayidx41.1 = getelementptr inbounds i32, i32* %2, i64 %15
  %19 = load i32, i32* %arrayidx41.1, align 4, !tbaa !0
  %mul42.1 = mul nsw i32 %19, %16
  %arrayidx48.1 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Intra, i64 0, i64 1, i64 %indvars.iv158, i64 1, i64 %indvars.iv155
  store i32 %mul42.1, i32* %arrayidx48.1, align 4, !tbaa !0
  %20 = load i32, i32* %arrayidx10.1, align 4, !tbaa !0
  %arrayidx56.1 = getelementptr inbounds i32, i32* %3, i64 %15
  %21 = load i32, i32* %arrayidx56.1, align 4, !tbaa !0
  %mul57.1 = mul nsw i32 %21, %20
  %arrayidx63.1 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %InvLevelScale4x4Luma_Inter, i64 0, i64 %indvars.iv158, i64 1, i64 %indvars.iv155
  store i32 %mul57.1, i32* %arrayidx63.1, align 4, !tbaa !0
  %arrayidx71.1 = getelementptr inbounds i32, i32* %4, i64 %15
  %22 = load i32, i32* %arrayidx71.1, align 4, !tbaa !0
  %mul72.1 = mul nsw i32 %22, %20
  %arrayidx78.1 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Inter, i64 0, i64 0, i64 %indvars.iv158, i64 1, i64 %indvars.iv155
  store i32 %mul72.1, i32* %arrayidx78.1, align 4, !tbaa !0
  %23 = load i32, i32* %arrayidx10.1, align 4, !tbaa !0
  %arrayidx86.1 = getelementptr inbounds i32, i32* %5, i64 %15
  %24 = load i32, i32* %arrayidx86.1, align 4, !tbaa !0
  %mul87.1 = mul nsw i32 %24, %23
  %arrayidx93.1 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Inter, i64 0, i64 1, i64 %indvars.iv158, i64 1, i64 %indvars.iv155
  store i32 %mul87.1, i32* %arrayidx93.1, align 4, !tbaa !0
  %25 = add nuw nsw i64 %indvars.iv155, 8
  %arrayidx10.2 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %dequant_coef, i64 0, i64 %indvars.iv158, i64 %indvars.iv155, i64 2
  %26 = load i32, i32* %arrayidx10.2, align 8, !tbaa !0
  %arrayidx12.2 = getelementptr inbounds i32, i32* %0, i64 %25
  %27 = load i32, i32* %arrayidx12.2, align 4, !tbaa !0
  %mul.2 = mul nsw i32 %27, %26
  %arrayidx18.2 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %InvLevelScale4x4Luma_Intra, i64 0, i64 %indvars.iv158, i64 2, i64 %indvars.iv155
  store i32 %mul.2, i32* %arrayidx18.2, align 4, !tbaa !0
  %arrayidx26.2 = getelementptr inbounds i32, i32* %1, i64 %25
  %28 = load i32, i32* %arrayidx26.2, align 4, !tbaa !0
  %mul27.2 = mul nsw i32 %28, %26
  %arrayidx33.2 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Intra, i64 0, i64 0, i64 %indvars.iv158, i64 2, i64 %indvars.iv155
  store i32 %mul27.2, i32* %arrayidx33.2, align 4, !tbaa !0
  %arrayidx41.2 = getelementptr inbounds i32, i32* %2, i64 %25
  %29 = load i32, i32* %arrayidx41.2, align 4, !tbaa !0
  %mul42.2 = mul nsw i32 %29, %26
  %arrayidx48.2 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Intra, i64 0, i64 1, i64 %indvars.iv158, i64 2, i64 %indvars.iv155
  store i32 %mul42.2, i32* %arrayidx48.2, align 4, !tbaa !0
  %30 = load i32, i32* %arrayidx10.2, align 8, !tbaa !0
  %arrayidx56.2 = getelementptr inbounds i32, i32* %3, i64 %25
  %31 = load i32, i32* %arrayidx56.2, align 4, !tbaa !0
  %mul57.2 = mul nsw i32 %31, %30
  %arrayidx63.2 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %InvLevelScale4x4Luma_Inter, i64 0, i64 %indvars.iv158, i64 2, i64 %indvars.iv155
  store i32 %mul57.2, i32* %arrayidx63.2, align 4, !tbaa !0
  %arrayidx71.2 = getelementptr inbounds i32, i32* %4, i64 %25
  %32 = load i32, i32* %arrayidx71.2, align 4, !tbaa !0
  %mul72.2 = mul nsw i32 %32, %30
  %arrayidx78.2 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Inter, i64 0, i64 0, i64 %indvars.iv158, i64 2, i64 %indvars.iv155
  store i32 %mul72.2, i32* %arrayidx78.2, align 4, !tbaa !0
  %33 = load i32, i32* %arrayidx10.2, align 8, !tbaa !0
  %arrayidx86.2 = getelementptr inbounds i32, i32* %5, i64 %25
  %34 = load i32, i32* %arrayidx86.2, align 4, !tbaa !0
  %mul87.2 = mul nsw i32 %34, %33
  %arrayidx93.2 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Inter, i64 0, i64 1, i64 %indvars.iv158, i64 2, i64 %indvars.iv155
  store i32 %mul87.2, i32* %arrayidx93.2, align 4, !tbaa !0
  %35 = add nuw nsw i64 %indvars.iv155, 12
  %arrayidx10.3 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %dequant_coef, i64 0, i64 %indvars.iv158, i64 %indvars.iv155, i64 3
  %36 = load i32, i32* %arrayidx10.3, align 4, !tbaa !0
  %arrayidx12.3 = getelementptr inbounds i32, i32* %0, i64 %35
  %37 = load i32, i32* %arrayidx12.3, align 4, !tbaa !0
  %mul.3 = mul nsw i32 %37, %36
  %arrayidx18.3 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %InvLevelScale4x4Luma_Intra, i64 0, i64 %indvars.iv158, i64 3, i64 %indvars.iv155
  store i32 %mul.3, i32* %arrayidx18.3, align 4, !tbaa !0
  %arrayidx26.3 = getelementptr inbounds i32, i32* %1, i64 %35
  %38 = load i32, i32* %arrayidx26.3, align 4, !tbaa !0
  %mul27.3 = mul nsw i32 %38, %36
  %arrayidx33.3 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Intra, i64 0, i64 0, i64 %indvars.iv158, i64 3, i64 %indvars.iv155
  store i32 %mul27.3, i32* %arrayidx33.3, align 4, !tbaa !0
  %arrayidx41.3 = getelementptr inbounds i32, i32* %2, i64 %35
  %39 = load i32, i32* %arrayidx41.3, align 4, !tbaa !0
  %mul42.3 = mul nsw i32 %39, %36
  %arrayidx48.3 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Intra, i64 0, i64 1, i64 %indvars.iv158, i64 3, i64 %indvars.iv155
  store i32 %mul42.3, i32* %arrayidx48.3, align 4, !tbaa !0
  %40 = load i32, i32* %arrayidx10.3, align 4, !tbaa !0
  %arrayidx56.3 = getelementptr inbounds i32, i32* %3, i64 %35
  %41 = load i32, i32* %arrayidx56.3, align 4, !tbaa !0
  %mul57.3 = mul nsw i32 %41, %40
  %arrayidx63.3 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %InvLevelScale4x4Luma_Inter, i64 0, i64 %indvars.iv158, i64 3, i64 %indvars.iv155
  store i32 %mul57.3, i32* %arrayidx63.3, align 4, !tbaa !0
  %arrayidx71.3 = getelementptr inbounds i32, i32* %4, i64 %35
  %42 = load i32, i32* %arrayidx71.3, align 4, !tbaa !0
  %mul72.3 = mul nsw i32 %42, %40
  %arrayidx78.3 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Inter, i64 0, i64 0, i64 %indvars.iv158, i64 3, i64 %indvars.iv155
  store i32 %mul72.3, i32* %arrayidx78.3, align 4, !tbaa !0
  %43 = load i32, i32* %arrayidx10.3, align 4, !tbaa !0
  %arrayidx86.3 = getelementptr inbounds i32, i32* %5, i64 %35
  %44 = load i32, i32* %arrayidx86.3, align 4, !tbaa !0
  %mul87.3 = mul nsw i32 %44, %43
  %arrayidx93.3 = getelementptr inbounds [2 x [6 x [4 x [4 x i32]]]], [2 x [6 x [4 x [4 x i32]]]]* %InvLevelScale4x4Chroma_Inter, i64 0, i64 1, i64 %indvars.iv158, i64 3, i64 %indvars.iv155
  store i32 %mul87.3, i32* %arrayidx93.3, align 4, !tbaa !0
  %indvars.iv.next156 = add nuw nsw i64 %indvars.iv155, 1
  %exitcond157 = icmp eq i64 %indvars.iv.next156, 4
  br i1 %exitcond157, label %for.inc.97, label %for.body.6

for.inc.97:                                       ; preds = %for.body.6
  %indvars.iv.next159 = add nuw nsw i64 %indvars.iv158, 1
  %exitcond160 = icmp eq i64 %indvars.iv.next159, 6
  br i1 %exitcond160, label %for.end.99.exitStub, label %for.cond.1.preheader
}

attributes #0 = { nounwind "polyjit-global-count"="5" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
