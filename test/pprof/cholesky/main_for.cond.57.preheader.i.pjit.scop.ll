
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'cholesky.dir/cholesky.c.main_for.cond.57.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.57.preheader.i.pjit.scop(double*, double*)  {
newFuncRoot:
  br label %for.cond.57.preheader.i

for.cond.92.preheader.i.preheader.exitStub:       ; preds = %for.inc.85.i
  ret void

for.cond.57.preheader.i:                          ; preds = %for.inc.85.i, %newFuncRoot
  %indvars.iv22.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next23.i, %for.inc.85.i ]
  br label %for.cond.61.preheader.i

for.cond.61.preheader.i:                          ; preds = %for.inc.82.i, %for.cond.57.preheader.i
  %indvars.iv19.i = phi i64 [ 0, %for.cond.57.preheader.i ], [ %indvars.iv.next20.i, %for.inc.82.i ]
  %2 = mul nuw nsw i64 %indvars.iv19.i, 2000
  %arrayidx67.i = getelementptr inbounds double, double* %0, i64 %2
  %arrayidx68.i = getelementptr inbounds double, double* %arrayidx67.i, i64 %indvars.iv22.i
  %arrayidx76.i = getelementptr inbounds double, double* %1, i64 %2
  br label %for.body.64.i

for.body.64.i:                                    ; preds = %for.body.64.i, %for.cond.61.preheader.i
  %indvars.iv16.i = phi i64 [ 0, %for.cond.61.preheader.i ], [ %indvars.iv.next17.i, %for.body.64.i ]
  %3 = load double, double* %arrayidx68.i, align 8, !tbaa !0
  %4 = mul nuw nsw i64 %indvars.iv16.i, 2000
  %arrayidx71.i = getelementptr inbounds double, double* %0, i64 %4
  %arrayidx72.i = getelementptr inbounds double, double* %arrayidx71.i, i64 %indvars.iv22.i
  %5 = load double, double* %arrayidx72.i, align 8, !tbaa !0
  %mul73.i = fmul double %3, %5
  %arrayidx77.i = getelementptr inbounds double, double* %arrayidx76.i, i64 %indvars.iv16.i
  %6 = load double, double* %arrayidx77.i, align 8, !tbaa !0
  %add78.i = fadd double %6, %mul73.i
  store double %add78.i, double* %arrayidx77.i, align 8, !tbaa !0
  %indvars.iv.next17.i = add nuw nsw i64 %indvars.iv16.i, 1
  %exitcond18.i = icmp eq i64 %indvars.iv.next17.i, 2000
  br i1 %exitcond18.i, label %for.inc.82.i, label %for.body.64.i

for.inc.82.i:                                     ; preds = %for.body.64.i
  %indvars.iv.next20.i = add nuw nsw i64 %indvars.iv19.i, 1
  %exitcond21.i = icmp eq i64 %indvars.iv.next20.i, 2000
  br i1 %exitcond21.i, label %for.inc.85.i, label %for.cond.61.preheader.i

for.inc.85.i:                                     ; preds = %for.inc.82.i
  %indvars.iv.next23.i = add nuw nsw i64 %indvars.iv22.i, 1
  %exitcond24.i = icmp eq i64 %indvars.iv.next23.i, 2000
  br i1 %exitcond24.i, label %for.cond.92.preheader.i.preheader.exitStub, label %for.cond.57.preheader.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
