
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Misc-C++/oopack_v1p8.cpp._ZNK15MatrixBenchmark9oop_styleEv_for.cond.2.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @_ZNK15MatrixBenchmark9oop_styleEv_for.cond.2.preheader.pjit.scop([2500 x double]* nonnull %C, [2500 x double]* nonnull %D, [2500 x double]* nonnull %E)  {
newFuncRoot:
  br label %for.cond.2.preheader

for.cond.cleanup.exitStub:                        ; preds = %for.cond.cleanup.4
  ret void

for.cond.2.preheader:                             ; preds = %for.cond.cleanup.4, %newFuncRoot
  %indvars.iv75 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next76, %for.cond.cleanup.4 ]
  %0 = mul nuw nsw i64 %indvars.iv75, 50
  br label %for.cond.6.preheader

for.cond.6.preheader:                             ; preds = %for.cond.cleanup.9, %for.cond.2.preheader
  %indvars.iv71 = phi i64 [ 0, %for.cond.2.preheader ], [ %indvars.iv.next72, %for.cond.cleanup.9 ]
  br label %for.body.10

for.body.10:                                      ; preds = %for.body.10, %for.cond.6.preheader
  %indvars.iv = phi i64 [ 0, %for.cond.6.preheader ], [ %indvars.iv.next, %for.body.10 ]
  %sum.064 = phi double [ 0.000000e+00, %for.cond.6.preheader ], [ %add, %for.body.10 ]
  %1 = add nuw nsw i64 %indvars.iv, %0
  %arrayidx.i.40 = getelementptr inbounds [2500 x double], [2500 x double]* %C, i64 0, i64 %1
  %2 = load double, double* %arrayidx.i.40, align 8, !tbaa !0
  %3 = mul nuw nsw i64 %indvars.iv, 50
  %4 = add nuw nsw i64 %3, %indvars.iv71
  %arrayidx.i = getelementptr inbounds [2500 x double], [2500 x double]* %D, i64 0, i64 %4
  %5 = load double, double* %arrayidx.i, align 8, !tbaa !0
  %mul = fmul double %2, %5
  %add = fadd double %sum.064, %mul
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 50
  br i1 %exitcond, label %for.cond.cleanup.9, label %for.body.10

for.cond.cleanup.9:                               ; preds = %for.body.10
  %add.lcssa = phi double [ %add, %for.body.10 ]
  %6 = add nuw nsw i64 %indvars.iv71, %0
  %arrayidx.i.46 = getelementptr inbounds [2500 x double], [2500 x double]* %E, i64 0, i64 %6
  store double %add.lcssa, double* %arrayidx.i.46, align 8, !tbaa !0
  %indvars.iv.next72 = add nuw nsw i64 %indvars.iv71, 1
  %exitcond74 = icmp eq i64 %indvars.iv.next72, 50
  br i1 %exitcond74, label %for.cond.cleanup.4, label %for.cond.6.preheader

for.cond.cleanup.4:                               ; preds = %for.cond.cleanup.9
  %indvars.iv.next76 = add nuw nsw i64 %indvars.iv75, 1
  %exitcond78 = icmp eq i64 %indvars.iv.next76, 50
  br i1 %exitcond78, label %for.cond.cleanup.exitStub, label %for.cond.2.preheader
}

attributes #0 = { nounwind "polyjit-global-count"="3" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
