
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/mafft/fftFunctions.c.zurasu2_entry.split.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @zurasu2_entry.split.pjit.scop(i32 %lag, i32 %clus1, i8** %seq1, i8** %aseq1, i32 %clus2, i8** %seq2, i8** %aseq2)  {
newFuncRoot:
  br label %entry.split

if.end.exitStub:                                  ; preds = %if.end.loopexit84, %for.cond.26.preheader, %if.end.loopexit, %for.cond.4.preheader
  ret void

entry.split:                                      ; preds = %newFuncRoot
  %cmp = icmp sgt i32 %lag, 0
  %cmp1.63 = icmp sgt i32 %clus1, 0
  br i1 %cmp, label %for.cond.preheader, label %for.cond.14.preheader

for.cond.preheader:                               ; preds = %entry.split
  br i1 %cmp1.63, label %for.body.preheader, label %for.cond.4.preheader

for.body.preheader:                               ; preds = %for.cond.preheader
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.preheader
  %indvars.iv70 = phi i64 [ %indvars.iv.next71, %for.body ], [ 0, %for.body.preheader ]
  %arrayidx = getelementptr inbounds i8*, i8** %seq1, i64 %indvars.iv70
  %0 = bitcast i8** %arrayidx to i64*
  %1 = load i64, i64* %0, align 8, !tbaa !0
  %arrayidx3 = getelementptr inbounds i8*, i8** %aseq1, i64 %indvars.iv70
  %2 = bitcast i8** %arrayidx3 to i64*
  store i64 %1, i64* %2, align 8, !tbaa !0
  %indvars.iv.next71 = add nuw nsw i64 %indvars.iv70, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next71 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %clus1
  br i1 %exitcond, label %for.cond.4.preheader.loopexit, label %for.body

for.cond.4.preheader.loopexit:                    ; preds = %for.body
  br label %for.cond.4.preheader

for.cond.4.preheader:                             ; preds = %for.cond.4.preheader.loopexit, %for.cond.preheader
  %cmp5.61 = icmp sgt i32 %clus2, 0
  br i1 %cmp5.61, label %for.body.6.lr.ph, label %if.end.exitStub

for.body.6.lr.ph:                                 ; preds = %for.cond.4.preheader
  %idx.ext = sext i32 %lag to i64
  br label %for.body.6

for.body.6:                                       ; preds = %for.body.6, %for.body.6.lr.ph
  %indvars.iv = phi i64 [ 0, %for.body.6.lr.ph ], [ %indvars.iv.next, %for.body.6 ]
  %arrayidx8 = getelementptr inbounds i8*, i8** %seq2, i64 %indvars.iv
  %3 = load i8*, i8** %arrayidx8, align 8, !tbaa !0
  %add.ptr = getelementptr inbounds i8, i8* %3, i64 %idx.ext
  %arrayidx10 = getelementptr inbounds i8*, i8** %aseq2, i64 %indvars.iv
  store i8* %add.ptr, i8** %arrayidx10, align 8, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv85 = trunc i64 %indvars.iv.next to i32
  %exitcond86 = icmp eq i32 %lftr.wideiv85, %clus2
  br i1 %exitcond86, label %if.end.loopexit, label %for.body.6

if.end.loopexit:                                  ; preds = %for.body.6
  br label %if.end.exitStub

for.cond.14.preheader:                            ; preds = %entry.split
  br i1 %cmp1.63, label %for.body.16.lr.ph, label %for.cond.26.preheader

for.body.16.lr.ph:                                ; preds = %for.cond.14.preheader
  %idx.ext19 = sext i32 %lag to i64
  %idx.neg = sub nsw i64 0, %idx.ext19
  br label %for.body.16

for.body.16:                                      ; preds = %for.body.16, %for.body.16.lr.ph
  %indvars.iv78 = phi i64 [ 0, %for.body.16.lr.ph ], [ %indvars.iv.next79, %for.body.16 ]
  %arrayidx18 = getelementptr inbounds i8*, i8** %seq1, i64 %indvars.iv78
  %4 = load i8*, i8** %arrayidx18, align 8, !tbaa !0
  %add.ptr20 = getelementptr inbounds i8, i8* %4, i64 %idx.neg
  %arrayidx22 = getelementptr inbounds i8*, i8** %aseq1, i64 %indvars.iv78
  store i8* %add.ptr20, i8** %arrayidx22, align 8, !tbaa !0
  %indvars.iv.next79 = add nuw nsw i64 %indvars.iv78, 1
  %lftr.wideiv89 = trunc i64 %indvars.iv.next79 to i32
  %exitcond90 = icmp eq i32 %lftr.wideiv89, %clus1
  br i1 %exitcond90, label %for.cond.26.preheader.loopexit, label %for.body.16

for.cond.26.preheader.loopexit:                   ; preds = %for.body.16
  br label %for.cond.26.preheader

for.cond.26.preheader:                            ; preds = %for.cond.26.preheader.loopexit, %for.cond.14.preheader
  %cmp27.65 = icmp sgt i32 %clus2, 0
  br i1 %cmp27.65, label %for.body.28.preheader, label %if.end.exitStub

for.body.28.preheader:                            ; preds = %for.cond.26.preheader
  br label %for.body.28

for.body.28:                                      ; preds = %for.body.28, %for.body.28.preheader
  %indvars.iv74 = phi i64 [ %indvars.iv.next75, %for.body.28 ], [ 0, %for.body.28.preheader ]
  %arrayidx30 = getelementptr inbounds i8*, i8** %seq2, i64 %indvars.iv74
  %5 = bitcast i8** %arrayidx30 to i64*
  %6 = load i64, i64* %5, align 8, !tbaa !0
  %arrayidx32 = getelementptr inbounds i8*, i8** %aseq2, i64 %indvars.iv74
  %7 = bitcast i8** %arrayidx32 to i64*
  store i64 %6, i64* %7, align 8, !tbaa !0
  %indvars.iv.next75 = add nuw nsw i64 %indvars.iv74, 1
  %lftr.wideiv87 = trunc i64 %indvars.iv.next75 to i32
  %exitcond88 = icmp eq i32 %lftr.wideiv87, %clus2
  br i1 %exitcond88, label %if.end.loopexit84, label %for.body.28

if.end.loopexit84:                                ; preds = %for.body.28
  br label %if.end.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"any pointer", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
