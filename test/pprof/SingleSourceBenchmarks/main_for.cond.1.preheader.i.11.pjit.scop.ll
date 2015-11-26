
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/stencils/seidel-2d/seidel-2d.c.main_for.cond.1.preheader.i.11.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.1.preheader.i.11.pjit.scop([1000 x double]* %arraydecay)  {
newFuncRoot:
  br label %for.cond.1.preheader.i.11

kernel_seidel_2d.exit.exitStub:                   ; preds = %for.inc.69.i
  ret void

for.cond.1.preheader.i.11:                        ; preds = %for.inc.69.i, %newFuncRoot
  %t.03.i = phi i32 [ %inc70.i, %for.inc.69.i ], [ 0, %newFuncRoot ]
  br label %for.cond.5.preheader.i

for.cond.5.preheader.i:                           ; preds = %for.inc.66.i, %for.cond.1.preheader.i.11
  %indvars.iv5.i = phi i64 [ 1, %for.cond.1.preheader.i.11 ], [ %indvars.iv.next6.i, %for.inc.66.i ]
  %0 = add nsw i64 %indvars.iv5.i, -1
  %indvars.iv.next6.i = add nuw nsw i64 %indvars.iv5.i, 1
  br label %for.body.8.i

for.body.8.i:                                     ; preds = %for.body.8.i, %for.cond.5.preheader.i
  %indvars.iv.i.12 = phi i64 [ 1, %for.cond.5.preheader.i ], [ %indvars.iv.next.i.13, %for.body.8.i ]
  %1 = add nsw i64 %indvars.iv.i.12, -1
  %arrayidx12.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %0, i64 %1
  %2 = load double, double* %arrayidx12.i, align 8, !tbaa !0
  %arrayidx17.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %0, i64 %indvars.iv.i.12
  %3 = load double, double* %arrayidx17.i, align 8, !tbaa !0
  %add.i = fadd double %2, %3
  %indvars.iv.next.i.13 = add nuw nsw i64 %indvars.iv.i.12, 1
  %arrayidx23.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %0, i64 %indvars.iv.next.i.13
  %4 = load double, double* %arrayidx23.i, align 8, !tbaa !0
  %add24.i = fadd double %add.i, %4
  %arrayidx29.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv5.i, i64 %1
  %5 = load double, double* %arrayidx29.i, align 8, !tbaa !0
  %add30.i = fadd double %add24.i, %5
  %arrayidx34.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv5.i, i64 %indvars.iv.i.12
  %6 = load double, double* %arrayidx34.i, align 8, !tbaa !0
  %add35.i = fadd double %add30.i, %6
  %arrayidx40.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv5.i, i64 %indvars.iv.next.i.13
  %7 = load double, double* %arrayidx40.i, align 8, !tbaa !0
  %add41.i = fadd double %add35.i, %7
  %arrayidx47.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv.next6.i, i64 %1
  %8 = load double, double* %arrayidx47.i, align 8, !tbaa !0
  %add48.i = fadd double %add41.i, %8
  %arrayidx53.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv.next6.i, i64 %indvars.iv.i.12
  %9 = load double, double* %arrayidx53.i, align 8, !tbaa !0
  %add54.i = fadd double %add48.i, %9
  %arrayidx60.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv.next6.i, i64 %indvars.iv.next.i.13
  %10 = load double, double* %arrayidx60.i, align 8, !tbaa !0
  %add61.i = fadd double %add54.i, %10
  %div.i.14 = fdiv double %add61.i, 9.000000e+00
  store double %div.i.14, double* %arrayidx34.i, align 8, !tbaa !0
  %exitcond.i.15 = icmp eq i64 %indvars.iv.next.i.13, 999
  br i1 %exitcond.i.15, label %for.inc.66.i, label %for.body.8.i

for.inc.66.i:                                     ; preds = %for.body.8.i
  %exitcond8.i = icmp eq i64 %indvars.iv.next6.i, 999
  br i1 %exitcond8.i, label %for.inc.69.i, label %for.cond.5.preheader.i

for.inc.69.i:                                     ; preds = %for.inc.66.i
  %inc70.i = add nuw nsw i32 %t.03.i, 1
  %exitcond9.i = icmp eq i32 %inc70.i, 20
  br i1 %exitcond9.i, label %kernel_seidel_2d.exit.exitStub, label %for.cond.1.preheader.i.11
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
