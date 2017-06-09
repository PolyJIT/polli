
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'zsyr2k.c.f2c_zsyr2k_for.body.100.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.doublecomplex = type { double, double }

; Function Attrs: nounwind
define weak void @f2c_zsyr2k_for.body.100.lr.ph.pjit.scop(i64, double* %r77, %struct.doublecomplex* %add.ptr6, double* %i109, i64)  {
newFuncRoot:
  br label %for.body.100.lr.ph

cleanup.loopexit2031.exitStub:                    ; preds = %for.inc.133
  ret void

for.body.100.lr.ph:                               ; preds = %for.inc.133, %newFuncRoot
  %indvars.iv1998 = phi i64 [ %indvars.iv.next1999, %for.inc.133 ], [ 2, %newFuncRoot ]
  %j.11922 = phi i64 [ %inc134, %for.inc.133 ], [ 1, %newFuncRoot ]
  %mul101 = mul nsw i64 %j.11922, %0
  br label %for.body.100

for.body.100:                                     ; preds = %for.body.100, %for.body.100.lr.ph
  %i__.11920 = phi i64 [ 1, %for.body.100.lr.ph ], [ %inc131, %for.body.100 ]
  %add102 = add nsw i64 %i__.11920, %mul101
  %2 = load double, double* %r77, align 8, !tbaa !0
  %arrayidx106 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %add.ptr6, i64 %add102
  %r107 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx106, i64 0, i32 0
  %3 = load double, double* %r107, align 8, !tbaa !0
  %mul108 = fmul double %2, %3
  %4 = load double, double* %i109, align 8, !tbaa !5
  %i111 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx106, i64 0, i32 1
  %5 = load double, double* %i111, align 8, !tbaa !5
  %mul112 = fmul double %4, %5
  %sub = fsub double %mul108, %mul112
  %mul117 = fmul double %2, %5
  %mul121 = fmul double %3, %4
  %add122 = fadd double %mul121, %mul117
  store double %sub, double* %r107, align 8, !tbaa !0
  store double %add122, double* %i111, align 8, !tbaa !5
  %inc131 = add nuw nsw i64 %i__.11920, 1
  %exitcond2000 = icmp eq i64 %inc131, %indvars.iv1998
  br i1 %exitcond2000, label %for.inc.133, label %for.body.100

for.inc.133:                                      ; preds = %for.body.100
  %inc134 = add nuw nsw i64 %j.11922, 1
  %indvars.iv.next1999 = add nuw i64 %indvars.iv1998, 1
  %exitcond2041 = icmp eq i64 %indvars.iv.next1999, %1
  br i1 %exitcond2041, label %cleanup.loopexit2031.exitStub, label %for.body.100.lr.ph
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 0}
!1 = !{!"", !2, i64 0, !2, i64 8}
!2 = !{!"double", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!1, !2, i64 8}
