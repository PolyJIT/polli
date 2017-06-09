
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/solvers/durbin/durbin.c.main_for.body.i.74.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.i.74.pjit.scop(double* %arraydecay8, double* %arraydecay7, double* %arraydecay9, [4000 x double]* %arraydecay6, [4000 x double]* %arraydecay)  {
newFuncRoot:
  br label %for.body.i.74

for.body.96.i.preheader.exitStub:                 ; preds = %for.end.84.i
  ret void

for.body.i.74:                                    ; preds = %for.end.84.i, %newFuncRoot
  %indvars.iv90 = phi i32 [ %indvars.iv.next91, %for.end.84.i ], [ 1, %newFuncRoot ]
  %indvars.iv21.i = phi i64 [ %indvars.iv.next22.i, %for.end.84.i ], [ 1, %newFuncRoot ]
  %0 = add nsw i64 %indvars.iv21.i, -1
  %arrayidx6.i = getelementptr inbounds double, double* %arraydecay8, i64 %0
  %1 = load double, double* %arrayidx6.i, align 8, !tbaa !0
  %arrayidx9.i = getelementptr inbounds double, double* %arraydecay7, i64 %0
  %2 = load double, double* %arrayidx9.i, align 8, !tbaa !0
  %mul.i.73 = fmul double %2, %2
  %mul16.i = fmul double %1, %mul.i.73
  %sub17.i = fsub double %1, %mul16.i
  %arrayidx19.i = getelementptr inbounds double, double* %arraydecay8, i64 %indvars.iv21.i
  store double %sub17.i, double* %arrayidx19.i, align 8, !tbaa !0
  %arrayidx21.i = getelementptr inbounds double, double* %arraydecay9, i64 %indvars.iv21.i
  %3 = bitcast double* %arrayidx21.i to i64*
  %4 = load i64, i64* %3, align 8, !tbaa !0
  %arrayidx24.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay6, i64 0, i64 %indvars.iv21.i
  %5 = bitcast double* %arrayidx24.i to i64*
  store i64 %4, i64* %5, align 8, !tbaa !0
  br label %for.body.28.i

for.body.28.i:                                    ; preds = %for.body.28.i, %for.body.i.74
  %indvars.iv8.i = phi i64 [ 0, %for.body.i.74 ], [ %indvars.iv.next9.i, %for.body.28.i ]
  %arrayidx32.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay6, i64 %indvars.iv8.i, i64 %indvars.iv21.i
  %6 = load double, double* %arrayidx32.i, align 8, !tbaa !0
  %7 = sub nsw i64 %0, %indvars.iv8.i
  %arrayidx36.i = getelementptr inbounds double, double* %arraydecay9, i64 %7
  %8 = load double, double* %arrayidx36.i, align 8, !tbaa !0
  %arrayidx41.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay, i64 %indvars.iv8.i, i64 %0
  %9 = load double, double* %arrayidx41.i, align 8, !tbaa !0
  %mul42.i = fmul double %8, %9
  %add.i = fadd double %6, %mul42.i
  %indvars.iv.next9.i = add nuw nsw i64 %indvars.iv8.i, 1
  %arrayidx47.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay6, i64 %indvars.iv.next9.i, i64 %indvars.iv21.i
  store double %add.i, double* %arrayidx47.i, align 8, !tbaa !0
  %lftr.wideiv88 = trunc i64 %indvars.iv.next9.i to i32
  %exitcond89 = icmp eq i32 %lftr.wideiv88, %indvars.iv90
  br i1 %exitcond89, label %for.end.i, label %for.body.28.i

for.end.i:                                        ; preds = %for.body.28.i
  %arrayidx51.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay6, i64 %indvars.iv21.i, i64 %indvars.iv21.i
  %10 = load double, double* %arrayidx51.i, align 8, !tbaa !0
  %11 = load double, double* %arrayidx19.i, align 8, !tbaa !0
  %12 = fmul double %10, %11
  %mul55.i = fsub double -0.000000e+00, %12
  %arrayidx57.i = getelementptr inbounds double, double* %arraydecay7, i64 %indvars.iv21.i
  store double %mul55.i, double* %arrayidx57.i, align 8, !tbaa !0
  br label %for.body.61.i

for.body.61.i:                                    ; preds = %for.body.61.i, %for.end.i
  %indvars.iv14.i = phi i64 [ 0, %for.end.i ], [ %indvars.iv.next15.i, %for.body.61.i ]
  %arrayidx66.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay, i64 %indvars.iv14.i, i64 %0
  %13 = load double, double* %arrayidx66.i, align 8, !tbaa !0
  %14 = load double, double* %arrayidx57.i, align 8, !tbaa !0
  %15 = sub nsw i64 %0, %indvars.iv14.i
  %arrayidx75.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay, i64 %15, i64 %0
  %16 = load double, double* %arrayidx75.i, align 8, !tbaa !0
  %mul76.i = fmul double %14, %16
  %add77.i = fadd double %13, %mul76.i
  %arrayidx81.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay, i64 %indvars.iv14.i, i64 %indvars.iv21.i
  store double %add77.i, double* %arrayidx81.i, align 8, !tbaa !0
  %indvars.iv.next15.i = add nuw nsw i64 %indvars.iv14.i, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next15.i to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %indvars.iv90
  br i1 %exitcond, label %for.end.84.i, label %for.body.61.i

for.end.84.i:                                     ; preds = %for.body.61.i
  %17 = bitcast double* %arrayidx57.i to i64*
  %18 = load i64, i64* %17, align 8, !tbaa !0
  %arrayidx90.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay, i64 %indvars.iv21.i, i64 %indvars.iv21.i
  %19 = bitcast double* %arrayidx90.i to i64*
  store i64 %18, i64* %19, align 8, !tbaa !0
  %indvars.iv.next22.i = add nuw nsw i64 %indvars.iv21.i, 1
  %indvars.iv.next91 = add nuw nsw i32 %indvars.iv90, 1
  %exitcond26.i = icmp eq i64 %indvars.iv.next22.i, 4000
  br i1 %exitcond26.i, label %for.body.96.i.preheader.exitStub, label %for.body.i.74
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
