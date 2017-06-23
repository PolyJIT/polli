
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/smg_residual.c.hypre_SMGResidual_for.body.314.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_SMGResidual_for.body.314.lr.ph.us.us.pjit.scop(i32 %bi.01407.us, i32 %ri.01406.us, double* %add.ptr, double* %add.ptr26, i64, i32, i32, i32 %sub325, i32, i32, i32* %add323.us.us.out, i32* %add326.us.us.out)  {
newFuncRoot:
  br label %for.body.314.lr.ph.us.us

for.cond.309.for.end.329_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.312.for.end_crit_edge.us.us
  store i32 %add323.us.us, i32* %add323.us.us.out
  store i32 %add326.us.us, i32* %add326.us.us.out
  ret void

for.body.314.lr.ph.us.us:                         ; preds = %for.cond.312.for.end_crit_edge.us.us, %newFuncRoot
  %bi.11401.us.us = phi i32 [ %add323.us.us, %for.cond.312.for.end_crit_edge.us.us ], [ %bi.01407.us, %newFuncRoot ]
  %ri.11400.us.us = phi i32 [ %add326.us.us, %for.cond.312.for.end_crit_edge.us.us ], [ %ri.01406.us, %newFuncRoot ]
  %loopj.11399.us.us = phi i32 [ %inc328.us.us, %for.cond.312.for.end_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %5 = sext i32 %bi.11401.us.us to i64
  %6 = sext i32 %ri.11400.us.us to i64
  br label %for.body.314.us.us

for.body.314.us.us:                               ; preds = %for.body.314.us.us, %for.body.314.lr.ph.us.us
  %indvars.iv1622 = phi i64 [ %indvars.iv.next1623, %for.body.314.us.us ], [ %6, %for.body.314.lr.ph.us.us ]
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body.314.us.us ], [ %5, %for.body.314.lr.ph.us.us ]
  %loopi.11394.us.us = phi i32 [ %inc.us.us, %for.body.314.us.us ], [ 0, %for.body.314.lr.ph.us.us ]
  %arrayidx316.us.us = getelementptr inbounds double, double* %add.ptr, i64 %indvars.iv
  %7 = bitcast double* %arrayidx316.us.us to i64*
  %8 = load i64, i64* %7, align 8, !tbaa !0
  %arrayidx318.us.us = getelementptr inbounds double, double* %add.ptr26, i64 %indvars.iv1622
  %9 = bitcast double* %arrayidx318.us.us to i64*
  store i64 %8, i64* %9, align 8, !tbaa !0
  %inc.us.us = add nuw nsw i32 %loopi.11394.us.us, 1
  %indvars.iv.next = add i64 %indvars.iv, %0
  %indvars.iv.next1623 = add i64 %indvars.iv1622, %0
  %exitcond1624 = icmp eq i32 %inc.us.us, %1
  br i1 %exitcond1624, label %for.cond.312.for.end_crit_edge.us.us, label %for.body.314.us.us

for.cond.312.for.end_crit_edge.us.us:             ; preds = %for.body.314.us.us
  %add323.us.us = add i32 %2, %bi.11401.us.us
  %10 = add i32 %sub325, %3
  %add326.us.us = add i32 %10, %ri.11400.us.us
  %inc328.us.us = add nuw nsw i32 %loopj.11399.us.us, 1
  %exitcond1627 = icmp eq i32 %inc328.us.us, %4
  br i1 %exitcond1627, label %for.cond.309.for.end.329_crit_edge.us.loopexit.exitStub, label %for.body.314.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
