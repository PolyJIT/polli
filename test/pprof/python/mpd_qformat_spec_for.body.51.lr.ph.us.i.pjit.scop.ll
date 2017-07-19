
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/python/Python-3.4.3/Modules/_decimal/libmpdec/io.c.mpd_qformat_spec_for.body.51.lr.ph.us.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.mpd_spec_t = type { i64, i64, i8, i8, i8, [5 x i8], i8*, i8*, i8* }

; Function Attrs: nounwind
define weak void @mpd_qformat_spec_for.body.51.lr.ph.us.i.pjit.scop(i64 %call.i.247, %struct.mpd_spec_t* %spec.addr.1, i8* %cp.0.i, i64 %lpad.0165.i)  {
newFuncRoot:
  br label %for.body.51.lr.ph.us.i

for.end.58.i.loopexit.exitStub:                   ; preds = %for.cond.48.for.inc.56_crit_edge.us.i
  ret void

for.body.51.lr.ph.us.i:                           ; preds = %for.cond.48.for.inc.56_crit_edge.us.i, %newFuncRoot
  %i.0175.us.i = phi i64 [ %inc57.us.i, %for.cond.48.for.inc.56_crit_edge.us.i ], [ 0, %newFuncRoot ]
  %mul53.us.i = mul i64 %i.0175.us.i, %call.i.247
  br label %for.body.51.us.i

for.body.51.us.i:                                 ; preds = %for.body.51.us.i, %for.body.51.lr.ph.us.i
  %j.0173.us.i = phi i64 [ 0, %for.body.51.lr.ph.us.i ], [ %inc.us.i, %for.body.51.us.i ]
  %arrayidx.us.i = getelementptr %struct.mpd_spec_t, %struct.mpd_spec_t* %spec.addr.1, i64 0, i32 5, i64 %j.0173.us.i
  %0 = load i8, i8* %arrayidx.us.i, align 1, !tbaa !0
  %add54.us.i = add i64 %j.0173.us.i, %mul53.us.i
  %arrayidx55.us.i = getelementptr i8, i8* %cp.0.i, i64 %add54.us.i
  store i8 %0, i8* %arrayidx55.us.i, align 1, !tbaa !0
  %inc.us.i = add nuw i64 %j.0173.us.i, 1
  %exitcond182.i = icmp eq i64 %inc.us.i, %call.i.247
  br i1 %exitcond182.i, label %for.cond.48.for.inc.56_crit_edge.us.i, label %for.body.51.us.i

for.cond.48.for.inc.56_crit_edge.us.i:            ; preds = %for.body.51.us.i
  %inc57.us.i = add nuw i64 %i.0175.us.i, 1
  %exitcond183.i = icmp eq i64 %inc57.us.i, %lpad.0165.i
  br i1 %exitcond183.i, label %for.end.58.i.loopexit.exitStub, label %for.body.51.lr.ph.us.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
