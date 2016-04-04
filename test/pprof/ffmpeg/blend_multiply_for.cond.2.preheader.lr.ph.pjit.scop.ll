
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'libavfilter/vf_blend.c.blend_multiply_for.cond.2.preheader.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @blend_multiply_for.cond.2.preheader.lr.ph.pjit.scop(i32 %width, i32 %dst_linesize, i32 %top_linesize, i32 %bottom_linesize, i32 %start, i8* %top, i8* %bottom, i8* %dst, double, i32 %end)  {
newFuncRoot:
  br label %for.cond.2.preheader.lr.ph

for.end.27.exitStub:                              ; preds = %for.end.27.loopexit, %for.cond.2.preheader.lr.ph
  ret void

for.cond.2.preheader.lr.ph:                       ; preds = %newFuncRoot
  %cmp3.43 = icmp sgt i32 %width, 0
  %idx.ext = sext i32 %dst_linesize to i64
  %idx.ext21 = sext i32 %top_linesize to i64
  %idx.ext23 = sext i32 %bottom_linesize to i64
  br i1 %cmp3.43, label %for.body.4.lr.ph.us.preheader, label %for.end.27.exitStub

for.body.4.lr.ph.us.preheader:                    ; preds = %for.cond.2.preheader.lr.ph
  br label %for.body.4.lr.ph.us

for.body.4.lr.ph.us:                              ; preds = %for.cond.2.for.end_crit_edge.us, %for.body.4.lr.ph.us.preheader
  %i.049.us = phi i32 [ %inc26.us, %for.cond.2.for.end_crit_edge.us ], [ %start, %for.body.4.lr.ph.us.preheader ]
  %top.addr.048.us = phi i8* [ %add.ptr22.us, %for.cond.2.for.end_crit_edge.us ], [ %top, %for.body.4.lr.ph.us.preheader ]
  %bottom.addr.047.us = phi i8* [ %add.ptr24.us, %for.cond.2.for.end_crit_edge.us ], [ %bottom, %for.body.4.lr.ph.us.preheader ]
  %dst.addr.046.us = phi i8* [ %add.ptr.us, %for.cond.2.for.end_crit_edge.us ], [ %dst, %for.body.4.lr.ph.us.preheader ]
  br label %for.body.4.us

for.body.4.us:                                    ; preds = %for.body.4.us, %for.body.4.lr.ph.us
  %indvars.iv = phi i64 [ 0, %for.body.4.lr.ph.us ], [ %indvars.iv.next, %for.body.4.us ]
  %arrayidx.us = getelementptr inbounds i8, i8* %top.addr.048.us, i64 %indvars.iv
  %1 = load i8, i8* %arrayidx.us, align 1, !tbaa !0
  %conv.us = zext i8 %1 to i32
  %conv5.us = uitofp i8 %1 to double
  %arrayidx10.us = getelementptr inbounds i8, i8* %bottom.addr.047.us, i64 %indvars.iv
  %2 = load i8, i8* %arrayidx10.us, align 1, !tbaa !0
  %conv11.us = zext i8 %2 to i32
  %mul.us = mul nuw nsw i32 %conv11.us, %conv.us
  %div.us = udiv i32 %mul.us, 255
  %sub.us = sub nsw i32 %div.us, %conv.us
  %conv16.us = sitofp i32 %sub.us to double
  %mul17.us = fmul nsz double %0, %conv16.us
  %add.us = fadd nsz double %conv5.us, %mul17.us
  %conv18.us = fptoui double %add.us to i8
  %arrayidx20.us = getelementptr inbounds i8, i8* %dst.addr.046.us, i64 %indvars.iv
  store i8 %conv18.us, i8* %arrayidx20.us, align 1, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv53 = trunc i64 %indvars.iv.next to i32
  %exitcond54 = icmp eq i32 %lftr.wideiv53, %width
  br i1 %exitcond54, label %for.cond.2.for.end_crit_edge.us, label %for.body.4.us

for.cond.2.for.end_crit_edge.us:                  ; preds = %for.body.4.us
  %add.ptr.us = getelementptr inbounds i8, i8* %dst.addr.046.us, i64 %idx.ext
  %add.ptr22.us = getelementptr inbounds i8, i8* %top.addr.048.us, i64 %idx.ext21
  %add.ptr24.us = getelementptr inbounds i8, i8* %bottom.addr.047.us, i64 %idx.ext23
  %inc26.us = add nsw i32 %i.049.us, 1
  %exitcond51 = icmp eq i32 %inc26.us, %end
  br i1 %exitcond51, label %for.end.27.loopexit, label %for.body.4.lr.ph.us

for.end.27.loopexit:                              ; preds = %for.cond.2.for.end_crit_edge.us
  br label %for.end.27.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
