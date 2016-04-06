; RUN: opt -S -load LLVMPolyJIT.so -polli-process-unprofitable -polly-use-runtime-alias-checks=false -polli-detect-scops -jitable -analyze < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @ddot_r_for.cond21.preheader.scop1(i32 %n, double* %dtemp.1.lcssa.reg2mem, double* %dtemp.13.reg2mem, double* %dx, double* %dy, double* %retval.0.reg2mem) {
newFuncRoot:
  br label %for.cond21.preheader

return.exitStub:                                  ; preds = %return.loopexit
  ret void

for.cond21.preheader:                             ; preds = %newFuncRoot
  %cmp222 = icmp sgt i32 %n, 0
  store double 0.000000e+00, double* %dtemp.1.lcssa.reg2mem
  br i1 %cmp222, label %for.inc30.lr.ph, label %return.loopexit

for.inc30.lr.ph:                                  ; preds = %for.cond21.preheader
  store double 0.000000e+00, double* %dtemp.13.reg2mem
  br label %for.inc30

for.inc30:                                        ; preds = %for.inc30, %for.inc30.lr.ph
  %indvar = phi i64 [ 0, %for.inc30.lr.ph ], [ %indvar.next, %for.inc30 ]
  %.moved.to.for.inc30 = zext i32 %n to i64
  %dtemp.13.reload = load double, double* %dtemp.13.reg2mem
  %arrayidx25 = getelementptr double, double* %dx, i64 %indvar
  %arrayidx27 = getelementptr double, double* %dy, i64 %indvar
  %0 = load double, double* %arrayidx25, align 8
  %1 = load double, double* %arrayidx27, align 8
  %mul28 = fmul double %0, %1
  %add29 = fadd double %dtemp.13.reload, %mul28
  %indvar.next = add i64 %indvar, 1
  %exitcond = icmp ne i64 %indvar.next, %.moved.to.for.inc30
  store double %add29, double* %dtemp.13.reg2mem
  br i1 %exitcond, label %for.inc30, label %for.cond21.return.loopexit_crit_edge

for.cond21.return.loopexit_crit_edge:             ; preds = %for.inc30
  %2 = load double, double* %dtemp.13.reg2mem
  store double %2, double* %dtemp.1.lcssa.reg2mem
  br label %return.loopexit

return.loopexit:                                  ; preds = %for.cond21.return.loopexit_crit_edge, %for.cond21.preheader
  %dtemp.1.lcssa.reload = load double, double* %dtemp.1.lcssa.reg2mem
  store double %dtemp.1.lcssa.reload, double* %retval.0.reg2mem
  br label %return.exitStub
}
