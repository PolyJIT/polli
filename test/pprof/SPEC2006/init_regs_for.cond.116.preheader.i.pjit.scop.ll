
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polli-process-unprofitable -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/403.gcc/src/regclass.c.init_regs_for.cond.116.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @init_regs_for.cond.116.preheader.i.pjit.scop([25 x i64]* nonnull %reg_class_contents, [25 x i32]* nonnull %reg_class_size)  {
newFuncRoot:
  br label %for.cond.116.preheader.i

for.cond.141.preheader.i.exitStub:                ; preds = %for.cond.141.preheader.i.preheader
  ret void

for.cond.116.preheader.i:                         ; preds = %for.inc.134.i, %newFuncRoot
  %indvars.iv1045.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next1046.i, %for.inc.134.i ]
  %arrayidx121.i = getelementptr inbounds [25 x i64], [25 x i64]* %reg_class_contents, i64 0, i64 %indvars.iv1045.i
  %0 = load i64, i64* %arrayidx121.i, align 8, !tbaa !0
  %arrayidx128.i = getelementptr inbounds [25 x i32], [25 x i32]* %reg_class_size, i64 0, i64 %indvars.iv1045.i
  br label %for.body.119.i

for.body.119.i:                                   ; preds = %for.inc.131.i, %for.cond.116.preheader.i
  %indvars.iv1042.i = phi i64 [ 0, %for.cond.116.preheader.i ], [ %indvars.iv.next1043.i, %for.inc.131.i ]
  %shl123.i = shl i64 1, %indvars.iv1042.i
  %and124.i = and i64 %shl123.i, %0
  %tobool125.i = icmp eq i64 %and124.i, 0
  br i1 %tobool125.i, label %for.inc.131.i, label %if.then.126.i

for.inc.131.i:                                    ; preds = %if.then.126.i, %for.body.119.i
  %indvars.iv.next1043.i = add nuw nsw i64 %indvars.iv1042.i, 1
  %exitcond1044.i = icmp eq i64 %indvars.iv.next1043.i, 53
  br i1 %exitcond1044.i, label %for.inc.134.i, label %for.body.119.i

for.inc.134.i:                                    ; preds = %for.inc.131.i
  %indvars.iv.next1046.i = add nuw nsw i64 %indvars.iv1045.i, 1
  %exitcond1047.i = icmp eq i64 %indvars.iv.next1046.i, 25
  br i1 %exitcond1047.i, label %for.cond.141.preheader.i.preheader, label %for.cond.116.preheader.i

for.cond.141.preheader.i.preheader:               ; preds = %for.inc.134.i
  br label %for.cond.141.preheader.i.exitStub

if.then.126.i:                                    ; preds = %for.body.119.i
  %1 = load i32, i32* %arrayidx128.i, align 4, !tbaa !4
  %inc129.i = add i32 %1, 1
  store i32 %inc129.i, i32* %arrayidx128.i, align 4, !tbaa !4
  br label %for.inc.131.i
}

attributes #0 = { nounwind "polyjit-global-count"="2" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"long", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !2, i64 0}
