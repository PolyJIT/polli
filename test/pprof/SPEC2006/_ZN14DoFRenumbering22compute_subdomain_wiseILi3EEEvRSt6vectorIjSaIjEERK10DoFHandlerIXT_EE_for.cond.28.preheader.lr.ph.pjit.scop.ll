
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/447.dealII/src/dof_renumbering.cc._ZN14DoFRenumbering22compute_subdomain_wiseILi3EEEvRSt6vectorIjSaIjEERK10DoFHandlerIXT_EE_for.cond.28.preheader.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZN14DoFRenumbering22compute_subdomain_wiseILi3EEEvRSt6vectorIjSaIjEERK10DoFHandlerIXT_EE_for.cond.28.preheader.lr.ph.pjit.scop(i32, i32** %_M_start.i.i.i, i32**, i32)  {
newFuncRoot:
  br label %for.cond.28.preheader.lr.ph

for.cond.cleanup.exitStub:                        ; preds = %for.cond.cleanup.loopexit, %for.cond.28.preheader.lr.ph
  ret void

for.cond.28.preheader.lr.ph:                      ; preds = %newFuncRoot
  %cmp29.71 = icmp eq i32 %0, 0
  %3 = load i32*, i32** %_M_start.i.i.i, align 8, !tbaa !0
  %4 = load i32*, i32** %1, align 8, !tbaa !0
  br i1 %cmp29.71, label %for.cond.cleanup.exitStub, label %for.body.31.lr.ph.us.preheader

for.body.31.lr.ph.us.preheader:                   ; preds = %for.cond.28.preheader.lr.ph
  br label %for.body.31.lr.ph.us

for.body.31.lr.ph.us:                             ; preds = %for.cond.28.for.cond.cleanup.30_crit_edge.us, %for.body.31.lr.ph.us.preheader
  %subdomain.076.us = phi i32 [ %inc41.us, %for.cond.28.for.cond.cleanup.30_crit_edge.us ], [ 0, %for.body.31.lr.ph.us.preheader ]
  %next_free_index.075.us = phi i32 [ %next_free_index.2.us.lcssa, %for.cond.28.for.cond.cleanup.30_crit_edge.us ], [ 0, %for.body.31.lr.ph.us.preheader ]
  br label %for.body.31.us

for.body.31.us:                                   ; preds = %for.inc.us, %for.body.31.lr.ph.us
  %indvars.iv = phi i64 [ 0, %for.body.31.lr.ph.us ], [ %indvars.iv.next, %for.inc.us ]
  %next_free_index.172.us = phi i32 [ %next_free_index.075.us, %for.body.31.lr.ph.us ], [ %next_free_index.2.us, %for.inc.us ]
  %add.ptr.i.61.us = getelementptr inbounds i32, i32* %3, i64 %indvars.iv
  %5 = load i32, i32* %add.ptr.i.61.us, align 4, !tbaa !6
  %cmp35.us = icmp eq i32 %5, %subdomain.076.us
  br i1 %cmp35.us, label %if.then.us, label %for.inc.us

if.then.us:                                       ; preds = %for.body.31.us
  %add.ptr.i.us = getelementptr inbounds i32, i32* %4, i64 %indvars.iv
  store i32 %next_free_index.172.us, i32* %add.ptr.i.us, align 4, !tbaa !6
  %inc.us = add i32 %next_free_index.172.us, 1
  br label %for.inc.us

for.inc.us:                                       ; preds = %if.then.us, %for.body.31.us
  %next_free_index.2.us = phi i32 [ %inc.us, %if.then.us ], [ %next_free_index.172.us, %for.body.31.us ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv82 = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv82, %0
  br i1 %exitcond, label %for.cond.28.for.cond.cleanup.30_crit_edge.us, label %for.body.31.us

for.cond.28.for.cond.cleanup.30_crit_edge.us:     ; preds = %for.inc.us
  %next_free_index.2.us.lcssa = phi i32 [ %next_free_index.2.us, %for.inc.us ]
  %inc41.us = add nuw i32 %subdomain.076.us, 1
  %exitcond79 = icmp eq i32 %subdomain.076.us, %2
  br i1 %exitcond79, label %for.cond.cleanup.loopexit, label %for.body.31.lr.ph.us

for.cond.cleanup.loopexit:                        ; preds = %for.cond.28.for.cond.cleanup.30_crit_edge.us
  br label %for.cond.cleanup.exitStub
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
