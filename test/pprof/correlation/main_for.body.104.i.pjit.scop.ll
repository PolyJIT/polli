
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'correlation.dir/correlation.c.main_for.body.104.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.104.i.pjit.scop(i64 %indvars.iv11.i, double* %arrayidx99.i, double*, i64 %indvars.iv16.i, double*)  {
newFuncRoot:
  br label %for.body.104.i

for.cond.93.loopexit.i.exitStub:                  ; preds = %for.end.128.i
  ret void

for.body.104.i:                                   ; preds = %for.end.128.i, %newFuncRoot
  %indvars.iv13.i = phi i64 [ %indvars.iv11.i, %newFuncRoot ], [ %indvars.iv.next14.i, %for.end.128.i ]
  %arrayidx108.i = getelementptr inbounds double, double* %arrayidx99.i, i64 %indvars.iv13.i
  store double 0.000000e+00, double* %arrayidx108.i, align 8, !tbaa !0
  br label %for.body.111.i

for.body.111.i:                                   ; preds = %for.body.111.i, %for.body.104.i
  %indvars.iv.i.128 = phi i64 [ 0, %for.body.104.i ], [ %indvars.iv.next.i.129, %for.body.111.i ]
  %2 = mul nuw nsw i64 %indvars.iv.i.128, 1200
  %arrayidx114.i = getelementptr inbounds double, double* %0, i64 %2
  %arrayidx115.i = getelementptr inbounds double, double* %arrayidx114.i, i64 %indvars.iv16.i
  %3 = load double, double* %arrayidx115.i, align 8, !tbaa !0
  %arrayidx119.i = getelementptr inbounds double, double* %arrayidx114.i, i64 %indvars.iv13.i
  %4 = load double, double* %arrayidx119.i, align 8, !tbaa !0
  %mul120.i = fmul double %3, %4
  %5 = load double, double* %arrayidx108.i, align 8, !tbaa !0
  %add125.i = fadd double %5, %mul120.i
  store double %add125.i, double* %arrayidx108.i, align 8, !tbaa !0
  %indvars.iv.next.i.129 = add nuw nsw i64 %indvars.iv.i.128, 1
  %exitcond.i.130 = icmp eq i64 %indvars.iv.next.i.129, 1400
  br i1 %exitcond.i.130, label %for.end.128.i, label %for.body.111.i

for.end.128.i:                                    ; preds = %for.body.111.i
  %6 = bitcast double* %arrayidx108.i to i64*
  %7 = load i64, i64* %6, align 8, !tbaa !0
  %8 = mul nuw nsw i64 %indvars.iv13.i, 1200
  %arrayidx135.i = getelementptr inbounds double, double* %1, i64 %8
  %arrayidx136.i = getelementptr inbounds double, double* %arrayidx135.i, i64 %indvars.iv16.i
  %9 = bitcast double* %arrayidx136.i to i64*
  store i64 %7, i64* %9, align 8, !tbaa !0
  %indvars.iv.next14.i = add nuw nsw i64 %indvars.iv13.i, 1
  %lftr.wideiv132 = trunc i64 %indvars.iv.next14.i to i32
  %exitcond133 = icmp eq i32 %lftr.wideiv132, 1200
  br i1 %exitcond133, label %for.cond.93.loopexit.i.exitStub, label %for.body.104.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
