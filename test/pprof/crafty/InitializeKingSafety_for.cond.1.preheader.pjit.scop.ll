
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'crafty.c.InitializeKingSafety_for.cond.1.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @InitializeKingSafety_for.cond.1.preheader.pjit.scop([16 x i32]* nonnull %safety_vector, [16 x i32]* nonnull %tropism_vector, [16 x [16 x i32]]* nonnull %king_safety)  {
newFuncRoot:
  br label %for.cond.1.preheader

for.end.15.exitStub:                              ; preds = %for.inc.13
  ret void

for.cond.1.preheader:                             ; preds = %for.inc.13, %newFuncRoot
  %indvars.iv25 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next26, %for.inc.13 ]
  %arrayidx = getelementptr inbounds [16 x i32], [16 x i32]* %safety_vector, i64 0, i64 %indvars.iv25
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !0
  %add = add nsw i32 %0, 100
  br label %for.body.3

for.body.3:                                       ; preds = %for.body.3, %for.cond.1.preheader
  %indvars.iv = phi i64 [ 0, %for.cond.1.preheader ], [ %indvars.iv.next, %for.body.3 ]
  %arrayidx5 = getelementptr inbounds [16 x i32], [16 x i32]* %tropism_vector, i64 0, i64 %indvars.iv
  %1 = load i32, i32* %arrayidx5, align 4, !tbaa !0
  %add6 = add nsw i32 %1, 100
  %mul = mul nsw i32 %add6, %add
  %div = sdiv i32 %mul, 100
  %2 = mul i32 %div, 180
  %mul7 = add i32 %2, -18000
  %div8 = sdiv i32 %mul7, 100
  %arrayidx12 = getelementptr inbounds [16 x [16 x i32]], [16 x [16 x i32]]* %king_safety, i64 0, i64 %indvars.iv25, i64 %indvars.iv
  store i32 %div8, i32* %arrayidx12, align 4, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 16
  br i1 %exitcond, label %for.inc.13, label %for.body.3

for.inc.13:                                       ; preds = %for.body.3
  %indvars.iv.next26 = add nuw nsw i64 %indvars.iv25, 1
  %exitcond27 = icmp eq i64 %indvars.iv.next26, 16
  br i1 %exitcond27, label %for.end.15.exitStub, label %for.cond.1.preheader
}

attributes #0 = { nounwind "polyjit-global-count"="3" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
