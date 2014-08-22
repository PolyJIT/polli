; RUN: polli -polli-analyze -jitable -polly-detect-keep-going %s 2>&1 | FileCheck %s

; CHECK: OK :: Possible aliasing: "dtemp.1.lcssa.reg2mem", "dtemp.16.reg2mem"
; CHECK: OK :: Possible aliasing: "dtemp.1.lcssa.reg2mem", "dtemp.16.reg2mem"
; CHECK: OK :: Possible aliasing: "dtemp.1.lcssa.reg2mem", "dtemp.16.reg2mem", "dx"
; CHECK: OK :: Possible aliasing: "dtemp.1.lcssa.reg2mem", "dtemp.16.reg2mem", "dx", "dy"
; CHECK: OK :: Possible aliasing: "dtemp.1.lcssa.reg2mem", "dtemp.16.reg2mem", "dx", "dy"
; CHECK: OK :: Possible aliasing: "dtemp.1.lcssa.reg2mem", "dtemp.16.reg2mem", "dx", "dy"
; CHECK: OK :: Possible aliasing: "dtemp.1.lcssa.reg2mem", "dtemp.16.reg2mem", "dx", "dy"

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @ddot_ur_for.cond23.preheader.scop0(i32 %rem, double* %dtemp.1.lcssa.reg2mem, double* %dtemp.16.reg2mem, double* %dx, double* %dy) {
newFuncRoot:
  br label %for.cond23.preheader

for.end34.exitStub:                               ; preds = %for.cond23.for.end34_crit_edge, %for.cond23.preheader
  ret void

for.cond23.preheader:                             ; preds = %newFuncRoot
  %cmp245 = icmp sgt i32 %rem, 0
  store double 0.000000e+00, double* %dtemp.1.lcssa.reg2mem
  br i1 %cmp245, label %for.inc32.lr.ph, label %for.end34.exitStub

for.inc32.lr.ph:                                  ; preds = %for.cond23.preheader
  store double 0.000000e+00, double* %dtemp.16.reg2mem
  br label %for.inc32

for.inc32:                                        ; preds = %for.inc32, %for.inc32.lr.ph
  %indvar15 = phi i64 [ 0, %for.inc32.lr.ph ], [ %indvar.next16, %for.inc32 ]
  %.moved.to.for.inc32 = zext i32 %rem to i64
  %dtemp.16.reload = load double* %dtemp.16.reg2mem
  %arrayidx27 = getelementptr double* %dx, i64 %indvar15
  %arrayidx29 = getelementptr double* %dy, i64 %indvar15
  %0 = load double* %arrayidx27, align 8
  %1 = load double* %arrayidx29, align 8
  %mul30 = fmul double %0, %1
  %add31 = fadd double %dtemp.16.reload, %mul30
  %indvar.next16 = add i64 %indvar15, 1
  %exitcond = icmp ne i64 %indvar.next16, %.moved.to.for.inc32
  store double %add31, double* %dtemp.16.reg2mem
  br i1 %exitcond, label %for.inc32, label %for.cond23.for.end34_crit_edge

for.cond23.for.end34_crit_edge:                   ; preds = %for.inc32
  %2 = load double* %dtemp.16.reg2mem
  store double %2, double* %dtemp.1.lcssa.reg2mem
  br label %for.end34.exitStub
}
