
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/JM/lencod/img_luma.c.getVerSubImageSixTap_for.cond.199.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.ImageParameters = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, float, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i8**, i8**, i32, i32***, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [9 x [16 x [16 x i16]]], [5 x [16 x [16 x i16]]], [9 x [8 x [8 x i16]]], [2 x [4 x [16 x [16 x i16]]]], [16 x [16 x i16]], [16 x [16 x i32]], i32****, i32***, i32***, i32***, i32****, i32****, %struct.Picture*, %struct.Slice*, %struct.macroblock*, i32*, i32*, i32, i32, i32, i32, [4 x [4 x i32]], i32, i32, i32, i32, i32, double, i32, i32, i32, i32, i16******, i16******, i16******, i16******, [15 x i16], i32, i32, i32, i32, i32, i32, i32, i32, [6 x [32 x i32]], i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [1 x i32], i32, i32, [2 x i32], i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, %struct.DecRefPicMarking_s*, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, double**, double***, i32***, double**, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [3 x [2 x i32]], [2 x i32], i32, i32, i16, i32, i32, i32, i32, i32 }
%struct.Picture = type { i32, i32, [100 x %struct.Slice*], i32, float, float, float }
%struct.Slice = type { i32, i32, i32, i32, i32, i32, %struct.datapartition*, %struct.MotionInfoContexts*, %struct.TextureInfoContexts*, i32, i32*, i32*, i32*, i32, i32*, i32*, i32*, i32 (i32)*, [3 x [2 x i32]] }
%struct.datapartition = type { %struct.Bitstream*, %struct.EncodingEnvironment, %struct.EncodingEnvironment }
%struct.Bitstream = type { i32, i32, i8, i32, i32, i8, i8, i32, i32, i8*, i32 }
%struct.EncodingEnvironment = type { i32, i32, i32, i32, i32, i8*, i32*, i32, i32 }
%struct.MotionInfoContexts = type { [3 x [11 x %struct.BiContextType]], [2 x [9 x %struct.BiContextType]], [2 x [10 x %struct.BiContextType]], [2 x [6 x %struct.BiContextType]], [4 x %struct.BiContextType], [4 x %struct.BiContextType], [3 x %struct.BiContextType] }
%struct.BiContextType = type { i16, i8, i64 }
%struct.TextureInfoContexts = type { [2 x %struct.BiContextType], [4 x %struct.BiContextType], [3 x [4 x %struct.BiContextType]], [10 x [4 x %struct.BiContextType]], [10 x [15 x %struct.BiContextType]], [10 x [15 x %struct.BiContextType]], [10 x [5 x %struct.BiContextType]], [10 x [5 x %struct.BiContextType]], [10 x [15 x %struct.BiContextType]], [10 x [15 x %struct.BiContextType]] }
%struct.macroblock = type { i32, i32, i32, [2 x i32], i32, [8 x i32], %struct.macroblock*, %struct.macroblock*, i32, [2 x [4 x [4 x [2 x i32]]]], [16 x i8], [16 x i8], i32, i64, [4 x i32], [4 x i32], i64, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, double, i32, i32, i32, i32, i32, i32, i32, i32, i32 }
%struct.DecRefPicMarking_s = type { i32, i32, i32, i32, i32, %struct.DecRefPicMarking_s* }

; Function Attrs: nounwind
define weak void @getVerSubImageSixTap_for.cond.199.preheader.pjit.scop(i1 %cmp18.653, i32 %add1, i16**, i32*** nonnull %imgY_sub_tmp, %struct.ImageParameters** nonnull %img)  {
newFuncRoot:
  br label %for.cond.199.preheader

for.cond.260.preheader.exitStub:                  ; preds = %for.cond.260.preheader.loopexit, %for.cond.199.preheader
  ret void

for.cond.199.preheader:                           ; preds = %newFuncRoot
  %1 = load i32**, i32*** %imgY_sub_tmp, align 8, !tbaa !0
  %2 = load %struct.ImageParameters*, %struct.ImageParameters** %img, align 8, !tbaa !0
  %max_imgpel_value248 = getelementptr inbounds %struct.ImageParameters, %struct.ImageParameters* %2, i64 0, i32 156
  br i1 %cmp18.653, label %for.body.202.us.preheader, label %for.cond.260.preheader.exitStub

for.body.202.us.preheader:                        ; preds = %for.cond.199.preheader
  %3 = sext i32 %add1 to i64
  %4 = load i16*, i16** %0, align 8, !tbaa !0
  %5 = load i32*, i32** %1, align 8, !tbaa !0
  %arrayidx222.us = getelementptr inbounds i32*, i32** %1, i64 1
  %6 = load i32*, i32** %arrayidx222.us, align 8, !tbaa !0
  %arrayidx232.us = getelementptr inbounds i32*, i32** %1, i64 2
  %7 = load i32*, i32** %arrayidx232.us, align 8, !tbaa !0
  %arrayidx243.us = getelementptr inbounds i32*, i32** %1, i64 3
  %8 = load i32*, i32** %arrayidx243.us, align 8, !tbaa !0
  %9 = load i32, i32* %max_imgpel_value248, align 8, !tbaa !4
  br label %for.body.215.us

for.body.215.us:                                  ; preds = %for.body.215.us, %for.body.202.us.preheader
  %indvars.iv718 = phi i64 [ 0, %for.body.202.us.preheader ], [ %indvars.iv.next719, %for.body.215.us ]
  %arrayidx219.us = getelementptr inbounds i32, i32* %5, i64 %indvars.iv718
  %10 = load i32, i32* %arrayidx219.us, align 4, !tbaa !10
  %arrayidx223.us = getelementptr inbounds i32, i32* %6, i64 %indvars.iv718
  %11 = load i32, i32* %arrayidx223.us, align 4, !tbaa !10
  %add224.us = add nsw i32 %11, %10
  %mul225.us = mul nsw i32 %add224.us, 20
  %arrayidx233.us = getelementptr inbounds i32, i32* %7, i64 %indvars.iv718
  %12 = load i32, i32* %arrayidx233.us, align 4, !tbaa !10
  %add234.us = add nsw i32 %12, %10
  %mul235.us = mul nsw i32 %add234.us, -5
  %arrayidx240.us = getelementptr inbounds i32, i32* %5, i64 %indvars.iv718
  %13 = load i32, i32* %arrayidx240.us, align 4, !tbaa !10
  %arrayidx244.us = getelementptr inbounds i32, i32* %8, i64 %indvars.iv718
  %14 = load i32, i32* %arrayidx244.us, align 4, !tbaa !10
  %add245.us = add i32 %mul225.us, 512
  %add236.us = add i32 %add245.us, %13
  %add247.us = add i32 %add236.us, %mul235.us
  %add.i.613.us = add i32 %add247.us, %14
  %shr.i.614.us = ashr i32 %add.i.613.us, 10
  %cmp.i.i.609.us = icmp sgt i32 %shr.i.614.us, 0
  %cond.i.i.610.us = select i1 %cmp.i.i.609.us, i32 %shr.i.614.us, i32 0
  %cmp.i.1.i.611.us = icmp slt i32 %cond.i.i.610.us, %9
  %cond.i.2.i.612.us = select i1 %cmp.i.1.i.611.us, i32 %cond.i.i.610.us, i32 %9
  %conv251.us = trunc i32 %cond.i.2.i.612.us to i16
  %arrayidx253.us = getelementptr inbounds i16, i16* %4, i64 %indvars.iv718
  store i16 %conv251.us, i16* %arrayidx253.us, align 2, !tbaa !11
  %indvars.iv.next719 = add nuw nsw i64 %indvars.iv718, 1
  %cmp213.us = icmp slt i64 %indvars.iv.next719, %3
  br i1 %cmp213.us, label %for.body.215.us, label %for.cond.212.for.cond.199.loopexit_crit_edge.us

for.cond.212.for.cond.199.loopexit_crit_edge.us:  ; preds = %for.body.215.us
  %arrayidx204.us.1 = getelementptr inbounds i16*, i16** %0, i64 1
  %15 = load i16*, i16** %arrayidx204.us.1, align 8, !tbaa !0
  %arrayidx218.us.1 = getelementptr inbounds i32*, i32** %1, i64 1
  %16 = load i32*, i32** %arrayidx218.us.1, align 8, !tbaa !0
  %arrayidx222.us.1 = getelementptr inbounds i32*, i32** %1, i64 2
  %17 = load i32*, i32** %arrayidx222.us.1, align 8, !tbaa !0
  %18 = load i32*, i32** %1, align 8, !tbaa !0
  %arrayidx232.us.1 = getelementptr inbounds i32*, i32** %1, i64 3
  %19 = load i32*, i32** %arrayidx232.us.1, align 8, !tbaa !0
  %arrayidx243.us.1 = getelementptr inbounds i32*, i32** %1, i64 4
  %20 = load i32*, i32** %arrayidx243.us.1, align 8, !tbaa !0
  %21 = load i32, i32* %max_imgpel_value248, align 8, !tbaa !4
  br label %for.body.215.us.1

for.body.215.us.1:                                ; preds = %for.body.215.us.1, %for.cond.212.for.cond.199.loopexit_crit_edge.us
  %indvars.iv718.1 = phi i64 [ 0, %for.cond.212.for.cond.199.loopexit_crit_edge.us ], [ %indvars.iv.next719.1, %for.body.215.us.1 ]
  %arrayidx219.us.1 = getelementptr inbounds i32, i32* %16, i64 %indvars.iv718.1
  %22 = load i32, i32* %arrayidx219.us.1, align 4, !tbaa !10
  %arrayidx223.us.1 = getelementptr inbounds i32, i32* %17, i64 %indvars.iv718.1
  %23 = load i32, i32* %arrayidx223.us.1, align 4, !tbaa !10
  %add224.us.1 = add nsw i32 %23, %22
  %mul225.us.1 = mul nsw i32 %add224.us.1, 20
  %arrayidx229.us.1 = getelementptr inbounds i32, i32* %18, i64 %indvars.iv718.1
  %24 = load i32, i32* %arrayidx229.us.1, align 4, !tbaa !10
  %arrayidx233.us.1 = getelementptr inbounds i32, i32* %19, i64 %indvars.iv718.1
  %25 = load i32, i32* %arrayidx233.us.1, align 4, !tbaa !10
  %add234.us.1 = add nsw i32 %25, %24
  %mul235.us.1 = mul nsw i32 %add234.us.1, -5
  %arrayidx244.us.1 = getelementptr inbounds i32, i32* %20, i64 %indvars.iv718.1
  %26 = load i32, i32* %arrayidx244.us.1, align 4, !tbaa !10
  %add245.us.1 = add i32 %24, 512
  %add236.us.1 = add i32 %add245.us.1, %mul225.us.1
  %add247.us.1 = add i32 %add236.us.1, %26
  %add.i.613.us.1 = add i32 %add247.us.1, %mul235.us.1
  %shr.i.614.us.1 = ashr i32 %add.i.613.us.1, 10
  %cmp.i.i.609.us.1 = icmp sgt i32 %shr.i.614.us.1, 0
  %cond.i.i.610.us.1 = select i1 %cmp.i.i.609.us.1, i32 %shr.i.614.us.1, i32 0
  %cmp.i.1.i.611.us.1 = icmp slt i32 %cond.i.i.610.us.1, %21
  %cond.i.2.i.612.us.1 = select i1 %cmp.i.1.i.611.us.1, i32 %cond.i.i.610.us.1, i32 %21
  %conv251.us.1 = trunc i32 %cond.i.2.i.612.us.1 to i16
  %arrayidx253.us.1 = getelementptr inbounds i16, i16* %15, i64 %indvars.iv718.1
  store i16 %conv251.us.1, i16* %arrayidx253.us.1, align 2, !tbaa !11
  %indvars.iv.next719.1 = add nuw nsw i64 %indvars.iv718.1, 1
  %cmp213.us.1 = icmp slt i64 %indvars.iv.next719.1, %3
  br i1 %cmp213.us.1, label %for.body.215.us.1, label %for.cond.260.preheader.loopexit

for.cond.260.preheader.loopexit:                  ; preds = %for.body.215.us.1
  br label %for.cond.260.preheader.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="2" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"any pointer", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !6, i64 15520}
!5 = !{!"", !6, i64 0, !6, i64 4, !6, i64 8, !6, i64 12, !6, i64 16, !6, i64 20, !6, i64 24, !6, i64 28, !6, i64 32, !6, i64 36, !6, i64 40, !6, i64 44, !7, i64 48, !6, i64 52, !6, i64 56, !6, i64 60, !6, i64 64, !6, i64 68, !6, i64 72, !6, i64 76, !6, i64 80, !6, i64 84, !6, i64 88, !6, i64 92, !6, i64 96, !6, i64 100, !6, i64 104, !6, i64 108, !6, i64 112, !6, i64 116, !6, i64 120, !1, i64 128, !1, i64 136, !6, i64 144, !1, i64 152, !6, i64 160, !6, i64 164, !6, i64 168, !6, i64 172, !6, i64 176, !6, i64 180, !6, i64 184, !6, i64 188, !6, i64 192, !6, i64 196, !6, i64 200, !6, i64 204, !2, i64 208, !2, i64 4816, !2, i64 7376, !2, i64 8528, !2, i64 12624, !2, i64 13136, !1, i64 14160, !1, i64 14168, !1, i64 14176, !1, i64 14184, !1, i64 14192, !1, i64 14200, !1, i64 14208, !1, i64 14216, !1, i64 14224, !1, i64 14232, !1, i64 14240, !6, i64 14248, !6, i64 14252, !6, i64 14256, !6, i64 14260, !2, i64 14264, !6, i64 14328, !6, i64 14332, !6, i64 14336, !6, i64 14340, !6, i64 14344, !8, i64 14352, !6, i64 14360, !6, i64 14364, !6, i64 14368, !6, i64 14372, !1, i64 14376, !1, i64 14384, !1, i64 14392, !1, i64 14400, !2, i64 14408, !6, i64 14440, !6, i64 14444, !6, i64 14448, !6, i64 14452, !6, i64 14456, !6, i64 14460, !6, i64 14464, !6, i64 14468, !2, i64 14472, !6, i64 15240, !6, i64 15244, !6, i64 15248, !6, i64 15252, !6, i64 15256, !6, i64 15260, !6, i64 15264, !6, i64 15268, !6, i64 15272, !2, i64 15276, !6, i64 15280, !6, i64 15284, !6, i64 15288, !2, i64 15292, !6, i64 15296, !6, i64 15300, !2, i64 15304, !6, i64 15312, !6, i64 15316, !6, i64 15320, !6, i64 15324, !6, i64 15328, !6, i64 15332, !6, i64 15336, !6, i64 15340, !6, i64 15344, !6, i64 15348, !6, i64 15352, !2, i64 15356, !6, i64 15360, !6, i64 15364, !6, i64 15368, !6, i64 15372, !1, i64 15376, !6, i64 15384, !6, i64 15388, !6, i64 15392, !6, i64 15396, !6, i64 15400, !6, i64 15404, !6, i64 15408, !6, i64 15412, !6, i64 15416, !6, i64 15420, !6, i64 15424, !6, i64 15428, !6, i64 15432, !6, i64 15436, !6, i64 15440, !6, i64 15444, !6, i64 15448, !6, i64 15452, !6, i64 15456, !6, i64 15460, !6, i64 15464, !6, i64 15468, !6, i64 15472, !1, i64 15480, !1, i64 15488, !1, i64 15496, !1, i64 15504, !6, i64 15512, !6, i64 15516, !6, i64 15520, !6, i64 15524, !6, i64 15528, !6, i64 15532, !6, i64 15536, !6, i64 15540, !6, i64 15544, !6, i64 15548, !2, i64 15552, !2, i64 15576, !6, i64 15584, !6, i64 15588, !9, i64 15592, !6, i64 15596, !6, i64 15600, !6, i64 15604, !6, i64 15608, !6, i64 15612}
!6 = !{!"int", !2, i64 0}
!7 = !{!"float", !2, i64 0}
!8 = !{!"double", !2, i64 0}
!9 = !{!"short", !2, i64 0}
!10 = !{!6, !6, i64 0}
!11 = !{!9, !9, i64 0}
