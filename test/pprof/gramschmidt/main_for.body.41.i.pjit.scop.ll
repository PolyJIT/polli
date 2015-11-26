
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'gramschmidt.dir/gramschmidt.c.main_for.body.41.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.41.i.pjit.scop(i64 %indvars.iv18.i, double* %arrayidx18.i, double*, i64 %indvars.iv23.i, double*)  {
newFuncRoot:
  br label %for.body.41.i

for.cond.loopexit.i.loopexit.exitStub:            ; preds = %for.inc.89.i
  ret void

for.body.41.i:                                    ; preds = %for.inc.89.i, %newFuncRoot
  %indvars.iv20.i = phi i64 [ %indvars.iv.next21.i, %for.inc.89.i ], [ %indvars.iv18.i, %newFuncRoot ]
  %arrayidx45.i = getelementptr inbounds double, double* %arrayidx18.i, i64 %indvars.iv20.i
  store double 0.000000e+00, double* %arrayidx45.i, align 8, !tbaa !0
  br label %for.body.48.i

for.body.48.i:                                    ; preds = %for.body.48.i, %for.body.41.i
  %indvars.iv12.i.134 = phi i64 [ 0, %for.body.41.i ], [ %indvars.iv.next13.i.135, %for.body.48.i ]
  %2 = mul nuw nsw i64 %indvars.iv12.i.134, 1200
  %arrayidx51.i = getelementptr inbounds double, double* %0, i64 %2
  %arrayidx52.i = getelementptr inbounds double, double* %arrayidx51.i, i64 %indvars.iv23.i
  %3 = load double, double* %arrayidx52.i, align 8, !tbaa !0
  %arrayidx55.i = getelementptr inbounds double, double* %1, i64 %2
  %arrayidx56.i = getelementptr inbounds double, double* %arrayidx55.i, i64 %indvars.iv20.i
  %4 = load double, double* %arrayidx56.i, align 8, !tbaa !0
  %mul57.i = fmul double %3, %4
  %5 = load double, double* %arrayidx45.i, align 8, !tbaa !0
  %add62.i = fadd double %5, %mul57.i
  store double %add62.i, double* %arrayidx45.i, align 8, !tbaa !0
  %indvars.iv.next13.i.135 = add nuw nsw i64 %indvars.iv12.i.134, 1
  %exitcond14.i.136 = icmp eq i64 %indvars.iv.next13.i.135, 1000
  br i1 %exitcond14.i.136, label %for.body.68.i.preheader, label %for.body.48.i

for.body.68.i.preheader:                          ; preds = %for.body.48.i
  br label %for.body.68.i

for.body.68.i:                                    ; preds = %for.body.68.i, %for.body.68.i.preheader
  %indvars.iv15.i = phi i64 [ %indvars.iv.next16.i, %for.body.68.i ], [ 0, %for.body.68.i.preheader ]
  %6 = mul nuw nsw i64 %indvars.iv15.i, 1200
  %arrayidx71.i = getelementptr inbounds double, double* %1, i64 %6
  %arrayidx72.i = getelementptr inbounds double, double* %arrayidx71.i, i64 %indvars.iv20.i
  %7 = load double, double* %arrayidx72.i, align 8, !tbaa !0
  %arrayidx75.i = getelementptr inbounds double, double* %0, i64 %6
  %arrayidx76.i = getelementptr inbounds double, double* %arrayidx75.i, i64 %indvars.iv23.i
  %8 = load double, double* %arrayidx76.i, align 8, !tbaa !0
  %9 = load double, double* %arrayidx45.i, align 8, !tbaa !0
  %mul81.i = fmul double %8, %9
  %sub.i = fsub double %7, %mul81.i
  store double %sub.i, double* %arrayidx72.i, align 8, !tbaa !0
  %indvars.iv.next16.i = add nuw nsw i64 %indvars.iv15.i, 1
  %exitcond17.i = icmp eq i64 %indvars.iv.next16.i, 1000
  br i1 %exitcond17.i, label %for.inc.89.i, label %for.body.68.i

for.inc.89.i:                                     ; preds = %for.body.68.i
  %indvars.iv.next21.i = add nuw nsw i64 %indvars.iv20.i, 1
  %lftr.wideiv137 = trunc i64 %indvars.iv.next21.i to i32
  %exitcond138 = icmp eq i32 %lftr.wideiv137, 1200
  br i1 %exitcond138, label %for.cond.loopexit.i.loopexit.exitStub, label %for.body.41.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
