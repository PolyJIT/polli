
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/mediabench/mpeg2/mpeg2dec/recon.c.form_component_prediction_for.cond.110.preheader.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @form_component_prediction_for.cond.110.preheader.lr.ph.pjit.scop(i32 %w, i32 %lx2, i32 %lx, i8* %add.ptr11, i8* %add.ptr6, i32 %h)  {
newFuncRoot:
  br label %for.cond.110.preheader.lr.ph

if.end.318.exitStub:                              ; preds = %if.end.318.loopexit610, %for.cond.110.preheader.lr.ph
  ret void

for.cond.110.preheader.lr.ph:                     ; preds = %newFuncRoot
  %cmp111.510 = icmp sgt i32 %w, 0
  %idx.ext130 = sext i32 %lx2 to i64
  br i1 %cmp111.510, label %for.body.113.lr.ph.us.preheader, label %if.end.318.exitStub

for.body.113.lr.ph.us.preheader:                  ; preds = %for.cond.110.preheader.lr.ph
  %0 = sext i32 %lx to i64
  br label %for.body.113.lr.ph.us

for.body.113.lr.ph.us:                            ; preds = %for.cond.110.for.end.129_crit_edge.us, %for.body.113.lr.ph.us.preheader
  %d.3515.us = phi i8* [ %add.ptr133.us, %for.cond.110.for.end.129_crit_edge.us ], [ %add.ptr11, %for.body.113.lr.ph.us.preheader ]
  %s.3514.us = phi i8* [ %add.ptr131.us, %for.cond.110.for.end.129_crit_edge.us ], [ %add.ptr6, %for.body.113.lr.ph.us.preheader ]
  %j.3513.us = phi i32 [ %inc135.us, %for.cond.110.for.end.129_crit_edge.us ], [ 0, %for.body.113.lr.ph.us.preheader ]
  br label %for.body.113.us

for.body.113.us:                                  ; preds = %for.body.113.us, %for.body.113.lr.ph.us
  %indvars.iv569 = phi i64 [ 0, %for.body.113.lr.ph.us ], [ %indvars.iv.next570, %for.body.113.us ]
  %arrayidx115.us = getelementptr inbounds i8, i8* %s.3514.us, i64 %indvars.iv569
  %1 = load i8, i8* %arrayidx115.us, align 1, !tbaa !0
  %conv116.us = zext i8 %1 to i32
  %2 = add nsw i64 %indvars.iv569, %0
  %arrayidx119.us = getelementptr inbounds i8, i8* %s.3514.us, i64 %2
  %3 = load i8, i8* %arrayidx119.us, align 1, !tbaa !0
  %conv120.us = zext i8 %3 to i32
  %add121.us = add nuw nsw i32 %conv116.us, 1
  %add122.us = add nuw nsw i32 %add121.us, %conv120.us
  %shr123.us = lshr i32 %add122.us, 1
  %conv124.us = trunc i32 %shr123.us to i8
  %arrayidx126.us = getelementptr inbounds i8, i8* %d.3515.us, i64 %indvars.iv569
  store i8 %conv124.us, i8* %arrayidx126.us, align 1, !tbaa !0
  %indvars.iv.next570 = add nuw nsw i64 %indvars.iv569, 1
  %lftr.wideiv618 = trunc i64 %indvars.iv.next570 to i32
  %exitcond619 = icmp eq i32 %lftr.wideiv618, %w
  br i1 %exitcond619, label %for.cond.110.for.end.129_crit_edge.us, label %for.body.113.us

for.cond.110.for.end.129_crit_edge.us:            ; preds = %for.body.113.us
  %add.ptr131.us = getelementptr inbounds i8, i8* %s.3514.us, i64 %idx.ext130
  %add.ptr133.us = getelementptr inbounds i8, i8* %d.3515.us, i64 %idx.ext130
  %inc135.us = add nuw nsw i32 %j.3513.us, 1
  %exitcond574 = icmp eq i32 %inc135.us, %h
  br i1 %exitcond574, label %if.end.318.loopexit610, label %for.body.113.lr.ph.us

if.end.318.loopexit610:                           ; preds = %for.cond.110.for.end.129_crit_edge.us
  br label %if.end.318.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
