
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/oggenc/oggenc.c.vorbis_lpc_to_lsp_if.end.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @vorbis_lpc_to_lsp_if.end.pjit.scop(float*, i32 %shr)  {
newFuncRoot:
  br label %if.end

cheby.exit.exitStub:                              ; preds = %cheby.exit.loopexit, %if.end
  ret void

if.end:                                           ; preds = %newFuncRoot
  %1 = load float, float* %0, align 4
  %mul.i = fmul float %1, 5.000000e-01
  store float %mul.i, float* %0, align 4
  %cmp.30.i = icmp slt i32 %shr, 2
  br i1 %cmp.30.i, label %cheby.exit.exitStub, label %for.cond.1.preheader.preheader.i

for.cond.1.preheader.preheader.i:                 ; preds = %if.end
  %2 = add nsw i32 %shr, 1
  %3 = sext i32 %shr to i64
  br label %for.body.3.preheader.i

for.body.3.preheader.i:                           ; preds = %for.inc.12.i, %for.cond.1.preheader.preheader.i
  %indvars.iv32.i = phi i64 [ 2, %for.cond.1.preheader.preheader.i ], [ %indvars.iv.next33.i, %for.inc.12.i ]
  br label %for.body.3.i

for.body.3.i:                                     ; preds = %for.body.3.i, %for.body.3.preheader.i
  %indvars.iv280 = phi i64 [ %indvars.iv.next281, %for.body.3.i ], [ %3, %for.body.3.preheader.i ]
  %arrayidx4.i = getelementptr inbounds float, float* %0, i64 %indvars.iv280
  %4 = load float, float* %arrayidx4.i, align 4
  %5 = add nsw i64 %indvars.iv280, -2
  %arrayidx6.i = getelementptr inbounds float, float* %0, i64 %5
  %6 = load float, float* %arrayidx6.i, align 4
  %sub7.i = fsub float %6, %4
  store float %sub7.i, float* %arrayidx6.i, align 4
  %add.i = fadd float %4, %4
  store float %add.i, float* %arrayidx4.i, align 4
  %indvars.iv.next281 = add nsw i64 %indvars.iv280, -1
  %cmp2.i = icmp sgt i64 %indvars.iv280, %indvars.iv32.i
  br i1 %cmp2.i, label %for.body.3.i, label %for.inc.12.i

for.inc.12.i:                                     ; preds = %for.body.3.i
  %indvars.iv.next33.i = add nuw nsw i64 %indvars.iv32.i, 1
  %lftr.wideiv322 = trunc i64 %indvars.iv.next33.i to i32
  %exitcond323 = icmp eq i32 %lftr.wideiv322, %2
  br i1 %exitcond323, label %cheby.exit.loopexit, label %for.body.3.preheader.i

cheby.exit.loopexit:                              ; preds = %for.inc.12.i
  br label %cheby.exit.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }
