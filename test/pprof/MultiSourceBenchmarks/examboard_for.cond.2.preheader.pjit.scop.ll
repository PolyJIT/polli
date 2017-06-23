
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/Prolangs-C/gnugo/exambord.c.examboard_for.cond.2.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @examboard_for.cond.2.preheader.pjit.scop(i32 %color, i32* %n.2.lcssa.lcssa.out, [19 x [19 x i8]]* nonnull %p, [19 x [19 x i8]]* nonnull %l, i32* nonnull %uik, i32* nonnull %ujk, i32* nonnull %uk)  {
newFuncRoot:
  br label %for.cond.2.preheader

for.end.32.exitStub:                              ; preds = %for.end.32.loopexit103
  store i32 %n.2.lcssa.lcssa, i32* %n.2.lcssa.lcssa.out
  ret void

for.cond.2.preheader:                             ; preds = %for.inc.30, %newFuncRoot
  %indvars.iv100 = phi i64 [ %indvars.iv.next101, %for.inc.30 ], [ 0, %newFuncRoot ]
  %n.068 = phi i32 [ %n.2.lcssa, %for.inc.30 ], [ 0, %newFuncRoot ]
  br label %for.body.4

for.body.4:                                       ; preds = %for.inc, %for.cond.2.preheader
  %indvars.iv97 = phi i64 [ 0, %for.cond.2.preheader ], [ %indvars.iv.next98, %for.inc ]
  %n.166 = phi i32 [ %n.068, %for.cond.2.preheader ], [ %n.2, %for.inc ]
  %arrayidx6 = getelementptr inbounds [19 x [19 x i8]], [19 x [19 x i8]]* %p, i64 0, i64 %indvars.iv100, i64 %indvars.iv97
  %0 = load i8, i8* %arrayidx6, align 1, !tbaa !0
  %conv = zext i8 %0 to i32
  %cmp7 = icmp eq i32 %conv, %color
  br i1 %cmp7, label %land.lhs.true, label %for.inc

land.lhs.true:                                    ; preds = %for.body.4
  %arrayidx12 = getelementptr inbounds [19 x [19 x i8]], [19 x [19 x i8]]* %l, i64 0, i64 %indvars.iv100, i64 %indvars.iv97
  %1 = load i8, i8* %arrayidx12, align 1, !tbaa !0
  %cmp14 = icmp eq i8 %1, 0
  br i1 %cmp14, label %if.then.16, label %for.inc

if.then.16:                                       ; preds = %land.lhs.true
  store i8 0, i8* %arrayidx6, align 1, !tbaa !0
  %2 = trunc i64 %indvars.iv100 to i32
  store i32 %2, i32* %uik, align 4, !tbaa !3
  %3 = trunc i64 %indvars.iv97 to i32
  store i32 %3, i32* %ujk, align 4, !tbaa !3
  %4 = load i32, i32* %uk, align 4, !tbaa !3
  %inc25 = add nsw i32 %4, 1
  store i32 %inc25, i32* %uk, align 4, !tbaa !3
  %inc27 = add nsw i32 %n.166, 1
  br label %for.inc

for.inc:                                          ; preds = %if.then.16, %land.lhs.true, %for.body.4
  %n.2 = phi i32 [ %inc27, %if.then.16 ], [ %n.166, %land.lhs.true ], [ %n.166, %for.body.4 ]
  %indvars.iv.next98 = add nuw nsw i64 %indvars.iv97, 1
  %exitcond99 = icmp eq i64 %indvars.iv.next98, 19
  br i1 %exitcond99, label %for.inc.30, label %for.body.4

for.inc.30:                                       ; preds = %for.inc
  %n.2.lcssa = phi i32 [ %n.2, %for.inc ]
  %indvars.iv.next101 = add nuw nsw i64 %indvars.iv100, 1
  %exitcond102 = icmp eq i64 %indvars.iv.next101, 19
  br i1 %exitcond102, label %for.end.32.loopexit103, label %for.cond.2.preheader

for.end.32.loopexit103:                           ; preds = %for.inc.30
  %n.2.lcssa.lcssa = phi i32 [ %n.2.lcssa, %for.inc.30 ]
  br label %for.end.32.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="5" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !1, i64 0}
