
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/struct_copy.c.hypre_StructCopy_for.body.307.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_StructCopy_for.body.307.lr.ph.us.us.pjit.scop(i32 %xi.0536.us, i32 %yi.0535.us, double* %add.ptr, double* %add.ptr20, i32, i32 %cond61, i32 %cond111, i32, i32* %add316.us.us.out, i32* %add319.us.us.out)  {
newFuncRoot:
  br label %for.body.307.lr.ph.us.us

for.cond.302.for.end.322_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.305.for.end_crit_edge.us.us
  store i32 %add316.us.us, i32* %add316.us.us.out
  store i32 %add319.us.us, i32* %add319.us.us.out
  ret void

for.body.307.lr.ph.us.us:                         ; preds = %for.cond.305.for.end_crit_edge.us.us, %newFuncRoot
  %xi.1530.us.us = phi i32 [ %add316.us.us, %for.cond.305.for.end_crit_edge.us.us ], [ %xi.0536.us, %newFuncRoot ]
  %yi.1529.us.us = phi i32 [ %add319.us.us, %for.cond.305.for.end_crit_edge.us.us ], [ %yi.0535.us, %newFuncRoot ]
  %loopj.1528.us.us = phi i32 [ %inc321.us.us, %for.cond.305.for.end_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %2 = sext i32 %xi.1530.us.us to i64
  %3 = sext i32 %yi.1529.us.us to i64
  br label %for.body.307.us.us

for.body.307.us.us:                               ; preds = %for.body.307.us.us, %for.body.307.lr.ph.us.us
  %indvars.iv656 = phi i64 [ %indvars.iv.next657, %for.body.307.us.us ], [ %3, %for.body.307.lr.ph.us.us ]
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body.307.us.us ], [ %2, %for.body.307.lr.ph.us.us ]
  %loopi.1523.us.us = phi i32 [ %inc.us.us, %for.body.307.us.us ], [ 0, %for.body.307.lr.ph.us.us ]
  %arrayidx309.us.us = getelementptr inbounds double, double* %add.ptr, i64 %indvars.iv
  %4 = bitcast double* %arrayidx309.us.us to i64*
  %5 = load i64, i64* %4, align 8, !tbaa !0
  %arrayidx311.us.us = getelementptr inbounds double, double* %add.ptr20, i64 %indvars.iv656
  %6 = bitcast double* %arrayidx311.us.us to i64*
  store i64 %5, i64* %6, align 8, !tbaa !0
  %inc.us.us = add nuw nsw i32 %loopi.1523.us.us, 1
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %indvars.iv.next657 = add nsw i64 %indvars.iv656, 1
  %exitcond658 = icmp eq i32 %inc.us.us, %0
  br i1 %exitcond658, label %for.cond.305.for.end_crit_edge.us.us, label %for.body.307.us.us

for.cond.305.for.end_crit_edge.us.us:             ; preds = %for.body.307.us.us
  %add316.us.us = add i32 %xi.1530.us.us, %cond61
  %add319.us.us = add i32 %yi.1529.us.us, %cond111
  %inc321.us.us = add nuw nsw i32 %loopj.1528.us.us, 1
  %exitcond661 = icmp eq i32 %inc321.us.us, %1
  br i1 %exitcond661, label %for.cond.302.for.end.322_crit_edge.us.loopexit.exitStub, label %for.body.307.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
