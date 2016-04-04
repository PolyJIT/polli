
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'common/quant.c.dequant_8x8_entry.split.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @dequant_8x8_entry.split.pjit.scop(i32 %i_qp, i16* %dct, [64 x i32]* %dequant_mf)  {
newFuncRoot:
  br label %entry.split

if.end.exitStub:                                  ; preds = %if.end.loopexit62, %if.end.loopexit
  ret void

entry.split:                                      ; preds = %newFuncRoot
  %rem = srem i32 %i_qp, 6
  %div = sdiv i32 %i_qp, 6
  %sub = add nsw i32 %div, -6
  %cmp = icmp sgt i32 %sub, -1
  br i1 %cmp, label %for.cond.preheader, label %if.else

for.cond.preheader:                               ; preds = %entry.split
  %idxprom3 = sext i32 %rem to i64
  br label %for.body

for.body:                                         ; preds = %for.body, %for.cond.preheader
  %indvars.iv = phi i64 [ 0, %for.cond.preheader ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i16, i16* %dct, i64 %indvars.iv
  %0 = load i16, i16* %arrayidx, align 2, !tbaa !0
  %conv = sext i16 %0 to i32
  %arrayidx5 = getelementptr inbounds [64 x i32], [64 x i32]* %dequant_mf, i64 %idxprom3, i64 %indvars.iv
  %1 = load i32, i32* %arrayidx5, align 4, !tbaa !4
  %mul = mul nsw i32 %conv, %1
  %shl = shl i32 %mul, %sub
  %conv6 = trunc i32 %shl to i16
  store i16 %conv6, i16* %arrayidx, align 2, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 64
  br i1 %exitcond, label %if.end.loopexit, label %for.body

if.end.loopexit:                                  ; preds = %for.body
  br label %if.end.exitStub

if.else:                                          ; preds = %entry.split
  %sub9 = sub nsw i32 6, %div
  %sub10 = add nsw i32 %sub9, -1
  %shl11 = shl i32 1, %sub10
  %idxprom22 = sext i32 %rem to i64
  br label %for.body.17

for.body.17:                                      ; preds = %for.body.17, %if.else
  %indvars.iv59 = phi i64 [ 0, %if.else ], [ %indvars.iv.next60, %for.body.17 ]
  %arrayidx19 = getelementptr inbounds i16, i16* %dct, i64 %indvars.iv59
  %2 = load i16, i16* %arrayidx19, align 2, !tbaa !0
  %conv20 = sext i16 %2 to i32
  %arrayidx24 = getelementptr inbounds [64 x i32], [64 x i32]* %dequant_mf, i64 %idxprom22, i64 %indvars.iv59
  %3 = load i32, i32* %arrayidx24, align 4, !tbaa !4
  %mul25 = mul nsw i32 %conv20, %3
  %add = add nsw i32 %mul25, %shl11
  %shr = ashr i32 %add, %sub9
  %conv27 = trunc i32 %shr to i16
  store i16 %conv27, i16* %arrayidx19, align 2, !tbaa !0
  %indvars.iv.next60 = add nuw nsw i64 %indvars.iv59, 1
  %exitcond61 = icmp eq i64 %indvars.iv.next60, 64
  br i1 %exitcond61, label %if.end.loopexit62, label %for.body.17

if.end.loopexit62:                                ; preds = %for.body.17
  br label %if.end.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"short", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !2, i64 0}
