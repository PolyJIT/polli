
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/smg3_setup_rap.c.hypre_SMG3RAPPeriodicSym_for.body.348.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_SMG3RAPPeriodicSym_for.body.348.lr.ph.us.us.pjit.scop(i32 %iAc.01689.us, i64, double* %call96, double* %call121, double* %call101, double* %call106, double* %call126, double* %call111, double* %call116, double* %call131, i32, i32, i32, i32* %indvars.iv.next2077.out)  {
newFuncRoot:
  br label %for.body.348.lr.ph.us.us

for.cond.343.for.end.379_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.346.for.end_crit_edge.us.us
  store i32 %indvars.iv.next2077, i32* %indvars.iv.next2077.out
  ret void

for.body.348.lr.ph.us.us:                         ; preds = %for.cond.346.for.end_crit_edge.us.us, %newFuncRoot
  %indvars.iv2076 = phi i32 [ %iAc.01689.us, %newFuncRoot ], [ %indvars.iv.next2077, %for.cond.346.for.end_crit_edge.us.us ]
  %loopj.11686.us.us = phi i32 [ %inc378.us.us, %for.cond.346.for.end_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %4 = sext i32 %indvars.iv2076 to i64
  br label %for.body.348.us.us

for.body.348.us.us:                               ; preds = %for.body.348.us.us, %for.body.348.lr.ph.us.us
  %indvars.iv2078 = phi i64 [ %indvars.iv.next2079, %for.body.348.us.us ], [ %4, %for.body.348.lr.ph.us.us ]
  %loopi.11683.us.us = phi i32 [ %inc.us.us, %for.body.348.us.us ], [ 0, %for.body.348.lr.ph.us.us ]
  %iAc.21682.us.us = phi i32 [ %add373.us.us, %for.body.348.us.us ], [ %indvars.iv2076, %for.body.348.lr.ph.us.us ]
  %sub349.us.us = add nsw i32 %iAc.21682.us.us, -1
  %5 = sub nsw i64 %indvars.iv2078, %0
  %arrayidx352.us.us = getelementptr inbounds double, double* %call96, i64 %indvars.iv2078
  %6 = load double, double* %arrayidx352.us.us, align 8, !tbaa !0
  %mul353.us.us = fmul double %6, 2.000000e+00
  %arrayidx355.us.us = getelementptr inbounds double, double* %call121, i64 %indvars.iv2078
  %7 = load double, double* %arrayidx355.us.us, align 8, !tbaa !0
  %add356.us.us = fadd double %7, %mul353.us.us
  store double %add356.us.us, double* %arrayidx355.us.us, align 8, !tbaa !0
  %arrayidx358.us.us = getelementptr inbounds double, double* %call101, i64 %indvars.iv2078
  %8 = load double, double* %arrayidx358.us.us, align 8, !tbaa !0
  %idxprom359.us.us = sext i32 %sub349.us.us to i64
  %arrayidx360.us.us = getelementptr inbounds double, double* %call106, i64 %idxprom359.us.us
  %9 = load double, double* %arrayidx360.us.us, align 8, !tbaa !0
  %add361.us.us = fadd double %8, %9
  %arrayidx363.us.us = getelementptr inbounds double, double* %call126, i64 %indvars.iv2078
  %10 = load double, double* %arrayidx363.us.us, align 8, !tbaa !0
  %add364.us.us = fadd double %10, %add361.us.us
  store double %add364.us.us, double* %arrayidx363.us.us, align 8, !tbaa !0
  %arrayidx366.us.us = getelementptr inbounds double, double* %call111, i64 %indvars.iv2078
  %11 = load double, double* %arrayidx366.us.us, align 8, !tbaa !0
  %arrayidx368.us.us = getelementptr inbounds double, double* %call116, i64 %5
  %12 = load double, double* %arrayidx368.us.us, align 8, !tbaa !0
  %add369.us.us = fadd double %11, %12
  %arrayidx371.us.us = getelementptr inbounds double, double* %call131, i64 %indvars.iv2078
  %13 = load double, double* %arrayidx371.us.us, align 8, !tbaa !0
  %add372.us.us = fadd double %13, %add369.us.us
  store double %add372.us.us, double* %arrayidx371.us.us, align 8, !tbaa !0
  %add373.us.us = add nsw i32 %iAc.21682.us.us, 1
  %inc.us.us = add nuw nsw i32 %loopi.11683.us.us, 1
  %indvars.iv.next2079 = add nsw i64 %indvars.iv2078, 1
  %exitcond2007 = icmp eq i32 %inc.us.us, %1
  br i1 %exitcond2007, label %for.cond.346.for.end_crit_edge.us.us, label %for.body.348.us.us

for.cond.346.for.end_crit_edge.us.us:             ; preds = %for.body.348.us.us
  %indvars.iv.next2077 = add i32 %indvars.iv2076, %2
  %inc378.us.us = add nuw nsw i32 %loopj.11686.us.us, 1
  %exitcond2009 = icmp eq i32 %inc378.us.us, %3
  br i1 %exitcond2009, label %for.cond.343.for.end.379_crit_edge.us.loopexit.exitStub, label %for.body.348.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
