
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'gesummv.dir/gesummv.c.main_for.body.i.142.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.i.142.pjit.scop(double*, double*, double*, double*, double*)  {
newFuncRoot:
  br label %for.body.i.142

kernel_gesummv.exit.exitStub:                     ; preds = %for.end.i
  ret void

for.body.i.142:                                   ; preds = %for.end.i, %newFuncRoot
  %indvars.iv3.i = phi i64 [ %indvars.iv.next4.i, %for.end.i ], [ 0, %newFuncRoot ]
  %arrayidx.i.140 = getelementptr inbounds double, double* %0, i64 %indvars.iv3.i
  store double 0.000000e+00, double* %arrayidx.i.140, align 8, !tbaa !0
  %arrayidx10.i = getelementptr inbounds double, double* %1, i64 %indvars.iv3.i
  store double 0.000000e+00, double* %arrayidx10.i, align 8, !tbaa !0
  %5 = mul nuw nsw i64 %indvars.iv3.i, 1300
  %arrayidx16.i.141 = getelementptr inbounds double, double* %2, i64 %5
  %arrayidx27.i = getelementptr inbounds double, double* %3, i64 %5
  br label %for.body.13.i

for.body.13.i:                                    ; preds = %for.body.13.i, %for.body.i.142
  %indvars.iv.i.143 = phi i64 [ 0, %for.body.i.142 ], [ %indvars.iv.next.i.145, %for.body.13.i ]
  %arrayidx17.i.144 = getelementptr inbounds double, double* %arrayidx16.i.141, i64 %indvars.iv.i.143
  %6 = load double, double* %arrayidx17.i.144, align 8, !tbaa !0
  %arrayidx19.i = getelementptr inbounds double, double* %4, i64 %indvars.iv.i.143
  %7 = load double, double* %arrayidx19.i, align 8, !tbaa !0
  %mul.i = fmul double %6, %7
  %8 = load double, double* %arrayidx.i.140, align 8, !tbaa !0
  %add22.i = fadd double %mul.i, %8
  store double %add22.i, double* %arrayidx.i.140, align 8, !tbaa !0
  %arrayidx28.i = getelementptr inbounds double, double* %arrayidx27.i, i64 %indvars.iv.i.143
  %9 = load double, double* %arrayidx28.i, align 8, !tbaa !0
  %10 = load double, double* %arrayidx19.i, align 8, !tbaa !0
  %mul31.i = fmul double %9, %10
  %11 = load double, double* %arrayidx10.i, align 8, !tbaa !0
  %add34.i = fadd double %mul31.i, %11
  store double %add34.i, double* %arrayidx10.i, align 8, !tbaa !0
  %indvars.iv.next.i.145 = add nuw nsw i64 %indvars.iv.i.143, 1
  %exitcond.i.146 = icmp eq i64 %indvars.iv.next.i.145, 1300
  br i1 %exitcond.i.146, label %for.end.i, label %for.body.13.i

for.end.i:                                        ; preds = %for.body.13.i
  %add34.i.lcssa = phi double [ %add34.i, %for.body.13.i ]
  %12 = load double, double* %arrayidx.i.140, align 8, !tbaa !0
  %mul39.i = fmul double %12, 1.500000e+00
  %mul42.i = fmul double %add34.i.lcssa, 1.200000e+00
  %add43.i = fadd double %mul42.i, %mul39.i
  store double %add43.i, double* %arrayidx10.i, align 8, !tbaa !0
  %indvars.iv.next4.i = add nuw nsw i64 %indvars.iv3.i, 1
  %exitcond5.i = icmp eq i64 %indvars.iv.next4.i, 1300
  br i1 %exitcond5.i, label %kernel_gesummv.exit.exitStub, label %for.body.i.142
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
