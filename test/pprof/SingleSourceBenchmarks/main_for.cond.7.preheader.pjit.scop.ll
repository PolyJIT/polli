
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Shootout/ary3.c.main_for.cond.7.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.7.preheader.pjit.scop(i32 %cond, i32*, i32*)  {
newFuncRoot:
  br label %for.cond.7.preheader

for.end.24.exitStub:                              ; preds = %for.end.24.loopexit, %for.cond.7.preheader
  ret void

for.cond.7.preheader:                             ; preds = %newFuncRoot
  %cmp12.53 = icmp sgt i32 %cond, 0
  br i1 %cmp12.53, label %for.body.14.lr.ph.us.preheader, label %for.end.24.exitStub

for.body.14.lr.ph.us.preheader:                   ; preds = %for.cond.7.preheader
  %2 = sext i32 %cond to i64
  br label %for.body.14.lr.ph.us

for.body.14.lr.ph.us:                             ; preds = %for.cond.11.for.inc.22_crit_edge.us, %for.body.14.lr.ph.us.preheader
  %k.055.us = phi i32 [ %inc23.us, %for.cond.11.for.inc.22_crit_edge.us ], [ 0, %for.body.14.lr.ph.us.preheader ]
  br label %for.body.14.us

for.body.14.us:                                   ; preds = %for.body.14.us, %for.body.14.lr.ph.us
  %indvars.iv = phi i64 [ %2, %for.body.14.lr.ph.us ], [ %indvars.iv.next, %for.body.14.us ]
  %indvars.iv.next = add nsw i64 %indvars.iv, -1
  %arrayidx16.us = getelementptr inbounds i32, i32* %0, i64 %indvars.iv.next
  %3 = load i32, i32* %arrayidx16.us, align 4, !tbaa !0
  %arrayidx18.us = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next
  %4 = load i32, i32* %arrayidx18.us, align 4, !tbaa !0
  %add19.us = add nsw i32 %4, %3
  store i32 %add19.us, i32* %arrayidx18.us, align 4, !tbaa !0
  %cmp12.us = icmp sgt i64 %indvars.iv, 1
  br i1 %cmp12.us, label %for.body.14.us, label %for.cond.11.for.inc.22_crit_edge.us

for.cond.11.for.inc.22_crit_edge.us:              ; preds = %for.body.14.us
  %inc23.us = add nuw nsw i32 %k.055.us, 1
  %exitcond = icmp eq i32 %inc23.us, 1000
  br i1 %exitcond, label %for.end.24.loopexit, label %for.body.14.lr.ph.us

for.end.24.loopexit:                              ; preds = %for.cond.11.for.inc.22_crit_edge.us
  br label %for.end.24.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
