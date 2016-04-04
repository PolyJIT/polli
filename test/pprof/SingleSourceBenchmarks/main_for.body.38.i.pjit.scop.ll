
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/datamining/covariance/covariance.c.main_for.body.38.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.38.i.pjit.scop(i64 %indvars.iv14.i, [1000 x double]* %arraydecay4, [1000 x double]* %arraydecay)  {
newFuncRoot:
  br label %for.body.38.i

for.inc.73.i.exitStub:                            ; preds = %for.end.61.i
  ret void

for.body.38.i:                                    ; preds = %for.end.61.i, %newFuncRoot
  %indvars.iv11.i = phi i64 [ %indvars.iv14.i, %newFuncRoot ], [ %indvars.iv.next12.i, %for.end.61.i ]
  %arrayidx42.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay4, i64 %indvars.iv14.i, i64 %indvars.iv11.i
  store double 0.000000e+00, double* %arrayidx42.i, align 8, !tbaa !0
  br label %for.body.45.i

for.body.45.i:                                    ; preds = %for.body.45.i, %for.body.38.i
  %indvars.iv.i.36 = phi i64 [ 0, %for.body.38.i ], [ %indvars.iv.next.i.38, %for.body.45.i ]
  %arrayidx49.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv.i.36, i64 %indvars.iv14.i
  %0 = load double, double* %arrayidx49.i, align 8, !tbaa !0
  %arrayidx53.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv.i.36, i64 %indvars.iv11.i
  %1 = load double, double* %arrayidx53.i, align 8, !tbaa !0
  %mul.i.37 = fmul double %0, %1
  %2 = load double, double* %arrayidx42.i, align 8, !tbaa !0
  %add58.i = fadd double %2, %mul.i.37
  store double %add58.i, double* %arrayidx42.i, align 8, !tbaa !0
  %indvars.iv.next.i.38 = add nuw nsw i64 %indvars.iv.i.36, 1
  %exitcond.i.39 = icmp eq i64 %indvars.iv.next.i.38, 1000
  br i1 %exitcond.i.39, label %for.end.61.i, label %for.body.45.i

for.end.61.i:                                     ; preds = %for.body.45.i
  %3 = bitcast double* %arrayidx42.i to i64*
  %4 = load i64, i64* %3, align 8, !tbaa !0
  %arrayidx69.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay4, i64 %indvars.iv11.i, i64 %indvars.iv14.i
  %5 = bitcast double* %arrayidx69.i to i64*
  store i64 %4, i64* %5, align 8, !tbaa !0
  %indvars.iv.next12.i = add nuw nsw i64 %indvars.iv11.i, 1
  %lftr.wideiv46 = trunc i64 %indvars.iv.next12.i to i32
  %exitcond47 = icmp eq i32 %lftr.wideiv46, 1000
  br i1 %exitcond47, label %for.inc.73.i.exitStub, label %for.body.38.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
