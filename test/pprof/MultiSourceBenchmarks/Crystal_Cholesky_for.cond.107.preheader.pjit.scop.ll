
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASC_Sequoia/CrystalMk/Crystal_Cholesky.c.Crystal_Cholesky_for.cond.107.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @Crystal_Cholesky_for.cond.107.preheader.pjit.scop(i32 %nSlip, double* %g, [12 x double]* %a)  {
newFuncRoot:
  br label %for.cond.107.preheader

for.end.130.exitStub:                             ; preds = %for.end.130.loopexit, %for.cond.107.preheader
  ret void

for.cond.107.preheader:                           ; preds = %newFuncRoot
  %cmp108.302 = icmp sgt i32 %nSlip, 1
  br i1 %cmp108.302, label %for.body.112.lr.ph.preheader, label %for.end.130.exitStub

for.body.112.lr.ph.preheader:                     ; preds = %for.cond.107.preheader
  br label %for.body.112.lr.ph

for.body.112.lr.ph:                               ; preds = %for.inc.128, %for.body.112.lr.ph.preheader
  %indvars.iv436 = phi i32 [ 1, %for.body.112.lr.ph.preheader ], [ %indvars.iv.next, %for.inc.128 ]
  %indvars.iv377 = phi i64 [ %indvars.iv.next378, %for.inc.128 ], [ 1, %for.body.112.lr.ph.preheader ]
  %arrayidx114 = getelementptr inbounds double, double* %g, i64 %indvars.iv377
  br label %for.body.112

for.body.112:                                     ; preds = %for.body.112, %for.body.112.lr.ph
  %indvars.iv372 = phi i64 [ 0, %for.body.112.lr.ph ], [ %indvars.iv.next373, %for.body.112 ]
  %0 = load double, double* %arrayidx114, align 8, !tbaa !0
  %arrayidx118 = getelementptr inbounds [12 x double], [12 x double]* %a, i64 %indvars.iv377, i64 %indvars.iv372
  %1 = load double, double* %arrayidx118, align 8, !tbaa !0
  %arrayidx120 = getelementptr inbounds double, double* %g, i64 %indvars.iv372
  %2 = load double, double* %arrayidx120, align 8, !tbaa !0
  %mul121 = fmul double %1, %2
  %sub122 = fsub double %0, %mul121
  store double %sub122, double* %arrayidx114, align 8, !tbaa !0
  %indvars.iv.next373 = add nuw nsw i64 %indvars.iv372, 1
  %lftr.wideiv437 = trunc i64 %indvars.iv.next373 to i32
  %exitcond438 = icmp eq i32 %lftr.wideiv437, %indvars.iv436
  br i1 %exitcond438, label %for.inc.128, label %for.body.112

for.inc.128:                                      ; preds = %for.body.112
  %indvars.iv.next378 = add nuw nsw i64 %indvars.iv377, 1
  %indvars.iv.next = add nuw nsw i32 %indvars.iv436, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next378 to i32
  %exitcond439 = icmp eq i32 %lftr.wideiv, %nSlip
  br i1 %exitcond439, label %for.end.130.loopexit, label %for.body.112.lr.ph

for.end.130.loopexit:                             ; preds = %for.inc.128
  br label %for.end.130.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
