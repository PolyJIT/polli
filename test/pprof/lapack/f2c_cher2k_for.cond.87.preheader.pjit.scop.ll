
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'cher2k.c.f2c_cher2k_for.cond.87.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.complex = type { float, float }

; Function Attrs: nounwind
define weak void @f2c_cher2k_for.cond.87.preheader.pjit.scop(i1 %cmp75.2281, %struct.complex* %q__1, i64, float* %beta, %struct.complex* %add.ptr6, i64)  {
newFuncRoot:
  br label %for.cond.87.preheader

cleanup.exitStub:                                 ; preds = %cleanup.loopexit2395, %for.cond.87.preheader
  ret void

for.cond.87.preheader:                            ; preds = %newFuncRoot
  br i1 %cmp75.2281, label %cleanup.exitStub, label %for.cond.90.preheader.lr.ph

for.cond.90.preheader.lr.ph:                      ; preds = %for.cond.87.preheader
  %r100 = getelementptr inbounds %struct.complex, %struct.complex* %q__1, i64 0, i32 0
  %i104 = getelementptr inbounds %struct.complex, %struct.complex* %q__1, i64 0, i32 1
  br label %for.cond.90.preheader

for.cond.90.preheader:                            ; preds = %for.end.113, %for.cond.90.preheader.lr.ph
  %indvars.iv2363 = phi i64 [ %indvars.iv.next2364, %for.end.113 ], [ 1, %for.cond.90.preheader.lr.ph ]
  %cmp91.2284 = icmp sgt i64 %indvars.iv2363, 1
  %mul93 = mul nsw i64 %indvars.iv2363, %0
  br i1 %cmp91.2284, label %for.body.92.preheader, label %for.end.113

for.body.92.preheader:                            ; preds = %for.cond.90.preheader
  br label %for.body.92

for.body.92:                                      ; preds = %for.body.92, %for.body.92.preheader
  %i__.12285 = phi i64 [ %inc112, %for.body.92 ], [ 1, %for.body.92.preheader ]
  %add94 = add nsw i64 %i__.12285, %mul93
  %2 = load float, float* %beta, align 4, !tbaa !0
  %arrayidx97 = getelementptr inbounds %struct.complex, %struct.complex* %add.ptr6, i64 %add94
  %r98 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx97, i64 0, i32 0
  %3 = load float, float* %r98, align 4, !tbaa !4
  %mul99 = fmul float %2, %3
  store float %mul99, float* %r100, align 4, !tbaa !4
  %i102 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx97, i64 0, i32 1
  %4 = load float, float* %i102, align 4, !tbaa !6
  %mul103 = fmul float %2, %4
  %5 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx97, i64 0, i32 0
  store float %mul99, float* %5, align 4, !tbaa !4
  store float %mul103, float* %i102, align 4, !tbaa !6
  %inc112 = add nuw nsw i64 %i__.12285, 1
  %exitcond2365 = icmp eq i64 %inc112, %indvars.iv2363
  br i1 %exitcond2365, label %for.cond.90.for.end.113_crit_edge, label %for.body.92

for.cond.90.for.end.113_crit_edge:                ; preds = %for.body.92
  %mul103.lcssa = phi float [ %mul103, %for.body.92 ]
  store float %mul103.lcssa, float* %i104, align 4, !tbaa !6
  br label %for.end.113

for.end.113:                                      ; preds = %for.cond.90.for.end.113_crit_edge, %for.cond.90.preheader
  %add115 = add nsw i64 %mul93, %indvars.iv2363
  %6 = load float, float* %beta, align 4, !tbaa !0
  %arrayidx118 = getelementptr inbounds %struct.complex, %struct.complex* %add.ptr6, i64 %add115
  %r119 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx118, i64 0, i32 0
  %7 = load float, float* %r119, align 4, !tbaa !4
  %mul120 = fmul float %6, %7
  store float %mul120, float* %r119, align 4, !tbaa !4
  %i124 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx118, i64 0, i32 1
  store float 0.000000e+00, float* %i124, align 4, !tbaa !6
  %indvars.iv.next2364 = add nuw nsw i64 %indvars.iv2363, 1
  %exitcond2366 = icmp eq i64 %indvars.iv2363, %1
  br i1 %exitcond2366, label %cleanup.loopexit2395, label %for.cond.90.preheader

cleanup.loopexit2395:                             ; preds = %for.end.113
  br label %cleanup.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !1, i64 0}
!5 = !{!"", !1, i64 0, !1, i64 4}
!6 = !{!5, !1, i64 4}
