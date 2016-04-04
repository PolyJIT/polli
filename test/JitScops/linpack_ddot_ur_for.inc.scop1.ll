; RUN: opt -S -load LLVMPolyJIT.so -polli-process-unprofitable -polly-delinearize=false -polli-detect -jitable -polly-detect-keep-going -analyze < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:
; CHECK:   0 region for.inc => for.cond.return.loopexit1_crit_edge.exitStub requires 4 params
; CHECK:     0 - (8 * %2)
; CHECK:     0 - %3
; CHECK:     0 - (8 * %0)
; CHECK:     0 - %1
; CHECK:     2 reasons can be fixed at run time:
; CHECK:       0 - Non affine access function: {(8 * %3),+,(8 * %2)}<%for.inc>
; CHECK:       1 - Non affine access function: {(8 * %1),+,(8 * %0)}<%for.inc>

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @ddot_ur_for.inc.scop1(double* %dtemp.010.reg2mem, i64, i64, double* %dy, i64, i64, double* %dx, i64) {
newFuncRoot:
  br label %for.inc

for.cond.return.loopexit1_crit_edge.exitStub:     ; preds = %for.inc
  ret void

for.inc:                                          ; preds = %for.inc, %newFuncRoot
  %indvar17 = phi i64 [ 0, %newFuncRoot ], [ %indvar.next18, %for.inc ]
  %dtemp.010.reload = load double, double* %dtemp.010.reg2mem
  %5 = mul i64 %0, %indvar17
  %6 = add i64 %1, %5
  %arrayidx15 = getelementptr double, double* %dy, i64 %6
  %7 = mul i64 %2, %indvar17
  %8 = add i64 %3, %7
  %arrayidx = getelementptr double, double* %dx, i64 %8
  %9 = load double, double* %arrayidx, align 8
  %10 = load double, double* %arrayidx15, align 8
  %mul16 = fmul double %9, %10
  %add17 = fadd double %dtemp.010.reload, %mul16
  %indvar.next18 = add i64 %indvar17, 1
  %exitcond19 = icmp ne i64 %indvar.next18, %4
  store double %add17, double* %dtemp.010.reg2mem
  br i1 %exitcond19, label %for.inc, label %for.cond.return.loopexit1_crit_edge.exitStub
}
