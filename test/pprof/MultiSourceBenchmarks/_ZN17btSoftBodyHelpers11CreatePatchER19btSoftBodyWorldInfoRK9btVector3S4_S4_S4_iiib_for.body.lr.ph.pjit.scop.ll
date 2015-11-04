
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/Bullet/btSoftBodyHelpers.cpp._ZN17btSoftBodyHelpers11CreatePatchER19btSoftBodyWorldInfoRK9btVector3S4_S4_S4_iiib_for.body.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.btVector3 = type { [4 x float] }

define weak void @_ZN17btSoftBodyHelpers11CreatePatchER19btSoftBodyWorldInfoRK9btVector3S4_S4_S4_iiib_for.body.lr.ph.pjit.scop(i32 %resy, %class.btVector3* %corner00, %class.btVector3* %corner01, %class.btVector3* %corner10, %class.btVector3* %corner11, i32 %resx, %class.btVector3*, float*)  {
newFuncRoot:
  br label %for.body.lr.ph

for.end.24.exitStub:                              ; preds = %for.end.24.loopexit, %for.body.lr.ph
  ret void

for.body.lr.ph:                                   ; preds = %newFuncRoot
  %sub = add nsw i32 %resy, -1
  %conv4 = sitofp i32 %sub to float
  %arrayidx.i.i = getelementptr inbounds %class.btVector3, %class.btVector3* %corner00, i64 0, i32 0, i64 0
  %2 = load float, float* %arrayidx.i.i, align 4, !tbaa !0
  %arrayidx3.i.i = getelementptr inbounds %class.btVector3, %class.btVector3* %corner01, i64 0, i32 0, i64 0
  %3 = load float, float* %arrayidx3.i.i, align 4, !tbaa !0
  %sub.i.i = fsub float %3, %2
  %arrayidx8.i.i = getelementptr inbounds %class.btVector3, %class.btVector3* %corner00, i64 0, i32 0, i64 1
  %4 = load float, float* %arrayidx8.i.i, align 4, !tbaa !0
  %arrayidx10.i.i = getelementptr inbounds %class.btVector3, %class.btVector3* %corner01, i64 0, i32 0, i64 1
  %5 = load float, float* %arrayidx10.i.i, align 4, !tbaa !0
  %sub13.i.i = fsub float %5, %4
  %arrayidx18.i.i = getelementptr inbounds %class.btVector3, %class.btVector3* %corner00, i64 0, i32 0, i64 2
  %6 = load float, float* %arrayidx18.i.i, align 4, !tbaa !0
  %arrayidx20.i.i = getelementptr inbounds %class.btVector3, %class.btVector3* %corner01, i64 0, i32 0, i64 2
  %7 = load float, float* %arrayidx20.i.i, align 4, !tbaa !0
  %sub23.i.i = fsub float %7, %6
  %arrayidx.i.i.283 = getelementptr inbounds %class.btVector3, %class.btVector3* %corner10, i64 0, i32 0, i64 0
  %8 = load float, float* %arrayidx.i.i.283, align 4, !tbaa !0
  %arrayidx3.i.i.284 = getelementptr inbounds %class.btVector3, %class.btVector3* %corner11, i64 0, i32 0, i64 0
  %9 = load float, float* %arrayidx3.i.i.284, align 4, !tbaa !0
  %sub.i.i.285 = fsub float %9, %8
  %arrayidx8.i.i.288 = getelementptr inbounds %class.btVector3, %class.btVector3* %corner10, i64 0, i32 0, i64 1
  %10 = load float, float* %arrayidx8.i.i.288, align 4, !tbaa !0
  %arrayidx10.i.i.289 = getelementptr inbounds %class.btVector3, %class.btVector3* %corner11, i64 0, i32 0, i64 1
  %11 = load float, float* %arrayidx10.i.i.289, align 4, !tbaa !0
  %sub13.i.i.290 = fsub float %11, %10
  %arrayidx18.i.i.293 = getelementptr inbounds %class.btVector3, %class.btVector3* %corner10, i64 0, i32 0, i64 2
  %12 = load float, float* %arrayidx18.i.i.293, align 4, !tbaa !0
  %arrayidx20.i.i.294 = getelementptr inbounds %class.btVector3, %class.btVector3* %corner11, i64 0, i32 0, i64 2
  %13 = load float, float* %arrayidx20.i.i.294, align 4, !tbaa !0
  %sub23.i.i.295 = fsub float %13, %12
  %cmp9.340 = icmp sgt i32 %resx, 0
  %sub12 = add nsw i32 %resx, -1
  %conv13 = sitofp i32 %sub12 to float
  br i1 %cmp9.340, label %for.body.us.preheader, label %for.end.24.exitStub

for.body.us.preheader:                            ; preds = %for.body.lr.ph
  %14 = sext i32 %resx to i64
  br label %for.body.us

for.body.us:                                      ; preds = %for.cond.8.for.cond.cleanup_crit_edge.us, %for.body.us.preheader
  %indvars.iv351 = phi i64 [ 0, %for.body.us.preheader ], [ %indvars.iv.next352, %for.cond.8.for.cond.cleanup_crit_edge.us ]
  %15 = trunc i64 %indvars.iv351 to i32
  %conv.us = sitofp i32 %15 to float
  %div.us = fdiv float %conv.us, %conv4
  %mul.i.i.us = fmul float %sub.i.i, %div.us
  %add.i.i.us = fadd float %2, %mul.i.i.us
  %mul14.i.i.us = fmul float %sub13.i.i, %div.us
  %add15.i.i.us = fadd float %4, %mul14.i.i.us
  %mul24.i.i.us = fmul float %sub23.i.i, %div.us
  %add25.i.i.us = fadd float %6, %mul24.i.i.us
  %mul.i.i.286.us = fmul float %sub.i.i.285, %div.us
  %add.i.i.287.us = fadd float %8, %mul.i.i.286.us
  %mul14.i.i.291.us = fmul float %sub13.i.i.290, %div.us
  %add15.i.i.292.us = fadd float %10, %mul14.i.i.291.us
  %mul24.i.i.296.us = fmul float %sub23.i.i.295, %div.us
  %add25.i.i.297.us = fadd float %12, %mul24.i.i.296.us
  %16 = mul nsw i64 %indvars.iv351, %14
  %sub.i.i.306.us = fsub float %add.i.i.287.us, %add.i.i.us
  %sub13.i.i.311.us = fsub float %add15.i.i.292.us, %add15.i.i.us
  %sub23.i.i.316.us = fsub float %add25.i.i.297.us, %add25.i.i.us
  br label %for.body.10.us

for.body.10.us:                                   ; preds = %for.body.10.us, %for.body.us
  %indvars.iv = phi i64 [ 0, %for.body.us ], [ %indvars.iv.next, %for.body.10.us ]
  %17 = trunc i64 %indvars.iv to i32
  %conv11.us = sitofp i32 %17 to float
  %div14.us = fdiv float %conv11.us, %conv13
  %18 = add nsw i64 %indvars.iv, %16
  %arrayidx.us = getelementptr inbounds %class.btVector3, %class.btVector3* %0, i64 %18
  %mul.i.i.307.us = fmul float %sub.i.i.306.us, %div14.us
  %add.i.i.308.us = fadd float %add.i.i.us, %mul.i.i.307.us
  %mul14.i.i.312.us = fmul float %sub13.i.i.311.us, %div14.us
  %add15.i.i.313.us = fadd float %add15.i.i.us, %mul14.i.i.312.us
  %mul24.i.i.317.us = fmul float %sub23.i.i.316.us, %div14.us
  %add25.i.i.318.us = fadd float %add25.i.i.us, %mul24.i.i.317.us
  %retval.sroa.0.0.vec.insert.i.i.319.us = insertelement <2 x float> undef, float %add.i.i.308.us, i32 0
  %retval.sroa.0.4.vec.insert.i.i.320.us = insertelement <2 x float> %retval.sroa.0.0.vec.insert.i.i.319.us, float %add15.i.i.313.us, i32 1
  %retval.sroa.3.8.vec.insert.i.i.321.us = insertelement <2 x float> undef, float %add25.i.i.318.us, i32 0
  %retval.sroa.3.12.vec.insert.i.i.322.us = insertelement <2 x float> %retval.sroa.3.8.vec.insert.i.i.321.us, float 0.000000e+00, i32 1
  %ref.tmp.sroa.0.0..sroa_cast.us = bitcast %class.btVector3* %arrayidx.us to <2 x float>*
  store <2 x float> %retval.sroa.0.4.vec.insert.i.i.320.us, <2 x float>* %ref.tmp.sroa.0.0..sroa_cast.us, align 4
  %ref.tmp.sroa.2.0..sroa_idx195.us = getelementptr inbounds %class.btVector3, %class.btVector3* %0, i64 %18, i32 0, i64 2
  %ref.tmp.sroa.2.0..sroa_cast.us = bitcast float* %ref.tmp.sroa.2.0..sroa_idx195.us to <2 x float>*
  store <2 x float> %retval.sroa.3.12.vec.insert.i.i.322.us, <2 x float>* %ref.tmp.sroa.2.0..sroa_cast.us, align 4
  %arrayidx21.us = getelementptr inbounds float, float* %1, i64 %18
  store float 1.000000e+00, float* %arrayidx21.us, align 4, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv358 = trunc i64 %indvars.iv.next to i32
  %exitcond359 = icmp eq i32 %lftr.wideiv358, %resx
  br i1 %exitcond359, label %for.cond.8.for.cond.cleanup_crit_edge.us, label %for.body.10.us

for.cond.8.for.cond.cleanup_crit_edge.us:         ; preds = %for.body.10.us
  %indvars.iv.next352 = add nuw nsw i64 %indvars.iv351, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next352 to i32
  %exitcond360 = icmp eq i32 %lftr.wideiv, %resy
  br i1 %exitcond360, label %for.end.24.loopexit, label %for.body.us

for.end.24.loopexit:                              ; preds = %for.cond.8.for.cond.cleanup_crit_edge.us
  br label %for.end.24.exitStub
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
