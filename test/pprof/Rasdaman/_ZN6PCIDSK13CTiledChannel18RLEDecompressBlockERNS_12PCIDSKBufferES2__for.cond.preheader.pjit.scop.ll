
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'sdk/channel/ctiledchannel.cpp._ZN6PCIDSK13CTiledChannel18RLEDecompressBlockERNS_12PCIDSKBufferES2__for.cond.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZN6PCIDSK13CTiledChannel18RLEDecompressBlockERNS_12PCIDSKBufferES2__for.cond.preheader.pjit.scop(i32 %dec.113, i32 %dst_offset.0121, i1 %cmp18.110, i64, i8*, i8*, i32 %call3, i32* %dst_offset.2.lcssa.out)  {
newFuncRoot:
  br label %for.cond.preheader

while.cond.backedge.loopexit.exitStub:            ; preds = %while.cond.15.loopexit
  store i32 %dst_offset.2.lcssa, i32* %dst_offset.2.lcssa.out
  ret void

for.cond.preheader:                               ; preds = %while.cond.15.loopexit, %newFuncRoot
  %dec116 = phi i32 [ %dec, %while.cond.15.loopexit ], [ %dec.113, %newFuncRoot ]
  %dst_offset.1115 = phi i32 [ %dst_offset.2.lcssa, %while.cond.15.loopexit ], [ %dst_offset.0121, %newFuncRoot ]
  br i1 %cmp18.110, label %for.body.preheader, label %while.cond.15.loopexit

for.body.preheader:                               ; preds = %for.cond.preheader
  %3 = sext i32 %dst_offset.1115 to i64
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.preheader
  %indvars.iv132 = phi i64 [ %3, %for.body.preheader ], [ %indvars.iv.next133, %for.body ]
  %indvars.iv = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next, %for.body ]
  %4 = add nsw i64 %indvars.iv, %0
  %arrayidx21 = getelementptr inbounds i8, i8* %1, i64 %4
  %5 = load i8, i8* %arrayidx21, align 1, !tbaa !0
  %arrayidx24 = getelementptr inbounds i8, i8* %2, i64 %indvars.iv132
  store i8 %5, i8* %arrayidx24, align 1, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %indvars.iv.next133 = add nsw i64 %indvars.iv132, 1
  %lftr.wideiv138 = trunc i64 %indvars.iv.next to i32
  %exitcond139 = icmp eq i32 %lftr.wideiv138, %call3
  br i1 %exitcond139, label %while.cond.15.loopexit.loopexit, label %for.body

while.cond.15.loopexit.loopexit:                  ; preds = %for.body
  %6 = add i32 %dst_offset.1115, %call3
  br label %while.cond.15.loopexit

while.cond.15.loopexit:                           ; preds = %while.cond.15.loopexit.loopexit, %for.cond.preheader
  %dst_offset.2.lcssa = phi i32 [ %dst_offset.1115, %for.cond.preheader ], [ %6, %while.cond.15.loopexit.loopexit ]
  %dec = add nsw i32 %dec116, -1
  %cmp16 = icmp sgt i32 %dec116, 0
  br i1 %cmp16, label %for.cond.preheader, label %while.cond.backedge.loopexit.exitStub
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
