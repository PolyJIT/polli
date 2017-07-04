
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'engine_influence.c.compute_followup_influence_for.cond.119.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.influence_data = type { [400 x i8], [400 x float], [400 x float], [400 x float], [400 x float], [400 x float], [400 x float], [400 x float], [400 x float], [400 x i32], [400 x i32], [400 x i32], [1084 x i32], [1084 x i32], [1084 x float], i32, i32, [400 x float], [400 x i32], i32, i32, [361 x i32], i32, [722 x %struct.intrusion_data] }
%struct.intrusion_data = type { i32, i32, float, float }

; Function Attrs: nounwind
define weak void @compute_followup_influence_for.cond.119.preheader.pjit.scop(i32 %sub, [400 x i32]* %int_influence, %struct.influence_data* %q, [421 x i8]* nonnull %board)  {
newFuncRoot:
  br label %for.cond.119.preheader

for.end.151.exitStub:                             ; preds = %for.end.151.loopexit241, %for.end.151.loopexit
  ret void

for.cond.119.preheader:                           ; preds = %newFuncRoot
  %cmp129 = icmp eq i32 %sub, 1
  br i1 %cmp129, label %for.body.122.us.preheader, label %for.body.122.preheader

for.body.122.us.preheader:                        ; preds = %for.cond.119.preheader
  br label %for.body.122.us

for.body.122.us:                                  ; preds = %for.inc.149.us, %for.body.122.us.preheader
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.inc.149.us ], [ 21, %for.body.122.us.preheader ]
  %arrayidx124.us = getelementptr inbounds [421 x i8], [421 x i8]* %board, i64 0, i64 %indvars.iv
  %0 = load i8, i8* %arrayidx124.us, align 1, !tbaa !0
  %cmp126.us = icmp eq i8 %0, 3
  br i1 %cmp126.us, label %for.inc.149.us, label %if.then.128.us

for.inc.149.us:                                   ; preds = %if.then.128.us, %for.body.122.us
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 400
  br i1 %exitcond, label %for.end.151.loopexit, label %for.body.122.us

for.end.151.loopexit:                             ; preds = %for.inc.149.us
  br label %for.end.151.exitStub

if.then.128.us:                                   ; preds = %for.body.122.us
  %arrayidx133.us = getelementptr inbounds [400 x i32], [400 x i32]* %int_influence, i64 0, i64 %indvars.iv
  %1 = load i32, i32* %arrayidx133.us, align 4, !tbaa !3
  %conv134.us = sitofp i32 %1 to float
  %div135.us = fmul float %conv134.us, 0x3F30000000000000
  %arrayidx137.us = getelementptr inbounds %struct.influence_data, %struct.influence_data* %q, i64 0, i32 1, i64 %indvars.iv
  %2 = load float, float* %arrayidx137.us, align 4, !tbaa !5
  %add138.us = fadd float %2, %div135.us
  store float %add138.us, float* %arrayidx137.us, align 4, !tbaa !5
  br label %for.inc.149.us

for.body.122.preheader:                           ; preds = %for.cond.119.preheader
  br label %for.body.122

for.body.122:                                     ; preds = %for.inc.149, %for.body.122.preheader
  %indvars.iv223 = phi i64 [ %indvars.iv.next224, %for.inc.149 ], [ 21, %for.body.122.preheader ]
  %arrayidx124 = getelementptr inbounds [421 x i8], [421 x i8]* %board, i64 0, i64 %indvars.iv223
  %3 = load i8, i8* %arrayidx124, align 1, !tbaa !0
  %cmp126 = icmp eq i8 %3, 3
  br i1 %cmp126, label %for.inc.149, label %if.then.128

for.inc.149:                                      ; preds = %if.then.128, %for.body.122
  %indvars.iv.next224 = add nuw nsw i64 %indvars.iv223, 1
  %exitcond225 = icmp eq i64 %indvars.iv.next224, 400
  br i1 %exitcond225, label %for.end.151.loopexit241, label %for.body.122

for.end.151.loopexit241:                          ; preds = %for.inc.149
  br label %for.end.151.exitStub

if.then.128:                                      ; preds = %for.body.122
  %arrayidx133 = getelementptr inbounds [400 x i32], [400 x i32]* %int_influence, i64 0, i64 %indvars.iv223
  %4 = load i32, i32* %arrayidx133, align 4, !tbaa !3
  %conv134 = sitofp i32 %4 to float
  %div135 = fmul float %conv134, 0x3F30000000000000
  %arrayidx145 = getelementptr inbounds %struct.influence_data, %struct.influence_data* %q, i64 0, i32 2, i64 %indvars.iv223
  %5 = load float, float* %arrayidx145, align 4, !tbaa !5
  %add146 = fadd float %5, %div135
  store float %add146, float* %arrayidx145, align 4, !tbaa !5
  br label %for.inc.149
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !1, i64 0}
!5 = !{!6, !6, i64 0}
!6 = !{!"float", !1, i64 0}
