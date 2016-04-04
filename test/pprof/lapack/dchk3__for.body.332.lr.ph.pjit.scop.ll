
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'dblat3.c.dchk3__for.body.332.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @dchk3__for.body.332.lr.ph.pjit.scop(i64, i64, double* %incdec.ptr5, double* %add.ptr, double* %add.ptr8, double, i64, i64)  {
newFuncRoot:
  br label %for.body.332.lr.ph

for.cond.325.for.end.353_crit_edge.loopexit.exitStub: ; preds = %for.inc.351
  ret void

for.body.332.lr.ph:                               ; preds = %for.inc.351, %newFuncRoot
  %j.1648 = phi i64 [ %inc352, %for.inc.351 ], [ 1, %newFuncRoot ]
  %sub333 = add nsw i64 %j.1648, -1
  %mul334 = mul nsw i64 %sub333, %0
  %mul337 = mul nsw i64 %j.1648, %1
  %mul345 = mul nsw i64 %sub333, %0
  br label %for.body.332

for.body.332:                                     ; preds = %for.body.332, %for.body.332.lr.ph
  %inc349669 = phi i64 [ 1, %for.body.332.lr.ph ], [ %inc349, %for.body.332 ]
  %add335 = add nsw i64 %inc349669, %mul334
  %arrayidx336 = getelementptr inbounds double, double* %incdec.ptr5, i64 %add335
  %5 = bitcast double* %arrayidx336 to i64*
  %6 = load i64, i64* %5, align 8, !tbaa !0
  %add338 = add nsw i64 %inc349669, %mul337
  %arrayidx339 = getelementptr inbounds double, double* %add.ptr, i64 %add338
  %7 = bitcast double* %arrayidx339 to i64*
  store i64 %6, i64* %7, align 8, !tbaa !0
  %add341 = add nsw i64 %inc349669, %mul337
  %arrayidx342 = getelementptr inbounds double, double* %add.ptr8, i64 %add341
  %8 = load double, double* %arrayidx342, align 8, !tbaa !0
  %mul343 = fmul double %2, %8
  %add346 = add nsw i64 %inc349669, %mul345
  %arrayidx347 = getelementptr inbounds double, double* %incdec.ptr5, i64 %add346
  store double %mul343, double* %arrayidx347, align 8, !tbaa !0
  %inc349 = add nuw nsw i64 %inc349669, 1
  %exitcond = icmp eq i64 %inc349, %3
  br i1 %exitcond, label %for.inc.351, label %for.body.332

for.inc.351:                                      ; preds = %for.body.332
  %inc352 = add nuw nsw i64 %j.1648, 1
  %exitcond678 = icmp eq i64 %j.1648, %4
  br i1 %exitcond678, label %for.cond.325.for.end.353_crit_edge.loopexit.exitStub, label %for.body.332.lr.ph
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
