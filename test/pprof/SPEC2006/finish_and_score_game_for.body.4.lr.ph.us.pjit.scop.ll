
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'interface_play_gtp.c.finish_and_score_game_for.body.4.lr.ph.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @finish_and_score_game_for.body.4.lr.ph.us.pjit.scop(i64, i32 %i.promoted322, i32 %cached_board.1.ph, i32, i32* %cached_board.3.us.lcssa.out, i32* %inc25.us.out, [421 x i8]* nonnull %board, [19 x [19 x i32]]* nonnull %finish_and_score_game.current_board)  {
newFuncRoot:
  br label %for.body.4.lr.ph.us

for.cond.for.end.26_crit_edge.loopexit.exitStub:  ; preds = %for.cond.2.for.inc.24_crit_edge.us
  store i32 %cached_board.3.us.lcssa, i32* %cached_board.3.us.lcssa.out
  store i32 %inc25.us, i32* %inc25.us.out
  ret void

for.body.4.lr.ph.us:                              ; preds = %for.cond.2.for.inc.24_crit_edge.us, %newFuncRoot
  %indvars.iv334 = phi i64 [ %0, %newFuncRoot ], [ %indvars.iv.next335, %for.cond.2.for.inc.24_crit_edge.us ]
  %2 = phi i32 [ %i.promoted322, %newFuncRoot ], [ %inc25.us, %for.cond.2.for.inc.24_crit_edge.us ]
  %cached_board.1314.us = phi i32 [ %cached_board.1.ph, %newFuncRoot ], [ %cached_board.3.us.lcssa, %for.cond.2.for.inc.24_crit_edge.us ]
  br label %for.body.4.us

for.body.4.us:                                    ; preds = %for.inc.us, %for.body.4.lr.ph.us
  %indvars.iv330 = phi i64 [ 0, %for.body.4.lr.ph.us ], [ %indvars.iv.next331, %for.inc.us ]
  %cached_board.2310.us = phi i32 [ %cached_board.1314.us, %for.body.4.lr.ph.us ], [ %cached_board.3.us, %for.inc.us ]
  %3 = mul nsw i64 %indvars.iv334, 20
  %add.us = add nsw i64 %3, 21
  %add5.us = add nsw i64 %add.us, %indvars.iv330
  %sext339 = shl i64 %add5.us, 32
  %idxprom.us = ashr exact i64 %sext339, 32
  %arrayidx.us = getelementptr inbounds [421 x i8], [421 x i8]* %board, i64 0, i64 %idxprom.us
  %4 = load i8, i8* %arrayidx.us, align 1, !tbaa !0
  %conv.us = zext i8 %4 to i32
  %arrayidx9.us = getelementptr inbounds [19 x [19 x i32]], [19 x [19 x i32]]* %finish_and_score_game.current_board, i64 0, i64 %indvars.iv334, i64 %indvars.iv330
  %5 = load i32, i32* %arrayidx9.us, align 4, !tbaa !3
  %cmp10.us = icmp eq i32 %conv.us, %5
  br i1 %cmp10.us, label %for.inc.us, label %if.then.12.us

for.inc.us:                                       ; preds = %if.then.12.us, %for.body.4.us
  %cached_board.3.us = phi i32 [ 0, %if.then.12.us ], [ %cached_board.2310.us, %for.body.4.us ]
  %indvars.iv.next331 = add nuw nsw i64 %indvars.iv330, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next331 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %1
  br i1 %exitcond, label %for.cond.2.for.inc.24_crit_edge.us, label %for.body.4.us

for.cond.2.for.inc.24_crit_edge.us:               ; preds = %for.inc.us
  %cached_board.3.us.lcssa = phi i32 [ %cached_board.3.us, %for.inc.us ]
  %inc25.us = add nsw i32 %2, 1
  %cmp1.us = icmp slt i32 %inc25.us, %1
  %indvars.iv.next335 = add nsw i64 %indvars.iv334, 1
  br i1 %cmp1.us, label %for.body.4.lr.ph.us, label %for.cond.for.end.26_crit_edge.loopexit.exitStub

if.then.12.us:                                    ; preds = %for.body.4.us
  store i32 %conv.us, i32* %arrayidx9.us, align 4, !tbaa !3
  br label %for.inc.us
}

attributes #0 = { nounwind "polyjit-global-count"="2" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !1, i64 0}
