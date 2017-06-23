
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'thinplatespline.cpp._ZN17VizGeorefSpline2D5solveEv_for.cond.139.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZN17VizGeorefSpline2D5solveEv_for.cond.139.preheader.i.pjit.scop(i1 %cmp2.309.i, i32, double*, double*)  {
newFuncRoot:
  br label %for.cond.139.preheader.i

_ZL12matrixInvertiPdS_.exit.exitStub:             ; preds = %_ZL12matrixInvertiPdS_.exit.loopexit, %for.cond.139.preheader.i
  ret void

for.cond.139.preheader.i:                         ; preds = %newFuncRoot
  br i1 %cmp2.309.i, label %for.cond.142.preheader.lr.ph.i, label %_ZL12matrixInvertiPdS_.exit.exitStub

for.cond.142.preheader.lr.ph.i:                   ; preds = %for.cond.139.preheader.i
  %mul145.i = shl i32 %0, 1
  %3 = sext i32 %0 to i64
  br label %for.body.144.lr.ph.i

for.body.144.lr.ph.i:                             ; preds = %for.inc.158.i, %for.cond.142.preheader.lr.ph.i
  %indvars.iv312.i = phi i64 [ 0, %for.cond.142.preheader.lr.ph.i ], [ %indvars.iv.next313.i, %for.inc.158.i ]
  %4 = trunc i64 %indvars.iv312.i to i32
  %mul146.i = mul i32 %mul145.i, %4
  %add147.i = add i32 %mul146.i, %0
  %5 = mul nsw i64 %indvars.iv312.i, %3
  br label %for.body.144.i

for.body.144.i:                                   ; preds = %for.body.144.i, %for.body.144.lr.ph.i
  %indvars.iv.i = phi i64 [ 0, %for.body.144.lr.ph.i ], [ %indvars.iv.next.i, %for.body.144.i ]
  %6 = trunc i64 %indvars.iv.i to i32
  %add148.i = add i32 %add147.i, %6
  %idxprom149.i = sext i32 %add148.i to i64
  %arrayidx150.i = getelementptr inbounds double, double* %1, i64 %idxprom149.i
  %7 = bitcast double* %arrayidx150.i to i64*
  %8 = load i64, i64* %7, align 8, !tbaa !0
  %9 = add nsw i64 %indvars.iv.i, %5
  %arrayidx154.i = getelementptr inbounds double, double* %2, i64 %9
  %10 = bitcast double* %arrayidx154.i to i64*
  store i64 %8, i64* %10, align 8, !tbaa !0
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %lftr.wideiv660 = trunc i64 %indvars.iv.next.i to i32
  %exitcond661 = icmp eq i32 %lftr.wideiv660, %0
  br i1 %exitcond661, label %for.inc.158.i, label %for.body.144.i

for.inc.158.i:                                    ; preds = %for.body.144.i
  %indvars.iv.next313.i = add nuw nsw i64 %indvars.iv312.i, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next313.i to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %0
  br i1 %exitcond, label %_ZL12matrixInvertiPdS_.exit.loopexit, label %for.body.144.lr.ph.i

_ZL12matrixInvertiPdS_.exit.loopexit:             ; preds = %for.inc.158.i
  br label %_ZL12matrixInvertiPdS_.exit.exitStub
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
