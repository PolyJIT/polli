
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/smg_setup_interp.c.hypre_SMGSetupInterpOp_for.body.442.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_SMGSetupInterpOp_for.body.442.lr.ph.us.us.pjit.scop(i32 %PTi.0777.us, i32 %xi.0776.us, double* %add.ptr, double* %add.ptr91, i64, i32, i32, i32 %cond220, i32, i32* %add454.us.us.out, i32* %add457.us.us.out)  {
newFuncRoot:
  br label %for.body.442.lr.ph.us.us

for.cond.435.for.end.460_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.439.for.end.451_crit_edge.us.us
  store i32 %add454.us.us, i32* %add454.us.us.out
  store i32 %add457.us.us, i32* %add457.us.us.out
  ret void

for.body.442.lr.ph.us.us:                         ; preds = %for.cond.439.for.end.451_crit_edge.us.us, %newFuncRoot
  %PTi.1771.us.us = phi i32 [ %add457.us.us, %for.cond.439.for.end.451_crit_edge.us.us ], [ %PTi.0777.us, %newFuncRoot ]
  %xi.1770.us.us = phi i32 [ %add454.us.us, %for.cond.439.for.end.451_crit_edge.us.us ], [ %xi.0776.us, %newFuncRoot ]
  %loopj.1769.us.us = phi i32 [ %inc459.us.us, %for.cond.439.for.end.451_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %4 = sext i32 %PTi.1771.us.us to i64
  %5 = sext i32 %xi.1770.us.us to i64
  br label %for.body.442.us.us

for.body.442.us.us:                               ; preds = %for.body.442.us.us, %for.body.442.lr.ph.us.us
  %indvars.iv922 = phi i64 [ %indvars.iv.next923, %for.body.442.us.us ], [ %5, %for.body.442.lr.ph.us.us ]
  %indvars.iv920 = phi i64 [ %indvars.iv.next921, %for.body.442.us.us ], [ %4, %for.body.442.lr.ph.us.us ]
  %loopi.1763.us.us = phi i32 [ %inc450.us.us, %for.body.442.us.us ], [ 0, %for.body.442.lr.ph.us.us ]
  %arrayidx444.us.us = getelementptr inbounds double, double* %add.ptr, i64 %indvars.iv922
  %6 = bitcast double* %arrayidx444.us.us to i64*
  %7 = load i64, i64* %6, align 8, !tbaa !0
  %arrayidx446.us.us = getelementptr inbounds double, double* %add.ptr91, i64 %indvars.iv920
  %8 = bitcast double* %arrayidx446.us.us to i64*
  store i64 %7, i64* %8, align 8, !tbaa !0
  %inc450.us.us = add nuw nsw i32 %loopi.1763.us.us, 1
  %indvars.iv.next921 = add nsw i64 %indvars.iv920, 1
  %indvars.iv.next923 = add i64 %indvars.iv922, %0
  %exitcond924 = icmp eq i32 %inc450.us.us, %1
  br i1 %exitcond924, label %for.cond.439.for.end.451_crit_edge.us.us, label %for.body.442.us.us

for.cond.439.for.end.451_crit_edge.us.us:         ; preds = %for.body.442.us.us
  %add454.us.us = add i32 %2, %xi.1770.us.us
  %add457.us.us = add i32 %PTi.1771.us.us, %cond220
  %inc459.us.us = add nuw nsw i32 %loopj.1769.us.us, 1
  %exitcond927 = icmp eq i32 %inc459.us.us, %3
  br i1 %exitcond927, label %for.cond.435.for.end.460_crit_edge.us.loopexit.exitStub, label %for.body.442.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
