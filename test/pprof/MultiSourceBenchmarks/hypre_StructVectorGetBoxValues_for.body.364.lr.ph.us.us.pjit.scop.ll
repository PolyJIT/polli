
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/struct_vector.c.hypre_StructVectorGetBoxValues_for.body.364.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_StructVectorGetBoxValues_for.body.364.lr.ph.us.us.pjit.scop(i32 %datai.0631.us, i32 %dvali.0630.us, double* %add.ptr, double* %values, i32, i32 %cond117, i32 %cond167, i32, i32* %add376.us.us.out, i32* %add379.us.us.out)  {
newFuncRoot:
  br label %for.body.364.lr.ph.us.us

for.cond.359.for.end.382_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.362.for.end.373_crit_edge.us.us
  store i32 %add376.us.us, i32* %add376.us.us.out
  store i32 %add379.us.us, i32* %add379.us.us.out
  ret void

for.body.364.lr.ph.us.us:                         ; preds = %for.cond.362.for.end.373_crit_edge.us.us, %newFuncRoot
  %datai.1625.us.us = phi i32 [ %add376.us.us, %for.cond.362.for.end.373_crit_edge.us.us ], [ %datai.0631.us, %newFuncRoot ]
  %dvali.1624.us.us = phi i32 [ %add379.us.us, %for.cond.362.for.end.373_crit_edge.us.us ], [ %dvali.0630.us, %newFuncRoot ]
  %loopj.1623.us.us = phi i32 [ %inc381.us.us, %for.cond.362.for.end.373_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %2 = sext i32 %datai.1625.us.us to i64
  %3 = sext i32 %dvali.1624.us.us to i64
  br label %for.body.364.us.us

for.body.364.us.us:                               ; preds = %for.body.364.us.us, %for.body.364.lr.ph.us.us
  %indvars.iv755 = phi i64 [ %indvars.iv.next756, %for.body.364.us.us ], [ %3, %for.body.364.lr.ph.us.us ]
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body.364.us.us ], [ %2, %for.body.364.lr.ph.us.us ]
  %loopi.1618.us.us = phi i32 [ %inc372.us.us, %for.body.364.us.us ], [ 0, %for.body.364.lr.ph.us.us ]
  %arrayidx366.us.us = getelementptr inbounds double, double* %add.ptr, i64 %indvars.iv
  %4 = bitcast double* %arrayidx366.us.us to i64*
  %5 = load i64, i64* %4, align 8, !tbaa !0
  %arrayidx368.us.us = getelementptr inbounds double, double* %values, i64 %indvars.iv755
  %6 = bitcast double* %arrayidx368.us.us to i64*
  store i64 %5, i64* %6, align 8, !tbaa !0
  %inc372.us.us = add nuw nsw i32 %loopi.1618.us.us, 1
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %indvars.iv.next756 = add nsw i64 %indvars.iv755, 1
  %exitcond757 = icmp eq i32 %inc372.us.us, %0
  br i1 %exitcond757, label %for.cond.362.for.end.373_crit_edge.us.us, label %for.body.364.us.us

for.cond.362.for.end.373_crit_edge.us.us:         ; preds = %for.body.364.us.us
  %add376.us.us = add i32 %datai.1625.us.us, %cond117
  %add379.us.us = add i32 %dvali.1624.us.us, %cond167
  %inc381.us.us = add nuw nsw i32 %loopj.1623.us.us, 1
  %exitcond760 = icmp eq i32 %inc381.us.us, %1
  br i1 %exitcond760, label %for.cond.359.for.end.382_crit_edge.us.loopexit.exitStub, label %for.body.364.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
