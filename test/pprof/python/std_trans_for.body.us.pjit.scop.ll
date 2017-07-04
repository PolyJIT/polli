
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/python/Python-3.4.3/Modules/_decimal/libmpdec/transpose.c.std_trans_for.body.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @std_trans_for.body.us.pjit.scop(i64 %cols, i64* %src, i64* %dest, i64 %rows)  {
newFuncRoot:
  br label %for.body.us

for.end.8.loopexit.exitStub:                      ; preds = %for.cond.1.for.inc.6_crit_edge.us
  ret void

for.body.us:                                      ; preds = %for.cond.1.for.inc.6_crit_edge.us, %newFuncRoot
  %r.026.us = phi i64 [ %inc7.us, %for.cond.1.for.inc.6_crit_edge.us ], [ 0, %newFuncRoot ]
  %mul.us = mul i64 %r.026.us, %cols
  br label %for.body.3.us

for.body.3.us:                                    ; preds = %for.body.3.us, %for.body.us
  %c.024.us = phi i64 [ 0, %for.body.us ], [ %inc.us, %for.body.3.us ]
  %isrc.023.us = phi i64 [ %mul.us, %for.body.us ], [ %add.us, %for.body.3.us ]
  %idest.022.us = phi i64 [ %r.026.us, %for.body.us ], [ %add5.us, %for.body.3.us ]
  %arrayidx.us = getelementptr i64, i64* %src, i64 %isrc.023.us
  %0 = load i64, i64* %arrayidx.us, align 8, !tbaa !0
  %arrayidx4.us = getelementptr i64, i64* %dest, i64 %idest.022.us
  store i64 %0, i64* %arrayidx4.us, align 8, !tbaa !0
  %add.us = add i64 %isrc.023.us, 1
  %add5.us = add i64 %idest.022.us, %rows
  %inc.us = add nuw i64 %c.024.us, 1
  %exitcond28 = icmp eq i64 %inc.us, %cols
  br i1 %exitcond28, label %for.cond.1.for.inc.6_crit_edge.us, label %for.body.3.us

for.cond.1.for.inc.6_crit_edge.us:                ; preds = %for.body.3.us
  %inc7.us = add nuw i64 %r.026.us, 1
  %exitcond29 = icmp eq i64 %inc7.us, %rows
  br i1 %exitcond29, label %for.end.8.loopexit.exitStub, label %for.body.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"long", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
