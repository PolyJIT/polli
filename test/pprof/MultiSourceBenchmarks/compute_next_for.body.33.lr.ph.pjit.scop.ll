
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/Prolangs-C/agrep/main.c.compute_next_for.body.33.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @compute_next_for.body.33.lr.ph.pjit.scop(i32 %ex.0.lcssa.i, i32 %M, i32* %Next, [32 x i32]* %V, [33 x i32]* nonnull %Bit)  {
newFuncRoot:
  br label %for.body.33.lr.ph

cleanup.exitStub:                                 ; preds = %cleanup.loopexit281, %cleanup.loopexit
  ret void

for.body.33.lr.ph:                                ; preds = %newFuncRoot
  %shr = ashr i32 %ex.0.lcssa.i, 1
  %cmp37.222 = icmp sgt i32 %M, 0
  br i1 %cmp37.222, label %for.body.33.us.preheader, label %for.body.33.preheader

for.body.33.us.preheader:                         ; preds = %for.body.33.lr.ph
  %0 = sext i32 %M to i64
  %1 = sext i32 %ex.0.lcssa.i to i64
  %2 = shl i32 %ex.0.lcssa.i, 1
  br label %for.body.33.us

for.body.33.us:                                   ; preds = %for.cond.36.for.inc.50_crit_edge.us, %for.body.33.us.preheader
  %indvars.iv245 = phi i64 [ %1, %for.body.33.us.preheader ], [ %indvars.iv.next246, %for.cond.36.for.inc.50_crit_edge.us ]
  %arrayidx35.us = getelementptr inbounds i32, i32* %Next, i64 %indvars.iv245
  store i32 %shr, i32* %arrayidx35.us, align 4, !tbaa !0
  %3 = trunc i64 %indvars.iv245 to i32
  br label %for.body.38.us

for.body.38.us:                                   ; preds = %if.end.us, %for.body.33.us
  %indvars.iv = phi i64 [ %0, %for.body.33.us ], [ %indvars.iv.next, %if.end.us ]
  %n.0223.us = phi i32 [ %3, %for.body.33.us ], [ %shr47.us, %if.end.us ]
  %4 = getelementptr inbounds [33 x i32], [33 x i32]* %Bit, i64 0, i64 32
  %5 = load i32, i32* %4
  %and.us = and i32 %5, %n.0223.us
  %tobool.us = icmp eq i32 %and.us, 0
  br i1 %tobool.us, label %if.end.us, label %if.then.39.us

if.end.us:                                        ; preds = %if.then.39.us, %for.body.38.us
  %shr47.us = ashr i32 %n.0223.us, 1
  %indvars.iv.next = add nsw i64 %indvars.iv, -1
  %cmp37.us = icmp sgt i64 %indvars.iv, 1
  br i1 %cmp37.us, label %for.body.38.us, label %for.cond.36.for.inc.50_crit_edge.us

for.cond.36.for.inc.50_crit_edge.us:              ; preds = %if.end.us
  %indvars.iv.next246 = add nsw i64 %indvars.iv245, 1
  %lftr.wideiv284 = trunc i64 %indvars.iv.next246 to i32
  %exitcond285 = icmp eq i32 %lftr.wideiv284, %2
  br i1 %exitcond285, label %cleanup.loopexit, label %for.body.33.us

cleanup.loopexit:                                 ; preds = %for.cond.36.for.inc.50_crit_edge.us
  br label %cleanup.exitStub

if.then.39.us:                                    ; preds = %for.body.38.us
  %6 = load i32, i32* %arrayidx35.us, align 4, !tbaa !0
  %arrayidx43.us = getelementptr inbounds [32 x i32], [32 x i32]* %V, i64 0, i64 %indvars.iv
  %7 = load i32, i32* %arrayidx43.us, align 4, !tbaa !0
  %or44.us = or i32 %7, %6
  store i32 %or44.us, i32* %arrayidx35.us, align 4, !tbaa !0
  br label %if.end.us

for.body.33.preheader:                            ; preds = %for.body.33.lr.ph
  %8 = sext i32 %ex.0.lcssa.i to i64
  %9 = shl i32 %ex.0.lcssa.i, 1
  br label %for.body.33

for.body.33:                                      ; preds = %for.body.33, %for.body.33.preheader
  %indvars.iv247 = phi i64 [ %8, %for.body.33.preheader ], [ %indvars.iv.next248, %for.body.33 ]
  %arrayidx35 = getelementptr inbounds i32, i32* %Next, i64 %indvars.iv247
  store i32 %shr, i32* %arrayidx35, align 4, !tbaa !0
  %indvars.iv.next248 = add nsw i64 %indvars.iv247, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next248 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %9
  br i1 %exitcond, label %cleanup.loopexit281, label %for.body.33

cleanup.loopexit281:                              ; preds = %for.body.33
  br label %cleanup.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
