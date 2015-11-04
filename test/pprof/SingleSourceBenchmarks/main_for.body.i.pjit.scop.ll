
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/solvers/lu/lu.c.main_for.body.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.i.pjit.scop([128 x double]* %arraydecay)  {
newFuncRoot:
  br label %for.body.i

kernel_lu.exit.exitStub:                          ; preds = %for.cond.loopexit.i.10
  ret void

for.body.i:                                       ; preds = %for.cond.loopexit.i.10, %newFuncRoot
  %indvars.iv24.i = phi i64 [ %indvars.iv.next25.i, %for.cond.loopexit.i.10 ], [ 0, %newFuncRoot ]
  %indvars.iv18.i = phi i64 [ %indvars.iv.next19.i, %for.cond.loopexit.i.10 ], [ 1, %newFuncRoot ]
  %indvars.iv.next25.i = add nuw nsw i64 %indvars.iv24.i, 1
  %cmp2.1.i = icmp slt i64 %indvars.iv.next25.i, 128
  br i1 %cmp2.1.i, label %for.body.3.lr.ph.i, label %for.cond.loopexit.i.10

for.body.3.lr.ph.i:                               ; preds = %for.body.i
  %arrayidx9.i = getelementptr inbounds [128 x double], [128 x double]* %arraydecay, i64 %indvars.iv24.i, i64 %indvars.iv24.i
  br label %for.body.3.i.13

for.body.3.i.13:                                  ; preds = %for.body.3.i.13, %for.body.3.lr.ph.i
  %indvars.iv9.i = phi i64 [ %indvars.iv18.i, %for.body.3.lr.ph.i ], [ %indvars.iv.next10.i, %for.body.3.i.13 ]
  %arrayidx5.i = getelementptr inbounds [128 x double], [128 x double]* %arraydecay, i64 %indvars.iv24.i, i64 %indvars.iv9.i
  %0 = load double, double* %arrayidx5.i, align 8, !tbaa !0
  %1 = load double, double* %arrayidx9.i, align 8, !tbaa !0
  %div.i.12 = fdiv double %0, %1
  store double %div.i.12, double* %arrayidx5.i, align 8, !tbaa !0
  %indvars.iv.next10.i = add nuw nsw i64 %indvars.iv9.i, 1
  %lftr.wideiv21 = trunc i64 %indvars.iv.next10.i to i32
  %exitcond22 = icmp eq i32 %lftr.wideiv21, 128
  br i1 %exitcond22, label %for.cond.15.preheader.i, label %for.body.3.i.13

for.cond.15.preheader.i:                          ; preds = %for.body.3.i.13
  br i1 %cmp2.1.i, label %for.body.21.lr.ph.us.i.preheader, label %for.cond.loopexit.i.10

for.body.21.lr.ph.us.i.preheader:                 ; preds = %for.cond.15.preheader.i
  br label %for.body.21.lr.ph.us.i

for.body.21.lr.ph.us.i:                           ; preds = %for.cond.19.for.inc.42_crit_edge.us.i, %for.body.21.lr.ph.us.i.preheader
  %indvars.iv20.i = phi i64 [ %indvars.iv.next21.i, %for.cond.19.for.inc.42_crit_edge.us.i ], [ %indvars.iv18.i, %for.body.21.lr.ph.us.i.preheader ]
  %arrayidx29.us.i = getelementptr inbounds [128 x double], [128 x double]* %arraydecay, i64 %indvars.iv20.i, i64 %indvars.iv24.i
  br label %for.body.21.us.i

for.body.21.us.i:                                 ; preds = %for.body.21.us.i, %for.body.21.lr.ph.us.i
  %indvars.iv14.i = phi i64 [ %indvars.iv18.i, %for.body.21.lr.ph.us.i ], [ %indvars.iv.next15.i, %for.body.21.us.i ]
  %arrayidx25.us.i = getelementptr inbounds [128 x double], [128 x double]* %arraydecay, i64 %indvars.iv20.i, i64 %indvars.iv14.i
  %2 = load double, double* %arrayidx25.us.i, align 8, !tbaa !0
  %3 = load double, double* %arrayidx29.us.i, align 8, !tbaa !0
  %arrayidx33.us.i = getelementptr inbounds [128 x double], [128 x double]* %arraydecay, i64 %indvars.iv24.i, i64 %indvars.iv14.i
  %4 = load double, double* %arrayidx33.us.i, align 8, !tbaa !0
  %mul.us.i = fmul double %3, %4
  %add34.us.i = fadd double %2, %mul.us.i
  store double %add34.us.i, double* %arrayidx25.us.i, align 8, !tbaa !0
  %indvars.iv.next15.i = add nuw nsw i64 %indvars.iv14.i, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next15.i to i32
  %exitcond = icmp eq i32 %lftr.wideiv, 128
  br i1 %exitcond, label %for.cond.19.for.inc.42_crit_edge.us.i, label %for.body.21.us.i

for.cond.19.for.inc.42_crit_edge.us.i:            ; preds = %for.body.21.us.i
  %indvars.iv.next21.i = add nuw nsw i64 %indvars.iv20.i, 1
  %lftr.wideiv23 = trunc i64 %indvars.iv.next21.i to i32
  %exitcond24 = icmp eq i32 %lftr.wideiv23, 128
  br i1 %exitcond24, label %for.cond.loopexit.i.10.loopexit, label %for.body.21.lr.ph.us.i

for.cond.loopexit.i.10.loopexit:                  ; preds = %for.cond.19.for.inc.42_crit_edge.us.i
  br label %for.cond.loopexit.i.10

for.cond.loopexit.i.10:                           ; preds = %for.cond.loopexit.i.10.loopexit, %for.cond.15.preheader.i, %for.body.i
  %indvars.iv.next19.i = add nuw nsw i64 %indvars.iv18.i, 1
  %exitcond26.i = icmp eq i64 %indvars.iv.next25.i, 128
  br i1 %exitcond26.i, label %kernel_lu.exit.exitStub, label %for.body.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
