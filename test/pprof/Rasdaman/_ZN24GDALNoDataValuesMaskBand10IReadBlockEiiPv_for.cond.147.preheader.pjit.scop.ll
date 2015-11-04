
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'gdalnodatavaluesmaskband.cpp._ZN24GDALNoDataValuesMaskBand10IReadBlockEiiPv_for.cond.147.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZN24GDALNoDataValuesMaskBand10IReadBlockEiiPv_for.cond.147.preheader.pjit.scop(i64, i1 %cmp148.502, i64, i32*, i32*, i32 %call8, i8* %pImage)  {
newFuncRoot:
  br label %for.cond.147.preheader

for.end.173.loopexit.exitStub:                    ; preds = %for.end.162
  ret void

for.cond.147.preheader:                           ; preds = %for.end.162, %newFuncRoot
  %indvars.iv552 = phi i64 [ %0, %newFuncRoot ], [ %indvars.iv.next553, %for.end.162 ]
  %indvars.iv.next553 = add nsw i64 %indvars.iv552, -1
  br i1 %cmp148.502, label %for.body.149.preheader, label %for.end.162

for.body.149.preheader:                           ; preds = %for.cond.147.preheader
  br label %for.body.149

for.body.149:                                     ; preds = %for.body.149, %for.body.149.preheader
  %indvars.iv546 = phi i64 [ %indvars.iv.next547, %for.body.149 ], [ 0, %for.body.149.preheader ]
  %nCountNoData146.0503 = phi i32 [ %inc158.nCountNoData146.0, %for.body.149 ], [ 0, %for.body.149.preheader ]
  %4 = mul nsw i64 %indvars.iv546, %1
  %5 = add nsw i64 %4, %indvars.iv.next553
  %arrayidx153 = getelementptr inbounds i32, i32* %2, i64 %5
  %6 = load i32, i32* %arrayidx153, align 4, !tbaa !0
  %arrayidx155 = getelementptr inbounds i32, i32* %3, i64 %indvars.iv546
  %7 = load i32, i32* %arrayidx155, align 4, !tbaa !0
  %cmp156 = icmp eq i32 %6, %7
  %inc158 = zext i1 %cmp156 to i32
  %inc158.nCountNoData146.0 = add nsw i32 %inc158, %nCountNoData146.0503
  %indvars.iv.next547 = add nuw nsw i64 %indvars.iv546, 1
  %lftr.wideiv599 = trunc i64 %indvars.iv.next547 to i32
  %exitcond600 = icmp eq i32 %lftr.wideiv599, %call8
  br i1 %exitcond600, label %for.end.162.loopexit, label %for.body.149

for.end.162.loopexit:                             ; preds = %for.body.149
  %inc158.nCountNoData146.0.lcssa = phi i32 [ %inc158.nCountNoData146.0, %for.body.149 ]
  br label %for.end.162

for.end.162:                                      ; preds = %for.end.162.loopexit, %for.cond.147.preheader
  %nCountNoData146.0.lcssa = phi i32 [ 0, %for.cond.147.preheader ], [ %inc158.nCountNoData146.0.lcssa, %for.end.162.loopexit ]
  %arrayidx166 = getelementptr inbounds i8, i8* %pImage, i64 %indvars.iv.next553
  %not.cmp163 = icmp ne i32 %nCountNoData146.0.lcssa, %call8
  %.490 = sext i1 %not.cmp163 to i8
  store i8 %.490, i8* %arrayidx166, align 1, !tbaa !4
  %cmp144 = icmp sgt i64 %indvars.iv552, 1
  br i1 %cmp144, label %for.cond.147.preheader, label %for.end.173.loopexit.exitStub
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!2, !2, i64 0}
