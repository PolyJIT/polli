
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/PAQ8p/paq8p.cpp._Z8wavModelR5Mixer_for.body.402.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_Z8wavModelR5Mixer_for.body.402.us.pjit.scop(i64 %indvars.iv3368, [49 x [49 x [2 x double]]]* %F, i64 %indvars.iv3372, i64 %idxprom276, [49 x [49 x double]]* %L, i32 %indvars.iv3441, double* %arrayidx397, i64)  {
newFuncRoot:
  br label %for.body.402.us

for.cond.365.loopexit.exitStub:                   ; preds = %for.cond.365.loopexit.loopexit
  ret void

for.body.402.us:                                  ; preds = %for.cond.409.for.end.424_crit_edge.us, %newFuncRoot
  %indvars.iv3370 = phi i64 [ %indvars.iv.next3371, %for.cond.409.for.end.424_crit_edge.us ], [ %indvars.iv3368, %newFuncRoot ]
  %arrayidx408.us = getelementptr inbounds [49 x [49 x [2 x double]]], [49 x [49 x [2 x double]]]* %F, i64 0, i64 %indvars.iv3372, i64 %indvars.iv3370, i64 %idxprom276
  %1 = load double, double* %arrayidx408.us, align 8, !tbaa !0
  br label %for.body.411.us

for.body.411.us:                                  ; preds = %for.body.411.us, %for.body.402.us
  %indvars.iv3362 = phi i64 [ 1, %for.body.402.us ], [ %indvars.iv.next3363, %for.body.411.us ]
  %sum.13280.us = phi double [ %1, %for.body.402.us ], [ %sub421.us, %for.body.411.us ]
  %arrayidx415.us = getelementptr inbounds [49 x [49 x double]], [49 x [49 x double]]* %L, i64 0, i64 %indvars.iv3370, i64 %indvars.iv3362
  %2 = load double, double* %arrayidx415.us, align 8, !tbaa !0
  %arrayidx419.us = getelementptr inbounds [49 x [49 x double]], [49 x [49 x double]]* %L, i64 0, i64 %indvars.iv3372, i64 %indvars.iv3362
  %3 = load double, double* %arrayidx419.us, align 8, !tbaa !0
  %mul420.us = fmul double %2, %3
  %sub421.us = fsub double %sum.13280.us, %mul420.us
  %indvars.iv.next3363 = add nuw nsw i64 %indvars.iv3362, 1
  %lftr.wideiv3443 = trunc i64 %indvars.iv.next3363 to i32
  %exitcond3444 = icmp eq i32 %lftr.wideiv3443, %indvars.iv3441
  br i1 %exitcond3444, label %for.cond.409.for.end.424_crit_edge.us, label %for.body.411.us

for.cond.409.for.end.424_crit_edge.us:            ; preds = %for.body.411.us
  %sub421.us.lcssa = phi double [ %sub421.us, %for.body.411.us ]
  %4 = load double, double* %arrayidx397, align 8, !tbaa !0
  %div429.us = fdiv double %sub421.us.lcssa, %4
  %arrayidx433.us = getelementptr inbounds [49 x [49 x double]], [49 x [49 x double]]* %L, i64 0, i64 %indvars.iv3370, i64 %indvars.iv3372
  store double %div429.us, double* %arrayidx433.us, align 8, !tbaa !0
  %cmp401.us = icmp slt i64 %indvars.iv3370, %0
  %indvars.iv.next3371 = add nuw i64 %indvars.iv3370, 1
  br i1 %cmp401.us, label %for.body.402.us, label %for.cond.365.loopexit.loopexit

for.cond.365.loopexit.loopexit:                   ; preds = %for.cond.409.for.end.424_crit_edge.us
  br label %for.cond.365.loopexit.exitStub
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
