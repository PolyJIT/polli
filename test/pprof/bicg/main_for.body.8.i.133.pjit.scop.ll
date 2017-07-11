
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'bicg.dir/bicg.c.main_for.body.8.i.133.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.8.i.133.pjit.scop(double*, double*, double*, double*, double*)  {
newFuncRoot:
  br label %for.body.8.i.133

kernel_bicg.exit.exitStub:                        ; preds = %for.inc.40.i
  ret void

for.body.8.i.133:                                 ; preds = %for.inc.40.i, %newFuncRoot
  %indvars.iv4.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next5.i, %for.inc.40.i ]
  %arrayidx10.i = getelementptr inbounds double, double* %0, i64 %indvars.iv4.i
  store double 0.000000e+00, double* %arrayidx10.i, align 8, !tbaa !0
  %arrayidx17.i.132 = getelementptr inbounds double, double* %1, i64 %indvars.iv4.i
  %5 = mul nuw nsw i64 %indvars.iv4.i, 1900
  %arrayidx20.i = getelementptr inbounds double, double* %2, i64 %5
  br label %for.body.13.i

for.body.13.i:                                    ; preds = %for.body.13.i, %for.body.8.i.133
  %indvars.iv.i.134 = phi i64 [ 0, %for.body.8.i.133 ], [ %indvars.iv.next.i.135, %for.body.13.i ]
  %arrayidx15.i = getelementptr inbounds double, double* %3, i64 %indvars.iv.i.134
  %6 = load double, double* %arrayidx15.i, align 8, !tbaa !0
  %7 = load double, double* %arrayidx17.i.132, align 8, !tbaa !0
  %arrayidx21.i = getelementptr inbounds double, double* %arrayidx20.i, i64 %indvars.iv.i.134
  %8 = load double, double* %arrayidx21.i, align 8, !tbaa !0
  %mul.i = fmul double %7, %8
  %add22.i = fadd double %6, %mul.i
  store double %add22.i, double* %arrayidx15.i, align 8, !tbaa !0
  %9 = load double, double* %arrayidx10.i, align 8, !tbaa !0
  %10 = load double, double* %arrayidx21.i, align 8, !tbaa !0
  %arrayidx32.i = getelementptr inbounds double, double* %4, i64 %indvars.iv.i.134
  %11 = load double, double* %arrayidx32.i, align 8, !tbaa !0
  %mul33.i = fmul double %10, %11
  %add34.i = fadd double %9, %mul33.i
  store double %add34.i, double* %arrayidx10.i, align 8, !tbaa !0
  %indvars.iv.next.i.135 = add nuw nsw i64 %indvars.iv.i.134, 1
  %exitcond.i.136 = icmp eq i64 %indvars.iv.next.i.135, 1900
  br i1 %exitcond.i.136, label %for.inc.40.i, label %for.body.13.i

for.inc.40.i:                                     ; preds = %for.body.13.i
  %indvars.iv.next5.i = add nuw nsw i64 %indvars.iv4.i, 1
  %exitcond6.i = icmp eq i64 %indvars.iv.next5.i, 2100
  br i1 %exitcond6.i, label %kernel_bicg.exit.exitStub, label %for.body.8.i.133
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
