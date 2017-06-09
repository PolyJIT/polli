
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/medley/reg_detect/reg_detect.c.main_for.cond.8.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.8.preheader.i.pjit.scop(i8*, [6 x [64 x i32]]* %arraydecay10, [6 x [64 x i32]]* %arraydecay11, [6 x i32]* %arraydecay5, i32* %arrayidx93.i, i32* %arrayidx96.i, i32*, i32*, i32*, i32*, i32*, i32*, i32*, i32*, i32*, i32*, i8*, i8*, i32*)  {
newFuncRoot:
  br label %for.cond.8.preheader.i

for.cond.1.preheader.i.61.preheader.exitStub:     ; preds = %for.body.90.i
  ret void

for.cond.8.preheader.i:                           ; preds = %for.body.90.i, %newFuncRoot
  %t.014.i = phi i32 [ 0, %newFuncRoot ], [ %inc130.i, %for.body.90.i ]
  %arrayidx13.i = bitcast i8* %0 to i32*
  br label %for.body.11.i

for.body.11.i:                                    ; preds = %for.body.11.i, %for.cond.8.preheader.i
  %indvars.iv.i = phi i64 [ 0, %for.cond.8.preheader.i ], [ %indvars.iv.next.i, %for.body.11.i ]
  %14 = load i32, i32* %arrayidx13.i, align 4, !tbaa !0
  %arrayidx19.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 0, i64 0, i64 %indvars.iv.i
  store i32 %14, i32* %arrayidx19.i, align 4, !tbaa !0
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %exitcond.i = icmp eq i64 %indvars.iv.next.i, 64
  br i1 %exitcond.i, label %for.inc.20.i, label %for.body.11.i

for.inc.20.i:                                     ; preds = %for.body.11.i
  %arrayidx13.i.1 = getelementptr inbounds i8, i8* %0, i64 4
  %15 = bitcast i8* %arrayidx13.i.1 to i32*
  br label %for.body.11.i.1

for.body.11.i.1:                                  ; preds = %for.body.11.i.1, %for.inc.20.i
  %indvars.iv.i.1 = phi i64 [ 0, %for.inc.20.i ], [ %indvars.iv.next.i.1, %for.body.11.i.1 ]
  %16 = load i32, i32* %15, align 4, !tbaa !0
  %arrayidx19.i.1 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 0, i64 1, i64 %indvars.iv.i.1
  store i32 %16, i32* %arrayidx19.i.1, align 4, !tbaa !0
  %indvars.iv.next.i.1 = add nuw nsw i64 %indvars.iv.i.1, 1
  %exitcond.i.1 = icmp eq i64 %indvars.iv.next.i.1, 64
  br i1 %exitcond.i.1, label %for.inc.20.i.1, label %for.body.11.i.1

for.inc.20.i.1:                                   ; preds = %for.body.11.i.1
  %arrayidx13.i.2 = getelementptr inbounds i8, i8* %0, i64 8
  %17 = bitcast i8* %arrayidx13.i.2 to i32*
  br label %for.body.11.i.2

for.body.11.i.2:                                  ; preds = %for.body.11.i.2, %for.inc.20.i.1
  %indvars.iv.i.2 = phi i64 [ 0, %for.inc.20.i.1 ], [ %indvars.iv.next.i.2, %for.body.11.i.2 ]
  %18 = load i32, i32* %17, align 4, !tbaa !0
  %arrayidx19.i.2 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 0, i64 2, i64 %indvars.iv.i.2
  store i32 %18, i32* %arrayidx19.i.2, align 4, !tbaa !0
  %indvars.iv.next.i.2 = add nuw nsw i64 %indvars.iv.i.2, 1
  %exitcond.i.2 = icmp eq i64 %indvars.iv.next.i.2, 64
  br i1 %exitcond.i.2, label %for.inc.20.i.2, label %for.body.11.i.2

for.inc.20.i.2:                                   ; preds = %for.body.11.i.2
  %arrayidx13.i.3 = getelementptr inbounds i8, i8* %0, i64 12
  %19 = bitcast i8* %arrayidx13.i.3 to i32*
  br label %for.body.11.i.3

for.body.11.i.3:                                  ; preds = %for.body.11.i.3, %for.inc.20.i.2
  %indvars.iv.i.3 = phi i64 [ 0, %for.inc.20.i.2 ], [ %indvars.iv.next.i.3, %for.body.11.i.3 ]
  %20 = load i32, i32* %19, align 4, !tbaa !0
  %arrayidx19.i.3 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 0, i64 3, i64 %indvars.iv.i.3
  store i32 %20, i32* %arrayidx19.i.3, align 4, !tbaa !0
  %indvars.iv.next.i.3 = add nuw nsw i64 %indvars.iv.i.3, 1
  %exitcond.i.3 = icmp eq i64 %indvars.iv.next.i.3, 64
  br i1 %exitcond.i.3, label %for.inc.20.i.3, label %for.body.11.i.3

for.inc.20.i.3:                                   ; preds = %for.body.11.i.3
  %arrayidx13.i.4 = getelementptr inbounds i8, i8* %0, i64 16
  %21 = bitcast i8* %arrayidx13.i.4 to i32*
  br label %for.body.11.i.4

for.body.11.i.4:                                  ; preds = %for.body.11.i.4, %for.inc.20.i.3
  %indvars.iv.i.4 = phi i64 [ 0, %for.inc.20.i.3 ], [ %indvars.iv.next.i.4, %for.body.11.i.4 ]
  %22 = load i32, i32* %21, align 4, !tbaa !0
  %arrayidx19.i.4 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 0, i64 4, i64 %indvars.iv.i.4
  store i32 %22, i32* %arrayidx19.i.4, align 4, !tbaa !0
  %indvars.iv.next.i.4 = add nuw nsw i64 %indvars.iv.i.4, 1
  %exitcond.i.4 = icmp eq i64 %indvars.iv.next.i.4, 64
  br i1 %exitcond.i.4, label %for.inc.20.i.4, label %for.body.11.i.4

for.inc.20.i.4:                                   ; preds = %for.body.11.i.4
  %arrayidx13.i.5 = getelementptr inbounds i8, i8* %0, i64 20
  %23 = bitcast i8* %arrayidx13.i.5 to i32*
  br label %for.body.11.i.5

for.body.11.i.5:                                  ; preds = %for.body.11.i.5, %for.inc.20.i.4
  %indvars.iv.i.5 = phi i64 [ 0, %for.inc.20.i.4 ], [ %indvars.iv.next.i.5, %for.body.11.i.5 ]
  %24 = load i32, i32* %23, align 4, !tbaa !0
  %arrayidx19.i.5 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 0, i64 5, i64 %indvars.iv.i.5
  store i32 %24, i32* %arrayidx19.i.5, align 4, !tbaa !0
  %indvars.iv.next.i.5 = add nuw nsw i64 %indvars.iv.i.5, 1
  %exitcond.i.5 = icmp eq i64 %indvars.iv.next.i.5, 64
  br i1 %exitcond.i.5, label %for.inc.20.i.5, label %for.body.11.i.5

for.inc.20.i.5:                                   ; preds = %for.body.11.i.5
  %arrayidx13.1.i = getelementptr inbounds i8, i8* %0, i64 28
  %25 = bitcast i8* %arrayidx13.1.i to i32*
  br label %for.body.11.1.i

for.body.11.1.i:                                  ; preds = %for.body.11.1.i, %for.inc.20.i.5
  %indvars.iv.1.i = phi i64 [ 0, %for.inc.20.i.5 ], [ %indvars.iv.next.1.i, %for.body.11.1.i ]
  %26 = load i32, i32* %25, align 4, !tbaa !0
  %arrayidx19.1.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 1, i64 1, i64 %indvars.iv.1.i
  store i32 %26, i32* %arrayidx19.1.i, align 4, !tbaa !0
  %indvars.iv.next.1.i = add nuw nsw i64 %indvars.iv.1.i, 1
  %exitcond.1.i = icmp eq i64 %indvars.iv.next.1.i, 64
  br i1 %exitcond.1.i, label %for.inc.20.1.i, label %for.body.11.1.i

for.inc.20.1.i:                                   ; preds = %for.body.11.1.i
  %arrayidx13.1.i.1 = getelementptr inbounds i8, i8* %0, i64 32
  %27 = bitcast i8* %arrayidx13.1.i.1 to i32*
  br label %for.body.11.1.i.1

for.body.11.1.i.1:                                ; preds = %for.body.11.1.i.1, %for.inc.20.1.i
  %indvars.iv.1.i.1 = phi i64 [ 0, %for.inc.20.1.i ], [ %indvars.iv.next.1.i.1, %for.body.11.1.i.1 ]
  %28 = load i32, i32* %27, align 4, !tbaa !0
  %arrayidx19.1.i.1 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 1, i64 2, i64 %indvars.iv.1.i.1
  store i32 %28, i32* %arrayidx19.1.i.1, align 4, !tbaa !0
  %indvars.iv.next.1.i.1 = add nuw nsw i64 %indvars.iv.1.i.1, 1
  %exitcond.1.i.1 = icmp eq i64 %indvars.iv.next.1.i.1, 64
  br i1 %exitcond.1.i.1, label %for.inc.20.1.i.1, label %for.body.11.1.i.1

for.inc.20.1.i.1:                                 ; preds = %for.body.11.1.i.1
  %arrayidx13.1.i.2 = getelementptr inbounds i8, i8* %0, i64 36
  %29 = bitcast i8* %arrayidx13.1.i.2 to i32*
  br label %for.body.11.1.i.2

for.body.11.1.i.2:                                ; preds = %for.body.11.1.i.2, %for.inc.20.1.i.1
  %indvars.iv.1.i.2 = phi i64 [ 0, %for.inc.20.1.i.1 ], [ %indvars.iv.next.1.i.2, %for.body.11.1.i.2 ]
  %30 = load i32, i32* %29, align 4, !tbaa !0
  %arrayidx19.1.i.2 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 1, i64 3, i64 %indvars.iv.1.i.2
  store i32 %30, i32* %arrayidx19.1.i.2, align 4, !tbaa !0
  %indvars.iv.next.1.i.2 = add nuw nsw i64 %indvars.iv.1.i.2, 1
  %exitcond.1.i.2 = icmp eq i64 %indvars.iv.next.1.i.2, 64
  br i1 %exitcond.1.i.2, label %for.inc.20.1.i.2, label %for.body.11.1.i.2

for.inc.20.1.i.2:                                 ; preds = %for.body.11.1.i.2
  %arrayidx13.1.i.3 = getelementptr inbounds i8, i8* %0, i64 40
  %31 = bitcast i8* %arrayidx13.1.i.3 to i32*
  br label %for.body.11.1.i.3

for.body.11.1.i.3:                                ; preds = %for.body.11.1.i.3, %for.inc.20.1.i.2
  %indvars.iv.1.i.3 = phi i64 [ 0, %for.inc.20.1.i.2 ], [ %indvars.iv.next.1.i.3, %for.body.11.1.i.3 ]
  %32 = load i32, i32* %31, align 4, !tbaa !0
  %arrayidx19.1.i.3 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 1, i64 4, i64 %indvars.iv.1.i.3
  store i32 %32, i32* %arrayidx19.1.i.3, align 4, !tbaa !0
  %indvars.iv.next.1.i.3 = add nuw nsw i64 %indvars.iv.1.i.3, 1
  %exitcond.1.i.3 = icmp eq i64 %indvars.iv.next.1.i.3, 64
  br i1 %exitcond.1.i.3, label %for.inc.20.1.i.3, label %for.body.11.1.i.3

for.inc.20.1.i.3:                                 ; preds = %for.body.11.1.i.3
  %arrayidx13.1.i.4 = getelementptr inbounds i8, i8* %0, i64 44
  %33 = bitcast i8* %arrayidx13.1.i.4 to i32*
  br label %for.body.11.1.i.4

for.body.11.1.i.4:                                ; preds = %for.body.11.1.i.4, %for.inc.20.1.i.3
  %indvars.iv.1.i.4 = phi i64 [ 0, %for.inc.20.1.i.3 ], [ %indvars.iv.next.1.i.4, %for.body.11.1.i.4 ]
  %34 = load i32, i32* %33, align 4, !tbaa !0
  %arrayidx19.1.i.4 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 1, i64 5, i64 %indvars.iv.1.i.4
  store i32 %34, i32* %arrayidx19.1.i.4, align 4, !tbaa !0
  %indvars.iv.next.1.i.4 = add nuw nsw i64 %indvars.iv.1.i.4, 1
  %exitcond.1.i.4 = icmp eq i64 %indvars.iv.next.1.i.4, 64
  br i1 %exitcond.1.i.4, label %for.inc.20.1.i.4, label %for.body.11.1.i.4

for.inc.20.1.i.4:                                 ; preds = %for.body.11.1.i.4
  %arrayidx13.2.i = getelementptr inbounds i8, i8* %0, i64 56
  %35 = bitcast i8* %arrayidx13.2.i to i32*
  br label %for.body.11.2.i

for.body.11.2.i:                                  ; preds = %for.body.11.2.i, %for.inc.20.1.i.4
  %indvars.iv.2.i = phi i64 [ 0, %for.inc.20.1.i.4 ], [ %indvars.iv.next.2.i, %for.body.11.2.i ]
  %36 = load i32, i32* %35, align 4, !tbaa !0
  %arrayidx19.2.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 2, i64 2, i64 %indvars.iv.2.i
  store i32 %36, i32* %arrayidx19.2.i, align 4, !tbaa !0
  %indvars.iv.next.2.i = add nuw nsw i64 %indvars.iv.2.i, 1
  %exitcond.2.i = icmp eq i64 %indvars.iv.next.2.i, 64
  br i1 %exitcond.2.i, label %for.inc.20.2.i, label %for.body.11.2.i

for.inc.20.2.i:                                   ; preds = %for.body.11.2.i
  %arrayidx13.2.i.1 = getelementptr inbounds i8, i8* %0, i64 60
  %37 = bitcast i8* %arrayidx13.2.i.1 to i32*
  br label %for.body.11.2.i.1

for.body.11.2.i.1:                                ; preds = %for.body.11.2.i.1, %for.inc.20.2.i
  %indvars.iv.2.i.1 = phi i64 [ 0, %for.inc.20.2.i ], [ %indvars.iv.next.2.i.1, %for.body.11.2.i.1 ]
  %38 = load i32, i32* %37, align 4, !tbaa !0
  %arrayidx19.2.i.1 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 2, i64 3, i64 %indvars.iv.2.i.1
  store i32 %38, i32* %arrayidx19.2.i.1, align 4, !tbaa !0
  %indvars.iv.next.2.i.1 = add nuw nsw i64 %indvars.iv.2.i.1, 1
  %exitcond.2.i.1 = icmp eq i64 %indvars.iv.next.2.i.1, 64
  br i1 %exitcond.2.i.1, label %for.inc.20.2.i.1, label %for.body.11.2.i.1

for.inc.20.2.i.1:                                 ; preds = %for.body.11.2.i.1
  %arrayidx13.2.i.2 = getelementptr inbounds i8, i8* %0, i64 64
  %39 = bitcast i8* %arrayidx13.2.i.2 to i32*
  br label %for.body.11.2.i.2

for.body.11.2.i.2:                                ; preds = %for.body.11.2.i.2, %for.inc.20.2.i.1
  %indvars.iv.2.i.2 = phi i64 [ 0, %for.inc.20.2.i.1 ], [ %indvars.iv.next.2.i.2, %for.body.11.2.i.2 ]
  %40 = load i32, i32* %39, align 4, !tbaa !0
  %arrayidx19.2.i.2 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 2, i64 4, i64 %indvars.iv.2.i.2
  store i32 %40, i32* %arrayidx19.2.i.2, align 4, !tbaa !0
  %indvars.iv.next.2.i.2 = add nuw nsw i64 %indvars.iv.2.i.2, 1
  %exitcond.2.i.2 = icmp eq i64 %indvars.iv.next.2.i.2, 64
  br i1 %exitcond.2.i.2, label %for.inc.20.2.i.2, label %for.body.11.2.i.2

for.inc.20.2.i.2:                                 ; preds = %for.body.11.2.i.2
  %arrayidx13.2.i.3 = getelementptr inbounds i8, i8* %0, i64 68
  %41 = bitcast i8* %arrayidx13.2.i.3 to i32*
  br label %for.body.11.2.i.3

for.body.11.2.i.3:                                ; preds = %for.body.11.2.i.3, %for.inc.20.2.i.2
  %indvars.iv.2.i.3 = phi i64 [ 0, %for.inc.20.2.i.2 ], [ %indvars.iv.next.2.i.3, %for.body.11.2.i.3 ]
  %42 = load i32, i32* %41, align 4, !tbaa !0
  %arrayidx19.2.i.3 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 2, i64 5, i64 %indvars.iv.2.i.3
  store i32 %42, i32* %arrayidx19.2.i.3, align 4, !tbaa !0
  %indvars.iv.next.2.i.3 = add nuw nsw i64 %indvars.iv.2.i.3, 1
  %exitcond.2.i.3 = icmp eq i64 %indvars.iv.next.2.i.3, 64
  br i1 %exitcond.2.i.3, label %for.inc.20.2.i.3, label %for.body.11.2.i.3

for.inc.20.2.i.3:                                 ; preds = %for.body.11.2.i.3
  %arrayidx13.3.i = getelementptr inbounds i8, i8* %0, i64 84
  %43 = bitcast i8* %arrayidx13.3.i to i32*
  br label %for.body.11.3.i

for.body.11.3.i:                                  ; preds = %for.body.11.3.i, %for.inc.20.2.i.3
  %indvars.iv.3.i = phi i64 [ 0, %for.inc.20.2.i.3 ], [ %indvars.iv.next.3.i, %for.body.11.3.i ]
  %44 = load i32, i32* %43, align 4, !tbaa !0
  %arrayidx19.3.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 3, i64 3, i64 %indvars.iv.3.i
  store i32 %44, i32* %arrayidx19.3.i, align 4, !tbaa !0
  %indvars.iv.next.3.i = add nuw nsw i64 %indvars.iv.3.i, 1
  %exitcond.3.i = icmp eq i64 %indvars.iv.next.3.i, 64
  br i1 %exitcond.3.i, label %for.inc.20.3.i, label %for.body.11.3.i

for.inc.20.3.i:                                   ; preds = %for.body.11.3.i
  %arrayidx13.3.i.1 = getelementptr inbounds i8, i8* %0, i64 88
  %45 = bitcast i8* %arrayidx13.3.i.1 to i32*
  br label %for.body.11.3.i.1

for.body.11.3.i.1:                                ; preds = %for.body.11.3.i.1, %for.inc.20.3.i
  %indvars.iv.3.i.1 = phi i64 [ 0, %for.inc.20.3.i ], [ %indvars.iv.next.3.i.1, %for.body.11.3.i.1 ]
  %46 = load i32, i32* %45, align 4, !tbaa !0
  %arrayidx19.3.i.1 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 3, i64 4, i64 %indvars.iv.3.i.1
  store i32 %46, i32* %arrayidx19.3.i.1, align 4, !tbaa !0
  %indvars.iv.next.3.i.1 = add nuw nsw i64 %indvars.iv.3.i.1, 1
  %exitcond.3.i.1 = icmp eq i64 %indvars.iv.next.3.i.1, 64
  br i1 %exitcond.3.i.1, label %for.inc.20.3.i.1, label %for.body.11.3.i.1

for.inc.20.3.i.1:                                 ; preds = %for.body.11.3.i.1
  %arrayidx13.3.i.2 = getelementptr inbounds i8, i8* %0, i64 92
  %47 = bitcast i8* %arrayidx13.3.i.2 to i32*
  br label %for.body.11.3.i.2

for.body.11.3.i.2:                                ; preds = %for.body.11.3.i.2, %for.inc.20.3.i.1
  %indvars.iv.3.i.2 = phi i64 [ 0, %for.inc.20.3.i.1 ], [ %indvars.iv.next.3.i.2, %for.body.11.3.i.2 ]
  %48 = load i32, i32* %47, align 4, !tbaa !0
  %arrayidx19.3.i.2 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 3, i64 5, i64 %indvars.iv.3.i.2
  store i32 %48, i32* %arrayidx19.3.i.2, align 4, !tbaa !0
  %indvars.iv.next.3.i.2 = add nuw nsw i64 %indvars.iv.3.i.2, 1
  %exitcond.3.i.2 = icmp eq i64 %indvars.iv.next.3.i.2, 64
  br i1 %exitcond.3.i.2, label %for.inc.20.3.i.2, label %for.body.11.3.i.2

for.inc.20.3.i.2:                                 ; preds = %for.body.11.3.i.2
  %arrayidx13.4.i = getelementptr inbounds i8, i8* %0, i64 112
  %49 = bitcast i8* %arrayidx13.4.i to i32*
  br label %for.body.11.4.i

for.body.11.4.i:                                  ; preds = %for.body.11.4.i, %for.inc.20.3.i.2
  %indvars.iv.4.i = phi i64 [ 0, %for.inc.20.3.i.2 ], [ %indvars.iv.next.4.i, %for.body.11.4.i ]
  %50 = load i32, i32* %49, align 4, !tbaa !0
  %arrayidx19.4.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 4, i64 4, i64 %indvars.iv.4.i
  store i32 %50, i32* %arrayidx19.4.i, align 4, !tbaa !0
  %indvars.iv.next.4.i = add nuw nsw i64 %indvars.iv.4.i, 1
  %exitcond.4.i = icmp eq i64 %indvars.iv.next.4.i, 64
  br i1 %exitcond.4.i, label %for.inc.20.4.i, label %for.body.11.4.i

for.inc.20.4.i:                                   ; preds = %for.body.11.4.i
  %arrayidx13.4.i.1 = getelementptr inbounds i8, i8* %0, i64 116
  %51 = bitcast i8* %arrayidx13.4.i.1 to i32*
  br label %for.body.11.4.i.1

for.body.11.4.i.1:                                ; preds = %for.body.11.4.i.1, %for.inc.20.4.i
  %indvars.iv.4.i.1 = phi i64 [ 0, %for.inc.20.4.i ], [ %indvars.iv.next.4.i.1, %for.body.11.4.i.1 ]
  %52 = load i32, i32* %51, align 4, !tbaa !0
  %arrayidx19.4.i.1 = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 4, i64 5, i64 %indvars.iv.4.i.1
  store i32 %52, i32* %arrayidx19.4.i.1, align 4, !tbaa !0
  %indvars.iv.next.4.i.1 = add nuw nsw i64 %indvars.iv.4.i.1, 1
  %exitcond.4.i.1 = icmp eq i64 %indvars.iv.next.4.i.1, 64
  br i1 %exitcond.4.i.1, label %for.inc.20.4.i.1, label %for.body.11.4.i.1

for.inc.20.4.i.1:                                 ; preds = %for.body.11.4.i.1
  %arrayidx13.5.i = getelementptr inbounds i8, i8* %0, i64 140
  %53 = bitcast i8* %arrayidx13.5.i to i32*
  br label %for.body.11.5.i

for.body.11.5.i:                                  ; preds = %for.body.11.5.i, %for.inc.20.4.i.1
  %indvars.iv.5.i = phi i64 [ 0, %for.inc.20.4.i.1 ], [ %indvars.iv.next.5.i, %for.body.11.5.i ]
  %54 = load i32, i32* %53, align 4, !tbaa !0
  %arrayidx19.5.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 5, i64 5, i64 %indvars.iv.5.i
  store i32 %54, i32* %arrayidx19.5.i, align 4, !tbaa !0
  %indvars.iv.next.5.i = add nuw nsw i64 %indvars.iv.5.i, 1
  %exitcond.5.i = icmp eq i64 %indvars.iv.next.5.i, 64
  br i1 %exitcond.5.i, label %for.body.33.lr.ph.i.preheader, label %for.body.11.5.i

for.body.33.lr.ph.i.preheader:                    ; preds = %for.body.11.5.i
  br label %for.body.33.lr.ph.i

for.body.33.lr.ph.i:                              ; preds = %for.inc.84.i, %for.body.33.lr.ph.i.preheader
  %indvars.iv33.i = phi i64 [ %indvars.iv.next34.i, %for.inc.84.i ], [ 0, %for.body.33.lr.ph.i.preheader ]
  br label %for.body.33.i

for.body.33.i:                                    ; preds = %for.end.69.i, %for.body.33.lr.ph.i
  %indvars.iv29.i = phi i64 [ %indvars.iv33.i, %for.body.33.lr.ph.i ], [ %indvars.iv.next30.i, %for.end.69.i ]
  %arrayidx38.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 %indvars.iv33.i, i64 %indvars.iv29.i, i64 0
  %55 = load i32, i32* %arrayidx38.i, align 4, !tbaa !0
  %arrayidx43.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay11, i64 %indvars.iv33.i, i64 %indvars.iv29.i, i64 0
  store i32 %55, i32* %arrayidx43.i, align 4, !tbaa !0
  br label %for.body.47.i

for.body.47.i:                                    ; preds = %for.body.47.i, %for.body.33.i
  %indvars.iv23.i = phi i64 [ 1, %for.body.33.i ], [ %indvars.iv.next24.i, %for.body.47.i ]
  %56 = add nsw i64 %indvars.iv23.i, -1
  %arrayidx54.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay11, i64 %indvars.iv33.i, i64 %indvars.iv29.i, i64 %56
  %57 = load i32, i32* %arrayidx54.i, align 4, !tbaa !0
  %arrayidx60.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay10, i64 %indvars.iv33.i, i64 %indvars.iv29.i, i64 %indvars.iv23.i
  %58 = load i32, i32* %arrayidx60.i, align 4, !tbaa !0
  %add.i = add nsw i32 %58, %57
  %arrayidx66.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay11, i64 %indvars.iv33.i, i64 %indvars.iv29.i, i64 %indvars.iv23.i
  store i32 %add.i, i32* %arrayidx66.i, align 4, !tbaa !0
  %indvars.iv.next24.i = add nuw nsw i64 %indvars.iv23.i, 1
  %exitcond26.i = icmp eq i64 %indvars.iv.next24.i, 64
  br i1 %exitcond26.i, label %for.end.69.i, label %for.body.47.i

for.end.69.i:                                     ; preds = %for.body.47.i
  %arrayidx76.i = getelementptr inbounds [6 x [64 x i32]], [6 x [64 x i32]]* %arraydecay11, i64 %indvars.iv33.i, i64 %indvars.iv29.i, i64 63
  %59 = load i32, i32* %arrayidx76.i, align 4, !tbaa !0
  %arrayidx80.i = getelementptr inbounds [6 x i32], [6 x i32]* %arraydecay5, i64 %indvars.iv33.i, i64 %indvars.iv29.i
  store i32 %59, i32* %arrayidx80.i, align 4, !tbaa !0
  %indvars.iv.next30.i = add nuw nsw i64 %indvars.iv29.i, 1
  %lftr.wideiv63 = trunc i64 %indvars.iv.next30.i to i32
  %exitcond64 = icmp eq i32 %lftr.wideiv63, 6
  br i1 %exitcond64, label %for.inc.84.i, label %for.body.33.i

for.inc.84.i:                                     ; preds = %for.end.69.i
  %indvars.iv.next34.i = add nuw nsw i64 %indvars.iv33.i, 1
  %exitcond35.i = icmp eq i64 %indvars.iv.next34.i, 6
  br i1 %exitcond35.i, label %for.body.90.i, label %for.body.33.lr.ph.i

for.body.90.i:                                    ; preds = %for.inc.84.i
  %60 = load i32, i32* %arrayidx93.i, align 4, !tbaa !0
  store i32 %60, i32* %arrayidx96.i, align 4, !tbaa !0
  %61 = load i32, i32* %1, align 4, !tbaa !0
  store i32 %61, i32* %2, align 4, !tbaa !0
  %62 = load i32, i32* %3, align 4, !tbaa !0
  store i32 %62, i32* %4, align 4, !tbaa !0
  %63 = load i32, i32* %5, align 4, !tbaa !0
  store i32 %63, i32* %6, align 4, !tbaa !0
  %64 = load i32, i32* %7, align 4, !tbaa !0
  store i32 %64, i32* %8, align 4, !tbaa !0
  %65 = load i32, i32* %9, align 4, !tbaa !0
  store i32 %65, i32* %10, align 4, !tbaa !0
  %arrayidx113.i = bitcast i8* %11 to i32*
  %66 = load i32, i32* %arrayidx113.i, align 4, !tbaa !0
  %arrayidx117.i = getelementptr inbounds i8, i8* %12, i64 28
  %67 = bitcast i8* %arrayidx117.i to i32*
  %68 = load i32, i32* %67, align 4, !tbaa !0
  %add118.i = add nsw i32 %68, %66
  %arrayidx122.i = getelementptr inbounds i8, i8* %11, i64 28
  %69 = bitcast i8* %arrayidx122.i to i32*
  store i32 %add118.i, i32* %69, align 4, !tbaa !0
  %arrayidx113.i.1 = getelementptr inbounds i8, i8* %11, i64 4
  %70 = bitcast i8* %arrayidx113.i.1 to i32*
  %71 = load i32, i32* %70, align 4, !tbaa !0
  %arrayidx117.i.1 = getelementptr inbounds i8, i8* %12, i64 32
  %72 = bitcast i8* %arrayidx117.i.1 to i32*
  %73 = load i32, i32* %72, align 4, !tbaa !0
  %add118.i.1 = add nsw i32 %73, %71
  %arrayidx122.i.1 = getelementptr inbounds i8, i8* %11, i64 32
  %74 = bitcast i8* %arrayidx122.i.1 to i32*
  store i32 %add118.i.1, i32* %74, align 4, !tbaa !0
  %arrayidx113.i.2 = getelementptr inbounds i8, i8* %11, i64 8
  %75 = bitcast i8* %arrayidx113.i.2 to i32*
  %76 = load i32, i32* %75, align 4, !tbaa !0
  %arrayidx117.i.2 = getelementptr inbounds i8, i8* %12, i64 36
  %77 = bitcast i8* %arrayidx117.i.2 to i32*
  %78 = load i32, i32* %77, align 4, !tbaa !0
  %add118.i.2 = add nsw i32 %78, %76
  %arrayidx122.i.2 = getelementptr inbounds i8, i8* %11, i64 36
  %79 = bitcast i8* %arrayidx122.i.2 to i32*
  store i32 %add118.i.2, i32* %79, align 4, !tbaa !0
  %arrayidx113.i.3 = getelementptr inbounds i8, i8* %11, i64 12
  %80 = bitcast i8* %arrayidx113.i.3 to i32*
  %81 = load i32, i32* %80, align 4, !tbaa !0
  %arrayidx117.i.3 = getelementptr inbounds i8, i8* %12, i64 40
  %82 = bitcast i8* %arrayidx117.i.3 to i32*
  %83 = load i32, i32* %82, align 4, !tbaa !0
  %add118.i.3 = add nsw i32 %83, %81
  %arrayidx122.i.3 = getelementptr inbounds i8, i8* %11, i64 40
  %84 = bitcast i8* %arrayidx122.i.3 to i32*
  store i32 %add118.i.3, i32* %84, align 4, !tbaa !0
  %arrayidx113.i.4 = getelementptr inbounds i8, i8* %11, i64 16
  %85 = bitcast i8* %arrayidx113.i.4 to i32*
  %86 = load i32, i32* %85, align 4, !tbaa !0
  %arrayidx117.i.4 = getelementptr inbounds i8, i8* %12, i64 44
  %87 = bitcast i8* %arrayidx117.i.4 to i32*
  %88 = load i32, i32* %87, align 4, !tbaa !0
  %add118.i.4 = add nsw i32 %88, %86
  %arrayidx122.i.4 = getelementptr inbounds i8, i8* %11, i64 44
  %89 = bitcast i8* %arrayidx122.i.4 to i32*
  store i32 %add118.i.4, i32* %89, align 4, !tbaa !0
  %arrayidx113.1.i = getelementptr inbounds i8, i8* %11, i64 28
  %90 = bitcast i8* %arrayidx113.1.i to i32*
  %91 = load i32, i32* %90, align 4, !tbaa !0
  %arrayidx117.1.i = getelementptr inbounds i8, i8* %12, i64 56
  %92 = bitcast i8* %arrayidx117.1.i to i32*
  %93 = load i32, i32* %92, align 4, !tbaa !0
  %add118.1.i = add nsw i32 %93, %91
  %arrayidx122.1.i = getelementptr inbounds i8, i8* %11, i64 56
  %94 = bitcast i8* %arrayidx122.1.i to i32*
  store i32 %add118.1.i, i32* %94, align 4, !tbaa !0
  %arrayidx113.1.i.1 = getelementptr inbounds i8, i8* %11, i64 32
  %95 = bitcast i8* %arrayidx113.1.i.1 to i32*
  %96 = load i32, i32* %95, align 4, !tbaa !0
  %arrayidx117.1.i.1 = getelementptr inbounds i8, i8* %12, i64 60
  %97 = bitcast i8* %arrayidx117.1.i.1 to i32*
  %98 = load i32, i32* %97, align 4, !tbaa !0
  %add118.1.i.1 = add nsw i32 %98, %96
  %arrayidx122.1.i.1 = getelementptr inbounds i8, i8* %11, i64 60
  %99 = bitcast i8* %arrayidx122.1.i.1 to i32*
  store i32 %add118.1.i.1, i32* %99, align 4, !tbaa !0
  %arrayidx113.1.i.2 = getelementptr inbounds i8, i8* %11, i64 36
  %100 = bitcast i8* %arrayidx113.1.i.2 to i32*
  %101 = load i32, i32* %100, align 4, !tbaa !0
  %arrayidx117.1.i.2 = getelementptr inbounds i8, i8* %12, i64 64
  %102 = bitcast i8* %arrayidx117.1.i.2 to i32*
  %103 = load i32, i32* %102, align 4, !tbaa !0
  %add118.1.i.2 = add nsw i32 %103, %101
  %arrayidx122.1.i.2 = getelementptr inbounds i8, i8* %11, i64 64
  %104 = bitcast i8* %arrayidx122.1.i.2 to i32*
  store i32 %add118.1.i.2, i32* %104, align 4, !tbaa !0
  %arrayidx113.1.i.3 = getelementptr inbounds i8, i8* %11, i64 40
  %105 = bitcast i8* %arrayidx113.1.i.3 to i32*
  %106 = load i32, i32* %105, align 4, !tbaa !0
  %arrayidx117.1.i.3 = getelementptr inbounds i8, i8* %12, i64 68
  %107 = bitcast i8* %arrayidx117.1.i.3 to i32*
  %108 = load i32, i32* %107, align 4, !tbaa !0
  %add118.1.i.3 = add nsw i32 %108, %106
  %arrayidx122.1.i.3 = getelementptr inbounds i8, i8* %11, i64 68
  %109 = bitcast i8* %arrayidx122.1.i.3 to i32*
  store i32 %add118.1.i.3, i32* %109, align 4, !tbaa !0
  %arrayidx113.2.i = getelementptr inbounds i8, i8* %11, i64 56
  %110 = bitcast i8* %arrayidx113.2.i to i32*
  %111 = load i32, i32* %110, align 4, !tbaa !0
  %arrayidx117.2.i = getelementptr inbounds i8, i8* %12, i64 84
  %112 = bitcast i8* %arrayidx117.2.i to i32*
  %113 = load i32, i32* %112, align 4, !tbaa !0
  %add118.2.i = add nsw i32 %113, %111
  %arrayidx122.2.i = getelementptr inbounds i8, i8* %11, i64 84
  %114 = bitcast i8* %arrayidx122.2.i to i32*
  store i32 %add118.2.i, i32* %114, align 4, !tbaa !0
  %arrayidx113.2.i.1 = getelementptr inbounds i8, i8* %11, i64 60
  %115 = bitcast i8* %arrayidx113.2.i.1 to i32*
  %116 = load i32, i32* %115, align 4, !tbaa !0
  %arrayidx117.2.i.1 = getelementptr inbounds i8, i8* %12, i64 88
  %117 = bitcast i8* %arrayidx117.2.i.1 to i32*
  %118 = load i32, i32* %117, align 4, !tbaa !0
  %add118.2.i.1 = add nsw i32 %118, %116
  %arrayidx122.2.i.1 = getelementptr inbounds i8, i8* %11, i64 88
  %119 = bitcast i8* %arrayidx122.2.i.1 to i32*
  store i32 %add118.2.i.1, i32* %119, align 4, !tbaa !0
  %arrayidx113.2.i.2 = getelementptr inbounds i8, i8* %11, i64 64
  %120 = bitcast i8* %arrayidx113.2.i.2 to i32*
  %121 = load i32, i32* %120, align 4, !tbaa !0
  %arrayidx117.2.i.2 = getelementptr inbounds i8, i8* %12, i64 92
  %122 = bitcast i8* %arrayidx117.2.i.2 to i32*
  %123 = load i32, i32* %122, align 4, !tbaa !0
  %add118.2.i.2 = add nsw i32 %123, %121
  %arrayidx122.2.i.2 = getelementptr inbounds i8, i8* %11, i64 92
  %124 = bitcast i8* %arrayidx122.2.i.2 to i32*
  store i32 %add118.2.i.2, i32* %124, align 4, !tbaa !0
  %arrayidx113.3.i = getelementptr inbounds i8, i8* %11, i64 84
  %125 = bitcast i8* %arrayidx113.3.i to i32*
  %126 = load i32, i32* %125, align 4, !tbaa !0
  %arrayidx117.3.i = getelementptr inbounds i8, i8* %12, i64 112
  %127 = bitcast i8* %arrayidx117.3.i to i32*
  %128 = load i32, i32* %127, align 4, !tbaa !0
  %add118.3.i = add nsw i32 %128, %126
  %arrayidx122.3.i = getelementptr inbounds i8, i8* %11, i64 112
  %129 = bitcast i8* %arrayidx122.3.i to i32*
  store i32 %add118.3.i, i32* %129, align 4, !tbaa !0
  %arrayidx113.3.i.1 = getelementptr inbounds i8, i8* %11, i64 88
  %130 = bitcast i8* %arrayidx113.3.i.1 to i32*
  %131 = load i32, i32* %130, align 4, !tbaa !0
  %arrayidx117.3.i.1 = getelementptr inbounds i8, i8* %12, i64 116
  %132 = bitcast i8* %arrayidx117.3.i.1 to i32*
  %133 = load i32, i32* %132, align 4, !tbaa !0
  %add118.3.i.1 = add nsw i32 %133, %131
  %arrayidx122.3.i.1 = getelementptr inbounds i8, i8* %11, i64 116
  %134 = bitcast i8* %arrayidx122.3.i.1 to i32*
  store i32 %add118.3.i.1, i32* %134, align 4, !tbaa !0
  %135 = load i32, i32* %13, align 4, !tbaa !0
  %arrayidx117.4.i = getelementptr inbounds i8, i8* %12, i64 140
  %136 = bitcast i8* %arrayidx117.4.i to i32*
  %137 = load i32, i32* %136, align 4, !tbaa !0
  %add118.4.i = add nsw i32 %137, %135
  %arrayidx122.4.i = getelementptr inbounds i8, i8* %11, i64 140
  %138 = bitcast i8* %arrayidx122.4.i to i32*
  store i32 %add118.4.i, i32* %138, align 4, !tbaa !0
  %inc130.i = add nuw nsw i32 %t.014.i, 1
  %exitcond50.i = icmp eq i32 %inc130.i, 10000
  br i1 %exitcond50.i, label %for.cond.1.preheader.i.61.preheader.exitStub, label %for.cond.8.preheader.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
