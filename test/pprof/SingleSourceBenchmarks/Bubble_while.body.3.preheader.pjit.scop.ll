
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polli-process-unprofitable -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Stanford/Bubblesort.c.Bubble_while.body.3.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @Bubble_while.body.3.preheader.pjit.scop([5001 x i32]* nonnull %sortlist)  {
newFuncRoot:
  br label %while.body.3.preheader

while.end.18.exitStub:                            ; preds = %while.end
  ret void

while.body.3.preheader:                           ; preds = %while.end, %newFuncRoot
  %indvars.iv40 = phi i32 [ %indvars.iv.next41, %while.end ], [ 500, %newFuncRoot ]
  br label %while.body.3

while.body.3:                                     ; preds = %while.cond.1.backedge, %while.body.3.preheader
  %indvars.iv = phi i64 [ 1, %while.body.3.preheader ], [ %indvars.iv.next, %while.cond.1.backedge ]
  %arrayidx = getelementptr inbounds [5001 x i32], [5001 x i32]* %sortlist, i64 0, i64 %indvars.iv
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %arrayidx5 = getelementptr inbounds [5001 x i32], [5001 x i32]* %sortlist, i64 0, i64 %indvars.iv.next
  %1 = load i32, i32* %arrayidx5, align 4, !tbaa !0
  %cmp6 = icmp sgt i32 %0, %1
  br i1 %cmp6, label %if.then, label %while.cond.1.backedge

if.then:                                          ; preds = %while.body.3
  store i32 %1, i32* %arrayidx, align 4, !tbaa !0
  store i32 %0, i32* %arrayidx5, align 4, !tbaa !0
  br label %while.cond.1.backedge

while.cond.1.backedge:                            ; preds = %if.then, %while.body.3
  %lftr.wideiv42 = trunc i64 %indvars.iv.next to i32
  %exitcond43 = icmp eq i32 %lftr.wideiv42, %indvars.iv40
  br i1 %exitcond43, label %while.end, label %while.body.3

while.end:                                        ; preds = %while.cond.1.backedge
  %indvars.iv.next41 = add nsw i32 %indvars.iv40, -1
  %cmp = icmp sgt i32 %indvars.iv.next41, 1
  br i1 %cmp, label %while.body.3.preheader, label %while.end.18.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
