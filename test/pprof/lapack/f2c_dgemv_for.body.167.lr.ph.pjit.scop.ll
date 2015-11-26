
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'dgemv.c.f2c_dgemv_for.body.167.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_dgemv_for.body.167.lr.ph.pjit.scop(i64 %ky.0, i64, double* %add.ptr, double* %incdec.ptr, i64, double* %alpha, double* %incdec.ptr1, i64, i64)  {
newFuncRoot:
  br label %for.body.167.lr.ph

cleanup.loopexit448.exitStub:                     ; preds = %for.end.176
  ret void

for.body.167.lr.ph:                               ; preds = %for.end.176, %newFuncRoot
  %jy.0391 = phi i64 [ %add180, %for.end.176 ], [ %ky.0, %newFuncRoot ]
  %j.2389 = phi i64 [ %inc182, %for.end.176 ], [ 1, %newFuncRoot ]
  %mul168 = mul nsw i64 %j.2389, %0
  br label %for.body.167

for.body.167:                                     ; preds = %for.body.167, %for.body.167.lr.ph
  %temp.0387 = phi double [ 0.000000e+00, %for.body.167.lr.ph ], [ %add173, %for.body.167 ]
  %i__.6386 = phi i64 [ 1, %for.body.167.lr.ph ], [ %inc175, %for.body.167 ]
  %add169 = add nsw i64 %i__.6386, %mul168
  %arrayidx170 = getelementptr inbounds double, double* %add.ptr, i64 %add169
  %4 = load double, double* %arrayidx170, align 8, !tbaa !0
  %arrayidx171 = getelementptr inbounds double, double* %incdec.ptr, i64 %i__.6386
  %5 = load double, double* %arrayidx171, align 8, !tbaa !0
  %mul172 = fmul double %4, %5
  %add173 = fadd double %temp.0387, %mul172
  %inc175 = add nuw nsw i64 %i__.6386, 1
  %exitcond434 = icmp eq i64 %i__.6386, %1
  br i1 %exitcond434, label %for.end.176, label %for.body.167

for.end.176:                                      ; preds = %for.body.167
  %add173.lcssa = phi double [ %add173, %for.body.167 ]
  %6 = load double, double* %alpha, align 8, !tbaa !0
  %mul177 = fmul double %add173.lcssa, %6
  %arrayidx178 = getelementptr inbounds double, double* %incdec.ptr1, i64 %jy.0391
  %7 = load double, double* %arrayidx178, align 8, !tbaa !0
  %add179 = fadd double %7, %mul177
  store double %add179, double* %arrayidx178, align 8, !tbaa !0
  %add180 = add nsw i64 %jy.0391, %2
  %inc182 = add nuw nsw i64 %j.2389, 1
  %exitcond435 = icmp eq i64 %j.2389, %3
  br i1 %exitcond435, label %cleanup.loopexit448.exitStub, label %for.body.167.lr.ph
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
