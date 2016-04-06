
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'filters/video/depth.c.get_frame_for.body.6.lr.ph.us.i.359.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @get_frame_for.body.6.lr.ph.us.i.359.i.pjit.scop(i8* %add.ptr170.i, i16* %add.ptr180.i, i16*, i32 %conv16.i, i64 %idx.ext.i.324.i, i64 %idx.ext39.i.325.i, i32 %conv6.i)  {
newFuncRoot:
  br label %for.body.6.lr.ph.us.i.359.i

if.end.205.i.loopexit.exitStub:                   ; preds = %for.cond.2.for.cond.cleanup.5_crit_edge.us.i.363.i
  ret void

for.body.6.lr.ph.us.i.359.i:                      ; preds = %for.cond.2.for.cond.cleanup.5_crit_edge.us.i.363.i, %newFuncRoot
  %y.073.us.i.356.i = phi i32 [ %inc38.us.i.360.i, %for.cond.2.for.cond.cleanup.5_crit_edge.us.i.363.i ], [ 0, %newFuncRoot ]
  %dst.addr.072.us.i.357.i = phi i8* [ %add.ptr40.us.i.362.i, %for.cond.2.for.cond.cleanup.5_crit_edge.us.i.363.i ], [ %add.ptr170.i, %newFuncRoot ]
  %src.addr.071.us.i.358.i = phi i16* [ %add.ptr.us.i.361.i, %for.cond.2.for.cond.cleanup.5_crit_edge.us.i.363.i ], [ %add.ptr180.i, %newFuncRoot ]
  br label %for.body.6.us.i.355.i

for.body.6.us.i.355.i:                            ; preds = %for.body.6.us.i.355.i, %for.body.6.lr.ph.us.i.359.i
  %indvars.iv.i.328.i = phi i64 [ 0, %for.body.6.lr.ph.us.i.359.i ], [ %indvars.iv.next.i.333.i, %for.body.6.us.i.355.i ]
  %err.068.us.i.329.i = phi i32 [ 0, %for.body.6.lr.ph.us.i.359.i ], [ %sub.us.i.353.i, %for.body.6.us.i.355.i ]
  %mul7.us.i.330.i = shl nsw i32 %err.068.us.i.329.i, 1
  %arrayidx.us.i.331.i = getelementptr inbounds i16, i16* %0, i64 %indvars.iv.i.328.i
  %1 = load i16, i16* %arrayidx.us.i.331.i, align 2, !tbaa !0
  %conv8.us.i.332.i = sext i16 %1 to i32
  %indvars.iv.next.i.333.i = add nuw nsw i64 %indvars.iv.i.328.i, 1
  %arrayidx12.us.i.334.i = getelementptr inbounds i16, i16* %0, i64 %indvars.iv.next.i.333.i
  %2 = load i16, i16* %arrayidx12.us.i.334.i, align 2, !tbaa !0
  %conv13.us.i.335.i = sext i16 %2 to i32
  %3 = shl nsw i64 %indvars.iv.i.328.i, 1
  %arrayidx17.us.i.336.i = getelementptr inbounds i16, i16* %src.addr.071.us.i.358.i, i64 %3
  %4 = load i16, i16* %arrayidx17.us.i.336.i, align 2, !tbaa !0
  %conv18.us.i.337.i = zext i16 %4 to i32
  %shl.us.i.338.i = shl nuw nsw i32 %conv18.us.i.337.i, 2
  %add9.us.i.339.i = add nsw i32 %mul7.us.i.330.i, 512
  %add14.us.i.340.i = add nsw i32 %add9.us.i.339.i, %conv8.us.i.332.i
  %add19.us.i.341.i = add nsw i32 %add14.us.i.340.i, %conv13.us.i.335.i
  %add20.us.i.342.i = add i32 %add19.us.i.341.i, %shl.us.i.338.i
  %shr.us.i.343.i = ashr i32 %add20.us.i.342.i, 10
  %cmp.i.us.i.344.i = icmp slt i32 %shr.us.i.343.i, 0
  %cmp1.i.us.i.345.i = icmp sgt i32 %shr.us.i.343.i, 255
  %cond.i.us.i.346.i = select i1 %cmp1.i.us.i.345.i, i32 255, i32 %shr.us.i.343.i
  %cond5.i.us.i.347.i = select i1 %cmp.i.us.i.344.i, i32 0, i32 %cond.i.us.i.346.i
  %conv21.us.i.348.i = trunc i32 %cond5.i.us.i.347.i to i8
  %arrayidx24.us.i.349.i = getelementptr inbounds i8, i8* %dst.addr.072.us.i.357.i, i64 %3
  store i8 %conv21.us.i.348.i, i8* %arrayidx24.us.i.349.i, align 1, !tbaa !4
  %5 = load i16, i16* %arrayidx17.us.i.336.i, align 2, !tbaa !0
  %conv28.us.i.350.i = zext i16 %5 to i32
  %conv32.us.i.351.i = shl nsw i32 %cond5.i.us.i.347.i, 8
  %shl33.us.i.352.i = and i32 %conv32.us.i.351.i, 65280
  %sub.us.i.353.i = sub nsw i32 %conv28.us.i.350.i, %shl33.us.i.352.i
  %conv34.us.i.354.i = trunc i32 %sub.us.i.353.i to i16
  store i16 %conv34.us.i.354.i, i16* %arrayidx.us.i.331.i, align 2, !tbaa !0
  %lftr.wideiv132 = trunc i64 %indvars.iv.next.i.333.i to i32
  %exitcond133 = icmp eq i32 %lftr.wideiv132, %conv16.i
  br i1 %exitcond133, label %for.cond.2.for.cond.cleanup.5_crit_edge.us.i.363.i, label %for.body.6.us.i.355.i

for.cond.2.for.cond.cleanup.5_crit_edge.us.i.363.i: ; preds = %for.body.6.us.i.355.i
  %inc38.us.i.360.i = add nuw nsw i32 %y.073.us.i.356.i, 1
  %add.ptr.us.i.361.i = getelementptr inbounds i16, i16* %src.addr.071.us.i.358.i, i64 %idx.ext.i.324.i
  %add.ptr40.us.i.362.i = getelementptr inbounds i8, i8* %dst.addr.072.us.i.357.i, i64 %idx.ext39.i.325.i
  %exitcond76.i.i = icmp eq i32 %inc38.us.i.360.i, %conv6.i
  br i1 %exitcond76.i.i, label %if.end.205.i.loopexit.exitStub, label %for.body.6.lr.ph.us.i.359.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"short", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!2, !2, i64 0}
