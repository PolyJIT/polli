
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/medley/floyd-warshall/floyd-warshall.c.main_for.cond.1.preheader.i.10.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.1.preheader.i.10.pjit.scop([1024 x double]* %arraydecay)  {
newFuncRoot:
  br label %for.cond.1.preheader.i.10

kernel_floyd_warshall.exit.exitStub:              ; preds = %for.inc.38.i
  ret void

for.cond.1.preheader.i.10:                        ; preds = %for.inc.38.i, %newFuncRoot
  %indvars.iv7.i = phi i64 [ %indvars.iv.next8.i, %for.inc.38.i ], [ 0, %newFuncRoot ]
  br label %for.cond.4.preheader.i

for.cond.4.preheader.i:                           ; preds = %for.inc.35.i, %for.cond.1.preheader.i.10
  %indvars.iv4.i = phi i64 [ 0, %for.cond.1.preheader.i.10 ], [ %indvars.iv.next5.i, %for.inc.35.i ]
  %arrayidx12.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv4.i, i64 %indvars.iv7.i
  br label %for.body.6.i

for.body.6.i:                                     ; preds = %for.body.6.i, %for.cond.4.preheader.i
  %indvars.iv.i.11 = phi i64 [ 0, %for.cond.4.preheader.i ], [ %indvars.iv.next.i.13, %for.body.6.i ]
  %arrayidx8.i.12 = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv4.i, i64 %indvars.iv.i.11
  %0 = load double, double* %arrayidx8.i.12, align 8, !tbaa !0
  %1 = load double, double* %arrayidx12.i, align 8, !tbaa !0
  %arrayidx16.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv7.i, i64 %indvars.iv.i.11
  %2 = load double, double* %arrayidx16.i, align 8, !tbaa !0
  %add.i = fadd double %1, %2
  %cmp17.i = fcmp olt double %0, %add.i
  %.add.i = select i1 %cmp17.i, double %0, double %add.i
  store double %.add.i, double* %arrayidx8.i.12, align 8, !tbaa !0
  %indvars.iv.next.i.13 = add nuw nsw i64 %indvars.iv.i.11, 1
  %exitcond.i.14 = icmp eq i64 %indvars.iv.next.i.13, 1024
  br i1 %exitcond.i.14, label %for.inc.35.i, label %for.body.6.i

for.inc.35.i:                                     ; preds = %for.body.6.i
  %indvars.iv.next5.i = add nuw nsw i64 %indvars.iv4.i, 1
  %exitcond6.i = icmp eq i64 %indvars.iv.next5.i, 1024
  br i1 %exitcond6.i, label %for.inc.38.i, label %for.cond.4.preheader.i

for.inc.38.i:                                     ; preds = %for.inc.35.i
  %indvars.iv.next8.i = add nuw nsw i64 %indvars.iv7.i, 1
  %exitcond9.i = icmp eq i64 %indvars.iv.next8.i, 1024
  br i1 %exitcond9.i, label %kernel_floyd_warshall.exit.exitStub, label %for.cond.1.preheader.i.10
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
