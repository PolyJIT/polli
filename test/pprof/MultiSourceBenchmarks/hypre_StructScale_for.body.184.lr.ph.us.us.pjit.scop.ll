
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/struct_scale.c.hypre_StructScale_for.body.184.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_StructScale_for.body.184.lr.ph.us.us.pjit.scop(i32 %yi.0344.us, double* %add.ptr, double %alpha, i32, i32 %cond51, i32, i32* %add191.us.us.out)  {
newFuncRoot:
  br label %for.body.184.lr.ph.us.us

for.cond.179.for.end.194_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.182.for.end_crit_edge.us.us
  store i32 %add191.us.us, i32* %add191.us.us.out
  ret void

for.body.184.lr.ph.us.us:                         ; preds = %for.cond.182.for.end_crit_edge.us.us, %newFuncRoot
  %yi.1340.us.us = phi i32 [ %add191.us.us, %for.cond.182.for.end_crit_edge.us.us ], [ %yi.0344.us, %newFuncRoot ]
  %loopj.1339.us.us = phi i32 [ %inc193.us.us, %for.cond.182.for.end_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %2 = sext i32 %yi.1340.us.us to i64
  br label %for.body.184.us.us

for.body.184.us.us:                               ; preds = %for.body.184.us.us, %for.body.184.lr.ph.us.us
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body.184.us.us ], [ %2, %for.body.184.lr.ph.us.us ]
  %loopi.1336.us.us = phi i32 [ %inc.us.us, %for.body.184.us.us ], [ 0, %for.body.184.lr.ph.us.us ]
  %arrayidx186.us.us = getelementptr inbounds double, double* %add.ptr, i64 %indvars.iv
  %3 = load double, double* %arrayidx186.us.us, align 8, !tbaa !0
  %mul187.us.us = fmul double %3, %alpha
  store double %mul187.us.us, double* %arrayidx186.us.us, align 8, !tbaa !0
  %inc.us.us = add nuw nsw i32 %loopi.1336.us.us, 1
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %exitcond435 = icmp eq i32 %inc.us.us, %0
  br i1 %exitcond435, label %for.cond.182.for.end_crit_edge.us.us, label %for.body.184.us.us

for.cond.182.for.end_crit_edge.us.us:             ; preds = %for.body.184.us.us
  %add191.us.us = add i32 %yi.1340.us.us, %cond51
  %inc193.us.us = add nuw nsw i32 %loopj.1339.us.us, 1
  %exitcond437 = icmp eq i32 %inc193.us.us, %1
  br i1 %exitcond437, label %for.cond.179.for.end.194_crit_edge.us.loopexit.exitStub, label %for.body.184.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
