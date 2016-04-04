
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'gemm.dir/gemm.c.main_for.cond.6.preheader.i.129.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.6.preheader.i.129.pjit.scop(double*, double*, double*)  {
newFuncRoot:
  br label %for.cond.6.preheader.i.129

kernel_gemm.exit.exitStub:                        ; preds = %for.inc.38.i
  ret void

for.cond.6.preheader.i.129:                       ; preds = %for.inc.38.i, %newFuncRoot
  %indvars.iv11.i = phi i64 [ %indvars.iv.next12.i, %for.inc.38.i ], [ 0, %newFuncRoot ]
  %3 = mul nuw nsw i64 %indvars.iv11.i, 1100
  %arrayidx.i.128 = getelementptr inbounds double, double* %0, i64 %3
  br label %for.body.8.i.134

for.body.8.i.134:                                 ; preds = %for.body.8.i.134, %for.cond.6.preheader.i.129
  %indvars.iv.i.130 = phi i64 [ 0, %for.cond.6.preheader.i.129 ], [ %indvars.iv.next.i.132, %for.body.8.i.134 ]
  %arrayidx10.i.131 = getelementptr inbounds double, double* %arrayidx.i.128, i64 %indvars.iv.i.130
  %4 = load double, double* %arrayidx10.i.131, align 8, !tbaa !0
  %mul.i = fmul double %4, 1.200000e+00
  store double %mul.i, double* %arrayidx10.i.131, align 8, !tbaa !0
  %indvars.iv.next.i.132 = add nuw nsw i64 %indvars.iv.i.130, 1
  %exitcond.i.133 = icmp eq i64 %indvars.iv.next.i.132, 1100
  br i1 %exitcond.i.133, label %for.cond.11.preheader.i, label %for.body.8.i.134

for.cond.11.preheader.i:                          ; preds = %for.body.8.i.134
  %5 = mul nuw nsw i64 %indvars.iv11.i, 1200
  %arrayidx19.i = getelementptr inbounds double, double* %1, i64 %5
  br label %for.cond.14.preheader.i

for.cond.14.preheader.i:                          ; preds = %for.inc.35.i, %for.cond.11.preheader.i
  %indvars.iv8.i = phi i64 [ 0, %for.cond.11.preheader.i ], [ %indvars.iv.next9.i, %for.inc.35.i ]
  %arrayidx20.i = getelementptr inbounds double, double* %arrayidx19.i, i64 %indvars.iv8.i
  %6 = mul nuw nsw i64 %indvars.iv8.i, 1100
  %arrayidx24.i = getelementptr inbounds double, double* %2, i64 %6
  br label %for.body.16.i

for.body.16.i:                                    ; preds = %for.body.16.i, %for.cond.14.preheader.i
  %indvars.iv5.i = phi i64 [ 0, %for.cond.14.preheader.i ], [ %indvars.iv.next6.i, %for.body.16.i ]
  %7 = load double, double* %arrayidx20.i, align 8, !tbaa !0
  %mul21.i = fmul double %7, 1.500000e+00
  %arrayidx25.i = getelementptr inbounds double, double* %arrayidx24.i, i64 %indvars.iv5.i
  %8 = load double, double* %arrayidx25.i, align 8, !tbaa !0
  %mul26.i = fmul double %mul21.i, %8
  %arrayidx30.i = getelementptr inbounds double, double* %arrayidx.i.128, i64 %indvars.iv5.i
  %9 = load double, double* %arrayidx30.i, align 8, !tbaa !0
  %add31.i = fadd double %9, %mul26.i
  store double %add31.i, double* %arrayidx30.i, align 8, !tbaa !0
  %indvars.iv.next6.i = add nuw nsw i64 %indvars.iv5.i, 1
  %exitcond7.i.135 = icmp eq i64 %indvars.iv.next6.i, 1100
  br i1 %exitcond7.i.135, label %for.inc.35.i, label %for.body.16.i

for.inc.35.i:                                     ; preds = %for.body.16.i
  %indvars.iv.next9.i = add nuw nsw i64 %indvars.iv8.i, 1
  %exitcond10.i = icmp eq i64 %indvars.iv.next9.i, 1200
  br i1 %exitcond10.i, label %for.inc.38.i, label %for.cond.14.preheader.i

for.inc.38.i:                                     ; preds = %for.inc.35.i
  %indvars.iv.next12.i = add nuw nsw i64 %indvars.iv11.i, 1
  %exitcond13.i = icmp eq i64 %indvars.iv.next12.i, 1000
  br i1 %exitcond13.i, label %kernel_gemm.exit.exitStub, label %for.cond.6.preheader.i.129
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
