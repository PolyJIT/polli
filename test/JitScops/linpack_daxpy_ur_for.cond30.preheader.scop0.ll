; RUN: opt -S -load LLVMPolyJIT.so -polly-detect-unprofitable -polly-use-runtime-alias-checks=false -polli-detect -jitable -polly-detect-keep-going -analyze < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:
; CHECK:   0 region for.cond30.preheader => for.end43.exitStub requires 0 params
; CHECK:     2 reasons can be fixed at run time:
; CHECK:       0 - Possible aliasing: "dy", "dx"
; CHECK:       1 - Possible aliasing: "dy", "dx"

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @daxpy_ur_for.cond30.preheader.scop0(i32 %rem, double* %dy, double* %dx, double %da) {
newFuncRoot:
  br label %for.cond30.preheader

for.end43.exitStub:                               ; preds = %for.cond30.for.end43_crit_edge, %for.cond30.preheader
  ret void

for.cond30.preheader:                             ; preds = %newFuncRoot
  %cmp315 = icmp sgt i32 %rem, 0
  br i1 %cmp315, label %for.body32.lr.ph, label %for.end43.exitStub

for.body32.lr.ph:                                 ; preds = %for.cond30.preheader
  br label %for.body32

for.body32:                                       ; preds = %for.body32, %for.body32.lr.ph
  %indvar11 = phi i64 [ 0, %for.body32.lr.ph ], [ %indvar.next12, %for.body32 ]
  %.moved.to.for.body32 = zext i32 %rem to i64
  %arrayidx40 = getelementptr double, double* %dy, i64 %indvar11
  %arrayidx36 = getelementptr double, double* %dx, i64 %indvar11
  %0 = load double, double* %arrayidx40, align 8
  %1 = load double, double* %arrayidx36, align 8
  %mul37 = fmul double %1, %da
  %add38 = fadd double %0, %mul37
  store double %add38, double* %arrayidx40, align 8
  %indvar.next12 = add i64 %indvar11, 1
  %exitcond = icmp ne i64 %indvar.next12, %.moved.to.for.body32
  br i1 %exitcond, label %for.body32, label %for.cond30.for.end43_crit_edge

for.cond30.for.end43_crit_edge:                   ; preds = %for.body32
  br label %for.end43.exitStub
}
