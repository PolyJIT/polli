
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'patterns_transform.c.transformation_init_for.cond.1.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @transformation_init_for.cond.1.preheader.pjit.scop([8 x [2 x [2 x i32]]]* nonnull %transformation2, [1369 x [8 x i32]]* nonnull %transformation)  {
newFuncRoot:
  br label %for.cond.1.preheader

for.end.41.exitStub:                              ; preds = %for.inc.39
  ret void

for.cond.1.preheader:                             ; preds = %for.inc.39, %newFuncRoot
  %indvars.iv76 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next77, %for.inc.39 ]
  %arrayidx8 = getelementptr inbounds [8 x [2 x [2 x i32]]], [8 x [2 x [2 x i32]]]* %transformation2, i64 0, i64 %indvars.iv76, i64 0, i64 0
  %0 = load i32, i32* %arrayidx8, align 16, !tbaa !0
  %arrayidx12 = getelementptr inbounds [8 x [2 x [2 x i32]]], [8 x [2 x [2 x i32]]]* %transformation2, i64 0, i64 %indvars.iv76, i64 0, i64 1
  %1 = load i32, i32* %arrayidx12, align 4, !tbaa !0
  %arrayidx17 = getelementptr inbounds [8 x [2 x [2 x i32]]], [8 x [2 x [2 x i32]]]* %transformation2, i64 0, i64 %indvars.iv76, i64 1, i64 0
  %2 = load i32, i32* %arrayidx17, align 8, !tbaa !0
  %arrayidx22 = getelementptr inbounds [8 x [2 x [2 x i32]]], [8 x [2 x [2 x i32]]]* %transformation2, i64 0, i64 %indvars.iv76, i64 1, i64 1
  %3 = load i32, i32* %arrayidx22, align 4, !tbaa !0
  %4 = sext i32 %2 to i64
  %5 = sext i32 %3 to i64
  %6 = sext i32 %1 to i64
  br label %for.cond.4.preheader

for.cond.4.preheader:                             ; preds = %for.inc.36, %for.cond.1.preheader
  %indvars.iv70 = phi i64 [ -18, %for.cond.1.preheader ], [ %indvars.iv.next71, %for.inc.36 ]
  %7 = mul nsw i64 %indvars.iv70, %6
  %8 = mul nsw i64 %indvars.iv70, %5
  %9 = mul nsw i64 %indvars.iv70, 37
  %10 = add nsw i64 %9, 684
  br label %for.body.6

for.body.6:                                       ; preds = %for.body.6, %for.cond.4.preheader
  %indvars.iv = phi i64 [ -18, %for.cond.4.preheader ], [ %indvars.iv.next, %for.body.6 ]
  %dx.061 = phi i32 [ -18, %for.cond.4.preheader ], [ %inc, %for.body.6 ]
  %mul = mul nsw i32 %dx.061, %0
  %11 = trunc i64 %7 to i32
  %add = add nsw i32 %mul, %11
  %12 = mul nsw i64 %indvars.iv, %4
  %13 = add nsw i64 %12, %8
  %mul25 = mul nsw i32 %add, 20
  %14 = trunc i64 %13 to i32
  %add26 = add nsw i32 %mul25, %14
  %15 = add nsw i64 %10, %indvars.iv
  %arrayidx35 = getelementptr inbounds [1369 x [8 x i32]], [1369 x [8 x i32]]* %transformation, i64 0, i64 %15, i64 %indvars.iv76
  store i32 %add26, i32* %arrayidx35, align 4, !tbaa !0
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %inc = add nsw i32 %dx.061, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 19
  br i1 %exitcond, label %for.inc.36, label %for.body.6

for.inc.36:                                       ; preds = %for.body.6
  %indvars.iv.next71 = add nsw i64 %indvars.iv70, 1
  %exitcond75 = icmp eq i64 %indvars.iv.next71, 19
  br i1 %exitcond75, label %for.inc.39, label %for.cond.4.preheader

for.inc.39:                                       ; preds = %for.inc.36
  %indvars.iv.next77 = add nuw nsw i64 %indvars.iv76, 1
  %exitcond78 = icmp eq i64 %indvars.iv.next77, 8
  br i1 %exitcond78, label %for.end.41.exitStub, label %for.cond.1.preheader
}

attributes #0 = { nounwind "polyjit-global-count"="2" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
