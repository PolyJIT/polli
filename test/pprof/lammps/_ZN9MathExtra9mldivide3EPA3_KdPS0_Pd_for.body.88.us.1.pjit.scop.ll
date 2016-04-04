
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polli-process-unprofitable -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '../math_extra.cpp._ZN9MathExtra9mldivide3EPA3_KdPS0_Pd_for.body.88.us.1.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @_ZN9MathExtra9mldivide3EPA3_KdPS0_Pd_for.body.88.us.1.pjit.scop([3 x [4 x double]]* %aug, double* %arrayidx97.1)  {
newFuncRoot:
  br label %for.body.88.us.1

for.cond.20.loopexit.1.exitStub:                  ; preds = %for.cond.99.for.cond.cleanup.101_crit_edge.us.1
  ret void

for.body.88.us.1:                                 ; preds = %for.cond.99.for.cond.cleanup.101_crit_edge.us.1, %newFuncRoot
  %indvars.iv292.1 = phi i64 [ 2, %newFuncRoot ], [ %indvars.iv.next293.1, %for.cond.99.for.cond.cleanup.101_crit_edge.us.1 ]
  %arrayidx93.us.1 = getelementptr inbounds [3 x [4 x double]], [3 x [4 x double]]* %aug, i64 0, i64 %indvars.iv292.1, i64 1
  %0 = load double, double* %arrayidx93.us.1, align 8, !tbaa !0
  %1 = load double, double* %arrayidx97.1, align 8, !tbaa !0
  %div.us.1 = fdiv double %0, %1
  br label %for.body.102.us.1

for.body.102.us.1:                                ; preds = %for.body.102.us.1, %for.body.88.us.1
  %indvars.iv286.1 = phi i64 [ 2, %for.body.88.us.1 ], [ %indvars.iv.next287.1, %for.body.102.us.1 ]
  %arrayidx106.us.1 = getelementptr inbounds [3 x [4 x double]], [3 x [4 x double]]* %aug, i64 0, i64 1, i64 %indvars.iv286.1
  %2 = load double, double* %arrayidx106.us.1, align 8, !tbaa !0
  %mul.us.1 = fmul double %div.us.1, %2
  %arrayidx110.us.1 = getelementptr inbounds [3 x [4 x double]], [3 x [4 x double]]* %aug, i64 0, i64 %indvars.iv292.1, i64 %indvars.iv286.1
  %3 = load double, double* %arrayidx110.us.1, align 8, !tbaa !0
  %sub.us.1 = fsub double %3, %mul.us.1
  store double %sub.us.1, double* %arrayidx110.us.1, align 8, !tbaa !0
  %indvars.iv.next287.1 = add nuw nsw i64 %indvars.iv286.1, 1
  %exitcond312 = icmp eq i64 %indvars.iv.next287.1, 4
  br i1 %exitcond312, label %for.cond.99.for.cond.cleanup.101_crit_edge.us.1, label %for.body.102.us.1

for.cond.99.for.cond.cleanup.101_crit_edge.us.1:  ; preds = %for.body.102.us.1
  %indvars.iv.next293.1 = add nuw nsw i64 %indvars.iv292.1, 1
  %lftr.wideiv294.1 = trunc i64 %indvars.iv.next293.1 to i32
  %exitcond295.1 = icmp eq i32 %lftr.wideiv294.1, 3
  br i1 %exitcond295.1, label %for.cond.20.loopexit.1.exitStub, label %for.body.88.us.1
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
