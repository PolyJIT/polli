
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/oggenc/oggenc.c.dradbg_for.body.537.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @dradbg_for.body.537.lr.ph.pjit.scop(i32 %ido, i32 %l1, i32 %sub592, i32 %mul1, float* %wa, float* %ch, float* %c1, i32 %ip)  {
newFuncRoot:
  br label %for.body.537.lr.ph

cleanup.exitStub:                                 ; preds = %cleanup.loopexit1660, %for.body.537.lr.ph
  ret void

for.body.537.lr.ph:                               ; preds = %newFuncRoot
  %cmp541.1220 = icmp sgt i32 %ido, 2
  %cmp547.1217 = icmp sgt i32 %l1, 0
  br i1 %cmp541.1220, label %for.body.537.us.preheader, label %cleanup.exitStub

for.body.537.us.preheader:                        ; preds = %for.body.537.lr.ph
  %0 = mul i32 %l1, %ido
  %1 = add i32 %0, 2
  %2 = sext i32 %ido to i64
  %3 = sext i32 %ido to i64
  br label %for.body.537.us

for.body.537.us:                                  ; preds = %for.cond.540.for.inc.588_crit_edge.us, %for.body.537.us.preheader
  %indvars.iv1680 = phi i64 [ %indvars.iv.next1681, %for.cond.540.for.inc.588_crit_edge.us ], [ -1, %for.body.537.us.preheader ]
  %indvars.iv1674 = phi i32 [ %indvars.iv.next1675, %for.cond.540.for.inc.588_crit_edge.us ], [ %1, %for.body.537.us.preheader ]
  %j.91227.us = phi i32 [ 1, %for.body.537.us.preheader ], [ %inc589.us, %for.cond.540.for.inc.588_crit_edge.us ]
  %is.01226.us = phi i32 [ %sub592, %for.body.537.us.preheader ], [ %add538.us, %for.cond.540.for.inc.588_crit_edge.us ]
  %t1.111225.us = phi i32 [ 0, %for.body.537.us.preheader ], [ %add539.us, %for.cond.540.for.inc.588_crit_edge.us ]
  %4 = sext i32 %indvars.iv1674 to i64
  %add538.us = add nsw i32 %is.01226.us, %ido
  %add539.us = add nsw i32 %t1.111225.us, %mul1
  br i1 %cmp547.1217, label %for.body.543.us.us.preheader, label %for.cond.540.for.inc.588_crit_edge.us

for.body.543.us.us.preheader:                     ; preds = %for.body.537.us
  br label %for.body.543.us.us

for.body.543.us.us:                               ; preds = %for.cond.546.for.inc.585_crit_edge.us.us, %for.body.543.us.us.preheader
  %indvars.iv1682 = phi i64 [ %indvars.iv1680, %for.body.543.us.us.preheader ], [ %indvars.iv.next1683, %for.cond.546.for.inc.585_crit_edge.us.us ]
  %indvars.iv1676 = phi i64 [ %4, %for.body.543.us.us.preheader ], [ %indvars.iv.next1677, %for.cond.546.for.inc.585_crit_edge.us.us ]
  %idij.01223.us.us = phi i32 [ %add538.us, %for.body.543.us.us.preheader ], [ %add545.us.us, %for.cond.546.for.inc.585_crit_edge.us.us ]
  %i.61222.us.us = phi i32 [ 2, %for.body.543.us.us.preheader ], [ %add586.us.us, %for.cond.546.for.inc.585_crit_edge.us.us ]
  %t2.111221.us.us = phi i32 [ %add539.us, %for.body.543.us.us.preheader ], [ %add544.us.us, %for.cond.546.for.inc.585_crit_edge.us.us ]
  %add544.us.us = add nsw i32 %t2.111221.us.us, 2
  %add545.us.us = add nsw i32 %idij.01223.us.us, 2
  %5 = add nsw i64 %indvars.iv1682, 1
  %arrayidx552.us.us = getelementptr inbounds float, float* %wa, i64 %5
  %idxprom557.us.us = sext i32 %add545.us.us to i64
  %arrayidx558.us.us = getelementptr inbounds float, float* %wa, i64 %idxprom557.us.us
  br label %for.body.549.us.us

for.body.549.us.us:                               ; preds = %for.body.549.us.us, %for.body.543.us.us
  %indvars.iv1678 = phi i64 [ %indvars.iv.next1679, %for.body.549.us.us ], [ %indvars.iv1676, %for.body.543.us.us ]
  %k.91219.us.us = phi i32 [ %inc583.us.us, %for.body.549.us.us ], [ 0, %for.body.543.us.us ]
  %t3.81218.us.us = phi i32 [ %add581.us.us, %for.body.549.us.us ], [ %add544.us.us, %for.body.543.us.us ]
  %6 = load float, float* %arrayidx552.us.us, align 4
  %sub553.us.us = add nsw i32 %t3.81218.us.us, -1
  %idxprom554.us.us = sext i32 %sub553.us.us to i64
  %arrayidx555.us.us = getelementptr inbounds float, float* %ch, i64 %idxprom554.us.us
  %7 = load float, float* %arrayidx555.us.us, align 4
  %mul556.us.us = fmul float %6, %7
  %8 = load float, float* %arrayidx558.us.us, align 4
  %arrayidx560.us.us = getelementptr inbounds float, float* %ch, i64 %indvars.iv1678
  %9 = load float, float* %arrayidx560.us.us, align 4
  %mul561.us.us = fmul float %8, %9
  %sub562.us.us = fsub float %mul556.us.us, %mul561.us.us
  %arrayidx565.us.us = getelementptr inbounds float, float* %c1, i64 %idxprom554.us.us
  store float %sub562.us.us, float* %arrayidx565.us.us, align 4
  %10 = load float, float* %arrayidx552.us.us, align 4
  %11 = load float, float* %arrayidx560.us.us, align 4
  %mul571.us.us = fmul float %10, %11
  %12 = load float, float* %arrayidx558.us.us, align 4
  %13 = load float, float* %arrayidx555.us.us, align 4
  %mul577.us.us = fmul float %12, %13
  %add578.us.us = fadd float %mul571.us.us, %mul577.us.us
  %arrayidx580.us.us = getelementptr inbounds float, float* %c1, i64 %indvars.iv1678
  store float %add578.us.us, float* %arrayidx580.us.us, align 4
  %add581.us.us = add nsw i32 %t3.81218.us.us, %ido
  %inc583.us.us = add nuw nsw i32 %k.91219.us.us, 1
  %indvars.iv.next1679 = add i64 %indvars.iv1678, %2
  %exitcond1463 = icmp eq i32 %inc583.us.us, %l1
  br i1 %exitcond1463, label %for.cond.546.for.inc.585_crit_edge.us.us, label %for.body.549.us.us

for.cond.546.for.inc.585_crit_edge.us.us:         ; preds = %for.body.549.us.us
  %add586.us.us = add nuw nsw i32 %i.61222.us.us, 2
  %cmp541.us.us = icmp slt i32 %add586.us.us, %ido
  %indvars.iv.next1677 = add nsw i64 %indvars.iv1676, 2
  %indvars.iv.next1683 = add nsw i64 %indvars.iv1682, 2
  br i1 %cmp541.us.us, label %for.body.543.us.us, label %for.cond.540.for.inc.588_crit_edge.us.loopexit

for.cond.540.for.inc.588_crit_edge.us.loopexit:   ; preds = %for.cond.546.for.inc.585_crit_edge.us.us
  br label %for.cond.540.for.inc.588_crit_edge.us

for.cond.540.for.inc.588_crit_edge.us:            ; preds = %for.cond.540.for.inc.588_crit_edge.us.loopexit, %for.body.537.us
  %inc589.us = add nuw nsw i32 %j.91227.us, 1
  %indvars.iv.next1675 = add i32 %indvars.iv1674, %0
  %indvars.iv.next1681 = add i64 %indvars.iv1680, %3
  %exitcond1469 = icmp eq i32 %inc589.us, %ip
  br i1 %exitcond1469, label %cleanup.loopexit1660, label %for.body.537.us

cleanup.loopexit1660:                             ; preds = %for.cond.540.for.inc.588_crit_edge.us
  br label %cleanup.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }
