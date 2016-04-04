
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Stanford/FloatMM.c.Mm_for.cond.1.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @Mm_for.cond.1.preheader.pjit.scop([41 x [41 x float]]* nonnull %rmr, [41 x [41 x float]]* nonnull %rma, [41 x [41 x float]]* nonnull %rmb)  {
newFuncRoot:
  br label %for.cond.1.preheader

for.end.8.exitStub:                               ; preds = %for.inc.6
  ret void

for.cond.1.preheader:                             ; preds = %for.inc.6, %newFuncRoot
  %indvars.iv53 = phi i64 [ 1, %newFuncRoot ], [ %indvars.iv.next54, %for.inc.6 ]
  br label %for.body.3

for.body.3:                                       ; preds = %rInnerproduct.exit, %for.cond.1.preheader
  %indvars.iv = phi i64 [ 1, %for.cond.1.preheader ], [ %indvars.iv.next, %rInnerproduct.exit ]
  %arrayidx5 = getelementptr inbounds [41 x [41 x float]], [41 x [41 x float]]* %rmr, i64 0, i64 %indvars.iv53, i64 %indvars.iv
  store float 0.000000e+00, float* %arrayidx5, align 4, !tbaa !0
  br label %for.body.i

for.body.i:                                       ; preds = %for.body.i, %for.body.3
  %add.i52 = phi float [ 0.000000e+00, %for.body.3 ], [ %add.i, %for.body.i ]
  %indvars.iv.i = phi i64 [ 1, %for.body.3 ], [ %indvars.iv.next.i, %for.body.i ]
  %arrayidx2.i = getelementptr inbounds [41 x [41 x float]], [41 x [41 x float]]* %rma, i64 0, i64 %indvars.iv53, i64 %indvars.iv.i
  %0 = load float, float* %arrayidx2.i, align 4, !tbaa !0
  %arrayidx6.i = getelementptr inbounds [41 x [41 x float]], [41 x [41 x float]]* %rmb, i64 0, i64 %indvars.iv.i, i64 %indvars.iv
  %1 = load float, float* %arrayidx6.i, align 4, !tbaa !0
  %mul.i = fmul float %0, %1
  %add.i = fadd float %add.i52, %mul.i
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %exitcond.i = icmp eq i64 %indvars.iv.next.i, 41
  br i1 %exitcond.i, label %rInnerproduct.exit, label %for.body.i

rInnerproduct.exit:                               ; preds = %for.body.i
  %add.i.lcssa = phi float [ %add.i, %for.body.i ]
  store float %add.i.lcssa, float* %arrayidx5, align 4, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 41
  br i1 %exitcond, label %for.inc.6, label %for.body.3

for.inc.6:                                        ; preds = %rInnerproduct.exit
  %indvars.iv.next54 = add nuw nsw i64 %indvars.iv53, 1
  %exitcond55 = icmp eq i64 %indvars.iv.next54, 41
  br i1 %exitcond55, label %for.end.8.exitStub, label %for.cond.1.preheader
}

attributes #0 = { nounwind "polyjit-global-count"="3" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
