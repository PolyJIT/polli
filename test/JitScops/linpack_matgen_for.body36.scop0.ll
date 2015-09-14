; RUN: opt -S -load LLVMPolyJIT.so -polly-detect-unprofitable -polly-use-runtime-alias-checks=false -polli-detect -jitable -polly-detect-keep-going -analyze < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:
; CHECK:   0 region for.body36 => for.cond33.for.inc49_crit_edge requires 0 params
; CHECK:     2 reasons can be fixed at run time:
; CHECK:       0 - Possible aliasing: "b", "a"
; CHECK:       1 - Possible aliasing: "b", "a"

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @matgen_for.body36.scop0(i64, double* %b, double* %a, i64) {
newFuncRoot:
  br label %for.body36

for.inc49.exitStub:                               ; preds = %for.cond33.for.inc49_crit_edge
  ret void

for.body36:                                       ; preds = %for.body36, %newFuncRoot
  %indvar = phi i64 [ 0, %newFuncRoot ], [ %indvar.next, %for.body36 ]
  %2 = add i64 %0, %indvar
  %add40 = trunc i64 %2 to i32
  %arrayidx45 = getelementptr double, double* %b, i64 %indvar
  %3 = load double, double* %arrayidx45, align 8
  %idxprom41 = sext i32 %add40 to i64
  %arrayidx42 = getelementptr inbounds double, double* %a, i64 %idxprom41
  %4 = load double, double* %arrayidx42, align 8
  %add43 = fadd double %3, %4
  store double %add43, double* %arrayidx45, align 8
  %indvar.next = add i64 %indvar, 1
  %exitcond = icmp ne i64 %indvar.next, %1
  br i1 %exitcond, label %for.body36, label %for.cond33.for.inc49_crit_edge

for.cond33.for.inc49_crit_edge:                   ; preds = %for.body36
  br label %for.inc49.exitStub
}
