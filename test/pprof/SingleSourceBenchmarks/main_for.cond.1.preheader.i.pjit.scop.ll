
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Misc/dt.c.main_for.cond.1.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.1.preheader.i.pjit.scop(double*, double*)  {
newFuncRoot:
  br label %for.cond.1.preheader.i

double_array_divs_variable.exit.exitStub:         ; preds = %for.inc.5.i
  ret void

for.cond.1.preheader.i:                           ; preds = %for.inc.5.i, %newFuncRoot
  %j.015.i = phi i64 [ 0, %newFuncRoot ], [ %inc6.i, %for.inc.5.i ]
  br label %for.body.3.i

for.body.3.i:                                     ; preds = %for.body.3.i, %for.cond.1.preheader.i
  %i.014.i = phi i64 [ 0, %for.cond.1.preheader.i ], [ %inc.i, %for.body.3.i ]
  %arrayidx.i = getelementptr inbounds double, double* %0, i64 %i.014.i
  %2 = load double, double* %arrayidx.i, align 8, !tbaa !0, !alias.scope !4, !noalias !7
  %arrayidx4.i = getelementptr inbounds double, double* %1, i64 %i.014.i
  %3 = load double, double* %arrayidx4.i, align 8, !tbaa !0, !alias.scope !7, !noalias !4
  %div.i = fdiv double %3, %2
  store double %div.i, double* %arrayidx4.i, align 8, !tbaa !0, !alias.scope !7, !noalias !4
  %inc.i = add nuw nsw i64 %i.014.i, 1
  %exitcond.i = icmp eq i64 %inc.i, 2048
  br i1 %exitcond.i, label %for.inc.5.i, label %for.body.3.i

for.inc.5.i:                                      ; preds = %for.body.3.i
  %inc6.i = add nuw nsw i64 %j.015.i, 1
  %exitcond16.i = icmp eq i64 %inc6.i, 131072
  br i1 %exitcond16.i, label %double_array_divs_variable.exit.exitStub, label %for.cond.1.preheader.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5}
!5 = distinct !{!5, !6, !"double_array_divs_variable: %dvec2"}
!6 = distinct !{!6, !"double_array_divs_variable"}
!7 = !{!8}
!8 = distinct !{!8, !6, !"double_array_divs_variable: %dvec1"}
