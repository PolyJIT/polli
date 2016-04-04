
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/447.dealII/src/fe_dgq.cc._ZNK6FE_DGQILi3EE14rotate_indicesERSt6vectorIjSaIjEEc_for.cond.35.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::vector.27" = type { %"struct.std::_Vector_base.28" }
%"struct.std::_Vector_base.28" = type { %"struct.std::_Vector_base<unsigned int, std::allocator<unsigned int> >::_Vector_impl" }
%"struct.std::_Vector_base<unsigned int, std::allocator<unsigned int> >::_Vector_impl" = type { i32*, i32*, i32* }

define weak void @_ZNK6FE_DGQILi3EE14rotate_indicesERSt6vectorIjSaIjEEc_for.cond.35.preheader.pjit.scop(i32 %add, %"class.std::vector.27"* %numbers, i32)  {
newFuncRoot:
  br label %for.cond.35.preheader

sw.epilog.exitStub:                               ; preds = %sw.epilog.loopexit698, %for.cond.35.preheader
  ret void

for.cond.35.preheader:                            ; preds = %newFuncRoot
  %cmp36.252 = icmp eq i32 %add, 0
  br i1 %cmp36.252, label %sw.epilog.exitStub, label %for.cond.39.preheader.lr.ph

for.cond.39.preheader.lr.ph:                      ; preds = %for.cond.35.preheader
  %cmp44.243 = icmp eq i32 %add, 0
  %_M_start.i.223 = getelementptr inbounds %"class.std::vector.27", %"class.std::vector.27"* %numbers, i64 0, i32 0, i32 0, i32 0
  %1 = load i32*, i32** %_M_start.i.223, align 8, !tbaa !0
  %2 = add i32 %0, 1
  %3 = add i32 %0, 2
  %4 = mul i32 %3, %0
  %5 = add i32 %4, 1
  br label %for.cond.43.preheader.lr.ph.us

for.cond.43.preheader.lr.ph.us:                   ; preds = %for.cond.39.for.cond.cleanup.41_crit_edge.us, %for.cond.39.preheader.lr.ph
  %l.3255.us = phi i32 [ %split251.us, %for.cond.39.for.cond.cleanup.41_crit_edge.us ], [ 0, %for.cond.39.preheader.lr.ph ]
  %iz34.0253.us = phi i32 [ %inc65.us, %for.cond.39.for.cond.cleanup.41_crit_edge.us ], [ 0, %for.cond.39.preheader.lr.ph ]
  %mul53.us = mul i32 %iz34.0253.us, %add
  br i1 %cmp44.243, label %for.cond.39.for.cond.cleanup.41_crit_edge.us, label %for.body.46.lr.ph.us.us.preheader

for.cond.39.for.cond.cleanup.41_crit_edge.us:     ; preds = %for.cond.39.for.cond.cleanup.41_crit_edge.us.loopexit, %for.cond.43.preheader.lr.ph.us
  %split251.us = phi i32 [ %8, %for.cond.39.for.cond.cleanup.41_crit_edge.us.loopexit ], [ %l.3255.us, %for.cond.43.preheader.lr.ph.us ]
  %inc65.us = add nuw i32 %iz34.0253.us, 1
  %exitcond681 = icmp eq i32 %inc65.us, %2
  br i1 %exitcond681, label %sw.epilog.loopexit698, label %for.cond.43.preheader.lr.ph.us

sw.epilog.loopexit698:                            ; preds = %for.cond.39.for.cond.cleanup.41_crit_edge.us
  br label %sw.epilog.exitStub

for.body.46.lr.ph.us.us.preheader:                ; preds = %for.cond.43.preheader.lr.ph.us
  br label %for.body.46.lr.ph.us.us

for.body.46.lr.ph.us.us:                          ; preds = %for.cond.43.for.cond.cleanup.45_crit_edge.us.us, %for.body.46.lr.ph.us.us.preheader
  %l.4250.us.us = phi i32 [ %7, %for.cond.43.for.cond.cleanup.45_crit_edge.us.us ], [ %l.3255.us, %for.body.46.lr.ph.us.us.preheader ]
  %iy.0248.us.us = phi i32 [ %inc62.us.us, %for.cond.43.for.cond.cleanup.45_crit_edge.us.us ], [ 0, %for.body.46.lr.ph.us.us.preheader ]
  %sub51.us.us = sub i32 %0, %iy.0248.us.us
  br label %for.body.46.us.us

for.body.46.us.us:                                ; preds = %for.body.46.us.us, %for.body.46.lr.ph.us.us
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body.46.us.us ], [ 0, %for.body.46.lr.ph.us.us ]
  %l.5245.us.us = phi i32 [ %inc55.us.us, %for.body.46.us.us ], [ %l.4250.us.us, %for.body.46.lr.ph.us.us ]
  %6 = trunc i64 %indvars.iv to i32
  %tmp226.us.us = add i32 %6, %mul53.us
  %tmp227.us.us = mul i32 %tmp226.us.us, %add
  %add54.us.us = add i32 %sub51.us.us, %tmp227.us.us
  %inc55.us.us = add i32 %l.5245.us.us, 1
  %conv56.us.us = zext i32 %add54.us.us to i64
  %add.ptr.i.224.us.us = getelementptr inbounds i32, i32* %1, i64 %conv56.us.us
  store i32 %l.5245.us.us, i32* %add.ptr.i.224.us.us, align 4, !tbaa !6
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv701 = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv701, %2
  br i1 %exitcond, label %for.cond.43.for.cond.cleanup.45_crit_edge.us.us, label %for.body.46.us.us

for.cond.43.for.cond.cleanup.45_crit_edge.us.us:  ; preds = %for.body.46.us.us
  %7 = add i32 %l.4250.us.us, %2
  %inc62.us.us = add nuw i32 %iy.0248.us.us, 1
  %exitcond680 = icmp eq i32 %inc62.us.us, %2
  br i1 %exitcond680, label %for.cond.39.for.cond.cleanup.41_crit_edge.us.loopexit, label %for.body.46.lr.ph.us.us

for.cond.39.for.cond.cleanup.41_crit_edge.us.loopexit: ; preds = %for.cond.43.for.cond.cleanup.45_crit_edge.us.us
  %8 = add i32 %5, %l.3255.us
  br label %for.cond.39.for.cond.cleanup.41_crit_edge.us
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !3, i64 0}
!1 = !{!"_ZTSSt12_Vector_baseIjSaIjEE", !2, i64 0}
!2 = !{!"_ZTSNSt12_Vector_baseIjSaIjEE12_Vector_implE", !3, i64 0, !3, i64 8, !3, i64 16}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !4, i64 0}
