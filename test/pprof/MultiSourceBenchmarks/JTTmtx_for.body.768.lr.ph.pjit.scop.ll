
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/mafft/constants.c.JTTmtx_for.body.768.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @JTTmtx_for.body.768.lr.ph.pjit.scop([20 x [20 x double]]* %r, [20 x double]* nonnull %JTTmtx.freq0_TM)  {
newFuncRoot:
  br label %for.body.768.lr.ph

for.body.794.preheader.exitStub:                  ; preds = %for.inc.789
  ret void

for.body.768.lr.ph:                               ; preds = %for.inc.789, %newFuncRoot
  %indvars.iv993 = phi i32 [ 1, %newFuncRoot ], [ %indvars.iv.next994, %for.inc.789 ]
  %indvars.iv985 = phi i64 [ %indvars.iv.next986, %for.inc.789 ], [ 1, %newFuncRoot ]
  %arrayidx770 = getelementptr inbounds [20 x double], [20 x double]* %JTTmtx.freq0_TM, i64 0, i64 %indvars.iv985
  %0 = load double, double* %arrayidx770, align 8, !tbaa !0
  %mul = fmul double %0, 4.000000e+02
  br label %for.body.768

for.body.768:                                     ; preds = %for.body.768, %for.body.768.lr.ph
  %indvars.iv979 = phi i64 [ 0, %for.body.768.lr.ph ], [ %indvars.iv.next980, %for.body.768 ]
  %arrayidx772 = getelementptr inbounds [20 x double], [20 x double]* %JTTmtx.freq0_TM, i64 0, i64 %indvars.iv979
  %1 = load double, double* %arrayidx772, align 8, !tbaa !0
  %mul773 = fmul double %mul, %1
  %arrayidx777 = getelementptr inbounds [20 x [20 x double]], [20 x [20 x double]]* %r, i64 0, i64 %indvars.iv979, i64 %indvars.iv985
  %2 = load double, double* %arrayidx777, align 8, !tbaa !0
  %div = fdiv double %2, %mul773
  store double %div, double* %arrayidx777, align 8, !tbaa !0
  %arrayidx785 = getelementptr inbounds [20 x [20 x double]], [20 x [20 x double]]* %r, i64 0, i64 %indvars.iv985, i64 %indvars.iv979
  store double %div, double* %arrayidx785, align 8, !tbaa !0
  %indvars.iv.next980 = add nuw nsw i64 %indvars.iv979, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next980 to i32
  %exitcond995 = icmp eq i32 %lftr.wideiv, %indvars.iv993
  br i1 %exitcond995, label %for.inc.789, label %for.body.768

for.inc.789:                                      ; preds = %for.body.768
  %indvars.iv.next986 = add nuw nsw i64 %indvars.iv985, 1
  %indvars.iv.next994 = add nuw nsw i32 %indvars.iv993, 1
  %exitcond987 = icmp eq i64 %indvars.iv.next986, 20
  br i1 %exitcond987, label %for.body.794.preheader.exitStub, label %for.body.768.lr.ph
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
