
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/solvers/gramschmidt/gramschmidt.c.main_for.body.35.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.35.i.pjit.scop(i64 %indvars.iv18.i, [512 x double]* %arraydecay3, i64 %indvars.iv23.i, [512 x double]* %arraydecay4, [512 x double]* %arraydecay)  {
newFuncRoot:
  br label %for.body.35.i

for.cond.loopexit.i.loopexit.exitStub:            ; preds = %for.inc.83.i
  ret void

for.body.35.i:                                    ; preds = %for.inc.83.i, %newFuncRoot
  %indvars.iv20.i = phi i64 [ %indvars.iv.next21.i, %for.inc.83.i ], [ %indvars.iv18.i, %newFuncRoot ]
  %arrayidx39.i = getelementptr inbounds [512 x double], [512 x double]* %arraydecay3, i64 %indvars.iv23.i, i64 %indvars.iv20.i
  store double 0.000000e+00, double* %arrayidx39.i, align 8, !tbaa !0
  br label %for.body.42.i

for.body.42.i:                                    ; preds = %for.body.42.i, %for.body.35.i
  %indvars.iv12.i.55 = phi i64 [ 0, %for.body.35.i ], [ %indvars.iv.next13.i.56, %for.body.42.i ]
  %arrayidx46.i = getelementptr inbounds [512 x double], [512 x double]* %arraydecay4, i64 %indvars.iv12.i.55, i64 %indvars.iv23.i
  %0 = load double, double* %arrayidx46.i, align 8, !tbaa !0
  %arrayidx50.i = getelementptr inbounds [512 x double], [512 x double]* %arraydecay, i64 %indvars.iv12.i.55, i64 %indvars.iv20.i
  %1 = load double, double* %arrayidx50.i, align 8, !tbaa !0
  %mul51.i = fmul double %0, %1
  %2 = load double, double* %arrayidx39.i, align 8, !tbaa !0
  %add56.i = fadd double %2, %mul51.i
  store double %add56.i, double* %arrayidx39.i, align 8, !tbaa !0
  %indvars.iv.next13.i.56 = add nuw nsw i64 %indvars.iv12.i.55, 1
  %exitcond14.i.57 = icmp eq i64 %indvars.iv.next13.i.56, 512
  br i1 %exitcond14.i.57, label %for.body.62.i.preheader, label %for.body.42.i

for.body.62.i.preheader:                          ; preds = %for.body.42.i
  br label %for.body.62.i

for.body.62.i:                                    ; preds = %for.body.62.i, %for.body.62.i.preheader
  %indvars.iv15.i = phi i64 [ %indvars.iv.next16.i, %for.body.62.i ], [ 0, %for.body.62.i.preheader ]
  %arrayidx66.i = getelementptr inbounds [512 x double], [512 x double]* %arraydecay, i64 %indvars.iv15.i, i64 %indvars.iv20.i
  %3 = load double, double* %arrayidx66.i, align 8, !tbaa !0
  %arrayidx70.i = getelementptr inbounds [512 x double], [512 x double]* %arraydecay4, i64 %indvars.iv15.i, i64 %indvars.iv23.i
  %4 = load double, double* %arrayidx70.i, align 8, !tbaa !0
  %5 = load double, double* %arrayidx39.i, align 8, !tbaa !0
  %mul75.i = fmul double %4, %5
  %sub.i = fsub double %3, %mul75.i
  store double %sub.i, double* %arrayidx66.i, align 8, !tbaa !0
  %indvars.iv.next16.i = add nuw nsw i64 %indvars.iv15.i, 1
  %exitcond17.i = icmp eq i64 %indvars.iv.next16.i, 512
  br i1 %exitcond17.i, label %for.inc.83.i, label %for.body.62.i

for.inc.83.i:                                     ; preds = %for.body.62.i
  %indvars.iv.next21.i = add nuw nsw i64 %indvars.iv20.i, 1
  %lftr.wideiv74 = trunc i64 %indvars.iv.next21.i to i32
  %exitcond75 = icmp eq i32 %lftr.wideiv74, 512
  br i1 %exitcond75, label %for.cond.loopexit.i.loopexit.exitStub, label %for.body.35.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
