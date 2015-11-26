
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/Prolangs-C/TimberWolfMC/makesite.c.Vside_if.then.27.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.kbox = type { i32, i32, i32, i32, i32 }

; Function Attrs: nounwind
define weak void @Vside_if.then.27.pjit.scop(i32 %sub26, i32 %div25, %struct.kbox** nonnull %kArray)  {
newFuncRoot:
  br label %if.then.27

if.end.102.exitStub:                              ; preds = %if.end.102.loopexit366, %for.cond.91.preheader, %if.end.102.loopexit, %for.cond.57.preheader
  ret void

if.then.27:                                       ; preds = %newFuncRoot
  %cmp28 = icmp sgt i32 %sub26, 50
  br i1 %cmp28, label %for.cond.preheader, label %for.cond.69.preheader

for.cond.preheader:                               ; preds = %if.then.27
  %0 = load %struct.kbox*, %struct.kbox** %kArray, align 8, !tbaa !0
  br label %for.body

for.body:                                         ; preds = %for.body, %for.cond.preheader
  %indvars.iv355 = phi i64 [ 1, %for.cond.preheader ], [ %indvars.iv.next356, %for.body ]
  %cap = getelementptr inbounds %struct.kbox, %struct.kbox* %0, i64 %indvars.iv355, i32 0
  store i32 0, i32* %cap, align 4, !tbaa !4
  %HV = getelementptr inbounds %struct.kbox, %struct.kbox* %0, i64 %indvars.iv355, i32 1
  store i32 0, i32* %HV, align 4, !tbaa !7
  %sp = getelementptr inbounds %struct.kbox, %struct.kbox* %0, i64 %indvars.iv355, i32 2
  store i32 0, i32* %sp, align 4, !tbaa !8
  %x41 = getelementptr inbounds %struct.kbox, %struct.kbox* %0, i64 %indvars.iv355, i32 3
  store i32 0, i32* %x41, align 4, !tbaa !9
  %y = getelementptr inbounds %struct.kbox, %struct.kbox* %0, i64 %indvars.iv355, i32 4
  store i32 0, i32* %y, align 4, !tbaa !10
  %indvars.iv.next356 = add nuw nsw i64 %indvars.iv355, 1
  %exitcond357 = icmp eq i64 %indvars.iv.next356, 51
  br i1 %exitcond357, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  %div45 = sdiv i32 %sub26, 50
  %1 = load %struct.kbox*, %struct.kbox** %kArray, align 8, !tbaa !0
  br label %for.body.49

for.body.49:                                      ; preds = %for.body.49, %for.end
  %indvars.iv352 = phi i64 [ 1, %for.end ], [ %indvars.iv.next353, %for.body.49 ]
  %cap52 = getelementptr inbounds %struct.kbox, %struct.kbox* %1, i64 %indvars.iv352, i32 0
  %2 = load i32, i32* %cap52, align 4, !tbaa !4
  %add53 = add nsw i32 %2, %div45
  store i32 %add53, i32* %cap52, align 4, !tbaa !4
  %indvars.iv.next353 = add nuw nsw i64 %indvars.iv352, 1
  %exitcond354 = icmp eq i64 %indvars.iv.next353, 51
  br i1 %exitcond354, label %for.cond.57.preheader, label %for.body.49

for.cond.57.preheader:                            ; preds = %for.body.49
  %rem = srem i32 %sub26, 50
  %cmp58.335 = icmp slt i32 %rem, 1
  br i1 %cmp58.335, label %if.end.102.exitStub, label %for.body.60.lr.ph

for.body.60.lr.ph:                                ; preds = %for.cond.57.preheader
  %3 = load %struct.kbox*, %struct.kbox** %kArray, align 8, !tbaa !0
  %4 = add nsw i32 %rem, 1
  br label %for.body.60

for.body.60:                                      ; preds = %for.body.60, %for.body.60.lr.ph
  %indvars.iv348 = phi i64 [ %indvars.iv.next349, %for.body.60 ], [ 1, %for.body.60.lr.ph ]
  %cap63 = getelementptr inbounds %struct.kbox, %struct.kbox* %3, i64 %indvars.iv348, i32 0
  %5 = load i32, i32* %cap63, align 4, !tbaa !4
  %inc64 = add nsw i32 %5, 1
  store i32 %inc64, i32* %cap63, align 4, !tbaa !4
  %indvars.iv.next349 = add nuw nsw i64 %indvars.iv348, 1
  %lftr.wideiv369 = trunc i64 %indvars.iv.next349 to i32
  %exitcond370 = icmp eq i32 %lftr.wideiv369, %4
  br i1 %exitcond370, label %if.end.102.loopexit, label %for.body.60

if.end.102.loopexit:                              ; preds = %for.body.60
  br label %if.end.102.exitStub

for.cond.69.preheader:                            ; preds = %if.then.27
  %cmp70.341 = icmp sgt i32 %div25, 1
  br i1 %cmp70.341, label %for.body.72.lr.ph, label %for.cond.91.preheader

for.body.72.lr.ph:                                ; preds = %for.cond.69.preheader
  %6 = load %struct.kbox*, %struct.kbox** %kArray, align 8, !tbaa !0
  br label %for.body.72

for.body.72:                                      ; preds = %for.body.72, %for.body.72.lr.ph
  %indvars.iv362 = phi i64 [ 1, %for.body.72.lr.ph ], [ %indvars.iv.next363, %for.body.72 ]
  %cap75 = getelementptr inbounds %struct.kbox, %struct.kbox* %6, i64 %indvars.iv362, i32 0
  store i32 0, i32* %cap75, align 4, !tbaa !4
  %HV78 = getelementptr inbounds %struct.kbox, %struct.kbox* %6, i64 %indvars.iv362, i32 1
  store i32 0, i32* %HV78, align 4, !tbaa !7
  %sp81 = getelementptr inbounds %struct.kbox, %struct.kbox* %6, i64 %indvars.iv362, i32 2
  store i32 0, i32* %sp81, align 4, !tbaa !8
  %x84 = getelementptr inbounds %struct.kbox, %struct.kbox* %6, i64 %indvars.iv362, i32 3
  store i32 0, i32* %x84, align 4, !tbaa !9
  %y87 = getelementptr inbounds %struct.kbox, %struct.kbox* %6, i64 %indvars.iv362, i32 4
  store i32 0, i32* %y87, align 4, !tbaa !10
  %indvars.iv.next363 = add nuw nsw i64 %indvars.iv362, 1
  %lftr.wideiv373 = trunc i64 %indvars.iv.next363 to i32
  %exitcond374 = icmp eq i32 %lftr.wideiv373, %div25
  br i1 %exitcond374, label %for.cond.91.preheader.loopexit, label %for.body.72

for.cond.91.preheader.loopexit:                   ; preds = %for.body.72
  br label %for.cond.91.preheader

for.cond.91.preheader:                            ; preds = %for.cond.91.preheader.loopexit, %for.cond.69.preheader
  %cmp92.339 = icmp sgt i32 %div25, 1
  br i1 %cmp92.339, label %for.body.94.lr.ph, label %if.end.102.exitStub

for.body.94.lr.ph:                                ; preds = %for.cond.91.preheader
  %7 = load %struct.kbox*, %struct.kbox** %kArray, align 8, !tbaa !0
  br label %for.body.94

for.body.94:                                      ; preds = %for.body.94, %for.body.94.lr.ph
  %indvars.iv358 = phi i64 [ 1, %for.body.94.lr.ph ], [ %indvars.iv.next359, %for.body.94 ]
  %cap97 = getelementptr inbounds %struct.kbox, %struct.kbox* %7, i64 %indvars.iv358, i32 0
  store i32 1, i32* %cap97, align 4, !tbaa !4
  %indvars.iv.next359 = add nuw nsw i64 %indvars.iv358, 1
  %lftr.wideiv371 = trunc i64 %indvars.iv.next359 to i32
  %exitcond372 = icmp eq i32 %lftr.wideiv371, %div25
  br i1 %exitcond372, label %if.end.102.loopexit366, label %for.body.94

if.end.102.loopexit366:                           ; preds = %for.body.94
  br label %if.end.102.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"any pointer", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !6, i64 0}
!5 = !{!"kbox", !6, i64 0, !6, i64 4, !6, i64 8, !6, i64 12, !6, i64 16}
!6 = !{!"int", !2, i64 0}
!7 = !{!5, !6, i64 4}
!8 = !{!5, !6, i64 8}
!9 = !{!5, !6, i64 12}
!10 = !{!5, !6, i64 16}
