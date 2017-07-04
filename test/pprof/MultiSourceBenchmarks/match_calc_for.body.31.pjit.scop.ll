
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/mafft/Lalignmm.c.match_calc_for.body.31.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @match_calc_for.body.31.pjit.scop([26 x float]* %scarr, i32, float*, [26 x [26 x i32]]* nonnull %n_dis)  {
newFuncRoot:
  br label %for.body.31

while.cond.preheader.exitStub:                    ; preds = %for.inc.50
  ret void

for.body.31:                                      ; preds = %for.inc.50, %newFuncRoot
  %indvars.iv131 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next132, %for.inc.50 ]
  %arrayidx33 = getelementptr inbounds [26 x float], [26 x float]* %scarr, i64 0, i64 %indvars.iv131
  store float 0.000000e+00, float* %arrayidx33, align 4, !tbaa !0
  br label %for.body.36

for.body.36:                                      ; preds = %for.body.36, %for.body.31
  %indvars.iv129 = phi i64 [ 0, %for.body.31 ], [ %indvars.iv.next130, %for.body.36 ]
  %2 = phi float [ 0.000000e+00, %for.body.31 ], [ %add, %for.body.36 ]
  %arrayidx40 = getelementptr inbounds [26 x [26 x i32]], [26 x [26 x i32]]* %n_dis, i64 0, i64 %indvars.iv129, i64 %indvars.iv131
  %3 = load i32, i32* %arrayidx40, align 4, !tbaa !4
  %sub = sub nsw i32 %3, %0
  %conv = sitofp i32 %sub to float
  %arrayidx44 = getelementptr inbounds float, float* %1, i64 %indvars.iv129
  %4 = load float, float* %arrayidx44, align 4, !tbaa !0
  %mul = fmul float %4, %conv
  %add = fadd float %2, %mul
  %indvars.iv.next130 = add nuw nsw i64 %indvars.iv129, 1
  %exitcond = icmp eq i64 %indvars.iv.next130, 26
  br i1 %exitcond, label %for.inc.50, label %for.body.36

for.inc.50:                                       ; preds = %for.body.36
  %add.lcssa = phi float [ %add, %for.body.36 ]
  store float %add.lcssa, float* %arrayidx33, align 4, !tbaa !0
  %indvars.iv.next132 = add nuw nsw i64 %indvars.iv131, 1
  %exitcond133 = icmp eq i64 %indvars.iv.next132, 26
  br i1 %exitcond133, label %while.cond.preheader.exitStub, label %for.body.31
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !2, i64 0}
