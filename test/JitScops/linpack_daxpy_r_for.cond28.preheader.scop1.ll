; RUN: opt -S -load LLVMPolyJIT.so -polly-use-runtime-alias-checks=false -polli-detect -jitable -polly-detect-keep-going -analyze < %s 2>&1 | FileCheck %s

;CHECK: 1 regions require runtime support:
;CHECK:   0 region for.cond28.preheader => for.end41.loopexit requires 0 params
;CHECK:     2 reasons can be fixed at run time:
;CHECK:       0 - Possible aliasing: "dy", "dx"
;CHECK:       1 - Possible aliasing: "dy", "dx"

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @daxpy_r_for.cond28.preheader.scop1(i32 %n, double* %dy, double* %dx, double %da) {
newFuncRoot:
  br label %for.cond28.preheader

for.end41.exitStub:                               ; preds = %for.end41.loopexit
  ret void

for.cond28.preheader:                             ; preds = %newFuncRoot
  %cmp293 = icmp sgt i32 %n, 0
  br i1 %cmp293, label %for.body30.lr.ph, label %for.end41.loopexit

for.body30.lr.ph:                                 ; preds = %for.cond28.preheader
  br label %for.body30

for.body30:                                       ; preds = %for.body30, %for.body30.lr.ph
  %indvar = phi i64 [ 0, %for.body30.lr.ph ], [ %indvar.next, %for.body30 ]
  %.moved.to.for.body30 = zext i32 %n to i64
  %arrayidx38 = getelementptr double, double* %dy, i64 %indvar
  %arrayidx34 = getelementptr double, double* %dx, i64 %indvar
  %0 = load double, double* %arrayidx38, align 8
  %1 = load double, double* %arrayidx34, align 8
  %mul35 = fmul double %1, %da
  %add36 = fadd double %0, %mul35
  store double %add36, double* %arrayidx38, align 8
  %indvar.next = add i64 %indvar, 1
  %exitcond = icmp ne i64 %indvar.next, %.moved.to.for.body30
  br i1 %exitcond, label %for.body30, label %for.cond28.for.end41.loopexit_crit_edge

for.cond28.for.end41.loopexit_crit_edge:          ; preds = %for.body30
  br label %for.end41.loopexit

for.end41.loopexit:                               ; preds = %for.cond28.for.end41.loopexit_crit_edge, %for.cond28.preheader
  br label %for.end41.exitStub
}
