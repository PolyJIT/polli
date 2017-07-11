
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/444.namd/src/ComputeNonbondedUtil.C._ZN20ComputeNonbondedUtil6selectEP13SimParametersP8MoleculeP7LJTable_for.body.61.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZN20ComputeNonbondedUtil6selectEP13SimParametersP8MoleculeP7LJTable_for.body.61.lr.ph.pjit.scop(i64, double*, i32, double* nonnull %_ZN20ComputeNonbondedUtil10lesScalingE)  {
newFuncRoot:
  br label %for.body.61.lr.ph

for.cond.cleanup.55.loopexit.exitStub:            ; preds = %for.cond.cleanup.60
  ret void

for.body.61.lr.ph:                                ; preds = %for.cond.cleanup.60, %newFuncRoot
  %indvars.iv1001 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next1002, %for.cond.cleanup.60 ]
  %3 = mul nsw i64 %indvars.iv1001, %0
  %notlhs888 = icmp eq i64 %indvars.iv1001, 0
  br i1 %notlhs888, label %for.body.61.us.preheader, label %for.body.61.preheader

for.body.61.us.preheader:                         ; preds = %for.body.61.lr.ph
  br label %for.body.61.us

for.body.61.us:                                   ; preds = %for.body.61.us, %for.body.61.us.preheader
  %indvars.iv996 = phi i64 [ %indvars.iv.next997, %for.body.61.us ], [ 0, %for.body.61.us.preheader ]
  %4 = or i64 %indvars.iv996, %indvars.iv1001
  %5 = trunc i64 %4 to i32
  %6 = icmp eq i32 %5, 0
  %7 = load double, double* %_ZN20ComputeNonbondedUtil10lesScalingE, align 8, !tbaa !0
  %.970 = select i1 %6, double 1.000000e+00, double %7
  %8 = add nsw i64 %indvars.iv996, %3
  %arrayidx80.us = getelementptr inbounds double, double* %1, i64 %8
  store double %.970, double* %arrayidx80.us, align 8, !tbaa !0
  %indvars.iv.next997 = add nuw nsw i64 %indvars.iv996, 1
  %lftr.wideiv1053 = trunc i64 %indvars.iv.next997 to i32
  %exitcond1054 = icmp eq i32 %lftr.wideiv1053, %2
  br i1 %exitcond1054, label %for.cond.cleanup.60.loopexit, label %for.body.61.us

for.cond.cleanup.60.loopexit:                     ; preds = %for.body.61.us
  br label %for.cond.cleanup.60

for.cond.cleanup.60:                              ; preds = %for.cond.cleanup.60.loopexit1050, %for.cond.cleanup.60.loopexit
  %indvars.iv.next1002 = add nuw nsw i64 %indvars.iv1001, 1
  %lftr.wideiv1055 = trunc i64 %indvars.iv.next1002 to i32
  %exitcond1056 = icmp eq i32 %lftr.wideiv1055, %2
  br i1 %exitcond1056, label %for.cond.cleanup.55.loopexit.exitStub, label %for.body.61.lr.ph

for.body.61.preheader:                            ; preds = %for.body.61.lr.ph
  br label %for.body.61

for.body.61:                                      ; preds = %if.end.75, %for.body.61.preheader
  %indvars.iv991 = phi i64 [ 0, %for.body.61.preheader ], [ %indvars.iv.next992, %if.end.75 ]
  %9 = or i64 %indvars.iv991, %indvars.iv1001
  %10 = trunc i64 %9 to i32
  %11 = icmp eq i32 %10, 0
  br i1 %11, label %if.end.75, label %if.then.66

if.end.75:                                        ; preds = %if.then.66, %for.body.61
  %lambda_pair62.0 = phi double [ 1.000000e+00, %for.body.61 ], [ %.887, %if.then.66 ]
  %12 = add nsw i64 %indvars.iv991, %3
  %arrayidx80 = getelementptr inbounds double, double* %1, i64 %12
  store double %lambda_pair62.0, double* %arrayidx80, align 8, !tbaa !0
  %indvars.iv.next992 = add nuw nsw i64 %indvars.iv991, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next992 to i32
  %exitcond1052 = icmp eq i32 %lftr.wideiv, %2
  br i1 %exitcond1052, label %for.cond.cleanup.60.loopexit1050, label %for.body.61

for.cond.cleanup.60.loopexit1050:                 ; preds = %if.end.75
  br label %for.cond.cleanup.60

if.then.66:                                       ; preds = %for.body.61
  %notrhs889 = icmp eq i64 %indvars.iv991, 0
  %cmp71 = icmp eq i64 %indvars.iv1001, %indvars.iv991
  %or.cond886 = or i1 %cmp71, %notrhs889
  %13 = load double, double* %_ZN20ComputeNonbondedUtil10lesScalingE, align 8, !tbaa !0
  %.887 = select i1 %or.cond886, double %13, double 0.000000e+00
  br label %if.end.75
}

attributes #0 = { "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
