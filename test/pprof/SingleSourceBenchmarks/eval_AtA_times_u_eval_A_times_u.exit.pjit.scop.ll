
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/BenchmarkGame/spectral-norm.c.eval_AtA_times_u_eval_A_times_u.exit.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @eval_AtA_times_u_eval_A_times_u.exit.pjit.scop(i1 %cmp.23.i, double* %AtAu, double* %vla, i32 %N)  {
newFuncRoot:
  br label %eval_A_times_u.exit

eval_At_times_u.exit.exitStub:                    ; preds = %eval_At_times_u.exit.loopexit, %eval_A_times_u.exit
  ret void

eval_A_times_u.exit:                              ; preds = %newFuncRoot
  br i1 %cmp.23.i, label %for.body.us.i.7.preheader, label %eval_At_times_u.exit.exitStub

for.body.us.i.7.preheader:                        ; preds = %eval_A_times_u.exit
  br label %for.body.us.i.7

for.body.us.i.7:                                  ; preds = %for.cond.1.for.inc.8_crit_edge.us.i.24, %for.body.us.i.7.preheader
  %indvars.iv30.i = phi i64 [ %indvars.iv.next31.i, %for.cond.1.for.inc.8_crit_edge.us.i.24 ], [ 0, %for.body.us.i.7.preheader ]
  %arrayidx.us.i.6 = getelementptr inbounds double, double* %AtAu, i64 %indvars.iv30.i
  store double 0.000000e+00, double* %arrayidx.us.i.6, align 8, !tbaa !0
  %0 = trunc i64 %indvars.iv30.i to i32
  %add.i.us.i.9 = add i32 %0, 1
  br label %for.body.3.us.i.21

for.body.3.us.i.21:                               ; preds = %for.body.3.us.i.21, %for.body.us.i.7
  %add.us.i.1927 = phi double [ 0.000000e+00, %for.body.us.i.7 ], [ %add.us.i.19, %for.body.3.us.i.21 ]
  %indvars.iv.i.8 = phi i64 [ 0, %for.body.us.i.7 ], [ %indvars.iv.next.i.13, %for.body.3.us.i.21 ]
  %j.023.us.i = phi i32 [ 0, %for.body.us.i.7 ], [ %inc.us.i.20, %for.body.3.us.i.21 ]
  %1 = add nuw nsw i64 %indvars.iv.i.8, %indvars.iv30.i
  %add2.i.us.i.10 = add i32 %add.i.us.i.9, %j.023.us.i
  %2 = trunc i64 %1 to i32
  %mul.i.us.i.11 = mul nsw i32 %add2.i.us.i.10, %2
  %div.i.us.i.12 = sdiv i32 %mul.i.us.i.11, 2
  %indvars.iv.next.i.13 = add nuw nsw i64 %indvars.iv.i.8, 1
  %3 = trunc i64 %indvars.iv.next.i.13 to i32
  %add4.i.us.i.14 = add i32 %div.i.us.i.12, %3
  %conv.i.us.i.15 = sitofp i32 %add4.i.us.i.14 to double
  %div5.i.us.i.16 = fdiv double 1.000000e+00, %conv.i.us.i.15
  %arrayidx5.us.i.17 = getelementptr inbounds double, double* %vla, i64 %indvars.iv.i.8
  %4 = load double, double* %arrayidx5.us.i.17, align 8, !tbaa !0
  %mul.us.i.18 = fmul double %4, %div5.i.us.i.16
  %add.us.i.19 = fadd double %add.us.i.1927, %mul.us.i.18
  %inc.us.i.20 = add nuw nsw i32 %j.023.us.i, 1
  %lftr.wideiv37 = trunc i64 %indvars.iv.next.i.13 to i32
  %exitcond38 = icmp eq i32 %lftr.wideiv37, %N
  br i1 %exitcond38, label %for.cond.1.for.inc.8_crit_edge.us.i.24, label %for.body.3.us.i.21

for.cond.1.for.inc.8_crit_edge.us.i.24:           ; preds = %for.body.3.us.i.21
  %add.us.i.19.lcssa = phi double [ %add.us.i.19, %for.body.3.us.i.21 ]
  store double %add.us.i.19.lcssa, double* %arrayidx.us.i.6, align 8, !tbaa !0
  %indvars.iv.next31.i = add nuw nsw i64 %indvars.iv30.i, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next31.i to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %N
  br i1 %exitcond, label %eval_At_times_u.exit.loopexit, label %for.body.us.i.7

eval_At_times_u.exit.loopexit:                    ; preds = %for.cond.1.for.inc.8_crit_edge.us.i.24
  br label %eval_At_times_u.exit.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
