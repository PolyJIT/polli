
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/Prolangs-C/agrep/main.c.compute_next_for.body.68.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @compute_next_for.body.68.lr.ph.pjit.scop(i32 %div65, i32 %M, i32 %ex.0.lcssa.i.219, i32* %arrayidx, i32* %Next, i32* %Next1, [32 x i32]* %V, [33 x i32]* nonnull %Bit)  {
newFuncRoot:
  br label %for.body.68.lr.ph

cleanup.exitStub:                                 ; preds = %cleanup.loopexit283, %cleanup.loopexit282
  ret void

for.body.68.lr.ph:                                ; preds = %newFuncRoot
  %cmp75.227 = icmp slt i32 %div65, %M
  %cmp98.230 = icmp sgt i32 %M, 1
  br i1 %cmp75.227, label %for.body.68.us.preheader, label %for.body.68.preheader

for.body.68.us.preheader:                         ; preds = %for.body.68.lr.ph
  %0 = sext i32 %M to i64
  %1 = sext i32 %div65 to i64
  %2 = sext i32 %div65 to i64
  %3 = sext i32 %M to i64
  %4 = sext i32 %div65 to i64
  %5 = sext i32 %ex.0.lcssa.i.219 to i64
  %6 = sext i32 %ex.0.lcssa.i.219 to i64
  %7 = shl i32 %ex.0.lcssa.i.219, 1
  br label %for.body.68.us

for.body.68.us:                                   ; preds = %for.inc.118.us, %for.body.68.us.preheader
  %indvars.iv257 = phi i64 [ %5, %for.body.68.us.preheader ], [ %indvars.iv.next258, %for.inc.118.us ]
  %8 = load i32, i32* %arrayidx, align 4, !tbaa !0
  %shr71.us = lshr i32 %8, 1
  %arrayidx73.us = getelementptr inbounds i32, i32* %Next, i64 %indvars.iv257
  store i32 %shr71.us, i32* %arrayidx73.us, align 4, !tbaa !0
  %9 = trunc i64 %indvars.iv257 to i32
  br label %for.body.76.us

for.body.76.us:                                   ; preds = %if.end.88.us, %for.body.68.us
  %indvars.iv251 = phi i64 [ %0, %for.body.68.us ], [ %indvars.iv.next252, %if.end.88.us ]
  %n.1228.us = phi i32 [ %9, %for.body.68.us ], [ %shr89.us, %if.end.88.us ]
  %10 = getelementptr inbounds [33 x i32], [33 x i32]* %Bit, i64 0, i64 32
  %11 = load i32, i32* %10
  %and77.us = and i32 %11, %n.1228.us
  %tobool78.us = icmp eq i32 %and77.us, 0
  br i1 %tobool78.us, label %if.end.88.us, label %if.then.79.us

if.end.88.us:                                     ; preds = %if.then.79.us, %for.body.76.us
  %shr89.us = ashr i32 %n.1228.us, 1
  %indvars.iv.next252 = add nsw i64 %indvars.iv251, -1
  %cmp75.us = icmp sgt i64 %indvars.iv.next252, %2
  br i1 %cmp75.us, label %for.body.76.us, label %for.cond.74.for.end.92_crit_edge.us

for.cond.74.for.end.92_crit_edge.us:              ; preds = %if.end.88.us
  %12 = sub nsw i64 %indvars.iv257, %6
  %arrayidx96.us = getelementptr inbounds i32, i32* %Next1, i64 %12
  store i32 0, i32* %arrayidx96.us, align 4, !tbaa !0
  br i1 %cmp98.230, label %for.body.99.us.preheader, label %for.inc.118.us

for.body.99.us.preheader:                         ; preds = %for.cond.74.for.end.92_crit_edge.us
  %13 = trunc i64 %12 to i32
  br label %for.body.99.us

for.body.99.us:                                   ; preds = %if.end.113.us, %for.body.99.us.preheader
  %indvars.iv254 = phi i64 [ 0, %for.body.99.us.preheader ], [ %indvars.iv.next255, %if.end.113.us ]
  %n.2231.us = phi i32 [ %13, %for.body.99.us.preheader ], [ %shr114.us, %if.end.113.us ]
  %14 = getelementptr inbounds [33 x i32], [33 x i32]* %Bit, i64 0, i64 32
  %15 = load i32, i32* %14
  %and100.us = and i32 %15, %n.2231.us
  %tobool101.us = icmp eq i32 %and100.us, 0
  br i1 %tobool101.us, label %if.end.113.us, label %if.then.102.us

if.end.113.us:                                    ; preds = %if.then.102.us, %for.body.99.us
  %shr114.us = ashr i32 %n.2231.us, 1
  %indvars.iv.next255 = add nuw nsw i64 %indvars.iv254, 1
  %cmp98.us = icmp slt i64 %indvars.iv.next255, %4
  br i1 %cmp98.us, label %for.body.99.us, label %for.inc.118.us.loopexit

for.inc.118.us.loopexit:                          ; preds = %if.end.113.us
  br label %for.inc.118.us

for.inc.118.us:                                   ; preds = %for.inc.118.us.loopexit, %for.cond.74.for.end.92_crit_edge.us
  %indvars.iv.next258 = add nsw i64 %indvars.iv257, 1
  %lftr.wideiv286 = trunc i64 %indvars.iv.next258 to i32
  %exitcond287 = icmp eq i32 %lftr.wideiv286, %7
  br i1 %exitcond287, label %cleanup.loopexit282, label %for.body.68.us

cleanup.loopexit282:                              ; preds = %for.inc.118.us
  br label %cleanup.exitStub

if.then.102.us:                                   ; preds = %for.body.99.us
  %16 = load i32, i32* %arrayidx96.us, align 4, !tbaa !0
  %17 = sub nsw i64 %3, %indvars.iv254
  %arrayidx108.us = getelementptr inbounds [32 x i32], [32 x i32]* %V, i64 0, i64 %17
  %18 = load i32, i32* %arrayidx108.us, align 4, !tbaa !0
  %or109.us = or i32 %18, %16
  store i32 %or109.us, i32* %arrayidx96.us, align 4, !tbaa !0
  br label %if.end.113.us

if.then.79.us:                                    ; preds = %for.body.76.us
  %19 = load i32, i32* %arrayidx73.us, align 4, !tbaa !0
  %20 = sub nsw i64 %indvars.iv251, %1
  %arrayidx84.us = getelementptr inbounds [32 x i32], [32 x i32]* %V, i64 0, i64 %20
  %21 = load i32, i32* %arrayidx84.us, align 4, !tbaa !0
  %or85.us = or i32 %21, %19
  store i32 %or85.us, i32* %arrayidx73.us, align 4, !tbaa !0
  br label %if.end.88.us

for.body.68.preheader:                            ; preds = %for.body.68.lr.ph
  %22 = sext i32 %div65 to i64
  %23 = sext i32 %M to i64
  %24 = sext i32 %ex.0.lcssa.i.219 to i64
  %25 = sext i32 %ex.0.lcssa.i.219 to i64
  %26 = shl i32 %ex.0.lcssa.i.219, 1
  br label %for.body.68

for.body.68:                                      ; preds = %for.inc.118, %for.body.68.preheader
  %indvars.iv265 = phi i64 [ %24, %for.body.68.preheader ], [ %indvars.iv.next266, %for.inc.118 ]
  %27 = load i32, i32* %arrayidx, align 4, !tbaa !0
  %shr71 = lshr i32 %27, 1
  %arrayidx73 = getelementptr inbounds i32, i32* %Next, i64 %indvars.iv265
  store i32 %shr71, i32* %arrayidx73, align 4, !tbaa !0
  %28 = sub nsw i64 %indvars.iv265, %25
  %arrayidx96 = getelementptr inbounds i32, i32* %Next1, i64 %28
  store i32 0, i32* %arrayidx96, align 4, !tbaa !0
  br i1 %cmp98.230, label %for.body.99.preheader, label %for.inc.118

for.body.99.preheader:                            ; preds = %for.body.68
  %29 = trunc i64 %28 to i32
  br label %for.body.99

for.body.99:                                      ; preds = %if.end.113, %for.body.99.preheader
  %indvars.iv262 = phi i64 [ 0, %for.body.99.preheader ], [ %indvars.iv.next263, %if.end.113 ]
  %n.2231 = phi i32 [ %29, %for.body.99.preheader ], [ %shr114, %if.end.113 ]
  %30 = getelementptr inbounds [33 x i32], [33 x i32]* %Bit, i64 0, i64 32
  %31 = load i32, i32* %30
  %and100 = and i32 %31, %n.2231
  %tobool101 = icmp eq i32 %and100, 0
  br i1 %tobool101, label %if.end.113, label %if.then.102

if.end.113:                                       ; preds = %if.then.102, %for.body.99
  %shr114 = ashr i32 %n.2231, 1
  %indvars.iv.next263 = add nuw nsw i64 %indvars.iv262, 1
  %cmp98 = icmp slt i64 %indvars.iv.next263, %22
  br i1 %cmp98, label %for.body.99, label %for.inc.118.loopexit

for.inc.118.loopexit:                             ; preds = %if.end.113
  br label %for.inc.118

for.inc.118:                                      ; preds = %for.inc.118.loopexit, %for.body.68
  %indvars.iv.next266 = add nsw i64 %indvars.iv265, 1
  %lftr.wideiv288 = trunc i64 %indvars.iv.next266 to i32
  %exitcond289 = icmp eq i32 %lftr.wideiv288, %26
  br i1 %exitcond289, label %cleanup.loopexit283, label %for.body.68

cleanup.loopexit283:                              ; preds = %for.inc.118
  br label %cleanup.exitStub

if.then.102:                                      ; preds = %for.body.99
  %32 = load i32, i32* %arrayidx96, align 4, !tbaa !0
  %33 = sub nsw i64 %23, %indvars.iv262
  %arrayidx108 = getelementptr inbounds [32 x i32], [32 x i32]* %V, i64 0, i64 %33
  %34 = load i32, i32* %arrayidx108, align 4, !tbaa !0
  %or109 = or i32 %34, %32
  store i32 %or109, i32* %arrayidx96, align 4, !tbaa !0
  br label %if.end.113
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
