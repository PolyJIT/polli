
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'doitgen.dir/doitgen.c.kernel_doitgen_for.body.11.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @kernel_doitgen_for.body.11.us.us.pjit.scop(double* %sum, double* %arrayidx19.us, i64, double* %C4, i32 %np)  {
newFuncRoot:
  br label %for.body.11.us.us

for.cond.9.for.cond.31.preheader_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.12.for.inc.28_crit_edge.us.us
  ret void

for.body.11.us.us:                                ; preds = %for.cond.12.for.inc.28_crit_edge.us.us, %newFuncRoot
  %indvars.iv128 = phi i64 [ %indvars.iv.next129, %for.cond.12.for.inc.28_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %arrayidx.us.us = getelementptr inbounds double, double* %sum, i64 %indvars.iv128
  store double 0.000000e+00, double* %arrayidx.us.us, align 8, !tbaa !0
  br label %for.body.14.us.us

for.body.14.us.us:                                ; preds = %for.body.14.us.us, %for.body.11.us.us
  %indvars.iv124 = phi i64 [ %indvars.iv.next125, %for.body.14.us.us ], [ 0, %for.body.11.us.us ]
  %arrayidx20.us.us = getelementptr inbounds double, double* %arrayidx19.us, i64 %indvars.iv124
  %1 = load double, double* %arrayidx20.us.us, align 8, !tbaa !0
  %2 = mul nuw nsw i64 %indvars.iv124, %0
  %arrayidx23.us.us = getelementptr inbounds double, double* %C4, i64 %2
  %arrayidx24.us.us = getelementptr inbounds double, double* %arrayidx23.us.us, i64 %indvars.iv128
  %3 = load double, double* %arrayidx24.us.us, align 8, !tbaa !0
  %mul.us.us = fmul double %1, %3
  %4 = load double, double* %arrayidx.us.us, align 8, !tbaa !0
  %add27.us.us = fadd double %4, %mul.us.us
  store double %add27.us.us, double* %arrayidx.us.us, align 8, !tbaa !0
  %indvars.iv.next125 = add nuw nsw i64 %indvars.iv124, 1
  %lftr.wideiv150 = trunc i64 %indvars.iv.next125 to i32
  %exitcond151 = icmp eq i32 %lftr.wideiv150, %np
  br i1 %exitcond151, label %for.cond.12.for.inc.28_crit_edge.us.us, label %for.body.14.us.us

for.cond.12.for.inc.28_crit_edge.us.us:           ; preds = %for.body.14.us.us
  %indvars.iv.next129 = add nuw nsw i64 %indvars.iv128, 1
  %lftr.wideiv152 = trunc i64 %indvars.iv.next129 to i32
  %exitcond153 = icmp eq i32 %lftr.wideiv152, %np
  br i1 %exitcond153, label %for.cond.9.for.cond.31.preheader_crit_edge.us.loopexit.exitStub, label %for.body.11.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
