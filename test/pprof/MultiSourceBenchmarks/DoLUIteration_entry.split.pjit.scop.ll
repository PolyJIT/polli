
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/nbench/nbench1.c.DoLUIteration_entry.split.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @DoLUIteration_entry.split.pjit.scop(i64 %numarrays, double* %abase, double* %a, double* %bbase, double* %b)  {
newFuncRoot:
  br label %entry.split

for.end.19.exitStub:                              ; preds = %for.end.19.loopexit, %entry.split
  ret void

entry.split:                                      ; preds = %newFuncRoot
  %cmp.69 = icmp eq i64 %numarrays, 0
  br i1 %cmp.69, label %for.end.19.exitStub, label %for.body.preheader

for.body.preheader:                               ; preds = %entry.split
  br label %for.body

for.body:                                         ; preds = %for.inc.17, %for.body.preheader
  %j.070 = phi i64 [ %inc18, %for.inc.17 ], [ 0, %for.body.preheader ]
  %mul1 = mul i64 %j.070, 10201
  %add.ptr = getelementptr inbounds double, double* %abase, i64 %mul1
  br label %for.body.6

for.body.6:                                       ; preds = %for.body.6, %for.body
  %i.067 = phi i64 [ 0, %for.body ], [ %inc, %for.body.6 ]
  %add.ptr7 = getelementptr inbounds double, double* %a, i64 %i.067
  %0 = bitcast double* %add.ptr7 to i64*
  %1 = load i64, i64* %0, align 8, !tbaa !0
  %add.ptr8 = getelementptr inbounds double, double* %add.ptr, i64 %i.067
  %2 = bitcast double* %add.ptr8 to i64*
  store i64 %1, i64* %2, align 8, !tbaa !0
  %inc = add nuw nsw i64 %i.067, 1
  %exitcond88 = icmp eq i64 %inc, 10201
  br i1 %exitcond88, label %for.body.11.preheader, label %for.body.6

for.body.11.preheader:                            ; preds = %for.body.6
  %mul = mul i64 %j.070, 101
  %add.ptr3 = getelementptr inbounds double, double* %bbase, i64 %mul
  br label %for.body.11

for.body.11:                                      ; preds = %for.body.11, %for.body.11.preheader
  %i.168 = phi i64 [ %inc15, %for.body.11 ], [ 0, %for.body.11.preheader ]
  %add.ptr12 = getelementptr inbounds double, double* %b, i64 %i.168
  %3 = bitcast double* %add.ptr12 to i64*
  %4 = load i64, i64* %3, align 8, !tbaa !0
  %add.ptr13 = getelementptr inbounds double, double* %add.ptr3, i64 %i.168
  %5 = bitcast double* %add.ptr13 to i64*
  store i64 %4, i64* %5, align 8, !tbaa !0
  %inc15 = add nuw nsw i64 %i.168, 1
  %exitcond89 = icmp eq i64 %inc15, 101
  br i1 %exitcond89, label %for.inc.17, label %for.body.11

for.inc.17:                                       ; preds = %for.body.11
  %inc18 = add nuw i64 %j.070, 1
  %exitcond90 = icmp eq i64 %inc18, %numarrays
  br i1 %exitcond90, label %for.end.19.loopexit, label %for.body

for.end.19.loopexit:                              ; preds = %for.inc.17
  br label %for.end.19.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
