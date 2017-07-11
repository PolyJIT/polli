
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'atax.dir/atax.c.main_for.body.9.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.9.i.pjit.scop(double*, double*, double*, double*)  {
newFuncRoot:
  br label %for.body.9.i

kernel_atax.exit.exitStub:                        ; preds = %for.inc.47.i
  ret void

for.body.9.i:                                     ; preds = %for.inc.47.i, %newFuncRoot
  %indvars.iv8.i.123 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next9.i.131, %for.inc.47.i ]
  %arrayidx11.i = getelementptr inbounds double, double* %0, i64 %indvars.iv8.i.123
  store double 0.000000e+00, double* %arrayidx11.i, align 8, !tbaa !0
  %4 = mul nuw nsw i64 %indvars.iv8.i.123, 2100
  %arrayidx19.i = getelementptr inbounds double, double* %1, i64 %4
  br label %for.body.14.i

for.body.14.i:                                    ; preds = %for.body.14.i, %for.body.9.i
  %indvars.iv.i.124 = phi i64 [ 0, %for.body.9.i ], [ %indvars.iv.next.i.126, %for.body.14.i ]
  %5 = load double, double* %arrayidx11.i, align 8, !tbaa !0
  %arrayidx20.i.125 = getelementptr inbounds double, double* %arrayidx19.i, i64 %indvars.iv.i.124
  %6 = load double, double* %arrayidx20.i.125, align 8, !tbaa !0
  %arrayidx22.i = getelementptr inbounds double, double* %2, i64 %indvars.iv.i.124
  %7 = load double, double* %arrayidx22.i, align 8, !tbaa !0
  %mul.i = fmul double %6, %7
  %add23.i = fadd double %5, %mul.i
  store double %add23.i, double* %arrayidx11.i, align 8, !tbaa !0
  %indvars.iv.next.i.126 = add nuw nsw i64 %indvars.iv.i.124, 1
  %exitcond.i.127 = icmp eq i64 %indvars.iv.next.i.126, 2100
  br i1 %exitcond.i.127, label %for.body.31.i.preheader, label %for.body.14.i

for.body.31.i.preheader:                          ; preds = %for.body.14.i
  br label %for.body.31.i

for.body.31.i:                                    ; preds = %for.body.31.i, %for.body.31.i.preheader
  %indvars.iv5.i.128 = phi i64 [ %indvars.iv.next6.i.129, %for.body.31.i ], [ 0, %for.body.31.i.preheader ]
  %arrayidx33.i = getelementptr inbounds double, double* %3, i64 %indvars.iv5.i.128
  %8 = load double, double* %arrayidx33.i, align 8, !tbaa !0
  %arrayidx37.i = getelementptr inbounds double, double* %arrayidx19.i, i64 %indvars.iv5.i.128
  %9 = load double, double* %arrayidx37.i, align 8, !tbaa !0
  %10 = load double, double* %arrayidx11.i, align 8, !tbaa !0
  %mul40.i = fmul double %9, %10
  %add41.i = fadd double %8, %mul40.i
  store double %add41.i, double* %arrayidx33.i, align 8, !tbaa !0
  %indvars.iv.next6.i.129 = add nuw nsw i64 %indvars.iv5.i.128, 1
  %exitcond7.i.130 = icmp eq i64 %indvars.iv.next6.i.129, 2100
  br i1 %exitcond7.i.130, label %for.inc.47.i, label %for.body.31.i

for.inc.47.i:                                     ; preds = %for.body.31.i
  %indvars.iv.next9.i.131 = add nuw nsw i64 %indvars.iv8.i.123, 1
  %exitcond10.i.132 = icmp eq i64 %indvars.iv.next9.i.131, 1900
  br i1 %exitcond10.i.132, label %kernel_atax.exit.exitStub, label %for.body.9.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
