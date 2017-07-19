
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'zherk.c.f2c_zherk_for.cond.67.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.doublecomplex = type { double, double }

; Function Attrs: nounwind
define weak void @f2c_zherk_for.cond.67.preheader.pjit.scop(i1 %cmp57.1565, i64, double* %beta, %struct.doublecomplex* %add.ptr3, i64)  {
newFuncRoot:
  br label %for.cond.67.preheader

cleanup.exitStub:                                 ; preds = %cleanup.loopexit1683, %for.cond.67.preheader
  ret void

for.cond.67.preheader:                            ; preds = %newFuncRoot
  br i1 %cmp57.1565, label %cleanup.exitStub, label %for.cond.70.preheader.preheader

for.cond.70.preheader.preheader:                  ; preds = %for.cond.67.preheader
  br label %for.cond.70.preheader

for.cond.70.preheader:                            ; preds = %for.end.93, %for.cond.70.preheader.preheader
  %indvars.iv1648 = phi i64 [ %indvars.iv.next1649, %for.end.93 ], [ 1, %for.cond.70.preheader.preheader ]
  %cmp71.1568 = icmp sgt i64 %indvars.iv1648, 1
  %mul73 = mul nsw i64 %indvars.iv1648, %0
  br i1 %cmp71.1568, label %for.body.72.preheader, label %for.end.93

for.body.72.preheader:                            ; preds = %for.cond.70.preheader
  br label %for.body.72

for.body.72:                                      ; preds = %for.body.72, %for.body.72.preheader
  %i__.11569 = phi i64 [ %inc92, %for.body.72 ], [ 1, %for.body.72.preheader ]
  %add74 = add nsw i64 %i__.11569, %mul73
  %2 = load double, double* %beta, align 8, !tbaa !0
  %arrayidx77 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %add.ptr3, i64 %add74
  %r78 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx77, i64 0, i32 0
  %3 = load double, double* %r78, align 8, !tbaa !4
  %mul79 = fmul double %2, %3
  %i82 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx77, i64 0, i32 1
  %4 = load double, double* %i82, align 8, !tbaa !6
  %mul83 = fmul double %2, %4
  store double %mul79, double* %r78, align 8, !tbaa !4
  store double %mul83, double* %i82, align 8, !tbaa !6
  %inc92 = add nuw nsw i64 %i__.11569, 1
  %exitcond1650 = icmp eq i64 %inc92, %indvars.iv1648
  br i1 %exitcond1650, label %for.end.93.loopexit, label %for.body.72

for.end.93.loopexit:                              ; preds = %for.body.72
  br label %for.end.93

for.end.93:                                       ; preds = %for.end.93.loopexit, %for.cond.70.preheader
  %add95 = add nsw i64 %mul73, %indvars.iv1648
  %5 = load double, double* %beta, align 8, !tbaa !0
  %arrayidx98 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %add.ptr3, i64 %add95
  %r99 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx98, i64 0, i32 0
  %6 = load double, double* %r99, align 8, !tbaa !4
  %mul100 = fmul double %5, %6
  store double %mul100, double* %r99, align 8, !tbaa !4
  %i104 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx98, i64 0, i32 1
  store double 0.000000e+00, double* %i104, align 8, !tbaa !6
  %indvars.iv.next1649 = add nuw nsw i64 %indvars.iv1648, 1
  %exitcond1651 = icmp eq i64 %indvars.iv1648, %1
  br i1 %exitcond1651, label %cleanup.loopexit1683, label %for.cond.70.preheader

cleanup.loopexit1683:                             ; preds = %for.end.93
  br label %cleanup.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !1, i64 0}
!5 = !{!"", !1, i64 0, !1, i64 8}
!6 = !{!5, !1, i64 8}
