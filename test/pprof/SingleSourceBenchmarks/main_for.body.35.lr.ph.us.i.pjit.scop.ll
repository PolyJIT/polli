
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Linpack/linpack-pc.c.main_for.body.35.lr.ph.us.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.35.lr.ph.us.i.pjit.scop([200 x float]* nonnull %main.b, [40200 x float]* nonnull %main.a)  {
newFuncRoot:
  br label %for.body.35.lr.ph.us.i

matgen.exit.exitStub:                             ; preds = %for.cond.32.for.inc.48_crit_edge.us.i
  ret void

for.body.35.lr.ph.us.i:                           ; preds = %for.cond.32.for.inc.48_crit_edge.us.i, %newFuncRoot
  %indvars.iv106.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next107.i, %for.cond.32.for.inc.48_crit_edge.us.i ]
  %0 = mul nuw nsw i64 %indvars.iv106.i, 201
  br label %for.body.35.us.i

for.body.35.us.i:                                 ; preds = %for.body.35.us.i, %for.body.35.lr.ph.us.i
  %indvars.iv.i = phi i64 [ 0, %for.body.35.lr.ph.us.i ], [ %indvars.iv.next.i, %for.body.35.us.i ]
  %arrayidx37.us.i = getelementptr inbounds [200 x float], [200 x float]* %main.b, i64 0, i64 %indvars.iv.i
  %1 = load float, float* %arrayidx37.us.i, align 4, !tbaa !0
  %2 = add nuw nsw i64 %indvars.iv.i, %0
  %arrayidx41.us.i = getelementptr inbounds [40200 x float], [40200 x float]* %main.a, i64 0, i64 %2
  %3 = load float, float* %arrayidx41.us.i, align 4, !tbaa !0
  %add42.us.i = fadd float %1, %3
  store float %add42.us.i, float* %arrayidx37.us.i, align 4, !tbaa !0
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %exitcond842 = icmp eq i64 %indvars.iv.next.i, 100
  br i1 %exitcond842, label %for.cond.32.for.inc.48_crit_edge.us.i, label %for.body.35.us.i

for.cond.32.for.inc.48_crit_edge.us.i:            ; preds = %for.body.35.us.i
  %indvars.iv.next107.i = add nuw nsw i64 %indvars.iv106.i, 1
  %exitcond843 = icmp eq i64 %indvars.iv.next107.i, 100
  br i1 %exitcond843, label %matgen.exit.exitStub, label %for.body.35.lr.ph.us.i
}

attributes #0 = { nounwind "polyjit-global-count"="2" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
