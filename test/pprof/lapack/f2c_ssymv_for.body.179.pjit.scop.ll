
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'ssymv.c.f2c_ssymv_for.body.179.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_ssymv_for.body.179.pjit.scop(float* %alpha, float* %incdec.ptr, i64, float* %add.ptr, float* %incdec.ptr1, i64, i64)  {
newFuncRoot:
  br label %for.body.179

cleanup.loopexit.exitStub:                        ; preds = %for.end.206
  ret void

for.body.179:                                     ; preds = %for.end.206, %newFuncRoot
  %j.2506 = phi i64 [ 1, %newFuncRoot ], [ %add188, %for.end.206 ]
  %3 = load float, float* %alpha, align 4, !tbaa !0
  %arrayidx180 = getelementptr inbounds float, float* %incdec.ptr, i64 %j.2506
  %4 = load float, float* %arrayidx180, align 4, !tbaa !0
  %mul181 = fmul float %3, %4
  %mul182 = mul nsw i64 %j.2506, %0
  %add183 = add nsw i64 %mul182, %j.2506
  %arrayidx184 = getelementptr inbounds float, float* %add.ptr, i64 %add183
  %5 = load float, float* %arrayidx184, align 4, !tbaa !0
  %mul185 = fmul float %mul181, %5
  %arrayidx186 = getelementptr inbounds float, float* %incdec.ptr1, i64 %j.2506
  %6 = load float, float* %arrayidx186, align 4, !tbaa !0
  %add187 = fadd float %6, %mul185
  store float %add187, float* %arrayidx186, align 4, !tbaa !0
  %add188 = add nuw nsw i64 %j.2506, 1
  %cmp190.502 = icmp slt i64 %j.2506, %1
  br i1 %cmp190.502, label %for.body.191.preheader, label %for.end.206

for.body.191.preheader:                           ; preds = %for.body.179
  br label %for.body.191

for.body.191:                                     ; preds = %for.body.191, %for.body.191.preheader
  %temp2.2504 = phi float [ %add203, %for.body.191 ], [ 0.000000e+00, %for.body.191.preheader ]
  %i__.6503 = phi i64 [ %inc205, %for.body.191 ], [ %add188, %for.body.191.preheader ]
  %add193 = add nsw i64 %i__.6503, %mul182
  %arrayidx194 = getelementptr inbounds float, float* %add.ptr, i64 %add193
  %7 = load float, float* %arrayidx194, align 4, !tbaa !0
  %mul195 = fmul float %mul181, %7
  %arrayidx196 = getelementptr inbounds float, float* %incdec.ptr1, i64 %i__.6503
  %8 = load float, float* %arrayidx196, align 4, !tbaa !0
  %add197 = fadd float %8, %mul195
  store float %add197, float* %arrayidx196, align 4, !tbaa !0
  %9 = load float, float* %arrayidx194, align 4, !tbaa !0
  %arrayidx201 = getelementptr inbounds float, float* %incdec.ptr, i64 %i__.6503
  %10 = load float, float* %arrayidx201, align 4, !tbaa !0
  %mul202 = fmul float %9, %10
  %add203 = fadd float %temp2.2504, %mul202
  %inc205 = add nuw nsw i64 %i__.6503, 1
  %exitcond = icmp eq i64 %i__.6503, %1
  br i1 %exitcond, label %for.end.206.loopexit, label %for.body.191

for.end.206.loopexit:                             ; preds = %for.body.191
  %add203.lcssa = phi float [ %add203, %for.body.191 ]
  br label %for.end.206

for.end.206:                                      ; preds = %for.end.206.loopexit, %for.body.179
  %temp2.2.lcssa = phi float [ 0.000000e+00, %for.body.179 ], [ %add203.lcssa, %for.end.206.loopexit ]
  %11 = load float, float* %alpha, align 4, !tbaa !0
  %mul207 = fmul float %temp2.2.lcssa, %11
  %12 = load float, float* %arrayidx186, align 4, !tbaa !0
  %add209 = fadd float %12, %mul207
  store float %add209, float* %arrayidx186, align 4, !tbaa !0
  %exitcond549 = icmp eq i64 %j.2506, %2
  br i1 %exitcond549, label %cleanup.loopexit.exitStub, label %for.body.179
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
