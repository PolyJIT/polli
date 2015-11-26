
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/obsequi/init.c.initialize_board_for.cond.67.preheader.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.Hash_Key = type { [4 x i32], i32 }

; Function Attrs: nounwind
define weak void @initialize_board_for.cond.67.preheader.lr.ph.pjit.scop(i32 %num_cols, i32 %num_rows, [30 x i32]* %board, %struct.Hash_Key* nonnull %g_norm_hashkey, %struct.Hash_Key* nonnull %g_flipV_hashkey, %struct.Hash_Key* nonnull %g_flipH_hashkey, %struct.Hash_Key* nonnull %g_flipVH_hashkey)  {
newFuncRoot:
  br label %for.cond.67.preheader.lr.ph

for.end.118.exitStub:                             ; preds = %for.end.118.loopexit, %for.cond.67.preheader.lr.ph
  ret void

for.cond.67.preheader.lr.ph:                      ; preds = %newFuncRoot
  %cmp68.309 = icmp sgt i32 %num_cols, 0
  %sub90 = add i32 %num_rows, -1
  br i1 %cmp68.309, label %for.body.69.lr.ph.us.preheader, label %for.end.118.exitStub

for.body.69.lr.ph.us.preheader:                   ; preds = %for.cond.67.preheader.lr.ph
  %0 = sext i32 %num_cols to i64
  %1 = sext i32 %num_cols to i64
  br label %for.body.69.lr.ph.us

for.body.69.lr.ph.us:                             ; preds = %for.cond.67.for.inc.116_crit_edge.us, %for.body.69.lr.ph.us.preheader
  %indvars.iv344 = phi i64 [ 0, %for.body.69.lr.ph.us.preheader ], [ %indvars.iv.next345, %for.cond.67.for.inc.116_crit_edge.us ]
  %2 = mul nsw i64 %indvars.iv344, %1
  %3 = trunc i64 %indvars.iv344 to i32
  %sub91.us = sub i32 %sub90, %3
  %mul92.us = mul nsw i32 %sub91.us, %num_cols
  %4 = sext i32 %mul92.us to i64
  %5 = sext i32 %mul92.us to i64
  br label %for.body.69.us

for.body.69.us:                                   ; preds = %for.inc.113.us, %for.body.69.lr.ph.us
  %indvars.iv = phi i64 [ 0, %for.body.69.lr.ph.us ], [ %indvars.iv.next, %for.inc.113.us ]
  %arrayidx73.us = getelementptr inbounds [30 x i32], [30 x i32]* %board, i64 %indvars.iv344, i64 %indvars.iv
  %6 = load i32, i32* %arrayidx73.us, align 4, !tbaa !0
  %cmp74.us = icmp eq i32 %6, 0
  br i1 %cmp74.us, label %for.inc.113.us, label %if.then.75.us

for.inc.113.us:                                   ; preds = %if.then.75.us, %for.body.69.us
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv381 = trunc i64 %indvars.iv.next to i32
  %exitcond382 = icmp eq i32 %lftr.wideiv381, %num_cols
  br i1 %exitcond382, label %for.cond.67.for.inc.116_crit_edge.us, label %for.body.69.us

for.cond.67.for.inc.116_crit_edge.us:             ; preds = %for.inc.113.us
  %indvars.iv.next345 = add nuw nsw i64 %indvars.iv344, 1
  %lftr.wideiv383 = trunc i64 %indvars.iv.next345 to i32
  %exitcond384 = icmp eq i32 %lftr.wideiv383, %num_rows
  br i1 %exitcond384, label %for.end.118.loopexit, label %for.body.69.lr.ph.us

for.end.118.loopexit:                             ; preds = %for.cond.67.for.inc.116_crit_edge.us
  br label %for.end.118.exitStub

if.then.75.us:                                    ; preds = %for.body.69.us
  %7 = add nsw i64 %indvars.iv, %2
  %8 = trunc i64 %7 to i32
  %rem189.us = and i32 %8, 31
  %shl78.us = shl i32 1, %rem189.us
  %9 = trunc i64 %7 to i32
  %div.us = sdiv i32 %9, 32
  %idxprom79.us = sext i32 %div.us to i64
  %arrayidx80.us = getelementptr inbounds %struct.Hash_Key, %struct.Hash_Key* %g_norm_hashkey, i64 0, i32 0, i64 %idxprom79.us
  %10 = load i32, i32* %arrayidx80.us, align 4, !tbaa !0
  %or.us = or i32 %10, %shl78.us
  store i32 %or.us, i32* %arrayidx80.us, align 4, !tbaa !0
  %11 = sub nsw i64 %0, %indvars.iv
  %12 = add nsw i64 %11, -1
  %13 = add nsw i64 %12, %2
  %14 = trunc i64 %13 to i32
  %rem84190.us = and i32 %14, 31
  %shl85.us = shl i32 1, %rem84190.us
  %15 = trunc i64 %13 to i32
  %div86.us = sdiv i32 %15, 32
  %idxprom87.us = sext i32 %div86.us to i64
  %arrayidx88.us = getelementptr inbounds %struct.Hash_Key, %struct.Hash_Key* %g_flipV_hashkey, i64 0, i32 0, i64 %idxprom87.us
  %16 = load i32, i32* %arrayidx88.us, align 4, !tbaa !0
  %or89.us = or i32 %16, %shl85.us
  store i32 %or89.us, i32* %arrayidx88.us, align 4, !tbaa !0
  %17 = add nsw i64 %indvars.iv, %5
  %18 = trunc i64 %17 to i32
  %rem94191.us = and i32 %18, 31
  %shl95.us = shl i32 1, %rem94191.us
  %19 = trunc i64 %17 to i32
  %div96.us = sdiv i32 %19, 32
  %idxprom97.us = sext i32 %div96.us to i64
  %arrayidx98.us = getelementptr inbounds %struct.Hash_Key, %struct.Hash_Key* %g_flipH_hashkey, i64 0, i32 0, i64 %idxprom97.us
  %20 = load i32, i32* %arrayidx98.us, align 4, !tbaa !0
  %or99.us = or i32 %20, %shl95.us
  store i32 %or99.us, i32* %arrayidx98.us, align 4, !tbaa !0
  %21 = add nsw i64 %12, %4
  %22 = trunc i64 %21 to i32
  %rem106192.us = and i32 %22, 31
  %shl107.us = shl i32 1, %rem106192.us
  %23 = trunc i64 %21 to i32
  %div108.us = sdiv i32 %23, 32
  %idxprom109.us = sext i32 %div108.us to i64
  %arrayidx110.us = getelementptr inbounds %struct.Hash_Key, %struct.Hash_Key* %g_flipVH_hashkey, i64 0, i32 0, i64 %idxprom109.us
  %24 = load i32, i32* %arrayidx110.us, align 4, !tbaa !0
  %or111.us = or i32 %24, %shl107.us
  store i32 %or111.us, i32* %arrayidx110.us, align 4, !tbaa !0
  br label %for.inc.113.us
}

attributes #0 = { nounwind "polyjit-global-count"="4" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
