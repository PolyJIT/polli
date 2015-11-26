
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'nussinov.dir/nussinov.c.main_for.body.6.us.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.6.us.i.pjit.scop(i32 %indvars.iv105, i64 %indvars.iv35.i, i32* %arrayidx.i.95, i32* %arrayidx40.i, i64 %indvars.iv42.i, i8* %arrayidx80.i, i8* %call, i64, i32*)  {
newFuncRoot:
  br label %for.body.6.us.i

for.inc.198.i.loopexit.exitStub:                  ; preds = %for.inc.195.us.i
  ret void

for.body.6.us.i:                                  ; preds = %for.inc.195.us.i, %newFuncRoot
  %indvars.iv107 = phi i32 [ %indvars.iv.next108, %for.inc.195.us.i ], [ %indvars.iv105, %newFuncRoot ]
  %indvars.iv37.i = phi i64 [ %indvars.iv.next38.i, %for.inc.195.us.i ], [ %indvars.iv35.i, %newFuncRoot ]
  %2 = add nsw i64 %indvars.iv37.i, -1
  %arrayidx10.us.i = getelementptr inbounds i32, i32* %arrayidx.i.95, i64 %indvars.iv37.i
  %3 = load i32, i32* %arrayidx10.us.i, align 4, !tbaa !0
  %arrayidx15.us.i = getelementptr inbounds i32, i32* %arrayidx.i.95, i64 %2
  %4 = load i32, i32* %arrayidx15.us.i, align 4, !tbaa !0
  %cmp16.us.i = icmp slt i32 %3, %4
  %..us.i = select i1 %cmp16.us.i, i32 %4, i32 %3
  store i32 %..us.i, i32* %arrayidx10.us.i, align 4, !tbaa !0
  %arrayidx41.us.i = getelementptr inbounds i32, i32* %arrayidx40.i, i64 %indvars.iv37.i
  %5 = load i32, i32* %arrayidx41.us.i, align 4, !tbaa !0
  %cmp42.us.i = icmp slt i32 %..us.i, %5
  %.1.us.i = select i1 %cmp42.us.i, i32 %5, i32 %..us.i
  store i32 %.1.us.i, i32* %arrayidx10.us.i, align 4, !tbaa !0
  %cmp67.us.i = icmp slt i64 %indvars.iv42.i, %2
  %arrayidx78.us.i = getelementptr inbounds i32, i32* %arrayidx40.i, i64 %2
  %6 = load i32, i32* %arrayidx78.us.i, align 4, !tbaa !0
  br i1 %cmp67.us.i, label %if.then.68.us.i, label %if.else.us.i

if.then.68.us.i:                                  ; preds = %for.body.6.us.i
  %7 = load i8, i8* %arrayidx80.i, align 1, !tbaa !4
  %conv.us.i = sext i8 %7 to i32
  %arrayidx82.us.i = getelementptr inbounds i8, i8* %call, i64 %indvars.iv37.i
  %8 = load i8, i8* %arrayidx82.us.i, align 1, !tbaa !4
  %conv83.us.i = sext i8 %8 to i32
  %add84.us.i = add nsw i32 %conv83.us.i, %conv.us.i
  %cmp85.us.i = icmp eq i32 %add84.us.i, 3
  %cond87.us.i = zext i1 %cmp85.us.i to i32
  %add88.us.i = add nsw i32 %cond87.us.i, %6
  %cmp89.us.i = icmp slt i32 %.1.us.i, %add88.us.i
  %add88..us.i = select i1 %cmp89.us.i, i32 %add88.us.i, i32 %.1.us.i
  br label %for.cond.153.preheader.us.i

for.cond.153.preheader.us.i:                      ; preds = %if.else.us.i, %if.then.68.us.i
  %storemerge.i = phi i32 [ %.2.us.i, %if.else.us.i ], [ %add88..us.i, %if.then.68.us.i ]
  store i32 %storemerge.i, i32* %arrayidx10.us.i, align 4, !tbaa !0
  %cmp154.6.us.i = icmp slt i64 %0, %indvars.iv37.i
  br i1 %cmp154.6.us.i, label %for.body.156.us.i.preheader, label %for.inc.195.us.i

for.body.156.us.i.preheader:                      ; preds = %for.cond.153.preheader.us.i
  br label %for.body.156.us.i

for.body.156.us.i:                                ; preds = %for.body.156.us.i, %for.body.156.us.i.preheader
  %indvars.iv27.i = phi i64 [ %indvars.iv.next28.i, %for.body.156.us.i ], [ %indvars.iv35.i, %for.body.156.us.i.preheader ]
  %9 = load i32, i32* %arrayidx10.us.i, align 4, !tbaa !0
  %arrayidx164.us.i = getelementptr inbounds i32, i32* %arrayidx.i.95, i64 %indvars.iv27.i
  %10 = load i32, i32* %arrayidx164.us.i, align 4, !tbaa !0
  %indvars.iv.next28.i = add nuw nsw i64 %indvars.iv27.i, 1
  %11 = mul nuw nsw i64 %indvars.iv.next28.i, 2500
  %arrayidx168.us.i = getelementptr inbounds i32, i32* %1, i64 %11
  %arrayidx169.us.i = getelementptr inbounds i32, i32* %arrayidx168.us.i, i64 %indvars.iv37.i
  %12 = load i32, i32* %arrayidx169.us.i, align 4, !tbaa !0
  %add170.us.i = add nsw i32 %12, %10
  %cmp171.us.i = icmp slt i32 %9, %add170.us.i
  %add170..us.i = select i1 %cmp171.us.i, i32 %add170.us.i, i32 %9
  store i32 %add170..us.i, i32* %arrayidx10.us.i, align 4, !tbaa !0
  %lftr.wideiv = trunc i64 %indvars.iv.next28.i to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %indvars.iv107
  br i1 %exitcond, label %for.inc.195.us.i.loopexit, label %for.body.156.us.i

for.inc.195.us.i.loopexit:                        ; preds = %for.body.156.us.i
  br label %for.inc.195.us.i

for.inc.195.us.i:                                 ; preds = %for.inc.195.us.i.loopexit, %for.cond.153.preheader.us.i
  %indvars.iv.next38.i = add nuw nsw i64 %indvars.iv37.i, 1
  %indvars.iv.next108 = add nuw nsw i32 %indvars.iv107, 1
  %lftr.wideiv109 = trunc i64 %indvars.iv.next38.i to i32
  %exitcond110 = icmp eq i32 %lftr.wideiv109, 2500
  br i1 %exitcond110, label %for.inc.198.i.loopexit.exitStub, label %for.body.6.us.i

if.else.us.i:                                     ; preds = %for.body.6.us.i
  %cmp130.us.i = icmp slt i32 %.1.us.i, %6
  %.2.us.i = select i1 %cmp130.us.i, i32 %6, i32 %.1.us.i
  br label %for.cond.153.preheader.us.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!2, !2, i64 0}
