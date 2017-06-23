; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polli-process-unprofitable  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 2 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/python/Python-3.4.3/Modules/pyexpat.c.PyUnknownEncodingHandler_cond.end.65.split.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.XML_Encoding = type { [256 x i32], i8*, i32 (i8*, i8*)*, void (i8*)* }

; Function Attrs: nounwind
define weak void @PyUnknownEncodingHandler_cond.end.65.split.us.pjit.scop(i1 %cmp78, i8* %cond66, %struct.XML_Encoding* %info)  {
newFuncRoot:
  br label %cond.end.65.split.us

for.end.103.exitStub:                             ; preds = %for.end.103.loopexit217, %for.end.103.loopexit
  ret void

cond.end.65.split.us:                             ; preds = %newFuncRoot
  br i1 %cmp78, label %cond.end.89.thread.us.us.preheader, label %cond.end.89.thread.us.preheader

cond.end.89.thread.us.us.preheader:               ; preds = %cond.end.65.split.us
  br label %cond.end.89.thread.us.us

cond.end.89.thread.us.us:                         ; preds = %cond.end.89.thread.us.us, %cond.end.89.thread.us.us.preheader
  %indvars.iv = phi i64 [ %indvars.iv.next, %cond.end.89.thread.us.us ], [ 0, %cond.end.89.thread.us.us.preheader ]
  %arrayidx75.us.us = getelementptr i8, i8* %cond66, i64 %indvars.iv
  %0 = load i8, i8* %arrayidx75.us.us, align 1, !tbaa !0
  %conv76.us.us = zext i8 %0 to i32
  %arrayidx99.165.us.us = getelementptr %struct.XML_Encoding, %struct.XML_Encoding* %info, i64 0, i32 0, i64 %indvars.iv
  store i32 %conv76.us.us, i32* %arrayidx99.165.us.us, align 4, !tbaa !3
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 256
  br i1 %exitcond, label %for.end.103.loopexit, label %cond.end.89.thread.us.us

for.end.103.loopexit:                             ; preds = %cond.end.89.thread.us.us
  br label %for.end.103.exitStub

cond.end.89.thread.us.preheader:                  ; preds = %cond.end.65.split.us
  br label %cond.end.89.thread.us

cond.end.89.thread.us:                            ; preds = %cond.end.89.thread.us, %cond.end.89.thread.us.preheader
  %indvars.iv205 = phi i64 [ %indvars.iv.next206, %cond.end.89.thread.us ], [ 0, %cond.end.89.thread.us.preheader ]
  %arrayidx75.us = getelementptr i8, i8* %cond66, i64 %indvars.iv205
  %1 = load i8, i8* %arrayidx75.us, align 1, !tbaa !0
  %conv76.us = zext i8 %1 to i32
  %arrayidx99.165.us = getelementptr %struct.XML_Encoding, %struct.XML_Encoding* %info, i64 0, i32 0, i64 %indvars.iv205
  store i32 %conv76.us, i32* %arrayidx99.165.us, align 4, !tbaa !3
  %indvars.iv.next206 = add nuw nsw i64 %indvars.iv205, 1
  %exitcond207 = icmp eq i64 %indvars.iv.next206, 256
  br i1 %exitcond207, label %for.end.103.loopexit217, label %cond.end.89.thread.us

for.end.103.loopexit217:                          ; preds = %cond.end.89.thread.us
  br label %for.end.103.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !1, i64 0}
