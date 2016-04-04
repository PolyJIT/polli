
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'seidel-2d.dir/seidel-2d.c.main_for.cond.2.preheader.i.89.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.2.preheader.i.89.pjit.scop(double*)  {
newFuncRoot:
  br label %for.cond.2.preheader.i.89

kernel_seidel_2d.exit.exitStub:                   ; preds = %for.inc.71.i
  ret void

for.cond.2.preheader.i.89:                        ; preds = %for.inc.71.i, %newFuncRoot
  %t.03.i = phi i32 [ %inc72.i, %for.inc.71.i ], [ 0, %newFuncRoot ]
  br label %for.cond.6.preheader.i

for.cond.6.preheader.i:                           ; preds = %for.inc.68.i, %for.cond.2.preheader.i.89
  %indvars.iv5.i = phi i64 [ 1, %for.cond.2.preheader.i.89 ], [ %indvars.iv.next6.i, %for.inc.68.i ]
  %1 = mul nuw nsw i64 %indvars.iv5.i, 2000
  %2 = add nsw i64 %1, -2000
  %arrayidx.i.90 = getelementptr inbounds double, double* %0, i64 %2
  %arrayidx30.i = getelementptr inbounds double, double* %0, i64 %1
  %indvars.iv.next6.i = add nuw nsw i64 %indvars.iv5.i, 1
  %3 = mul nuw nsw i64 %indvars.iv.next6.i, 2000
  %arrayidx48.i = getelementptr inbounds double, double* %0, i64 %3
  br label %for.body.9.i

for.body.9.i:                                     ; preds = %for.body.9.i, %for.cond.6.preheader.i
  %indvars.iv.i.91 = phi i64 [ 1, %for.cond.6.preheader.i ], [ %indvars.iv.next.i.92, %for.body.9.i ]
  %4 = add nsw i64 %indvars.iv.i.91, -1
  %arrayidx13.i = getelementptr inbounds double, double* %arrayidx.i.90, i64 %4
  %5 = load double, double* %arrayidx13.i, align 8, !tbaa !0
  %arrayidx18.i = getelementptr inbounds double, double* %arrayidx.i.90, i64 %indvars.iv.i.91
  %6 = load double, double* %arrayidx18.i, align 8, !tbaa !0
  %add19.i = fadd double %5, %6
  %indvars.iv.next.i.92 = add nuw nsw i64 %indvars.iv.i.91, 1
  %arrayidx25.i = getelementptr inbounds double, double* %arrayidx.i.90, i64 %indvars.iv.next.i.92
  %7 = load double, double* %arrayidx25.i, align 8, !tbaa !0
  %add26.i = fadd double %add19.i, %7
  %arrayidx31.i = getelementptr inbounds double, double* %arrayidx30.i, i64 %4
  %8 = load double, double* %arrayidx31.i, align 8, !tbaa !0
  %add32.i = fadd double %add26.i, %8
  %arrayidx36.i = getelementptr inbounds double, double* %arrayidx30.i, i64 %indvars.iv.i.91
  %9 = load double, double* %arrayidx36.i, align 8, !tbaa !0
  %add37.i = fadd double %add32.i, %9
  %arrayidx42.i = getelementptr inbounds double, double* %arrayidx30.i, i64 %indvars.iv.next.i.92
  %10 = load double, double* %arrayidx42.i, align 8, !tbaa !0
  %add43.i = fadd double %add37.i, %10
  %arrayidx49.i = getelementptr inbounds double, double* %arrayidx48.i, i64 %4
  %11 = load double, double* %arrayidx49.i, align 8, !tbaa !0
  %add50.i = fadd double %add43.i, %11
  %arrayidx55.i = getelementptr inbounds double, double* %arrayidx48.i, i64 %indvars.iv.i.91
  %12 = load double, double* %arrayidx55.i, align 8, !tbaa !0
  %add56.i = fadd double %add50.i, %12
  %arrayidx62.i = getelementptr inbounds double, double* %arrayidx48.i, i64 %indvars.iv.next.i.92
  %13 = load double, double* %arrayidx62.i, align 8, !tbaa !0
  %add63.i = fadd double %add56.i, %13
  %div.i.93 = fdiv double %add63.i, 9.000000e+00
  store double %div.i.93, double* %arrayidx36.i, align 8, !tbaa !0
  %exitcond.i.94 = icmp eq i64 %indvars.iv.next.i.92, 1999
  br i1 %exitcond.i.94, label %for.inc.68.i, label %for.body.9.i

for.inc.68.i:                                     ; preds = %for.body.9.i
  %exitcond8.i = icmp eq i64 %indvars.iv.next6.i, 1999
  br i1 %exitcond8.i, label %for.inc.71.i, label %for.cond.6.preheader.i

for.inc.71.i:                                     ; preds = %for.inc.68.i
  %inc72.i = add nuw nsw i32 %t.03.i, 1
  %exitcond9.i = icmp eq i32 %inc72.i, 500
  br i1 %exitcond9.i, label %kernel_seidel_2d.exit.exitStub, label %for.cond.2.preheader.i.89
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
