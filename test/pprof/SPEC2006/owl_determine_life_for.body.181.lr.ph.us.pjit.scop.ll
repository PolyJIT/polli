
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'engine_owl.c.owl_determine_life_for.body.181.lr.ph.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.local_owl_data = type { [400 x i8], [400 x i8], [400 x i8], i32, [400 x %struct.eye_data], [400 x %struct.half_eye_data], [10 x i32], [10 x i32], [10 x i32], [10 x i32], [10 x i32], [400 x i8], i32, [400 x i8], i32, i32 }
%struct.eye_data = type { i32, i32, i32, i32, %struct.eyevalue, i32, i32, i8, i8, i8, i8, i8 }
%struct.eyevalue = type { i8, i8, i8, i8 }
%struct.half_eye_data = type { float, i8, i32, [4 x i32], i32, [4 x i32] }

; Function Attrs: nounwind
define weak void @owl_determine_life_for.body.181.lr.ph.us.pjit.scop(%struct.local_owl_data* %owl, i64, [400 x i8]* %mw, [400 x i8]* %mz, i32* %pessimistic_min, i32)  {
newFuncRoot:
  br label %for.body.181.lr.ph.us

for.end.236.exitStub:                             ; preds = %for.end.236.loopexit
  ret void

for.body.181.lr.ph.us:                            ; preds = %for.cond.178.for.inc.234_crit_edge.us, %newFuncRoot
  %indvars.iv187 = phi i64 [ %indvars.iv.next188, %for.cond.178.for.inc.234_crit_edge.us ], [ 0, %newFuncRoot ]
  %2 = mul nuw nsw i64 %indvars.iv187, 20
  %3 = add nuw nsw i64 %2, 21
  br label %for.body.181.us

for.body.181.us:                                  ; preds = %for.inc.231.us, %for.body.181.lr.ph.us
  %indvars.iv182 = phi i64 [ 0, %for.body.181.lr.ph.us ], [ %indvars.iv.next183, %for.inc.231.us ]
  %4 = add nuw nsw i64 %3, %indvars.iv182
  %origin187.us = getelementptr inbounds %struct.local_owl_data, %struct.local_owl_data* %owl, i64 0, i32 4, i64 %4, i32 3
  %5 = load i32, i32* %origin187.us, align 4, !tbaa !0
  %6 = trunc i64 %0 to i32
  %cmp188.us = icmp eq i32 %5, %6
  br i1 %cmp188.us, label %land.lhs.true.190.us, label %for.inc.231.us

land.lhs.true.190.us:                             ; preds = %for.body.181.us
  %arrayidx195.us = getelementptr inbounds [400 x i8], [400 x i8]* %mw, i64 0, i64 %4
  %7 = load i8, i8* %arrayidx195.us, align 1, !tbaa !6
  %arrayidx201.us = getelementptr inbounds [400 x i8], [400 x i8]* %mz, i64 0, i64 %4
  %8 = load i8, i8* %arrayidx201.us, align 1, !tbaa !6
  %cmp203.us = icmp slt i8 %7, %8
  br i1 %cmp203.us, label %if.then.229.us, label %lor.lhs.false.us

if.then.229.us:                                   ; preds = %lor.lhs.false.us, %land.lhs.true.190.us
  store i32 0, i32* %pessimistic_min, align 4, !tbaa !7
  br label %for.inc.231.us

for.inc.231.us:                                   ; preds = %lor.lhs.false.us, %if.then.229.us, %for.body.181.us
  %indvars.iv.next183 = add nuw nsw i64 %indvars.iv182, 1
  %lftr.wideiv241 = trunc i64 %indvars.iv.next183 to i32
  %exitcond242 = icmp eq i32 %lftr.wideiv241, %1
  br i1 %exitcond242, label %for.cond.178.for.inc.234_crit_edge.us, label %for.body.181.us

for.cond.178.for.inc.234_crit_edge.us:            ; preds = %for.inc.231.us
  %indvars.iv.next188 = add nuw nsw i64 %indvars.iv187, 1
  %lftr.wideiv243 = trunc i64 %indvars.iv.next188 to i32
  %exitcond244 = icmp eq i32 %lftr.wideiv243, %1
  br i1 %exitcond244, label %for.end.236.loopexit, label %for.body.181.lr.ph.us

for.end.236.loopexit:                             ; preds = %for.cond.178.for.inc.234_crit_edge.us
  br label %for.end.236.exitStub

lor.lhs.false.us:                                 ; preds = %land.lhs.true.190.us
  %conv202.us = sext i8 %8 to i32
  %conv196.us = sext i8 %7 to i32
  %mul217.us = mul nsw i32 %conv202.us, 3
  %cmp218.us = icmp slt i32 %conv196.us, %mul217.us
  %cmp227.us = icmp sgt i8 %8, 5
  %or.cond2.us = and i1 %cmp227.us, %cmp218.us
  br i1 %or.cond2.us, label %if.then.229.us, label %for.inc.231.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 12}
!1 = !{!"eye_data", !2, i64 0, !2, i64 4, !2, i64 8, !2, i64 12, !5, i64 16, !2, i64 20, !2, i64 24, !3, i64 28, !3, i64 29, !3, i64 30, !3, i64 31, !3, i64 32}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!"eyevalue", !3, i64 0, !3, i64 1, !3, i64 2, !3, i64 3}
!6 = !{!3, !3, i64 0}
!7 = !{!2, !2, i64 0}
