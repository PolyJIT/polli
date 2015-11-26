
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Shootout-C++/ary3.cpp.main_for.cond.12.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @main_for.cond.12.preheader.pjit.scop(i32 %cond, i32* %x.sroa.0.0145, i32*)  {
newFuncRoot:
  br label %for.cond.12.preheader

for.end.30.exitStub:                              ; preds = %for.end.30.loopexit, %for.cond.12.preheader
  ret void

for.cond.12.preheader:                            ; preds = %newFuncRoot
  %cmp17.151 = icmp sgt i32 %cond, 0
  br i1 %cmp17.151, label %for.body.18.lr.ph.us.preheader, label %for.end.30.exitStub

for.body.18.lr.ph.us.preheader:                   ; preds = %for.cond.12.preheader
  %1 = sext i32 %cond to i64
  br label %for.body.18.lr.ph.us

for.body.18.lr.ph.us:                             ; preds = %for.cond.16.for.cond.cleanup_crit_edge.us, %for.body.18.lr.ph.us.preheader
  %k.0153.us = phi i32 [ %inc29.us, %for.cond.16.for.cond.cleanup_crit_edge.us ], [ 0, %for.body.18.lr.ph.us.preheader ]
  br label %for.body.18.us

for.body.18.us:                                   ; preds = %for.body.18.us, %for.body.18.lr.ph.us
  %indvars.iv = phi i64 [ %1, %for.body.18.lr.ph.us ], [ %indvars.iv.next, %for.body.18.us ]
  %indvars.iv.next = add nsw i64 %indvars.iv, -1
  %add.ptr.i.112.us = getelementptr inbounds i32, i32* %x.sroa.0.0145, i64 %indvars.iv.next
  %2 = load i32, i32* %add.ptr.i.112.us, align 4, !tbaa !0
  %add.ptr.i.114.us = getelementptr inbounds i32, i32* %0, i64 %indvars.iv.next
  %3 = load i32, i32* %add.ptr.i.114.us, align 4, !tbaa !0
  %add25.us = add nsw i32 %3, %2
  store i32 %add25.us, i32* %add.ptr.i.114.us, align 4, !tbaa !0
  %cmp17.us = icmp sgt i64 %indvars.iv, 1
  br i1 %cmp17.us, label %for.body.18.us, label %for.cond.16.for.cond.cleanup_crit_edge.us

for.cond.16.for.cond.cleanup_crit_edge.us:        ; preds = %for.body.18.us
  %inc29.us = add nuw nsw i32 %k.0153.us, 1
  %exitcond = icmp eq i32 %inc29.us, 1000
  br i1 %exitcond, label %for.end.30.loopexit, label %for.body.18.lr.ph.us

for.end.30.loopexit:                              ; preds = %for.cond.16.for.cond.cleanup_crit_edge.us
  br label %for.end.30.exitStub
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
