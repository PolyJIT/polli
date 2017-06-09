; RUN: opt -S -load LLVMPolyJIT.so -polli-process-unprofitable -polli-detect-scops -jitable -analyze < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:
; CHECK:   0 region for.inc => for.cond.return.loopexit1_crit_edge.exitStub requires 2 params
; CHECK:     0 - (8 * %0)
; CHECK:     0 - %1

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @ddot_r_for.inc.scop0(double* %dtemp.06.reg2mem, i64, i64, double* %dy, i64, i64, double* %dx, i64) {
newFuncRoot:
  br label %for.inc

for.cond.return.loopexit1_crit_edge.exitStub:     ; preds = %for.inc
  ret void

for.inc:                                          ; preds = %for.inc, %newFuncRoot
  %indvar11 = phi i64 [ 0, %newFuncRoot ], [ %indvar.next12, %for.inc ]
  %dtemp.06.reload = load double, double* %dtemp.06.reg2mem
  %5 = mul i64 %0, %indvar11
  %6 = add i64 %1, %5
  %arrayidx15 = getelementptr double, double* %dy, i64 %6
  %7 = mul i64 %2, %indvar11
  %8 = add i64 %3, %7
  %arrayidx = getelementptr double, double* %dx, i64 %8
  %9 = load double, double* %arrayidx, align 8
  %10 = load double, double* %arrayidx15, align 8
  %mul16 = fmul double %9, %10
  %add17 = fadd double %dtemp.06.reload, %mul16
  %indvar.next12 = add i64 %indvar11, 1
  %exitcond13 = icmp ne i64 %indvar.next12, %4
  store double %add17, double* %dtemp.06.reg2mem
  br i1 %exitcond13, label %for.inc, label %for.cond.return.loopexit1_crit_edge.exitStub
}
