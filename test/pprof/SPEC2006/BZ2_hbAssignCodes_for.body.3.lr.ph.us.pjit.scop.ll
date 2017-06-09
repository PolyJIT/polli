
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/401.bzip2/src/huffman.c.BZ2_hbAssignCodes_for.body.3.lr.ph.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @BZ2_hbAssignCodes_for.body.3.lr.ph.us.pjit.scop(i32 %minLen, i8* %length, i32* %code, i32 %alphaSize, i32 %maxLen)  {
newFuncRoot:
  br label %for.body.3.lr.ph.us

for.end.11.loopexit.exitStub:                     ; preds = %for.cond.1.for.end_crit_edge.us
  ret void

for.body.3.lr.ph.us:                              ; preds = %for.cond.1.for.end_crit_edge.us, %newFuncRoot
  %vec.027.us = phi i32 [ %shl.us, %for.cond.1.for.end_crit_edge.us ], [ 0, %newFuncRoot ]
  %n.026.us = phi i32 [ %inc10.us, %for.cond.1.for.end_crit_edge.us ], [ %minLen, %newFuncRoot ]
  br label %for.body.3.us

for.body.3.us:                                    ; preds = %for.inc.us, %for.body.3.lr.ph.us
  %indvars.iv = phi i64 [ 0, %for.body.3.lr.ph.us ], [ %indvars.iv.next, %for.inc.us ]
  %vec.123.us = phi i32 [ %vec.027.us, %for.body.3.lr.ph.us ], [ %vec.2.us, %for.inc.us ]
  %arrayidx.us = getelementptr inbounds i8, i8* %length, i64 %indvars.iv
  %0 = load i8, i8* %arrayidx.us, align 1, !tbaa !0
  %conv.us = zext i8 %0 to i32
  %cmp4.us = icmp eq i32 %conv.us, %n.026.us
  br i1 %cmp4.us, label %if.then.us, label %for.inc.us

if.then.us:                                       ; preds = %for.body.3.us
  %arrayidx7.us = getelementptr inbounds i32, i32* %code, i64 %indvars.iv
  store i32 %vec.123.us, i32* %arrayidx7.us, align 4, !tbaa !3
  %inc.us = add nsw i32 %vec.123.us, 1
  br label %for.inc.us

for.inc.us:                                       ; preds = %if.then.us, %for.body.3.us
  %vec.2.us = phi i32 [ %inc.us, %if.then.us ], [ %vec.123.us, %for.body.3.us ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv29 = trunc i64 %indvars.iv.next to i32
  %exitcond30 = icmp eq i32 %lftr.wideiv29, %alphaSize
  br i1 %exitcond30, label %for.cond.1.for.end_crit_edge.us, label %for.body.3.us

for.cond.1.for.end_crit_edge.us:                  ; preds = %for.inc.us
  %vec.2.us.lcssa = phi i32 [ %vec.2.us, %for.inc.us ]
  %shl.us = shl i32 %vec.2.us.lcssa, 1
  %inc10.us = add nsw i32 %n.026.us, 1
  %cmp.us = icmp slt i32 %n.026.us, %maxLen
  br i1 %cmp.us, label %for.body.3.lr.ph.us, label %for.end.11.loopexit.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !1, i64 0}
