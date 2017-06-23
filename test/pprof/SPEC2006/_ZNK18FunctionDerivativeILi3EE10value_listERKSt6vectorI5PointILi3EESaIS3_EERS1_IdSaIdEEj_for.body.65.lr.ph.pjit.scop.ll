; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli-process-unprofitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 2 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/447.dealII/src/function_derivative.cc._ZNK18FunctionDerivativeILi3EE10value_listERKSt6vectorI5PointILi3EESaIS3_EERS1_IdSaIdEEj_for.body.65.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.Point.23 = type { %class.Tensor.24 }
%class.Tensor.24 = type { [3 x double] }
%"class.std::vector.18" = type { %"struct.std::_Vector_base.19" }
%"struct.std::_Vector_base.19" = type { %"struct.std::_Vector_base<Point<3>, std::allocator<Point<3> > >::_Vector_impl" }
%"struct.std::_Vector_base<Point<3>, std::allocator<Point<3> > >::_Vector_impl" = type { %class.Point.23*, %class.Point.23*, %class.Point.23* }

define weak void @_ZNK18FunctionDerivativeILi3EE10value_listERKSt6vectorI5PointILi3EESaIS3_EERS1_IdSaIdEEj_for.body.65.lr.ph.pjit.scop(%class.Point.23** %_M_start.i.i.i.508, %"class.std::vector.18"* %incr, i1, i64 %sub.ptr.div.i)  {
newFuncRoot:
  br label %for.body.65.lr.ph

for.cond.cleanup.64.exitStub:                     ; preds = %for.cond.cleanup.64.loopexit898, %for.cond.cleanup.64.loopexit
  ret void

for.body.65.lr.ph:                                ; preds = %newFuncRoot
  %1 = load %class.Point.23*, %class.Point.23** %_M_start.i.i.i.508, align 8, !tbaa !0
  %_M_start.i.564 = getelementptr inbounds %"class.std::vector.18", %"class.std::vector.18"* %incr, i64 0, i32 0, i32 0, i32 0
  %2 = load %class.Point.23*, %class.Point.23** %_M_start.i.564, align 8, !tbaa !0
  br i1 %0, label %for.body.65.us.preheader, label %for.body.65.preheader

for.body.65.us.preheader:                         ; preds = %for.body.65.lr.ph
  %3 = trunc i64 %sub.ptr.div.i to i32
  br label %for.body.65.us

for.body.65.us:                                   ; preds = %for.body.65.us, %for.body.65.us.preheader
  %indvars.iv872 = phi i64 [ %indvars.iv.next873, %for.body.65.us ], [ 0, %for.body.65.us.preheader ]
  %arrayidx.i.580.us = getelementptr inbounds %class.Point.23, %class.Point.23* %2, i64 %indvars.iv872, i32 0, i32 0, i64 0
  %4 = load double, double* %arrayidx.i.580.us, align 8, !tbaa !6
  %arrayidx4.i.581.us = getelementptr inbounds %class.Point.23, %class.Point.23* %1, i64 %indvars.iv872, i32 0, i32 0, i64 0
  %5 = load double, double* %arrayidx4.i.581.us, align 8, !tbaa !6
  %sub.i.582.us = fsub double %5, %4
  store double %sub.i.582.us, double* %arrayidx4.i.581.us, align 8, !tbaa !6
  %arrayidx.1.i.583.us = getelementptr inbounds %class.Point.23, %class.Point.23* %2, i64 %indvars.iv872, i32 0, i32 0, i64 1
  %6 = load double, double* %arrayidx.1.i.583.us, align 8, !tbaa !6
  %arrayidx4.1.i.584.us = getelementptr inbounds %class.Point.23, %class.Point.23* %1, i64 %indvars.iv872, i32 0, i32 0, i64 1
  %7 = load double, double* %arrayidx4.1.i.584.us, align 8, !tbaa !6
  %sub.1.i.585.us = fsub double %7, %6
  store double %sub.1.i.585.us, double* %arrayidx4.1.i.584.us, align 8, !tbaa !6
  %arrayidx.2.i.586.us = getelementptr inbounds %class.Point.23, %class.Point.23* %2, i64 %indvars.iv872, i32 0, i32 0, i64 2
  %8 = load double, double* %arrayidx.2.i.586.us, align 8, !tbaa !6
  %arrayidx4.2.i.587.us = getelementptr inbounds %class.Point.23, %class.Point.23* %1, i64 %indvars.iv872, i32 0, i32 0, i64 2
  %9 = load double, double* %arrayidx4.2.i.587.us, align 8, !tbaa !6
  %sub.2.i.588.us = fsub double %9, %8
  store double %sub.2.i.588.us, double* %arrayidx4.2.i.587.us, align 8, !tbaa !6
  %indvars.iv.next873 = add nuw nsw i64 %indvars.iv872, 1
  %lftr.wideiv911 = trunc i64 %indvars.iv.next873 to i32
  %exitcond912 = icmp eq i32 %lftr.wideiv911, %3
  br i1 %exitcond912, label %for.cond.cleanup.64.loopexit, label %for.body.65.us

for.cond.cleanup.64.loopexit:                     ; preds = %for.body.65.us
  br label %for.cond.cleanup.64.exitStub

for.body.65.preheader:                            ; preds = %for.body.65.lr.ph
  %10 = trunc i64 %sub.ptr.div.i to i32
  br label %for.body.65

for.body.65:                                      ; preds = %for.body.65, %for.body.65.preheader
  %indvars.iv876 = phi i64 [ %indvars.iv.next877, %for.body.65 ], [ 0, %for.body.65.preheader ]
  %arrayidx.i.580 = getelementptr inbounds %class.Point.23, %class.Point.23* %2, i64 0, i32 0, i32 0, i64 0
  %11 = load double, double* %arrayidx.i.580, align 8, !tbaa !6
  %arrayidx4.i.581 = getelementptr inbounds %class.Point.23, %class.Point.23* %1, i64 %indvars.iv876, i32 0, i32 0, i64 0
  %12 = load double, double* %arrayidx4.i.581, align 8, !tbaa !6
  %sub.i.582 = fsub double %12, %11
  store double %sub.i.582, double* %arrayidx4.i.581, align 8, !tbaa !6
  %arrayidx.1.i.583 = getelementptr inbounds %class.Point.23, %class.Point.23* %2, i64 0, i32 0, i32 0, i64 1
  %13 = load double, double* %arrayidx.1.i.583, align 8, !tbaa !6
  %arrayidx4.1.i.584 = getelementptr inbounds %class.Point.23, %class.Point.23* %1, i64 %indvars.iv876, i32 0, i32 0, i64 1
  %14 = load double, double* %arrayidx4.1.i.584, align 8, !tbaa !6
  %sub.1.i.585 = fsub double %14, %13
  store double %sub.1.i.585, double* %arrayidx4.1.i.584, align 8, !tbaa !6
  %arrayidx.2.i.586 = getelementptr inbounds %class.Point.23, %class.Point.23* %2, i64 0, i32 0, i32 0, i64 2
  %15 = load double, double* %arrayidx.2.i.586, align 8, !tbaa !6
  %arrayidx4.2.i.587 = getelementptr inbounds %class.Point.23, %class.Point.23* %1, i64 %indvars.iv876, i32 0, i32 0, i64 2
  %16 = load double, double* %arrayidx4.2.i.587, align 8, !tbaa !6
  %sub.2.i.588 = fsub double %16, %15
  store double %sub.2.i.588, double* %arrayidx4.2.i.587, align 8, !tbaa !6
  %indvars.iv.next877 = add nuw nsw i64 %indvars.iv876, 1
  %lftr.wideiv913 = trunc i64 %indvars.iv.next877 to i32
  %exitcond914 = icmp eq i32 %lftr.wideiv913, %10
  br i1 %exitcond914, label %for.cond.cleanup.64.loopexit898, label %for.body.65

for.cond.cleanup.64.loopexit898:                  ; preds = %for.body.65
  br label %for.cond.cleanup.64.exitStub
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !3, i64 0}
!1 = !{!"_ZTSSt12_Vector_baseI5PointILi3EESaIS1_EE", !2, i64 0}
!2 = !{!"_ZTSNSt12_Vector_baseI5PointILi3EESaIS1_EE12_Vector_implE", !3, i64 0, !3, i64 8, !3, i64 16}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"double", !4, i64 0}
