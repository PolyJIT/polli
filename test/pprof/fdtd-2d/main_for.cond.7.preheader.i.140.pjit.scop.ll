
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'fdtd-2d.dir/fdtd-2d.c.main_for.cond.7.preheader.i.140.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.7.preheader.i.140.pjit.scop(double*, double*, double*, double*)  {
newFuncRoot:
  br label %for.cond.7.preheader.i.140

kernel_fdtd_2d.exit.exitStub:                     ; preds = %for.inc.120.i
  ret void

for.cond.7.preheader.i.140:                       ; preds = %for.inc.120.i, %newFuncRoot
  %indvars.iv29.i = phi i64 [ %indvars.iv.next30.i, %for.inc.120.i ], [ 0, %newFuncRoot ]
  %arrayidx.i.139 = getelementptr inbounds double, double* %0, i64 %indvars.iv29.i
  %4 = bitcast double* %arrayidx.i.139 to i64*
  br label %for.body.9.i.144

for.body.9.i.144:                                 ; preds = %for.body.9.i.144, %for.cond.7.preheader.i.140
  %indvars.iv.i.141 = phi i64 [ 0, %for.cond.7.preheader.i.140 ], [ %indvars.iv.next.i.142, %for.body.9.i.144 ]
  %5 = load i64, i64* %4, align 8, !tbaa !0
  %arrayidx12.i = getelementptr inbounds double, double* %1, i64 %indvars.iv.i.141
  %6 = bitcast double* %arrayidx12.i to i64*
  store i64 %5, i64* %6, align 8, !tbaa !0
  %indvars.iv.next.i.142 = add nuw nsw i64 %indvars.iv.i.141, 1
  %exitcond.i.143 = icmp eq i64 %indvars.iv.next.i.142, 1200
  br i1 %exitcond.i.143, label %for.cond.16.preheader.i.preheader, label %for.body.9.i.144

for.cond.16.preheader.i.preheader:                ; preds = %for.body.9.i.144
  br label %for.cond.16.preheader.i

for.cond.16.preheader.i:                          ; preds = %for.inc.40.i, %for.cond.16.preheader.i.preheader
  %indvars.iv12.i = phi i64 [ %indvars.iv.next13.i, %for.inc.40.i ], [ 1, %for.cond.16.preheader.i.preheader ]
  %7 = mul nuw nsw i64 %indvars.iv12.i, 1200
  %arrayidx21.i.145 = getelementptr inbounds double, double* %1, i64 %7
  %arrayidx25.i = getelementptr inbounds double, double* %2, i64 %7
  %8 = add nsw i64 %7, -1200
  %arrayidx29.i = getelementptr inbounds double, double* %2, i64 %8
  br label %for.body.18.i

for.body.18.i:                                    ; preds = %for.body.18.i, %for.cond.16.preheader.i
  %indvars.iv9.i.146 = phi i64 [ 0, %for.cond.16.preheader.i ], [ %indvars.iv.next10.i.149, %for.body.18.i ]
  %arrayidx22.i.147 = getelementptr inbounds double, double* %arrayidx21.i.145, i64 %indvars.iv9.i.146
  %9 = load double, double* %arrayidx22.i.147, align 8, !tbaa !0
  %arrayidx26.i = getelementptr inbounds double, double* %arrayidx25.i, i64 %indvars.iv9.i.146
  %10 = load double, double* %arrayidx26.i, align 8, !tbaa !0
  %arrayidx30.i = getelementptr inbounds double, double* %arrayidx29.i, i64 %indvars.iv9.i.146
  %11 = load double, double* %arrayidx30.i, align 8, !tbaa !0
  %sub31.i = fsub double %10, %11
  %mul.i.148 = fmul double %sub31.i, 5.000000e-01
  %sub32.i = fsub double %9, %mul.i.148
  store double %sub32.i, double* %arrayidx22.i.147, align 8, !tbaa !0
  %indvars.iv.next10.i.149 = add nuw nsw i64 %indvars.iv9.i.146, 1
  %exitcond11.i.150 = icmp eq i64 %indvars.iv.next10.i.149, 1200
  br i1 %exitcond11.i.150, label %for.inc.40.i, label %for.body.18.i

for.inc.40.i:                                     ; preds = %for.body.18.i
  %indvars.iv.next13.i = add nuw nsw i64 %indvars.iv12.i, 1
  %exitcond15.i = icmp eq i64 %indvars.iv.next13.i, 1000
  br i1 %exitcond15.i, label %for.cond.46.preheader.i.preheader, label %for.cond.16.preheader.i

for.cond.46.preheader.i.preheader:                ; preds = %for.inc.40.i
  br label %for.cond.46.preheader.i

for.cond.46.preheader.i:                          ; preds = %for.inc.72.i, %for.cond.46.preheader.i.preheader
  %indvars.iv20.i = phi i64 [ %indvars.iv.next21.i, %for.inc.72.i ], [ 0, %for.cond.46.preheader.i.preheader ]
  %12 = mul nuw nsw i64 %indvars.iv20.i, 1200
  %arrayidx51.i = getelementptr inbounds double, double* %3, i64 %12
  %arrayidx55.i = getelementptr inbounds double, double* %2, i64 %12
  br label %for.body.48.i

for.body.48.i:                                    ; preds = %for.body.48.i, %for.cond.46.preheader.i
  %indvars.iv16.i = phi i64 [ 1, %for.cond.46.preheader.i ], [ %indvars.iv.next17.i, %for.body.48.i ]
  %arrayidx52.i = getelementptr inbounds double, double* %arrayidx51.i, i64 %indvars.iv16.i
  %13 = load double, double* %arrayidx52.i, align 8, !tbaa !0
  %arrayidx56.i = getelementptr inbounds double, double* %arrayidx55.i, i64 %indvars.iv16.i
  %14 = load double, double* %arrayidx56.i, align 8, !tbaa !0
  %15 = add nsw i64 %indvars.iv16.i, -1
  %arrayidx61.i = getelementptr inbounds double, double* %arrayidx55.i, i64 %15
  %16 = load double, double* %arrayidx61.i, align 8, !tbaa !0
  %sub62.i = fsub double %14, %16
  %mul63.i = fmul double %sub62.i, 5.000000e-01
  %sub64.i = fsub double %13, %mul63.i
  store double %sub64.i, double* %arrayidx52.i, align 8, !tbaa !0
  %indvars.iv.next17.i = add nuw nsw i64 %indvars.iv16.i, 1
  %exitcond19.i = icmp eq i64 %indvars.iv.next17.i, 1200
  br i1 %exitcond19.i, label %for.inc.72.i, label %for.body.48.i

for.inc.72.i:                                     ; preds = %for.body.48.i
  %indvars.iv.next21.i = add nuw nsw i64 %indvars.iv20.i, 1
  %exitcond22.i = icmp eq i64 %indvars.iv.next21.i, 1000
  br i1 %exitcond22.i, label %for.cond.79.preheader.i.preheader, label %for.cond.46.preheader.i

for.cond.79.preheader.i.preheader:                ; preds = %for.inc.72.i
  br label %for.cond.79.preheader.i

for.cond.79.preheader.i:                          ; preds = %for.inc.117.i, %for.cond.79.preheader.i.preheader
  %indvars.iv26.i.151 = phi i64 [ %indvars.iv.next27.i.152, %for.inc.117.i ], [ 0, %for.cond.79.preheader.i.preheader ]
  %17 = mul nuw nsw i64 %indvars.iv26.i.151, 1200
  %arrayidx85.i = getelementptr inbounds double, double* %2, i64 %17
  %arrayidx90.i = getelementptr inbounds double, double* %3, i64 %17
  %indvars.iv.next27.i.152 = add nuw nsw i64 %indvars.iv26.i.151, 1
  %18 = mul nuw nsw i64 %indvars.iv.next27.i.152, 1200
  %arrayidx100.i = getelementptr inbounds double, double* %1, i64 %18
  %arrayidx105.i = getelementptr inbounds double, double* %1, i64 %17
  br label %for.body.82.i

for.body.82.i:                                    ; preds = %for.body.82.i, %for.cond.79.preheader.i
  %indvars.iv23.i = phi i64 [ 0, %for.cond.79.preheader.i ], [ %indvars.iv.next24.i, %for.body.82.i ]
  %arrayidx86.i = getelementptr inbounds double, double* %arrayidx85.i, i64 %indvars.iv23.i
  %19 = load double, double* %arrayidx86.i, align 8, !tbaa !0
  %indvars.iv.next24.i = add nuw nsw i64 %indvars.iv23.i, 1
  %arrayidx91.i = getelementptr inbounds double, double* %arrayidx90.i, i64 %indvars.iv.next24.i
  %20 = load double, double* %arrayidx91.i, align 8, !tbaa !0
  %arrayidx95.i = getelementptr inbounds double, double* %arrayidx90.i, i64 %indvars.iv23.i
  %21 = load double, double* %arrayidx95.i, align 8, !tbaa !0
  %sub96.i = fsub double %20, %21
  %arrayidx101.i = getelementptr inbounds double, double* %arrayidx100.i, i64 %indvars.iv23.i
  %22 = load double, double* %arrayidx101.i, align 8, !tbaa !0
  %add102.i = fadd double %sub96.i, %22
  %arrayidx106.i = getelementptr inbounds double, double* %arrayidx105.i, i64 %indvars.iv23.i
  %23 = load double, double* %arrayidx106.i, align 8, !tbaa !0
  %sub107.i = fsub double %add102.i, %23
  %mul108.i = fmul double %sub107.i, 7.000000e-01
  %sub109.i = fsub double %19, %mul108.i
  store double %sub109.i, double* %arrayidx86.i, align 8, !tbaa !0
  %exitcond25.i.153 = icmp eq i64 %indvars.iv.next24.i, 1199
  br i1 %exitcond25.i.153, label %for.inc.117.i, label %for.body.82.i

for.inc.117.i:                                    ; preds = %for.body.82.i
  %exitcond28.i = icmp eq i64 %indvars.iv.next27.i.152, 999
  br i1 %exitcond28.i, label %for.inc.120.i, label %for.cond.79.preheader.i

for.inc.120.i:                                    ; preds = %for.inc.117.i
  %indvars.iv.next30.i = add nuw nsw i64 %indvars.iv29.i, 1
  %exitcond31.i = icmp eq i64 %indvars.iv.next30.i, 500
  br i1 %exitcond31.i, label %kernel_fdtd_2d.exit.exitStub, label %for.cond.7.preheader.i.140
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
