
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/456.hmmer/src/sre_math.c.FMX2Multiply_for.body.3.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @FMX2Multiply_for.body.3.us.us.pjit.scop(float*, float** %arrayidx11.us, i64 %idxprom9, float** %arrayidx15, float** %arrayidx.us, i32 %p, i32 %n)  {
newFuncRoot:
  br label %for.body.3.us.us

for.cond.1.for.inc.24_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.6.for.inc.21_crit_edge.us.us
  ret void

for.body.3.us.us:                                 ; preds = %for.cond.6.for.inc.21_crit_edge.us.us, %newFuncRoot
  %indvars.iv71 = phi i64 [ %indvars.iv.next72, %for.cond.6.for.inc.21_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %arrayidx5.us.us = getelementptr inbounds float, float* %0, i64 %indvars.iv71
  store float 0.000000e+00, float* %arrayidx5.us.us, align 4, !tbaa !0
  %1 = load float*, float** %arrayidx11.us, align 8, !tbaa !4
  %arrayidx12.us.us = getelementptr inbounds float, float* %1, i64 %idxprom9
  %2 = load float*, float** %arrayidx15, align 8, !tbaa !4
  %arrayidx16.us.us = getelementptr inbounds float, float* %2, i64 %indvars.iv71
  %3 = load float*, float** %arrayidx.us, align 8, !tbaa !4
  %arrayidx20.us.us = getelementptr inbounds float, float* %3, i64 %indvars.iv71
  br label %for.body.8.us.us

for.body.8.us.us:                                 ; preds = %for.body.8.us.us, %for.body.3.us.us
  %k.043.us.us = phi i32 [ 0, %for.body.3.us.us ], [ %inc.us.us, %for.body.8.us.us ]
  %4 = load float, float* %arrayidx12.us.us, align 4, !tbaa !0
  %5 = load float, float* %arrayidx16.us.us, align 4, !tbaa !0
  %mul.us.us = fmul float %4, %5
  %6 = load float, float* %arrayidx20.us.us, align 4, !tbaa !0
  %add.us.us = fadd float %mul.us.us, %6
  store float %add.us.us, float* %arrayidx20.us.us, align 4, !tbaa !0
  %inc.us.us = add nuw nsw i32 %k.043.us.us, 1
  %exitcond70 = icmp eq i32 %inc.us.us, %p
  br i1 %exitcond70, label %for.cond.6.for.inc.21_crit_edge.us.us, label %for.body.8.us.us

for.cond.6.for.inc.21_crit_edge.us.us:            ; preds = %for.body.8.us.us
  %indvars.iv.next72 = add nuw nsw i64 %indvars.iv71, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next72 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %n
  br i1 %exitcond, label %for.cond.1.for.inc.24_crit_edge.us.loopexit.exitStub, label %for.body.3.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"any pointer", !2, i64 0}
