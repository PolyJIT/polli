
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/VersaBench/beamformer/beamformer.c.begin_for.body.105.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.BeamFirData = type { i32, i32, i32, float*, float* }

; Function Attrs: nounwind
define weak void @begin_for.body.105.pjit.scop([12288 x float]* %beam_input, [4 x [24 x float]]* %beam_weights, i64 %indvars.iv336, [1024 x float]* %beam_output, [4 x %struct.BeamFirData]* %mf_fir_data, %struct.BeamFirData** %arrayidx125.out)  {
newFuncRoot:
  br label %for.body.105

for.body.123.exitStub:                            ; preds = %for.cond.121.preheader
  store %struct.BeamFirData* %arrayidx125, %struct.BeamFirData** %arrayidx125.out
  ret void

for.body.105:                                     ; preds = %BeamForm.exit, %newFuncRoot
  %indvars.iv326 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next327, %BeamForm.exit ]
  %0 = mul nuw nsw i64 %indvars.iv326, 24
  %add.ptr113 = getelementptr inbounds [12288 x float], [12288 x float]* %beam_input, i64 0, i64 %0
  br label %for.body.i.259

for.body.i.259:                                   ; preds = %for.body.i.259, %for.body.105
  %indvars.iv.i.255 = phi i64 [ 0, %for.body.105 ], [ %indvars.iv.next.i.257, %for.body.i.259 ]
  %imag_curr.056.i = phi float [ 0.000000e+00, %for.body.105 ], [ %add31.i, %for.body.i.259 ]
  %real_curr.055.i = phi float [ 0.000000e+00, %for.body.105 ], [ %add13.i, %for.body.i.259 ]
  %1 = shl nsw i64 %indvars.iv.i.255, 1
  %arrayidx.i = getelementptr inbounds [4 x [24 x float]], [4 x [24 x float]]* %beam_weights, i64 0, i64 %indvars.iv336, i64 %1
  %2 = load float, float* %arrayidx.i, align 8, !tbaa !0
  %arrayidx3.i = getelementptr inbounds float, float* %add.ptr113, i64 %1
  %3 = load float, float* %arrayidx3.i, align 8, !tbaa !0
  %mul4.i = fmul float %2, %3
  %4 = or i64 %1, 1
  %arrayidx7.i = getelementptr inbounds [4 x [24 x float]], [4 x [24 x float]]* %beam_weights, i64 0, i64 %indvars.iv336, i64 %4
  %5 = load float, float* %arrayidx7.i, align 4, !tbaa !0
  %arrayidx11.i = getelementptr inbounds float, float* %add.ptr113, i64 %4
  %6 = load float, float* %arrayidx11.i, align 4, !tbaa !0
  %mul12.i = fmul float %5, %6
  %sub.i.256 = fsub float %mul4.i, %mul12.i
  %add13.i = fadd float %real_curr.055.i, %sub.i.256
  %mul21.i = fmul float %2, %6
  %mul29.i = fmul float %3, %5
  %add30.i = fadd float %mul29.i, %mul21.i
  %add31.i = fadd float %imag_curr.056.i, %add30.i
  %indvars.iv.next.i.257 = add nuw nsw i64 %indvars.iv.i.255, 1
  %exitcond.i.258 = icmp eq i64 %indvars.iv.next.i.257, 12
  br i1 %exitcond.i.258, label %BeamForm.exit, label %for.body.i.259

BeamForm.exit:                                    ; preds = %for.body.i.259
  %add31.i.lcssa = phi float [ %add31.i, %for.body.i.259 ]
  %add13.i.lcssa = phi float [ %add13.i, %for.body.i.259 ]
  %7 = shl nsw i64 %indvars.iv326, 1
  %add.ptr117 = getelementptr inbounds [1024 x float], [1024 x float]* %beam_output, i64 0, i64 %7
  store float %add13.i.lcssa, float* %add.ptr117, align 8, !tbaa !0
  %arrayidx33.i = getelementptr inbounds float, float* %add.ptr117, i64 1
  store float %add31.i.lcssa, float* %arrayidx33.i, align 4, !tbaa !0
  %indvars.iv.next327 = add nuw nsw i64 %indvars.iv326, 1
  %exitcond330 = icmp eq i64 %indvars.iv.next327, 512
  br i1 %exitcond330, label %for.cond.121.preheader, label %for.body.105

for.cond.121.preheader:                           ; preds = %BeamForm.exit
  %arrayidx125 = getelementptr inbounds [4 x %struct.BeamFirData], [4 x %struct.BeamFirData]* %mf_fir_data, i64 0, i64 %indvars.iv336
  br label %for.body.123.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
