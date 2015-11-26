
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/python/Python-3.4.3/Modules/_testbuffer.c.ndarray_subscript_for.body.lr.ph.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.ndbuf = type { %struct.ndbuf*, %struct.ndbuf*, i64, i64, i8*, i32, i64, %struct.bufferinfo }
%struct.bufferinfo = type { i8*, %struct._object*, i64, i64, i32, i32, i8*, i64*, i64*, i64*, i8* }
%struct._object = type { i64, %struct._typeobject* }
%struct._typeobject = type { %struct.PyVarObject, i8*, i64, i64, void (%struct._object*)*, i32 (%struct._object*, %struct._IO_FILE*, i32)*, %struct._object* (%struct._object*, i8*)*, i32 (%struct._object*, i8*, %struct._object*)*, i8*, %struct._object* (%struct._object*)*, %struct.PyNumberMethods*, %struct.PySequenceMethods*, %struct.PyMappingMethods*, i64 (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*, %struct._object*)*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, i32 (%struct._object*, %struct._object*, %struct._object*)*, %struct.PyBufferProcs*, i64, i8*, i32 (%struct._object*, i32 (%struct._object*, i8*)*, i8*)*, i32 (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*, i32)*, i64, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*)*, %struct.PyMethodDef*, %struct.PyMemberDef*, %struct.PyGetSetDef*, %struct._typeobject*, %struct._object*, %struct._object* (%struct._object*, %struct._object*, %struct._object*)*, i32 (%struct._object*, %struct._object*, %struct._object*)*, i64, i32 (%struct._object*, %struct._object*, %struct._object*)*, %struct._object* (%struct._typeobject*, i64)*, %struct._object* (%struct._typeobject*, %struct._object*, %struct._object*)*, void (i8*)*, i32 (%struct._object*)*, %struct._object*, %struct._object*, %struct._object*, %struct._object*, %struct._object*, void (%struct._object*)*, i32, void (%struct._object*)* }
%struct.PyVarObject = type { %struct._object, i64 }
%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.PyNumberMethods = type { %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*, %struct._object*)*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*)*, i32 (%struct._object*)*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*)*, i8*, %struct._object* (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*)* }
%struct.PySequenceMethods = type { i64 (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, i64)*, %struct._object* (%struct._object*, i64)*, i8*, i32 (%struct._object*, i64, %struct._object*)*, i8*, i32 (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, %struct._object* (%struct._object*, i64)* }
%struct.PyMappingMethods = type { i64 (%struct._object*)*, %struct._object* (%struct._object*, %struct._object*)*, i32 (%struct._object*, %struct._object*, %struct._object*)* }
%struct.PyBufferProcs = type { i32 (%struct._object*, %struct.bufferinfo*, i32)*, void (%struct._object*, %struct.bufferinfo*)* }
%struct.PyMethodDef = type { i8*, %struct._object* (%struct._object*, %struct._object*)*, i32, i8* }
%struct.PyMemberDef = type opaque
%struct.PyGetSetDef = type { i8*, %struct._object* (%struct._object*, i8*)*, i32 (%struct._object*, %struct._object*, i8*)*, i8*, i8* }

; Function Attrs: nounwind
define weak void @ndarray_subscript_for.body.lr.ph.i.pjit.scop(i64** %shape23.i, %struct.ndbuf*, i64* %suboffsets.0.i, i32, i64*, i64*, i64** %suboffsets8.i)  {
newFuncRoot:
  br label %for.body.lr.ph.i

if.end.54.exitStub:                               ; preds = %if.end.54.loopexit236, %if.end.54.loopexit
  ret void

for.body.lr.ph.i:                                 ; preds = %newFuncRoot
  %4 = load i64*, i64** %shape23.i, align 8, !tbaa !0
  %strides25.i = getelementptr inbounds %struct.ndbuf, %struct.ndbuf* %0, i64 0, i32 7, i32 8
  %5 = load i64*, i64** %strides25.i, align 8, !tbaa !7
  %tobool28.i = icmp eq i64* %suboffsets.0.i, null
  br i1 %tobool28.i, label %for.body.us.i.preheader, label %for.body.i.preheader

for.body.us.i.preheader:                          ; preds = %for.body.lr.ph.i
  %6 = sext i32 %1 to i64
  br label %for.body.us.i

for.body.us.i:                                    ; preds = %for.body.us.i, %for.body.us.i.preheader
  %i.092.us.i = phi i64 [ %inc.us.i, %for.body.us.i ], [ 0, %for.body.us.i.preheader ]
  %arrayidx.us.i = getelementptr i64, i64* %4, i64 %i.092.us.i
  %7 = load i64, i64* %arrayidx.us.i, align 8, !tbaa !8
  %arrayidx24.us.i = getelementptr i64, i64* %2, i64 %i.092.us.i
  store i64 %7, i64* %arrayidx24.us.i, align 8, !tbaa !8
  %arrayidx26.us.i = getelementptr i64, i64* %5, i64 %i.092.us.i
  %8 = load i64, i64* %arrayidx26.us.i, align 8, !tbaa !8
  %arrayidx27.us.i = getelementptr i64, i64* %3, i64 %i.092.us.i
  store i64 %8, i64* %arrayidx27.us.i, align 8, !tbaa !8
  %inc.us.i = add nuw nsw i64 %i.092.us.i, 1
  %exitcond233 = icmp eq i64 %inc.us.i, %6
  br i1 %exitcond233, label %if.end.54.loopexit, label %for.body.us.i

if.end.54.loopexit:                               ; preds = %for.body.us.i
  br label %if.end.54.exitStub

for.body.i.preheader:                             ; preds = %for.body.lr.ph.i
  %9 = load i64*, i64** %suboffsets8.i, align 8, !tbaa !9
  %10 = sext i32 %1 to i64
  br label %for.body.i

for.body.i:                                       ; preds = %for.body.i, %for.body.i.preheader
  %i.092.i = phi i64 [ %inc.i, %for.body.i ], [ 0, %for.body.i.preheader ]
  %arrayidx.i = getelementptr i64, i64* %4, i64 %i.092.i
  %11 = load i64, i64* %arrayidx.i, align 8, !tbaa !8
  %arrayidx24.i = getelementptr i64, i64* %2, i64 %i.092.i
  store i64 %11, i64* %arrayidx24.i, align 8, !tbaa !8
  %arrayidx26.i = getelementptr i64, i64* %5, i64 %i.092.i
  %12 = load i64, i64* %arrayidx26.i, align 8, !tbaa !8
  %arrayidx27.i = getelementptr i64, i64* %3, i64 %i.092.i
  store i64 %12, i64* %arrayidx27.i, align 8, !tbaa !8
  %arrayidx31.i = getelementptr i64, i64* %9, i64 %i.092.i
  %13 = load i64, i64* %arrayidx31.i, align 8, !tbaa !8
  %arrayidx32.i = getelementptr i64, i64* %suboffsets.0.i, i64 %i.092.i
  store i64 %13, i64* %arrayidx32.i, align 8, !tbaa !8
  %inc.i = add nuw nsw i64 %i.092.i, 1
  %exitcond234 = icmp eq i64 %inc.i, %10
  br i1 %exitcond234, label %if.end.54.loopexit236, label %for.body.i

if.end.54.loopexit236:                            ; preds = %for.body.i
  br label %if.end.54.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 48}
!1 = !{!"bufferinfo", !2, i64 0, !2, i64 8, !5, i64 16, !5, i64 24, !6, i64 32, !6, i64 36, !2, i64 40, !2, i64 48, !2, i64 56, !2, i64 64, !2, i64 72}
!2 = !{!"any pointer", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!"long", !3, i64 0}
!6 = !{!"int", !3, i64 0}
!7 = !{!1, !2, i64 56}
!8 = !{!5, !5, i64 0}
!9 = !{!1, !2, i64 64}
