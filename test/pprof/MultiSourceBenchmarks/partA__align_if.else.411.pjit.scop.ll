
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/mafft/partSalignmm.c.partA__align_if.else.411.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @partA__align_if.else.411.pjit.scop(i1 %cmp.i.742, float*, i32 %conv.i.739, i64 %call2.i.740, i64 %call.i.738, i32**, i32 %conv3.i.741, float* %currentw.0.lcssa)  {
newFuncRoot:
  br label %if.else.411

for.cond.42.preheader.i.exitStub:                 ; preds = %for.cond.42.preheader.i.loopexit, %for.cond.19.preheader.i, %if.else.411
  ret void

if.else.411:                                      ; preds = %newFuncRoot
  br i1 %cmp.i.742, label %for.cond.42.preheader.i.exitStub, label %if.else.i

if.else.i:                                        ; preds = %if.else.411
  %2 = load float, float* %0, align 4, !tbaa !0
  %cmp6.43.i = icmp sgt i32 %conv.i.739, 0
  br i1 %cmp6.43.i, label %for.body.lr.ph.i.713, label %for.cond.19.preheader.i

for.body.lr.ph.i.713:                             ; preds = %if.else.i
  %sext5.i = shl i64 %call2.i.740, 32
  %idxprom15.i = ashr exact i64 %sext5.i, 32
  %sext6.i = shl i64 %call.i.738, 32
  %idxprom16.i = ashr exact i64 %sext6.i, 32
  %arrayidx17.i = getelementptr inbounds i32*, i32** %1, i64 %idxprom16.i
  %3 = trunc i64 %call.i.738 to i32
  br label %for.body.i.714

for.body.i.714:                                   ; preds = %for.inc.i, %for.body.lr.ph.i.713
  %indvars.iv177.i = phi i64 [ 0, %for.body.lr.ph.i.713 ], [ %indvars.iv.next178.i, %for.inc.i ]
  %wm.045.i = phi float [ %2, %for.body.lr.ph.i.713 ], [ %wm.1.i, %for.inc.i ]
  %arrayidx8.i = getelementptr inbounds float, float* %0, i64 %indvars.iv177.i
  %4 = load float, float* %arrayidx8.i, align 4, !tbaa !0
  %cmp9.i = fcmp ult float %4, %wm.045.i
  br i1 %cmp9.i, label %for.inc.i, label %if.then.11.i

for.inc.i:                                        ; preds = %if.then.11.i, %for.body.i.714
  %wm.1.i = phi float [ %4, %if.then.11.i ], [ %wm.045.i, %for.body.i.714 ]
  %indvars.iv.next178.i = add nuw nsw i64 %indvars.iv177.i, 1
  %lftr.wideiv1171 = trunc i64 %indvars.iv.next178.i to i32
  %exitcond1172 = icmp eq i32 %lftr.wideiv1171, %3
  br i1 %exitcond1172, label %for.cond.19.preheader.i.loopexit, label %for.body.i.714

for.cond.19.preheader.i.loopexit:                 ; preds = %for.inc.i
  %wm.1.i.lcssa = phi float [ %wm.1.i, %for.inc.i ]
  br label %for.cond.19.preheader.i

for.cond.19.preheader.i:                          ; preds = %for.cond.19.preheader.i.loopexit, %if.else.i
  %wm.0.lcssa.i = phi float [ %2, %if.else.i ], [ %wm.1.i.lcssa, %for.cond.19.preheader.i.loopexit ]
  %cmp20.40.i = icmp sgt i32 %conv3.i.741, 0
  br i1 %cmp20.40.i, label %for.body.22.lr.ph.i, label %for.cond.42.preheader.i.exitStub

for.body.22.lr.ph.i:                              ; preds = %for.cond.19.preheader.i
  %sext3.i = shl i64 %call2.i.740, 32
  %idxprom33.i = ashr exact i64 %sext3.i, 32
  %sext4.i = shl i64 %call.i.738, 32
  %idxprom34.i = ashr exact i64 %sext4.i, 32
  %arrayidx35.i = getelementptr inbounds i32*, i32** %1, i64 %idxprom34.i
  %5 = trunc i64 %call2.i.740 to i32
  br label %for.body.22.i

for.body.22.i:                                    ; preds = %for.inc.38.i, %for.body.22.lr.ph.i
  %indvars.iv173.i = phi i64 [ 0, %for.body.22.lr.ph.i ], [ %indvars.iv.next174.i, %for.inc.38.i ]
  %wm.242.i = phi float [ %wm.0.lcssa.i, %for.body.22.lr.ph.i ], [ %wm.3.i, %for.inc.38.i ]
  %arrayidx24.i = getelementptr inbounds float, float* %currentw.0.lcssa, i64 %indvars.iv173.i
  %6 = load float, float* %arrayidx24.i, align 4, !tbaa !0
  %cmp25.i = fcmp ult float %6, %wm.242.i
  br i1 %cmp25.i, label %for.inc.38.i, label %if.then.27.i

for.inc.38.i:                                     ; preds = %if.then.27.i, %for.body.22.i
  %wm.3.i = phi float [ %6, %if.then.27.i ], [ %wm.242.i, %for.body.22.i ]
  %indvars.iv.next174.i = add nuw nsw i64 %indvars.iv173.i, 1
  %lftr.wideiv1169 = trunc i64 %indvars.iv.next174.i to i32
  %exitcond1170 = icmp eq i32 %lftr.wideiv1169, %5
  br i1 %exitcond1170, label %for.cond.42.preheader.i.loopexit, label %for.body.22.i

for.cond.42.preheader.i.loopexit:                 ; preds = %for.inc.38.i
  br label %for.cond.42.preheader.i.exitStub

if.then.27.i:                                     ; preds = %for.body.22.i
  %7 = trunc i64 %indvars.iv173.i to i32
  %sub312.i = sub i32 %7, %conv3.i.741
  %8 = load i32*, i32** %arrayidx35.i, align 8, !tbaa !4
  %arrayidx36.i = getelementptr inbounds i32, i32* %8, i64 %idxprom33.i
  store i32 %sub312.i, i32* %arrayidx36.i, align 4, !tbaa !6
  br label %for.inc.38.i

if.then.11.i:                                     ; preds = %for.body.i.714
  %9 = sub i64 %call.i.738, %indvars.iv177.i
  %10 = load i32*, i32** %arrayidx17.i, align 8, !tbaa !4
  %arrayidx18.i = getelementptr inbounds i32, i32* %10, i64 %idxprom15.i
  %11 = trunc i64 %9 to i32
  store i32 %11, i32* %arrayidx18.i, align 4, !tbaa !6
  br label %for.inc.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"any pointer", !2, i64 0}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !2, i64 0}
