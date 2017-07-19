
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/kernels/doitgen/doitgen.c.main_for.cond.4.preheader.i.43.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.4.preheader.i.43.pjit.scop([128 x [128 x double]]* %arraydecay6, i64 %indvars.iv15.i.40, [128 x [128 x double]]* %arraydecay, [128 x double]* %arraydecay3)  {
newFuncRoot:
  br label %for.cond.4.preheader.i.43

for.inc.60.i.exitStub:                            ; preds = %for.inc.57.i
  ret void

for.cond.4.preheader.i.43:                        ; preds = %for.inc.57.i, %newFuncRoot
  %indvars.iv12.i.42 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next13.i.56, %for.inc.57.i ]
  br label %for.body.6.i.45

for.body.6.i.45:                                  ; preds = %for.inc.36.i, %for.cond.4.preheader.i.43
  %indvars.iv6.i.44 = phi i64 [ 0, %for.cond.4.preheader.i.43 ], [ %indvars.iv.next7.i.51, %for.inc.36.i ]
  %arrayidx10.i = getelementptr inbounds [128 x [128 x double]], [128 x [128 x double]]* %arraydecay6, i64 %indvars.iv15.i.40, i64 %indvars.iv12.i.42, i64 %indvars.iv6.i.44
  store double 0.000000e+00, double* %arrayidx10.i, align 8, !tbaa !0
  br label %for.body.13.i

for.body.13.i:                                    ; preds = %for.body.13.i, %for.body.6.i.45
  %indvars.iv.i.46 = phi i64 [ 0, %for.body.6.i.45 ], [ %indvars.iv.next.i.49, %for.body.13.i ]
  %0 = load double, double* %arrayidx10.i, align 8, !tbaa !0
  %arrayidx25.i = getelementptr inbounds [128 x [128 x double]], [128 x [128 x double]]* %arraydecay, i64 %indvars.iv15.i.40, i64 %indvars.iv12.i.42, i64 %indvars.iv.i.46
  %1 = load double, double* %arrayidx25.i, align 8, !tbaa !0
  %arrayidx29.i = getelementptr inbounds [128 x double], [128 x double]* %arraydecay3, i64 %indvars.iv.i.46, i64 %indvars.iv6.i.44
  %2 = load double, double* %arrayidx29.i, align 8, !tbaa !0
  %mul.i.47 = fmul double %1, %2
  %add.i.48 = fadd double %0, %mul.i.47
  store double %add.i.48, double* %arrayidx10.i, align 8, !tbaa !0
  %indvars.iv.next.i.49 = add nuw nsw i64 %indvars.iv.i.46, 1
  %exitcond.i.50 = icmp eq i64 %indvars.iv.next.i.49, 128
  br i1 %exitcond.i.50, label %for.inc.36.i, label %for.body.13.i

for.inc.36.i:                                     ; preds = %for.body.13.i
  %indvars.iv.next7.i.51 = add nuw nsw i64 %indvars.iv6.i.44, 1
  %exitcond8.i.52 = icmp eq i64 %indvars.iv.next7.i.51, 128
  br i1 %exitcond8.i.52, label %for.body.41.i.preheader, label %for.body.6.i.45

for.body.41.i.preheader:                          ; preds = %for.inc.36.i
  br label %for.body.41.i

for.body.41.i:                                    ; preds = %for.body.41.i, %for.body.41.i.preheader
  %indvars.iv9.i.53 = phi i64 [ %indvars.iv.next10.i.54, %for.body.41.i ], [ 0, %for.body.41.i.preheader ]
  %arrayidx47.i = getelementptr inbounds [128 x [128 x double]], [128 x [128 x double]]* %arraydecay6, i64 %indvars.iv15.i.40, i64 %indvars.iv12.i.42, i64 %indvars.iv9.i.53
  %3 = bitcast double* %arrayidx47.i to i64*
  %4 = load i64, i64* %3, align 8, !tbaa !0
  %arrayidx53.i = getelementptr inbounds [128 x [128 x double]], [128 x [128 x double]]* %arraydecay, i64 %indvars.iv15.i.40, i64 %indvars.iv12.i.42, i64 %indvars.iv9.i.53
  %5 = bitcast double* %arrayidx53.i to i64*
  store i64 %4, i64* %5, align 8, !tbaa !0
  %indvars.iv.next10.i.54 = add nuw nsw i64 %indvars.iv9.i.53, 1
  %exitcond11.i.55 = icmp eq i64 %indvars.iv.next10.i.54, 128
  br i1 %exitcond11.i.55, label %for.inc.57.i, label %for.body.41.i

for.inc.57.i:                                     ; preds = %for.body.41.i
  %indvars.iv.next13.i.56 = add nuw nsw i64 %indvars.iv12.i.42, 1
  %exitcond14.i.57 = icmp eq i64 %indvars.iv.next13.i.56, 128
  br i1 %exitcond14.i.57, label %for.inc.60.i.exitStub, label %for.cond.4.preheader.i.43
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
