
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'common/pixel.c.pixel_ssd_nv12_core_for.body.4.lr.ph.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @pixel_ssd_nv12_core_for.body.4.lr.ph.us.pjit.scop(i8* %pixuv1, i8* %pixuv2, i64* %ssd_u, i64* %ssd_v, i32 %width, i64 %stride1, i64 %stride2, i32 %height)  {
newFuncRoot:
  br label %for.body.4.lr.ph.us

for.cond.cleanup.loopexit.exitStub:               ; preds = %for.cond.1.for.cond.cleanup.3_crit_edge.us
  ret void

for.body.4.lr.ph.us:                              ; preds = %for.cond.1.for.cond.cleanup.3_crit_edge.us, %newFuncRoot
  %pixuv1.addr.054.us = phi i8* [ %add.ptr.us, %for.cond.1.for.cond.cleanup.3_crit_edge.us ], [ %pixuv1, %newFuncRoot ]
  %pixuv2.addr.053.us = phi i8* [ %add.ptr27.us, %for.cond.1.for.cond.cleanup.3_crit_edge.us ], [ %pixuv2, %newFuncRoot ]
  %y.052.us = phi i32 [ %inc26.us, %for.cond.1.for.cond.cleanup.3_crit_edge.us ], [ 0, %newFuncRoot ]
  br label %for.body.4.us

for.body.4.us:                                    ; preds = %for.body.4.us, %for.body.4.lr.ph.us
  %indvars.iv = phi i64 [ 0, %for.body.4.lr.ph.us ], [ %indvars.iv.next, %for.body.4.us ]
  %0 = shl nsw i64 %indvars.iv, 1
  %arrayidx.us = getelementptr inbounds i8, i8* %pixuv1.addr.054.us, i64 %0
  %1 = load i8, i8* %arrayidx.us, align 1, !tbaa !0
  %conv.us = zext i8 %1 to i32
  %arrayidx7.us = getelementptr inbounds i8, i8* %pixuv2.addr.053.us, i64 %0
  %2 = load i8, i8* %arrayidx7.us, align 1, !tbaa !0
  %conv8.us = zext i8 %2 to i32
  %sub.us = sub nsw i32 %conv.us, %conv8.us
  %3 = or i64 %0, 1
  %arrayidx11.us = getelementptr inbounds i8, i8* %pixuv1.addr.054.us, i64 %3
  %4 = load i8, i8* %arrayidx11.us, align 1, !tbaa !0
  %conv12.us = zext i8 %4 to i32
  %arrayidx16.us = getelementptr inbounds i8, i8* %pixuv2.addr.053.us, i64 %3
  %5 = load i8, i8* %arrayidx16.us, align 1, !tbaa !0
  %conv17.us = zext i8 %5 to i32
  %sub18.us = sub nsw i32 %conv12.us, %conv17.us
  %mul19.us = mul nsw i32 %sub.us, %sub.us
  %conv20.47.us = zext i32 %mul19.us to i64
  %6 = load i64, i64* %ssd_u, align 8, !tbaa !3
  %add21.us = add i64 %conv20.47.us, %6
  store i64 %add21.us, i64* %ssd_u, align 8, !tbaa !3
  %mul22.us = mul nsw i32 %sub18.us, %sub18.us
  %conv23.48.us = zext i32 %mul22.us to i64
  %7 = load i64, i64* %ssd_v, align 8, !tbaa !3
  %add24.us = add i64 %conv23.48.us, %7
  store i64 %add24.us, i64* %ssd_v, align 8, !tbaa !3
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv60 = trunc i64 %indvars.iv.next to i32
  %exitcond61 = icmp eq i32 %lftr.wideiv60, %width
  br i1 %exitcond61, label %for.cond.1.for.cond.cleanup.3_crit_edge.us, label %for.body.4.us

for.cond.1.for.cond.cleanup.3_crit_edge.us:       ; preds = %for.body.4.us
  %inc26.us = add nuw nsw i32 %y.052.us, 1
  %add.ptr.us = getelementptr inbounds i8, i8* %pixuv1.addr.054.us, i64 %stride1
  %add.ptr27.us = getelementptr inbounds i8, i8* %pixuv2.addr.053.us, i64 %stride2
  %exitcond58 = icmp eq i32 %inc26.us, %height
  br i1 %exitcond58, label %for.cond.cleanup.loopexit.exitStub, label %for.body.4.lr.ph.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
!3 = !{!4, !4, i64 0}
!4 = !{!"long", !1, i64 0}
