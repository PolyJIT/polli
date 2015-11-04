
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/HYPRE_struct_pcg.c.HYPRE_StructDiagScale_for.body.429.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @HYPRE_StructDiagScale_for.body.429.lr.ph.us.us.pjit.scop(i32 %Ai.0729.us, i32 %yi.0728.us, i32 %xi.0727.us, double* %add.ptr27, double* %call, double* %add.ptr, i32, i32 %cond70, i32 %cond120, i32 %cond170, i32, i32* %add442.us.us.out, i32* %add445.us.us.out, i32* %add448.us.us.out)  {
newFuncRoot:
  br label %for.body.429.lr.ph.us.us

for.cond.424.for.end.451_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.427.for.end_crit_edge.us.us
  store i32 %add442.us.us, i32* %add442.us.us.out
  store i32 %add445.us.us, i32* %add445.us.us.out
  store i32 %add448.us.us, i32* %add448.us.us.out
  ret void

for.body.429.lr.ph.us.us:                         ; preds = %for.cond.427.for.end_crit_edge.us.us, %newFuncRoot
  %Ai.1721.us.us = phi i32 [ %add442.us.us, %for.cond.427.for.end_crit_edge.us.us ], [ %Ai.0729.us, %newFuncRoot ]
  %yi.1720.us.us = phi i32 [ %add448.us.us, %for.cond.427.for.end_crit_edge.us.us ], [ %yi.0728.us, %newFuncRoot ]
  %xi.1719.us.us = phi i32 [ %add445.us.us, %for.cond.427.for.end_crit_edge.us.us ], [ %xi.0727.us, %newFuncRoot ]
  %loopj.1718.us.us = phi i32 [ %inc450.us.us, %for.cond.427.for.end_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %2 = sext i32 %Ai.1721.us.us to i64
  %3 = sext i32 %yi.1720.us.us to i64
  %4 = sext i32 %xi.1719.us.us to i64
  br label %for.body.429.us.us

for.body.429.us.us:                               ; preds = %for.body.429.us.us, %for.body.429.lr.ph.us.us
  %indvars.iv782 = phi i64 [ %indvars.iv.next783, %for.body.429.us.us ], [ %4, %for.body.429.lr.ph.us.us ]
  %indvars.iv780 = phi i64 [ %indvars.iv.next781, %for.body.429.us.us ], [ %3, %for.body.429.lr.ph.us.us ]
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body.429.us.us ], [ %2, %for.body.429.lr.ph.us.us ]
  %loopi.1711.us.us = phi i32 [ %inc.us.us, %for.body.429.us.us ], [ 0, %for.body.429.lr.ph.us.us ]
  %arrayidx431.us.us = getelementptr inbounds double, double* %add.ptr27, i64 %indvars.iv780
  %5 = load double, double* %arrayidx431.us.us, align 8, !tbaa !0
  %arrayidx433.us.us = getelementptr inbounds double, double* %call, i64 %indvars.iv
  %6 = load double, double* %arrayidx433.us.us, align 8, !tbaa !0
  %div434.us.us = fdiv double %5, %6
  %arrayidx436.us.us = getelementptr inbounds double, double* %add.ptr, i64 %indvars.iv782
  store double %div434.us.us, double* %arrayidx436.us.us, align 8, !tbaa !0
  %inc.us.us = add nuw nsw i32 %loopi.1711.us.us, 1
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %indvars.iv.next781 = add nsw i64 %indvars.iv780, 1
  %indvars.iv.next783 = add nsw i64 %indvars.iv782, 1
  %exitcond784 = icmp eq i32 %inc.us.us, %0
  br i1 %exitcond784, label %for.cond.427.for.end_crit_edge.us.us, label %for.body.429.us.us

for.cond.427.for.end_crit_edge.us.us:             ; preds = %for.body.429.us.us
  %add442.us.us = add i32 %Ai.1721.us.us, %cond70
  %add445.us.us = add i32 %xi.1719.us.us, %cond120
  %add448.us.us = add i32 %yi.1720.us.us, %cond170
  %inc450.us.us = add nuw nsw i32 %loopj.1718.us.us, 1
  %exitcond788 = icmp eq i32 %inc450.us.us, %1
  br i1 %exitcond788, label %for.cond.424.for.end.451_crit_edge.us.loopexit.exitStub, label %for.body.429.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
