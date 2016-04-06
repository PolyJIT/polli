
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'covariance.dir/covariance.c.main_for.body.43.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.43.i.pjit.scop(i64 %indvars.iv14.i, double* %arrayidx46.i, double*, double*)  {
newFuncRoot:
  br label %for.body.43.i

for.inc.84.i.exitStub:                            ; preds = %for.end.66.i
  ret void

for.body.43.i:                                    ; preds = %for.end.66.i, %newFuncRoot
  %indvars.iv11.i = phi i64 [ %indvars.iv14.i, %newFuncRoot ], [ %indvars.iv.next12.i, %for.end.66.i ]
  %arrayidx47.i = getelementptr inbounds double, double* %arrayidx46.i, i64 %indvars.iv11.i
  store double 0.000000e+00, double* %arrayidx47.i, align 8, !tbaa !0
  br label %for.body.50.i

for.body.50.i:                                    ; preds = %for.body.50.i, %for.body.43.i
  %indvars.iv.i.119 = phi i64 [ 0, %for.body.43.i ], [ %indvars.iv.next.i.121, %for.body.50.i ]
  %2 = mul nuw nsw i64 %indvars.iv.i.119, 1200
  %arrayidx53.i = getelementptr inbounds double, double* %0, i64 %2
  %arrayidx54.i = getelementptr inbounds double, double* %arrayidx53.i, i64 %indvars.iv14.i
  %3 = load double, double* %arrayidx54.i, align 8, !tbaa !0
  %arrayidx58.i = getelementptr inbounds double, double* %arrayidx53.i, i64 %indvars.iv11.i
  %4 = load double, double* %arrayidx58.i, align 8, !tbaa !0
  %mul.i.120 = fmul double %3, %4
  %5 = load double, double* %arrayidx47.i, align 8, !tbaa !0
  %add63.i = fadd double %5, %mul.i.120
  store double %add63.i, double* %arrayidx47.i, align 8, !tbaa !0
  %indvars.iv.next.i.121 = add nuw nsw i64 %indvars.iv.i.119, 1
  %exitcond.i.122 = icmp eq i64 %indvars.iv.next.i.121, 1400
  br i1 %exitcond.i.122, label %for.end.66.i, label %for.body.50.i

for.end.66.i:                                     ; preds = %for.body.50.i
  %add63.i.lcssa = phi double [ %add63.i, %for.body.50.i ]
  %div72.i = fdiv double %add63.i.lcssa, 1.399000e+03
  store double %div72.i, double* %arrayidx47.i, align 8, !tbaa !0
  %6 = mul nuw nsw i64 %indvars.iv11.i, 1200
  %arrayidx79.i = getelementptr inbounds double, double* %1, i64 %6
  %arrayidx80.i = getelementptr inbounds double, double* %arrayidx79.i, i64 %indvars.iv14.i
  store double %div72.i, double* %arrayidx80.i, align 8, !tbaa !0
  %indvars.iv.next12.i = add nuw nsw i64 %indvars.iv11.i, 1
  %lftr.wideiv124 = trunc i64 %indvars.iv.next12.i to i32
  %exitcond125 = icmp eq i32 %lftr.wideiv124, 1200
  br i1 %exitcond125, label %for.inc.84.i.exitStub, label %for.body.43.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
