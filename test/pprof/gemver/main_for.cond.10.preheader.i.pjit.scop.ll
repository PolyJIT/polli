
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'gemver.dir/gemver.c.main_for.cond.10.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.10.preheader.i.pjit.scop(double*, double*, double*, double*, double*)  {
newFuncRoot:
  br label %for.cond.10.preheader.i

for.cond.36.preheader.i.preheader.exitStub:       ; preds = %for.inc.30.i
  ret void

for.cond.10.preheader.i:                          ; preds = %for.inc.30.i, %newFuncRoot
  %indvars.iv23.i = phi i64 [ %indvars.iv.next24.i, %for.inc.30.i ], [ 0, %newFuncRoot ]
  %5 = mul nuw nsw i64 %indvars.iv23.i, 2000
  %arrayidx.i.175 = getelementptr inbounds double, double* %0, i64 %5
  %arrayidx16.i.176 = getelementptr inbounds double, double* %1, i64 %indvars.iv23.i
  %arrayidx21.i = getelementptr inbounds double, double* %2, i64 %indvars.iv23.i
  br label %for.body.12.i

for.body.12.i:                                    ; preds = %for.body.12.i, %for.cond.10.preheader.i
  %indvars.iv20.i = phi i64 [ 0, %for.cond.10.preheader.i ], [ %indvars.iv.next21.i, %for.body.12.i ]
  %arrayidx14.i = getelementptr inbounds double, double* %arrayidx.i.175, i64 %indvars.iv20.i
  %6 = load double, double* %arrayidx14.i, align 8, !tbaa !0
  %7 = load double, double* %arrayidx16.i.176, align 8, !tbaa !0
  %arrayidx18.i = getelementptr inbounds double, double* %3, i64 %indvars.iv20.i
  %8 = load double, double* %arrayidx18.i, align 8, !tbaa !0
  %mul.i = fmul double %7, %8
  %add19.i = fadd double %6, %mul.i
  %9 = load double, double* %arrayidx21.i, align 8, !tbaa !0
  %arrayidx23.i = getelementptr inbounds double, double* %4, i64 %indvars.iv20.i
  %10 = load double, double* %arrayidx23.i, align 8, !tbaa !0
  %mul24.i = fmul double %9, %10
  %add25.i = fadd double %add19.i, %mul24.i
  store double %add25.i, double* %arrayidx14.i, align 8, !tbaa !0
  %indvars.iv.next21.i = add nuw nsw i64 %indvars.iv20.i, 1
  %exitcond22.i = icmp eq i64 %indvars.iv.next21.i, 2000
  br i1 %exitcond22.i, label %for.inc.30.i, label %for.body.12.i

for.inc.30.i:                                     ; preds = %for.body.12.i
  %indvars.iv.next24.i = add nuw nsw i64 %indvars.iv23.i, 1
  %exitcond25.i = icmp eq i64 %indvars.iv.next24.i, 2000
  br i1 %exitcond25.i, label %for.cond.36.preheader.i.preheader.exitStub, label %for.cond.10.preheader.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
