
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/ALAC/encode/matrix_enc.c.mix32_entry.split.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @mix32_entry.split.pjit.scop(i32 %bytesShifted, i32 %mixres, i32 %numSamples, i32 %stride, i32* %in, i32* %u, i32* %v, i16* %shiftUV, i32 %mixbits)  {
newFuncRoot:
  br label %entry.split

if.end.72.exitStub:                               ; preds = %if.end.72.loopexit170, %if.then, %if.end.72.loopexit169, %for.cond.44.preheader, %if.end.72.loopexit, %for.cond.28.preheader
  ret void

entry.split:                                      ; preds = %newFuncRoot
  %mul = shl nsw i32 %bytesShifted, 3
  %sh_prom = zext i32 %mul to i64
  %shl = shl i64 1, %sh_prom
  %sub = add nuw nsw i64 %shl, 4294967295
  %conv = trunc i64 %sub to i32
  %cmp = icmp eq i32 %mixres, 0
  br i1 %cmp, label %if.else, label %if.then

if.else:                                          ; preds = %entry.split
  %cmp25 = icmp eq i32 %bytesShifted, 0
  %cmp29.142 = icmp sgt i32 %numSamples, 0
  br i1 %cmp25, label %for.cond.28.preheader, label %for.cond.44.preheader

for.cond.28.preheader:                            ; preds = %if.else
  br i1 %cmp29.142, label %for.body.31.lr.ph, label %if.end.72.exitStub

for.body.31.lr.ph:                                ; preds = %for.cond.28.preheader
  %idx.ext38 = zext i32 %stride to i64
  br label %for.body.31

for.body.31:                                      ; preds = %for.body.31, %for.body.31.lr.ph
  %indvars.iv = phi i64 [ 0, %for.body.31.lr.ph ], [ %indvars.iv.next, %for.body.31 ]
  %ip.1144 = phi i32* [ %in, %for.body.31.lr.ph ], [ %add.ptr39, %for.body.31 ]
  %0 = load i32, i32* %ip.1144, align 4, !tbaa !0
  %arrayidx34 = getelementptr inbounds i32, i32* %u, i64 %indvars.iv
  store i32 %0, i32* %arrayidx34, align 4, !tbaa !0
  %arrayidx35 = getelementptr inbounds i32, i32* %ip.1144, i64 1
  %1 = load i32, i32* %arrayidx35, align 4, !tbaa !0
  %arrayidx37 = getelementptr inbounds i32, i32* %v, i64 %indvars.iv
  store i32 %1, i32* %arrayidx37, align 4, !tbaa !0
  %add.ptr39 = getelementptr inbounds i32, i32* %ip.1144, i64 %idx.ext38
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv171 = trunc i64 %indvars.iv.next to i32
  %exitcond172 = icmp eq i32 %lftr.wideiv171, %numSamples
  br i1 %exitcond172, label %if.end.72.loopexit, label %for.body.31

if.end.72.loopexit:                               ; preds = %for.body.31
  br label %if.end.72.exitStub

for.cond.44.preheader:                            ; preds = %if.else
  br i1 %cmp29.142, label %for.body.47.lr.ph, label %if.end.72.exitStub

for.body.47.lr.ph:                                ; preds = %for.cond.44.preheader
  %idx.ext50 = zext i32 %stride to i64
  br label %for.body.47

for.body.47:                                      ; preds = %for.body.47, %for.body.47.lr.ph
  %indvars.iv158 = phi i64 [ 0, %for.body.47.lr.ph ], [ %indvars.iv.next159, %for.body.47 ]
  %indvars.iv155 = phi i64 [ 0, %for.body.47.lr.ph ], [ %indvars.iv.next156, %for.body.47 ]
  %ip.2148 = phi i32* [ %in, %for.body.47.lr.ph ], [ %add.ptr51, %for.body.47 ]
  %2 = load i32, i32* %ip.2148, align 4, !tbaa !0
  %arrayidx49 = getelementptr inbounds i32, i32* %ip.2148, i64 1
  %3 = load i32, i32* %arrayidx49, align 4, !tbaa !0
  %add.ptr51 = getelementptr inbounds i32, i32* %ip.2148, i64 %idx.ext50
  %and52 = and i32 %2, %conv
  %conv53 = trunc i32 %and52 to i16
  %arrayidx56 = getelementptr inbounds i16, i16* %shiftUV, i64 %indvars.iv155
  store i16 %conv53, i16* %arrayidx56, align 2, !tbaa !4
  %and57 = and i32 %3, %conv
  %conv58 = trunc i32 %and57 to i16
  %4 = or i64 %indvars.iv155, 1
  %arrayidx61 = getelementptr inbounds i16, i16* %shiftUV, i64 %4
  store i16 %conv58, i16* %arrayidx61, align 2, !tbaa !4
  %shr62 = ashr i32 %2, %mul
  %shr63 = ashr i32 %3, %mul
  %arrayidx65 = getelementptr inbounds i32, i32* %u, i64 %indvars.iv158
  store i32 %shr62, i32* %arrayidx65, align 4, !tbaa !0
  %arrayidx67 = getelementptr inbounds i32, i32* %v, i64 %indvars.iv158
  store i32 %shr63, i32* %arrayidx67, align 4, !tbaa !0
  %indvars.iv.next159 = add nuw nsw i64 %indvars.iv158, 1
  %indvars.iv.next156 = add nuw nsw i64 %indvars.iv155, 2
  %lftr.wideiv = trunc i64 %indvars.iv.next159 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %numSamples
  br i1 %exitcond, label %if.end.72.loopexit169, label %for.body.47

if.end.72.loopexit169:                            ; preds = %for.body.47
  br label %if.end.72.exitStub

if.then:                                          ; preds = %entry.split
  %shl2 = shl i32 1, %mixbits
  %sub3 = sub nsw i32 %shl2, %mixres
  %cmp4.149 = icmp sgt i32 %numSamples, 0
  br i1 %cmp4.149, label %for.body.lr.ph, label %if.end.72.exitStub

for.body.lr.ph:                                   ; preds = %if.then
  %idx.ext = zext i32 %stride to i64
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.lr.ph
  %indvars.iv165 = phi i64 [ 0, %for.body.lr.ph ], [ %indvars.iv.next166, %for.body ]
  %indvars.iv162 = phi i64 [ 0, %for.body.lr.ph ], [ %indvars.iv.next163, %for.body ]
  %ip.0152 = phi i32* [ %in, %for.body.lr.ph ], [ %add.ptr, %for.body ]
  %5 = load i32, i32* %ip.0152, align 4, !tbaa !0
  %arrayidx6 = getelementptr inbounds i32, i32* %ip.0152, i64 1
  %6 = load i32, i32* %arrayidx6, align 4, !tbaa !0
  %add.ptr = getelementptr inbounds i32, i32* %ip.0152, i64 %idx.ext
  %and = and i32 %5, %conv
  %conv7 = trunc i32 %and to i16
  %arrayidx8 = getelementptr inbounds i16, i16* %shiftUV, i64 %indvars.iv162
  store i16 %conv7, i16* %arrayidx8, align 2, !tbaa !4
  %and9 = and i32 %6, %conv
  %conv10 = trunc i32 %and9 to i16
  %7 = or i64 %indvars.iv162, 1
  %arrayidx13 = getelementptr inbounds i16, i16* %shiftUV, i64 %7
  store i16 %conv10, i16* %arrayidx13, align 2, !tbaa !4
  %shr = ashr i32 %5, %mul
  %shr14 = ashr i32 %6, %mul
  %mul15 = mul nsw i32 %shr, %mixres
  %mul16 = mul nsw i32 %shr14, %sub3
  %add17 = add nsw i32 %mul16, %mul15
  %shr18 = ashr i32 %add17, %mixbits
  %arrayidx20 = getelementptr inbounds i32, i32* %u, i64 %indvars.iv165
  store i32 %shr18, i32* %arrayidx20, align 4, !tbaa !0
  %sub21 = sub nsw i32 %shr, %shr14
  %arrayidx23 = getelementptr inbounds i32, i32* %v, i64 %indvars.iv165
  store i32 %sub21, i32* %arrayidx23, align 4, !tbaa !0
  %indvars.iv.next166 = add nuw nsw i64 %indvars.iv165, 1
  %indvars.iv.next163 = add nuw nsw i64 %indvars.iv162, 2
  %lftr.wideiv173 = trunc i64 %indvars.iv.next166 to i32
  %exitcond174 = icmp eq i32 %lftr.wideiv173, %numSamples
  br i1 %exitcond174, label %if.end.72.loopexit170, label %for.body

if.end.72.loopexit170:                            ; preds = %for.body
  br label %if.end.72.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"short", !2, i64 0}
