
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polli-process-unprofitable -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/464.h264ref/src/block.c.dct_chroma_sp_for.cond.309.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.macroblock = type { i32, i32, i32, i32, i32, [8 x i32], %struct.macroblock*, %struct.macroblock*, i32, [2 x [4 x [4 x [2 x i32]]]], [16 x i32], [16 x i32], i32, i64, [4 x i32], [4 x i32], i64, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, double, i32, i32, i32, i32, i32, i32, i32, i32, i32 }
%struct.ImageParameters = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, float, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32**, i32**, i32, i32***, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [9 x [16 x [16 x i16]]], [5 x [16 x [16 x i16]]], [9 x [8 x [8 x i16]]], [2 x [4 x [16 x [16 x i16]]]], [16 x [16 x i16]], [16 x [16 x i32]], i32****, i32***, %struct.Picture*, %struct.Slice*, %struct.macroblock*, [1200 x %struct.syntaxelement], i32*, i32*, i32, i32, i32, i32, [4 x [4 x i32]], i32, i32, i32, i32, i32, double, i32, i32, i32, i32, i16******, i16******, i16******, i16******, [15 x i16], i32, i32, i32, i32, i32, i32, i32, i32, [6 x [15 x i32]], i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [1 x i32], i32, i32, [2 x i32], i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, %struct.DecRefPicMarking_s*, i32, i32, i32, i32, i32, double, i32, i32, i32, i32, i32, i32, i32, double*, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [2 x i32], i32, i32, i32 }
%struct.Picture = type { i32, i32, [100 x %struct.Slice*], i32, float, float, float }
%struct.Slice = type { i32, i32, i32, i32, i32, i32, %struct.datapartition*, %struct.MotionInfoContexts*, %struct.TextureInfoContexts*, %struct.RMPNIbuffer_s*, i32, i32*, i32*, i32*, i32, i32*, i32*, i32*, i32 (i32)*, [3 x [2 x i32]] }
%struct.datapartition = type { %struct.Bitstream*, %struct.EncodingEnvironment, i32 (%struct.syntaxelement*, %struct.datapartition*)* }
%struct.Bitstream = type { i32, i32, i8, i32, i32, i8, i8, i32, i32, i8*, i32 }
%struct.EncodingEnvironment = type { i32, i32, i32, i32, i32, i8*, i32*, i32, i32, i32, i32, i32, i8*, i32*, i32, i32, i32, i32, i32, i32 }
%struct.syntaxelement = type { i32, i32, i32, i32, i32, i32, i32, i32, void (i32, i32, i32*, i32*)*, void (%struct.syntaxelement*, %struct.EncodingEnvironment*)* }
%struct.MotionInfoContexts = type { [3 x [11 x %struct.BiContextType]], [2 x [9 x %struct.BiContextType]], [2 x [10 x %struct.BiContextType]], [2 x [6 x %struct.BiContextType]], [4 x %struct.BiContextType], [4 x %struct.BiContextType], [3 x %struct.BiContextType] }
%struct.BiContextType = type { i16, i8, i64 }
%struct.TextureInfoContexts = type { [2 x %struct.BiContextType], [4 x %struct.BiContextType], [3 x [4 x %struct.BiContextType]], [10 x [4 x %struct.BiContextType]], [10 x [15 x %struct.BiContextType]], [10 x [15 x %struct.BiContextType]], [10 x [5 x %struct.BiContextType]], [10 x [5 x %struct.BiContextType]], [10 x [15 x %struct.BiContextType]], [10 x [15 x %struct.BiContextType]] }
%struct.RMPNIbuffer_s = type { i32, i32, %struct.RMPNIbuffer_s* }
%struct.DecRefPicMarking_s = type { i32, i32, i32, i32, i32, %struct.DecRefPicMarking_s* }

; Function Attrs: nounwind
define weak void @dct_chroma_sp_for.cond.309.preheader.pjit.scop([8 x [8 x i32]]* %predicted_chroma_block, [4 x i32]* %m5, i32* %arrayidx352, i32* %arrayidx367, i32* %arrayidx369, i32* %arrayidx427, i32* %arrayidx443, i32* %arrayidx445, [4 x i32]* %m1, [4 x i32]* %mp1, i32 %rem91, i32 %div94, i32 %div791984, i32 %rem, i32 %div67, i32 %div551982, i32 %uv, %struct.macroblock*, i64 %idxprom, i32** %arrayidx485.out, i32** %arrayidx501.out, i32** %arrayidx517.out, i32** %arrayidx533.out, i32* %.out, i32* %mul595.out, i32* %add597.out, i32* %.out1, i32* %mul617.out, i32* %add619.out, i32** %arrayidx649.out, i64* %conv741.out, i64** %cbp_blk.out, i32** %arrayidx758.out, i32* %.out2, i32* %.out3, %struct.ImageParameters** nonnull %img, [6 x [4 x [4 x i32]]]* nonnull %quant_coef, [6 x [4 x [4 x i32]]]* nonnull %dequant_coef)  {
newFuncRoot:
  br label %for.cond.309.preheader

for.body.585.exitStub:                            ; preds = %for.end.469
  store i32* %arrayidx485, i32** %arrayidx485.out
  store i32* %arrayidx501, i32** %arrayidx501.out
  store i32* %arrayidx517, i32** %arrayidx517.out
  store i32* %arrayidx533, i32** %arrayidx533.out
  store i32 %69, i32* %.out
  store i32 %mul595, i32* %mul595.out
  store i32 %add597, i32* %add597.out
  store i32 %70, i32* %.out1
  store i32 %mul617, i32* %mul617.out
  store i32 %add619, i32* %add619.out
  store i32* %arrayidx649, i32** %arrayidx649.out
  store i64 %conv741, i64* %conv741.out
  store i64* %cbp_blk, i64** %cbp_blk.out
  store i32* %arrayidx758, i32** %arrayidx758.out
  store i32 %71, i32* %.out2
  store i32 %72, i32* %.out3
  ret void

for.cond.309.preheader:                           ; preds = %for.inc.467, %newFuncRoot
  %indvars.iv2125 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next2126, %for.inc.467 ]
  %1 = or i64 %indvars.iv2125, 2
  %2 = or i64 %indvars.iv2125, 1
  %3 = or i64 %indvars.iv2125, 3
  br label %for.cond.313.preheader

for.cond.313.preheader:                           ; preds = %for.inc.464, %for.cond.309.preheader
  %indvars.iv2120 = phi i64 [ 0, %for.cond.309.preheader ], [ %indvars.iv.next2121, %for.inc.464 ]
  %4 = or i64 %indvars.iv2120, 2
  %5 = or i64 %indvars.iv2120, 1
  %6 = or i64 %indvars.iv2120, 3
  br label %for.body.316

for.body.316:                                     ; preds = %for.body.316, %for.cond.313.preheader
  %indvars.iv2106 = phi i64 [ 0, %for.cond.313.preheader ], [ %indvars.iv.next2107, %for.body.316 ]
  %7 = add nuw nsw i64 %indvars.iv2106, %indvars.iv2125
  %arrayidx327 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %indvars.iv2120, i64 %7
  %8 = load i32, i32* %arrayidx327, align 4, !tbaa !0
  %9 = or i64 %indvars.iv2120, 3
  %arrayidx332 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %9, i64 %7
  %10 = load i32, i32* %arrayidx332, align 4, !tbaa !0
  %add333 = add nsw i32 %10, %8
  %arrayidx335 = getelementptr inbounds [4 x i32], [4 x i32]* %m5, i64 0, i64 0
  store i32 %add333, i32* %arrayidx335, align 16, !tbaa !0
  %11 = load i32, i32* %arrayidx327, align 4, !tbaa !0
  %sub346 = sub nsw i32 %11, %10
  %arrayidx348 = getelementptr inbounds [4 x i32], [4 x i32]* %m5, i64 0, i64 3
  store i32 %sub346, i32* %arrayidx348, align 4, !tbaa !0
  %12 = or i64 %indvars.iv2120, 1
  %arrayidx327.1 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %12, i64 %7
  %13 = load i32, i32* %arrayidx327.1, align 4, !tbaa !0
  %14 = or i64 %indvars.iv2120, 2
  %arrayidx332.1 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %14, i64 %7
  %15 = load i32, i32* %arrayidx332.1, align 4, !tbaa !0
  %add333.1 = add nsw i32 %15, %13
  %arrayidx335.1 = getelementptr inbounds [4 x i32], [4 x i32]* %m5, i64 0, i64 1
  store i32 %add333.1, i32* %arrayidx335.1, align 4, !tbaa !0
  %16 = load i32, i32* %arrayidx327.1, align 4, !tbaa !0
  %sub346.1 = sub nsw i32 %16, %15
  %arrayidx348.1 = getelementptr inbounds [4 x i32], [4 x i32]* %m5, i64 0, i64 2
  store i32 %sub346.1, i32* %arrayidx348.1, align 8, !tbaa !0
  %17 = load i32, i32* %arrayidx352, align 16, !tbaa !0
  %add354 = add nsw i32 %17, %add333.1
  %arrayidx358 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %indvars.iv2120, i64 %7
  store i32 %add354, i32* %arrayidx358, align 4, !tbaa !0
  %sub361 = sub nsw i32 %17, %add333.1
  %arrayidx366 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %4, i64 %7
  store i32 %sub361, i32* %arrayidx366, align 4, !tbaa !0
  %18 = load i32, i32* %arrayidx367, align 4, !tbaa !0
  %mul368 = shl i32 %18, 1
  %19 = load i32, i32* %arrayidx369, align 8, !tbaa !0
  %add370 = add nsw i32 %mul368, %19
  %arrayidx375 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %5, i64 %7
  store i32 %add370, i32* %arrayidx375, align 4, !tbaa !0
  %mul378 = shl nsw i32 %19, 1
  %sub379 = sub nsw i32 %18, %mul378
  %arrayidx384 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %6, i64 %7
  store i32 %sub379, i32* %arrayidx384, align 4, !tbaa !0
  %indvars.iv.next2107 = add nuw nsw i64 %indvars.iv2106, 1
  %exitcond2109 = icmp eq i64 %indvars.iv.next2107, 4
  br i1 %exitcond2109, label %for.body.391.preheader, label %for.body.316

for.body.391.preheader:                           ; preds = %for.body.316
  br label %for.body.391

for.body.391:                                     ; preds = %for.body.391, %for.body.391.preheader
  %indvars.iv2116 = phi i64 [ %indvars.iv.next2117, %for.body.391 ], [ 0, %for.body.391.preheader ]
  %20 = add nuw nsw i64 %indvars.iv2116, %indvars.iv2120
  %arrayidx402 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %20, i64 %indvars.iv2125
  %21 = load i32, i32* %arrayidx402, align 16, !tbaa !0
  %22 = or i64 %indvars.iv2125, 3
  %arrayidx407 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %20, i64 %22
  %23 = load i32, i32* %arrayidx407, align 4, !tbaa !0
  %add408 = add nsw i32 %23, %21
  %arrayidx410 = getelementptr inbounds [4 x i32], [4 x i32]* %m5, i64 0, i64 0
  store i32 %add408, i32* %arrayidx410, align 16, !tbaa !0
  %24 = load i32, i32* %arrayidx402, align 16, !tbaa !0
  %sub421 = sub nsw i32 %24, %23
  %arrayidx423 = getelementptr inbounds [4 x i32], [4 x i32]* %m5, i64 0, i64 3
  store i32 %sub421, i32* %arrayidx423, align 4, !tbaa !0
  %25 = or i64 %indvars.iv2125, 1
  %arrayidx402.1 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %20, i64 %25
  %26 = load i32, i32* %arrayidx402.1, align 4, !tbaa !0
  %27 = or i64 %indvars.iv2125, 2
  %arrayidx407.1 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %20, i64 %27
  %28 = load i32, i32* %arrayidx407.1, align 8, !tbaa !0
  %add408.1 = add nsw i32 %28, %26
  %arrayidx410.1 = getelementptr inbounds [4 x i32], [4 x i32]* %m5, i64 0, i64 1
  store i32 %add408.1, i32* %arrayidx410.1, align 4, !tbaa !0
  %29 = load i32, i32* %arrayidx402.1, align 4, !tbaa !0
  %sub421.1 = sub nsw i32 %29, %28
  %arrayidx423.1 = getelementptr inbounds [4 x i32], [4 x i32]* %m5, i64 0, i64 2
  store i32 %sub421.1, i32* %arrayidx423.1, align 8, !tbaa !0
  %30 = load i32, i32* %arrayidx427, align 16, !tbaa !0
  %add429 = add nsw i32 %30, %add408.1
  %arrayidx434 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %20, i64 %indvars.iv2125
  store i32 %add429, i32* %arrayidx434, align 16, !tbaa !0
  %sub437 = sub nsw i32 %30, %add408.1
  %arrayidx442 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %20, i64 %1
  store i32 %sub437, i32* %arrayidx442, align 8, !tbaa !0
  %31 = load i32, i32* %arrayidx443, align 4, !tbaa !0
  %mul444 = shl i32 %31, 1
  %32 = load i32, i32* %arrayidx445, align 8, !tbaa !0
  %add446 = add nsw i32 %mul444, %32
  %arrayidx451 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %20, i64 %2
  store i32 %add446, i32* %arrayidx451, align 4, !tbaa !0
  %mul454 = shl nsw i32 %32, 1
  %sub455 = sub nsw i32 %31, %mul454
  %arrayidx460 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 %20, i64 %3
  store i32 %sub455, i32* %arrayidx460, align 4, !tbaa !0
  %indvars.iv.next2117 = add nuw nsw i64 %indvars.iv2116, 1
  %exitcond2119 = icmp eq i64 %indvars.iv.next2117, 4
  br i1 %exitcond2119, label %for.inc.464, label %for.body.391

for.inc.464:                                      ; preds = %for.body.391
  %indvars.iv.next2121 = add nuw nsw i64 %indvars.iv2120, 4
  %cmp310 = icmp slt i64 %indvars.iv.next2121, 5
  br i1 %cmp310, label %for.cond.313.preheader, label %for.inc.467

for.inc.467:                                      ; preds = %for.inc.464
  %indvars.iv.next2126 = add nuw nsw i64 %indvars.iv2125, 4
  %cmp306 = icmp slt i64 %indvars.iv.next2126, 5
  br i1 %cmp306, label %for.cond.309.preheader, label %for.end.469

for.end.469:                                      ; preds = %for.inc.467
  %33 = load %struct.ImageParameters*, %struct.ImageParameters** %img, align 8, !tbaa !4
  %arrayidx472 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %33, i64 0, i32 46, i64 0, i64 0
  %34 = load i32, i32* %arrayidx472, align 8, !tbaa !0
  %arrayidx475 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %33, i64 0, i32 46, i64 4, i64 0
  %35 = load i32, i32* %arrayidx475, align 8, !tbaa !0
  %add476 = add nsw i32 %35, %34
  %arrayidx479 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %33, i64 0, i32 46, i64 0, i64 4
  %36 = load i32, i32* %arrayidx479, align 8, !tbaa !0
  %add480 = add nsw i32 %add476, %36
  %arrayidx483 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %33, i64 0, i32 46, i64 4, i64 4
  %37 = load i32, i32* %arrayidx483, align 8, !tbaa !0
  %add484 = add nsw i32 %add480, %37
  %arrayidx485 = getelementptr inbounds [4 x i32], [4 x i32]* %m1, i64 0, i64 0
  store i32 %add484, i32* %arrayidx485, align 16, !tbaa !0
  %38 = load %struct.ImageParameters*, %struct.ImageParameters** %img, align 8, !tbaa !4
  %arrayidx488 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %38, i64 0, i32 46, i64 0, i64 0
  %39 = load i32, i32* %arrayidx488, align 8, !tbaa !0
  %arrayidx491 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %38, i64 0, i32 46, i64 4, i64 0
  %40 = load i32, i32* %arrayidx491, align 8, !tbaa !0
  %sub492 = sub i32 %39, %40
  %arrayidx495 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %38, i64 0, i32 46, i64 0, i64 4
  %41 = load i32, i32* %arrayidx495, align 8, !tbaa !0
  %add496 = add nsw i32 %sub492, %41
  %arrayidx499 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %38, i64 0, i32 46, i64 4, i64 4
  %42 = load i32, i32* %arrayidx499, align 8, !tbaa !0
  %sub500 = sub i32 %add496, %42
  %arrayidx501 = getelementptr inbounds [4 x i32], [4 x i32]* %m1, i64 0, i64 1
  store i32 %sub500, i32* %arrayidx501, align 4, !tbaa !0
  %43 = load %struct.ImageParameters*, %struct.ImageParameters** %img, align 8, !tbaa !4
  %arrayidx504 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %43, i64 0, i32 46, i64 0, i64 0
  %44 = load i32, i32* %arrayidx504, align 8, !tbaa !0
  %arrayidx507 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %43, i64 0, i32 46, i64 4, i64 0
  %45 = load i32, i32* %arrayidx507, align 8, !tbaa !0
  %add508 = add nsw i32 %45, %44
  %arrayidx511 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %43, i64 0, i32 46, i64 0, i64 4
  %46 = load i32, i32* %arrayidx511, align 8, !tbaa !0
  %sub512 = sub i32 %add508, %46
  %arrayidx515 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %43, i64 0, i32 46, i64 4, i64 4
  %47 = load i32, i32* %arrayidx515, align 8, !tbaa !0
  %sub516 = sub i32 %sub512, %47
  %arrayidx517 = getelementptr inbounds [4 x i32], [4 x i32]* %m1, i64 0, i64 2
  store i32 %sub516, i32* %arrayidx517, align 8, !tbaa !0
  %48 = load %struct.ImageParameters*, %struct.ImageParameters** %img, align 8, !tbaa !4
  %arrayidx520 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %48, i64 0, i32 46, i64 0, i64 0
  %49 = load i32, i32* %arrayidx520, align 8, !tbaa !0
  %arrayidx523 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %48, i64 0, i32 46, i64 4, i64 0
  %50 = load i32, i32* %arrayidx523, align 8, !tbaa !0
  %sub524 = sub i32 %49, %50
  %arrayidx527 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %48, i64 0, i32 46, i64 0, i64 4
  %51 = load i32, i32* %arrayidx527, align 8, !tbaa !0
  %sub528 = sub i32 %sub524, %51
  %arrayidx531 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %48, i64 0, i32 46, i64 4, i64 4
  %52 = load i32, i32* %arrayidx531, align 8, !tbaa !0
  %add532 = add nsw i32 %sub528, %52
  %arrayidx533 = getelementptr inbounds [4 x i32], [4 x i32]* %m1, i64 0, i64 3
  store i32 %add532, i32* %arrayidx533, align 4, !tbaa !0
  %arrayidx535 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 0, i64 0
  %53 = load i32, i32* %arrayidx535, align 16, !tbaa !0
  %arrayidx537 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 4, i64 0
  %54 = load i32, i32* %arrayidx537, align 16, !tbaa !0
  %add538 = add nsw i32 %54, %53
  %arrayidx540 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 0, i64 4
  %55 = load i32, i32* %arrayidx540, align 16, !tbaa !0
  %add541 = add nsw i32 %add538, %55
  %arrayidx543 = getelementptr inbounds [8 x [8 x i32]], [8 x [8 x i32]]* %predicted_chroma_block, i64 0, i64 4, i64 4
  %56 = load i32, i32* %arrayidx543, align 16, !tbaa !0
  %add544 = add nsw i32 %add541, %56
  %arrayidx545 = getelementptr inbounds [4 x i32], [4 x i32]* %mp1, i64 0, i64 0
  store i32 %add544, i32* %arrayidx545, align 16, !tbaa !0
  %57 = load i32, i32* %arrayidx535, align 16, !tbaa !0
  %58 = load i32, i32* %arrayidx537, align 16, !tbaa !0
  %sub550 = sub i32 %57, %58
  %59 = load i32, i32* %arrayidx540, align 16, !tbaa !0
  %add553 = add nsw i32 %sub550, %59
  %60 = load i32, i32* %arrayidx543, align 16, !tbaa !0
  %sub556 = sub i32 %add553, %60
  %arrayidx557 = getelementptr inbounds [4 x i32], [4 x i32]* %mp1, i64 0, i64 1
  store i32 %sub556, i32* %arrayidx557, align 4, !tbaa !0
  %61 = load i32, i32* %arrayidx535, align 16, !tbaa !0
  %62 = load i32, i32* %arrayidx537, align 16, !tbaa !0
  %add562 = add nsw i32 %62, %61
  %63 = load i32, i32* %arrayidx540, align 16, !tbaa !0
  %sub565 = sub i32 %add562, %63
  %64 = load i32, i32* %arrayidx543, align 16, !tbaa !0
  %sub568 = sub i32 %sub565, %64
  %arrayidx569 = getelementptr inbounds [4 x i32], [4 x i32]* %mp1, i64 0, i64 2
  store i32 %sub568, i32* %arrayidx569, align 8, !tbaa !0
  %65 = load i32, i32* %arrayidx535, align 16, !tbaa !0
  %66 = load i32, i32* %arrayidx537, align 16, !tbaa !0
  %sub574 = sub i32 %65, %66
  %67 = load i32, i32* %arrayidx540, align 16, !tbaa !0
  %sub577 = sub i32 %sub574, %67
  %68 = load i32, i32* %arrayidx543, align 16, !tbaa !0
  %add580 = add nsw i32 %sub577, %68
  %arrayidx581 = getelementptr inbounds [4 x i32], [4 x i32]* %mp1, i64 0, i64 3
  store i32 %add580, i32* %arrayidx581, align 4, !tbaa !0
  %idxprom590 = sext i32 %rem91 to i64
  %arrayidx593 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %quant_coef, i64 0, i64 %idxprom590, i64 0, i64 0
  %69 = load i32, i32* %arrayidx593, align 16, !tbaa !0
  %mul595 = shl nsw i32 %div94, 1
  %add597 = add nsw i32 %div791984, 16
  %idxprom612 = sext i32 %rem to i64
  %arrayidx615 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %quant_coef, i64 0, i64 %idxprom612, i64 0, i64 0
  %70 = load i32, i32* %arrayidx615, align 16, !tbaa !0
  %mul617 = shl nsw i32 %div67, 1
  %add619 = add nsw i32 %div551982, 16
  %arrayidx649 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %dequant_coef, i64 0, i64 %idxprom612, i64 0, i64 0
  %shl739 = shl i32 %uv, 2
  %shl740 = shl i32 983040, %shl739
  %conv741 = sext i32 %shl740 to i64
  %cbp_blk = getelementptr inbounds %struct.macroblock, %struct.macroblock* %0, i64 %idxprom, i32 13
  %arrayidx758 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %dequant_coef, i64 0, i64 %idxprom612, i64 0, i64 0
  %71 = load i32, i32* %arrayidx593, align 16, !tbaa !0
  %arrayidx781 = getelementptr inbounds [6 x [4 x [4 x i32]]], [6 x [4 x [4 x i32]]]* %dequant_coef, i64 0, i64 %idxprom590, i64 0, i64 0
  %72 = load i32, i32* %arrayidx781, align 16, !tbaa !0
  br label %for.body.585.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="3" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"any pointer", !2, i64 0}
