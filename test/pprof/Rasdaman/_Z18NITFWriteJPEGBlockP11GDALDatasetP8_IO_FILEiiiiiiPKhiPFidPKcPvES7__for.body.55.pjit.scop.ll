
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'nitfwritejpeg.cpp._Z18NITFWriteJPEGBlockP11GDALDatasetP8_IO_FILEiiiiiiPKhiPFidPKcPvES7__for.body.55.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_Z18NITFWriteJPEGBlockP11GDALDatasetP8_IO_FILEiiiiiiPKhiPFidPKcPvES7__for.body.55.pjit.scop(i64, i8* %call19, i1 %cmp60.228, i32 %sub.nBlockXSize, i32 %call3, i32 %nBlockXSize)  {
newFuncRoot:
  br label %for.body.55

if.end.71.loopexit.exitStub:                      ; preds = %for.cond.cleanup.61
  ret void

for.body.55:                                      ; preds = %for.cond.cleanup.61, %newFuncRoot
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.cond.cleanup.61 ], [ 0, %newFuncRoot ]
  %1 = add nsw i64 %indvars.iv, %0
  %arrayidx = getelementptr inbounds i8, i8* %call19, i64 %1
  %2 = load i8, i8* %arrayidx, align 1, !tbaa !0
  br i1 %cmp60.228, label %for.body.62.preheader, label %for.cond.cleanup.61

for.body.62.preheader:                            ; preds = %for.body.55
  br label %for.body.62

for.body.62:                                      ; preds = %for.body.62, %for.body.62.preheader
  %iX.0229 = phi i32 [ %inc, %for.body.62 ], [ %sub.nBlockXSize, %for.body.62.preheader ]
  %mul63 = mul nsw i32 %iX.0229, %call3
  %3 = trunc i64 %indvars.iv to i32
  %add64 = add nsw i32 %mul63, %3
  %idxprom65 = sext i32 %add64 to i64
  %arrayidx66 = getelementptr inbounds i8, i8* %call19, i64 %idxprom65
  store i8 %2, i8* %arrayidx66, align 1, !tbaa !0
  %inc = add nsw i32 %iX.0229, 1
  %cmp60 = icmp slt i32 %inc, %nBlockXSize
  br i1 %cmp60, label %for.body.62, label %for.cond.cleanup.61.loopexit

for.cond.cleanup.61.loopexit:                     ; preds = %for.body.62
  br label %for.cond.cleanup.61

for.cond.cleanup.61:                              ; preds = %for.cond.cleanup.61.loopexit, %for.body.55
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv252 = trunc i64 %indvars.iv.next to i32
  %exitcond253 = icmp eq i32 %lftr.wideiv252, %call3
  br i1 %exitcond253, label %if.end.71.loopexit.exitStub, label %for.body.55
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
