
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Stanford/IntMM.c.Intmm_for.cond.1.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @Intmm_for.cond.1.preheader.pjit.scop([41 x [41 x i32]]* nonnull %imr, [41 x [41 x i32]]* nonnull %ima, [41 x [41 x i32]]* nonnull %imb)  {
newFuncRoot:
  br label %for.cond.1.preheader

for.end.8.exitStub:                               ; preds = %for.inc.6
  ret void

for.cond.1.preheader:                             ; preds = %for.inc.6, %newFuncRoot
  %indvars.iv50 = phi i64 [ 1, %newFuncRoot ], [ %indvars.iv.next51, %for.inc.6 ]
  br label %for.body.3

for.body.3:                                       ; preds = %Innerproduct.exit, %for.cond.1.preheader
  %indvars.iv = phi i64 [ 1, %for.cond.1.preheader ], [ %indvars.iv.next, %Innerproduct.exit ]
  %arrayidx5 = getelementptr inbounds [41 x [41 x i32]], [41 x [41 x i32]]* %imr, i64 0, i64 %indvars.iv50, i64 %indvars.iv
  store i32 0, i32* %arrayidx5, align 4, !tbaa !0
  br label %for.body.i

for.body.i:                                       ; preds = %for.body.i, %for.body.3
  %add.i49 = phi i32 [ 0, %for.body.3 ], [ %add.i, %for.body.i ]
  %indvars.iv.i = phi i64 [ 1, %for.body.3 ], [ %indvars.iv.next.i, %for.body.i ]
  %arrayidx2.i = getelementptr inbounds [41 x [41 x i32]], [41 x [41 x i32]]* %ima, i64 0, i64 %indvars.iv50, i64 %indvars.iv.i
  %0 = load i32, i32* %arrayidx2.i, align 4, !tbaa !0
  %arrayidx6.i = getelementptr inbounds [41 x [41 x i32]], [41 x [41 x i32]]* %imb, i64 0, i64 %indvars.iv.i, i64 %indvars.iv
  %1 = load i32, i32* %arrayidx6.i, align 4, !tbaa !0
  %mul.i = mul nsw i32 %1, %0
  %add.i = add nsw i32 %mul.i, %add.i49
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %exitcond.i = icmp eq i64 %indvars.iv.next.i, 41
  br i1 %exitcond.i, label %Innerproduct.exit, label %for.body.i

Innerproduct.exit:                                ; preds = %for.body.i
  %add.i.lcssa = phi i32 [ %add.i, %for.body.i ]
  store i32 %add.i.lcssa, i32* %arrayidx5, align 4, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 41
  br i1 %exitcond, label %for.inc.6, label %for.body.3

for.inc.6:                                        ; preds = %Innerproduct.exit
  %indvars.iv.next51 = add nuw nsw i64 %indvars.iv50, 1
  %exitcond52 = icmp eq i64 %indvars.iv.next51, 41
  br i1 %exitcond52, label %for.end.8.exitStub, label %for.cond.1.preheader
}

attributes #0 = { nounwind "polyjit-global-count"="3" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
