; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'common/mc.c.x264_plane_copy_interleave_c_for.body.4.lr.ph.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @x264_plane_copy_interleave_c_for.body.4.lr.ph.us.pjit.scop(i8* %dst, i8* %srcu, i8* %srcv, i32 %w, i64 %i_dst, i64 %i_srcu, i64 %i_srcv, i32 %h)  {
newFuncRoot:
  br label %for.body.4.lr.ph.us

for.cond.cleanup.loopexit.exitStub:               ; preds = %for.cond.1.for.cond.cleanup.3_crit_edge.us
  ret void

for.body.4.lr.ph.us:                              ; preds = %for.cond.1.for.cond.cleanup.3_crit_edge.us, %newFuncRoot
  %y.035.us = phi i32 [ %inc13.us, %for.cond.1.for.cond.cleanup.3_crit_edge.us ], [ 0, %newFuncRoot ]
  %dst.addr.034.us = phi i8* [ %add.ptr.us, %for.cond.1.for.cond.cleanup.3_crit_edge.us ], [ %dst, %newFuncRoot ]
  %srcu.addr.033.us = phi i8* [ %add.ptr14.us, %for.cond.1.for.cond.cleanup.3_crit_edge.us ], [ %srcu, %newFuncRoot ]
  %srcv.addr.032.us = phi i8* [ %add.ptr15.us, %for.cond.1.for.cond.cleanup.3_crit_edge.us ], [ %srcv, %newFuncRoot ]
  br label %for.body.4.us

for.body.4.us:                                    ; preds = %for.body.4.us, %for.body.4.lr.ph.us
  %indvars.iv = phi i64 [ 0, %for.body.4.lr.ph.us ], [ %indvars.iv.next, %for.body.4.us ]
  %arrayidx.us = getelementptr inbounds i8, i8* %srcu.addr.033.us, i64 %indvars.iv
  %0 = load i8, i8* %arrayidx.us, align 1, !tbaa !0
  %1 = shl nsw i64 %indvars.iv, 1
  %arrayidx6.us = getelementptr inbounds i8, i8* %dst.addr.034.us, i64 %1
  store i8 %0, i8* %arrayidx6.us, align 1, !tbaa !0
  %arrayidx8.us = getelementptr inbounds i8, i8* %srcv.addr.032.us, i64 %indvars.iv
  %2 = load i8, i8* %arrayidx8.us, align 1, !tbaa !0
  %3 = or i64 %1, 1
  %arrayidx11.us = getelementptr inbounds i8, i8* %dst.addr.034.us, i64 %3
  store i8 %2, i8* %arrayidx11.us, align 1, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv41 = trunc i64 %indvars.iv.next to i32
  %exitcond42 = icmp eq i32 %lftr.wideiv41, %w
  br i1 %exitcond42, label %for.cond.1.for.cond.cleanup.3_crit_edge.us, label %for.body.4.us

for.cond.1.for.cond.cleanup.3_crit_edge.us:       ; preds = %for.body.4.us
  %inc13.us = add nuw nsw i32 %y.035.us, 1
  %add.ptr.us = getelementptr inbounds i8, i8* %dst.addr.034.us, i64 %i_dst
  %add.ptr14.us = getelementptr inbounds i8, i8* %srcu.addr.033.us, i64 %i_srcu
  %add.ptr15.us = getelementptr inbounds i8, i8* %srcv.addr.032.us, i64 %i_srcv
  %exitcond39 = icmp eq i32 %inc13.us, %h
  br i1 %exitcond39, label %for.cond.cleanup.loopexit.exitStub, label %for.body.4.lr.ph.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
