
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'Objects/abstract.c.PyBuffer_FillContiguousStrides_entry.split.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @PyBuffer_FillContiguousStrides_entry.split.pjit.scop(i32 %itemsize, i8 %fort, i32 %nd, i64* %strides, i64* %shape)  {
newFuncRoot:
  br label %entry.split

if.end.exitStub:                                  ; preds = %if.end.loopexit44, %for.cond.7.preheader, %if.end.loopexit, %for.cond.preheader
  ret void

entry.split:                                      ; preds = %newFuncRoot
  %conv = sext i32 %itemsize to i64
  %cmp = icmp eq i8 %fort, 70
  br i1 %cmp, label %for.cond.preheader, label %for.cond.7.preheader

for.cond.preheader:                               ; preds = %entry.split
  %cmp3.34 = icmp sgt i32 %nd, 0
  br i1 %cmp3.34, label %for.body.preheader, label %if.end.exitStub

for.body.preheader:                               ; preds = %for.cond.preheader
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.preheader
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ 0, %for.body.preheader ]
  %sd.036 = phi i64 [ %mul, %for.body ], [ %conv, %for.body.preheader ]
  %arrayidx = getelementptr i64, i64* %strides, i64 %indvars.iv
  store i64 %sd.036, i64* %arrayidx, align 8, !tbaa !0
  %arrayidx6 = getelementptr i64, i64* %shape, i64 %indvars.iv
  %0 = load i64, i64* %arrayidx6, align 8, !tbaa !0
  %mul = mul i64 %0, %sd.036
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv45 = trunc i64 %indvars.iv.next to i32
  %exitcond46 = icmp eq i32 %lftr.wideiv45, %nd
  br i1 %exitcond46, label %if.end.loopexit, label %for.body

if.end.loopexit:                                  ; preds = %for.body
  br label %if.end.exitStub

for.cond.7.preheader:                             ; preds = %entry.split
  %k.1.37 = add i32 %nd, -1
  %cmp8.38 = icmp sgt i32 %k.1.37, -1
  br i1 %cmp8.38, label %for.body.10.preheader, label %if.end.exitStub

for.body.10.preheader:                            ; preds = %for.cond.7.preheader
  %1 = add i32 %nd, -1
  %2 = sext i32 %1 to i64
  br label %for.body.10

for.body.10:                                      ; preds = %for.body.10, %for.body.10.preheader
  %indvars.iv42 = phi i64 [ %2, %for.body.10.preheader ], [ %indvars.iv.next43, %for.body.10 ]
  %k.140 = phi i32 [ %k.1.37, %for.body.10.preheader ], [ %k.1, %for.body.10 ]
  %sd.139 = phi i64 [ %conv, %for.body.10.preheader ], [ %mul15, %for.body.10 ]
  %arrayidx12 = getelementptr i64, i64* %strides, i64 %indvars.iv42
  store i64 %sd.139, i64* %arrayidx12, align 8, !tbaa !0
  %arrayidx14 = getelementptr i64, i64* %shape, i64 %indvars.iv42
  %3 = load i64, i64* %arrayidx14, align 8, !tbaa !0
  %mul15 = mul i64 %3, %sd.139
  %k.1 = add i32 %k.140, -1
  %cmp8 = icmp sgt i32 %k.1, -1
  %indvars.iv.next43 = add nsw i64 %indvars.iv42, -1
  br i1 %cmp8, label %for.body.10, label %if.end.loopexit44

if.end.loopexit44:                                ; preds = %for.body.10
  br label %if.end.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"long", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
