
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli-process-unprofitable -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/447.dealII/src/tensor.cc._ZN6TensorILi4ELi3EEdVERKd_for.body.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.Tensor.10 = type { [3 x %class.Tensor.7] }
%class.Tensor.7 = type { [3 x %class.Tensor.4] }
%class.Tensor.4 = type { [3 x %class.Tensor.1] }
%class.Tensor.1 = type { [3 x double] }

; Function Attrs: nounwind
define weak void @_ZN6TensorILi4ELi3EEdVERKd_for.body.pjit.scop(double* %s, %class.Tensor.10* %this)  {
newFuncRoot:
  br label %for.body

for.cond.cleanup.exitStub:                        ; preds = %_ZN6TensorILi3ELi3EEdVERKd.exit
  ret void

for.body:                                         ; preds = %_ZN6TensorILi3ELi3EEdVERKd.exit, %newFuncRoot
  %indvars.iv = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next, %_ZN6TensorILi3ELi3EEdVERKd.exit ]
  br label %for.body.i

for.body.i:                                       ; preds = %for.body.i, %for.body
  %indvars.iv.i = phi i64 [ 0, %for.body ], [ %indvars.iv.next.i, %for.body.i ]
  %0 = load double, double* %s, align 8, !tbaa !0
  %arrayidx.i.i.i = getelementptr inbounds %class.Tensor.10, %class.Tensor.10* %this, i64 0, i32 0, i64 %indvars.iv, i32 0, i64 %indvars.iv.i, i32 0, i64 0, i32 0, i64 0
  %1 = load double, double* %arrayidx.i.i.i, align 8, !tbaa !0
  %div.i.i.i = fdiv double %1, %0
  store double %div.i.i.i, double* %arrayidx.i.i.i, align 8, !tbaa !0
  %2 = load double, double* %s, align 8, !tbaa !0
  %arrayidx.1.i.i.i = getelementptr inbounds %class.Tensor.10, %class.Tensor.10* %this, i64 0, i32 0, i64 %indvars.iv, i32 0, i64 %indvars.iv.i, i32 0, i64 0, i32 0, i64 1
  %3 = load double, double* %arrayidx.1.i.i.i, align 8, !tbaa !0
  %div.1.i.i.i = fdiv double %3, %2
  store double %div.1.i.i.i, double* %arrayidx.1.i.i.i, align 8, !tbaa !0
  %4 = load double, double* %s, align 8, !tbaa !0
  %arrayidx.2.i.i.i = getelementptr inbounds %class.Tensor.10, %class.Tensor.10* %this, i64 0, i32 0, i64 %indvars.iv, i32 0, i64 %indvars.iv.i, i32 0, i64 0, i32 0, i64 2
  %5 = load double, double* %arrayidx.2.i.i.i, align 8, !tbaa !0
  %div.2.i.i.i = fdiv double %5, %4
  store double %div.2.i.i.i, double* %arrayidx.2.i.i.i, align 8, !tbaa !0
  %6 = load double, double* %s, align 8, !tbaa !0
  %arrayidx.i.1.i.i = getelementptr inbounds %class.Tensor.10, %class.Tensor.10* %this, i64 0, i32 0, i64 %indvars.iv, i32 0, i64 %indvars.iv.i, i32 0, i64 1, i32 0, i64 0
  %7 = load double, double* %arrayidx.i.1.i.i, align 8, !tbaa !0
  %div.i.1.i.i = fdiv double %7, %6
  store double %div.i.1.i.i, double* %arrayidx.i.1.i.i, align 8, !tbaa !0
  %8 = load double, double* %s, align 8, !tbaa !0
  %arrayidx.1.i.1.i.i = getelementptr inbounds %class.Tensor.10, %class.Tensor.10* %this, i64 0, i32 0, i64 %indvars.iv, i32 0, i64 %indvars.iv.i, i32 0, i64 1, i32 0, i64 1
  %9 = load double, double* %arrayidx.1.i.1.i.i, align 8, !tbaa !0
  %div.1.i.1.i.i = fdiv double %9, %8
  store double %div.1.i.1.i.i, double* %arrayidx.1.i.1.i.i, align 8, !tbaa !0
  %10 = load double, double* %s, align 8, !tbaa !0
  %arrayidx.2.i.1.i.i = getelementptr inbounds %class.Tensor.10, %class.Tensor.10* %this, i64 0, i32 0, i64 %indvars.iv, i32 0, i64 %indvars.iv.i, i32 0, i64 1, i32 0, i64 2
  %11 = load double, double* %arrayidx.2.i.1.i.i, align 8, !tbaa !0
  %div.2.i.1.i.i = fdiv double %11, %10
  store double %div.2.i.1.i.i, double* %arrayidx.2.i.1.i.i, align 8, !tbaa !0
  %12 = load double, double* %s, align 8, !tbaa !0
  %arrayidx.i.2.i.i = getelementptr inbounds %class.Tensor.10, %class.Tensor.10* %this, i64 0, i32 0, i64 %indvars.iv, i32 0, i64 %indvars.iv.i, i32 0, i64 2, i32 0, i64 0
  %13 = load double, double* %arrayidx.i.2.i.i, align 8, !tbaa !0
  %div.i.2.i.i = fdiv double %13, %12
  store double %div.i.2.i.i, double* %arrayidx.i.2.i.i, align 8, !tbaa !0
  %14 = load double, double* %s, align 8, !tbaa !0
  %arrayidx.1.i.2.i.i = getelementptr inbounds %class.Tensor.10, %class.Tensor.10* %this, i64 0, i32 0, i64 %indvars.iv, i32 0, i64 %indvars.iv.i, i32 0, i64 2, i32 0, i64 1
  %15 = load double, double* %arrayidx.1.i.2.i.i, align 8, !tbaa !0
  %div.1.i.2.i.i = fdiv double %15, %14
  store double %div.1.i.2.i.i, double* %arrayidx.1.i.2.i.i, align 8, !tbaa !0
  %16 = load double, double* %s, align 8, !tbaa !0
  %arrayidx.2.i.2.i.i = getelementptr inbounds %class.Tensor.10, %class.Tensor.10* %this, i64 0, i32 0, i64 %indvars.iv, i32 0, i64 %indvars.iv.i, i32 0, i64 2, i32 0, i64 2
  %17 = load double, double* %arrayidx.2.i.2.i.i, align 8, !tbaa !0
  %div.2.i.2.i.i = fdiv double %17, %16
  store double %div.2.i.2.i.i, double* %arrayidx.2.i.2.i.i, align 8, !tbaa !0
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %exitcond.i = icmp eq i64 %indvars.iv.next.i, 3
  br i1 %exitcond.i, label %_ZN6TensorILi3ELi3EEdVERKd.exit, label %for.body.i

_ZN6TensorILi3ELi3EEdVERKd.exit:                  ; preds = %for.body.i
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 3
  br i1 %exitcond, label %for.cond.cleanup.exitStub, label %for.body
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
