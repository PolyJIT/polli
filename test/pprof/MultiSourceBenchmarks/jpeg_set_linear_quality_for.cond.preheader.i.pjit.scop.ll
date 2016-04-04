
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli-process-unprofitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/mediabench/jpeg/jpeg-6a/jcparam.c.jpeg_set_linear_quality_for.cond.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.JQUANT_TBL = type { [64 x i16], i32 }

; Function Attrs: nounwind
define weak void @jpeg_set_linear_quality_for.cond.preheader.i.pjit.scop(i32 %scale_factor, i32 %force_baseline, %struct.JQUANT_TBL** %arrayidx.i, i64* %conv12.i.out, i1* %tobool.i.out, [64 x i32]* nonnull %jpeg_set_linear_quality.std_luminance_quant_tbl)  {
newFuncRoot:
  br label %for.cond.preheader.i

jpeg_add_quant_table.exit.exitStub:               ; preds = %jpeg_add_quant_table.exit.loopexit56, %jpeg_add_quant_table.exit.loopexit
  store i64 %conv12.i, i64* %conv12.i.out
  store i1 %tobool.i, i1* %tobool.i.out
  ret void

for.cond.preheader.i:                             ; preds = %newFuncRoot
  %conv12.i = sext i32 %scale_factor to i64
  %tobool.i = icmp eq i32 %force_baseline, 0
  %0 = load %struct.JQUANT_TBL*, %struct.JQUANT_TBL** %arrayidx.i, align 8, !tbaa !0
  br i1 %tobool.i, label %for.body.i.preheader, label %for.body.us.i.preheader

for.body.i.preheader:                             ; preds = %for.cond.preheader.i
  br label %for.body.i

for.body.i:                                       ; preds = %for.body.i, %for.body.i.preheader
  %indvars.iv.i = phi i64 [ %indvars.iv.next.i, %for.body.i ], [ 0, %for.body.i.preheader ]
  %arrayidx11.i = getelementptr inbounds [64 x i32], [64 x i32]* %jpeg_set_linear_quality.std_luminance_quant_tbl, i64 0, i64 %indvars.iv.i
  %1 = load i32, i32* %arrayidx11.i, align 4, !tbaa !4
  %conv.i = zext i32 %1 to i64
  %mul.i = mul nsw i64 %conv.i, %conv12.i
  %add.i = add nsw i64 %mul.i, 50
  %div.i = sdiv i64 %add.i, 100
  %cmp13.i = icmp slt i64 %div.i, 1
  %.div.i = select i1 %cmp13.i, i64 1, i64 %div.i
  %cmp17.i = icmp sgt i64 %.div.i, 32767
  %..div.i = select i1 %cmp17.i, i64 32767, i64 %.div.i
  %2 = trunc i64 %..div.i to i16
  %arrayidx27.i = getelementptr inbounds %struct.JQUANT_TBL, %struct.JQUANT_TBL* %0, i64 0, i32 0, i64 %indvars.iv.i
  store i16 %2, i16* %arrayidx27.i, align 2, !tbaa !6
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %exitcond.i = icmp eq i64 %indvars.iv.next.i, 64
  br i1 %exitcond.i, label %jpeg_add_quant_table.exit.loopexit, label %for.body.i

jpeg_add_quant_table.exit.loopexit:               ; preds = %for.body.i
  br label %jpeg_add_quant_table.exit.exitStub

for.body.us.i.preheader:                          ; preds = %for.cond.preheader.i
  br label %for.body.us.i

for.body.us.i:                                    ; preds = %for.body.us.i, %for.body.us.i.preheader
  %indvars.iv49.i = phi i64 [ %indvars.iv.next50.i, %for.body.us.i ], [ 0, %for.body.us.i.preheader ]
  %arrayidx11.us.i = getelementptr inbounds [64 x i32], [64 x i32]* %jpeg_set_linear_quality.std_luminance_quant_tbl, i64 0, i64 %indvars.iv49.i
  %3 = load i32, i32* %arrayidx11.us.i, align 4, !tbaa !4
  %conv.us.i = zext i32 %3 to i64
  %mul.us.i = mul nsw i64 %conv.us.i, %conv12.i
  %add.us.i = add nsw i64 %mul.us.i, 50
  %div.us.i = sdiv i64 %add.us.i, 100
  %cmp13.us.i = icmp slt i64 %div.us.i, 1
  %.div.us.i = select i1 %cmp13.us.i, i64 1, i64 %div.us.i
  %4 = icmp slt i64 %.div.us.i, 255
  %5 = select i1 %4, i64 %.div.us.i, i64 255
  %6 = trunc i64 %5 to i16
  %arrayidx27.us.i = getelementptr inbounds %struct.JQUANT_TBL, %struct.JQUANT_TBL* %0, i64 0, i32 0, i64 %indvars.iv49.i
  store i16 %6, i16* %arrayidx27.us.i, align 2, !tbaa !6
  %indvars.iv.next50.i = add nuw nsw i64 %indvars.iv49.i, 1
  %exitcond51.i = icmp eq i64 %indvars.iv.next50.i, 64
  br i1 %exitcond51.i, label %jpeg_add_quant_table.exit.loopexit56, label %for.body.us.i

jpeg_add_quant_table.exit.loopexit56:             ; preds = %for.body.us.i
  br label %jpeg_add_quant_table.exit.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"any pointer", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !2, i64 0}
!6 = !{!7, !7, i64 0}
!7 = !{!"short", !2, i64 0}
