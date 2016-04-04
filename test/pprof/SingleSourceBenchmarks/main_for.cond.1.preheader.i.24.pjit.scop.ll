
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/stencils/jacobi-2d-imper/jacobi-2d-imper.c.main_for.cond.1.preheader.i.24.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.1.preheader.i.24.pjit.scop([1000 x double]* %arraydecay, [1000 x double]* %arraydecay2)  {
newFuncRoot:
  br label %for.cond.1.preheader.i.24

kernel_jacobi_2d_imper.exit.exitStub:             ; preds = %for.inc.62.i
  ret void

for.cond.1.preheader.i.24:                        ; preds = %for.inc.62.i, %newFuncRoot
  %t.05.i = phi i32 [ %inc63.i, %for.inc.62.i ], [ 0, %newFuncRoot ]
  br label %for.cond.4.preheader.i

for.cond.4.preheader.i:                           ; preds = %for.inc.37.i, %for.cond.1.preheader.i.24
  %indvars.iv7.i = phi i64 [ 1, %for.cond.1.preheader.i.24 ], [ %indvars.iv.next8.i, %for.inc.37.i ]
  %indvars.iv.next8.i = add nuw nsw i64 %indvars.iv7.i, 1
  %0 = add nsw i64 %indvars.iv7.i, -1
  br label %for.body.7.i

for.body.7.i:                                     ; preds = %for.body.7.i, %for.cond.4.preheader.i
  %indvars.iv.i.25 = phi i64 [ 1, %for.cond.4.preheader.i ], [ %indvars.iv.next.i.26, %for.body.7.i ]
  %arrayidx9.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv7.i, i64 %indvars.iv.i.25
  %1 = load double, double* %arrayidx9.i, align 8, !tbaa !0
  %2 = add nsw i64 %indvars.iv.i.25, -1
  %arrayidx14.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv7.i, i64 %2
  %3 = load double, double* %arrayidx14.i, align 8, !tbaa !0
  %add.i = fadd double %1, %3
  %indvars.iv.next.i.26 = add nuw nsw i64 %indvars.iv.i.25, 1
  %arrayidx19.i.27 = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv7.i, i64 %indvars.iv.next.i.26
  %4 = load double, double* %arrayidx19.i.27, align 8, !tbaa !0
  %add20.i = fadd double %add.i, %4
  %arrayidx25.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv.next8.i, i64 %indvars.iv.i.25
  %5 = load double, double* %arrayidx25.i, align 8, !tbaa !0
  %add26.i = fadd double %add20.i, %5
  %arrayidx31.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %0, i64 %indvars.iv.i.25
  %6 = load double, double* %arrayidx31.i, align 8, !tbaa !0
  %add32.i = fadd double %add26.i, %6
  %mul.i.28 = fmul double %add32.i, 2.000000e-01
  %arrayidx36.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay2, i64 %indvars.iv7.i, i64 %indvars.iv.i.25
  store double %mul.i.28, double* %arrayidx36.i, align 8, !tbaa !0
  %exitcond.i.29 = icmp eq i64 %indvars.iv.next.i.26, 999
  br i1 %exitcond.i.29, label %for.inc.37.i, label %for.body.7.i

for.inc.37.i:                                     ; preds = %for.body.7.i
  %exitcond10.i = icmp eq i64 %indvars.iv.next8.i, 999
  br i1 %exitcond10.i, label %for.cond.44.preheader.i.preheader, label %for.cond.4.preheader.i

for.cond.44.preheader.i.preheader:                ; preds = %for.inc.37.i
  br label %for.cond.44.preheader.i

for.cond.44.preheader.i:                          ; preds = %for.inc.59.i, %for.cond.44.preheader.i.preheader
  %indvars.iv14.i = phi i64 [ %indvars.iv.next15.i, %for.inc.59.i ], [ 1, %for.cond.44.preheader.i.preheader ]
  br label %for.body.47.i

for.body.47.i:                                    ; preds = %for.body.47.i, %for.cond.44.preheader.i
  %indvars.iv11.i = phi i64 [ 1, %for.cond.44.preheader.i ], [ %indvars.iv.next12.i, %for.body.47.i ]
  %arrayidx51.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay2, i64 %indvars.iv14.i, i64 %indvars.iv11.i
  %7 = bitcast double* %arrayidx51.i to i64*
  %8 = load i64, i64* %7, align 8, !tbaa !0
  %arrayidx55.i = getelementptr inbounds [1000 x double], [1000 x double]* %arraydecay, i64 %indvars.iv14.i, i64 %indvars.iv11.i
  %9 = bitcast double* %arrayidx55.i to i64*
  store i64 %8, i64* %9, align 8, !tbaa !0
  %indvars.iv.next12.i = add nuw nsw i64 %indvars.iv11.i, 1
  %exitcond13.i = icmp eq i64 %indvars.iv.next12.i, 999
  br i1 %exitcond13.i, label %for.inc.59.i, label %for.body.47.i

for.inc.59.i:                                     ; preds = %for.body.47.i
  %indvars.iv.next15.i = add nuw nsw i64 %indvars.iv14.i, 1
  %exitcond16.i = icmp eq i64 %indvars.iv.next15.i, 999
  br i1 %exitcond16.i, label %for.inc.62.i, label %for.cond.44.preheader.i

for.inc.62.i:                                     ; preds = %for.inc.59.i
  %inc63.i = add nuw nsw i32 %t.05.i, 1
  %exitcond17.i = icmp eq i32 %inc63.i, 20
  br i1 %exitcond17.i, label %kernel_jacobi_2d_imper.exit.exitStub, label %for.cond.1.preheader.i.24
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
