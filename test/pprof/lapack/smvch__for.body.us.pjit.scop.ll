
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'sblat2.c.smvch__for.body.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @smvch__for.body.us.pjit.scop(i64 %i__.promoted, i64 %ky.0, float* %incdec.ptr2, float* %incdec.ptr3, i1 %cmp26.330, float* %alpha, float* %beta, float* %incdec.ptr1, i64, i64 %ml.0, i64, i64 %nl.0., float* %add.ptr, float* %incdec.ptr, i64, i64 %nl.0, i64* %inc114.us.out)  {
newFuncRoot:
  br label %for.body.us

for.cond.for.end.115_crit_edge.loopexit.exitStub: ; preds = %if.end.81.loopexit326.us
  store i64 %inc114.us, i64* %inc114.us.out
  ret void

for.body.us:                                      ; preds = %if.end.81.loopexit326.us, %newFuncRoot
  %inc114338.us = phi i64 [ %inc114.us, %if.end.81.loopexit326.us ], [ %i__.promoted, %newFuncRoot ]
  %iy.0337.us = phi i64 [ %add112.us, %if.end.81.loopexit326.us ], [ %ky.0, %newFuncRoot ]
  %arrayidx.us = getelementptr inbounds float, float* %incdec.ptr2, i64 %iy.0337.us
  store float 0.000000e+00, float* %arrayidx.us, align 4, !tbaa !0
  %arrayidx22.us = getelementptr inbounds float, float* %incdec.ptr3, i64 %iy.0337.us
  store float 0.000000e+00, float* %arrayidx22.us, align 4, !tbaa !0
  br i1 %cmp26.330, label %if.end.81.loopexit326.us, label %for.body.28.lr.ph.us

if.end.81.loopexit326.us:                         ; preds = %if.end.81.loopexit326.us.loopexit, %for.body.us
  %3 = load float, float* %alpha, align 4, !tbaa !0
  %4 = load float, float* %arrayidx.us, align 4, !tbaa !0
  %mul83.us = fmul float %3, %4
  %5 = load float, float* %beta, align 4, !tbaa !0
  %arrayidx84.us = getelementptr inbounds float, float* %incdec.ptr1, i64 %iy.0337.us
  %6 = load float, float* %arrayidx84.us, align 4, !tbaa !0
  %mul85.us = fmul float %5, %6
  %add86.us = fadd float %mul83.us, %mul85.us
  store float %add86.us, float* %arrayidx.us, align 4, !tbaa !0
  %7 = load float, float* %alpha, align 4, !tbaa !0
  %cmp88.us = fcmp oge float %7, 0.000000e+00
  %sub92.us = fsub float -0.000000e+00, %7
  %cond94.us = select i1 %cmp88.us, float %7, float %sub92.us
  %conv95.us = fpext float %cond94.us to double
  %8 = load float, float* %arrayidx22.us, align 4, !tbaa !0
  %conv97.us = fpext float %8 to double
  %mul98.us = fmul double %conv97.us, %conv95.us
  %9 = load float, float* %beta, align 4, !tbaa !0
  %10 = load float, float* %arrayidx84.us, align 4, !tbaa !0
  %mul100.us = fmul float %9, %10
  %cmp101.us = fcmp oge float %mul100.us, 0.000000e+00
  %sub105.us = fsub float -0.000000e+00, %mul100.us
  %cond107.us = select i1 %cmp101.us, float %mul100.us, float %sub105.us
  %conv108.us = fpext float %cond107.us to double
  %add109.us = fadd double %mul98.us, %conv108.us
  %conv110.us = fptrunc double %add109.us to float
  store float %conv110.us, float* %arrayidx22.us, align 4, !tbaa !0
  %add112.us = add nsw i64 %iy.0337.us, %0
  %inc114.us = add nsw i64 %inc114338.us, 1
  %cmp20.us = icmp slt i64 %inc114338.us, %ml.0
  br i1 %cmp20.us, label %for.body.us, label %for.cond.for.end.115_crit_edge.loopexit.exitStub

for.body.28.lr.ph.us:                             ; preds = %for.body.us
  %mul.us = mul nsw i64 %inc114338.us, %1
  %mul35.us = mul nsw i64 %inc114338.us, %1
  br label %for.body.28.us

for.body.28.us:                                   ; preds = %for.body.28.us, %for.body.28.lr.ph.us
  %jx.0332.us = phi i64 [ %nl.0., %for.body.28.lr.ph.us ], [ %add47.us, %for.body.28.us ]
  %j.0331.us = phi i64 [ 1, %for.body.28.lr.ph.us ], [ %inc.us, %for.body.28.us ]
  %add29.us = add nsw i64 %j.0331.us, %mul.us
  %arrayidx30.us = getelementptr inbounds float, float* %add.ptr, i64 %add29.us
  %11 = load float, float* %arrayidx30.us, align 4, !tbaa !0
  %arrayidx31.us = getelementptr inbounds float, float* %incdec.ptr, i64 %jx.0332.us
  %12 = load float, float* %arrayidx31.us, align 4, !tbaa !0
  %mul32.us = fmul float %11, %12
  %13 = load float, float* %arrayidx.us, align 4, !tbaa !0
  %add34.us = fadd float %13, %mul32.us
  store float %add34.us, float* %arrayidx.us, align 4, !tbaa !0
  %add36.us = add nsw i64 %j.0331.us, %mul35.us
  %arrayidx37.us = getelementptr inbounds float, float* %add.ptr, i64 %add36.us
  %14 = load float, float* %arrayidx37.us, align 4, !tbaa !0
  %15 = load float, float* %arrayidx31.us, align 4, !tbaa !0
  %mul39.us = fmul float %14, %15
  %cmp40.us = fcmp oge float %mul39.us, 0.000000e+00
  %sub.us = fsub float -0.000000e+00, %mul39.us
  %cond.us = select i1 %cmp40.us, float %mul39.us, float %sub.us
  %16 = load float, float* %arrayidx22.us, align 4, !tbaa !0
  %conv46.us = fadd float %16, %cond.us
  store float %conv46.us, float* %arrayidx22.us, align 4, !tbaa !0
  %add47.us = add nsw i64 %jx.0332.us, %2
  %inc.us = add nuw nsw i64 %j.0331.us, 1
  %exitcond = icmp eq i64 %j.0331.us, %nl.0
  br i1 %exitcond, label %if.end.81.loopexit326.us.loopexit, label %for.body.28.us

if.end.81.loopexit326.us.loopexit:                ; preds = %for.body.28.us
  br label %if.end.81.loopexit326.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
