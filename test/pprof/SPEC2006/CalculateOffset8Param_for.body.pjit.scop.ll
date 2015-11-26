
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-process-unprofitable -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/464.h264ref/src/q_offsets.c.CalculateOffset8Param_for.body.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @CalculateOffset8Param_for.body.pjit.scop(i32* %type60, [3 x [64 x i16]]* nonnull %OffsetList8x8input, [13 x [8 x [8 x i32]]]* nonnull %LevelOffset8x8Luma_Intra, [13 x [8 x [8 x i32]]]* nonnull %LevelOffset8x8Luma_Inter)  {
newFuncRoot:
  br label %for.body

if.end.105.loopexit181.exitStub:                  ; preds = %for.inc.40
  ret void

for.body:                                         ; preds = %for.inc.40, %newFuncRoot
  %indvars.iv177 = phi i64 [ %indvars.iv.next178, %for.inc.40 ], [ 0, %newFuncRoot ]
  %0 = add nuw nsw i64 %indvars.iv177, 6
  br label %for.cond.4.preheader

for.cond.4.preheader:                             ; preds = %for.inc.37, %for.body
  %indvars.iv174 = phi i64 [ 0, %for.body ], [ %indvars.iv.next175, %for.inc.37 ]
  br label %for.body.6

for.body.6:                                       ; preds = %if.end, %for.cond.4.preheader
  %indvars.iv169 = phi i64 [ 0, %for.cond.4.preheader ], [ %indvars.iv.next170, %if.end ]
  %1 = shl i64 %indvars.iv169, 3
  %2 = add nuw nsw i64 %1, %indvars.iv174
  %3 = load i32, i32* %type60, align 8, !tbaa !0
  %cmp8 = icmp eq i32 %3, 2
  br i1 %cmp8, label %if.then.9, label %if.else

if.then.9:                                        ; preds = %for.body.6
  %arrayidx = getelementptr inbounds [3 x [64 x i16]], [3 x [64 x i16]]* %OffsetList8x8input, i64 0, i64 0, i64 %2
  %4 = load i16, i16* %arrayidx, align 2, !tbaa !8
  %conv = sext i16 %4 to i32
  %5 = trunc i64 %0 to i32
  %shl10 = shl i32 %conv, %5
  %arrayidx16 = getelementptr inbounds [13 x [8 x [8 x i32]]], [13 x [8 x [8 x i32]]]* %LevelOffset8x8Luma_Intra, i64 0, i64 %indvars.iv177, i64 %indvars.iv174, i64 %indvars.iv169
  store i32 %shl10, i32* %arrayidx16, align 4, !tbaa !10
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then.9
  %arrayidx28 = getelementptr inbounds [3 x [64 x i16]], [3 x [64 x i16]]* %OffsetList8x8input, i64 0, i64 2, i64 %2
  %6 = load i16, i16* %arrayidx28, align 2, !tbaa !8
  %conv29 = sext i16 %6 to i32
  %7 = trunc i64 %0 to i32
  %shl30 = shl i32 %conv29, %7
  %arrayidx36 = getelementptr inbounds [13 x [8 x [8 x i32]]], [13 x [8 x [8 x i32]]]* %LevelOffset8x8Luma_Inter, i64 0, i64 %indvars.iv177, i64 %indvars.iv174, i64 %indvars.iv169
  store i32 %shl30, i32* %arrayidx36, align 4, !tbaa !10
  %indvars.iv.next170 = add nuw nsw i64 %indvars.iv169, 1
  %exitcond173 = icmp eq i64 %indvars.iv.next170, 8
  br i1 %exitcond173, label %for.inc.37, label %for.body.6

for.inc.37:                                       ; preds = %if.end
  %indvars.iv.next175 = add nuw nsw i64 %indvars.iv174, 1
  %exitcond176 = icmp eq i64 %indvars.iv.next175, 8
  br i1 %exitcond176, label %for.inc.40, label %for.cond.4.preheader

for.inc.40:                                       ; preds = %for.inc.37
  %indvars.iv.next178 = add nuw nsw i64 %indvars.iv177, 1
  %exitcond180 = icmp eq i64 %indvars.iv.next178, 13
  br i1 %exitcond180, label %if.end.105.loopexit181.exitStub, label %for.body

if.else:                                          ; preds = %for.body.6
  %arrayidx18 = getelementptr inbounds [3 x [64 x i16]], [3 x [64 x i16]]* %OffsetList8x8input, i64 0, i64 1, i64 %2
  %8 = load i16, i16* %arrayidx18, align 2, !tbaa !8
  %conv19 = sext i16 %8 to i32
  %9 = trunc i64 %0 to i32
  %shl20 = shl i32 %conv19, %9
  %arrayidx26 = getelementptr inbounds [13 x [8 x [8 x i32]]], [13 x [8 x [8 x i32]]]* %LevelOffset8x8Luma_Intra, i64 0, i64 %indvars.iv177, i64 %indvars.iv174, i64 %indvars.iv169
  store i32 %shl20, i32* %arrayidx26, align 4, !tbaa !10
  br label %if.end
}

attributes #0 = { nounwind "polyjit-global-count"="3" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 24}
!1 = !{!"", !2, i64 0, !2, i64 4, !2, i64 8, !2, i64 12, !2, i64 16, !2, i64 20, !2, i64 24, !2, i64 28, !2, i64 32, !2, i64 36, !2, i64 40, !2, i64 44, !5, i64 48, !2, i64 52, !2, i64 56, !2, i64 60, !2, i64 64, !2, i64 68, !2, i64 72, !2, i64 76, !2, i64 80, !2, i64 84, !2, i64 88, !2, i64 92, !2, i64 96, !6, i64 104, !6, i64 112, !2, i64 120, !6, i64 128, !2, i64 136, !2, i64 140, !2, i64 144, !2, i64 148, !2, i64 152, !2, i64 156, !2, i64 160, !2, i64 164, !2, i64 168, !2, i64 172, !2, i64 176, !2, i64 180, !3, i64 184, !3, i64 4792, !3, i64 7352, !3, i64 8504, !3, i64 12600, !3, i64 13112, !6, i64 14136, !6, i64 14144, !6, i64 14152, !6, i64 14160, !6, i64 14168, !3, i64 14176, !6, i64 71776, !6, i64 71784, !2, i64 71792, !2, i64 71796, !2, i64 71800, !2, i64 71804, !3, i64 71808, !2, i64 71872, !2, i64 71876, !2, i64 71880, !2, i64 71884, !2, i64 71888, !7, i64 71896, !2, i64 71904, !2, i64 71908, !2, i64 71912, !2, i64 71916, !6, i64 71920, !6, i64 71928, !6, i64 71936, !6, i64 71944, !3, i64 71952, !2, i64 71984, !2, i64 71988, !2, i64 71992, !2, i64 71996, !2, i64 72000, !2, i64 72004, !2, i64 72008, !2, i64 72012, !3, i64 72016, !2, i64 72376, !2, i64 72380, !2, i64 72384, !2, i64 72388, !2, i64 72392, !2, i64 72396, !2, i64 72400, !2, i64 72404, !2, i64 72408, !2, i64 72412, !2, i64 72416, !2, i64 72420, !3, i64 72424, !2, i64 72428, !2, i64 72432, !3, i64 72436, !2, i64 72444, !2, i64 72448, !2, i64 72452, !2, i64 72456, !2, i64 72460, !2, i64 72464, !2, i64 72468, !2, i64 72472, !2, i64 72476, !2, i64 72480, !2, i64 72484, !2, i64 72488, !2, i64 72492, !2, i64 72496, !2, i64 72500, !2, i64 72504, !2, i64 72508, !6, i64 72512, !2, i64 72520, !2, i64 72524, !2, i64 72528, !2, i64 72532, !2, i64 72536, !7, i64 72544, !2, i64 72552, !2, i64 72556, !2, i64 72560, !2, i64 72564, !2, i64 72568, !2, i64 72572, !2, i64 72576, !6, i64 72584, !2, i64 72592, !2, i64 72596, !2, i64 72600, !2, i64 72604, !2, i64 72608, !2, i64 72612, !2, i64 72616, !2, i64 72620, !2, i64 72624, !2, i64 72628, !2, i64 72632, !2, i64 72636, !2, i64 72640, !2, i64 72644, !2, i64 72648, !2, i64 72652, !2, i64 72656, !2, i64 72660, !2, i64 72664, !2, i64 72668, !2, i64 72672, !2, i64 72676, !2, i64 72680, !2, i64 72684, !2, i64 72688, !2, i64 72692, !2, i64 72696, !2, i64 72700, !2, i64 72704, !2, i64 72708, !2, i64 72712, !3, i64 72716, !2, i64 72724, !2, i64 72728, !2, i64 72732}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!"float", !3, i64 0}
!6 = !{!"any pointer", !3, i64 0}
!7 = !{!"double", !3, i64 0}
!8 = !{!9, !9, i64 0}
!9 = !{!"short", !3, i64 0}
!10 = !{!2, !2, i64 0}
