
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/semi_interp.c.hypre_SemiInterp_for.body.333.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_SemiInterp_for.body.333.lr.ph.us.us.pjit.scop(i32 %xci.01445.us, i32 %ei.01444.us, double* %add.ptr45, double* %add.ptr, i64, i32, i32, i32 %cond137, i32, i32* %add343.us.us.out, i32* %add346.us.us.out)  {
newFuncRoot:
  br label %for.body.333.lr.ph.us.us

for.cond.328.for.end.349_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.331.for.end_crit_edge.us.us
  store i32 %add343.us.us, i32* %add343.us.us.out
  store i32 %add346.us.us, i32* %add346.us.us.out
  ret void

for.body.333.lr.ph.us.us:                         ; preds = %for.cond.331.for.end_crit_edge.us.us, %newFuncRoot
  %xci.11439.us.us = phi i32 [ %add346.us.us, %for.cond.331.for.end_crit_edge.us.us ], [ %xci.01445.us, %newFuncRoot ]
  %ei.11438.us.us = phi i32 [ %add343.us.us, %for.cond.331.for.end_crit_edge.us.us ], [ %ei.01444.us, %newFuncRoot ]
  %loopj.11437.us.us = phi i32 [ %inc348.us.us, %for.cond.331.for.end_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %4 = sext i32 %xci.11439.us.us to i64
  %5 = sext i32 %ei.11438.us.us to i64
  br label %for.body.333.us.us

for.body.333.us.us:                               ; preds = %for.body.333.us.us, %for.body.333.lr.ph.us.us
  %indvars.iv1625 = phi i64 [ %indvars.iv.next1626, %for.body.333.us.us ], [ %5, %for.body.333.lr.ph.us.us ]
  %indvars.iv1623 = phi i64 [ %indvars.iv.next1624, %for.body.333.us.us ], [ %4, %for.body.333.lr.ph.us.us ]
  %loopi.11431.us.us = phi i32 [ %inc340.us.us, %for.body.333.us.us ], [ 0, %for.body.333.lr.ph.us.us ]
  %arrayidx335.us.us = getelementptr inbounds double, double* %add.ptr45, i64 %indvars.iv1623
  %6 = bitcast double* %arrayidx335.us.us to i64*
  %7 = load i64, i64* %6, align 8, !tbaa !0
  %arrayidx337.us.us = getelementptr inbounds double, double* %add.ptr, i64 %indvars.iv1625
  %8 = bitcast double* %arrayidx337.us.us to i64*
  store i64 %7, i64* %8, align 8, !tbaa !0
  %inc340.us.us = add nuw nsw i32 %loopi.11431.us.us, 1
  %indvars.iv.next1624 = add nsw i64 %indvars.iv1623, 1
  %indvars.iv.next1626 = add i64 %indvars.iv1625, %0
  %exitcond1627 = icmp eq i32 %inc340.us.us, %1
  br i1 %exitcond1627, label %for.cond.331.for.end_crit_edge.us.us, label %for.body.333.us.us

for.cond.331.for.end_crit_edge.us.us:             ; preds = %for.body.333.us.us
  %add343.us.us = add i32 %2, %ei.11438.us.us
  %add346.us.us = add i32 %xci.11439.us.us, %cond137
  %inc348.us.us = add nuw nsw i32 %loopj.11437.us.us, 1
  %exitcond1630 = icmp eq i32 %inc348.us.us, %3
  br i1 %exitcond1630, label %for.cond.328.for.end.349_crit_edge.us.loopexit.exitStub, label %for.body.333.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
