
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/447.dealII/src/full_matrix.float.cc._ZNK10FullMatrixIfE5vmultIfEEvR6VectorIT_ERKS4_b_for.cond.461.preheader.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.Vector.11 = type { i32 (...)**, i32, i32, float* }

; Function Attrs: nounwind
define weak void @_ZNK10FullMatrixIfE5vmultIfEEvR6VectorIT_ERKS4_b_for.cond.461.preheader.lr.ph.pjit.scop(i32, %class.Vector.11* %dst, %class.Vector.11* %src, i32, float*)  {
newFuncRoot:
  br label %for.cond.461.preheader.lr.ph

if.end.480.exitStub:                              ; preds = %if.end.480.loopexit959, %if.end.480.loopexit
  ret void

for.cond.461.preheader.lr.ph:                     ; preds = %newFuncRoot
  %cmp462.918 = icmp eq i32 %0, 0
  %val.i.741 = getelementptr inbounds %class.Vector.11, %class.Vector.11* %dst, i64 0, i32 3
  %3 = load float*, float** %val.i.741, align 8, !tbaa !0
  %val.i = getelementptr inbounds %class.Vector.11, %class.Vector.11* %src, i64 0, i32 3
  %4 = load float*, float** %val.i, align 8, !tbaa !0
  br i1 %cmp462.918, label %for.cond.cleanup.463.preheader, label %for.body.464.lr.ph.us.preheader

for.cond.cleanup.463.preheader:                   ; preds = %for.cond.461.preheader.lr.ph
  br label %for.cond.cleanup.463

for.cond.cleanup.463:                             ; preds = %for.cond.cleanup.463, %for.cond.cleanup.463.preheader
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.cond.cleanup.463 ], [ 0, %for.cond.cleanup.463.preheader ]
  %arrayidx.i.742 = getelementptr inbounds float, float* %3, i64 %indvars.iv
  %5 = load float, float* %arrayidx.i.742, align 4, !tbaa !6
  %add473 = fadd float %5, 0.000000e+00
  store float %add473, float* %arrayidx.i.742, align 4, !tbaa !6
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv961 = trunc i64 %indvars.iv.next to i32
  %exitcond962 = icmp eq i32 %lftr.wideiv961, %1
  br i1 %exitcond962, label %if.end.480.loopexit, label %for.cond.cleanup.463

if.end.480.loopexit:                              ; preds = %for.cond.cleanup.463
  br label %if.end.480.exitStub

for.body.464.lr.ph.us.preheader:                  ; preds = %for.cond.461.preheader.lr.ph
  %6 = add i32 %0, -1
  %7 = zext i32 %6 to i64
  %8 = add nuw nsw i64 %7, 1
  br label %for.body.464.lr.ph.us

for.body.464.lr.ph.us:                            ; preds = %for.cond.461.for.cond.cleanup.463_crit_edge.us, %for.body.464.lr.ph.us.preheader
  %indvars.iv942 = phi i64 [ 0, %for.body.464.lr.ph.us.preheader ], [ %indvars.iv.next943, %for.cond.461.for.cond.cleanup.463_crit_edge.us ]
  %e.2924.us = phi float* [ %2, %for.body.464.lr.ph.us.preheader ], [ %scevgep, %for.cond.461.for.cond.cleanup.463_crit_edge.us ]
  br label %for.body.464.us

for.body.464.us:                                  ; preds = %for.body.464.us, %for.body.464.lr.ph.us
  %indvars.iv938 = phi i64 [ 0, %for.body.464.lr.ph.us ], [ %indvars.iv.next939, %for.body.464.us ]
  %s459.0920.us = phi float [ 0.000000e+00, %for.body.464.lr.ph.us ], [ %add468.us, %for.body.464.us ]
  %e.3919.us = phi float* [ %e.2924.us, %for.body.464.lr.ph.us ], [ %incdec.ptr466.us, %for.body.464.us ]
  %arrayidx.i.us = getelementptr inbounds float, float* %4, i64 %indvars.iv938
  %9 = load float, float* %arrayidx.i.us, align 4, !tbaa !6
  %incdec.ptr466.us = getelementptr inbounds float, float* %e.3919.us, i64 1
  %10 = load float, float* %e.3919.us, align 4, !tbaa !6
  %mul467.us = fmul float %9, %10
  %add468.us = fadd float %s459.0920.us, %mul467.us
  %indvars.iv.next939 = add nuw nsw i64 %indvars.iv938, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next939 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %0
  br i1 %exitcond, label %for.cond.461.for.cond.cleanup.463_crit_edge.us, label %for.body.464.us

for.cond.461.for.cond.cleanup.463_crit_edge.us:   ; preds = %for.body.464.us
  %add468.us.lcssa = phi float [ %add468.us, %for.body.464.us ]
  %scevgep = getelementptr float, float* %e.2924.us, i64 %8
  %arrayidx.i.742.us = getelementptr inbounds float, float* %3, i64 %indvars.iv942
  %11 = load float, float* %arrayidx.i.742.us, align 4, !tbaa !6
  %add473.us = fadd float %add468.us.lcssa, %11
  store float %add473.us, float* %arrayidx.i.742.us, align 4, !tbaa !6
  %indvars.iv.next943 = add nuw nsw i64 %indvars.iv942, 1
  %lftr.wideiv963 = trunc i64 %indvars.iv.next943 to i32
  %exitcond964 = icmp eq i32 %lftr.wideiv963, %1
  br i1 %exitcond964, label %if.end.480.loopexit959, label %for.body.464.lr.ph.us

if.end.480.loopexit959:                           ; preds = %for.cond.461.for.cond.cleanup.463_crit_edge.us
  br label %if.end.480.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !5, i64 16}
!1 = !{!"_ZTS6VectorIfE", !2, i64 8, !2, i64 12, !5, i64 16}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!"any pointer", !3, i64 0}
!6 = !{!7, !7, i64 0}
!7 = !{!"float", !3, i64 0}
