; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'common/cabac.c.x264_cabac_init_for.cond.8.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @x264_cabac_init_for.cond.8.preheader.pjit.scop(i64, [1024 x [2 x i8]]* nonnull %x264_cabac_context_init_I, [4 x [52 x [1024 x i8]]]* nonnull %x264_cabac_contexts, [3 x [1024 x [2 x i8]]]* nonnull %x264_cabac_context_init_PB)  {
newFuncRoot:
  br label %for.cond.8.preheader

for.cond.cleanup.6.3.exitStub:                    ; preds = %for.cond.cleanup.10.3
  ret void

for.cond.8.preheader:                             ; preds = %for.cond.cleanup.10, %newFuncRoot
  %indvars.iv66 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next67, %for.cond.cleanup.10 ]
  br label %for.body.11

for.body.11:                                      ; preds = %for.body.11, %for.cond.8.preheader
  %indvars.iv = phi i64 [ 0, %for.cond.8.preheader ], [ %indvars.iv.next, %for.body.11 ]
  %arrayidx14 = getelementptr inbounds [1024 x [2 x i8]], [1024 x [2 x i8]]* %x264_cabac_context_init_I, i64 0, i64 %indvars.iv, i64 0
  %1 = load i8, i8* %arrayidx14, align 2, !tbaa !0
  %conv = sext i8 %1 to i32
  %2 = trunc i64 %indvars.iv66 to i32
  %mul = mul nsw i32 %conv, %2
  %shr = ashr i32 %mul, 4
  %arrayidx17 = getelementptr inbounds [1024 x [2 x i8]], [1024 x [2 x i8]]* %x264_cabac_context_init_I, i64 0, i64 %indvars.iv, i64 1
  %3 = load i8, i8* %arrayidx17, align 1, !tbaa !0
  %conv18 = sext i8 %3 to i32
  %add = add nsw i32 %shr, %conv18
  %cmp.i = icmp slt i32 %add, 1
  %cmp1.i = icmp sgt i32 %add, 126
  %cond.i = select i1 %cmp1.i, i32 126, i32 %add
  %cond5.i = select i1 %cmp.i, i32 1, i32 %cond.i
  %sub19 = sub nsw i32 127, %cond5.i
  %cmp20 = icmp slt i32 %cond5.i, %sub19
  %cond26 = select i1 %cmp20, i32 %cond5.i, i32 %sub19
  %shl = shl nsw i32 %cond26, 1
  %shr27.62 = lshr i32 %cond5.i, 6
  %or = or i32 %shl, %shr27.62
  %conv28 = trunc i32 %or to i8
  %arrayidx34 = getelementptr inbounds [4 x [52 x [1024 x i8]]], [4 x [52 x [1024 x i8]]]* %x264_cabac_contexts, i64 0, i64 0, i64 %indvars.iv66, i64 %indvars.iv
  store i8 %conv28, i8* %arrayidx34, align 1, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %cmp9 = icmp slt i64 %indvars.iv.next, %0
  br i1 %cmp9, label %for.body.11, label %for.cond.cleanup.10

for.cond.cleanup.10:                              ; preds = %for.body.11
  %indvars.iv.next67 = add nuw nsw i64 %indvars.iv66, 1
  %exitcond = icmp eq i64 %indvars.iv.next67, 52
  br i1 %exitcond, label %for.cond.8.preheader.1.preheader, label %for.cond.8.preheader

for.cond.8.preheader.1.preheader:                 ; preds = %for.cond.cleanup.10
  br label %for.cond.8.preheader.1

for.cond.8.preheader.1:                           ; preds = %for.cond.cleanup.10.1, %for.cond.8.preheader.1.preheader
  %indvars.iv66.1 = phi i64 [ %indvars.iv.next67.1, %for.cond.cleanup.10.1 ], [ 0, %for.cond.8.preheader.1.preheader ]
  br label %for.body.11.1

for.body.11.1:                                    ; preds = %for.body.11.1, %for.cond.8.preheader.1
  %indvars.iv.1 = phi i64 [ 0, %for.cond.8.preheader.1 ], [ %indvars.iv.next.1, %for.body.11.1 ]
  %arrayidx14.1 = getelementptr inbounds [3 x [1024 x [2 x i8]]], [3 x [1024 x [2 x i8]]]* %x264_cabac_context_init_PB, i64 0, i64 0, i64 %indvars.iv.1, i64 0
  %4 = load i8, i8* %arrayidx14.1, align 2, !tbaa !0
  %conv.1 = sext i8 %4 to i32
  %5 = trunc i64 %indvars.iv66.1 to i32
  %mul.1 = mul nsw i32 %conv.1, %5
  %shr.1 = ashr i32 %mul.1, 4
  %arrayidx17.1 = getelementptr inbounds [3 x [1024 x [2 x i8]]], [3 x [1024 x [2 x i8]]]* %x264_cabac_context_init_PB, i64 0, i64 0, i64 %indvars.iv.1, i64 1
  %6 = load i8, i8* %arrayidx17.1, align 1, !tbaa !0
  %conv18.1 = sext i8 %6 to i32
  %add.1 = add nsw i32 %shr.1, %conv18.1
  %cmp.i.1 = icmp slt i32 %add.1, 1
  %cmp1.i.1 = icmp sgt i32 %add.1, 126
  %cond.i.1 = select i1 %cmp1.i.1, i32 126, i32 %add.1
  %cond5.i.1 = select i1 %cmp.i.1, i32 1, i32 %cond.i.1
  %sub19.1 = sub nsw i32 127, %cond5.i.1
  %cmp20.1 = icmp slt i32 %cond5.i.1, %sub19.1
  %cond26.1 = select i1 %cmp20.1, i32 %cond5.i.1, i32 %sub19.1
  %shl.1 = shl nsw i32 %cond26.1, 1
  %shr27.62.1 = lshr i32 %cond5.i.1, 6
  %or.1 = or i32 %shl.1, %shr27.62.1
  %conv28.1 = trunc i32 %or.1 to i8
  %arrayidx34.1 = getelementptr inbounds [4 x [52 x [1024 x i8]]], [4 x [52 x [1024 x i8]]]* %x264_cabac_contexts, i64 0, i64 1, i64 %indvars.iv66.1, i64 %indvars.iv.1
  store i8 %conv28.1, i8* %arrayidx34.1, align 1, !tbaa !0
  %indvars.iv.next.1 = add nuw nsw i64 %indvars.iv.1, 1
  %cmp9.1 = icmp slt i64 %indvars.iv.next.1, %0
  br i1 %cmp9.1, label %for.body.11.1, label %for.cond.cleanup.10.1

for.cond.cleanup.10.1:                            ; preds = %for.body.11.1
  %indvars.iv.next67.1 = add nuw nsw i64 %indvars.iv66.1, 1
  %exitcond.1 = icmp eq i64 %indvars.iv.next67.1, 52
  br i1 %exitcond.1, label %for.cond.8.preheader.2.preheader, label %for.cond.8.preheader.1

for.cond.8.preheader.2.preheader:                 ; preds = %for.cond.cleanup.10.1
  br label %for.cond.8.preheader.2

for.cond.8.preheader.2:                           ; preds = %for.cond.cleanup.10.2, %for.cond.8.preheader.2.preheader
  %indvars.iv66.2 = phi i64 [ %indvars.iv.next67.2, %for.cond.cleanup.10.2 ], [ 0, %for.cond.8.preheader.2.preheader ]
  br label %for.body.11.2

for.body.11.2:                                    ; preds = %for.body.11.2, %for.cond.8.preheader.2
  %indvars.iv.2 = phi i64 [ 0, %for.cond.8.preheader.2 ], [ %indvars.iv.next.2, %for.body.11.2 ]
  %arrayidx14.2 = getelementptr inbounds [3 x [1024 x [2 x i8]]], [3 x [1024 x [2 x i8]]]* %x264_cabac_context_init_PB, i64 0, i64 1, i64 %indvars.iv.2, i64 0
  %7 = load i8, i8* %arrayidx14.2, align 2, !tbaa !0
  %conv.2 = sext i8 %7 to i32
  %8 = trunc i64 %indvars.iv66.2 to i32
  %mul.2 = mul nsw i32 %conv.2, %8
  %shr.2 = ashr i32 %mul.2, 4
  %arrayidx17.2 = getelementptr inbounds [3 x [1024 x [2 x i8]]], [3 x [1024 x [2 x i8]]]* %x264_cabac_context_init_PB, i64 0, i64 1, i64 %indvars.iv.2, i64 1
  %9 = load i8, i8* %arrayidx17.2, align 1, !tbaa !0
  %conv18.2 = sext i8 %9 to i32
  %add.2 = add nsw i32 %shr.2, %conv18.2
  %cmp.i.2 = icmp slt i32 %add.2, 1
  %cmp1.i.2 = icmp sgt i32 %add.2, 126
  %cond.i.2 = select i1 %cmp1.i.2, i32 126, i32 %add.2
  %cond5.i.2 = select i1 %cmp.i.2, i32 1, i32 %cond.i.2
  %sub19.2 = sub nsw i32 127, %cond5.i.2
  %cmp20.2 = icmp slt i32 %cond5.i.2, %sub19.2
  %cond26.2 = select i1 %cmp20.2, i32 %cond5.i.2, i32 %sub19.2
  %shl.2 = shl nsw i32 %cond26.2, 1
  %shr27.62.2 = lshr i32 %cond5.i.2, 6
  %or.2 = or i32 %shl.2, %shr27.62.2
  %conv28.2 = trunc i32 %or.2 to i8
  %arrayidx34.2 = getelementptr inbounds [4 x [52 x [1024 x i8]]], [4 x [52 x [1024 x i8]]]* %x264_cabac_contexts, i64 0, i64 2, i64 %indvars.iv66.2, i64 %indvars.iv.2
  store i8 %conv28.2, i8* %arrayidx34.2, align 1, !tbaa !0
  %indvars.iv.next.2 = add nuw nsw i64 %indvars.iv.2, 1
  %cmp9.2 = icmp slt i64 %indvars.iv.next.2, %0
  br i1 %cmp9.2, label %for.body.11.2, label %for.cond.cleanup.10.2

for.cond.cleanup.10.2:                            ; preds = %for.body.11.2
  %indvars.iv.next67.2 = add nuw nsw i64 %indvars.iv66.2, 1
  %exitcond.2 = icmp eq i64 %indvars.iv.next67.2, 52
  br i1 %exitcond.2, label %for.cond.8.preheader.3.preheader, label %for.cond.8.preheader.2

for.cond.8.preheader.3.preheader:                 ; preds = %for.cond.cleanup.10.2
  br label %for.cond.8.preheader.3

for.cond.8.preheader.3:                           ; preds = %for.cond.cleanup.10.3, %for.cond.8.preheader.3.preheader
  %indvars.iv66.3 = phi i64 [ %indvars.iv.next67.3, %for.cond.cleanup.10.3 ], [ 0, %for.cond.8.preheader.3.preheader ]
  br label %for.body.11.3

for.body.11.3:                                    ; preds = %for.body.11.3, %for.cond.8.preheader.3
  %indvars.iv.3 = phi i64 [ 0, %for.cond.8.preheader.3 ], [ %indvars.iv.next.3, %for.body.11.3 ]
  %arrayidx14.3 = getelementptr inbounds [3 x [1024 x [2 x i8]]], [3 x [1024 x [2 x i8]]]* %x264_cabac_context_init_PB, i64 0, i64 2, i64 %indvars.iv.3, i64 0
  %10 = load i8, i8* %arrayidx14.3, align 2, !tbaa !0
  %conv.3 = sext i8 %10 to i32
  %11 = trunc i64 %indvars.iv66.3 to i32
  %mul.3 = mul nsw i32 %conv.3, %11
  %shr.3 = ashr i32 %mul.3, 4
  %arrayidx17.3 = getelementptr inbounds [3 x [1024 x [2 x i8]]], [3 x [1024 x [2 x i8]]]* %x264_cabac_context_init_PB, i64 0, i64 2, i64 %indvars.iv.3, i64 1
  %12 = load i8, i8* %arrayidx17.3, align 1, !tbaa !0
  %conv18.3 = sext i8 %12 to i32
  %add.3 = add nsw i32 %shr.3, %conv18.3
  %cmp.i.3 = icmp slt i32 %add.3, 1
  %cmp1.i.3 = icmp sgt i32 %add.3, 126
  %cond.i.3 = select i1 %cmp1.i.3, i32 126, i32 %add.3
  %cond5.i.3 = select i1 %cmp.i.3, i32 1, i32 %cond.i.3
  %sub19.3 = sub nsw i32 127, %cond5.i.3
  %cmp20.3 = icmp slt i32 %cond5.i.3, %sub19.3
  %cond26.3 = select i1 %cmp20.3, i32 %cond5.i.3, i32 %sub19.3
  %shl.3 = shl nsw i32 %cond26.3, 1
  %shr27.62.3 = lshr i32 %cond5.i.3, 6
  %or.3 = or i32 %shl.3, %shr27.62.3
  %conv28.3 = trunc i32 %or.3 to i8
  %arrayidx34.3 = getelementptr inbounds [4 x [52 x [1024 x i8]]], [4 x [52 x [1024 x i8]]]* %x264_cabac_contexts, i64 0, i64 3, i64 %indvars.iv66.3, i64 %indvars.iv.3
  store i8 %conv28.3, i8* %arrayidx34.3, align 1, !tbaa !0
  %indvars.iv.next.3 = add nuw nsw i64 %indvars.iv.3, 1
  %cmp9.3 = icmp slt i64 %indvars.iv.next.3, %0
  br i1 %cmp9.3, label %for.body.11.3, label %for.cond.cleanup.10.3

for.cond.cleanup.10.3:                            ; preds = %for.body.11.3
  %indvars.iv.next67.3 = add nuw nsw i64 %indvars.iv66.3, 1
  %exitcond.3 = icmp eq i64 %indvars.iv.next67.3, 52
  br i1 %exitcond.3, label %for.cond.cleanup.6.3.exitStub, label %for.cond.8.preheader.3
}

attributes #0 = { nounwind "polyjit-global-count"="3" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
