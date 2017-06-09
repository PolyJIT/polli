
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/464.h264ref/src/rdopt.c.encode_one_macroblock_for.cond.3507.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @encode_one_macroblock_for.cond.3507.preheader.pjit.scop(i64, i64, i32, i32, [16 x [16 x i32]]* nonnull %rec_resG, [16 x [16 x i32]]* nonnull %rec_resG_8x8, [16 x [16 x i32]]* nonnull %resTrans_R, [16 x [16 x i32]]* nonnull %resTrans_R_8x8, [16 x [16 x i32]]* nonnull %resTrans_B, [16 x [16 x i32]]* nonnull %resTrans_B_8x8, [3 x [16 x [16 x i32]]]* nonnull %mprRGB, [3 x [16 x [16 x i32]]]* nonnull %mprRGB_8x8)  {
newFuncRoot:
  br label %for.cond.3507.preheader

if.end.3566.exitStub:                             ; preds = %if.end.3566.loopexit
  ret void

for.cond.3507.preheader:                          ; preds = %for.inc.3563, %newFuncRoot
  %indvars.iv8944 = phi i64 [ %indvars.iv.next8945, %for.inc.3563 ], [ %0, %newFuncRoot ]
  br label %for.body.3511

for.body.3511:                                    ; preds = %for.body.3511, %for.cond.3507.preheader
  %indvars.iv8940 = phi i64 [ %1, %for.cond.3507.preheader ], [ %indvars.iv.next8941, %for.body.3511 ]
  %arrayidx3515 = getelementptr inbounds [16 x [16 x i32]], [16 x [16 x i32]]* %rec_resG, i64 0, i64 %indvars.iv8940, i64 %indvars.iv8944
  %4 = load i32, i32* %arrayidx3515, align 4, !tbaa !0
  %arrayidx3519 = getelementptr inbounds [16 x [16 x i32]], [16 x [16 x i32]]* %rec_resG_8x8, i64 0, i64 %indvars.iv8940, i64 %indvars.iv8944
  store i32 %4, i32* %arrayidx3519, align 4, !tbaa !0
  %arrayidx3523 = getelementptr inbounds [16 x [16 x i32]], [16 x [16 x i32]]* %resTrans_R, i64 0, i64 %indvars.iv8940, i64 %indvars.iv8944
  %5 = load i32, i32* %arrayidx3523, align 4, !tbaa !0
  %arrayidx3527 = getelementptr inbounds [16 x [16 x i32]], [16 x [16 x i32]]* %resTrans_R_8x8, i64 0, i64 %indvars.iv8940, i64 %indvars.iv8944
  store i32 %5, i32* %arrayidx3527, align 4, !tbaa !0
  %arrayidx3531 = getelementptr inbounds [16 x [16 x i32]], [16 x [16 x i32]]* %resTrans_B, i64 0, i64 %indvars.iv8940, i64 %indvars.iv8944
  %6 = load i32, i32* %arrayidx3531, align 4, !tbaa !0
  %arrayidx3535 = getelementptr inbounds [16 x [16 x i32]], [16 x [16 x i32]]* %resTrans_B_8x8, i64 0, i64 %indvars.iv8940, i64 %indvars.iv8944
  store i32 %6, i32* %arrayidx3535, align 4, !tbaa !0
  %arrayidx3539 = getelementptr inbounds [3 x [16 x [16 x i32]]], [3 x [16 x [16 x i32]]]* %mprRGB, i64 0, i64 0, i64 %indvars.iv8940, i64 %indvars.iv8944
  %7 = load i32, i32* %arrayidx3539, align 4, !tbaa !0
  %arrayidx3543 = getelementptr inbounds [3 x [16 x [16 x i32]]], [3 x [16 x [16 x i32]]]* %mprRGB_8x8, i64 0, i64 0, i64 %indvars.iv8940, i64 %indvars.iv8944
  store i32 %7, i32* %arrayidx3543, align 4, !tbaa !0
  %arrayidx3547 = getelementptr inbounds [3 x [16 x [16 x i32]]], [3 x [16 x [16 x i32]]]* %mprRGB, i64 0, i64 1, i64 %indvars.iv8940, i64 %indvars.iv8944
  %8 = load i32, i32* %arrayidx3547, align 4, !tbaa !0
  %arrayidx3551 = getelementptr inbounds [3 x [16 x [16 x i32]]], [3 x [16 x [16 x i32]]]* %mprRGB_8x8, i64 0, i64 1, i64 %indvars.iv8940, i64 %indvars.iv8944
  store i32 %8, i32* %arrayidx3551, align 4, !tbaa !0
  %arrayidx3555 = getelementptr inbounds [3 x [16 x [16 x i32]]], [3 x [16 x [16 x i32]]]* %mprRGB, i64 0, i64 2, i64 %indvars.iv8940, i64 %indvars.iv8944
  %9 = load i32, i32* %arrayidx3555, align 4, !tbaa !0
  %arrayidx3559 = getelementptr inbounds [3 x [16 x [16 x i32]]], [3 x [16 x [16 x i32]]]* %mprRGB_8x8, i64 0, i64 2, i64 %indvars.iv8940, i64 %indvars.iv8944
  store i32 %9, i32* %arrayidx3559, align 4, !tbaa !0
  %indvars.iv.next8941 = add nsw i64 %indvars.iv8940, 1
  %lftr.wideiv8942 = trunc i64 %indvars.iv.next8941 to i32
  %exitcond8943 = icmp eq i32 %lftr.wideiv8942, %2
  br i1 %exitcond8943, label %for.inc.3563, label %for.body.3511

for.inc.3563:                                     ; preds = %for.body.3511
  %indvars.iv.next8945 = add nsw i64 %indvars.iv8944, 1
  %lftr.wideiv8946 = trunc i64 %indvars.iv.next8945 to i32
  %exitcond8947 = icmp eq i32 %lftr.wideiv8946, %3
  br i1 %exitcond8947, label %if.end.3566.loopexit, label %for.cond.3507.preheader

if.end.3566.loopexit:                             ; preds = %for.inc.3563
  br label %if.end.3566.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="8" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
