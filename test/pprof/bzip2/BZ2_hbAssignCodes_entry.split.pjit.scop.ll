
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'huffman.c.BZ2_hbAssignCodes_entry.split.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @BZ2_hbAssignCodes_entry.split.pjit.scop(i32 %minLen, i32 %maxLen, i32 %alphaSize, i8* %length, i32* %code)  {
newFuncRoot:
  br label %entry.split

for.end.11.exitStub:                              ; preds = %for.end.11.loopexit, %entry.split
  ret void

entry.split:                                      ; preds = %newFuncRoot
  %cmp.25 = icmp sgt i32 %minLen, %maxLen
  br i1 %cmp.25, label %for.end.11.exitStub, label %for.cond.1.preheader.lr.ph

for.cond.1.preheader.lr.ph:                       ; preds = %entry.split
  %cmp2.22 = icmp sgt i32 %alphaSize, 0
  br label %for.cond.1.preheader

for.cond.1.preheader:                             ; preds = %for.end, %for.cond.1.preheader.lr.ph
  %vec.027 = phi i32 [ 0, %for.cond.1.preheader.lr.ph ], [ %shl, %for.end ]
  %n.026 = phi i32 [ %minLen, %for.cond.1.preheader.lr.ph ], [ %inc10, %for.end ]
  br i1 %cmp2.22, label %for.body.3.preheader, label %for.end

for.body.3.preheader:                             ; preds = %for.cond.1.preheader
  br label %for.body.3

for.body.3:                                       ; preds = %for.inc, %for.body.3.preheader
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.inc ], [ 0, %for.body.3.preheader ]
  %vec.123 = phi i32 [ %vec.2, %for.inc ], [ %vec.027, %for.body.3.preheader ]
  %arrayidx = getelementptr inbounds i8, i8* %length, i64 %indvars.iv
  %0 = load i8, i8* %arrayidx, align 1, !tbaa !0
  %conv = zext i8 %0 to i32
  %cmp4 = icmp eq i32 %conv, %n.026
  br i1 %cmp4, label %if.then, label %for.inc

if.then:                                          ; preds = %for.body.3
  %arrayidx7 = getelementptr inbounds i32, i32* %code, i64 %indvars.iv
  store i32 %vec.123, i32* %arrayidx7, align 4, !tbaa !3
  %inc = add nsw i32 %vec.123, 1
  br label %for.inc

for.inc:                                          ; preds = %if.then, %for.body.3
  %vec.2 = phi i32 [ %inc, %if.then ], [ %vec.123, %for.body.3 ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv28 = trunc i64 %indvars.iv.next to i32
  %exitcond29 = icmp eq i32 %lftr.wideiv28, %alphaSize
  br i1 %exitcond29, label %for.end.loopexit, label %for.body.3

for.end.loopexit:                                 ; preds = %for.inc
  %vec.2.lcssa = phi i32 [ %vec.2, %for.inc ]
  br label %for.end

for.end:                                          ; preds = %for.end.loopexit, %for.cond.1.preheader
  %vec.1.lcssa = phi i32 [ %vec.027, %for.cond.1.preheader ], [ %vec.2.lcssa, %for.end.loopexit ]
  %shl = shl i32 %vec.1.lcssa, 1
  %inc10 = add nsw i32 %n.026, 1
  %cmp = icmp slt i32 %n.026, %maxLen
  br i1 %cmp, label %for.cond.1.preheader, label %for.end.11.loopexit

for.end.11.loopexit:                              ; preds = %for.end
  br label %for.end.11.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !1, i64 0}
