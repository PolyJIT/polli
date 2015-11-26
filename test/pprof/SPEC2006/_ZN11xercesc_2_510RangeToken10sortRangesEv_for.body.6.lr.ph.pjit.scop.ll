
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/483.xalancbmk/src/RangeToken.cpp._ZN11xercesc_2_510RangeToken10sortRangesEv_for.body.6.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @_ZN11xercesc_2_510RangeToken10sortRangesEv_for.body.6.lr.ph.pjit.scop(i64, i32 %sub, i32** %fRanges)  {
newFuncRoot:
  br label %for.body.6.lr.ph

for.cond.cleanup.loopexit.exitStub:               ; preds = %for.cond.cleanup.5
  ret void

for.body.6.lr.ph:                                 ; preds = %for.cond.cleanup.5, %newFuncRoot
  %indvars.iv96 = phi i64 [ %0, %newFuncRoot ], [ %indvars.iv.next97, %for.cond.cleanup.5 ]
  %i.091 = phi i32 [ %sub, %newFuncRoot ], [ %sub64, %for.cond.cleanup.5 ]
  %1 = load i32*, i32** %fRanges, align 8, !tbaa !0
  br label %for.body.6

for.body.6:                                       ; preds = %for.cond.3.backedge, %for.body.6.lr.ph
  %indvars.iv = phi i64 [ 0, %for.body.6.lr.ph ], [ %indvars.iv.next, %for.cond.3.backedge ]
  %arrayidx = getelementptr inbounds i32, i32* %1, i64 %indvars.iv
  %2 = load i32, i32* %arrayidx, align 4, !tbaa !7
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 2
  %arrayidx10 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next
  %3 = load i32, i32* %arrayidx10, align 4, !tbaa !7
  %cmp11 = icmp sgt i32 %2, %3
  br i1 %cmp11, label %if.then.30, label %lor.lhs.false.12

if.then.30:                                       ; preds = %land.lhs.true, %for.body.6
  %4 = load i32*, i32** %fRanges, align 8, !tbaa !0
  %arrayidx34 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next
  %5 = load i32, i32* %arrayidx34, align 4, !tbaa !7
  %arrayidx37 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv
  %6 = load i32, i32* %arrayidx37, align 4, !tbaa !7
  store i32 %6, i32* %arrayidx34, align 4, !tbaa !7
  %7 = load i32*, i32** %fRanges, align 8, !tbaa !0
  %arrayidx44 = getelementptr inbounds i32, i32* %7, i64 %indvars.iv
  store i32 %5, i32* %arrayidx44, align 4, !tbaa !7
  %8 = add nuw nsw i64 %indvars.iv, 3
  %9 = load i32*, i32** %fRanges, align 8, !tbaa !0
  %arrayidx48 = getelementptr inbounds i32, i32* %9, i64 %8
  %10 = load i32, i32* %arrayidx48, align 4, !tbaa !7
  %11 = or i64 %indvars.iv, 1
  %arrayidx52 = getelementptr inbounds i32, i32* %9, i64 %11
  %12 = load i32, i32* %arrayidx52, align 4, !tbaa !7
  store i32 %12, i32* %arrayidx48, align 4, !tbaa !7
  %13 = load i32*, i32** %fRanges, align 8, !tbaa !0
  %arrayidx60 = getelementptr inbounds i32, i32* %13, i64 %11
  store i32 %10, i32* %arrayidx60, align 4, !tbaa !7
  br label %for.cond.3.backedge

for.cond.3.backedge:                              ; preds = %land.lhs.true, %lor.lhs.false.12, %if.then.30
  %cmp4 = icmp sgt i64 %indvars.iv.next, %indvars.iv96
  br i1 %cmp4, label %for.cond.cleanup.5, label %for.body.6

for.cond.cleanup.5:                               ; preds = %for.cond.3.backedge
  %sub64 = add nsw i32 %i.091, -2
  %cmp2 = icmp sgt i32 %sub64, -1
  %indvars.iv.next97 = add nsw i64 %indvars.iv96, -2
  br i1 %cmp2, label %for.body.6.lr.ph, label %for.cond.cleanup.loopexit.exitStub

lor.lhs.false.12:                                 ; preds = %for.body.6
  %cmp20 = icmp eq i32 %2, %3
  br i1 %cmp20, label %land.lhs.true, label %for.cond.3.backedge

land.lhs.true:                                    ; preds = %lor.lhs.false.12
  %14 = or i64 %indvars.iv, 1
  %arrayidx24 = getelementptr inbounds i32, i32* %1, i64 %14
  %15 = load i32, i32* %arrayidx24, align 4, !tbaa !7
  %16 = add nuw nsw i64 %indvars.iv, 3
  %arrayidx28 = getelementptr inbounds i32, i32* %1, i64 %16
  %17 = load i32, i32* %arrayidx28, align 4, !tbaa !7
  %cmp29 = icmp sgt i32 %15, %17
  br i1 %cmp29, label %if.then.30, label %for.cond.3.backedge
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !6, i64 48}
!1 = !{!"_ZTSN11xercesc_2_510RangeTokenE", !2, i64 24, !2, i64 25, !5, i64 28, !5, i64 32, !5, i64 36, !6, i64 40, !6, i64 48, !6, i64 56, !6, i64 64}
!2 = !{!"bool", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!"int", !3, i64 0}
!6 = !{!"any pointer", !3, i64 0}
!7 = !{!5, !5, i64 0}
