
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli-process-unprofitable -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/447.dealII/src/fe_q.cc._ZN4FE_QILi3EE37lexicographic_to_hierarchic_numberingERK17FiniteElementDataILi3EEj_for.body.115.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZN4FE_QILi3EE37lexicographic_to_hierarchic_numberingERK17FiniteElementDataILi3EEj_for.body.115.lr.ph.us.us.pjit.scop(i32 %add90.us, i32 %incy.0.us, i32 %tensorstart91.0.us, i32** %_M_start.i.i.i, i32 %incx.0.us, i32 %degree, i32)  {
newFuncRoot:
  br label %for.body.115.lr.ph.us.us

for.cond.107.for.cond.cleanup.109_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.112.for.cond.cleanup.114_crit_edge.us.us
  ret void

for.body.115.lr.ph.us.us:                         ; preds = %for.cond.112.for.cond.cleanup.114_crit_edge.us.us, %newFuncRoot
  %jy.0332.us.us = phi i32 [ %inc129.us.us, %for.cond.112.for.cond.cleanup.114_crit_edge.us.us ], [ 1, %newFuncRoot ]
  %index88.0331.us.us = phi i32 [ %3, %for.cond.112.for.cond.cleanup.114_crit_edge.us.us ], [ %add90.us, %newFuncRoot ]
  %mul119.us.us = mul i32 %jy.0332.us.us, %incy.0.us
  %add118.us.us = add i32 %mul119.us.us, %tensorstart91.0.us
  %1 = load i32*, i32** %_M_start.i.i.i, align 8, !tbaa !0
  br label %for.body.115.us.us

for.body.115.us.us:                               ; preds = %for.body.115.us.us, %for.body.115.lr.ph.us.us
  %indvars.iv465 = phi i64 [ %indvars.iv.next466, %for.body.115.us.us ], [ 1, %for.body.115.lr.ph.us.us ]
  %index88.1327.us.us = phi i32 [ %inc121.us.us, %for.body.115.us.us ], [ %index88.0331.us.us, %for.body.115.lr.ph.us.us ]
  %2 = trunc i64 %indvars.iv465 to i32
  %mul117.us.us = mul i32 %2, %incx.0.us
  %add120.us.us = add i32 %add118.us.us, %mul117.us.us
  %inc121.us.us = add i32 %index88.1327.us.us, 1
  %conv122.us.us = zext i32 %add120.us.us to i64
  %add.ptr.i.304.us.us = getelementptr inbounds i32, i32* %1, i64 %conv122.us.us
  store i32 %index88.1327.us.us, i32* %add.ptr.i.304.us.us, align 4, !tbaa !6
  %indvars.iv.next466 = add nuw nsw i64 %indvars.iv465, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next466 to i32
  %exitcond482 = icmp eq i32 %lftr.wideiv, %degree
  br i1 %exitcond482, label %for.cond.112.for.cond.cleanup.114_crit_edge.us.us, label %for.body.115.us.us

for.cond.112.for.cond.cleanup.114_crit_edge.us.us: ; preds = %for.body.115.us.us
  %3 = add i32 %0, %index88.0331.us.us
  %inc129.us.us = add nuw i32 %jy.0332.us.us, 1
  %exitcond469 = icmp eq i32 %inc129.us.us, %degree
  br i1 %exitcond469, label %for.cond.107.for.cond.cleanup.109_crit_edge.us.loopexit.exitStub, label %for.body.115.lr.ph.us.us
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !3, i64 0}
!1 = !{!"_ZTSSt12_Vector_baseIjSaIjEE", !2, i64 0}
!2 = !{!"_ZTSNSt12_Vector_baseIjSaIjEE12_Vector_implE", !3, i64 0, !3, i64 8, !3, i64 16}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !4, i64 0}
