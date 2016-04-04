
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'ssyrk.c.f2c_ssyrk_for.cond.69.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_ssyrk_for.cond.69.preheader.pjit.scop(i1 %cmp60.645, i64, i64, float* %beta, float* %add.ptr3)  {
newFuncRoot:
  br label %for.cond.69.preheader

cleanup.exitStub:                                 ; preds = %cleanup.loopexit812, %for.cond.69.preheader
  ret void

for.cond.69.preheader:                            ; preds = %newFuncRoot
  br i1 %cmp60.645, label %cleanup.exitStub, label %for.body.74.lr.ph.preheader

for.body.74.lr.ph.preheader:                      ; preds = %for.cond.69.preheader
  %2 = add i64 %0, 2
  br label %for.body.74.lr.ph

for.body.74.lr.ph:                                ; preds = %for.inc.85, %for.body.74.lr.ph.preheader
  %indvars.iv746 = phi i64 [ %indvars.iv.next747, %for.inc.85 ], [ 2, %for.body.74.lr.ph.preheader ]
  %j.1651 = phi i64 [ %inc86, %for.inc.85 ], [ 1, %for.body.74.lr.ph.preheader ]
  %mul75 = mul nsw i64 %j.1651, %1
  br label %for.body.74

for.body.74:                                      ; preds = %for.body.74, %for.body.74.lr.ph
  %i__.1649 = phi i64 [ 1, %for.body.74.lr.ph ], [ %inc83, %for.body.74 ]
  %3 = load float, float* %beta, align 4, !tbaa !0
  %add76 = add nsw i64 %i__.1649, %mul75
  %arrayidx77 = getelementptr inbounds float, float* %add.ptr3, i64 %add76
  %4 = load float, float* %arrayidx77, align 4, !tbaa !0
  %mul78 = fmul float %3, %4
  store float %mul78, float* %arrayidx77, align 4, !tbaa !0
  %inc83 = add nuw nsw i64 %i__.1649, 1
  %exitcond748 = icmp eq i64 %inc83, %indvars.iv746
  br i1 %exitcond748, label %for.inc.85, label %for.body.74

for.inc.85:                                       ; preds = %for.body.74
  %inc86 = add nuw nsw i64 %j.1651, 1
  %indvars.iv.next747 = add nuw i64 %indvars.iv746, 1
  %exitcond823 = icmp eq i64 %indvars.iv.next747, %2
  br i1 %exitcond823, label %cleanup.loopexit812, label %for.body.74.lr.ph

cleanup.loopexit812:                              ; preds = %for.inc.85
  br label %cleanup.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
