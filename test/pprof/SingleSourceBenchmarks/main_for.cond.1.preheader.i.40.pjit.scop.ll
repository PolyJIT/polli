
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/kernels/symm/symm.c.main_for.cond.1.preheader.i.40.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.1.preheader.i.40.pjit.scop([1024 x double]* %arraydecay3, [1024 x double]* %arraydecay4, [1024 x double]* %arraydecay)  {
newFuncRoot:
  br label %for.cond.1.preheader.i.40

kernel_symm.exit.exitStub:                        ; preds = %for.inc.53.i
  ret void

for.cond.1.preheader.i.40:                        ; preds = %for.inc.53.i, %newFuncRoot
  %indvars.iv9.i = phi i64 [ %indvars.iv.next10.i, %for.inc.53.i ], [ 0, %newFuncRoot ]
  %arrayidx36.i.39 = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay3, i64 %indvars.iv9.i, i64 %indvars.iv9.i
  br label %for.cond.4.preheader.i

for.cond.4.preheader.i:                           ; preds = %for.end.i, %for.cond.1.preheader.i.40
  %indvars.iv6.i = phi i64 [ 0, %for.cond.1.preheader.i.40 ], [ %indvars.iv.next7.i, %for.end.i ]
  %0 = add nsw i64 %indvars.iv6.i, -1
  %cmp5.1.i = icmp sgt i64 %indvars.iv6.i, 1
  br i1 %cmp5.1.i, label %for.body.6.lr.ph.i, label %for.end.i

for.body.6.lr.ph.i:                               ; preds = %for.cond.4.preheader.i
  %arrayidx12.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %indvars.iv9.i, i64 %indvars.iv6.i
  br label %for.body.6.i

for.body.6.i:                                     ; preds = %for.body.6.i, %for.body.6.lr.ph.i
  %indvars.iv.i.41 = phi i64 [ 0, %for.body.6.lr.ph.i ], [ %indvars.iv.next.i.43, %for.body.6.i ]
  %acc.03.i = phi double [ 0.000000e+00, %for.body.6.lr.ph.i ], [ %add27.i, %for.body.6.i ]
  %arrayidx8.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay3, i64 %indvars.iv.i.41, i64 %indvars.iv9.i
  %1 = load double, double* %arrayidx8.i, align 8, !tbaa !0
  %mul.i.42 = fmul double %1, 3.241200e+04
  %2 = load double, double* %arrayidx12.i, align 8, !tbaa !0
  %mul13.i = fmul double %mul.i.42, %2
  %arrayidx17.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv.i.41, i64 %indvars.iv6.i
  %3 = load double, double* %arrayidx17.i, align 8, !tbaa !0
  %add.i = fadd double %3, %mul13.i
  store double %add.i, double* %arrayidx17.i, align 8, !tbaa !0
  %arrayidx21.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %indvars.iv.i.41, i64 %indvars.iv6.i
  %4 = load double, double* %arrayidx21.i, align 8, !tbaa !0
  %5 = load double, double* %arrayidx8.i, align 8, !tbaa !0
  %mul26.i = fmul double %4, %5
  %add27.i = fadd double %acc.03.i, %mul26.i
  %indvars.iv.next.i.43 = add nuw nsw i64 %indvars.iv.i.41, 1
  %cmp5.i = icmp slt i64 %indvars.iv.next.i.43, %0
  br i1 %cmp5.i, label %for.body.6.i, label %for.end.i.loopexit

for.end.i.loopexit:                               ; preds = %for.body.6.i
  %add27.i.lcssa = phi double [ %add27.i, %for.body.6.i ]
  br label %for.end.i

for.end.i:                                        ; preds = %for.end.i.loopexit, %for.cond.4.preheader.i
  %acc.0.lcssa.i = phi double [ 0.000000e+00, %for.cond.4.preheader.i ], [ %add27.i.lcssa, %for.end.i.loopexit ]
  %arrayidx31.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv9.i, i64 %indvars.iv6.i
  %6 = load double, double* %arrayidx31.i, align 8, !tbaa !0
  %mul32.i = fmul double %6, 2.123000e+03
  %7 = load double, double* %arrayidx36.i.39, align 8, !tbaa !0
  %mul37.i = fmul double %7, 3.241200e+04
  %arrayidx41.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %indvars.iv9.i, i64 %indvars.iv6.i
  %8 = load double, double* %arrayidx41.i, align 8, !tbaa !0
  %mul42.i = fmul double %mul37.i, %8
  %add43.i = fadd double %mul32.i, %mul42.i
  %mul44.i = fmul double %acc.0.lcssa.i, 3.241200e+04
  %add45.i = fadd double %mul44.i, %add43.i
  store double %add45.i, double* %arrayidx31.i, align 8, !tbaa !0
  %indvars.iv.next7.i = add nuw nsw i64 %indvars.iv6.i, 1
  %exitcond.i.44 = icmp eq i64 %indvars.iv.next7.i, 1024
  br i1 %exitcond.i.44, label %for.inc.53.i, label %for.cond.4.preheader.i

for.inc.53.i:                                     ; preds = %for.end.i
  %indvars.iv.next10.i = add nuw nsw i64 %indvars.iv9.i, 1
  %exitcond11.i = icmp eq i64 %indvars.iv.next10.i, 1024
  br i1 %exitcond11.i, label %kernel_symm.exit.exitStub, label %for.cond.1.preheader.i.40
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
