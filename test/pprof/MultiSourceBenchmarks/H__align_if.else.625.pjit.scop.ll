
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/mafft/Halignmm.c.H__align_if.else.625.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @H__align_if.else.625.pjit.scop(i1 %cmp.i.1352, float*, i32 %conv.i.1345, i64 %call2.i.1346, i64 %call.i.1344, i32**, i32 %conv3.i.1347, float* %currentw.0.lcssa)  {
newFuncRoot:
  br label %if.else.625

for.cond.47.preheader.i.exitStub:                 ; preds = %for.cond.47.preheader.i.loopexit, %for.cond.24.preheader.i, %if.else.625
  ret void

if.else.625:                                      ; preds = %newFuncRoot
  br i1 %cmp.i.1352, label %for.cond.47.preheader.i.exitStub, label %if.else.i

if.else.i:                                        ; preds = %if.else.625
  %2 = load float, float* %0, align 4, !tbaa !0
  %cmp11.45.i = icmp sgt i32 %conv.i.1345, 0
  br i1 %cmp11.45.i, label %for.body.lr.ph.i.1120, label %for.cond.24.preheader.i

for.body.lr.ph.i.1120:                            ; preds = %if.else.i
  %sext5.i = shl i64 %call2.i.1346, 32
  %idxprom20.i = ashr exact i64 %sext5.i, 32
  %sext6.i = shl i64 %call.i.1344, 32
  %idxprom21.i = ashr exact i64 %sext6.i, 32
  %arrayidx22.i = getelementptr inbounds i32*, i32** %1, i64 %idxprom21.i
  %3 = trunc i64 %call.i.1344 to i32
  br label %for.body.i.1121

for.body.i.1121:                                  ; preds = %for.inc.i, %for.body.lr.ph.i.1120
  %indvars.iv73.i = phi i64 [ 0, %for.body.lr.ph.i.1120 ], [ %indvars.iv.next74.i, %for.inc.i ]
  %wm.046.i = phi float [ %2, %for.body.lr.ph.i.1120 ], [ %wm.1.i, %for.inc.i ]
  %arrayidx13.i = getelementptr inbounds float, float* %0, i64 %indvars.iv73.i
  %4 = load float, float* %arrayidx13.i, align 4, !tbaa !0
  %cmp14.i = fcmp ult float %4, %wm.046.i
  br i1 %cmp14.i, label %for.inc.i, label %if.then.16.i

for.inc.i:                                        ; preds = %if.then.16.i, %for.body.i.1121
  %wm.1.i = phi float [ %4, %if.then.16.i ], [ %wm.046.i, %for.body.i.1121 ]
  %indvars.iv.next74.i = add nuw nsw i64 %indvars.iv73.i, 1
  %lftr.wideiv1661 = trunc i64 %indvars.iv.next74.i to i32
  %exitcond1662 = icmp eq i32 %lftr.wideiv1661, %3
  br i1 %exitcond1662, label %for.cond.24.preheader.i.loopexit, label %for.body.i.1121

for.cond.24.preheader.i.loopexit:                 ; preds = %for.inc.i
  %wm.1.i.lcssa = phi float [ %wm.1.i, %for.inc.i ]
  br label %for.cond.24.preheader.i

for.cond.24.preheader.i:                          ; preds = %for.cond.24.preheader.i.loopexit, %if.else.i
  %wm.0.lcssa.i = phi float [ %2, %if.else.i ], [ %wm.1.i.lcssa, %for.cond.24.preheader.i.loopexit ]
  %cmp25.42.i = icmp sgt i32 %conv3.i.1347, 0
  br i1 %cmp25.42.i, label %for.body.27.lr.ph.i, label %for.cond.47.preheader.i.exitStub

for.body.27.lr.ph.i:                              ; preds = %for.cond.24.preheader.i
  %sext3.i = shl i64 %call2.i.1346, 32
  %idxprom38.i = ashr exact i64 %sext3.i, 32
  %sext4.i = shl i64 %call.i.1344, 32
  %idxprom39.i = ashr exact i64 %sext4.i, 32
  %arrayidx40.i = getelementptr inbounds i32*, i32** %1, i64 %idxprom39.i
  %5 = trunc i64 %call2.i.1346 to i32
  br label %for.body.27.i

for.body.27.i:                                    ; preds = %for.inc.43.i, %for.body.27.lr.ph.i
  %indvars.iv69.i = phi i64 [ 0, %for.body.27.lr.ph.i ], [ %indvars.iv.next70.i, %for.inc.43.i ]
  %wm.243.i = phi float [ %wm.0.lcssa.i, %for.body.27.lr.ph.i ], [ %wm.3.i, %for.inc.43.i ]
  %arrayidx29.i = getelementptr inbounds float, float* %currentw.0.lcssa, i64 %indvars.iv69.i
  %6 = load float, float* %arrayidx29.i, align 4, !tbaa !0
  %cmp30.i = fcmp ult float %6, %wm.243.i
  br i1 %cmp30.i, label %for.inc.43.i, label %if.then.32.i

for.inc.43.i:                                     ; preds = %if.then.32.i, %for.body.27.i
  %wm.3.i = phi float [ %6, %if.then.32.i ], [ %wm.243.i, %for.body.27.i ]
  %indvars.iv.next70.i = add nuw nsw i64 %indvars.iv69.i, 1
  %lftr.wideiv1659 = trunc i64 %indvars.iv.next70.i to i32
  %exitcond1660 = icmp eq i32 %lftr.wideiv1659, %5
  br i1 %exitcond1660, label %for.cond.47.preheader.i.loopexit, label %for.body.27.i

for.cond.47.preheader.i.loopexit:                 ; preds = %for.inc.43.i
  br label %for.cond.47.preheader.i.exitStub

if.then.32.i:                                     ; preds = %for.body.27.i
  %7 = trunc i64 %indvars.iv69.i to i32
  %sub362.i = sub i32 %7, %conv3.i.1347
  %8 = load i32*, i32** %arrayidx40.i, align 8, !tbaa !4
  %arrayidx41.i = getelementptr inbounds i32, i32* %8, i64 %idxprom38.i
  store i32 %sub362.i, i32* %arrayidx41.i, align 4, !tbaa !6
  br label %for.inc.43.i

if.then.16.i:                                     ; preds = %for.body.i.1121
  %9 = sub i64 %call.i.1344, %indvars.iv73.i
  %10 = load i32*, i32** %arrayidx22.i, align 8, !tbaa !4
  %arrayidx23.i = getelementptr inbounds i32, i32* %10, i64 %idxprom20.i
  %11 = trunc i64 %9 to i32
  store i32 %11, i32* %arrayidx23.i, align 4, !tbaa !6
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
