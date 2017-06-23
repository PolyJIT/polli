
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'jacobi-1d.dir/jacobi-1d.c.main_for.cond.2.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.2.preheader.i.pjit.scop(double*, double*)  {
newFuncRoot:
  br label %for.cond.2.preheader.i

kernel_jacobi_1d.exit.exitStub:                   ; preds = %for.inc.35.i
  ret void

for.cond.2.preheader.i:                           ; preds = %for.inc.35.i, %newFuncRoot
  %t.03.i = phi i32 [ %inc36.i, %for.inc.35.i ], [ 0, %newFuncRoot ]
  br label %for.body.4.i

for.body.4.i:                                     ; preds = %for.body.4.i, %for.cond.2.preheader.i
  %indvars.iv.i.92 = phi i64 [ 1, %for.cond.2.preheader.i ], [ %indvars.iv.next.i.94, %for.body.4.i ]
  %2 = add nsw i64 %indvars.iv.i.92, -1
  %arrayidx.i.93 = getelementptr inbounds double, double* %0, i64 %2
  %3 = load double, double* %arrayidx.i.93, align 8, !tbaa !0
  %arrayidx7.i = getelementptr inbounds double, double* %0, i64 %indvars.iv.i.92
  %4 = load double, double* %arrayidx7.i, align 8, !tbaa !0
  %add8.i = fadd double %3, %4
  %indvars.iv.next.i.94 = add nuw nsw i64 %indvars.iv.i.92, 1
  %arrayidx11.i = getelementptr inbounds double, double* %0, i64 %indvars.iv.next.i.94
  %5 = load double, double* %arrayidx11.i, align 8, !tbaa !0
  %add12.i = fadd double %add8.i, %5
  %mul.i = fmul double %add12.i, 3.333300e-01
  %arrayidx14.i = getelementptr inbounds double, double* %1, i64 %indvars.iv.i.92
  store double %mul.i, double* %arrayidx14.i, align 8, !tbaa !0
  %exitcond.i.95 = icmp eq i64 %indvars.iv.next.i.94, 1999
  br i1 %exitcond.i.95, label %for.body.18.i.preheader, label %for.body.4.i

for.body.18.i.preheader:                          ; preds = %for.body.4.i
  br label %for.body.18.i

for.body.18.i:                                    ; preds = %for.body.18.i, %for.body.18.i.preheader
  %indvars.iv5.i = phi i64 [ %indvars.iv.next6.i, %for.body.18.i ], [ 1, %for.body.18.i.preheader ]
  %6 = add nsw i64 %indvars.iv5.i, -1
  %arrayidx21.i = getelementptr inbounds double, double* %1, i64 %6
  %7 = load double, double* %arrayidx21.i, align 8, !tbaa !0
  %arrayidx23.i = getelementptr inbounds double, double* %1, i64 %indvars.iv5.i
  %8 = load double, double* %arrayidx23.i, align 8, !tbaa !0
  %add24.i = fadd double %7, %8
  %indvars.iv.next6.i = add nuw nsw i64 %indvars.iv5.i, 1
  %arrayidx27.i = getelementptr inbounds double, double* %1, i64 %indvars.iv.next6.i
  %9 = load double, double* %arrayidx27.i, align 8, !tbaa !0
  %add28.i = fadd double %add24.i, %9
  %mul29.i = fmul double %add28.i, 3.333300e-01
  %arrayidx31.i = getelementptr inbounds double, double* %0, i64 %indvars.iv5.i
  store double %mul29.i, double* %arrayidx31.i, align 8, !tbaa !0
  %exitcond8.i = icmp eq i64 %indvars.iv.next6.i, 1999
  br i1 %exitcond8.i, label %for.inc.35.i, label %for.body.18.i

for.inc.35.i:                                     ; preds = %for.body.18.i
  %inc36.i = add nuw nsw i32 %t.03.i, 1
  %exitcond9.i = icmp eq i32 %inc36.i, 500
  br i1 %exitcond9.i, label %kernel_jacobi_1d.exit.exitStub, label %for.cond.2.preheader.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
