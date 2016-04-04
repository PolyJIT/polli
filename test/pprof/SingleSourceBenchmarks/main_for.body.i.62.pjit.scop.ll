
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/kernels/gesummv/gesummv.c.main_for.body.i.62.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.i.62.pjit.scop(double* %arraydecay11, double* %arraydecay13, [4000 x double]* %arraydecay, double* %arraydecay8, [4000 x double]* %arraydecay7)  {
newFuncRoot:
  br label %for.body.i.62

kernel_gesummv.exit.exitStub:                     ; preds = %for.end.i
  ret void

for.body.i.62:                                    ; preds = %for.end.i, %newFuncRoot
  %indvars.iv3.i.60 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next4.i.68, %for.end.i ]
  %arrayidx.i.61 = getelementptr inbounds double, double* %arraydecay11, i64 %indvars.iv3.i.60
  store double 0.000000e+00, double* %arrayidx.i.61, align 8, !tbaa !0
  %arrayidx4.i = getelementptr inbounds double, double* %arraydecay13, i64 %indvars.iv3.i.60
  store double 0.000000e+00, double* %arrayidx4.i, align 8, !tbaa !0
  br label %for.body.7.i

for.body.7.i:                                     ; preds = %for.body.7.i, %for.body.i.62
  %indvars.iv.i.63 = phi i64 [ 0, %for.body.i.62 ], [ %indvars.iv.next.i.66, %for.body.7.i ]
  %arrayidx11.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay, i64 %indvars.iv3.i.60, i64 %indvars.iv.i.63
  %0 = load double, double* %arrayidx11.i, align 8, !tbaa !0
  %arrayidx13.i.64 = getelementptr inbounds double, double* %arraydecay8, i64 %indvars.iv.i.63
  %1 = load double, double* %arrayidx13.i.64, align 8, !tbaa !0
  %mul.i.65 = fmul double %0, %1
  %2 = load double, double* %arrayidx.i.61, align 8, !tbaa !0
  %add.i = fadd double %mul.i.65, %2
  store double %add.i, double* %arrayidx.i.61, align 8, !tbaa !0
  %arrayidx21.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay7, i64 %indvars.iv3.i.60, i64 %indvars.iv.i.63
  %3 = load double, double* %arrayidx21.i, align 8, !tbaa !0
  %4 = load double, double* %arrayidx13.i.64, align 8, !tbaa !0
  %mul24.i = fmul double %3, %4
  %5 = load double, double* %arrayidx4.i, align 8, !tbaa !0
  %add27.i = fadd double %mul24.i, %5
  store double %add27.i, double* %arrayidx4.i, align 8, !tbaa !0
  %indvars.iv.next.i.66 = add nuw nsw i64 %indvars.iv.i.63, 1
  %exitcond.i.67 = icmp eq i64 %indvars.iv.next.i.66, 4000
  br i1 %exitcond.i.67, label %for.end.i, label %for.body.7.i

for.end.i:                                        ; preds = %for.body.7.i
  %add27.i.lcssa = phi double [ %add27.i, %for.body.7.i ]
  %6 = load double, double* %arrayidx.i.61, align 8, !tbaa !0
  %mul32.i = fmul double %6, 4.353200e+04
  %mul35.i = fmul double %add27.i.lcssa, 1.231300e+04
  %add36.i = fadd double %mul35.i, %mul32.i
  store double %add36.i, double* %arrayidx4.i, align 8, !tbaa !0
  %indvars.iv.next4.i.68 = add nuw nsw i64 %indvars.iv3.i.60, 1
  %exitcond5.i.69 = icmp eq i64 %indvars.iv.next4.i.68, 4000
  br i1 %exitcond5.i.69, label %kernel_gesummv.exit.exitStub, label %for.body.i.62
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
