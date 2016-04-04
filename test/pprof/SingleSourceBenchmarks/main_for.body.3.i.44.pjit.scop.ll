
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/kernels/gemm/gemm.c.main_for.body.3.i.44.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.3.i.44.pjit.scop([1024 x double]* %arraydecay, i64 %indvars.iv7.i.41, [1024 x double]* %arraydecay3, [1024 x double]* %arraydecay4)  {
newFuncRoot:
  br label %for.body.3.i.44

for.inc.26.i.exitStub:                            ; preds = %for.inc.23.i
  ret void

for.body.3.i.44:                                  ; preds = %for.inc.23.i, %newFuncRoot
  %indvars.iv4.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next5.i, %for.inc.23.i ]
  %arrayidx5.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv7.i.41, i64 %indvars.iv4.i
  %0 = load double, double* %arrayidx5.i, align 8, !tbaa !0
  %mul.i.43 = fmul double %0, 2.123000e+03
  store double %mul.i.43, double* %arrayidx5.i, align 8, !tbaa !0
  br label %for.body.8.i

for.body.8.i:                                     ; preds = %for.body.8.i, %for.body.3.i.44
  %indvars.iv.i.45 = phi i64 [ 0, %for.body.3.i.44 ], [ %indvars.iv.next.i.46, %for.body.8.i ]
  %arrayidx12.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay3, i64 %indvars.iv7.i.41, i64 %indvars.iv.i.45
  %1 = load double, double* %arrayidx12.i, align 8, !tbaa !0
  %mul13.i = fmul double %1, 3.241200e+04
  %arrayidx17.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %indvars.iv.i.45, i64 %indvars.iv4.i
  %2 = load double, double* %arrayidx17.i, align 8, !tbaa !0
  %mul18.i = fmul double %mul13.i, %2
  %3 = load double, double* %arrayidx5.i, align 8, !tbaa !0
  %add.i = fadd double %3, %mul18.i
  store double %add.i, double* %arrayidx5.i, align 8, !tbaa !0
  %indvars.iv.next.i.46 = add nuw nsw i64 %indvars.iv.i.45, 1
  %exitcond.i.47 = icmp eq i64 %indvars.iv.next.i.46, 1024
  br i1 %exitcond.i.47, label %for.inc.23.i, label %for.body.8.i

for.inc.23.i:                                     ; preds = %for.body.8.i
  %indvars.iv.next5.i = add nuw nsw i64 %indvars.iv4.i, 1
  %exitcond6.i = icmp eq i64 %indvars.iv.next5.i, 1024
  br i1 %exitcond6.i, label %for.inc.26.i.exitStub, label %for.body.3.i.44
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
