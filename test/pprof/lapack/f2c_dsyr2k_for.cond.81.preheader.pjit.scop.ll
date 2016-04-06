
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'dsyr2k.c.f2c_dsyr2k_for.cond.81.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_dsyr2k_for.cond.81.preheader.pjit.scop(i1 %cmp72.788, i64, i64, double* %beta, double* %add.ptr6)  {
newFuncRoot:
  br label %for.cond.81.preheader

cleanup.exitStub:                                 ; preds = %cleanup.loopexit921, %for.cond.81.preheader
  ret void

for.cond.81.preheader:                            ; preds = %newFuncRoot
  br i1 %cmp72.788, label %cleanup.exitStub, label %for.body.86.lr.ph.preheader

for.body.86.lr.ph.preheader:                      ; preds = %for.cond.81.preheader
  %2 = add i64 %0, 2
  br label %for.body.86.lr.ph

for.body.86.lr.ph:                                ; preds = %for.inc.97, %for.body.86.lr.ph.preheader
  %indvars.iv866 = phi i64 [ %indvars.iv.next867, %for.inc.97 ], [ 2, %for.body.86.lr.ph.preheader ]
  %j.1794 = phi i64 [ %inc98, %for.inc.97 ], [ 1, %for.body.86.lr.ph.preheader ]
  %mul87 = mul nsw i64 %j.1794, %1
  br label %for.body.86

for.body.86:                                      ; preds = %for.body.86, %for.body.86.lr.ph
  %i__.1792 = phi i64 [ 1, %for.body.86.lr.ph ], [ %inc95, %for.body.86 ]
  %3 = load double, double* %beta, align 8, !tbaa !0
  %add88 = add nsw i64 %i__.1792, %mul87
  %arrayidx89 = getelementptr inbounds double, double* %add.ptr6, i64 %add88
  %4 = load double, double* %arrayidx89, align 8, !tbaa !0
  %mul90 = fmul double %3, %4
  store double %mul90, double* %arrayidx89, align 8, !tbaa !0
  %inc95 = add nuw nsw i64 %i__.1792, 1
  %exitcond868 = icmp eq i64 %inc95, %indvars.iv866
  br i1 %exitcond868, label %for.inc.97, label %for.body.86

for.inc.97:                                       ; preds = %for.body.86
  %inc98 = add nuw nsw i64 %j.1794, 1
  %indvars.iv.next867 = add nuw i64 %indvars.iv866, 1
  %exitcond931 = icmp eq i64 %indvars.iv.next867, %2
  br i1 %exitcond931, label %cleanup.loopexit921, label %for.body.86.lr.ph

cleanup.loopexit921:                              ; preds = %for.inc.97
  br label %cleanup.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
