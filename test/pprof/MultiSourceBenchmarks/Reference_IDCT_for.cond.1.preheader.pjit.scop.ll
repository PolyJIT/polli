
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/mediabench/mpeg2/mpeg2dec/idctref.c.Reference_IDCT_for.cond.1.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @Reference_IDCT_for.cond.1.preheader.pjit.scop(i16* %block, [64 x double]* %tmp, [8 x [8 x double]]* nonnull %c)  {
newFuncRoot:
  br label %for.cond.1.preheader

for.end.69.exitStub:                              ; preds = %for.inc.67
  ret void

for.cond.1.preheader:                             ; preds = %for.inc.21, %newFuncRoot
  %indvars.iv128 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next129, %for.inc.21 ]
  %0 = shl i64 %indvars.iv128, 3
  %1 = shl i64 %indvars.iv128, 3
  br label %for.body.6

for.body.6:                                       ; preds = %for.body.6, %for.cond.1.preheader
  %indvars.iv124 = phi i64 [ 0, %for.cond.1.preheader ], [ %indvars.iv.next125, %for.body.6 ]
  %arrayidx8 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 0, i64 %indvars.iv124
  %2 = load double, double* %arrayidx8, align 8, !tbaa !0
  %arrayidx10 = getelementptr inbounds i16, i16* %block, i64 %0
  %3 = load i16, i16* %arrayidx10, align 2, !tbaa !4
  %conv11 = sitofp i16 %3 to double
  %mul12 = fmul double %2, %conv11
  %add13 = fadd double %mul12, 0.000000e+00
  %arrayidx8.1 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 1, i64 %indvars.iv124
  %4 = load double, double* %arrayidx8.1, align 8, !tbaa !0
  %5 = or i64 %0, 1
  %arrayidx10.1 = getelementptr inbounds i16, i16* %block, i64 %5
  %6 = load i16, i16* %arrayidx10.1, align 2, !tbaa !4
  %conv11.1 = sitofp i16 %6 to double
  %mul12.1 = fmul double %4, %conv11.1
  %add13.1 = fadd double %add13, %mul12.1
  %arrayidx8.2 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 2, i64 %indvars.iv124
  %7 = load double, double* %arrayidx8.2, align 8, !tbaa !0
  %8 = or i64 %0, 2
  %arrayidx10.2 = getelementptr inbounds i16, i16* %block, i64 %8
  %9 = load i16, i16* %arrayidx10.2, align 2, !tbaa !4
  %conv11.2 = sitofp i16 %9 to double
  %mul12.2 = fmul double %7, %conv11.2
  %add13.2 = fadd double %add13.1, %mul12.2
  %arrayidx8.3 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 3, i64 %indvars.iv124
  %10 = load double, double* %arrayidx8.3, align 8, !tbaa !0
  %11 = or i64 %0, 3
  %arrayidx10.3 = getelementptr inbounds i16, i16* %block, i64 %11
  %12 = load i16, i16* %arrayidx10.3, align 2, !tbaa !4
  %conv11.3 = sitofp i16 %12 to double
  %mul12.3 = fmul double %10, %conv11.3
  %add13.3 = fadd double %add13.2, %mul12.3
  %arrayidx8.4 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 4, i64 %indvars.iv124
  %13 = load double, double* %arrayidx8.4, align 8, !tbaa !0
  %14 = or i64 %0, 4
  %arrayidx10.4 = getelementptr inbounds i16, i16* %block, i64 %14
  %15 = load i16, i16* %arrayidx10.4, align 2, !tbaa !4
  %conv11.4 = sitofp i16 %15 to double
  %mul12.4 = fmul double %13, %conv11.4
  %add13.4 = fadd double %add13.3, %mul12.4
  %arrayidx8.5 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 5, i64 %indvars.iv124
  %16 = load double, double* %arrayidx8.5, align 8, !tbaa !0
  %17 = or i64 %0, 5
  %arrayidx10.5 = getelementptr inbounds i16, i16* %block, i64 %17
  %18 = load i16, i16* %arrayidx10.5, align 2, !tbaa !4
  %conv11.5 = sitofp i16 %18 to double
  %mul12.5 = fmul double %16, %conv11.5
  %add13.5 = fadd double %add13.4, %mul12.5
  %arrayidx8.6 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 6, i64 %indvars.iv124
  %19 = load double, double* %arrayidx8.6, align 8, !tbaa !0
  %20 = or i64 %0, 6
  %arrayidx10.6 = getelementptr inbounds i16, i16* %block, i64 %20
  %21 = load i16, i16* %arrayidx10.6, align 2, !tbaa !4
  %conv11.6 = sitofp i16 %21 to double
  %mul12.6 = fmul double %19, %conv11.6
  %add13.6 = fadd double %add13.5, %mul12.6
  %arrayidx8.7 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 7, i64 %indvars.iv124
  %22 = load double, double* %arrayidx8.7, align 8, !tbaa !0
  %23 = or i64 %0, 7
  %arrayidx10.7 = getelementptr inbounds i16, i16* %block, i64 %23
  %24 = load i16, i16* %arrayidx10.7, align 2, !tbaa !4
  %conv11.7 = sitofp i16 %24 to double
  %mul12.7 = fmul double %22, %conv11.7
  %add13.7 = fadd double %add13.6, %mul12.7
  %25 = add nuw nsw i64 %indvars.iv124, %1
  %arrayidx17 = getelementptr inbounds [64 x double], [64 x double]* %tmp, i64 0, i64 %25
  store double %add13.7, double* %arrayidx17, align 8, !tbaa !0
  %indvars.iv.next125 = add nuw nsw i64 %indvars.iv124, 1
  %exitcond127 = icmp eq i64 %indvars.iv.next125, 8
  br i1 %exitcond127, label %for.inc.21, label %for.body.6

for.inc.21:                                       ; preds = %for.body.6
  %indvars.iv.next129 = add nuw nsw i64 %indvars.iv128, 1
  %exitcond132 = icmp eq i64 %indvars.iv.next129, 8
  br i1 %exitcond132, label %for.cond.28.preheader.preheader, label %for.cond.1.preheader

for.cond.28.preheader.preheader:                  ; preds = %for.inc.21
  br label %for.cond.28.preheader

for.cond.28.preheader:                            ; preds = %for.inc.67, %for.cond.28.preheader.preheader
  %indvars.iv117 = phi i64 [ %indvars.iv.next118, %for.inc.67 ], [ 0, %for.cond.28.preheader.preheader ]
  br label %for.body.35

for.body.35:                                      ; preds = %for.body.35, %for.cond.28.preheader
  %indvars.iv112 = phi i64 [ 0, %for.cond.28.preheader ], [ %indvars.iv.next113, %for.body.35 ]
  %arrayidx39 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 0, i64 %indvars.iv112
  %26 = load double, double* %arrayidx39, align 8, !tbaa !0
  %arrayidx43 = getelementptr inbounds [64 x double], [64 x double]* %tmp, i64 0, i64 %indvars.iv117
  %27 = load double, double* %arrayidx43, align 8, !tbaa !0
  %mul44 = fmul double %26, %27
  %add45 = fadd double %mul44, 0.000000e+00
  %arrayidx39.1 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 1, i64 %indvars.iv112
  %28 = load double, double* %arrayidx39.1, align 8, !tbaa !0
  %29 = add nuw nsw i64 %indvars.iv117, 8
  %arrayidx43.1 = getelementptr inbounds [64 x double], [64 x double]* %tmp, i64 0, i64 %29
  %30 = load double, double* %arrayidx43.1, align 8, !tbaa !0
  %mul44.1 = fmul double %28, %30
  %add45.1 = fadd double %add45, %mul44.1
  %arrayidx39.2 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 2, i64 %indvars.iv112
  %31 = load double, double* %arrayidx39.2, align 8, !tbaa !0
  %32 = add nuw nsw i64 %indvars.iv117, 16
  %arrayidx43.2 = getelementptr inbounds [64 x double], [64 x double]* %tmp, i64 0, i64 %32
  %33 = load double, double* %arrayidx43.2, align 8, !tbaa !0
  %mul44.2 = fmul double %31, %33
  %add45.2 = fadd double %add45.1, %mul44.2
  %arrayidx39.3 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 3, i64 %indvars.iv112
  %34 = load double, double* %arrayidx39.3, align 8, !tbaa !0
  %35 = add nuw nsw i64 %indvars.iv117, 24
  %arrayidx43.3 = getelementptr inbounds [64 x double], [64 x double]* %tmp, i64 0, i64 %35
  %36 = load double, double* %arrayidx43.3, align 8, !tbaa !0
  %mul44.3 = fmul double %34, %36
  %add45.3 = fadd double %add45.2, %mul44.3
  %arrayidx39.4 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 4, i64 %indvars.iv112
  %37 = load double, double* %arrayidx39.4, align 8, !tbaa !0
  %38 = add nuw nsw i64 %indvars.iv117, 32
  %arrayidx43.4 = getelementptr inbounds [64 x double], [64 x double]* %tmp, i64 0, i64 %38
  %39 = load double, double* %arrayidx43.4, align 8, !tbaa !0
  %mul44.4 = fmul double %37, %39
  %add45.4 = fadd double %add45.3, %mul44.4
  %arrayidx39.5 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 5, i64 %indvars.iv112
  %40 = load double, double* %arrayidx39.5, align 8, !tbaa !0
  %41 = add nuw nsw i64 %indvars.iv117, 40
  %arrayidx43.5 = getelementptr inbounds [64 x double], [64 x double]* %tmp, i64 0, i64 %41
  %42 = load double, double* %arrayidx43.5, align 8, !tbaa !0
  %mul44.5 = fmul double %40, %42
  %add45.5 = fadd double %add45.4, %mul44.5
  %arrayidx39.6 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 6, i64 %indvars.iv112
  %43 = load double, double* %arrayidx39.6, align 8, !tbaa !0
  %44 = add nuw nsw i64 %indvars.iv117, 48
  %arrayidx43.6 = getelementptr inbounds [64 x double], [64 x double]* %tmp, i64 0, i64 %44
  %45 = load double, double* %arrayidx43.6, align 8, !tbaa !0
  %mul44.6 = fmul double %43, %45
  %add45.6 = fadd double %add45.5, %mul44.6
  %arrayidx39.7 = getelementptr inbounds [8 x [8 x double]], [8 x [8 x double]]* %c, i64 0, i64 7, i64 %indvars.iv112
  %46 = load double, double* %arrayidx39.7, align 8, !tbaa !0
  %47 = add nuw nsw i64 %indvars.iv117, 56
  %arrayidx43.7 = getelementptr inbounds [64 x double], [64 x double]* %tmp, i64 0, i64 %47
  %48 = load double, double* %arrayidx43.7, align 8, !tbaa !0
  %mul44.7 = fmul double %46, %48
  %add45.7 = fadd double %add45.6, %mul44.7
  %add49 = fadd double %add45.7, 5.000000e-01
  %call = tail call double @floor(double %add49) #2
  %conv50 = fptosi double %call to i32
  %cmp51 = icmp slt i32 %conv50, -256
  %cmp53 = icmp sgt i32 %conv50, 255
  %cond = select i1 %cmp53, i32 255, i32 %conv50
  %49 = trunc i32 %cond to i16
  %conv59 = select i1 %cmp51, i16 -256, i16 %49
  %50 = shl i64 %indvars.iv112, 3
  %51 = add nuw nsw i64 %50, %indvars.iv117
  %arrayidx63 = getelementptr inbounds i16, i16* %block, i64 %51
  store i16 %conv59, i16* %arrayidx63, align 2, !tbaa !4
  %indvars.iv.next113 = add nuw nsw i64 %indvars.iv112, 1
  %exitcond116 = icmp eq i64 %indvars.iv.next113, 8
  br i1 %exitcond116, label %for.inc.67, label %for.body.35

for.inc.67:                                       ; preds = %for.body.35
  %indvars.iv.next118 = add nuw nsw i64 %indvars.iv117, 1
  %exitcond119 = icmp eq i64 %indvars.iv.next118, 8
  br i1 %exitcond119, label %for.end.69.exitStub, label %for.cond.28.preheader
}

; Function Attrs: nounwind readnone
declare double @floor(double) #1

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }
attributes #1 = { nounwind readnone "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"short", !2, i64 0}
