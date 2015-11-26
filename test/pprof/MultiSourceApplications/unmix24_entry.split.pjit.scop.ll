
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/ALAC/encode/matrix_dec.c.unmix24_entry.split.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @unmix24_entry.split.pjit.scop(i32 %bytesShifted, i32 %mixres, i32 %numSamples, i32 %stride, i8* %out, i32* %u, i32* %v, i16* %shiftUV, i32 %mixbits)  {
newFuncRoot:
  br label %entry.split

if.end.196.exitStub:                              ; preds = %if.end.196.loopexit368, %for.cond.48.preheader, %if.end.196.loopexit367, %for.cond.preheader, %if.end.196.loopexit366, %for.cond.155.preheader, %if.end.196.loopexit, %for.cond.101.preheader
  ret void

entry.split:                                      ; preds = %newFuncRoot
  %mul = shl nsw i32 %bytesShifted, 3
  %cmp = icmp eq i32 %mixres, 0
  %cmp1 = icmp ne i32 %bytesShifted, 0
  %cmp102.331 = icmp sgt i32 %numSamples, 0
  br i1 %cmp, label %if.else.97, label %if.then

if.else.97:                                       ; preds = %entry.split
  br i1 %cmp1, label %for.cond.101.preheader, label %for.cond.155.preheader

for.cond.101.preheader:                           ; preds = %if.else.97
  br i1 %cmp102.331, label %for.body.104.lr.ph, label %if.end.196.exitStub

for.body.104.lr.ph:                               ; preds = %for.cond.101.preheader
  %0 = mul i32 %stride, 3
  %mul147 = add i32 %0, -3
  %idx.ext148 = zext i32 %mul147 to i64
  br label %for.body.104

for.body.104:                                     ; preds = %for.body.104, %for.body.104.lr.ph
  %indvars.iv349 = phi i64 [ 0, %for.body.104.lr.ph ], [ %indvars.iv.next350, %for.body.104 ]
  %indvars.iv = phi i64 [ 0, %for.body.104.lr.ph ], [ %indvars.iv.next, %for.body.104 ]
  %op.2334 = phi i8* [ %out, %for.body.104.lr.ph ], [ %add.ptr149, %for.body.104 ]
  %arrayidx106 = getelementptr inbounds i32, i32* %u, i64 %indvars.iv349
  %1 = load i32, i32* %arrayidx106, align 4, !tbaa !0
  %arrayidx108 = getelementptr inbounds i32, i32* %v, i64 %indvars.iv349
  %2 = load i32, i32* %arrayidx108, align 4, !tbaa !0
  %shl109 = shl i32 %1, %mul
  %arrayidx112 = getelementptr inbounds i16, i16* %shiftUV, i64 %indvars.iv
  %3 = load i16, i16* %arrayidx112, align 2, !tbaa !4
  %conv113 = zext i16 %3 to i32
  %or114 = or i32 %conv113, %shl109
  %shl115 = shl i32 %2, %mul
  %4 = or i64 %indvars.iv, 1
  %arrayidx118 = getelementptr inbounds i16, i16* %shiftUV, i64 %4
  %5 = load i16, i16* %arrayidx118, align 2, !tbaa !4
  %conv119 = zext i16 %5 to i32
  %or120 = or i32 %conv119, %shl115
  %shr121.316 = lshr i32 %shl109, 16
  %conv123 = trunc i32 %shr121.316 to i8
  %arrayidx124 = getelementptr inbounds i8, i8* %op.2334, i64 2
  store i8 %conv123, i8* %arrayidx124, align 1, !tbaa !6
  %shr125.317 = lshr i32 %or114, 8
  %conv127 = trunc i32 %shr125.317 to i8
  %arrayidx128 = getelementptr inbounds i8, i8* %op.2334, i64 1
  store i8 %conv127, i8* %arrayidx128, align 1, !tbaa !6
  %conv131 = trunc i32 %or114 to i8
  store i8 %conv131, i8* %op.2334, align 1, !tbaa !6
  %add.ptr133 = getelementptr inbounds i8, i8* %op.2334, i64 3
  %shr134.318 = lshr i32 %shl115, 16
  %conv136 = trunc i32 %shr134.318 to i8
  %arrayidx137 = getelementptr inbounds i8, i8* %op.2334, i64 5
  store i8 %conv136, i8* %arrayidx137, align 1, !tbaa !6
  %shr138.319 = lshr i32 %or120, 8
  %conv140 = trunc i32 %shr138.319 to i8
  %arrayidx141 = getelementptr inbounds i8, i8* %op.2334, i64 4
  store i8 %conv140, i8* %arrayidx141, align 1, !tbaa !6
  %conv144 = trunc i32 %or120 to i8
  store i8 %conv144, i8* %add.ptr133, align 1, !tbaa !6
  %add.ptr149 = getelementptr inbounds i8, i8* %add.ptr133, i64 %idx.ext148
  %indvars.iv.next350 = add nuw nsw i64 %indvars.iv349, 1
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 2
  %lftr.wideiv369 = trunc i64 %indvars.iv.next350 to i32
  %exitcond370 = icmp eq i32 %lftr.wideiv369, %numSamples
  br i1 %exitcond370, label %if.end.196.loopexit, label %for.body.104

if.end.196.loopexit:                              ; preds = %for.body.104
  br label %if.end.196.exitStub

for.cond.155.preheader:                           ; preds = %if.else.97
  br i1 %cmp102.331, label %for.body.158.lr.ph, label %if.end.196.exitStub

for.body.158.lr.ph:                               ; preds = %for.cond.155.preheader
  %6 = mul i32 %stride, 3
  %mul189 = add i32 %6, -3
  %idx.ext190 = zext i32 %mul189 to i64
  br label %for.body.158

for.body.158:                                     ; preds = %for.body.158, %for.body.158.lr.ph
  %indvars.iv351 = phi i64 [ 0, %for.body.158.lr.ph ], [ %indvars.iv.next352, %for.body.158 ]
  %op.3337 = phi i8* [ %out, %for.body.158.lr.ph ], [ %add.ptr191, %for.body.158 ]
  %arrayidx160 = getelementptr inbounds i32, i32* %u, i64 %indvars.iv351
  %7 = load i32, i32* %arrayidx160, align 4, !tbaa !0
  %shr161.312 = lshr i32 %7, 16
  %conv163 = trunc i32 %shr161.312 to i8
  %arrayidx164 = getelementptr inbounds i8, i8* %op.3337, i64 2
  store i8 %conv163, i8* %arrayidx164, align 1, !tbaa !6
  %shr165.313 = lshr i32 %7, 8
  %conv167 = trunc i32 %shr165.313 to i8
  %arrayidx168 = getelementptr inbounds i8, i8* %op.3337, i64 1
  store i8 %conv167, i8* %arrayidx168, align 1, !tbaa !6
  %conv171 = trunc i32 %7 to i8
  store i8 %conv171, i8* %op.3337, align 1, !tbaa !6
  %add.ptr173 = getelementptr inbounds i8, i8* %op.3337, i64 3
  %arrayidx175 = getelementptr inbounds i32, i32* %v, i64 %indvars.iv351
  %8 = load i32, i32* %arrayidx175, align 4, !tbaa !0
  %shr176.314 = lshr i32 %8, 16
  %conv178 = trunc i32 %shr176.314 to i8
  %arrayidx179 = getelementptr inbounds i8, i8* %op.3337, i64 5
  store i8 %conv178, i8* %arrayidx179, align 1, !tbaa !6
  %shr180.315 = lshr i32 %8, 8
  %conv182 = trunc i32 %shr180.315 to i8
  %arrayidx183 = getelementptr inbounds i8, i8* %op.3337, i64 4
  store i8 %conv182, i8* %arrayidx183, align 1, !tbaa !6
  %conv186 = trunc i32 %8 to i8
  store i8 %conv186, i8* %add.ptr173, align 1, !tbaa !6
  %add.ptr191 = getelementptr inbounds i8, i8* %add.ptr173, i64 %idx.ext190
  %indvars.iv.next352 = add nuw nsw i64 %indvars.iv351, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next352 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %numSamples
  br i1 %exitcond, label %if.end.196.loopexit366, label %for.body.158

if.end.196.loopexit366:                           ; preds = %for.body.158
  br label %if.end.196.exitStub

if.then:                                          ; preds = %entry.split
  br i1 %cmp1, label %for.cond.preheader, label %for.cond.48.preheader

for.cond.preheader:                               ; preds = %if.then
  br i1 %cmp102.331, label %for.body.lr.ph, label %if.end.196.exitStub

for.body.lr.ph:                                   ; preds = %for.cond.preheader
  %9 = mul i32 %stride, 3
  %mul45 = add i32 %9, -3
  %idx.ext = zext i32 %mul45 to i64
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.lr.ph
  %indvars.iv358 = phi i64 [ 0, %for.body.lr.ph ], [ %indvars.iv.next359, %for.body ]
  %indvars.iv355 = phi i64 [ 0, %for.body.lr.ph ], [ %indvars.iv.next356, %for.body ]
  %op.0341 = phi i8* [ %out, %for.body.lr.ph ], [ %add.ptr46, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %u, i64 %indvars.iv358
  %10 = load i32, i32* %arrayidx, align 4, !tbaa !0
  %arrayidx5 = getelementptr inbounds i32, i32* %v, i64 %indvars.iv358
  %11 = load i32, i32* %arrayidx5, align 4, !tbaa !0
  %add = add nsw i32 %11, %10
  %mul8 = mul nsw i32 %11, %mixres
  %shr = ashr i32 %mul8, %mixbits
  %sub = sub i32 %add, %shr
  %sub11 = sub nsw i32 %sub, %11
  %shl = shl i32 %sub, %mul
  %arrayidx14 = getelementptr inbounds i16, i16* %shiftUV, i64 %indvars.iv355
  %12 = load i16, i16* %arrayidx14, align 2, !tbaa !4
  %conv = zext i16 %12 to i32
  %or = or i32 %shl, %conv
  %shl15 = shl i32 %sub11, %mul
  %13 = or i64 %indvars.iv355, 1
  %arrayidx18 = getelementptr inbounds i16, i16* %shiftUV, i64 %13
  %14 = load i16, i16* %arrayidx18, align 2, !tbaa !4
  %conv19 = zext i16 %14 to i32
  %or20 = or i32 %shl15, %conv19
  %shr21.324 = lshr i32 %shl, 16
  %conv22 = trunc i32 %shr21.324 to i8
  %arrayidx23 = getelementptr inbounds i8, i8* %op.0341, i64 2
  store i8 %conv22, i8* %arrayidx23, align 1, !tbaa !6
  %shr24.325 = lshr i32 %or, 8
  %conv26 = trunc i32 %shr24.325 to i8
  %arrayidx27 = getelementptr inbounds i8, i8* %op.0341, i64 1
  store i8 %conv26, i8* %arrayidx27, align 1, !tbaa !6
  %conv30 = trunc i32 %or to i8
  store i8 %conv30, i8* %op.0341, align 1, !tbaa !6
  %add.ptr = getelementptr inbounds i8, i8* %op.0341, i64 3
  %shr32.326 = lshr i32 %shl15, 16
  %conv34 = trunc i32 %shr32.326 to i8
  %arrayidx35 = getelementptr inbounds i8, i8* %op.0341, i64 5
  store i8 %conv34, i8* %arrayidx35, align 1, !tbaa !6
  %shr36.327 = lshr i32 %or20, 8
  %conv38 = trunc i32 %shr36.327 to i8
  %arrayidx39 = getelementptr inbounds i8, i8* %op.0341, i64 4
  store i8 %conv38, i8* %arrayidx39, align 1, !tbaa !6
  %conv42 = trunc i32 %or20 to i8
  store i8 %conv42, i8* %add.ptr, align 1, !tbaa !6
  %add.ptr46 = getelementptr inbounds i8, i8* %add.ptr, i64 %idx.ext
  %indvars.iv.next359 = add nuw nsw i64 %indvars.iv358, 1
  %indvars.iv.next356 = add nuw nsw i64 %indvars.iv355, 2
  %lftr.wideiv371 = trunc i64 %indvars.iv.next359 to i32
  %exitcond372 = icmp eq i32 %lftr.wideiv371, %numSamples
  br i1 %exitcond372, label %if.end.196.loopexit367, label %for.body

if.end.196.loopexit367:                           ; preds = %for.body
  br label %if.end.196.exitStub

for.cond.48.preheader:                            ; preds = %if.then
  br i1 %cmp102.331, label %for.body.51.lr.ph, label %if.end.196.exitStub

for.body.51.lr.ph:                                ; preds = %for.cond.48.preheader
  %15 = mul i32 %stride, 3
  %mul91 = add i32 %15, -3
  %idx.ext92 = zext i32 %mul91 to i64
  br label %for.body.51

for.body.51:                                      ; preds = %for.body.51, %for.body.51.lr.ph
  %indvars.iv362 = phi i64 [ 0, %for.body.51.lr.ph ], [ %indvars.iv.next363, %for.body.51 ]
  %op.1344 = phi i8* [ %out, %for.body.51.lr.ph ], [ %add.ptr93, %for.body.51 ]
  %arrayidx53 = getelementptr inbounds i32, i32* %u, i64 %indvars.iv362
  %16 = load i32, i32* %arrayidx53, align 4, !tbaa !0
  %arrayidx55 = getelementptr inbounds i32, i32* %v, i64 %indvars.iv362
  %17 = load i32, i32* %arrayidx55, align 4, !tbaa !0
  %add56 = add nsw i32 %17, %16
  %mul59 = mul nsw i32 %17, %mixres
  %shr60 = ashr i32 %mul59, %mixbits
  %sub61 = sub i32 %add56, %shr60
  %sub64 = sub nsw i32 %sub61, %17
  %shr65.320 = lshr i32 %sub61, 16
  %conv67 = trunc i32 %shr65.320 to i8
  %arrayidx68 = getelementptr inbounds i8, i8* %op.1344, i64 2
  store i8 %conv67, i8* %arrayidx68, align 1, !tbaa !6
  %shr69.321 = lshr i32 %sub61, 8
  %conv71 = trunc i32 %shr69.321 to i8
  %arrayidx72 = getelementptr inbounds i8, i8* %op.1344, i64 1
  store i8 %conv71, i8* %arrayidx72, align 1, !tbaa !6
  %conv75 = trunc i32 %sub61 to i8
  store i8 %conv75, i8* %op.1344, align 1, !tbaa !6
  %add.ptr77 = getelementptr inbounds i8, i8* %op.1344, i64 3
  %shr78.322 = lshr i32 %sub64, 16
  %conv80 = trunc i32 %shr78.322 to i8
  %arrayidx81 = getelementptr inbounds i8, i8* %op.1344, i64 5
  store i8 %conv80, i8* %arrayidx81, align 1, !tbaa !6
  %shr82.323 = lshr i32 %sub64, 8
  %conv84 = trunc i32 %shr82.323 to i8
  %arrayidx85 = getelementptr inbounds i8, i8* %op.1344, i64 4
  store i8 %conv84, i8* %arrayidx85, align 1, !tbaa !6
  %conv88 = trunc i32 %sub64 to i8
  store i8 %conv88, i8* %add.ptr77, align 1, !tbaa !6
  %add.ptr93 = getelementptr inbounds i8, i8* %add.ptr77, i64 %idx.ext92
  %indvars.iv.next363 = add nuw nsw i64 %indvars.iv362, 1
  %lftr.wideiv373 = trunc i64 %indvars.iv.next363 to i32
  %exitcond374 = icmp eq i32 %lftr.wideiv373, %numSamples
  br i1 %exitcond374, label %if.end.196.loopexit368, label %for.body.51

if.end.196.loopexit368:                           ; preds = %for.body.51
  br label %if.end.196.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"short", !2, i64 0}
!6 = !{!2, !2, i64 0}
