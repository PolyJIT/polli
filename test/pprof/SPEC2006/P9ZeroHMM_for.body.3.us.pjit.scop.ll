
; RUN: opt -load LLVMPolyJIT.so -O3  -polli-process-unprofitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/456.hmmer/src/plan9.c.P9ZeroHMM_for.body.3.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.basic_state = type { [3 x float], [20 x float] }

; Function Attrs: nounwind
define weak void @P9ZeroHMM_for.body.3.us.pjit.scop(%struct.basic_state*, %struct.basic_state*, %struct.basic_state*, %struct.basic_state** %mat21, %struct.basic_state** %ins26, %struct.basic_state** %del32, i32, i64)  {
newFuncRoot:
  br label %for.body.3.us

for.end.41.loopexit.exitStub:                     ; preds = %for.cond.16.for.inc.39_crit_edge.us
  ret void

for.body.3.us:                                    ; preds = %for.cond.16.for.inc.39_crit_edge.us, %newFuncRoot
  %indvars.iv76 = phi i64 [ %indvars.iv.next77, %for.cond.16.for.inc.39_crit_edge.us ], [ 0, %newFuncRoot ]
  %arrayidx5.us = getelementptr inbounds %struct.basic_state, %struct.basic_state* %0, i64 %indvars.iv76, i32 0, i64 0
  store float 0.000000e+00, float* %arrayidx5.us, align 4, !tbaa !0
  %arrayidx10.us = getelementptr inbounds %struct.basic_state, %struct.basic_state* %1, i64 %indvars.iv76, i32 0, i64 0
  store float 0.000000e+00, float* %arrayidx10.us, align 4, !tbaa !0
  %arrayidx15.us = getelementptr inbounds %struct.basic_state, %struct.basic_state* %2, i64 %indvars.iv76, i32 0, i64 0
  store float 0.000000e+00, float* %arrayidx15.us, align 4, !tbaa !0
  %arrayidx5.us.1 = getelementptr inbounds %struct.basic_state, %struct.basic_state* %0, i64 %indvars.iv76, i32 0, i64 1
  store float 0.000000e+00, float* %arrayidx5.us.1, align 4, !tbaa !0
  %arrayidx10.us.1 = getelementptr inbounds %struct.basic_state, %struct.basic_state* %1, i64 %indvars.iv76, i32 0, i64 1
  store float 0.000000e+00, float* %arrayidx10.us.1, align 4, !tbaa !0
  %arrayidx15.us.1 = getelementptr inbounds %struct.basic_state, %struct.basic_state* %2, i64 %indvars.iv76, i32 0, i64 1
  store float 0.000000e+00, float* %arrayidx15.us.1, align 4, !tbaa !0
  %arrayidx5.us.2 = getelementptr inbounds %struct.basic_state, %struct.basic_state* %0, i64 %indvars.iv76, i32 0, i64 2
  store float 0.000000e+00, float* %arrayidx5.us.2, align 4, !tbaa !0
  %arrayidx10.us.2 = getelementptr inbounds %struct.basic_state, %struct.basic_state* %1, i64 %indvars.iv76, i32 0, i64 2
  store float 0.000000e+00, float* %arrayidx10.us.2, align 4, !tbaa !0
  %arrayidx15.us.2 = getelementptr inbounds %struct.basic_state, %struct.basic_state* %2, i64 %indvars.iv76, i32 0, i64 2
  store float 0.000000e+00, float* %arrayidx15.us.2, align 4, !tbaa !0
  %5 = load %struct.basic_state*, %struct.basic_state** %mat21, align 8, !tbaa !4
  %6 = load %struct.basic_state*, %struct.basic_state** %ins26, align 8, !tbaa !8
  %7 = load %struct.basic_state*, %struct.basic_state** %del32, align 8, !tbaa !9
  br label %for.body.18.us

for.body.18.us:                                   ; preds = %for.body.18.us, %for.body.3.us
  %indvars.iv73 = phi i64 [ 0, %for.body.3.us ], [ %indvars.iv.next74, %for.body.18.us ]
  %arrayidx23.us = getelementptr inbounds %struct.basic_state, %struct.basic_state* %5, i64 %indvars.iv76, i32 1, i64 %indvars.iv73
  store float 0.000000e+00, float* %arrayidx23.us, align 4, !tbaa !0
  %arrayidx29.us = getelementptr inbounds %struct.basic_state, %struct.basic_state* %6, i64 %indvars.iv76, i32 1, i64 %indvars.iv73
  store float 0.000000e+00, float* %arrayidx29.us, align 4, !tbaa !0
  %arrayidx35.us = getelementptr inbounds %struct.basic_state, %struct.basic_state* %7, i64 %indvars.iv76, i32 1, i64 %indvars.iv73
  store float 0.000000e+00, float* %arrayidx35.us, align 4, !tbaa !0
  %indvars.iv.next74 = add nuw nsw i64 %indvars.iv73, 1
  %lftr.wideiv93 = trunc i64 %indvars.iv.next74 to i32
  %exitcond = icmp eq i32 %lftr.wideiv93, %3
  br i1 %exitcond, label %for.cond.16.for.inc.39_crit_edge.us, label %for.body.18.us

for.cond.16.for.inc.39_crit_edge.us:              ; preds = %for.body.18.us
  %indvars.iv.next77 = add nuw nsw i64 %indvars.iv76, 1
  %cmp.us = icmp sgt i64 %indvars.iv76, %4
  br i1 %cmp.us, label %for.end.41.loopexit.exitStub, label %for.body.3.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !7, i64 16}
!5 = !{!"plan9_s", !6, i64 0, !7, i64 8, !7, i64 16, !7, i64 24, !2, i64 32, !7, i64 112, !7, i64 120, !7, i64 128, !7, i64 136, !6, i64 144}
!6 = !{!"int", !2, i64 0}
!7 = !{!"any pointer", !2, i64 0}
!8 = !{!5, !7, i64 8}
!9 = !{!5, !7, i64 24}
