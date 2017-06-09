
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/kernels/3mm/3mm.c.main_for.body.3.i.92.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.3.i.92.pjit.scop([1024 x double]* %arraydecay10, i64 %indvars.iv31.i, [1024 x double]* %arraydecay, [1024 x double]* %arraydecay7)  {
newFuncRoot:
  br label %for.body.3.i.92

for.inc.24.i.exitStub:                            ; preds = %for.inc.21.i
  ret void

for.body.3.i.92:                                  ; preds = %for.inc.21.i, %newFuncRoot
  %indvars.iv28.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next29.i, %for.inc.21.i ]
  %arrayidx5.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay10, i64 %indvars.iv31.i, i64 %indvars.iv28.i
  store double 0.000000e+00, double* %arrayidx5.i, align 8, !tbaa !0
  br label %for.body.8.i

for.body.8.i:                                     ; preds = %for.body.8.i, %for.body.3.i.92
  %indvars.iv25.i = phi i64 [ 0, %for.body.3.i.92 ], [ %indvars.iv.next26.i, %for.body.8.i ]
  %arrayidx12.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv31.i, i64 %indvars.iv25.i
  %0 = load double, double* %arrayidx12.i, align 8, !tbaa !0
  %arrayidx16.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay7, i64 %indvars.iv25.i, i64 %indvars.iv28.i
  %1 = load double, double* %arrayidx16.i, align 8, !tbaa !0
  %mul.i.93 = fmul double %0, %1
  %2 = load double, double* %arrayidx5.i, align 8, !tbaa !0
  %add.i = fadd double %2, %mul.i.93
  store double %add.i, double* %arrayidx5.i, align 8, !tbaa !0
  %indvars.iv.next26.i = add nuw nsw i64 %indvars.iv25.i, 1
  %exitcond27.i = icmp eq i64 %indvars.iv.next26.i, 1024
  br i1 %exitcond27.i, label %for.inc.21.i, label %for.body.8.i

for.inc.21.i:                                     ; preds = %for.body.8.i
  %indvars.iv.next29.i = add nuw nsw i64 %indvars.iv28.i, 1
  %exitcond30.i = icmp eq i64 %indvars.iv.next29.i, 1024
  br i1 %exitcond30.i, label %for.inc.24.i.exitStub, label %for.body.3.i.92
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
