
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'LULESH_OMP.cc.main_for.body.187.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.Domain = type { %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector.0", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", %"class.std::vector", double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, i32, i32, i32, i32, i32, i32 }
%"class.std::vector.0" = type { %"struct.std::_Vector_base.1" }
%"struct.std::_Vector_base.1" = type { %"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl" }
%"struct.std::_Vector_base<int, std::allocator<int> >::_Vector_impl" = type { i32*, i32*, i32* }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl" }
%"struct.std::_Vector_base<double, std::allocator<double> >::_Vector_impl" = type { double*, double*, double* }

define weak void @main_for.body.187.lr.ph.pjit.scop(i32 %conv.i, i64 %call.i, i32 %add, %struct.Domain* nonnull %domain)  {
newFuncRoot:
  br label %for.body.187.lr.ph

for.cond.cleanup.186.exitStub:                    ; preds = %for.cond.cleanup.186.loopexit, %for.body.187.lr.ph
  ret void

for.body.187.lr.ph:                               ; preds = %newFuncRoot
  %cmp193.757 = icmp slt i32 %conv.i, 0
  %0 = getelementptr inbounds %struct.Domain, %struct.Domain* %domain, i64 0, i32 13, i32 0, i32 0, i32 0
  %1 = load i32*, i32** %0
  %2 = getelementptr inbounds %struct.Domain, %struct.Domain* %domain, i64 0, i32 14, i32 0, i32 0, i32 0
  %3 = load i32*, i32** %2
  %4 = getelementptr inbounds %struct.Domain, %struct.Domain* %domain, i64 0, i32 15, i32 0, i32 0, i32 0
  %5 = load i32*, i32** %4
  br i1 %cmp193.757, label %for.cond.cleanup.186.exitStub, label %for.body.187.preheader

for.body.187.preheader:                           ; preds = %for.body.187.lr.ph
  %6 = trunc i64 %call.i to i32
  %7 = add i32 %6, 1
  %8 = trunc i64 %call.i to i32
  br label %for.body.187

for.body.187:                                     ; preds = %for.cond.cleanup.194, %for.body.187.preheader
  %nidx.6763 = phi i32 [ %10, %for.cond.cleanup.194 ], [ 0, %for.body.187.preheader ]
  %i183.0762 = phi i32 [ %inc208, %for.cond.cleanup.194 ], [ 0, %for.body.187.preheader ]
  %mul188 = mul nsw i32 %i183.0762, %add
  %mul189 = mul nsw i32 %mul188, %add
  %9 = sext i32 %nidx.6763 to i64
  br label %for.body.195

for.body.195:                                     ; preds = %for.body.195, %for.body.187
  %indvars.iv847 = phi i64 [ %indvars.iv.next848, %for.body.195 ], [ %9, %for.body.187 ]
  %j191.0758 = phi i32 [ %inc205, %for.body.195 ], [ 0, %for.body.187 ]
  %mul196 = mul nsw i32 %j191.0758, %add
  %add197 = add nsw i32 %mul196, %mul189
  %add.ptr.i.i.698 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv847
  store i32 %add197, i32* %add.ptr.i.i.698, align 4, !tbaa !0
  %add199 = add nsw i32 %j191.0758, %mul189
  %add.ptr.i.i.696 = getelementptr inbounds i32, i32* %3, i64 %indvars.iv847
  store i32 %add199, i32* %add.ptr.i.i.696, align 4, !tbaa !0
  %add201 = add nsw i32 %j191.0758, %mul188
  %add.ptr.i.i.694 = getelementptr inbounds i32, i32* %5, i64 %indvars.iv847
  store i32 %add201, i32* %add.ptr.i.i.694, align 4, !tbaa !0
  %inc205 = add nuw nsw i32 %j191.0758, 1
  %indvars.iv.next848 = add nsw i64 %indvars.iv847, 1
  %exitcond849 = icmp eq i32 %inc205, %7
  br i1 %exitcond849, label %for.cond.cleanup.194, label %for.body.195

for.cond.cleanup.194:                             ; preds = %for.body.195
  %10 = add i32 %nidx.6763, %7
  %inc208 = add nuw nsw i32 %i183.0762, 1
  %exitcond850 = icmp eq i32 %i183.0762, %8
  br i1 %exitcond850, label %for.cond.cleanup.186.loopexit, label %for.body.187

for.cond.cleanup.186.loopexit:                    ; preds = %for.cond.cleanup.194
  br label %for.cond.cleanup.186.exitStub
}

attributes #0 = { "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
