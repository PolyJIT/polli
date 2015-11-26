
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/kernels/2mm/2mm.c.main_for.body.36.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.36.i.pjit.scop([1024 x double]* %arraydecay11, i64 %indvars.iv10.i.74, [1024 x double]* %arraydecay12, [1024 x double]* %arraydecay10)  {
newFuncRoot:
  br label %for.body.36.i

for.inc.65.i.exitStub:                            ; preds = %for.inc.62.i
  ret void

for.body.36.i:                                    ; preds = %for.inc.62.i, %newFuncRoot
  %indvars.iv7.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next8.i, %for.inc.62.i ]
  %arrayidx40.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay11, i64 %indvars.iv10.i.74, i64 %indvars.iv7.i
  %0 = load double, double* %arrayidx40.i, align 8, !tbaa !0
  %mul41.i = fmul double %0, 2.123000e+03
  store double %mul41.i, double* %arrayidx40.i, align 8, !tbaa !0
  br label %for.body.44.i

for.body.44.i:                                    ; preds = %for.body.44.i, %for.body.36.i
  %indvars.iv.i.75 = phi i64 [ 0, %for.body.36.i ], [ %indvars.iv.next.i.76, %for.body.44.i ]
  %arrayidx48.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay12, i64 %indvars.iv10.i.74, i64 %indvars.iv.i.75
  %1 = load double, double* %arrayidx48.i, align 8, !tbaa !0
  %arrayidx52.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay10, i64 %indvars.iv.i.75, i64 %indvars.iv7.i
  %2 = load double, double* %arrayidx52.i, align 8, !tbaa !0
  %mul53.i = fmul double %1, %2
  %3 = load double, double* %arrayidx40.i, align 8, !tbaa !0
  %add58.i = fadd double %3, %mul53.i
  store double %add58.i, double* %arrayidx40.i, align 8, !tbaa !0
  %indvars.iv.next.i.76 = add nuw nsw i64 %indvars.iv.i.75, 1
  %exitcond.i.77 = icmp eq i64 %indvars.iv.next.i.76, 1024
  br i1 %exitcond.i.77, label %for.inc.62.i, label %for.body.44.i

for.inc.62.i:                                     ; preds = %for.body.44.i
  %indvars.iv.next8.i = add nuw nsw i64 %indvars.iv7.i, 1
  %exitcond9.i = icmp eq i64 %indvars.iv.next8.i, 1024
  br i1 %exitcond9.i, label %for.inc.65.i.exitStub, label %for.body.36.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
