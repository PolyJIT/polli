
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'trmm.dir/trmm.c.main_for.body.10.lr.ph.us.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.10.lr.ph.us.i.pjit.scop(double* %arrayidx24.i, i64 %indvars.iv6.i, double*, i64 %indvars.iv14.i, double*)  {
newFuncRoot:
  br label %for.body.10.lr.ph.us.i

for.cond.loopexit.i.loopexit.exitStub:            ; preds = %for.cond.8.for.end_crit_edge.us.i
  ret void

for.body.10.lr.ph.us.i:                           ; preds = %for.cond.8.for.end_crit_edge.us.i, %newFuncRoot
  %indvars.iv11.i = phi i64 [ %indvars.iv.next12.i, %for.cond.8.for.end_crit_edge.us.i ], [ 0, %newFuncRoot ]
  %arrayidx20.us.i = getelementptr inbounds double, double* %arrayidx24.i, i64 %indvars.iv11.i
  br label %for.body.10.us.i

for.body.10.us.i:                                 ; preds = %for.body.10.us.i, %for.body.10.lr.ph.us.i
  %indvars.iv8.i.108 = phi i64 [ %indvars.iv6.i, %for.body.10.lr.ph.us.i ], [ %indvars.iv.next9.i.109, %for.body.10.us.i ]
  %2 = mul nuw nsw i64 %indvars.iv8.i.108, 1000
  %arrayidx.us.i = getelementptr inbounds double, double* %0, i64 %2
  %arrayidx12.us.i = getelementptr inbounds double, double* %arrayidx.us.i, i64 %indvars.iv14.i
  %3 = load double, double* %arrayidx12.us.i, align 8, !tbaa !0
  %4 = mul nuw nsw i64 %indvars.iv8.i.108, 1200
  %arrayidx15.us.i = getelementptr inbounds double, double* %1, i64 %4
  %arrayidx16.us.i = getelementptr inbounds double, double* %arrayidx15.us.i, i64 %indvars.iv11.i
  %5 = load double, double* %arrayidx16.us.i, align 8, !tbaa !0
  %mul.us.i = fmul double %3, %5
  %6 = load double, double* %arrayidx20.us.i, align 8, !tbaa !0
  %add21.us.i = fadd double %6, %mul.us.i
  store double %add21.us.i, double* %arrayidx20.us.i, align 8, !tbaa !0
  %indvars.iv.next9.i.109 = add nuw nsw i64 %indvars.iv8.i.108, 1
  %lftr.wideiv122 = trunc i64 %indvars.iv.next9.i.109 to i32
  %exitcond123 = icmp eq i32 %lftr.wideiv122, 1000
  br i1 %exitcond123, label %for.cond.8.for.end_crit_edge.us.i, label %for.body.10.us.i

for.cond.8.for.end_crit_edge.us.i:                ; preds = %for.body.10.us.i
  %add21.us.i.lcssa = phi double [ %add21.us.i, %for.body.10.us.i ]
  %mul26.us.i = fmul double %add21.us.i.lcssa, 1.500000e+00
  store double %mul26.us.i, double* %arrayidx20.us.i, align 8, !tbaa !0
  %indvars.iv.next12.i = add nuw nsw i64 %indvars.iv11.i, 1
  %exitcond13.i = icmp eq i64 %indvars.iv.next12.i, 1200
  br i1 %exitcond13.i, label %for.cond.loopexit.i.loopexit.exitStub, label %for.body.10.lr.ph.us.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
