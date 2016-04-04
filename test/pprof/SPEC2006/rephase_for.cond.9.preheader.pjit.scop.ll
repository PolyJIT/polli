
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/433.milc/src/rephase.c.rephase_for.cond.9.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.site = type { i16, i16, i16, i16, i8, i32, %struct.double_prn, i32, [4 x %struct.su3_matrix], [4 x %struct.anti_hermitmat], [4 x double], %struct.su3_vector, %struct.su3_vector, %struct.su3_vector, %struct.su3_vector, %struct.su3_vector, %struct.su3_vector, [4 x %struct.su3_vector], [4 x %struct.su3_vector], %struct.su3_vector, %struct.su3_matrix, %struct.su3_matrix }
%struct.double_prn = type { i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, double }
%struct.anti_hermitmat = type { %struct.complex, %struct.complex, %struct.complex, double, double, double, double }
%struct.complex = type { double, double }
%struct.su3_vector = type { [3 x %struct.complex] }
%struct.su3_matrix = type { [3 x [3 x %struct.complex]] }

; Function Attrs: nounwind
define weak void @rephase_for.cond.9.preheader.pjit.scop(%struct.site*, i32)  {
newFuncRoot:
  br label %for.cond.9.preheader

for.end.44.exitStub:                              ; preds = %for.end.44.loopexit
  ret void

for.cond.9.preheader:                             ; preds = %for.inc.42, %newFuncRoot
  %s.074 = phi %struct.site* [ %0, %newFuncRoot ], [ %incdec.ptr, %for.inc.42 ]
  %i.073 = phi i32 [ 0, %newFuncRoot ], [ %inc43, %for.inc.42 ]
  br label %for.cond.12.preheader

for.cond.12.preheader:                            ; preds = %for.cond.12.preheader, %for.cond.9.preheader
  %indvars.iv78 = phi i64 [ 0, %for.cond.9.preheader ], [ %indvars.iv.next79, %for.cond.12.preheader ]
  %arrayidx = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 10, i64 %indvars.iv78
  %2 = load double, double* %arrayidx, align 8, !tbaa !0
  %real = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 0, i64 0, i32 0
  %3 = load double, double* %real, align 8, !tbaa !4
  %mul = fmul double %2, %3
  store double %mul, double* %real, align 8, !tbaa !4
  %4 = load double, double* %arrayidx, align 8, !tbaa !0
  %imag = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 0, i64 0, i32 1
  %5 = load double, double* %imag, align 8, !tbaa !6
  %mul35 = fmul double %4, %5
  store double %mul35, double* %imag, align 8, !tbaa !6
  %6 = load double, double* %arrayidx, align 8, !tbaa !0
  %real.1 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 0, i64 1, i32 0
  %7 = load double, double* %real.1, align 8, !tbaa !4
  %mul.1 = fmul double %6, %7
  store double %mul.1, double* %real.1, align 8, !tbaa !4
  %8 = load double, double* %arrayidx, align 8, !tbaa !0
  %imag.1 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 0, i64 1, i32 1
  %9 = load double, double* %imag.1, align 8, !tbaa !6
  %mul35.1 = fmul double %8, %9
  store double %mul35.1, double* %imag.1, align 8, !tbaa !6
  %10 = load double, double* %arrayidx, align 8, !tbaa !0
  %real.2 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 0, i64 2, i32 0
  %11 = load double, double* %real.2, align 8, !tbaa !4
  %mul.2 = fmul double %10, %11
  store double %mul.2, double* %real.2, align 8, !tbaa !4
  %12 = load double, double* %arrayidx, align 8, !tbaa !0
  %imag.2 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 0, i64 2, i32 1
  %13 = load double, double* %imag.2, align 8, !tbaa !6
  %mul35.2 = fmul double %12, %13
  store double %mul35.2, double* %imag.2, align 8, !tbaa !6
  %14 = load double, double* %arrayidx, align 8, !tbaa !0
  %real.1.81 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 1, i64 0, i32 0
  %15 = load double, double* %real.1.81, align 8, !tbaa !4
  %mul.1.82 = fmul double %14, %15
  store double %mul.1.82, double* %real.1.81, align 8, !tbaa !4
  %16 = load double, double* %arrayidx, align 8, !tbaa !0
  %imag.1.83 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 1, i64 0, i32 1
  %17 = load double, double* %imag.1.83, align 8, !tbaa !6
  %mul35.1.84 = fmul double %16, %17
  store double %mul35.1.84, double* %imag.1.83, align 8, !tbaa !6
  %18 = load double, double* %arrayidx, align 8, !tbaa !0
  %real.1.1 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 1, i64 1, i32 0
  %19 = load double, double* %real.1.1, align 8, !tbaa !4
  %mul.1.1 = fmul double %18, %19
  store double %mul.1.1, double* %real.1.1, align 8, !tbaa !4
  %20 = load double, double* %arrayidx, align 8, !tbaa !0
  %imag.1.1 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 1, i64 1, i32 1
  %21 = load double, double* %imag.1.1, align 8, !tbaa !6
  %mul35.1.1 = fmul double %20, %21
  store double %mul35.1.1, double* %imag.1.1, align 8, !tbaa !6
  %22 = load double, double* %arrayidx, align 8, !tbaa !0
  %real.2.1 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 1, i64 2, i32 0
  %23 = load double, double* %real.2.1, align 8, !tbaa !4
  %mul.2.1 = fmul double %22, %23
  store double %mul.2.1, double* %real.2.1, align 8, !tbaa !4
  %24 = load double, double* %arrayidx, align 8, !tbaa !0
  %imag.2.1 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 1, i64 2, i32 1
  %25 = load double, double* %imag.2.1, align 8, !tbaa !6
  %mul35.2.1 = fmul double %24, %25
  store double %mul35.2.1, double* %imag.2.1, align 8, !tbaa !6
  %26 = load double, double* %arrayidx, align 8, !tbaa !0
  %real.2.85 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 2, i64 0, i32 0
  %27 = load double, double* %real.2.85, align 8, !tbaa !4
  %mul.2.86 = fmul double %26, %27
  store double %mul.2.86, double* %real.2.85, align 8, !tbaa !4
  %28 = load double, double* %arrayidx, align 8, !tbaa !0
  %imag.2.87 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 2, i64 0, i32 1
  %29 = load double, double* %imag.2.87, align 8, !tbaa !6
  %mul35.2.88 = fmul double %28, %29
  store double %mul35.2.88, double* %imag.2.87, align 8, !tbaa !6
  %30 = load double, double* %arrayidx, align 8, !tbaa !0
  %real.1.2 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 2, i64 1, i32 0
  %31 = load double, double* %real.1.2, align 8, !tbaa !4
  %mul.1.2 = fmul double %30, %31
  store double %mul.1.2, double* %real.1.2, align 8, !tbaa !4
  %32 = load double, double* %arrayidx, align 8, !tbaa !0
  %imag.1.2 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 2, i64 1, i32 1
  %33 = load double, double* %imag.1.2, align 8, !tbaa !6
  %mul35.1.2 = fmul double %32, %33
  store double %mul35.1.2, double* %imag.1.2, align 8, !tbaa !6
  %34 = load double, double* %arrayidx, align 8, !tbaa !0
  %real.2.2 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 2, i64 2, i32 0
  %35 = load double, double* %real.2.2, align 8, !tbaa !4
  %mul.2.2 = fmul double %34, %35
  store double %mul.2.2, double* %real.2.2, align 8, !tbaa !4
  %36 = load double, double* %arrayidx, align 8, !tbaa !0
  %imag.2.2 = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 0, i32 8, i64 %indvars.iv78, i32 0, i64 2, i64 2, i32 1
  %37 = load double, double* %imag.2.2, align 8, !tbaa !6
  %mul35.2.2 = fmul double %36, %37
  store double %mul35.2.2, double* %imag.2.2, align 8, !tbaa !6
  %indvars.iv.next79 = add nuw nsw i64 %indvars.iv78, 1
  %exitcond80 = icmp eq i64 %indvars.iv.next79, 4
  br i1 %exitcond80, label %for.inc.42, label %for.cond.12.preheader

for.inc.42:                                       ; preds = %for.cond.12.preheader
  %inc43 = add nuw nsw i32 %i.073, 1
  %incdec.ptr = getelementptr inbounds %struct.site, %struct.site* %s.074, i64 1
  %cmp8 = icmp slt i32 %inc43, %1
  br i1 %cmp8, label %for.cond.9.preheader, label %for.end.44.loopexit

for.end.44.loopexit:                              ; preds = %for.inc.42
  br label %for.end.44.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !1, i64 0}
!5 = !{!"", !1, i64 0, !1, i64 8}
!6 = !{!5, !1, i64 8}
