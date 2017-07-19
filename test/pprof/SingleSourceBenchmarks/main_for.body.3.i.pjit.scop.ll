
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/kernels/bicg/bicg.c.main_for.body.3.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.3.i.pjit.scop(double* %arraydecay9, double* %arraydecay5, double* %arraydecay8, [4000 x double]* %arraydecay, double* %arraydecay6)  {
newFuncRoot:
  br label %for.body.3.i

kernel_bicg.exit.exitStub:                        ; preds = %for.inc.34.i
  ret void

for.body.3.i:                                     ; preds = %for.inc.34.i, %newFuncRoot
  %indvars.iv4.i.63 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next5.i.68, %for.inc.34.i ]
  %arrayidx5.i = getelementptr inbounds double, double* %arraydecay9, i64 %indvars.iv4.i.63
  store double 0.000000e+00, double* %arrayidx5.i, align 8, !tbaa !0
  %arrayidx12.i = getelementptr inbounds double, double* %arraydecay5, i64 %indvars.iv4.i.63
  br label %for.body.8.i

for.body.8.i:                                     ; preds = %for.body.8.i, %for.body.3.i
  %indvars.iv.i.64 = phi i64 [ 0, %for.body.3.i ], [ %indvars.iv.next.i.66, %for.body.8.i ]
  %arrayidx10.i = getelementptr inbounds double, double* %arraydecay8, i64 %indvars.iv.i.64
  %0 = load double, double* %arrayidx10.i, align 8, !tbaa !0
  %1 = load double, double* %arrayidx12.i, align 8, !tbaa !0
  %arrayidx16.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay, i64 %indvars.iv4.i.63, i64 %indvars.iv.i.64
  %2 = load double, double* %arrayidx16.i, align 8, !tbaa !0
  %mul.i.65 = fmul double %1, %2
  %add.i = fadd double %0, %mul.i.65
  store double %add.i, double* %arrayidx10.i, align 8, !tbaa !0
  %3 = load double, double* %arrayidx5.i, align 8, !tbaa !0
  %4 = load double, double* %arrayidx16.i, align 8, !tbaa !0
  %arrayidx26.i = getelementptr inbounds double, double* %arraydecay6, i64 %indvars.iv.i.64
  %5 = load double, double* %arrayidx26.i, align 8, !tbaa !0
  %mul27.i = fmul double %4, %5
  %add28.i = fadd double %3, %mul27.i
  store double %add28.i, double* %arrayidx5.i, align 8, !tbaa !0
  %indvars.iv.next.i.66 = add nuw nsw i64 %indvars.iv.i.64, 1
  %exitcond.i.67 = icmp eq i64 %indvars.iv.next.i.66, 4000
  br i1 %exitcond.i.67, label %for.inc.34.i, label %for.body.8.i

for.inc.34.i:                                     ; preds = %for.body.8.i
  %indvars.iv.next5.i.68 = add nuw nsw i64 %indvars.iv4.i.63, 1
  %exitcond6.i.69 = icmp eq i64 %indvars.iv.next5.i.68, 4000
  br i1 %exitcond6.i.69, label %kernel_bicg.exit.exitStub, label %for.body.3.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
