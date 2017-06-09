; RUN: opt -S -load LLVMPolyJIT.so -polli-process-unprofitable -polli-detect-scops -jitable -analyze < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:
; CHECK:   0 region for.body => for.cond.for.end94.loopexit2_crit_edge.exitStub requires 2 params
; CHECK:     0 - (8 * %0)
; CHECK:     0 - %1

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @daxpy_ur_for.body.scop1(i64, i64, double* %dy, i64, i64, double* %dx, double %da, i64) {
newFuncRoot:
  br label %for.body

for.cond.for.end94.loopexit2_crit_edge.exitStub:  ; preds = %for.body
  ret void

for.body:                                         ; preds = %for.body, %newFuncRoot
  %indvar13 = phi i64 [ 0, %newFuncRoot ], [ %indvar.next14, %for.body ]
  %5 = mul i64 %0, %indvar13
  %6 = add i64 %1, %5
  %arrayidx24 = getelementptr double, double* %dy, i64 %6
  %7 = mul i64 %2, %indvar13
  %8 = add i64 %3, %7
  %arrayidx20 = getelementptr double, double* %dx, i64 %8
  %9 = load double, double* %arrayidx24, align 8
  %10 = load double, double* %arrayidx20, align 8
  %mul21 = fmul double %10, %da
  %add22 = fadd double %9, %mul21
  store double %add22, double* %arrayidx24, align 8
  %indvar.next14 = add i64 %indvar13, 1
  %exitcond15 = icmp ne i64 %indvar.next14, %4
  br i1 %exitcond15, label %for.body, label %for.cond.for.end94.loopexit2_crit_edge.exitStub
}
