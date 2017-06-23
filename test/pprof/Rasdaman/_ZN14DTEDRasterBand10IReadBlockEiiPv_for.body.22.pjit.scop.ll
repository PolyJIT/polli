
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'dteddataset.cpp._ZN14DTEDRasterBand10IReadBlockEiiPv_for.body.22.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZN14DTEDRasterBand10IReadBlockEiiPv_for.body.22.pjit.scop(i32 %sub25, i32, i16* %add.ptr24, i16*, i1 %cmp35.143, i64, i64, i64)  {
newFuncRoot:
  br label %for.body.22

for.inc.51.loopexit.exitStub:                     ; preds = %for.cond.cleanup.36
  ret void

for.body.22:                                      ; preds = %for.cond.cleanup.36, %newFuncRoot
  %indvars.iv157 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next158, %for.cond.cleanup.36 ]
  %5 = trunc i64 %indvars.iv157 to i32
  %sub26 = sub i32 %sub25, %5
  %mul28 = mul nsw i32 %sub26, %0
  %idx.ext29 = sext i32 %mul28 to i64
  %add.ptr30 = getelementptr inbounds i16, i16* %add.ptr24, i64 %idx.ext29
  %add.ptr32 = getelementptr inbounds i16, i16* %1, i64 %indvars.iv157
  br i1 %cmp35.143, label %for.body.37.preheader, label %for.cond.cleanup.36

for.body.37.preheader:                            ; preds = %for.body.22
  br label %for.body.37

for.body.37:                                      ; preds = %for.body.37, %for.body.37.preheader
  %indvars.iv154 = phi i64 [ %indvars.iv.next155, %for.body.37 ], [ 0, %for.body.37.preheader ]
  %6 = mul nsw i64 %indvars.iv154, %2
  %arrayidx = getelementptr inbounds i16, i16* %add.ptr32, i64 %6
  %7 = load i16, i16* %arrayidx, align 2, !tbaa !0
  %arrayidx40 = getelementptr inbounds i16, i16* %add.ptr30, i64 %indvars.iv154
  store i16 %7, i16* %arrayidx40, align 2, !tbaa !0
  %indvars.iv.next155 = add nuw nsw i64 %indvars.iv154, 1
  %cmp35 = icmp slt i64 %indvars.iv.next155, %3
  br i1 %cmp35, label %for.body.37, label %for.cond.cleanup.36.loopexit

for.cond.cleanup.36.loopexit:                     ; preds = %for.body.37
  br label %for.cond.cleanup.36

for.cond.cleanup.36:                              ; preds = %for.cond.cleanup.36.loopexit, %for.body.22
  %indvars.iv.next158 = add nuw nsw i64 %indvars.iv157, 1
  %cmp20 = icmp slt i64 %indvars.iv.next158, %4
  br i1 %cmp20, label %for.body.22, label %for.inc.51.loopexit.exitStub
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"short", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
