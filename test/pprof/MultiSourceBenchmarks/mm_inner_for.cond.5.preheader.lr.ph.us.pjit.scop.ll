
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/VersaBench/bmm/bmm.c.mm_inner_for.cond.5.preheader.lr.ph.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @mm_inner_for.cond.5.preheader.lr.ph.us.pjit.scop(i64, i32 %I, i1 %cmp7.42, i64, i32 %J, i64, i32 %K, i32 %add6, i32 %add2, i32 %add, [1024 x [1024 x float]]* nonnull %c, [1024 x [1024 x float]]* nonnull %a, [1024 x [1024 x float]]* nonnull %b)  {
newFuncRoot:
  br label %for.cond.5.preheader.lr.ph.us

for.end.25.exitStub:                              ; preds = %for.end.25.loopexit
  ret void

for.cond.5.preheader.lr.ph.us:                    ; preds = %for.cond.1.for.inc.23_crit_edge.us, %newFuncRoot
  %indvars.iv76 = phi i64 [ %0, %newFuncRoot ], [ %indvars.iv.next77, %for.cond.1.for.inc.23_crit_edge.us ]
  %i.049.us = phi i32 [ %I, %newFuncRoot ], [ %inc24.us, %for.cond.1.for.inc.23_crit_edge.us ]
  br i1 %cmp7.42, label %for.body.8.lr.ph.us.us.preheader, label %for.cond.1.for.inc.23_crit_edge.us

for.body.8.lr.ph.us.us.preheader:                 ; preds = %for.cond.5.preheader.lr.ph.us
  br label %for.body.8.lr.ph.us.us

for.body.8.lr.ph.us.us:                           ; preds = %for.cond.5.for.inc.20_crit_edge.us.us, %for.body.8.lr.ph.us.us.preheader
  %indvars.iv74 = phi i64 [ %indvars.iv.next75, %for.cond.5.for.inc.20_crit_edge.us.us ], [ %1, %for.body.8.lr.ph.us.us.preheader ]
  %j.046.us.us = phi i32 [ %inc21.us.us, %for.cond.5.for.inc.20_crit_edge.us.us ], [ %J, %for.body.8.lr.ph.us.us.preheader ]
  %arrayidx18.us.us = getelementptr inbounds [1024 x [1024 x float]], [1024 x [1024 x float]]* %c, i64 0, i64 %indvars.iv76, i64 %indvars.iv74
  %arrayidx18.promoted.us.us = load float, float* %arrayidx18.us.us, align 4, !tbaa !0
  br label %for.body.8.us.us

for.body.8.us.us:                                 ; preds = %for.body.8.us.us, %for.body.8.lr.ph.us.us
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body.8.us.us ], [ %2, %for.body.8.lr.ph.us.us ]
  %3 = phi float [ %add19.us.us, %for.body.8.us.us ], [ %arrayidx18.promoted.us.us, %for.body.8.lr.ph.us.us ]
  %k.043.us.us = phi i32 [ %inc.us.us, %for.body.8.us.us ], [ %K, %for.body.8.lr.ph.us.us ]
  %arrayidx10.us.us = getelementptr inbounds [1024 x [1024 x float]], [1024 x [1024 x float]]* %a, i64 0, i64 %indvars.iv76, i64 %indvars.iv
  %4 = load float, float* %arrayidx10.us.us, align 4, !tbaa !0
  %arrayidx14.us.us = getelementptr inbounds [1024 x [1024 x float]], [1024 x [1024 x float]]* %b, i64 0, i64 %indvars.iv, i64 %indvars.iv74
  %5 = load float, float* %arrayidx14.us.us, align 4, !tbaa !0
  %mul.us.us = fmul float %4, %5
  %add19.us.us = fadd float %3, %mul.us.us
  %inc.us.us = add nsw i32 %k.043.us.us, 1
  %cmp7.us.us = icmp slt i32 %inc.us.us, %add6
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  br i1 %cmp7.us.us, label %for.body.8.us.us, label %for.cond.5.for.inc.20_crit_edge.us.us

for.cond.5.for.inc.20_crit_edge.us.us:            ; preds = %for.body.8.us.us
  %add19.us.us.lcssa = phi float [ %add19.us.us, %for.body.8.us.us ]
  store float %add19.us.us.lcssa, float* %arrayidx18.us.us, align 4, !tbaa !0
  %inc21.us.us = add nsw i32 %j.046.us.us, 1
  %cmp3.us.us = icmp slt i32 %inc21.us.us, %add2
  %indvars.iv.next75 = add nsw i64 %indvars.iv74, 1
  br i1 %cmp3.us.us, label %for.body.8.lr.ph.us.us, label %for.cond.1.for.inc.23_crit_edge.us.loopexit

for.cond.1.for.inc.23_crit_edge.us.loopexit:      ; preds = %for.cond.5.for.inc.20_crit_edge.us.us
  br label %for.cond.1.for.inc.23_crit_edge.us

for.cond.1.for.inc.23_crit_edge.us:               ; preds = %for.cond.1.for.inc.23_crit_edge.us.loopexit, %for.cond.5.preheader.lr.ph.us
  %inc24.us = add nsw i32 %i.049.us, 1
  %cmp.us = icmp slt i32 %inc24.us, %add
  %indvars.iv.next77 = add nsw i64 %indvars.iv76, 1
  br i1 %cmp.us, label %for.cond.5.preheader.lr.ph.us, label %for.end.25.loopexit

for.end.25.loopexit:                              ; preds = %for.cond.1.for.inc.23_crit_edge.us
  br label %for.end.25.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="3" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
