
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '../../../../CPP/7zip/Archive/7z/7zIn.cpp._ZNK8NArchive3N7z7CFolder14CheckStructureEj_for.cond.130.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZNK8NArchive3N7z7CFolder14CheckStructureEj_for.cond.130.preheader.pjit.scop([32 x i32]* %mask)  {
newFuncRoot:
  br label %for.cond.130.preheader

for.body.153.exitStub:                            ; preds = %for.body.153.preheader
  ret void

for.cond.130.preheader:                           ; preds = %for.cond.cleanup, %newFuncRoot
  %indvars.iv428 = phi i64 [ %indvars.iv.next429, %for.cond.cleanup ], [ 0, %newFuncRoot ]
  %arrayidx135 = getelementptr inbounds [32 x i32], [32 x i32]* %mask, i64 0, i64 %indvars.iv428
  br label %for.body.132

for.body.132:                                     ; preds = %for.inc.144, %for.cond.130.preheader
  %indvars.iv = phi i64 [ 0, %for.cond.130.preheader ], [ %indvars.iv.next, %for.inc.144 ]
  %0 = trunc i64 %indvars.iv to i32
  %shl133 = shl i32 1, %0
  %1 = load i32, i32* %arrayidx135, align 4, !tbaa !0
  %and = and i32 %shl133, %1
  %cmp136 = icmp eq i32 %and, 0
  br i1 %cmp136, label %for.inc.144, label %if.then.137

for.inc.144:                                      ; preds = %if.then.137, %for.body.132
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 32
  br i1 %exitcond, label %for.cond.cleanup, label %for.body.132

for.cond.cleanup:                                 ; preds = %for.inc.144
  %indvars.iv.next429 = add nuw nsw i64 %indvars.iv428, 1
  %exitcond430 = icmp eq i64 %indvars.iv.next429, 32
  br i1 %exitcond430, label %for.body.153.preheader, label %for.cond.130.preheader

for.body.153.preheader:                           ; preds = %for.cond.cleanup
  br label %for.body.153.exitStub

if.then.137:                                      ; preds = %for.body.132
  %arrayidx139 = getelementptr inbounds [32 x i32], [32 x i32]* %mask, i64 0, i64 %indvars.iv
  %2 = load i32, i32* %arrayidx139, align 4, !tbaa !0
  %or142 = or i32 %2, %1
  store i32 %or142, i32* %arrayidx135, align 4, !tbaa !0
  br label %for.inc.144
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
