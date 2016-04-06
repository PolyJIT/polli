
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/kernels/syr2k/syr2k.c.main_for.cond.12.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.12.preheader.i.pjit.scop([1024 x double]* %arraydecay, [1024 x double]* %arraydecay3, [1024 x double]* %arraydecay4)  {
newFuncRoot:
  br label %for.cond.12.preheader.i

kernel_syr2k.exit.exitStub:                       ; preds = %for.inc.53.i
  ret void

for.cond.12.preheader.i:                          ; preds = %for.inc.53.i, %newFuncRoot
  %indvars.iv9.i = phi i64 [ %indvars.iv.next10.i, %for.inc.53.i ], [ 0, %newFuncRoot ]
  br label %for.cond.15.preheader.i

for.cond.15.preheader.i:                          ; preds = %for.inc.50.i, %for.cond.12.preheader.i
  %indvars.iv6.i = phi i64 [ 0, %for.cond.12.preheader.i ], [ %indvars.iv.next7.i, %for.inc.50.i ]
  %arrayidx31.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv9.i, i64 %indvars.iv6.i
  br label %for.body.17.i

for.body.17.i:                                    ; preds = %for.body.17.i, %for.cond.15.preheader.i
  %indvars.iv.i.41 = phi i64 [ 0, %for.cond.15.preheader.i ], [ %indvars.iv.next.i.42, %for.body.17.i ]
  %arrayidx21.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay3, i64 %indvars.iv9.i, i64 %indvars.iv.i.41
  %0 = load double, double* %arrayidx21.i, align 8, !tbaa !0
  %mul22.i = fmul double %0, 3.241200e+04
  %arrayidx26.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %indvars.iv6.i, i64 %indvars.iv.i.41
  %1 = load double, double* %arrayidx26.i, align 8, !tbaa !0
  %mul27.i = fmul double %mul22.i, %1
  %2 = load double, double* %arrayidx31.i, align 8, !tbaa !0
  %add.i = fadd double %2, %mul27.i
  store double %add.i, double* %arrayidx31.i, align 8, !tbaa !0
  %arrayidx35.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %indvars.iv9.i, i64 %indvars.iv.i.41
  %3 = load double, double* %arrayidx35.i, align 8, !tbaa !0
  %mul36.i = fmul double %3, 3.241200e+04
  %arrayidx40.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay3, i64 %indvars.iv6.i, i64 %indvars.iv.i.41
  %4 = load double, double* %arrayidx40.i, align 8, !tbaa !0
  %mul41.i = fmul double %mul36.i, %4
  %add46.i = fadd double %add.i, %mul41.i
  store double %add46.i, double* %arrayidx31.i, align 8, !tbaa !0
  %indvars.iv.next.i.42 = add nuw nsw i64 %indvars.iv.i.41, 1
  %exitcond.i.43 = icmp eq i64 %indvars.iv.next.i.42, 1024
  br i1 %exitcond.i.43, label %for.inc.50.i, label %for.body.17.i

for.inc.50.i:                                     ; preds = %for.body.17.i
  %indvars.iv.next7.i = add nuw nsw i64 %indvars.iv6.i, 1
  %exitcond8.i = icmp eq i64 %indvars.iv.next7.i, 1024
  br i1 %exitcond8.i, label %for.inc.53.i, label %for.cond.15.preheader.i

for.inc.53.i:                                     ; preds = %for.inc.50.i
  %indvars.iv.next10.i = add nuw nsw i64 %indvars.iv9.i, 1
  %exitcond11.i = icmp eq i64 %indvars.iv.next10.i, 1024
  br i1 %exitcond11.i, label %kernel_syr2k.exit.exitStub, label %for.cond.12.preheader.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
