
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/datamining/correlation/correlation.c.main_for.body.90.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.90.i.pjit.scop([1000 x double]* %arraydecay5, [1000 x double]* %arraydecay)  {
newFuncRoot:
  br label %for.body.90.i

kernel_correlation.exit.exitStub:                 ; preds = %for.cond.87.loopexit.i
  ret void

for.body.90.i:                                    ; preds = %for.cond.87.loopexit.i, %newFuncRoot
  %indvars.iv16.i = phi i64 [ %indvars.iv.next17.i, %for.cond.87.loopexit.i ], [ 0, %newFuncRoot ]
  %indvars.iv11.i = phi i64 [ %indvars.iv.next12.i, %for.cond.87.loopexit.i ], [ 1, %newFuncRoot ]
  %arrayidx94.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay5, i64 %indvars.iv16.i, i64 %indvars.iv16.i
  store double 1.000000e+00, double* %arrayidx94.i, align 8, !tbaa !0
  br label %for.body.98.i

for.body.98.i:                                    ; preds = %for.end.122.i, %for.body.90.i
  %indvars.iv13.i = phi i64 [ %indvars.iv11.i, %for.body.90.i ], [ %indvars.iv.next14.i, %for.end.122.i ]
  %arrayidx102.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay5, i64 %indvars.iv16.i, i64 %indvars.iv13.i
  store double 0.000000e+00, double* %arrayidx102.i, align 8, !tbaa !0
  br label %for.body.105.i

for.body.105.i:                                   ; preds = %for.body.105.i, %for.body.98.i
  %indvars.iv.i.48 = phi i64 [ 0, %for.body.98.i ], [ %indvars.iv.next.i.49, %for.body.105.i ]
  %arrayidx109.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv.i.48, i64 %indvars.iv16.i
  %0 = load double, double* %arrayidx109.i, align 8, !tbaa !0
  %arrayidx113.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv.i.48, i64 %indvars.iv13.i
  %1 = load double, double* %arrayidx113.i, align 8, !tbaa !0
  %mul114.i = fmul double %0, %1
  %2 = load double, double* %arrayidx102.i, align 8, !tbaa !0
  %add119.i = fadd double %2, %mul114.i
  store double %add119.i, double* %arrayidx102.i, align 8, !tbaa !0
  %indvars.iv.next.i.49 = add nuw nsw i64 %indvars.iv.i.48, 1
  %exitcond.i.50 = icmp eq i64 %indvars.iv.next.i.49, 1000
  br i1 %exitcond.i.50, label %for.end.122.i, label %for.body.105.i

for.end.122.i:                                    ; preds = %for.body.105.i
  %3 = bitcast double* %arrayidx102.i to i64*
  %4 = load i64, i64* %3, align 8, !tbaa !0
  %arrayidx130.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay5, i64 %indvars.iv13.i, i64 %indvars.iv16.i
  %5 = bitcast double* %arrayidx130.i to i64*
  store i64 %4, i64* %5, align 8, !tbaa !0
  %indvars.iv.next14.i = add nuw nsw i64 %indvars.iv13.i, 1
  %lftr.wideiv58 = trunc i64 %indvars.iv.next14.i to i32
  %exitcond59 = icmp eq i32 %lftr.wideiv58, 1000
  br i1 %exitcond59, label %for.cond.87.loopexit.i, label %for.body.98.i

for.cond.87.loopexit.i:                           ; preds = %for.end.122.i
  %indvars.iv.next17.i = add nuw nsw i64 %indvars.iv16.i, 1
  %indvars.iv.next12.i = add nuw nsw i64 %indvars.iv11.i, 1
  %exitcond18.i = icmp eq i64 %indvars.iv.next17.i, 999
  br i1 %exitcond18.i, label %kernel_correlation.exit.exitStub, label %for.body.90.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
