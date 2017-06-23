
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/stencils/fdtd-apml/fdtd-apml.c.main_for.cond.7.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.7.preheader.i.pjit.scop([65 x double]* %arraydecay36, i64 %indvars.iv11.i, double* %arraydecay32, double* %arraydecay33, [65 x double]* %arraydecay37, [65 x [65 x double]]* %arraydecay25, [65 x [65 x double]]* %arraydecay26, [65 x [65 x double]]* %arraydecay38, double* %arraydecay30, double* %arraydecay31, [65 x [65 x double]]* %arraydecay27, double* %arrayidx75.i, double* %arrayidx87.i, [65 x double]* %arraydecay24, double*, double*, [65 x double]* %arraydecay, double*, double* %arrayidx345.i, double* %arrayidx349.i, double* %arrayidx354.i, double* %arrayidx361.i, double*, double* %arrayidx377.i, double* %arrayidx402.i, i64*)  {
newFuncRoot:
  br label %for.cond.7.preheader.i

for.inc.449.i.exitStub:                           ; preds = %for.end.339.i
  ret void

for.cond.7.preheader.i:                           ; preds = %for.end.339.i, %newFuncRoot
  %indvars.iv8.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next9.i, %for.end.339.i ]
  %indvars.iv.next9.i = add nuw nsw i64 %indvars.iv8.i, 1
  %arrayidx38.i = getelementptr inbounds [65 x double], [65 x double]* %arraydecay36, i64 %indvars.iv11.i, i64 %indvars.iv8.i
  %arrayidx40.i = getelementptr inbounds double, double* %arraydecay32, i64 %indvars.iv8.i
  %arrayidx42.i.195 = getelementptr inbounds double, double* %arraydecay33, i64 %indvars.iv8.i
  %arrayidx61.i = getelementptr inbounds [65 x double], [65 x double]* %arraydecay37, i64 %indvars.iv11.i, i64 %indvars.iv8.i
  %5 = bitcast double* %arrayidx61.i to i64*
  br label %for.body.9.i

for.body.9.i:                                     ; preds = %for.body.9.i, %for.cond.7.preheader.i
  %indvars.iv.i.196 = phi i64 [ 0, %for.cond.7.preheader.i ], [ %indvars.iv.next.i.197, %for.body.9.i ]
  %arrayidx13.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay25, i64 %indvars.iv11.i, i64 %indvars.iv8.i, i64 %indvars.iv.i.196
  %6 = load double, double* %arrayidx13.i, align 8, !tbaa !0
  %arrayidx19.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay25, i64 %indvars.iv11.i, i64 %indvars.iv.next9.i, i64 %indvars.iv.i.196
  %7 = load double, double* %arrayidx19.i, align 8, !tbaa !0
  %sub.i = fsub double %6, %7
  %indvars.iv.next.i.197 = add nuw nsw i64 %indvars.iv.i.196, 1
  %arrayidx26.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay26, i64 %indvars.iv11.i, i64 %indvars.iv8.i, i64 %indvars.iv.next.i.197
  %8 = load double, double* %arrayidx26.i, align 8, !tbaa !0
  %add27.i = fadd double %sub.i, %8
  %arrayidx33.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay26, i64 %indvars.iv11.i, i64 %indvars.iv8.i, i64 %indvars.iv.i.196
  %9 = load double, double* %arrayidx33.i, align 8, !tbaa !0
  %sub34.i = fsub double %add27.i, %9
  store double %sub34.i, double* %arrayidx38.i, align 8, !tbaa !0
  %10 = load double, double* %arrayidx40.i, align 8, !tbaa !0
  %11 = load double, double* %arrayidx42.i.195, align 8, !tbaa !0
  %div.i.198 = fdiv double %10, %11
  %arrayidx48.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay38, i64 %indvars.iv11.i, i64 %indvars.iv8.i, i64 %indvars.iv.i.196
  %12 = load double, double* %arrayidx48.i, align 8, !tbaa !0
  %mul.i.199 = fmul double %div.i.198, %12
  %div51.i = fdiv double 4.200000e+01, %11
  %mul56.i = fmul double %sub34.i, %div51.i
  %sub57.i = fsub double %mul.i.199, %mul56.i
  store double %sub57.i, double* %arrayidx61.i, align 8, !tbaa !0
  %arrayidx63.i.200 = getelementptr inbounds double, double* %arraydecay30, i64 %indvars.iv.i.196
  %13 = load double, double* %arrayidx63.i.200, align 8, !tbaa !0
  %arrayidx65.i = getelementptr inbounds double, double* %arraydecay31, i64 %indvars.iv.i.196
  %14 = load double, double* %arrayidx65.i, align 8, !tbaa !0
  %div66.i = fdiv double %13, %14
  %arrayidx72.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay27, i64 %indvars.iv11.i, i64 %indvars.iv8.i, i64 %indvars.iv.i.196
  %15 = load double, double* %arrayidx72.i, align 8, !tbaa !0
  %mul73.i = fmul double %div66.i, %15
  %16 = load double, double* %arrayidx75.i, align 8, !tbaa !0
  %mul76.i = fmul double %16, 2.341000e+03
  %div79.i = fdiv double %mul76.i, %14
  %mul84.i = fmul double %sub57.i, %div79.i
  %add85.i.201 = fadd double %mul73.i, %mul84.i
  %17 = load double, double* %arrayidx87.i, align 8, !tbaa !0
  %mul88.i = fmul double %17, 2.341000e+03
  %div91.i = fdiv double %mul88.i, %14
  %18 = load double, double* %arrayidx48.i, align 8, !tbaa !0
  %mul98.i = fmul double %18, %div91.i
  %sub99.i = fsub double %add85.i.201, %mul98.i
  store double %sub99.i, double* %arrayidx72.i, align 8, !tbaa !0
  %19 = load i64, i64* %5, align 8, !tbaa !0
  %20 = bitcast double* %arrayidx48.i to i64*
  store i64 %19, i64* %20, align 8, !tbaa !0
  %exitcond.i.202 = icmp eq i64 %indvars.iv.next.i.197, 64
  br i1 %exitcond.i.202, label %for.end.i, label %for.body.9.i

for.end.i:                                        ; preds = %for.body.9.i
  %arrayidx121.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay25, i64 %indvars.iv11.i, i64 %indvars.iv8.i, i64 64
  %21 = load double, double* %arrayidx121.i, align 8, !tbaa !0
  %arrayidx128.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay25, i64 %indvars.iv11.i, i64 %indvars.iv.next9.i, i64 64
  %22 = load double, double* %arrayidx128.i, align 8, !tbaa !0
  %sub129.i = fsub double %21, %22
  %arrayidx133.i = getelementptr inbounds [65 x double], [65 x double]* %arraydecay24, i64 %indvars.iv11.i, i64 %indvars.iv8.i
  %23 = load double, double* %arrayidx133.i, align 8, !tbaa !0
  %add134.i = fadd double %sub129.i, %23
  %arrayidx140.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay26, i64 %indvars.iv11.i, i64 %indvars.iv8.i, i64 64
  %24 = load double, double* %arrayidx140.i, align 8, !tbaa !0
  %sub141.i = fsub double %add134.i, %24
  store double %sub141.i, double* %arrayidx38.i, align 8, !tbaa !0
  %25 = load double, double* %arrayidx40.i, align 8, !tbaa !0
  %26 = load double, double* %arrayidx42.i.195, align 8, !tbaa !0
  %div150.i = fdiv double %25, %26
  %arrayidx156.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay38, i64 %indvars.iv11.i, i64 %indvars.iv8.i, i64 64
  %27 = load double, double* %arrayidx156.i, align 8, !tbaa !0
  %mul157.i = fmul double %div150.i, %27
  %div160.i = fdiv double 4.200000e+01, %26
  %mul165.i = fmul double %sub141.i, %div160.i
  %sub166.i = fsub double %mul157.i, %mul165.i
  store double %sub166.i, double* %arrayidx61.i, align 8, !tbaa !0
  %28 = load double, double* %0, align 8, !tbaa !0
  %29 = load double, double* %1, align 8, !tbaa !0
  %div175.i = fdiv double %28, %29
  %arrayidx181.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay27, i64 %indvars.iv11.i, i64 %indvars.iv8.i, i64 64
  %30 = load double, double* %arrayidx181.i, align 8, !tbaa !0
  %mul182.i = fmul double %div175.i, %30
  %31 = load double, double* %arrayidx75.i, align 8, !tbaa !0
  %mul185.i = fmul double %31, 2.341000e+03
  %div188.i = fdiv double %mul185.i, %29
  %mul193.i = fmul double %sub166.i, %div188.i
  %add194.i = fadd double %mul182.i, %mul193.i
  %32 = load double, double* %arrayidx87.i, align 8, !tbaa !0
  %mul197.i = fmul double %32, 2.341000e+03
  %div200.i = fdiv double %mul197.i, %29
  %33 = load double, double* %arrayidx156.i, align 8, !tbaa !0
  %mul207.i = fmul double %33, %div200.i
  %sub208.i = fsub double %add194.i, %mul207.i
  store double %sub208.i, double* %arrayidx181.i, align 8, !tbaa !0
  %34 = load i64, i64* %5, align 8, !tbaa !0
  %35 = bitcast double* %arrayidx156.i to i64*
  store i64 %34, i64* %35, align 8, !tbaa !0
  br label %for.body.227.i

for.body.227.i:                                   ; preds = %for.body.227.i, %for.end.i
  %indvars.iv5.i = phi i64 [ 0, %for.end.i ], [ %indvars.iv.next6.i, %for.body.227.i ]
  %arrayidx233.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay25, i64 %indvars.iv11.i, i64 64, i64 %indvars.iv5.i
  %36 = load double, double* %arrayidx233.i, align 8, !tbaa !0
  %arrayidx237.i = getelementptr inbounds [65 x double], [65 x double]* %arraydecay, i64 %indvars.iv11.i, i64 %indvars.iv5.i
  %37 = load double, double* %arrayidx237.i, align 8, !tbaa !0
  %sub238.i = fsub double %36, %37
  %indvars.iv.next6.i = add nuw nsw i64 %indvars.iv5.i, 1
  %arrayidx245.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay26, i64 %indvars.iv11.i, i64 64, i64 %indvars.iv.next6.i
  %38 = load double, double* %arrayidx245.i, align 8, !tbaa !0
  %add246.i = fadd double %sub238.i, %38
  %arrayidx252.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay26, i64 %indvars.iv11.i, i64 64, i64 %indvars.iv5.i
  %39 = load double, double* %arrayidx252.i, align 8, !tbaa !0
  %sub253.i = fsub double %add246.i, %39
  store double %sub253.i, double* %arrayidx38.i, align 8, !tbaa !0
  %40 = load double, double* %2, align 8, !tbaa !0
  %41 = load double, double* %arrayidx42.i.195, align 8, !tbaa !0
  %div262.i = fdiv double %40, %41
  %arrayidx268.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay38, i64 %indvars.iv11.i, i64 %indvars.iv8.i, i64 %indvars.iv5.i
  %42 = load double, double* %arrayidx268.i, align 8, !tbaa !0
  %mul269.i = fmul double %div262.i, %42
  %div272.i = fdiv double 4.200000e+01, %41
  %mul277.i = fmul double %sub253.i, %div272.i
  %sub278.i = fsub double %mul269.i, %mul277.i
  store double %sub278.i, double* %arrayidx61.i, align 8, !tbaa !0
  %arrayidx284.i = getelementptr inbounds double, double* %arraydecay30, i64 %indvars.iv5.i
  %43 = load double, double* %arrayidx284.i, align 8, !tbaa !0
  %arrayidx286.i = getelementptr inbounds double, double* %arraydecay31, i64 %indvars.iv5.i
  %44 = load double, double* %arrayidx286.i, align 8, !tbaa !0
  %div287.i = fdiv double %43, %44
  %arrayidx293.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay27, i64 %indvars.iv11.i, i64 64, i64 %indvars.iv5.i
  %45 = load double, double* %arrayidx293.i, align 8, !tbaa !0
  %mul294.i = fmul double %div287.i, %45
  %46 = load double, double* %arrayidx75.i, align 8, !tbaa !0
  %mul297.i = fmul double %46, 2.341000e+03
  %div300.i = fdiv double %mul297.i, %44
  %mul305.i = fmul double %sub278.i, %div300.i
  %add306.i = fadd double %mul294.i, %mul305.i
  %47 = load double, double* %arrayidx87.i, align 8, !tbaa !0
  %mul309.i = fmul double %47, 2.341000e+03
  %div312.i = fdiv double %mul309.i, %44
  %arrayidx318.i = getelementptr inbounds [65 x [65 x double]], [65 x [65 x double]]* %arraydecay38, i64 %indvars.iv11.i, i64 64, i64 %indvars.iv5.i
  %48 = load double, double* %arrayidx318.i, align 8, !tbaa !0
  %mul319.i = fmul double %48, %div312.i
  %sub320.i = fsub double %add306.i, %mul319.i
  store double %sub320.i, double* %arrayidx293.i, align 8, !tbaa !0
  %49 = load i64, i64* %5, align 8, !tbaa !0
  %50 = bitcast double* %arrayidx318.i to i64*
  store i64 %49, i64* %50, align 8, !tbaa !0
  %exitcond7.i = icmp eq i64 %indvars.iv.next6.i, 64
  br i1 %exitcond7.i, label %for.end.339.i, label %for.body.227.i

for.end.339.i:                                    ; preds = %for.body.227.i
  %51 = load double, double* %arrayidx345.i, align 8, !tbaa !0
  %52 = load double, double* %arrayidx349.i, align 8, !tbaa !0
  %sub350.i = fsub double %51, %52
  %53 = load double, double* %arrayidx354.i, align 8, !tbaa !0
  %add355.i = fadd double %sub350.i, %53
  %54 = load double, double* %arrayidx361.i, align 8, !tbaa !0
  %sub362.i = fsub double %add355.i, %54
  store double %sub362.i, double* %arrayidx38.i, align 8, !tbaa !0
  %55 = load double, double* %2, align 8, !tbaa !0
  %56 = load double, double* %3, align 8, !tbaa !0
  %div371.i = fdiv double %55, %56
  %57 = load double, double* %arrayidx377.i, align 8, !tbaa !0
  %mul378.i = fmul double %div371.i, %57
  %div381.i = fdiv double 4.200000e+01, %56
  %mul386.i = fmul double %sub362.i, %div381.i
  %sub387.i = fsub double %mul378.i, %mul386.i
  store double %sub387.i, double* %arrayidx61.i, align 8, !tbaa !0
  %58 = load double, double* %0, align 8, !tbaa !0
  %59 = load double, double* %1, align 8, !tbaa !0
  %div396.i = fdiv double %58, %59
  %60 = load double, double* %arrayidx402.i, align 8, !tbaa !0
  %mul403.i = fmul double %div396.i, %60
  %61 = load double, double* %arrayidx75.i, align 8, !tbaa !0
  %mul406.i = fmul double %61, 2.341000e+03
  %div409.i = fdiv double %mul406.i, %59
  %mul414.i = fmul double %sub387.i, %div409.i
  %add415.i = fadd double %mul403.i, %mul414.i
  %62 = load double, double* %arrayidx87.i, align 8, !tbaa !0
  %mul418.i = fmul double %62, 2.341000e+03
  %div421.i = fdiv double %mul418.i, %59
  %63 = load double, double* %arrayidx377.i, align 8, !tbaa !0
  %mul428.i = fmul double %63, %div421.i
  %sub429.i = fsub double %add415.i, %mul428.i
  store double %sub429.i, double* %arrayidx402.i, align 8, !tbaa !0
  %64 = load i64, i64* %5, align 8, !tbaa !0
  store i64 %64, i64* %4, align 8, !tbaa !0
  %exitcond10.i = icmp eq i64 %indvars.iv.next9.i, 64
  br i1 %exitcond10.i, label %for.inc.449.i.exitStub, label %for.cond.7.preheader.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
