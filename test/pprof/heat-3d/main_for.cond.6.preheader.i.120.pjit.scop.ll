
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'heat-3d.dir/heat-3d.c.main_for.cond.6.preheader.i.120.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.6.preheader.i.120.pjit.scop(double*, double*)  {
newFuncRoot:
  br label %for.cond.6.preheader.i.120

kernel_heat_3d.exit.exitStub:                     ; preds = %for.inc.215.i
  ret void

for.cond.6.preheader.i.120:                       ; preds = %for.inc.215.i, %newFuncRoot
  %t.07.i = phi i32 [ %inc216.i, %for.inc.215.i ], [ 1, %newFuncRoot ]
  br label %for.cond.9.preheader.i.122

for.cond.9.preheader.i.122:                       ; preds = %for.inc.104.i, %for.cond.6.preheader.i.120
  %indvars.iv13.i = phi i64 [ 1, %for.cond.6.preheader.i.120 ], [ %indvars.iv.next14.i, %for.inc.104.i ]
  %indvars.iv.next14.i = add nuw nsw i64 %indvars.iv13.i, 1
  %2 = mul nuw nsw i64 %indvars.iv.next14.i, 14400
  %arrayidx.i.121 = getelementptr inbounds double, double* %0, i64 %2
  %3 = mul nuw nsw i64 %indvars.iv13.i, 14400
  %arrayidx25.i = getelementptr inbounds double, double* %0, i64 %3
  %4 = add nsw i64 %3, -14400
  %arrayidx33.i = getelementptr inbounds double, double* %0, i64 %4
  %arrayidx98.i = getelementptr inbounds double, double* %1, i64 %3
  br label %for.cond.13.preheader.i

for.cond.13.preheader.i:                          ; preds = %for.inc.101.i, %for.cond.9.preheader.i.122
  %indvars.iv9.i.123 = phi i64 [ 1, %for.cond.9.preheader.i.122 ], [ %indvars.iv.next10.i.124, %for.inc.101.i ]
  %5 = mul nuw nsw i64 %indvars.iv9.i.123, 120
  %arrayidx20.i = getelementptr inbounds double, double* %arrayidx.i.121, i64 %5
  %arrayidx26.i = getelementptr inbounds double, double* %arrayidx25.i, i64 %5
  %arrayidx34.i = getelementptr inbounds double, double* %arrayidx33.i, i64 %5
  %indvars.iv.next10.i.124 = add nuw nsw i64 %indvars.iv9.i.123, 1
  %6 = mul nuw nsw i64 %indvars.iv.next10.i.124, 120
  %arrayidx43.i = getelementptr inbounds double, double* %arrayidx25.i, i64 %6
  %7 = add nsw i64 %5, -120
  %arrayidx58.i = getelementptr inbounds double, double* %arrayidx25.i, i64 %7
  %arrayidx99.i = getelementptr inbounds double, double* %arrayidx98.i, i64 %5
  br label %for.body.16.i

for.body.16.i:                                    ; preds = %for.body.16.i, %for.cond.13.preheader.i
  %indvars.iv.i.125 = phi i64 [ 1, %for.cond.13.preheader.i ], [ %indvars.iv.next.i.127, %for.body.16.i ]
  %arrayidx21.i = getelementptr inbounds double, double* %arrayidx20.i, i64 %indvars.iv.i.125
  %8 = load double, double* %arrayidx21.i, align 8, !tbaa !0
  %arrayidx27.i = getelementptr inbounds double, double* %arrayidx26.i, i64 %indvars.iv.i.125
  %9 = load double, double* %arrayidx27.i, align 8, !tbaa !0
  %mul.i.126 = fmul double %9, 2.000000e+00
  %sub28.i = fsub double %8, %mul.i.126
  %arrayidx35.i = getelementptr inbounds double, double* %arrayidx34.i, i64 %indvars.iv.i.125
  %10 = load double, double* %arrayidx35.i, align 8, !tbaa !0
  %add36.i = fadd double %10, %sub28.i
  %mul37.i = fmul double %add36.i, 1.250000e-01
  %arrayidx44.i = getelementptr inbounds double, double* %arrayidx43.i, i64 %indvars.iv.i.125
  %11 = load double, double* %arrayidx44.i, align 8, !tbaa !0
  %sub52.i = fsub double %11, %mul.i.126
  %arrayidx59.i = getelementptr inbounds double, double* %arrayidx58.i, i64 %indvars.iv.i.125
  %12 = load double, double* %arrayidx59.i, align 8, !tbaa !0
  %add60.i = fadd double %sub52.i, %12
  %mul61.i = fmul double %add60.i, 1.250000e-01
  %add62.i = fadd double %mul37.i, %mul61.i
  %indvars.iv.next.i.127 = add nuw nsw i64 %indvars.iv.i.125, 1
  %arrayidx69.i = getelementptr inbounds double, double* %arrayidx26.i, i64 %indvars.iv.next.i.127
  %13 = load double, double* %arrayidx69.i, align 8, !tbaa !0
  %sub77.i = fsub double %13, %mul.i.126
  %14 = add nsw i64 %indvars.iv.i.125, -1
  %arrayidx84.i = getelementptr inbounds double, double* %arrayidx26.i, i64 %14
  %15 = load double, double* %arrayidx84.i, align 8, !tbaa !0
  %add85.i = fadd double %sub77.i, %15
  %mul86.i = fmul double %add85.i, 1.250000e-01
  %add87.i = fadd double %add62.i, %mul86.i
  %add94.i = fadd double %9, %add87.i
  %arrayidx100.i = getelementptr inbounds double, double* %arrayidx99.i, i64 %indvars.iv.i.125
  store double %add94.i, double* %arrayidx100.i, align 8, !tbaa !0
  %exitcond.i.128 = icmp eq i64 %indvars.iv.next.i.127, 119
  br i1 %exitcond.i.128, label %for.inc.101.i, label %for.body.16.i

for.inc.101.i:                                    ; preds = %for.body.16.i
  %exitcond12.i.129 = icmp eq i64 %indvars.iv.next10.i.124, 119
  br i1 %exitcond12.i.129, label %for.inc.104.i, label %for.cond.13.preheader.i

for.inc.104.i:                                    ; preds = %for.inc.101.i
  %exitcond16.i = icmp eq i64 %indvars.iv.next14.i, 119
  br i1 %exitcond16.i, label %for.cond.111.preheader.i.preheader, label %for.cond.9.preheader.i.122

for.cond.111.preheader.i.preheader:               ; preds = %for.inc.104.i
  br label %for.cond.111.preheader.i

for.cond.111.preheader.i:                         ; preds = %for.inc.212.i, %for.cond.111.preheader.i.preheader
  %indvars.iv25.i = phi i64 [ %indvars.iv.next26.i, %for.inc.212.i ], [ 1, %for.cond.111.preheader.i.preheader ]
  %indvars.iv.next26.i = add nuw nsw i64 %indvars.iv25.i, 1
  %16 = mul nuw nsw i64 %indvars.iv.next26.i, 14400
  %arrayidx123.i = getelementptr inbounds double, double* %1, i64 %16
  %17 = mul nuw nsw i64 %indvars.iv25.i, 14400
  %arrayidx129.i = getelementptr inbounds double, double* %1, i64 %17
  %18 = add nsw i64 %17, -14400
  %arrayidx138.i = getelementptr inbounds double, double* %1, i64 %18
  %arrayidx203.i = getelementptr inbounds double, double* %0, i64 %17
  br label %for.cond.115.preheader.i

for.cond.115.preheader.i:                         ; preds = %for.inc.209.i, %for.cond.111.preheader.i
  %indvars.iv21.i = phi i64 [ 1, %for.cond.111.preheader.i ], [ %indvars.iv.next22.i, %for.inc.209.i ]
  %19 = mul nuw nsw i64 %indvars.iv21.i, 120
  %arrayidx124.i = getelementptr inbounds double, double* %arrayidx123.i, i64 %19
  %arrayidx130.i = getelementptr inbounds double, double* %arrayidx129.i, i64 %19
  %arrayidx139.i = getelementptr inbounds double, double* %arrayidx138.i, i64 %19
  %indvars.iv.next22.i = add nuw nsw i64 %indvars.iv21.i, 1
  %20 = mul nuw nsw i64 %indvars.iv.next22.i, 120
  %arrayidx148.i = getelementptr inbounds double, double* %arrayidx129.i, i64 %20
  %21 = add nsw i64 %19, -120
  %arrayidx163.i = getelementptr inbounds double, double* %arrayidx129.i, i64 %21
  %arrayidx204.i = getelementptr inbounds double, double* %arrayidx203.i, i64 %19
  br label %for.body.118.i

for.body.118.i:                                   ; preds = %for.body.118.i, %for.cond.115.preheader.i
  %indvars.iv17.i = phi i64 [ 1, %for.cond.115.preheader.i ], [ %indvars.iv.next18.i, %for.body.118.i ]
  %arrayidx125.i = getelementptr inbounds double, double* %arrayidx124.i, i64 %indvars.iv17.i
  %22 = load double, double* %arrayidx125.i, align 8, !tbaa !0
  %arrayidx131.i = getelementptr inbounds double, double* %arrayidx130.i, i64 %indvars.iv17.i
  %23 = load double, double* %arrayidx131.i, align 8, !tbaa !0
  %mul132.i = fmul double %23, 2.000000e+00
  %sub133.i = fsub double %22, %mul132.i
  %arrayidx140.i = getelementptr inbounds double, double* %arrayidx139.i, i64 %indvars.iv17.i
  %24 = load double, double* %arrayidx140.i, align 8, !tbaa !0
  %add141.i = fadd double %24, %sub133.i
  %mul142.i = fmul double %add141.i, 1.250000e-01
  %arrayidx149.i = getelementptr inbounds double, double* %arrayidx148.i, i64 %indvars.iv17.i
  %25 = load double, double* %arrayidx149.i, align 8, !tbaa !0
  %sub157.i = fsub double %25, %mul132.i
  %arrayidx164.i = getelementptr inbounds double, double* %arrayidx163.i, i64 %indvars.iv17.i
  %26 = load double, double* %arrayidx164.i, align 8, !tbaa !0
  %add165.i = fadd double %sub157.i, %26
  %mul166.i = fmul double %add165.i, 1.250000e-01
  %add167.i = fadd double %mul142.i, %mul166.i
  %indvars.iv.next18.i = add nuw nsw i64 %indvars.iv17.i, 1
  %arrayidx174.i = getelementptr inbounds double, double* %arrayidx130.i, i64 %indvars.iv.next18.i
  %27 = load double, double* %arrayidx174.i, align 8, !tbaa !0
  %sub182.i = fsub double %27, %mul132.i
  %28 = add nsw i64 %indvars.iv17.i, -1
  %arrayidx189.i = getelementptr inbounds double, double* %arrayidx130.i, i64 %28
  %29 = load double, double* %arrayidx189.i, align 8, !tbaa !0
  %add190.i = fadd double %sub182.i, %29
  %mul191.i = fmul double %add190.i, 1.250000e-01
  %add192.i = fadd double %add167.i, %mul191.i
  %add199.i = fadd double %23, %add192.i
  %arrayidx205.i = getelementptr inbounds double, double* %arrayidx204.i, i64 %indvars.iv17.i
  store double %add199.i, double* %arrayidx205.i, align 8, !tbaa !0
  %exitcond20.i = icmp eq i64 %indvars.iv.next18.i, 119
  br i1 %exitcond20.i, label %for.inc.209.i, label %for.body.118.i

for.inc.209.i:                                    ; preds = %for.body.118.i
  %exitcond24.i = icmp eq i64 %indvars.iv.next22.i, 119
  br i1 %exitcond24.i, label %for.inc.212.i, label %for.cond.115.preheader.i

for.inc.212.i:                                    ; preds = %for.inc.209.i
  %exitcond28.i = icmp eq i64 %indvars.iv.next26.i, 119
  br i1 %exitcond28.i, label %for.inc.215.i, label %for.cond.111.preheader.i

for.inc.215.i:                                    ; preds = %for.inc.212.i
  %inc216.i = add nuw nsw i32 %t.07.i, 1
  %exitcond29.i = icmp eq i32 %inc216.i, 501
  br i1 %exitcond29.i, label %kernel_heat_3d.exit.exitStub, label %for.cond.6.preheader.i.120
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
