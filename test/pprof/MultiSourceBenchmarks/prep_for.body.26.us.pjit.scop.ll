
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/Prolangs-C/agrep/sgrep.c.prep_for.body.26.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @prep_for.body.26.us.pjit.scop(i32 %div, i32 %sub2, i1 %cmp36.173, i32, i8* %Pattern, i32* nonnull %shift_1)  {
newFuncRoot:
  br label %for.body.26.us

for.end.65.loopexit.exitStub:                     ; preds = %for.cond.30.for.inc.63_crit_edge.us
  ret void

for.body.26.us:                                   ; preds = %for.cond.30.for.inc.63_crit_edge.us, %newFuncRoot
  %i.2179.us = phi i32 [ %inc64.us, %for.cond.30.for.inc.63_crit_edge.us ], [ 0, %newFuncRoot ]
  %mul28.us = mul i32 %i.2179.us, %div
  %sub29.us = sub i32 %sub2, %mul28.us
  br i1 %cmp36.173, label %for.cond.30.for.inc.63_crit_edge.us, label %for.body.38.lr.ph.us202.preheader

for.cond.30.for.inc.63_crit_edge.us:              ; preds = %for.cond.30.for.inc.63_crit_edge.us.loopexit, %for.body.26.us
  %inc64.us = add nuw nsw i32 %i.2179.us, 1
  %exitcond225 = icmp eq i32 %inc64.us, %0
  br i1 %exitcond225, label %for.end.65.loopexit.exitStub, label %for.body.26.us

for.body.38.lr.ph.us202.preheader:                ; preds = %for.body.26.us
  br label %for.body.38.lr.ph.us202

for.body.38.lr.ph.us202:                          ; preds = %for.cond.34.for.inc.60_crit_edge.us207, %for.body.38.lr.ph.us202.preheader
  %indvars.iv220 = phi i64 [ %indvars.iv.next221, %for.cond.34.for.inc.60_crit_edge.us207 ], [ 1, %for.body.38.lr.ph.us202.preheader ]
  %1 = trunc i64 %indvars.iv220 to i32
  %sub39.us.204 = sub i32 %sub29.us, %1
  %idxprom40.us.205 = sext i32 %sub39.us.204 to i64
  %arrayidx41.us.206 = getelementptr inbounds i8, i8* %Pattern, i64 %idxprom40.us.205
  br label %for.body.38.us183

for.body.38.us183:                                ; preds = %for.inc.57.us193, %for.body.38.lr.ph.us202
  %indvars.iv217 = phi i64 [ %indvars.iv.next218, %for.inc.57.us193 ], [ 0, %for.body.38.lr.ph.us202 ]
  %2 = load i8, i8* %arrayidx41.us.206, align 1, !tbaa !0
  %3 = trunc i64 %indvars.iv217 to i32
  %mul44.us.185 = mul i32 %3, %div
  %sub45.us.186 = sub i32 %sub2, %mul44.us.185
  %idxprom46.us.187 = zext i32 %sub45.us.186 to i64
  %arrayidx47.us.188 = getelementptr inbounds i8, i8* %Pattern, i64 %idxprom46.us.187
  %4 = load i8, i8* %arrayidx47.us.188, align 1, !tbaa !0
  %cmp49.us.189 = icmp eq i8 %2, %4
  %5 = load i32, i32* %shift_1, align 4
  %6 = sext i32 %5 to i64
  %cmp52.us.190 = icmp slt i64 %indvars.iv220, %6
  %or.cond.us.191 = and i1 %cmp49.us.189, %cmp52.us.190
  br i1 %or.cond.us.191, label %if.then.54.us192, label %for.inc.57.us193

if.then.54.us192:                                 ; preds = %for.body.38.us183
  %7 = trunc i64 %indvars.iv220 to i32
  store i32 %7, i32* %shift_1, align 4, !tbaa !3
  br label %for.inc.57.us193

for.inc.57.us193:                                 ; preds = %if.then.54.us192, %for.body.38.us183
  %indvars.iv.next218 = add nuw nsw i64 %indvars.iv217, 1
  %lftr.wideiv235 = trunc i64 %indvars.iv.next218 to i32
  %exitcond236 = icmp eq i32 %lftr.wideiv235, %0
  br i1 %exitcond236, label %for.cond.34.for.inc.60_crit_edge.us207, label %for.body.38.us183

for.cond.34.for.inc.60_crit_edge.us207:           ; preds = %for.inc.57.us193
  %indvars.iv.next221 = add nuw nsw i64 %indvars.iv220, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next221 to i32
  %exitcond237 = icmp eq i32 %lftr.wideiv, %div
  br i1 %exitcond237, label %for.cond.30.for.inc.63_crit_edge.us.loopexit, label %for.body.38.lr.ph.us202

for.cond.30.for.inc.63_crit_edge.us.loopexit:     ; preds = %for.cond.34.for.inc.60_crit_edge.us207
  br label %for.cond.30.for.inc.63_crit_edge.us
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !1, i64 0}
