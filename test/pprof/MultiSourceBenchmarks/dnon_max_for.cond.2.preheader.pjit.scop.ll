
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/McCat/18-imp/L_canny.c.dnon_max_for.cond.2.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @dnon_max_for.cond.2.preheader.pjit.scop(i1 %cmp4.257, i64, i64, i64, i64, i64, float* %Ix, float* %Iy, float* %gr, float*, i32, i32)  {
newFuncRoot:
  br label %for.cond.2.preheader

for.end.165.loopexit.exitStub:                    ; preds = %for.inc.163
  ret void

for.cond.2.preheader:                             ; preds = %for.inc.163, %newFuncRoot
  %indvars.iv270 = phi i64 [ 1, %newFuncRoot ], [ %indvars.iv.next271, %for.inc.163 ]
  br i1 %cmp4.257, label %for.body.6.lr.ph, label %for.inc.163

for.body.6.lr.ph:                                 ; preds = %for.cond.2.preheader
  %8 = mul nsw i64 %indvars.iv270, %0
  %9 = add nuw nsw i64 %indvars.iv270, 1
  %10 = mul nsw i64 %9, %1
  %11 = add nsw i64 %indvars.iv270, -1
  %12 = mul nsw i64 %11, %2
  %13 = add nuw nsw i64 %indvars.iv270, 1
  %14 = mul nsw i64 %13, %3
  %15 = add nsw i64 %indvars.iv270, -1
  %16 = mul nsw i64 %15, %4
  br label %for.body.6

for.body.6:                                       ; preds = %for.inc, %for.body.6.lr.ph
  %indvars.iv283 = phi i64 [ %indvars.iv.next284, %for.inc ], [ 1, %for.body.6.lr.ph ]
  %j.0258 = phi i32 [ 1, %for.body.6.lr.ph ], [ %inc, %for.inc ]
  %17 = trunc i64 %8 to i32
  %add = add nsw i32 %j.0258, %17
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %Ix, i64 %idxprom
  %18 = load float, float* %arrayidx, align 4, !tbaa !0
  %conv8 = fpext float %18 to double
  %cmp9 = fcmp ugt double %conv8, 1.000000e-08
  %cmp16 = fcmp ult double %conv8, -1.000000e-08
  %or.cond = or i1 %cmp9, %cmp16
  br i1 %or.cond, label %if.else, label %if.then

if.else:                                          ; preds = %for.body.6
  %arrayidx31 = getelementptr inbounds float, float* %Iy, i64 %idxprom
  %19 = load float, float* %arrayidx31, align 4, !tbaa !0
  %div = fdiv float %19, %18
  %conv36 = fpext float %div to double
  %cmp37 = fcmp oge float %div, 0.000000e+00
  %cmp41 = fcmp olt double %conv36, 4.000000e-01
  %or.cond255 = and i1 %cmp37, %cmp41
  br i1 %or.cond255, label %if.then.43, label %if.else.82

if.then.43:                                       ; preds = %if.else
  %20 = add nsw i64 %indvars.iv283, %10
  %21 = add nsw i64 %20, 1
  %arrayidx49 = getelementptr inbounds float, float* %gr, i64 %21
  %22 = load float, float* %arrayidx49, align 4, !tbaa !0
  %mul50 = fmul float %div, %22
  %conv51 = fpext float %mul50 to double
  %sub53 = fsub double 1.000000e+00, %conv36
  %arrayidx58 = getelementptr inbounds float, float* %gr, i64 %20
  %23 = load float, float* %arrayidx58, align 4, !tbaa !0
  %conv59 = fpext float %23 to double
  %mul60 = fmul double %sub53, %conv59
  %add61 = fadd double %conv51, %mul60
  %conv62 = fptrunc double %add61 to float
  %24 = add nsw i64 %indvars.iv283, %12
  %25 = add nsw i64 %24, -1
  %arrayidx68 = getelementptr inbounds float, float* %gr, i64 %25
  %26 = load float, float* %arrayidx68, align 4, !tbaa !0
  %mul69 = fmul float %div, %26
  %conv70 = fpext float %mul69 to double
  %arrayidx77 = getelementptr inbounds float, float* %gr, i64 %24
  %27 = load float, float* %arrayidx77, align 4, !tbaa !0
  %conv78 = fpext float %27 to double
  %mul79 = fmul double %sub53, %conv78
  %add80 = fadd double %conv70, %mul79
  %conv81 = fptrunc double %add80 to float
  br label %if.end.137

if.end.137:                                       ; preds = %if.then, %if.then.90, %if.then.43
  %ampl1.0 = phi float [ %39, %if.then ], [ %conv62, %if.then.43 ], [ %conv110, %if.then.90 ]
  %ampl2.0 = phi float [ %40, %if.then ], [ %conv81, %if.then.43 ], [ %conv130, %if.then.90 ]
  %arrayidx141 = getelementptr inbounds float, float* %gr, i64 %idxprom
  %28 = load float, float* %arrayidx141, align 4, !tbaa !0
  %conv142 = fpext float %28 to double
  %conv143 = fpext float %ampl1.0 to double
  %add144 = fadd double %conv143, 1.000000e-08
  %cmp145 = fcmp ogt double %conv142, %add144
  br i1 %cmp145, label %land.lhs.true.147, label %for.inc

land.lhs.true.147:                                ; preds = %if.end.137
  %conv153 = fpext float %ampl2.0 to double
  %add154 = fadd double %conv153, 1.000000e-08
  %cmp155 = fcmp ogt double %conv142, %add154
  br i1 %cmp155, label %if.then.157, label %for.inc

if.then.157:                                      ; preds = %land.lhs.true.147
  %arrayidx161 = getelementptr inbounds float, float* %5, i64 %idxprom
  store float 2.550000e+02, float* %arrayidx161, align 4, !tbaa !0
  br label %for.inc

for.inc:                                          ; preds = %if.else.131, %if.then.157, %land.lhs.true.147, %if.end.137
  %indvars.iv.next284 = add nuw nsw i64 %indvars.iv283, 1
  %inc = add nuw nsw i32 %j.0258, 1
  %lftr.wideiv285 = trunc i64 %indvars.iv.next284 to i32
  %exitcond286 = icmp eq i32 %lftr.wideiv285, %6
  br i1 %exitcond286, label %for.inc.163.loopexit, label %for.body.6

for.inc.163.loopexit:                             ; preds = %for.inc
  br label %for.inc.163

for.inc.163:                                      ; preds = %for.inc.163.loopexit, %for.cond.2.preheader
  %indvars.iv.next271 = add nuw nsw i64 %indvars.iv270, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next271 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %7
  br i1 %exitcond, label %for.end.165.loopexit.exitStub, label %for.cond.2.preheader

if.else.82:                                       ; preds = %if.else
  %cmp84 = fcmp ole float %div, 0.000000e+00
  %cmp88 = fcmp ogt double %conv36, -4.000000e-01
  %or.cond256 = and i1 %cmp84, %cmp88
  br i1 %or.cond256, label %if.then.90, label %if.else.131

if.then.90:                                       ; preds = %if.else.82
  %29 = add nsw i64 %indvars.iv283, %14
  %30 = add nsw i64 %29, -1
  %arrayidx96 = getelementptr inbounds float, float* %gr, i64 %30
  %31 = load float, float* %arrayidx96, align 4, !tbaa !0
  %32 = fmul float %div, %31
  %mul98 = fsub float -0.000000e+00, %32
  %conv99 = fpext float %mul98 to double
  %add101 = fadd double %conv36, 1.000000e+00
  %arrayidx106 = getelementptr inbounds float, float* %gr, i64 %29
  %33 = load float, float* %arrayidx106, align 4, !tbaa !0
  %conv107 = fpext float %33 to double
  %mul108 = fmul double %add101, %conv107
  %add109 = fadd double %conv99, %mul108
  %conv110 = fptrunc double %add109 to float
  %34 = add nsw i64 %indvars.iv283, %16
  %35 = add nsw i64 %34, 1
  %arrayidx116 = getelementptr inbounds float, float* %gr, i64 %35
  %36 = load float, float* %arrayidx116, align 4, !tbaa !0
  %37 = fmul float %div, %36
  %mul118 = fsub float -0.000000e+00, %37
  %conv119 = fpext float %mul118 to double
  %arrayidx126 = getelementptr inbounds float, float* %gr, i64 %34
  %38 = load float, float* %arrayidx126, align 4, !tbaa !0
  %conv127 = fpext float %38 to double
  %mul128 = fmul double %add101, %conv127
  %add129 = fadd double %conv119, %mul128
  %conv130 = fptrunc double %add129 to float
  br label %if.end.137

if.else.131:                                      ; preds = %if.else.82
  %arrayidx135 = getelementptr inbounds float, float* %5, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx135, align 4, !tbaa !0
  br label %for.inc

if.then:                                          ; preds = %for.body.6
  %sub20 = add nsw i32 %add, -1
  %idxprom21 = sext i32 %sub20 to i64
  %arrayidx22 = getelementptr inbounds float, float* %gr, i64 %idxprom21
  %39 = load float, float* %arrayidx22, align 4, !tbaa !0
  %add25 = add nsw i32 %add, 1
  %idxprom26 = sext i32 %add25 to i64
  %arrayidx27 = getelementptr inbounds float, float* %gr, i64 %idxprom26
  %40 = load float, float* %arrayidx27, align 4, !tbaa !0
  br label %if.end.137
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
