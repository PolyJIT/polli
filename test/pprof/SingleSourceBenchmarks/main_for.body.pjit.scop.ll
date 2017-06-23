
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Misc/fp-convert.c.main_for.body.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.pjit.scop([2048 x float]* %x, [2048 x float]* %y, double* %add11.out)  {
newFuncRoot:
  br label %for.body

for.end.14.exitStub:                              ; preds = %loop.exit
  store double %add11, double* %add11.out
  ret void

for.body:                                         ; preds = %loop.exit, %newFuncRoot
  %b.035 = phi float [ 1.000000e+00, %newFuncRoot ], [ %b.1, %loop.exit ]
  %a.034 = phi float [ 0.000000e+00, %newFuncRoot ], [ %a.1, %loop.exit ]
  %total.033 = phi double [ 0.000000e+00, %newFuncRoot ], [ %add11, %loop.exit ]
  %i.032 = phi i32 [ 0, %newFuncRoot ], [ %inc13, %loop.exit ]
  %rem = srem i32 %i.032, 10
  %tobool = icmp eq i32 %rem, 0
  %add = fadd float %a.034, 0x3FB99999A0000000
  %add1 = fadd float %b.035, 0x3FC99999A0000000
  %a.1 = select i1 %tobool, float %add, float 0.000000e+00
  %b.1 = select i1 %tobool, float %add1, float 1.000000e+00
  br label %for.body.4

for.body.4:                                       ; preds = %for.body.4, %for.body
  %indvars.iv = phi i64 [ 0, %for.body ], [ %indvars.iv.next, %for.body.4 ]
  %0 = trunc i64 %indvars.iv to i32
  %conv = sitofp i32 %0 to float
  %add5 = fadd float %a.1, %conv
  %arrayidx = getelementptr inbounds [2048 x float], [2048 x float]* %x, i64 0, i64 %indvars.iv
  store float %add5, float* %arrayidx, align 4, !tbaa !0
  %add7 = fadd float %b.1, %conv
  %arrayidx9 = getelementptr inbounds [2048 x float], [2048 x float]* %y, i64 0, i64 %indvars.iv
  store float %add7, float* %arrayidx9, align 4, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 2048
  br i1 %exitcond, label %for.body.i.preheader, label %for.body.4

for.body.i.preheader:                             ; preds = %for.body.4
  br label %for.body.i

for.body.i:                                       ; preds = %for.body.i, %for.body.i.preheader
  %accumulator.011.i = phi double [ %add.i, %for.body.i ], [ 0.000000e+00, %for.body.i.preheader ]
  %i.010.i = phi i64 [ %inc.i, %for.body.i ], [ 0, %for.body.i.preheader ]
  %arrayidx.i = getelementptr inbounds [2048 x float], [2048 x float]* %x, i64 0, i64 %i.010.i
  %1 = load float, float* %arrayidx.i, align 4, !tbaa !0
  %conv.i = fpext float %1 to double
  %arrayidx1.i = getelementptr inbounds [2048 x float], [2048 x float]* %y, i64 0, i64 %i.010.i
  %2 = load float, float* %arrayidx1.i, align 4, !tbaa !0
  %conv2.i = fpext float %2 to double
  %mul.i = fmul double %conv.i, %conv2.i
  %add.i = fadd double %accumulator.011.i, %mul.i
  %inc.i = add nuw nsw i64 %i.010.i, 1
  %exitcond.i = icmp eq i64 %inc.i, 2048
  br i1 %exitcond.i, label %loop.exit, label %for.body.i

loop.exit:                                        ; preds = %for.body.i
  %add.i.lcssa = phi double [ %add.i, %for.body.i ]
  %add11 = fadd double %total.033, %add.i.lcssa
  %inc13 = add nuw nsw i32 %i.032, 1
  %exitcond36 = icmp eq i32 %inc13, 500000
  br i1 %exitcond36, label %for.end.14.exitStub, label %for.body
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
