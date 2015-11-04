
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'dblat2.c.dmvch__for.body.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @dmvch__for.body.us.pjit.scop(i64 %i__.promoted, i64 %ky.0, double* %incdec.ptr2, double* %incdec.ptr3, i1 %cmp26.313, double* %alpha, double* %beta, double* %incdec.ptr1, i64, i64 %ml.0, i64, i64 %nl.0., double* %add.ptr, double* %incdec.ptr, i64, i64 %nl.0, i64* %inc104.us.out)  {
newFuncRoot:
  br label %for.body.us

for.cond.for.end.105_crit_edge.loopexit.exitStub: ; preds = %if.end.75.loopexit309.us
  store i64 %inc104.us, i64* %inc104.us.out
  ret void

for.body.us:                                      ; preds = %if.end.75.loopexit309.us, %newFuncRoot
  %inc104321.us = phi i64 [ %inc104.us, %if.end.75.loopexit309.us ], [ %i__.promoted, %newFuncRoot ]
  %iy.0320.us = phi i64 [ %add102.us, %if.end.75.loopexit309.us ], [ %ky.0, %newFuncRoot ]
  %arrayidx.us = getelementptr inbounds double, double* %incdec.ptr2, i64 %iy.0320.us
  store double 0.000000e+00, double* %arrayidx.us, align 8, !tbaa !0
  %arrayidx22.us = getelementptr inbounds double, double* %incdec.ptr3, i64 %iy.0320.us
  store double 0.000000e+00, double* %arrayidx22.us, align 8, !tbaa !0
  br i1 %cmp26.313, label %if.end.75.loopexit309.us, label %for.body.28.lr.ph.us

if.end.75.loopexit309.us:                         ; preds = %if.end.75.loopexit309.us.loopexit, %for.body.us
  %3 = load double, double* %alpha, align 8, !tbaa !0
  %4 = load double, double* %arrayidx.us, align 8, !tbaa !0
  %mul77.us = fmul double %3, %4
  %5 = load double, double* %beta, align 8, !tbaa !0
  %arrayidx78.us = getelementptr inbounds double, double* %incdec.ptr1, i64 %iy.0320.us
  %6 = load double, double* %arrayidx78.us, align 8, !tbaa !0
  %mul79.us = fmul double %5, %6
  %add80.us = fadd double %mul77.us, %mul79.us
  store double %add80.us, double* %arrayidx.us, align 8, !tbaa !0
  %7 = load double, double* %alpha, align 8, !tbaa !0
  %cmp82.us = fcmp oge double %7, 0.000000e+00
  %sub86.us = fsub double -0.000000e+00, %7
  %cond88.us = select i1 %cmp82.us, double %7, double %sub86.us
  %8 = load double, double* %arrayidx22.us, align 8, !tbaa !0
  %mul90.us = fmul double %8, %cond88.us
  %9 = load double, double* %beta, align 8, !tbaa !0
  %10 = load double, double* %arrayidx78.us, align 8, !tbaa !0
  %mul92.us = fmul double %9, %10
  %cmp93.us = fcmp oge double %mul92.us, 0.000000e+00
  %sub97.us = fsub double -0.000000e+00, %mul92.us
  %cond99.us = select i1 %cmp93.us, double %mul92.us, double %sub97.us
  %add100.us = fadd double %mul90.us, %cond99.us
  store double %add100.us, double* %arrayidx22.us, align 8, !tbaa !0
  %add102.us = add nsw i64 %iy.0320.us, %0
  %inc104.us = add nsw i64 %inc104321.us, 1
  %cmp20.us = icmp slt i64 %inc104321.us, %ml.0
  br i1 %cmp20.us, label %for.body.us, label %for.cond.for.end.105_crit_edge.loopexit.exitStub

for.body.28.lr.ph.us:                             ; preds = %for.body.us
  %mul.us = mul nsw i64 %inc104321.us, %1
  %mul35.us = mul nsw i64 %inc104321.us, %1
  br label %for.body.28.us

for.body.28.us:                                   ; preds = %for.body.28.us, %for.body.28.lr.ph.us
  %jx.0315.us = phi i64 [ %nl.0., %for.body.28.lr.ph.us ], [ %add44.us, %for.body.28.us ]
  %j.0314.us = phi i64 [ 1, %for.body.28.lr.ph.us ], [ %inc.us, %for.body.28.us ]
  %add29.us = add nsw i64 %j.0314.us, %mul.us
  %arrayidx30.us = getelementptr inbounds double, double* %add.ptr, i64 %add29.us
  %11 = load double, double* %arrayidx30.us, align 8, !tbaa !0
  %arrayidx31.us = getelementptr inbounds double, double* %incdec.ptr, i64 %jx.0315.us
  %12 = load double, double* %arrayidx31.us, align 8, !tbaa !0
  %mul32.us = fmul double %11, %12
  %13 = load double, double* %arrayidx.us, align 8, !tbaa !0
  %add34.us = fadd double %13, %mul32.us
  store double %add34.us, double* %arrayidx.us, align 8, !tbaa !0
  %add36.us = add nsw i64 %j.0314.us, %mul35.us
  %arrayidx37.us = getelementptr inbounds double, double* %add.ptr, i64 %add36.us
  %14 = load double, double* %arrayidx37.us, align 8, !tbaa !0
  %15 = load double, double* %arrayidx31.us, align 8, !tbaa !0
  %mul39.us = fmul double %14, %15
  %cmp40.us = fcmp oge double %mul39.us, 0.000000e+00
  %sub.us = fsub double -0.000000e+00, %mul39.us
  %cond.us = select i1 %cmp40.us, double %mul39.us, double %sub.us
  %16 = load double, double* %arrayidx22.us, align 8, !tbaa !0
  %add43.us = fadd double %16, %cond.us
  store double %add43.us, double* %arrayidx22.us, align 8, !tbaa !0
  %add44.us = add nsw i64 %jx.0315.us, %2
  %inc.us = add nuw nsw i64 %j.0314.us, 1
  %exitcond = icmp eq i64 %j.0314.us, %nl.0
  br i1 %exitcond, label %if.end.75.loopexit309.us.loopexit, label %for.body.28.us

if.end.75.loopexit309.us.loopexit:                ; preds = %for.body.28.us
  br label %if.end.75.loopexit309.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
