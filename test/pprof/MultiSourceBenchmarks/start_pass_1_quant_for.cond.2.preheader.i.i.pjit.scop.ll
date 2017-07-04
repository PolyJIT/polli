
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/mediabench/jpeg/jpeg-6a/jquant1.c.start_pass_1_quant_for.cond.2.preheader.i.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @start_pass_1_quant_for.cond.2.preheader.i.i.pjit.scop(i64 %mul.i.i, [16 x i32]*, [16 x [16 x i8]]* nonnull %base_dither_matrix)  {
newFuncRoot:
  br label %for.cond.2.preheader.i.i

if.end.14.i.loopexit.exitStub:                    ; preds = %for.inc.23.i.i
  ret void

for.cond.2.preheader.i.i:                         ; preds = %for.inc.23.i.i, %newFuncRoot
  %indvars.iv43.i.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next44.i.i, %for.inc.23.i.i ]
  br label %for.body.5.i.i

for.body.5.i.i:                                   ; preds = %cond.end.i.i, %for.cond.2.preheader.i.i
  %indvars.iv.i.i = phi i64 [ 0, %for.cond.2.preheader.i.i ], [ %indvars.iv.next.i.i, %cond.end.i.i ]
  %arrayidx7.i.i = getelementptr inbounds [16 x [16 x i8]], [16 x [16 x i8]]* %base_dither_matrix, i64 0, i64 %indvars.iv43.i.i, i64 %indvars.iv.i.i
  %1 = load i8, i8* %arrayidx7.i.i, align 1, !tbaa !0
  %conv8.i.i = zext i8 %1 to i32
  %mul9.i.i = shl nuw nsw i32 %conv8.i.i, 1
  %sub10.i.i = sub nsw i32 255, %mul9.i.i
  %conv11.i.i = sext i32 %sub10.i.i to i64
  %mul12.i.i = mul nsw i64 %conv11.i.i, 255
  %cmp13.i.i = icmp slt i32 %sub10.i.i, 0
  br i1 %cmp13.i.i, label %cond.true.i.i, label %cond.false.i.i

cond.true.i.i:                                    ; preds = %for.body.5.i.i
  %sub15.i.i = sub nsw i64 0, %mul12.i.i
  %div.i.i = sdiv i64 %sub15.i.i, %mul.i.i
  %sub16.i.i = sub nsw i64 0, %div.i.i
  br label %cond.end.i.i

cond.end.i.i:                                     ; preds = %cond.false.i.i, %cond.true.i.i
  %cond.i.i = phi i64 [ %sub16.i.i, %cond.true.i.i ], [ %div17.i.i, %cond.false.i.i ]
  %conv18.i.i = trunc i64 %cond.i.i to i32
  %arrayidx22.i.i = getelementptr inbounds [16 x i32], [16 x i32]* %0, i64 %indvars.iv43.i.i, i64 %indvars.iv.i.i
  store i32 %conv18.i.i, i32* %arrayidx22.i.i, align 4, !tbaa !3
  %indvars.iv.next.i.i = add nuw nsw i64 %indvars.iv.i.i, 1
  %exitcond.i.i = icmp eq i64 %indvars.iv.next.i.i, 16
  br i1 %exitcond.i.i, label %for.inc.23.i.i, label %for.body.5.i.i

for.inc.23.i.i:                                   ; preds = %cond.end.i.i
  %indvars.iv.next44.i.i = add nuw nsw i64 %indvars.iv43.i.i, 1
  %exitcond45.i.i = icmp eq i64 %indvars.iv.next44.i.i, 16
  br i1 %exitcond45.i.i, label %if.end.14.i.loopexit.exitStub, label %for.cond.2.preheader.i.i

cond.false.i.i:                                   ; preds = %for.body.5.i.i
  %div17.i.i = sdiv i64 %mul12.i.i, %mul.i.i
  br label %cond.end.i.i
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !1, i64 0}
