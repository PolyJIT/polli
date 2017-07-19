
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/kernels/atax/atax.c.main_for.body.5.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.5.i.pjit.scop(double* %arraydecay8, [4000 x double]* %arraydecay, double* %arraydecay4, double* %arraydecay7)  {
newFuncRoot:
  br label %for.body.5.i

kernel_atax.exit.exitStub:                        ; preds = %for.inc.42.i
  ret void

for.body.5.i:                                     ; preds = %for.inc.42.i, %newFuncRoot
  %indvars.iv8.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next9.i, %for.inc.42.i ]
  %arrayidx7.i = getelementptr inbounds double, double* %arraydecay8, i64 %indvars.iv8.i
  store double 0.000000e+00, double* %arrayidx7.i, align 8, !tbaa !0
  br label %for.body.10.i

for.body.10.i:                                    ; preds = %for.body.10.i, %for.body.5.i
  %indvars.iv.i.47 = phi i64 [ 0, %for.body.5.i ], [ %indvars.iv.next.i.50, %for.body.10.i ]
  %0 = load double, double* %arrayidx7.i, align 8, !tbaa !0
  %arrayidx16.i.48 = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay, i64 %indvars.iv8.i, i64 %indvars.iv.i.47
  %1 = load double, double* %arrayidx16.i.48, align 8, !tbaa !0
  %arrayidx18.i = getelementptr inbounds double, double* %arraydecay4, i64 %indvars.iv.i.47
  %2 = load double, double* %arrayidx18.i, align 8, !tbaa !0
  %mul.i.49 = fmul double %1, %2
  %add.i = fadd double %0, %mul.i.49
  store double %add.i, double* %arrayidx7.i, align 8, !tbaa !0
  %indvars.iv.next.i.50 = add nuw nsw i64 %indvars.iv.i.47, 1
  %exitcond.i.51 = icmp eq i64 %indvars.iv.next.i.50, 4000
  br i1 %exitcond.i.51, label %for.body.26.i.preheader, label %for.body.10.i

for.body.26.i.preheader:                          ; preds = %for.body.10.i
  br label %for.body.26.i

for.body.26.i:                                    ; preds = %for.body.26.i, %for.body.26.i.preheader
  %indvars.iv5.i = phi i64 [ %indvars.iv.next6.i, %for.body.26.i ], [ 0, %for.body.26.i.preheader ]
  %arrayidx28.i = getelementptr inbounds double, double* %arraydecay7, i64 %indvars.iv5.i
  %3 = load double, double* %arrayidx28.i, align 8, !tbaa !0
  %arrayidx32.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay, i64 %indvars.iv8.i, i64 %indvars.iv5.i
  %4 = load double, double* %arrayidx32.i, align 8, !tbaa !0
  %5 = load double, double* %arrayidx7.i, align 8, !tbaa !0
  %mul35.i = fmul double %4, %5
  %add36.i = fadd double %3, %mul35.i
  store double %add36.i, double* %arrayidx28.i, align 8, !tbaa !0
  %indvars.iv.next6.i = add nuw nsw i64 %indvars.iv5.i, 1
  %exitcond7.i = icmp eq i64 %indvars.iv.next6.i, 4000
  br i1 %exitcond7.i, label %for.inc.42.i, label %for.body.26.i

for.inc.42.i:                                     ; preds = %for.body.26.i
  %indvars.iv.next9.i = add nuw nsw i64 %indvars.iv8.i, 1
  %exitcond10.i = icmp eq i64 %indvars.iv.next9.i, 4000
  br i1 %exitcond10.i, label %kernel_atax.exit.exitStub, label %for.body.5.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
