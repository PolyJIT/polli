
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'ludcmp.dir/ludcmp.c.main_for.cond.116.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.116.preheader.i.pjit.scop(double*, double*)  {
newFuncRoot:
  br label %for.cond.116.preheader.i

init_array.exit.exitStub:                         ; preds = %for.inc.131.i
  ret void

for.cond.116.preheader.i:                         ; preds = %for.inc.131.i, %newFuncRoot
  %indvars.iv14.i = phi i64 [ %indvars.iv.next15.i, %for.inc.131.i ], [ 0, %newFuncRoot ]
  %2 = mul nuw nsw i64 %indvars.iv14.i, 2000
  %arrayidx122.i = getelementptr inbounds double, double* %0, i64 %2
  %arrayidx126.i = getelementptr inbounds double, double* %1, i64 %2
  br label %for.body.119.i

for.body.119.i:                                   ; preds = %for.body.119.i, %for.cond.116.preheader.i
  %indvars.iv.i = phi i64 [ 0, %for.cond.116.preheader.i ], [ %indvars.iv.next.i, %for.body.119.i ]
  %arrayidx123.i = getelementptr inbounds double, double* %arrayidx122.i, i64 %indvars.iv.i
  %3 = bitcast double* %arrayidx123.i to i64*
  %4 = load i64, i64* %3, align 8, !tbaa !0
  %arrayidx127.i = getelementptr inbounds double, double* %arrayidx126.i, i64 %indvars.iv.i
  %5 = bitcast double* %arrayidx127.i to i64*
  store i64 %4, i64* %5, align 8, !tbaa !0
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %exitcond.i = icmp eq i64 %indvars.iv.next.i, 2000
  br i1 %exitcond.i, label %for.inc.131.i, label %for.body.119.i

for.inc.131.i:                                    ; preds = %for.body.119.i
  %indvars.iv.next15.i = add nuw nsw i64 %indvars.iv14.i, 1
  %exitcond16.i = icmp eq i64 %indvars.iv.next15.i, 2000
  br i1 %exitcond16.i, label %init_array.exit.exitStub, label %for.cond.116.preheader.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
