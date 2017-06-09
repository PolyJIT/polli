
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/mafft/MSalignmm.c.MSalignmm_rec_for.body.31.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @MSalignmm_rec_for.body.31.i.pjit.scop([26 x float]* %scarr.i.i, float*, [26 x [26 x i32]]* nonnull %n_dis)  {
newFuncRoot:
  br label %for.body.31.i

while.cond.preheader.i.exitStub:                  ; preds = %for.inc.50.i
  ret void

for.body.31.i:                                    ; preds = %for.inc.50.i, %newFuncRoot
  %indvars.iv131.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next132.i, %for.inc.50.i ]
  %arrayidx33.i = getelementptr inbounds [26 x float], [26 x float]* %scarr.i.i, i64 0, i64 %indvars.iv131.i
  store float 0.000000e+00, float* %arrayidx33.i, align 4, !tbaa !0
  br label %for.body.36.i

for.body.36.i:                                    ; preds = %for.body.36.i, %for.body.31.i
  %indvars.iv129.i = phi i64 [ 0, %for.body.31.i ], [ %indvars.iv.next130.i, %for.body.36.i ]
  %1 = phi float [ 0.000000e+00, %for.body.31.i ], [ %add.i.3, %for.body.36.i ]
  %arrayidx40.i = getelementptr inbounds [26 x [26 x i32]], [26 x [26 x i32]]* %n_dis, i64 0, i64 %indvars.iv129.i, i64 %indvars.iv131.i
  %2 = load i32, i32* %arrayidx40.i, align 4, !tbaa !4
  %conv.i = sitofp i32 %2 to float
  %arrayidx44.i = getelementptr inbounds float, float* %0, i64 %indvars.iv129.i
  %3 = load float, float* %arrayidx44.i, align 4, !tbaa !0
  %mul.i = fmul float %conv.i, %3
  %add.i.3 = fadd float %1, %mul.i
  %indvars.iv.next130.i = add nuw nsw i64 %indvars.iv129.i, 1
  %exitcond.i.4 = icmp eq i64 %indvars.iv.next130.i, 26
  br i1 %exitcond.i.4, label %for.inc.50.i, label %for.body.36.i

for.inc.50.i:                                     ; preds = %for.body.36.i
  %add.i.3.lcssa = phi float [ %add.i.3, %for.body.36.i ]
  store float %add.i.3.lcssa, float* %arrayidx33.i, align 4, !tbaa !0
  %indvars.iv.next132.i = add nuw nsw i64 %indvars.iv131.i, 1
  %exitcond133.i = icmp eq i64 %indvars.iv.next132.i, 26
  br i1 %exitcond133.i, label %while.cond.preheader.i.exitStub, label %for.body.31.i
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !2, i64 0}
