
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'jacobi-2d.dir/jacobi-2d.c.main_for.cond.4.preheader.i.105.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.4.preheader.i.105.pjit.scop(double*, double*)  {
newFuncRoot:
  br label %for.cond.4.preheader.i.105

kernel_jacobi_2d.exit.exitStub:                   ; preds = %for.inc.91.i
  ret void

for.cond.4.preheader.i.105:                       ; preds = %for.inc.91.i, %newFuncRoot
  %t.05.i = phi i32 [ %inc92.i, %for.inc.91.i ], [ 0, %newFuncRoot ]
  br label %for.cond.7.preheader.i

for.cond.7.preheader.i:                           ; preds = %for.inc.41.i, %for.cond.4.preheader.i.105
  %indvars.iv7.i = phi i64 [ 1, %for.cond.4.preheader.i.105 ], [ %indvars.iv.next8.i, %for.inc.41.i ]
  %2 = mul nuw nsw i64 %indvars.iv7.i, 1300
  %arrayidx.i.106 = getelementptr inbounds double, double* %0, i64 %2
  %indvars.iv.next8.i = add nuw nsw i64 %indvars.iv7.i, 1
  %3 = mul nuw nsw i64 %indvars.iv.next8.i, 1300
  %arrayidx28.i = getelementptr inbounds double, double* %0, i64 %3
  %4 = add nsw i64 %2, -1300
  %arrayidx34.i = getelementptr inbounds double, double* %0, i64 %4
  %arrayidx39.i = getelementptr inbounds double, double* %1, i64 %2
  br label %for.body.10.i

for.body.10.i:                                    ; preds = %for.body.10.i, %for.cond.7.preheader.i
  %indvars.iv.i.107 = phi i64 [ 1, %for.cond.7.preheader.i ], [ %indvars.iv.next.i.109, %for.body.10.i ]
  %arrayidx12.i.108 = getelementptr inbounds double, double* %arrayidx.i.106, i64 %indvars.iv.i.107
  %5 = load double, double* %arrayidx12.i.108, align 8, !tbaa !0
  %6 = add nsw i64 %indvars.iv.i.107, -1
  %arrayidx17.i = getelementptr inbounds double, double* %arrayidx.i.106, i64 %6
  %7 = load double, double* %arrayidx17.i, align 8, !tbaa !0
  %add18.i = fadd double %5, %7
  %indvars.iv.next.i.109 = add nuw nsw i64 %indvars.iv.i.107, 1
  %arrayidx23.i.110 = getelementptr inbounds double, double* %arrayidx.i.106, i64 %indvars.iv.next.i.109
  %8 = load double, double* %arrayidx23.i.110, align 8, !tbaa !0
  %add24.i = fadd double %add18.i, %8
  %arrayidx29.i = getelementptr inbounds double, double* %arrayidx28.i, i64 %indvars.iv.i.107
  %9 = load double, double* %arrayidx29.i, align 8, !tbaa !0
  %add30.i = fadd double %add24.i, %9
  %arrayidx35.i = getelementptr inbounds double, double* %arrayidx34.i, i64 %indvars.iv.i.107
  %10 = load double, double* %arrayidx35.i, align 8, !tbaa !0
  %add36.i = fadd double %add30.i, %10
  %mul.i.111 = fmul double %add36.i, 2.000000e-01
  %arrayidx40.i = getelementptr inbounds double, double* %arrayidx39.i, i64 %indvars.iv.i.107
  store double %mul.i.111, double* %arrayidx40.i, align 8, !tbaa !0
  %exitcond.i.112 = icmp eq i64 %indvars.iv.next.i.109, 1299
  br i1 %exitcond.i.112, label %for.inc.41.i, label %for.body.10.i

for.inc.41.i:                                     ; preds = %for.body.10.i
  %exitcond10.i = icmp eq i64 %indvars.iv.next8.i, 1299
  br i1 %exitcond10.i, label %for.cond.48.preheader.i.preheader, label %for.cond.7.preheader.i

for.cond.48.preheader.i.preheader:                ; preds = %for.inc.41.i
  br label %for.cond.48.preheader.i

for.cond.48.preheader.i:                          ; preds = %for.inc.88.i, %for.cond.48.preheader.i.preheader
  %indvars.iv15.i = phi i64 [ %indvars.iv.next16.i, %for.inc.88.i ], [ 1, %for.cond.48.preheader.i.preheader ]
  %11 = mul nuw nsw i64 %indvars.iv15.i, 1300
  %arrayidx54.i = getelementptr inbounds double, double* %1, i64 %11
  %indvars.iv.next16.i = add nuw nsw i64 %indvars.iv15.i, 1
  %12 = mul nuw nsw i64 %indvars.iv.next16.i, 1300
  %arrayidx71.i = getelementptr inbounds double, double* %1, i64 %12
  %13 = add nsw i64 %11, -1300
  %arrayidx77.i = getelementptr inbounds double, double* %1, i64 %13
  %arrayidx83.i = getelementptr inbounds double, double* %0, i64 %11
  br label %for.body.51.i

for.body.51.i:                                    ; preds = %for.body.51.i, %for.cond.48.preheader.i
  %indvars.iv11.i = phi i64 [ 1, %for.cond.48.preheader.i ], [ %indvars.iv.next12.i, %for.body.51.i ]
  %arrayidx55.i = getelementptr inbounds double, double* %arrayidx54.i, i64 %indvars.iv11.i
  %14 = load double, double* %arrayidx55.i, align 8, !tbaa !0
  %15 = add nsw i64 %indvars.iv11.i, -1
  %arrayidx60.i = getelementptr inbounds double, double* %arrayidx54.i, i64 %15
  %16 = load double, double* %arrayidx60.i, align 8, !tbaa !0
  %add61.i = fadd double %14, %16
  %indvars.iv.next12.i = add nuw nsw i64 %indvars.iv11.i, 1
  %arrayidx66.i = getelementptr inbounds double, double* %arrayidx54.i, i64 %indvars.iv.next12.i
  %17 = load double, double* %arrayidx66.i, align 8, !tbaa !0
  %add67.i = fadd double %add61.i, %17
  %arrayidx72.i = getelementptr inbounds double, double* %arrayidx71.i, i64 %indvars.iv11.i
  %18 = load double, double* %arrayidx72.i, align 8, !tbaa !0
  %add73.i = fadd double %add67.i, %18
  %arrayidx78.i = getelementptr inbounds double, double* %arrayidx77.i, i64 %indvars.iv11.i
  %19 = load double, double* %arrayidx78.i, align 8, !tbaa !0
  %add79.i = fadd double %add73.i, %19
  %mul80.i = fmul double %add79.i, 2.000000e-01
  %arrayidx84.i = getelementptr inbounds double, double* %arrayidx83.i, i64 %indvars.iv11.i
  store double %mul80.i, double* %arrayidx84.i, align 8, !tbaa !0
  %exitcond14.i = icmp eq i64 %indvars.iv.next12.i, 1299
  br i1 %exitcond14.i, label %for.inc.88.i, label %for.body.51.i

for.inc.88.i:                                     ; preds = %for.body.51.i
  %exitcond18.i = icmp eq i64 %indvars.iv.next16.i, 1299
  br i1 %exitcond18.i, label %for.inc.91.i, label %for.cond.48.preheader.i

for.inc.91.i:                                     ; preds = %for.inc.88.i
  %inc92.i = add nuw nsw i32 %t.05.i, 1
  %exitcond19.i = icmp eq i32 %inc92.i, 500
  br i1 %exitcond19.i, label %kernel_jacobi_2d.exit.exitStub, label %for.cond.4.preheader.i.105
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
