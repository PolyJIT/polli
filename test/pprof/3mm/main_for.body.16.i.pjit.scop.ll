
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '3mm.dir/3mm.c.main_for.body.16.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.16.i.pjit.scop(double* %arrayidx.i.200, double* %arrayidx24.i, double*)  {
newFuncRoot:
  br label %for.body.16.i

for.inc.38.i.exitStub:                            ; preds = %for.inc.35.i
  ret void

for.body.16.i:                                    ; preds = %for.inc.35.i, %newFuncRoot
  %indvars.iv28.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next29.i, %for.inc.35.i ]
  %arrayidx18.i = getelementptr inbounds double, double* %arrayidx.i.200, i64 %indvars.iv28.i
  store double 0.000000e+00, double* %arrayidx18.i, align 8, !tbaa !0
  br label %for.body.21.i

for.body.21.i:                                    ; preds = %for.body.21.i, %for.body.16.i
  %indvars.iv25.i = phi i64 [ 0, %for.body.16.i ], [ %indvars.iv.next26.i, %for.body.21.i ]
  %arrayidx25.i = getelementptr inbounds double, double* %arrayidx24.i, i64 %indvars.iv25.i
  %1 = load double, double* %arrayidx25.i, align 8, !tbaa !0
  %2 = mul nuw nsw i64 %indvars.iv25.i, 900
  %arrayidx28.i = getelementptr inbounds double, double* %0, i64 %2
  %arrayidx29.i = getelementptr inbounds double, double* %arrayidx28.i, i64 %indvars.iv28.i
  %3 = load double, double* %arrayidx29.i, align 8, !tbaa !0
  %mul.i = fmul double %1, %3
  %4 = load double, double* %arrayidx18.i, align 8, !tbaa !0
  %add34.i = fadd double %4, %mul.i
  store double %add34.i, double* %arrayidx18.i, align 8, !tbaa !0
  %indvars.iv.next26.i = add nuw nsw i64 %indvars.iv25.i, 1
  %exitcond27.i = icmp eq i64 %indvars.iv.next26.i, 1000
  br i1 %exitcond27.i, label %for.inc.35.i, label %for.body.21.i

for.inc.35.i:                                     ; preds = %for.body.21.i
  %indvars.iv.next29.i = add nuw nsw i64 %indvars.iv28.i, 1
  %exitcond30.i = icmp eq i64 %indvars.iv.next29.i, 900
  br i1 %exitcond30.i, label %for.inc.38.i.exitStub, label %for.body.16.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
