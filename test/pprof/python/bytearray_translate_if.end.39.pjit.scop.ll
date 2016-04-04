
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'Objects/bytearrayobject.c.bytearray_translate_if.end.39.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @bytearray_translate_if.end.39.pjit.scop(i8* %table.0, [256 x i32]* %trans_table)  {
newFuncRoot:
  br label %if.end.39

for.cond.67.preheader.exitStub:                   ; preds = %for.cond.67.preheader.loopexit213, %for.cond.67.preheader.loopexit
  ret void

if.end.39:                                        ; preds = %newFuncRoot
  %cmp40 = icmp eq i8* %table.0, null
  br i1 %cmp40, label %for.body.46.preheader, label %for.body.56.preheader

for.body.46.preheader:                            ; preds = %if.end.39
  br label %for.body.46

for.body.46:                                      ; preds = %for.body.46, %for.body.46.preheader
  %i.1208 = phi i64 [ %inc, %for.body.46 ], [ 0, %for.body.46.preheader ]
  %conv48 = trunc i64 %i.1208 to i32
  %conv49 = and i32 %conv48, 255
  %arrayidx50 = getelementptr [256 x i32], [256 x i32]* %trans_table, i64 0, i64 %i.1208
  store i32 %conv49, i32* %arrayidx50, align 4, !tbaa !0
  %inc = add nuw nsw i64 %i.1208, 1
  %exitcond = icmp eq i64 %inc, 256
  br i1 %exitcond, label %for.cond.67.preheader.loopexit, label %for.body.46

for.cond.67.preheader.loopexit:                   ; preds = %for.body.46
  br label %for.cond.67.preheader.exitStub

for.body.56.preheader:                            ; preds = %if.end.39
  br label %for.body.56

for.body.56:                                      ; preds = %for.body.56, %for.body.56.preheader
  %i.2209 = phi i64 [ %inc64, %for.body.56 ], [ 0, %for.body.56.preheader ]
  %arrayidx57 = getelementptr i8, i8* %table.0, i64 %i.2209
  %0 = load i8, i8* %arrayidx57, align 1, !tbaa !4
  %conv61 = zext i8 %0 to i32
  %arrayidx62 = getelementptr [256 x i32], [256 x i32]* %trans_table, i64 0, i64 %i.2209
  store i32 %conv61, i32* %arrayidx62, align 4, !tbaa !0
  %inc64 = add nuw nsw i64 %i.2209, 1
  %exitcond212 = icmp eq i64 %inc64, 256
  br i1 %exitcond212, label %for.cond.67.preheader.loopexit213, label %for.body.56

for.cond.67.preheader.loopexit213:                ; preds = %for.body.56
  br label %for.cond.67.preheader.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!2, !2, i64 0}
