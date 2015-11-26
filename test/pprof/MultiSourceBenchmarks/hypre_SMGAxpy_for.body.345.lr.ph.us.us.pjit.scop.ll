
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/smg_axpy.c.hypre_SMGAxpy_for.body.345.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_SMGAxpy_for.body.345.lr.ph.us.us.pjit.scop(i32 %xi.0593.us, i32 %yi.0592.us, double* %add.ptr, double %alpha, double* %add.ptr56, i64, i32, i32, i32 %sub358, i32, i32, i32* %add356.us.us.out, i32* %add359.us.us.out)  {
newFuncRoot:
  br label %for.body.345.lr.ph.us.us

for.cond.340.for.end.362_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.343.for.end_crit_edge.us.us
  store i32 %add356.us.us, i32* %add356.us.us.out
  store i32 %add359.us.us, i32* %add359.us.us.out
  ret void

for.body.345.lr.ph.us.us:                         ; preds = %for.cond.343.for.end_crit_edge.us.us, %newFuncRoot
  %xi.1587.us.us = phi i32 [ %add356.us.us, %for.cond.343.for.end_crit_edge.us.us ], [ %xi.0593.us, %newFuncRoot ]
  %yi.1586.us.us = phi i32 [ %add359.us.us, %for.cond.343.for.end_crit_edge.us.us ], [ %yi.0592.us, %newFuncRoot ]
  %loopj.1585.us.us = phi i32 [ %inc361.us.us, %for.cond.343.for.end_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %5 = sext i32 %xi.1587.us.us to i64
  %6 = sext i32 %yi.1586.us.us to i64
  br label %for.body.345.us.us

for.body.345.us.us:                               ; preds = %for.body.345.us.us, %for.body.345.lr.ph.us.us
  %indvars.iv635 = phi i64 [ %indvars.iv.next636, %for.body.345.us.us ], [ %6, %for.body.345.lr.ph.us.us ]
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body.345.us.us ], [ %5, %for.body.345.lr.ph.us.us ]
  %loopi.1580.us.us = phi i32 [ %inc.us.us, %for.body.345.us.us ], [ 0, %for.body.345.lr.ph.us.us ]
  %arrayidx347.us.us = getelementptr inbounds double, double* %add.ptr, i64 %indvars.iv
  %7 = load double, double* %arrayidx347.us.us, align 8, !tbaa !0
  %mul348.us.us = fmul double %7, %alpha
  %arrayidx350.us.us = getelementptr inbounds double, double* %add.ptr56, i64 %indvars.iv635
  %8 = load double, double* %arrayidx350.us.us, align 8, !tbaa !0
  %add351.us.us = fadd double %8, %mul348.us.us
  store double %add351.us.us, double* %arrayidx350.us.us, align 8, !tbaa !0
  %inc.us.us = add nuw nsw i32 %loopi.1580.us.us, 1
  %indvars.iv.next = add i64 %indvars.iv, %0
  %indvars.iv.next636 = add i64 %indvars.iv635, %0
  %exitcond637 = icmp eq i32 %inc.us.us, %1
  br i1 %exitcond637, label %for.cond.343.for.end_crit_edge.us.us, label %for.body.345.us.us

for.cond.343.for.end_crit_edge.us.us:             ; preds = %for.body.345.us.us
  %add356.us.us = add i32 %2, %xi.1587.us.us
  %9 = add i32 %sub358, %3
  %add359.us.us = add i32 %9, %yi.1586.us.us
  %inc361.us.us = add nuw nsw i32 %loopj.1585.us.us, 1
  %exitcond640 = icmp eq i32 %inc361.us.us, %4
  br i1 %exitcond640, label %for.cond.340.for.end.362_crit_edge.us.loopexit.exitStub, label %for.body.345.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
