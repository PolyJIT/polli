
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'Objects/bytesobject.c.bytes_translate_if.end.73.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @bytes_translate_if.end.73.pjit.scop(i8* %table.0259, [256 x i32]* %trans_table)  {
newFuncRoot:
  br label %if.end.73

if.end.101.exitStub:                              ; preds = %if.end.101.loopexit278, %if.end.101.loopexit
  ret void

if.end.73:                                        ; preds = %newFuncRoot
  %cmp74 = icmp eq i8* %table.0259, null
  br i1 %cmp74, label %for.body.80.preheader, label %for.body.91.preheader

for.body.80.preheader:                            ; preds = %if.end.73
  br label %for.body.80

for.body.80:                                      ; preds = %for.body.80, %for.body.80.preheader
  %i.1271 = phi i64 [ %inc85, %for.body.80 ], [ 0, %for.body.80.preheader ]
  %conv82 = trunc i64 %i.1271 to i32
  %conv83 = and i32 %conv82, 255
  %arrayidx84 = getelementptr [256 x i32], [256 x i32]* %trans_table, i64 0, i64 %i.1271
  store i32 %conv83, i32* %arrayidx84, align 4, !tbaa !0
  %inc85 = add nuw nsw i64 %i.1271, 1
  %exitcond276 = icmp eq i64 %inc85, 256
  br i1 %exitcond276, label %if.end.101.loopexit, label %for.body.80

if.end.101.loopexit:                              ; preds = %for.body.80
  br label %if.end.101.exitStub

for.body.91.preheader:                            ; preds = %if.end.73
  br label %for.body.91

for.body.91:                                      ; preds = %for.body.91, %for.body.91.preheader
  %i.2272 = phi i64 [ %inc99, %for.body.91 ], [ 0, %for.body.91.preheader ]
  %arrayidx92 = getelementptr i8, i8* %table.0259, i64 %i.2272
  %0 = load i8, i8* %arrayidx92, align 1, !tbaa !4
  %conv96 = zext i8 %0 to i32
  %arrayidx97 = getelementptr [256 x i32], [256 x i32]* %trans_table, i64 0, i64 %i.2272
  store i32 %conv96, i32* %arrayidx97, align 4, !tbaa !0
  %inc99 = add nuw nsw i64 %i.2272, 1
  %exitcond277 = icmp eq i64 %inc99, 256
  br i1 %exitcond277, label %if.end.101.loopexit278, label %for.body.91

if.end.101.loopexit278:                           ; preds = %for.body.91
  br label %if.end.101.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!2, !2, i64 0}
