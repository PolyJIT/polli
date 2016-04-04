
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/7zip/CPP/7zip/Archive/7z/7zIn.cpp._ZNK8NArchive3N7z7CFolder14CheckStructureEv_for.cond.123.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZNK8NArchive3N7z7CFolder14CheckStructureEv_for.cond.123.preheader.pjit.scop([32 x i32]* %mask)  {
newFuncRoot:
  br label %for.cond.123.preheader

for.body.146.exitStub:                            ; preds = %for.body.146.preheader
  ret void

for.cond.123.preheader:                           ; preds = %for.cond.cleanup, %newFuncRoot
  %indvars.iv323 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next324, %for.cond.cleanup ]
  %arrayidx128 = getelementptr inbounds [32 x i32], [32 x i32]* %mask, i64 0, i64 %indvars.iv323
  br label %for.body.125

for.body.125:                                     ; preds = %for.inc.137, %for.cond.123.preheader
  %indvars.iv321 = phi i64 [ 0, %for.cond.123.preheader ], [ %indvars.iv.next322, %for.inc.137 ]
  %0 = trunc i64 %indvars.iv321 to i32
  %shl126 = shl i32 1, %0
  %1 = load i32, i32* %arrayidx128, align 4, !tbaa !0
  %and = and i32 %shl126, %1
  %cmp129 = icmp eq i32 %and, 0
  br i1 %cmp129, label %for.inc.137, label %if.then.130

for.inc.137:                                      ; preds = %if.then.130, %for.body.125
  %indvars.iv.next322 = add nuw nsw i64 %indvars.iv321, 1
  %exitcond = icmp eq i64 %indvars.iv.next322, 32
  br i1 %exitcond, label %for.cond.cleanup, label %for.body.125

for.cond.cleanup:                                 ; preds = %for.inc.137
  %indvars.iv.next324 = add nuw nsw i64 %indvars.iv323, 1
  %exitcond325 = icmp eq i64 %indvars.iv.next324, 32
  br i1 %exitcond325, label %for.body.146.preheader, label %for.cond.123.preheader

for.body.146.preheader:                           ; preds = %for.cond.cleanup
  br label %for.body.146.exitStub

if.then.130:                                      ; preds = %for.body.125
  %arrayidx132 = getelementptr inbounds [32 x i32], [32 x i32]* %mask, i64 0, i64 %indvars.iv321
  %2 = load i32, i32* %arrayidx132, align 4, !tbaa !0
  %or135 = or i32 %2, %1
  store i32 %or135, i32* %arrayidx128, align 4, !tbaa !0
  br label %for.inc.137
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
