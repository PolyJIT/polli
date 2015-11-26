
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '2mm.dir/2mm.c.main_for.body.15.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.15.i.pjit.scop(double* %arrayidx.i.172, double* %arrayidx23.i, double*)  {
newFuncRoot:
  br label %for.body.15.i

for.inc.38.i.176.exitStub:                        ; preds = %for.inc.35.i
  ret void

for.body.15.i:                                    ; preds = %for.inc.35.i, %newFuncRoot
  %indvars.iv16.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next17.i, %for.inc.35.i ]
  %arrayidx17.i = getelementptr inbounds double, double* %arrayidx.i.172, i64 %indvars.iv16.i
  store double 0.000000e+00, double* %arrayidx17.i, align 8, !tbaa !0
  br label %for.body.20.i

for.body.20.i:                                    ; preds = %for.body.20.i, %for.body.15.i
  %indvars.iv13.i = phi i64 [ 0, %for.body.15.i ], [ %indvars.iv.next14.i, %for.body.20.i ]
  %arrayidx24.i = getelementptr inbounds double, double* %arrayidx23.i, i64 %indvars.iv13.i
  %1 = load double, double* %arrayidx24.i, align 8, !tbaa !0
  %mul.i = fmul double %1, 1.500000e+00
  %2 = mul nuw nsw i64 %indvars.iv13.i, 900
  %arrayidx27.i = getelementptr inbounds double, double* %0, i64 %2
  %arrayidx28.i = getelementptr inbounds double, double* %arrayidx27.i, i64 %indvars.iv16.i
  %3 = load double, double* %arrayidx28.i, align 8, !tbaa !0
  %mul29.i = fmul double %mul.i, %3
  %4 = load double, double* %arrayidx17.i, align 8, !tbaa !0
  %add34.i = fadd double %4, %mul29.i
  store double %add34.i, double* %arrayidx17.i, align 8, !tbaa !0
  %indvars.iv.next14.i = add nuw nsw i64 %indvars.iv13.i, 1
  %exitcond15.i = icmp eq i64 %indvars.iv.next14.i, 1100
  br i1 %exitcond15.i, label %for.inc.35.i, label %for.body.20.i

for.inc.35.i:                                     ; preds = %for.body.20.i
  %indvars.iv.next17.i = add nuw nsw i64 %indvars.iv16.i, 1
  %exitcond18.i.173 = icmp eq i64 %indvars.iv.next17.i, 900
  br i1 %exitcond18.i.173, label %for.inc.38.i.176.exitStub, label %for.body.15.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
