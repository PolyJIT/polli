
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASC_Sequoia/CrystalMk/Crystal_div.c.Crystal_div_for.body.22.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @Crystal_div_for.body.22.lr.ph.pjit.scop(i32 %nSlip, double %deltaTime, [12 x double]* %rateFact, [12 x double]* %sgn, double* %tau, [12 x double]* %dtcdgd, [12 x double]* %bor_array)  {
newFuncRoot:
  br label %for.body.22.lr.ph

for.cond.63.preheader.exitStub:                   ; preds = %for.cond.63.preheader.loopexit250, %for.cond.63.preheader.loopexit
  ret void

for.body.22.lr.ph:                                ; preds = %newFuncRoot
  %cmp32.207 = icmp sgt i32 %nSlip, 0
  %mul35 = fmul double %deltaTime, 1.200000e+00
  br i1 %cmp32.207, label %for.body.22.us.preheader, label %for.body.22.preheader

for.body.22.us.preheader:                         ; preds = %for.body.22.lr.ph
  br label %for.body.22.us

for.body.22.us:                                   ; preds = %for.cond.31.for.end.45_crit_edge.us, %for.body.22.us.preheader
  %indvars.iv233 = phi i64 [ %indvars.iv.next234, %for.cond.31.for.end.45_crit_edge.us ], [ 0, %for.body.22.us.preheader ]
  %arrayidx24.us = getelementptr inbounds [12 x double], [12 x double]* %rateFact, i64 0, i64 %indvars.iv233
  %0 = load double, double* %arrayidx24.us, align 8, !tbaa !0
  %mul25.us = fmul double %0, 3.000000e+01
  %arrayidx27.us = getelementptr inbounds [12 x double], [12 x double]* %sgn, i64 0, i64 %indvars.iv233
  %1 = load double, double* %arrayidx27.us, align 8, !tbaa !0
  %mul28.us = fmul double %mul25.us, %1
  %arrayidx30.us = getelementptr inbounds double, double* %tau, i64 %indvars.iv233
  store double %mul28.us, double* %arrayidx30.us, align 8, !tbaa !0
  %2 = load double, double* %arrayidx24.us, align 8, !tbaa !0
  %mul38.us = fmul double %mul35, %2
  br label %for.body.34.us

for.body.34.us:                                   ; preds = %for.body.34.us, %for.body.22.us
  %indvars.iv229 = phi i64 [ 0, %for.body.22.us ], [ %indvars.iv.next230, %for.body.34.us ]
  %arrayidx42.us = getelementptr inbounds [12 x double], [12 x double]* %dtcdgd, i64 %indvars.iv233, i64 %indvars.iv229
  store double %mul38.us, double* %arrayidx42.us, align 8, !tbaa !0
  %indvars.iv.next230 = add nuw nsw i64 %indvars.iv229, 1
  %lftr.wideiv257 = trunc i64 %indvars.iv.next230 to i32
  %exitcond258 = icmp eq i32 %lftr.wideiv257, %nSlip
  br i1 %exitcond258, label %for.cond.31.for.end.45_crit_edge.us, label %for.body.34.us

for.cond.31.for.end.45_crit_edge.us:              ; preds = %for.body.34.us
  %3 = load double, double* %arrayidx30.us, align 8, !tbaa !0
  %mul48.us = fmul double %3, 1.000000e-02
  %4 = load double, double* %arrayidx27.us, align 8, !tbaa !0
  %mul51.us = fmul double %mul48.us, %4
  %arrayidx53.us = getelementptr inbounds [12 x double], [12 x double]* %bor_array, i64 0, i64 %indvars.iv233
  %5 = load double, double* %arrayidx53.us, align 8, !tbaa !0
  %mul54.us = fmul double %mul51.us, %5
  %arrayidx58.us = getelementptr inbounds [12 x double], [12 x double]* %dtcdgd, i64 %indvars.iv233, i64 %indvars.iv233
  %6 = load double, double* %arrayidx58.us, align 8, !tbaa !0
  %add59.us = fadd double %6, %mul54.us
  store double %add59.us, double* %arrayidx58.us, align 8, !tbaa !0
  %indvars.iv.next234 = add nuw nsw i64 %indvars.iv233, 1
  %lftr.wideiv259 = trunc i64 %indvars.iv.next234 to i32
  %exitcond260 = icmp eq i32 %lftr.wideiv259, %nSlip
  br i1 %exitcond260, label %for.cond.63.preheader.loopexit, label %for.body.22.us

for.cond.63.preheader.loopexit:                   ; preds = %for.cond.31.for.end.45_crit_edge.us
  br label %for.cond.63.preheader.exitStub

for.body.22.preheader:                            ; preds = %for.body.22.lr.ph
  br label %for.body.22

for.body.22:                                      ; preds = %for.body.22, %for.body.22.preheader
  %indvars.iv237 = phi i64 [ %indvars.iv.next238, %for.body.22 ], [ 0, %for.body.22.preheader ]
  %arrayidx24 = getelementptr inbounds [12 x double], [12 x double]* %rateFact, i64 0, i64 %indvars.iv237
  %7 = load double, double* %arrayidx24, align 8, !tbaa !0
  %mul25 = fmul double %7, 3.000000e+01
  %arrayidx27 = getelementptr inbounds [12 x double], [12 x double]* %sgn, i64 0, i64 %indvars.iv237
  %8 = load double, double* %arrayidx27, align 8, !tbaa !0
  %mul28 = fmul double %mul25, %8
  %arrayidx30 = getelementptr inbounds double, double* %tau, i64 %indvars.iv237
  store double %mul28, double* %arrayidx30, align 8, !tbaa !0
  %mul48 = fmul double %mul28, 1.000000e-02
  %mul51 = fmul double %8, %mul48
  %arrayidx53 = getelementptr inbounds [12 x double], [12 x double]* %bor_array, i64 0, i64 %indvars.iv237
  %9 = load double, double* %arrayidx53, align 8, !tbaa !0
  %mul54 = fmul double %9, %mul51
  %arrayidx58 = getelementptr inbounds [12 x double], [12 x double]* %dtcdgd, i64 %indvars.iv237, i64 %indvars.iv237
  %10 = load double, double* %arrayidx58, align 8, !tbaa !0
  %add59 = fadd double %10, %mul54
  store double %add59, double* %arrayidx58, align 8, !tbaa !0
  %indvars.iv.next238 = add nuw nsw i64 %indvars.iv237, 1
  %lftr.wideiv261 = trunc i64 %indvars.iv.next238 to i32
  %exitcond262 = icmp eq i32 %lftr.wideiv261, %nSlip
  br i1 %exitcond262, label %for.cond.63.preheader.loopexit250, label %for.body.22

for.cond.63.preheader.loopexit250:                ; preds = %for.body.22
  br label %for.cond.63.preheader.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
