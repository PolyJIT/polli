
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'geotiff.cpp._ZN12GTiffDataset12VirtualMemIOE10GDALRWFlagiiiiPvii12GDALDataTypeiPixxxP20GDALRasterIOExtraArg_for.cond.471.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZN12GTiffDataset12VirtualMemIOE10GDALRWFlagiiiiPvii12GDALDataTypeiPixxxP20GDALRasterIOExtraArg_for.cond.471.preheader.pjit.scop(i8* %add.ptr450, i8* %add.ptr454, i1 %cmp472.1619, i32 %nBandCount, i64 %idx.ext483, i64 %nPixelSpace, i32 %nBufXSize)  {
newFuncRoot:
  br label %for.cond.471.preheader

for.inc.563.loopexit1709.exitStub:                ; preds = %for.cond.cleanup.473
  ret void

for.cond.471.preheader:                           ; preds = %for.cond.cleanup.473, %newFuncRoot
  %pabyLocalData447.01624 = phi i8* [ %add.ptr485, %for.cond.cleanup.473 ], [ %add.ptr450, %newFuncRoot ]
  %pabyLocalSrcData451.01623 = phi i8* [ %add.ptr484, %for.cond.cleanup.473 ], [ %add.ptr454, %newFuncRoot ]
  %x465.01622 = phi i32 [ %inc487, %for.cond.cleanup.473 ], [ 0, %newFuncRoot ]
  br i1 %cmp472.1619, label %for.body.474.preheader, label %for.cond.cleanup.473

for.body.474.preheader:                           ; preds = %for.cond.471.preheader
  br label %for.body.474

for.body.474:                                     ; preds = %for.body.474, %for.body.474.preheader
  %indvars.iv1686 = phi i64 [ %indvars.iv.next1687, %for.body.474 ], [ 0, %for.body.474.preheader ]
  %arrayidx476 = getelementptr inbounds i8, i8* %pabyLocalSrcData451.01623, i64 %indvars.iv1686
  %0 = load i8, i8* %arrayidx476, align 1, !tbaa !0
  %arrayidx478 = getelementptr inbounds i8, i8* %pabyLocalData447.01624, i64 %indvars.iv1686
  store i8 %0, i8* %arrayidx478, align 1, !tbaa !0
  %indvars.iv.next1687 = add nuw nsw i64 %indvars.iv1686, 1
  %lftr.wideiv1735 = trunc i64 %indvars.iv.next1687 to i32
  %exitcond1736 = icmp eq i32 %lftr.wideiv1735, %nBandCount
  br i1 %exitcond1736, label %for.cond.cleanup.473.loopexit, label %for.body.474

for.cond.cleanup.473.loopexit:                    ; preds = %for.body.474
  br label %for.cond.cleanup.473

for.cond.cleanup.473:                             ; preds = %for.cond.cleanup.473.loopexit, %for.cond.471.preheader
  %add.ptr484 = getelementptr inbounds i8, i8* %pabyLocalSrcData451.01623, i64 %idx.ext483
  %add.ptr485 = getelementptr inbounds i8, i8* %pabyLocalData447.01624, i64 %nPixelSpace
  %inc487 = add nuw nsw i32 %x465.01622, 1
  %exitcond1690 = icmp eq i32 %inc487, %nBufXSize
  br i1 %exitcond1690, label %for.inc.563.loopexit1709.exitStub, label %for.cond.471.preheader
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
