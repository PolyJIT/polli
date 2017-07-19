
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/semi_restrict.c.hypre_SemiRestrict_for.body.622.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_SemiRestrict_for.body.622.lr.ph.us.us.pjit.scop(i32 %Ri.01015.us, i32 %ri.01014.us, i32 %rci.01013.us, double* %add.ptr101, double* %Rp0.0, double* %add.ptr147, double* %add.ptr81, double* %add.ptr193, double* %add.ptr199, i64, i32, i32 %cond260, i32 %sub647, i32, i32 %cond360, i32, i32* %add645.us.us.out, i32* %add648.us.us.out, i32* %add651.us.us.out)  {
newFuncRoot:
  br label %for.body.622.lr.ph.us.us

for.cond.617.for.end.654_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.620.for.end_crit_edge.us.us
  store i32 %add645.us.us, i32* %add645.us.us.out
  store i32 %add648.us.us, i32* %add648.us.us.out
  store i32 %add651.us.us, i32* %add651.us.us.out
  ret void

for.body.622.lr.ph.us.us:                         ; preds = %for.cond.620.for.end_crit_edge.us.us, %newFuncRoot
  %Ri.11007.us.us = phi i32 [ %add645.us.us, %for.cond.620.for.end_crit_edge.us.us ], [ %Ri.01015.us, %newFuncRoot ]
  %ri.11006.us.us = phi i32 [ %add648.us.us, %for.cond.620.for.end_crit_edge.us.us ], [ %ri.01014.us, %newFuncRoot ]
  %rci.11005.us.us = phi i32 [ %add651.us.us, %for.cond.620.for.end_crit_edge.us.us ], [ %rci.01013.us, %newFuncRoot ]
  %loopj.11004.us.us = phi i32 [ %inc653.us.us, %for.cond.620.for.end_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %4 = sext i32 %Ri.11007.us.us to i64
  %5 = sext i32 %ri.11006.us.us to i64
  %6 = sext i32 %rci.11005.us.us to i64
  br label %for.body.622.us.us

for.body.622.us.us:                               ; preds = %for.body.622.us.us, %for.body.622.lr.ph.us.us
  %indvars.iv1091 = phi i64 [ %indvars.iv.next1092, %for.body.622.us.us ], [ %6, %for.body.622.lr.ph.us.us ]
  %indvars.iv1089 = phi i64 [ %indvars.iv.next1090, %for.body.622.us.us ], [ %5, %for.body.622.lr.ph.us.us ]
  %indvars.iv1087 = phi i64 [ %indvars.iv.next1088, %for.body.622.us.us ], [ %4, %for.body.622.lr.ph.us.us ]
  %loopi.1997.us.us = phi i32 [ %inc642.us.us, %for.body.622.us.us ], [ 0, %for.body.622.lr.ph.us.us ]
  %arrayidx624.us.us = getelementptr inbounds double, double* %add.ptr101, i64 %indvars.iv1089
  %7 = load double, double* %arrayidx624.us.us, align 8, !tbaa !0
  %arrayidx626.us.us = getelementptr inbounds double, double* %Rp0.0, i64 %indvars.iv1087
  %8 = load double, double* %arrayidx626.us.us, align 8, !tbaa !0
  %arrayidx628.us.us = getelementptr inbounds double, double* %add.ptr147, i64 %indvars.iv1089
  %9 = load double, double* %arrayidx628.us.us, align 8, !tbaa !0
  %mul629.us.us = fmul double %8, %9
  %arrayidx631.us.us = getelementptr inbounds double, double* %add.ptr81, i64 %indvars.iv1087
  %10 = load double, double* %arrayidx631.us.us, align 8, !tbaa !0
  %arrayidx633.us.us = getelementptr inbounds double, double* %add.ptr193, i64 %indvars.iv1089
  %11 = load double, double* %arrayidx633.us.us, align 8, !tbaa !0
  %mul634.us.us = fmul double %10, %11
  %add635.us.us = fadd double %mul629.us.us, %mul634.us.us
  %add636.us.us = fadd double %7, %add635.us.us
  %arrayidx638.us.us = getelementptr inbounds double, double* %add.ptr199, i64 %indvars.iv1091
  store double %add636.us.us, double* %arrayidx638.us.us, align 8, !tbaa !0
  %inc642.us.us = add nuw nsw i32 %loopi.1997.us.us, 1
  %indvars.iv.next1088 = add nsw i64 %indvars.iv1087, 1
  %indvars.iv.next1090 = add i64 %indvars.iv1089, %0
  %indvars.iv.next1092 = add nsw i64 %indvars.iv1091, 1
  %exitcond1093 = icmp eq i32 %inc642.us.us, %1
  br i1 %exitcond1093, label %for.cond.620.for.end_crit_edge.us.us, label %for.body.622.us.us

for.cond.620.for.end_crit_edge.us.us:             ; preds = %for.body.622.us.us
  %add645.us.us = add i32 %Ri.11007.us.us, %cond260
  %12 = add i32 %sub647, %2
  %add648.us.us = add i32 %12, %ri.11006.us.us
  %add651.us.us = add i32 %rci.11005.us.us, %cond360
  %inc653.us.us = add nuw nsw i32 %loopj.11004.us.us, 1
  %exitcond1097 = icmp eq i32 %inc653.us.us, %3
  br i1 %exitcond1097, label %for.cond.617.for.end.654_crit_edge.us.loopexit.exitStub, label %for.body.622.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
