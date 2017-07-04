
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/smg2_setup_rap.c.hypre_SMG2RAPPeriodicNoSym_for.body.229.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_SMG2RAPPeriodicNoSym_for.body.229.lr.ph.us.us.pjit.scop(i32 %iAc.0473.us, double* %call53, double* %call28, double* %call18, double* %call43, double* %call23, double* %call, double* %call48, double* %call33, double* %call38, i32, i32 %cond95, i32, i32* %add269.us.us.out)  {
newFuncRoot:
  br label %for.body.229.lr.ph.us.us

for.cond.224.for.end.272_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.227.for.end_crit_edge.us.us
  store i32 %add269.us.us, i32* %add269.us.us.out
  ret void

for.body.229.lr.ph.us.us:                         ; preds = %for.cond.227.for.end_crit_edge.us.us, %newFuncRoot
  %loopj.1470.us.us = phi i32 [ %inc271.us.us, %for.cond.227.for.end_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %iAc.1469.us.us = phi i32 [ %add269.us.us, %for.cond.227.for.end_crit_edge.us.us ], [ %iAc.0473.us, %newFuncRoot ]
  %2 = sext i32 %iAc.1469.us.us to i64
  br label %for.body.229.us.us

for.body.229.us.us:                               ; preds = %for.body.229.us.us, %for.body.229.lr.ph.us.us
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body.229.us.us ], [ %2, %for.body.229.lr.ph.us.us ]
  %loopi.1467.us.us = phi i32 [ %inc.us.us, %for.body.229.us.us ], [ 0, %for.body.229.lr.ph.us.us ]
  %arrayidx231.us.us = getelementptr inbounds double, double* %call53, i64 %indvars.iv
  %3 = load double, double* %arrayidx231.us.us, align 8, !tbaa !0
  %arrayidx233.us.us = getelementptr inbounds double, double* %call28, i64 %indvars.iv
  %4 = load double, double* %arrayidx233.us.us, align 8, !tbaa !0
  %add234.us.us = fadd double %3, %4
  %arrayidx236.us.us = getelementptr inbounds double, double* %call18, i64 %indvars.iv
  %5 = load double, double* %arrayidx236.us.us, align 8, !tbaa !0
  %add237.us.us = fadd double %5, %add234.us.us
  store double %add237.us.us, double* %arrayidx236.us.us, align 8, !tbaa !0
  store double 0.000000e+00, double* %arrayidx231.us.us, align 8, !tbaa !0
  store double 0.000000e+00, double* %arrayidx233.us.us, align 8, !tbaa !0
  %arrayidx243.us.us = getelementptr inbounds double, double* %call43, i64 %indvars.iv
  %6 = load double, double* %arrayidx243.us.us, align 8, !tbaa !0
  %arrayidx245.us.us = getelementptr inbounds double, double* %call23, i64 %indvars.iv
  %7 = load double, double* %arrayidx245.us.us, align 8, !tbaa !0
  %add246.us.us = fadd double %6, %7
  %arrayidx248.us.us = getelementptr inbounds double, double* %call, i64 %indvars.iv
  %8 = load double, double* %arrayidx248.us.us, align 8, !tbaa !0
  %add249.us.us = fadd double %8, %add246.us.us
  store double %add249.us.us, double* %arrayidx248.us.us, align 8, !tbaa !0
  store double 0.000000e+00, double* %arrayidx243.us.us, align 8, !tbaa !0
  store double 0.000000e+00, double* %arrayidx245.us.us, align 8, !tbaa !0
  %arrayidx255.us.us = getelementptr inbounds double, double* %call48, i64 %indvars.iv
  %9 = load double, double* %arrayidx255.us.us, align 8, !tbaa !0
  %arrayidx257.us.us = getelementptr inbounds double, double* %call33, i64 %indvars.iv
  %10 = load double, double* %arrayidx257.us.us, align 8, !tbaa !0
  %add258.us.us = fadd double %9, %10
  %arrayidx260.us.us = getelementptr inbounds double, double* %call38, i64 %indvars.iv
  %11 = load double, double* %arrayidx260.us.us, align 8, !tbaa !0
  %add261.us.us = fadd double %11, %add258.us.us
  store double %add261.us.us, double* %arrayidx260.us.us, align 8, !tbaa !0
  store double 0.000000e+00, double* %arrayidx255.us.us, align 8, !tbaa !0
  store double 0.000000e+00, double* %arrayidx257.us.us, align 8, !tbaa !0
  %inc.us.us = add nuw nsw i32 %loopi.1467.us.us, 1
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %exitcond518 = icmp eq i32 %inc.us.us, %0
  br i1 %exitcond518, label %for.cond.227.for.end_crit_edge.us.us, label %for.body.229.us.us

for.cond.227.for.end_crit_edge.us.us:             ; preds = %for.body.229.us.us
  %add269.us.us = add i32 %iAc.1469.us.us, %cond95
  %inc271.us.us = add nuw nsw i32 %loopj.1470.us.us, 1
  %exitcond520 = icmp eq i32 %inc271.us.us, %1
  br i1 %exitcond520, label %for.cond.224.for.end.272_crit_edge.us.loopexit.exitStub, label %for.body.229.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
