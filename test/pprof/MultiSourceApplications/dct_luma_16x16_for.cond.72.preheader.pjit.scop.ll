
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polli-process-unprofitable -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/JM/lencod/block.c.dct_luma_16x16_for.cond.72.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @dct_luma_16x16_for.cond.72.preheader.pjit.scop(i32, i32* %add368.out, [4 x [4 x [4 x [4 x i32]]]]* nonnull %dct_luma_16x16.M0, [4 x [4 x i32]]* nonnull %dct_luma_16x16.M4, i32* nonnull %dct_luma_16x16.M5.0, i32* nonnull %dct_luma_16x16.M5.1, i32* nonnull %dct_luma_16x16.M5.2, i32* nonnull %dct_luma_16x16.M5.3)  {
newFuncRoot:
  br label %for.cond.72.preheader

for.body.348.exitStub:                            ; preds = %for.cond.227.preheader
  store i32 %add368, i32* %add368.out
  ret void

for.cond.72.preheader:                            ; preds = %for.inc.224, %newFuncRoot
  %indvars.iv1773 = phi i64 [ %indvars.iv.next1774, %for.inc.224 ], [ 0, %newFuncRoot ]
  br label %for.body.79

for.body.79:                                      ; preds = %for.body.79, %for.cond.72.preheader
  %indvars.iv1770 = phi i64 [ 0, %for.cond.72.preheader ], [ %indvars.iv.next1771, %for.body.79 ]
  %arrayidx86 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 0, i64 0
  %1 = load i32, i32* %arrayidx86, align 16, !tbaa !0
  %arrayidx93 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 0, i64 3
  %2 = load i32, i32* %arrayidx93, align 4, !tbaa !0
  %add94 = add nsw i32 %2, %1
  %arrayidx101 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 0, i64 1
  %3 = load i32, i32* %arrayidx101, align 4, !tbaa !0
  %arrayidx108 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 0, i64 2
  %4 = load i32, i32* %arrayidx108, align 8, !tbaa !0
  %add109 = add nsw i32 %4, %3
  %sub124 = sub nsw i32 %3, %4
  %5 = load i32, i32* %arrayidx86, align 16, !tbaa !0
  %6 = load i32, i32* %arrayidx93, align 4, !tbaa !0
  %sub139 = sub nsw i32 %5, %6
  %add140 = add nsw i32 %add109, %add94
  %7 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 0
  store i32 %add140, i32* %7
  %sub144 = sub nsw i32 %add94, %add109
  %8 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 2
  store i32 %sub144, i32* %8
  %shl = shl i32 %sub139, 1
  %add148 = add nsw i32 %shl, %sub124
  %9 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 1
  store i32 %add148, i32* %9
  %shl152 = shl i32 %sub124, 1
  %sub153 = sub nsw i32 %sub139, %shl152
  %10 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 3
  store i32 %sub153, i32* %10
  %arrayidx86.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 1, i64 0
  %11 = load i32, i32* %arrayidx86.1, align 16, !tbaa !0
  %arrayidx93.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 1, i64 3
  %12 = load i32, i32* %arrayidx93.1, align 4, !tbaa !0
  %add94.1 = add nsw i32 %12, %11
  %arrayidx101.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 1, i64 1
  %13 = load i32, i32* %arrayidx101.1, align 4, !tbaa !0
  %arrayidx108.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 1, i64 2
  %14 = load i32, i32* %arrayidx108.1, align 8, !tbaa !0
  %add109.1 = add nsw i32 %14, %13
  %sub124.1 = sub nsw i32 %13, %14
  %15 = load i32, i32* %arrayidx86.1, align 16, !tbaa !0
  %16 = load i32, i32* %arrayidx93.1, align 4, !tbaa !0
  %sub139.1 = sub nsw i32 %15, %16
  %add140.1 = add nsw i32 %add109.1, %add94.1
  %17 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 0
  store i32 %add140.1, i32* %17
  %sub144.1 = sub nsw i32 %add94.1, %add109.1
  %18 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 2
  store i32 %sub144.1, i32* %18
  %shl.1 = shl i32 %sub139.1, 1
  %add148.1 = add nsw i32 %shl.1, %sub124.1
  %19 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 1
  store i32 %add148.1, i32* %19
  %shl152.1 = shl i32 %sub124.1, 1
  %sub153.1 = sub nsw i32 %sub139.1, %shl152.1
  %20 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 3
  store i32 %sub153.1, i32* %20
  %arrayidx86.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 2, i64 0
  %21 = load i32, i32* %arrayidx86.2, align 16, !tbaa !0
  %arrayidx93.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 2, i64 3
  %22 = load i32, i32* %arrayidx93.2, align 4, !tbaa !0
  %add94.2 = add nsw i32 %22, %21
  %arrayidx101.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 2, i64 1
  %23 = load i32, i32* %arrayidx101.2, align 4, !tbaa !0
  %arrayidx108.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 2, i64 2
  %24 = load i32, i32* %arrayidx108.2, align 8, !tbaa !0
  %add109.2 = add nsw i32 %24, %23
  %sub124.2 = sub nsw i32 %23, %24
  %25 = load i32, i32* %arrayidx86.2, align 16, !tbaa !0
  %26 = load i32, i32* %arrayidx93.2, align 4, !tbaa !0
  %sub139.2 = sub nsw i32 %25, %26
  %add140.2 = add nsw i32 %add109.2, %add94.2
  %27 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 0
  store i32 %add140.2, i32* %27
  %sub144.2 = sub nsw i32 %add94.2, %add109.2
  %28 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 2
  store i32 %sub144.2, i32* %28
  %shl.2 = shl i32 %sub139.2, 1
  %add148.2 = add nsw i32 %shl.2, %sub124.2
  %29 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 1
  store i32 %add148.2, i32* %29
  %shl152.2 = shl i32 %sub124.2, 1
  %sub153.2 = sub nsw i32 %sub139.2, %shl152.2
  %30 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 3
  store i32 %sub153.2, i32* %30
  %arrayidx86.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 3, i64 0
  %31 = load i32, i32* %arrayidx86.3, align 16, !tbaa !0
  %arrayidx93.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 3, i64 3
  %32 = load i32, i32* %arrayidx93.3, align 4, !tbaa !0
  %add94.3 = add nsw i32 %32, %31
  %arrayidx101.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 3, i64 1
  %33 = load i32, i32* %arrayidx101.3, align 4, !tbaa !0
  %arrayidx108.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 3, i64 2
  %34 = load i32, i32* %arrayidx108.3, align 8, !tbaa !0
  %add109.3 = add nsw i32 %34, %33
  %sub124.3 = sub nsw i32 %33, %34
  %35 = load i32, i32* %arrayidx86.3, align 16, !tbaa !0
  %36 = load i32, i32* %arrayidx93.3, align 4, !tbaa !0
  %sub139.3 = sub nsw i32 %35, %36
  %add140.3 = add nsw i32 %add109.3, %add94.3
  %37 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 0
  store i32 %add140.3, i32* %37
  %sub144.3 = sub nsw i32 %add94.3, %add109.3
  %38 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 2
  store i32 %sub144.3, i32* %38
  %shl.3 = shl i32 %sub139.3, 1
  %add148.3 = add nsw i32 %shl.3, %sub124.3
  %39 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 1
  store i32 %add148.3, i32* %39
  %shl152.3 = shl i32 %sub124.3, 1
  %sub153.3 = sub nsw i32 %sub139.3, %shl152.3
  %40 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 3
  store i32 %sub153.3, i32* %40
  %41 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 0
  %42 = load i32, i32* %41
  %43 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 0
  %44 = load i32, i32* %43
  %add168 = add nsw i32 %44, %42
  %45 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 0
  %46 = load i32, i32* %45
  %47 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 0
  %48 = load i32, i32* %47
  %add173 = add nsw i32 %48, %46
  %sub178 = sub nsw i32 %46, %48
  %49 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 0
  %50 = load i32, i32* %49
  %51 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 0
  %52 = load i32, i32* %51
  %sub183 = sub nsw i32 %50, %52
  %add184 = add nsw i32 %add173, %add168
  %arrayidx191 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 0, i64 0
  store i32 %add184, i32* %arrayidx191, align 16, !tbaa !0
  %sub192 = sub nsw i32 %add168, %add173
  %arrayidx199 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 2, i64 0
  store i32 %sub192, i32* %arrayidx199, align 16, !tbaa !0
  %shl200 = shl i32 %sub183, 1
  %add201 = add nsw i32 %shl200, %sub178
  %arrayidx208 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 1, i64 0
  store i32 %add201, i32* %arrayidx208, align 16, !tbaa !0
  %shl209 = shl i32 %sub178, 1
  %sub210 = sub nsw i32 %sub183, %shl209
  %arrayidx217 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 3, i64 0
  store i32 %sub210, i32* %arrayidx217, align 16, !tbaa !0
  %53 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 1
  %54 = load i32, i32* %53
  %55 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 1
  %56 = load i32, i32* %55
  %add168.1 = add nsw i32 %56, %54
  %57 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 1
  %58 = load i32, i32* %57
  %59 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 1
  %60 = load i32, i32* %59
  %add173.1 = add nsw i32 %60, %58
  %sub178.1 = sub nsw i32 %58, %60
  %61 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 1
  %62 = load i32, i32* %61
  %63 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 1
  %64 = load i32, i32* %63
  %sub183.1 = sub nsw i32 %62, %64
  %add184.1 = add nsw i32 %add173.1, %add168.1
  %arrayidx191.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 0, i64 1
  store i32 %add184.1, i32* %arrayidx191.1, align 4, !tbaa !0
  %sub192.1 = sub nsw i32 %add168.1, %add173.1
  %arrayidx199.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 2, i64 1
  store i32 %sub192.1, i32* %arrayidx199.1, align 4, !tbaa !0
  %shl200.1 = shl i32 %sub183.1, 1
  %add201.1 = add nsw i32 %shl200.1, %sub178.1
  %arrayidx208.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 1, i64 1
  store i32 %add201.1, i32* %arrayidx208.1, align 4, !tbaa !0
  %shl209.1 = shl i32 %sub178.1, 1
  %sub210.1 = sub nsw i32 %sub183.1, %shl209.1
  %arrayidx217.1 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 3, i64 1
  store i32 %sub210.1, i32* %arrayidx217.1, align 4, !tbaa !0
  %65 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 2
  %66 = load i32, i32* %65
  %67 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 2
  %68 = load i32, i32* %67
  %add168.2 = add nsw i32 %68, %66
  %69 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 2
  %70 = load i32, i32* %69
  %71 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 2
  %72 = load i32, i32* %71
  %add173.2 = add nsw i32 %72, %70
  %sub178.2 = sub nsw i32 %70, %72
  %73 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 2
  %74 = load i32, i32* %73
  %75 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 2
  %76 = load i32, i32* %75
  %sub183.2 = sub nsw i32 %74, %76
  %add184.2 = add nsw i32 %add173.2, %add168.2
  %arrayidx191.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 0, i64 2
  store i32 %add184.2, i32* %arrayidx191.2, align 8, !tbaa !0
  %sub192.2 = sub nsw i32 %add168.2, %add173.2
  %arrayidx199.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 2, i64 2
  store i32 %sub192.2, i32* %arrayidx199.2, align 8, !tbaa !0
  %shl200.2 = shl i32 %sub183.2, 1
  %add201.2 = add nsw i32 %shl200.2, %sub178.2
  %arrayidx208.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 1, i64 2
  store i32 %add201.2, i32* %arrayidx208.2, align 8, !tbaa !0
  %shl209.2 = shl i32 %sub178.2, 1
  %sub210.2 = sub nsw i32 %sub183.2, %shl209.2
  %arrayidx217.2 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 3, i64 2
  store i32 %sub210.2, i32* %arrayidx217.2, align 8, !tbaa !0
  %77 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 3
  %78 = load i32, i32* %77
  %79 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 3
  %80 = load i32, i32* %79
  %add168.3 = add nsw i32 %80, %78
  %81 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 3
  %82 = load i32, i32* %81
  %83 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 3
  %84 = load i32, i32* %83
  %add173.3 = add nsw i32 %84, %82
  %sub178.3 = sub nsw i32 %82, %84
  %85 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 3
  %86 = load i32, i32* %85
  %87 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 3
  %88 = load i32, i32* %87
  %sub183.3 = sub nsw i32 %86, %88
  %add184.3 = add nsw i32 %add173.3, %add168.3
  %arrayidx191.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 0, i64 3
  store i32 %add184.3, i32* %arrayidx191.3, align 4, !tbaa !0
  %sub192.3 = sub nsw i32 %add168.3, %add173.3
  %arrayidx199.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 2, i64 3
  store i32 %sub192.3, i32* %arrayidx199.3, align 4, !tbaa !0
  %shl200.3 = shl i32 %sub183.3, 1
  %add201.3 = add nsw i32 %shl200.3, %sub178.3
  %arrayidx208.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 1, i64 3
  store i32 %add201.3, i32* %arrayidx208.3, align 4, !tbaa !0
  %shl209.3 = shl i32 %sub178.3, 1
  %sub210.3 = sub nsw i32 %sub183.3, %shl209.3
  %arrayidx217.3 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 %indvars.iv1773, i64 %indvars.iv1770, i64 3, i64 3
  store i32 %sub210.3, i32* %arrayidx217.3, align 4, !tbaa !0
  %indvars.iv.next1771 = add nuw nsw i64 %indvars.iv1770, 1
  %exitcond1772 = icmp eq i64 %indvars.iv.next1771, 4
  br i1 %exitcond1772, label %for.inc.224, label %for.body.79

for.inc.224:                                      ; preds = %for.body.79
  %sub183.3.lcssa = phi i32 [ %sub183.3, %for.body.79 ]
  %sub178.3.lcssa = phi i32 [ %sub178.3, %for.body.79 ]
  %add173.3.lcssa = phi i32 [ %add173.3, %for.body.79 ]
  %add168.3.lcssa = phi i32 [ %add168.3, %for.body.79 ]
  %indvars.iv.next1774 = add nuw nsw i64 %indvars.iv1773, 1
  %exitcond1775 = icmp eq i64 %indvars.iv.next1774, 4
  br i1 %exitcond1775, label %for.cond.227.preheader, label %for.cond.72.preheader

for.cond.227.preheader:                           ; preds = %for.inc.224
  %sub183.3.lcssa.lcssa = phi i32 [ %sub183.3.lcssa, %for.inc.224 ]
  %sub178.3.lcssa.lcssa = phi i32 [ %sub178.3.lcssa, %for.inc.224 ]
  %add173.3.lcssa.lcssa = phi i32 [ %add173.3.lcssa, %for.inc.224 ]
  %add168.3.lcssa.lcssa = phi i32 [ %add168.3.lcssa, %for.inc.224 ]
  store i32 %add168.3.lcssa.lcssa, i32* %dct_luma_16x16.M5.0, align 16, !tbaa !0
  store i32 %add173.3.lcssa.lcssa, i32* %dct_luma_16x16.M5.1, align 4, !tbaa !0
  store i32 %sub178.3.lcssa.lcssa, i32* %dct_luma_16x16.M5.2, align 8, !tbaa !0
  store i32 %sub183.3.lcssa.lcssa, i32* %dct_luma_16x16.M5.3, align 4, !tbaa !0
  %89 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 0, i64 0, i64 0, i64 0
  %90 = load i32, i32* %89
  %91 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 0
  store i32 %90, i32* %91
  %92 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 0, i64 1, i64 0, i64 0
  %93 = load i32, i32* %92
  %94 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 1
  store i32 %93, i32* %94
  %95 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 0, i64 2, i64 0, i64 0
  %96 = load i32, i32* %95
  %97 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 2
  store i32 %96, i32* %97
  %98 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 0, i64 3, i64 0, i64 0
  %99 = load i32, i32* %98
  %100 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 3
  store i32 %99, i32* %100
  %101 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 1, i64 0, i64 0, i64 0
  %102 = load i32, i32* %101
  %103 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 0
  store i32 %102, i32* %103
  %104 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 1, i64 1, i64 0, i64 0
  %105 = load i32, i32* %104
  %106 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 1
  store i32 %105, i32* %106
  %107 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 1, i64 2, i64 0, i64 0
  %108 = load i32, i32* %107
  %109 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 2
  store i32 %108, i32* %109
  %110 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 1, i64 3, i64 0, i64 0
  %111 = load i32, i32* %110
  %112 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 3
  store i32 %111, i32* %112
  %113 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 2, i64 0, i64 0, i64 0
  %114 = load i32, i32* %113
  %115 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 0
  store i32 %114, i32* %115
  %116 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 2, i64 1, i64 0, i64 0
  %117 = load i32, i32* %116
  %118 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 1
  store i32 %117, i32* %118
  %119 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 2, i64 2, i64 0, i64 0
  %120 = load i32, i32* %119
  %121 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 2
  store i32 %120, i32* %121
  %122 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 2, i64 3, i64 0, i64 0
  %123 = load i32, i32* %122
  %124 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 3
  store i32 %123, i32* %124
  %125 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 3, i64 0, i64 0, i64 0
  %126 = load i32, i32* %125
  %127 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 0
  store i32 %126, i32* %127
  %128 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 3, i64 1, i64 0, i64 0
  %129 = load i32, i32* %128
  %130 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 1
  store i32 %129, i32* %130
  %131 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 3, i64 2, i64 0, i64 0
  %132 = load i32, i32* %131
  %133 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 2
  store i32 %132, i32* %133
  %134 = getelementptr inbounds [4 x [4 x [4 x [4 x i32]]]], [4 x [4 x [4 x [4 x i32]]]]* %dct_luma_16x16.M0, i64 0, i64 3, i64 3, i64 0, i64 0
  %135 = load i32, i32* %134
  %136 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 3
  store i32 %135, i32* %136
  %137 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 0
  %138 = load i32, i32* %137
  %139 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 3
  %140 = load i32, i32* %139
  %add261 = add nsw i32 %140, %138
  %141 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 1
  %142 = load i32, i32* %141
  %143 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 2
  %144 = load i32, i32* %143
  %add268 = add nsw i32 %144, %142
  %sub275 = sub nsw i32 %142, %144
  %145 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 0
  %146 = load i32, i32* %145
  %147 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 3
  %148 = load i32, i32* %147
  %sub282 = sub nsw i32 %146, %148
  %add283 = add nsw i32 %add268, %add261
  %149 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 0
  store i32 %add283, i32* %149
  %sub287 = sub nsw i32 %add261, %add268
  %150 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 2
  store i32 %sub287, i32* %150
  %add291 = add nsw i32 %sub282, %sub275
  %151 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 1
  store i32 %add291, i32* %151
  %sub295 = sub nsw i32 %sub282, %sub275
  %152 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 3
  store i32 %sub295, i32* %152
  %153 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 0
  %154 = load i32, i32* %153
  %155 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 3
  %156 = load i32, i32* %155
  %add261.1 = add nsw i32 %156, %154
  %157 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 1
  %158 = load i32, i32* %157
  %159 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 2
  %160 = load i32, i32* %159
  %add268.1 = add nsw i32 %160, %158
  %sub275.1 = sub nsw i32 %158, %160
  %161 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 0
  %162 = load i32, i32* %161
  %163 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 3
  %164 = load i32, i32* %163
  %sub282.1 = sub nsw i32 %162, %164
  %add283.1 = add nsw i32 %add268.1, %add261.1
  %165 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 0
  store i32 %add283.1, i32* %165
  %sub287.1 = sub nsw i32 %add261.1, %add268.1
  %166 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 2
  store i32 %sub287.1, i32* %166
  %add291.1 = add nsw i32 %sub282.1, %sub275.1
  %167 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 1
  store i32 %add291.1, i32* %167
  %sub295.1 = sub nsw i32 %sub282.1, %sub275.1
  %168 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 3
  store i32 %sub295.1, i32* %168
  %169 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 0
  %170 = load i32, i32* %169
  %171 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 3
  %172 = load i32, i32* %171
  %add261.2 = add nsw i32 %172, %170
  %173 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 1
  %174 = load i32, i32* %173
  %175 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 2
  %176 = load i32, i32* %175
  %add268.2 = add nsw i32 %176, %174
  %sub275.2 = sub nsw i32 %174, %176
  %177 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 0
  %178 = load i32, i32* %177
  %179 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 3
  %180 = load i32, i32* %179
  %sub282.2 = sub nsw i32 %178, %180
  %add283.2 = add nsw i32 %add268.2, %add261.2
  %181 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 0
  store i32 %add283.2, i32* %181
  %sub287.2 = sub nsw i32 %add261.2, %add268.2
  %182 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 2
  store i32 %sub287.2, i32* %182
  %add291.2 = add nsw i32 %sub282.2, %sub275.2
  %183 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 1
  store i32 %add291.2, i32* %183
  %sub295.2 = sub nsw i32 %sub282.2, %sub275.2
  %184 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 3
  store i32 %sub295.2, i32* %184
  %185 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 0
  %186 = load i32, i32* %185
  %187 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 3
  %188 = load i32, i32* %187
  %add261.3 = add nsw i32 %188, %186
  %189 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 1
  %190 = load i32, i32* %189
  %191 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 2
  %192 = load i32, i32* %191
  %add268.3 = add nsw i32 %192, %190
  %sub275.3 = sub nsw i32 %190, %192
  %193 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 0
  %194 = load i32, i32* %193
  %195 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 3
  %196 = load i32, i32* %195
  %sub282.3 = sub nsw i32 %194, %196
  %add283.3 = add nsw i32 %add268.3, %add261.3
  %197 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 0
  store i32 %add283.3, i32* %197
  %sub287.3 = sub nsw i32 %add261.3, %add268.3
  %198 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 2
  store i32 %sub287.3, i32* %198
  %add291.3 = add nsw i32 %sub282.3, %sub275.3
  %199 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 1
  store i32 %add291.3, i32* %199
  %sub295.3 = sub nsw i32 %sub282.3, %sub275.3
  %200 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 3
  store i32 %sub295.3, i32* %200
  store i32 %add261.3, i32* %dct_luma_16x16.M5.0, align 16, !tbaa !0
  store i32 %add268.3, i32* %dct_luma_16x16.M5.1, align 4, !tbaa !0
  store i32 %sub275.3, i32* %dct_luma_16x16.M5.2, align 8, !tbaa !0
  store i32 %sub282.3, i32* %dct_luma_16x16.M5.3, align 4, !tbaa !0
  %201 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 0
  %202 = load i32, i32* %201
  %203 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 0
  %204 = load i32, i32* %203
  %add310 = add nsw i32 %204, %202
  %205 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 0
  %206 = load i32, i32* %205
  %207 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 0
  %208 = load i32, i32* %207
  %add315 = add nsw i32 %208, %206
  %sub320 = sub nsw i32 %206, %208
  %209 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 0
  %210 = load i32, i32* %209
  %211 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 0
  %212 = load i32, i32* %211
  %sub325 = sub nsw i32 %210, %212
  %add326 = add nsw i32 %add315, %add310
  %shr327 = ashr i32 %add326, 1
  %213 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 0
  store i32 %shr327, i32* %213
  %sub330 = sub nsw i32 %add310, %add315
  %shr331 = ashr i32 %sub330, 1
  %214 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 0
  store i32 %shr331, i32* %214
  %add334 = add nsw i32 %sub325, %sub320
  %shr335 = ashr i32 %add334, 1
  %215 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 0
  store i32 %shr335, i32* %215
  %sub338 = sub nsw i32 %sub325, %sub320
  %shr339 = ashr i32 %sub338, 1
  %216 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 0
  store i32 %shr339, i32* %216
  %217 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 1
  %218 = load i32, i32* %217
  %219 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 1
  %220 = load i32, i32* %219
  %add310.1 = add nsw i32 %220, %218
  %221 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 1
  %222 = load i32, i32* %221
  %223 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 1
  %224 = load i32, i32* %223
  %add315.1 = add nsw i32 %224, %222
  %sub320.1 = sub nsw i32 %222, %224
  %225 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 1
  %226 = load i32, i32* %225
  %227 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 1
  %228 = load i32, i32* %227
  %sub325.1 = sub nsw i32 %226, %228
  %add326.1 = add nsw i32 %add315.1, %add310.1
  %shr327.1 = ashr i32 %add326.1, 1
  %229 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 1
  store i32 %shr327.1, i32* %229
  %sub330.1 = sub nsw i32 %add310.1, %add315.1
  %shr331.1 = ashr i32 %sub330.1, 1
  %230 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 1
  store i32 %shr331.1, i32* %230
  %add334.1 = add nsw i32 %sub325.1, %sub320.1
  %shr335.1 = ashr i32 %add334.1, 1
  %231 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 1
  store i32 %shr335.1, i32* %231
  %sub338.1 = sub nsw i32 %sub325.1, %sub320.1
  %shr339.1 = ashr i32 %sub338.1, 1
  %232 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 1
  store i32 %shr339.1, i32* %232
  %233 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 2
  %234 = load i32, i32* %233
  %235 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 2
  %236 = load i32, i32* %235
  %add310.2 = add nsw i32 %236, %234
  %237 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 2
  %238 = load i32, i32* %237
  %239 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 2
  %240 = load i32, i32* %239
  %add315.2 = add nsw i32 %240, %238
  %sub320.2 = sub nsw i32 %238, %240
  %241 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 2
  %242 = load i32, i32* %241
  %243 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 2
  %244 = load i32, i32* %243
  %sub325.2 = sub nsw i32 %242, %244
  %add326.2 = add nsw i32 %add315.2, %add310.2
  %shr327.2 = ashr i32 %add326.2, 1
  %245 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 2
  store i32 %shr327.2, i32* %245
  %sub330.2 = sub nsw i32 %add310.2, %add315.2
  %shr331.2 = ashr i32 %sub330.2, 1
  %246 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 2
  store i32 %shr331.2, i32* %246
  %add334.2 = add nsw i32 %sub325.2, %sub320.2
  %shr335.2 = ashr i32 %add334.2, 1
  %247 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 2
  store i32 %shr335.2, i32* %247
  %sub338.2 = sub nsw i32 %sub325.2, %sub320.2
  %shr339.2 = ashr i32 %sub338.2, 1
  %248 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 2
  store i32 %shr339.2, i32* %248
  %249 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 3
  %250 = load i32, i32* %249
  %251 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 3
  %252 = load i32, i32* %251
  %add310.3 = add nsw i32 %252, %250
  %253 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 3
  %254 = load i32, i32* %253
  %255 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 3
  %256 = load i32, i32* %255
  %add315.3 = add nsw i32 %256, %254
  %sub320.3 = sub nsw i32 %254, %256
  %257 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 3
  %258 = load i32, i32* %257
  %259 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 3
  %260 = load i32, i32* %259
  %sub325.3 = sub nsw i32 %258, %260
  %add326.3 = add nsw i32 %add315.3, %add310.3
  %shr327.3 = ashr i32 %add326.3, 1
  %261 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 0, i64 3
  store i32 %shr327.3, i32* %261
  %sub330.3 = sub nsw i32 %add310.3, %add315.3
  %shr331.3 = ashr i32 %sub330.3, 1
  %262 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 2, i64 3
  store i32 %shr331.3, i32* %262
  %add334.3 = add nsw i32 %sub325.3, %sub320.3
  %shr335.3 = ashr i32 %add334.3, 1
  %263 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 1, i64 3
  store i32 %shr335.3, i32* %263
  %sub338.3 = sub nsw i32 %sub325.3, %sub320.3
  %shr339.3 = ashr i32 %sub338.3, 1
  %264 = getelementptr inbounds [4 x [4 x i32]], [4 x [4 x i32]]* %dct_luma_16x16.M4, i64 0, i64 3, i64 3
  store i32 %shr339.3, i32* %264
  store i32 %add310.3, i32* %dct_luma_16x16.M5.0, align 16, !tbaa !0
  store i32 %add315.3, i32* %dct_luma_16x16.M5.1, align 4, !tbaa !0
  store i32 %sub320.3, i32* %dct_luma_16x16.M5.2, align 8, !tbaa !0
  store i32 %sub325.3, i32* %dct_luma_16x16.M5.3, align 4, !tbaa !0
  %add368 = add nsw i32 %0, 16
  br label %for.body.348.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="6" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
