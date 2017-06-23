
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/447.dealII/src/fe_tools.cc._ZNK10FullMatrixIdE5vmultIfEEvR6VectorIT_ERKS4_b_for.cond.715.preheader.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.Vector.125 = type { i32 (...)**, i32, i32, float* }

; Function Attrs: nounwind
define weak void @_ZNK10FullMatrixIdE5vmultIfEEvR6VectorIT_ERKS4_b_for.cond.715.preheader.lr.ph.pjit.scop(i32, %class.Vector.125* %dst, %class.Vector.125* %src, i32, double*)  {
newFuncRoot:
  br label %for.cond.715.preheader.lr.ph

if.end.737.exitStub:                              ; preds = %if.end.737.loopexit1216, %if.end.737.loopexit
  ret void

for.cond.715.preheader.lr.ph:                     ; preds = %newFuncRoot
  %cmp716.1175 = icmp eq i32 %0, 0
  %val.i.998 = getelementptr inbounds %class.Vector.125, %class.Vector.125* %dst, i64 0, i32 3
  %3 = load float*, float** %val.i.998, align 8, !tbaa !0
  %val.i = getelementptr inbounds %class.Vector.125, %class.Vector.125* %src, i64 0, i32 3
  %4 = load float*, float** %val.i, align 8, !tbaa !0
  br i1 %cmp716.1175, label %for.cond.cleanup.717.preheader, label %for.body.718.lr.ph.us.preheader

for.cond.cleanup.717.preheader:                   ; preds = %for.cond.715.preheader.lr.ph
  br label %for.cond.cleanup.717

for.cond.cleanup.717:                             ; preds = %for.cond.cleanup.717, %for.cond.cleanup.717.preheader
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.cond.cleanup.717 ], [ 0, %for.cond.cleanup.717.preheader ]
  %arrayidx.i.999 = getelementptr inbounds float, float* %3, i64 %indvars.iv
  %5 = load float, float* %arrayidx.i.999, align 4, !tbaa !6
  %add730 = fadd float %5, 0.000000e+00
  store float %add730, float* %arrayidx.i.999, align 4, !tbaa !6
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv1218 = trunc i64 %indvars.iv.next to i32
  %exitcond1219 = icmp eq i32 %lftr.wideiv1218, %1
  br i1 %exitcond1219, label %if.end.737.loopexit, label %for.cond.cleanup.717

if.end.737.loopexit:                              ; preds = %for.cond.cleanup.717
  br label %if.end.737.exitStub

for.body.718.lr.ph.us.preheader:                  ; preds = %for.cond.715.preheader.lr.ph
  %6 = add i32 %0, -1
  %7 = zext i32 %6 to i64
  %8 = add nuw nsw i64 %7, 1
  br label %for.body.718.lr.ph.us

for.body.718.lr.ph.us:                            ; preds = %for.cond.715.for.cond.cleanup.717_crit_edge.us, %for.body.718.lr.ph.us.preheader
  %indvars.iv1199 = phi i64 [ 0, %for.body.718.lr.ph.us.preheader ], [ %indvars.iv.next1200, %for.cond.715.for.cond.cleanup.717_crit_edge.us ]
  %e.21181.us = phi double* [ %2, %for.body.718.lr.ph.us.preheader ], [ %scevgep, %for.cond.715.for.cond.cleanup.717_crit_edge.us ]
  br label %for.body.718.us

for.body.718.us:                                  ; preds = %for.body.718.us, %for.body.718.lr.ph.us
  %indvars.iv1195 = phi i64 [ 0, %for.body.718.lr.ph.us ], [ %indvars.iv.next1196, %for.body.718.us ]
  %s713.01177.us = phi float [ 0.000000e+00, %for.body.718.lr.ph.us ], [ %conv725.us, %for.body.718.us ]
  %e.31176.us = phi double* [ %e.21181.us, %for.body.718.lr.ph.us ], [ %incdec.ptr721.us, %for.body.718.us ]
  %arrayidx.i.us = getelementptr inbounds float, float* %4, i64 %indvars.iv1195
  %9 = load float, float* %arrayidx.i.us, align 4, !tbaa !6
  %conv720.us = fpext float %9 to double
  %incdec.ptr721.us = getelementptr inbounds double, double* %e.31176.us, i64 1
  %10 = load double, double* %e.31176.us, align 8, !tbaa !8
  %mul722.us = fmul double %conv720.us, %10
  %conv723.us = fpext float %s713.01177.us to double
  %add724.us = fadd double %conv723.us, %mul722.us
  %conv725.us = fptrunc double %add724.us to float
  %indvars.iv.next1196 = add nuw nsw i64 %indvars.iv1195, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next1196 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %0
  br i1 %exitcond, label %for.cond.715.for.cond.cleanup.717_crit_edge.us, label %for.body.718.us

for.cond.715.for.cond.cleanup.717_crit_edge.us:   ; preds = %for.body.718.us
  %conv725.us.lcssa = phi float [ %conv725.us, %for.body.718.us ]
  %scevgep = getelementptr double, double* %e.21181.us, i64 %8
  %arrayidx.i.999.us = getelementptr inbounds float, float* %3, i64 %indvars.iv1199
  %11 = load float, float* %arrayidx.i.999.us, align 4, !tbaa !6
  %add730.us = fadd float %conv725.us.lcssa, %11
  store float %add730.us, float* %arrayidx.i.999.us, align 4, !tbaa !6
  %indvars.iv.next1200 = add nuw nsw i64 %indvars.iv1199, 1
  %lftr.wideiv1220 = trunc i64 %indvars.iv.next1200 to i32
  %exitcond1221 = icmp eq i32 %lftr.wideiv1220, %1
  br i1 %exitcond1221, label %if.end.737.loopexit1216, label %for.body.718.lr.ph.us

if.end.737.loopexit1216:                          ; preds = %for.cond.715.for.cond.cleanup.717_crit_edge.us
  br label %if.end.737.exitStub
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
!8 = !{!9, !9, i64 0}
!9 = !{!"double", !3, i64 0}
