
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = './enc/unicode.c.onigenc_unicode_get_case_fold_codes_by_str_for.body.165.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.OnigCaseFoldCodeItem = type { i32, i32, [3 x i32] }

; Function Attrs: nounwind
define weak void @onigenc_unicode_get_case_fold_codes_by_str_for.body.165.lr.ph.us.us.pjit.scop(i32 %n.7846.us, i32* %arrayidx174.us, [3 x [4 x i32]]* %cs, %struct.OnigCaseFoldCodeItem* %items, i32 %cond, i32, i32)  {
newFuncRoot:
  br label %for.body.165.lr.ph.us.us

for.cond.158.for.inc.200_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.162.for.inc.197_crit_edge.us.us
  ret void

for.body.165.lr.ph.us.us:                         ; preds = %for.cond.162.for.inc.197_crit_edge.us.us, %newFuncRoot
  %indvars.iv904 = phi i64 [ %indvars.iv.next905, %for.cond.162.for.inc.197_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %n.8842.us.us = phi i32 [ %5, %for.cond.162.for.inc.197_crit_edge.us.us ], [ %n.7846.us, %newFuncRoot ]
  %2 = load i32, i32* %arrayidx174.us, align 4, !tbaa !0
  %arrayidx181.us.us = getelementptr [3 x [4 x i32]], [3 x [4 x i32]]* %cs, i64 0, i64 1, i64 %indvars.iv904
  %3 = load i32, i32* %arrayidx181.us.us, align 4, !tbaa !0
  br label %for.body.165.us.us

for.body.165.us.us:                               ; preds = %for.body.165.us.us, %for.body.165.lr.ph.us.us
  %indvars.iv900 = phi i64 [ %indvars.iv.next901, %for.body.165.us.us ], [ 0, %for.body.165.lr.ph.us.us ]
  %n.9838.us.us = phi i32 [ %inc193.us.us, %for.body.165.us.us ], [ %n.8842.us.us, %for.body.165.lr.ph.us.us ]
  %idxprom166.us.us = sext i32 %n.9838.us.us to i64
  %byte_len168.us.us = getelementptr inbounds %struct.OnigCaseFoldCodeItem, %struct.OnigCaseFoldCodeItem* %items, i64 %idxprom166.us.us, i32 0
  store i32 %cond, i32* %byte_len168.us.us, align 4, !tbaa !4
  %code_len171.us.us = getelementptr inbounds %struct.OnigCaseFoldCodeItem, %struct.OnigCaseFoldCodeItem* %items, i64 %idxprom166.us.us, i32 1
  store i32 3, i32* %code_len171.us.us, align 4, !tbaa !6
  %arrayidx178.us.us = getelementptr %struct.OnigCaseFoldCodeItem, %struct.OnigCaseFoldCodeItem* %items, i64 %idxprom166.us.us, i32 2, i64 0
  store i32 %2, i32* %arrayidx178.us.us, align 4, !tbaa !0
  %arrayidx185.us.us = getelementptr %struct.OnigCaseFoldCodeItem, %struct.OnigCaseFoldCodeItem* %items, i64 %idxprom166.us.us, i32 2, i64 1
  store i32 %3, i32* %arrayidx185.us.us, align 4, !tbaa !0
  %arrayidx188.us.us = getelementptr [3 x [4 x i32]], [3 x [4 x i32]]* %cs, i64 0, i64 2, i64 %indvars.iv900
  %4 = load i32, i32* %arrayidx188.us.us, align 4, !tbaa !0
  %arrayidx192.us.us = getelementptr %struct.OnigCaseFoldCodeItem, %struct.OnigCaseFoldCodeItem* %items, i64 %idxprom166.us.us, i32 2, i64 2
  store i32 %4, i32* %arrayidx192.us.us, align 4, !tbaa !0
  %inc193.us.us = add i32 %n.9838.us.us, 1
  %indvars.iv.next901 = add nuw nsw i64 %indvars.iv900, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next901 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %0
  br i1 %exitcond, label %for.cond.162.for.inc.197_crit_edge.us.us, label %for.body.165.us.us

for.cond.162.for.inc.197_crit_edge.us.us:         ; preds = %for.body.165.us.us
  %5 = add i32 %n.8842.us.us, %0
  %indvars.iv.next905 = add nuw nsw i64 %indvars.iv904, 1
  %lftr.wideiv926 = trunc i64 %indvars.iv.next905 to i32
  %exitcond927 = icmp eq i32 %lftr.wideiv926, %1
  br i1 %exitcond927, label %for.cond.158.for.inc.200_crit_edge.us.loopexit.exitStub, label %for.body.165.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !1, i64 0}
!5 = !{!"", !1, i64 0, !1, i64 4, !2, i64 8}
!6 = !{!5, !1, i64 4}
