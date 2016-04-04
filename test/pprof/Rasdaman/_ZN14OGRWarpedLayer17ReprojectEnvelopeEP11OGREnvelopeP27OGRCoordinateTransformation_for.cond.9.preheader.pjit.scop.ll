
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'ogrwarpedlayer.cpp._ZN14OGRWarpedLayer17ReprojectEnvelopeEP11OGREnvelopeP27OGRCoordinateTransformation_for.cond.9.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZN14OGRWarpedLayer17ReprojectEnvelopeEP11OGREnvelopeP27OGRCoordinateTransformation_for.cond.9.preheader.pjit.scop(double %div2, double* %MinX, double %div, double*, double* %MinY, double*)  {
newFuncRoot:
  br label %for.cond.9.preheader

for.end.25.exitStub:                              ; preds = %for.inc.23
  ret void

for.cond.9.preheader:                             ; preds = %for.inc.23, %newFuncRoot
  %indvars.iv207 = phi i64 [ %indvars.iv.next208, %for.inc.23 ], [ 0, %newFuncRoot ]
  %2 = mul nuw nsw i64 %indvars.iv207, 21
  %3 = trunc i64 %indvars.iv207 to i32
  %conv16 = sitofp i32 %3 to double
  %mul17 = fmul double %div2, %conv16
  br label %for.body.11

for.body.11:                                      ; preds = %for.body.11, %for.cond.9.preheader
  %indvars.iv203 = phi i64 [ 0, %for.cond.9.preheader ], [ %indvars.iv.next204, %for.body.11 ]
  %4 = load double, double* %MinX, align 8, !tbaa !0
  %5 = trunc i64 %indvars.iv203 to i32
  %conv = sitofp i32 %5 to double
  %mul = fmul double %div, %conv
  %add = fadd double %4, %mul
  %6 = add nuw nsw i64 %indvars.iv203, %2
  %arrayidx = getelementptr inbounds double, double* %0, i64 %6
  store double %add, double* %arrayidx, align 8, !tbaa !5
  %7 = load double, double* %MinY, align 8, !tbaa !6
  %add18 = fadd double %mul17, %7
  %arrayidx22 = getelementptr inbounds double, double* %1, i64 %6
  store double %add18, double* %arrayidx22, align 8, !tbaa !5
  %indvars.iv.next204 = add nuw nsw i64 %indvars.iv203, 1
  %exitcond206 = icmp eq i64 %indvars.iv.next204, 21
  br i1 %exitcond206, label %for.inc.23, label %for.body.11

for.inc.23:                                       ; preds = %for.body.11
  %indvars.iv.next208 = add nuw nsw i64 %indvars.iv207, 1
  %exitcond210 = icmp eq i64 %indvars.iv.next208, 21
  br i1 %exitcond210, label %for.end.25.exitStub, label %for.cond.9.preheader
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 0}
!1 = !{!"_ZTS11OGREnvelope", !2, i64 0, !2, i64 8, !2, i64 16, !2, i64 24}
!2 = !{!"double", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!2, !2, i64 0}
!6 = !{!1, !2, i64 16}
