
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'csymm.c.f2c_csymm_for.body.98.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.complex = type { float, float }

; Function Attrs: nounwind
define weak void @f2c_csymm_for.body.98.lr.ph.pjit.scop(i64, float* %r75, %struct.complex* %add.ptr6, float* %i107, i64, i64)  {
newFuncRoot:
  br label %for.body.98.lr.ph

cleanup.loopexit1866.exitStub:                    ; preds = %for.inc.131
  ret void

for.body.98.lr.ph:                                ; preds = %for.inc.131, %newFuncRoot
  %j.11792 = phi i64 [ %inc132, %for.inc.131 ], [ 1, %newFuncRoot ]
  %mul99 = mul nsw i64 %j.11792, %0
  br label %for.body.98

for.body.98:                                      ; preds = %for.body.98, %for.body.98.lr.ph
  %i__.11790 = phi i64 [ 1, %for.body.98.lr.ph ], [ %inc129, %for.body.98 ]
  %add100 = add nsw i64 %i__.11790, %mul99
  %3 = load float, float* %r75, align 4, !tbaa !0
  %arrayidx104 = getelementptr inbounds %struct.complex, %struct.complex* %add.ptr6, i64 %add100
  %r105 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx104, i64 0, i32 0
  %4 = load float, float* %r105, align 4, !tbaa !0
  %mul106 = fmul float %3, %4
  %5 = load float, float* %i107, align 4, !tbaa !5
  %i109 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx104, i64 0, i32 1
  %6 = load float, float* %i109, align 4, !tbaa !5
  %mul110 = fmul float %5, %6
  %sub = fsub float %mul106, %mul110
  %mul115 = fmul float %3, %6
  %mul119 = fmul float %4, %5
  %add120 = fadd float %mul119, %mul115
  store float %sub, float* %r105, align 4, !tbaa !0
  store float %add120, float* %i109, align 4, !tbaa !5
  %inc129 = add nuw nsw i64 %i__.11790, 1
  %exitcond1846 = icmp eq i64 %i__.11790, %1
  br i1 %exitcond1846, label %for.inc.131, label %for.body.98

for.inc.131:                                      ; preds = %for.body.98
  %inc132 = add nuw nsw i64 %j.11792, 1
  %exitcond1847 = icmp eq i64 %j.11792, %2
  br i1 %exitcond1847, label %cleanup.loopexit1866.exitStub, label %for.body.98.lr.ph
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 0}
!1 = !{!"", !2, i64 0, !2, i64 4}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!1, !2, i64 4}
