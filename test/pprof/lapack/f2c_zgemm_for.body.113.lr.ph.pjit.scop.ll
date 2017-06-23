
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'zgemm.c.f2c_zgemm_for.body.113.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.doublecomplex = type { double, double }

; Function Attrs: nounwind
define weak void @f2c_zgemm_for.body.113.lr.ph.pjit.scop(i64, double* %r90, %struct.doublecomplex* %add.ptr6, double* %i122, i64, i64)  {
newFuncRoot:
  br label %for.body.113.lr.ph

cleanup.loopexit2648.exitStub:                    ; preds = %for.inc.146
  ret void

for.body.113.lr.ph:                               ; preds = %for.inc.146, %newFuncRoot
  %j.12483 = phi i64 [ %inc147, %for.inc.146 ], [ 1, %newFuncRoot ]
  %mul114 = mul nsw i64 %j.12483, %0
  br label %for.body.113

for.body.113:                                     ; preds = %for.body.113, %for.body.113.lr.ph
  %i__.12481 = phi i64 [ 1, %for.body.113.lr.ph ], [ %inc144, %for.body.113 ]
  %add115 = add nsw i64 %i__.12481, %mul114
  %3 = load double, double* %r90, align 8, !tbaa !0
  %arrayidx119 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %add.ptr6, i64 %add115
  %r120 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx119, i64 0, i32 0
  %4 = load double, double* %r120, align 8, !tbaa !0
  %mul121 = fmul double %3, %4
  %5 = load double, double* %i122, align 8, !tbaa !5
  %i124 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx119, i64 0, i32 1
  %6 = load double, double* %i124, align 8, !tbaa !5
  %mul125 = fmul double %5, %6
  %sub = fsub double %mul121, %mul125
  %mul130 = fmul double %3, %6
  %mul134 = fmul double %4, %5
  %add135 = fadd double %mul134, %mul130
  store double %sub, double* %r120, align 8, !tbaa !0
  store double %add135, double* %i124, align 8, !tbaa !5
  %inc144 = add nuw nsw i64 %i__.12481, 1
  %exitcond2613 = icmp eq i64 %i__.12481, %1
  br i1 %exitcond2613, label %for.inc.146, label %for.body.113

for.inc.146:                                      ; preds = %for.body.113
  %inc147 = add nuw nsw i64 %j.12483, 1
  %exitcond2614 = icmp eq i64 %j.12483, %2
  br i1 %exitcond2614, label %cleanup.loopexit2648.exitStub, label %for.body.113.lr.ph
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 0}
!1 = !{!"", !2, i64 0, !2, i64 8}
!2 = !{!"double", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!1, !2, i64 8}
