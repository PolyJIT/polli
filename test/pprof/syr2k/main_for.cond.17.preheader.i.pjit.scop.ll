
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'syr2k.dir/syr2k.c.main_for.cond.17.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.17.preheader.i.pjit.scop(double*, double*, double*)  {
newFuncRoot:
  br label %for.cond.17.preheader.i

kernel_syr2k.exit.exitStub:                       ; preds = %for.inc.55.i
  ret void

for.cond.17.preheader.i:                          ; preds = %for.inc.55.i, %newFuncRoot
  %indvars.iv9.i.128 = phi i64 [ %indvars.iv.next10.i.136, %for.inc.55.i ], [ 0, %newFuncRoot ]
  %3 = mul nuw nsw i64 %indvars.iv9.i.128, 1000
  %arrayidx30.i = getelementptr inbounds double, double* %0, i64 %3
  %arrayidx40.i.129 = getelementptr inbounds double, double* %1, i64 %3
  %4 = mul nuw nsw i64 %indvars.iv9.i.128, 1200
  %arrayidx46.i = getelementptr inbounds double, double* %2, i64 %4
  br label %for.cond.20.preheader.i

for.cond.20.preheader.i:                          ; preds = %for.inc.52.i, %for.cond.17.preheader.i
  %indvars.iv6.i.130 = phi i64 [ 0, %for.cond.17.preheader.i ], [ %indvars.iv.next7.i.134, %for.inc.52.i ]
  %arrayidx31.i = getelementptr inbounds double, double* %arrayidx30.i, i64 %indvars.iv6.i.130
  %arrayidx41.i = getelementptr inbounds double, double* %arrayidx40.i.129, i64 %indvars.iv6.i.130
  br label %for.body.22.i

for.body.22.i:                                    ; preds = %for.body.22.i, %for.cond.20.preheader.i
  %indvars.iv.i.131 = phi i64 [ 0, %for.cond.20.preheader.i ], [ %indvars.iv.next.i.132, %for.body.22.i ]
  %5 = mul nuw nsw i64 %indvars.iv.i.131, 1000
  %arrayidx25.i = getelementptr inbounds double, double* %1, i64 %5
  %arrayidx26.i = getelementptr inbounds double, double* %arrayidx25.i, i64 %indvars.iv6.i.130
  %6 = load double, double* %arrayidx26.i, align 8, !tbaa !0
  %mul27.i = fmul double %6, 1.500000e+00
  %7 = load double, double* %arrayidx31.i, align 8, !tbaa !0
  %mul32.i = fmul double %mul27.i, %7
  %arrayidx35.i = getelementptr inbounds double, double* %0, i64 %5
  %arrayidx36.i = getelementptr inbounds double, double* %arrayidx35.i, i64 %indvars.iv6.i.130
  %8 = load double, double* %arrayidx36.i, align 8, !tbaa !0
  %mul37.i = fmul double %8, 1.500000e+00
  %9 = load double, double* %arrayidx41.i, align 8, !tbaa !0
  %mul42.i = fmul double %mul37.i, %9
  %add43.i = fadd double %mul32.i, %mul42.i
  %arrayidx47.i = getelementptr inbounds double, double* %arrayidx46.i, i64 %indvars.iv.i.131
  %10 = load double, double* %arrayidx47.i, align 8, !tbaa !0
  %add48.i = fadd double %10, %add43.i
  store double %add48.i, double* %arrayidx47.i, align 8, !tbaa !0
  %indvars.iv.next.i.132 = add nuw nsw i64 %indvars.iv.i.131, 1
  %exitcond.i.133 = icmp eq i64 %indvars.iv.next.i.132, 1200
  br i1 %exitcond.i.133, label %for.inc.52.i, label %for.body.22.i

for.inc.52.i:                                     ; preds = %for.body.22.i
  %indvars.iv.next7.i.134 = add nuw nsw i64 %indvars.iv6.i.130, 1
  %exitcond8.i.135 = icmp eq i64 %indvars.iv.next7.i.134, 1000
  br i1 %exitcond8.i.135, label %for.inc.55.i, label %for.cond.20.preheader.i

for.inc.55.i:                                     ; preds = %for.inc.52.i
  %indvars.iv.next10.i.136 = add nuw nsw i64 %indvars.iv9.i.128, 1
  %exitcond11.i = icmp eq i64 %indvars.iv.next10.i.136, 1200
  br i1 %exitcond11.i, label %kernel_syr2k.exit.exitStub, label %for.cond.17.preheader.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
