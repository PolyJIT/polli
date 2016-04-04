
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/mediabench/gsm/toast/short_term.c.Gsm_Short_Term_Synthesis_Filter_while.body.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.gsm_state = type { [280 x i16], i16, i64, i32, [8 x i16], [2 x [8 x i16]], i16, i16, [9 x i16], i16, i8, i8 }

; Function Attrs: nounwind
define weak void @Gsm_Short_Term_Synthesis_Filter_while.body.i.pjit.scop(i16* %add.ptr23, i16* %add.ptr22, [8 x i16]* %LARp, %struct.gsm_state* %S, i16* %arraydecay.i.400)  {
newFuncRoot:
  br label %while.body.i

Short_term_synthesis_filtering.exit.exitStub:     ; preds = %for.end.i
  ret void

while.body.i:                                     ; preds = %for.end.i, %newFuncRoot
  %dec104.in.i = phi i32 [ %dec104.i, %for.end.i ], [ 120, %newFuncRoot ]
  %sr.addr.0103.i = phi i16* [ %incdec.ptr67.i, %for.end.i ], [ %add.ptr23, %newFuncRoot ]
  %wt.addr.0102.i = phi i16* [ %incdec.ptr.i.51, %for.end.i ], [ %add.ptr22, %newFuncRoot ]
  %0 = load i16, i16* %wt.addr.0102.i, align 2, !tbaa !0
  br label %for.body.i.46

for.body.i.46:                                    ; preds = %cond.end.43.i, %while.body.i
  %indvars.iv105.i = phi i64 [ 8, %while.body.i ], [ %indvars.iv.next106.i, %cond.end.43.i ]
  %indvars.iv.i = phi i64 [ 7, %while.body.i ], [ %indvars.iv.next.i, %cond.end.43.i ]
  %sri.098.i = phi i16 [ %0, %while.body.i ], [ %conv27.i, %cond.end.43.i ]
  %arrayidx.i = getelementptr inbounds [8 x i16], [8 x i16]* %LARp, i64 0, i64 %indvars.iv.i
  %1 = load i16, i16* %arrayidx.i, align 2, !tbaa !0
  %arrayidx5.i = getelementptr inbounds %struct.gsm_state, %struct.gsm_state* %S, i64 0, i32 8, i64 %indvars.iv.i
  %2 = load i16, i16* %arrayidx5.i, align 2, !tbaa !0
  %cmp.i = icmp eq i16 %1, -32768
  %cmp8.i = icmp eq i16 %2, -32768
  %or.cond.i = and i1 %cmp.i, %cmp8.i
  br i1 %or.cond.i, label %cond.end.i, label %cond.false.i

cond.end.i:                                       ; preds = %cond.false.i, %for.body.i.46
  %cond.i = phi i64 [ %and.i, %cond.false.i ], [ 32767, %for.body.i.46 ]
  %conv13.i.49 = sext i16 %sri.098.i to i64
  %sext.i = shl nuw i64 %cond.i, 48
  %conv14.i = ashr exact i64 %sext.i, 48
  %sub.i.50 = sub nsw i64 %conv13.i.49, %conv14.i
  %cmp15.i = icmp sgt i64 %sub.i.50, 32766
  %cmp19.i = icmp sgt i64 %sub.i.50, -32768
  %cond24.i = select i1 %cmp19.i, i64 %sub.i.50, i64 -32768
  %cond26.i = select i1 %cmp15.i, i64 32767, i64 %cond24.i
  %conv27.i = trunc i64 %cond26.i to i16
  %cmp33.i = icmp eq i16 %conv27.i, -32768
  %or.cond96.i = and i1 %cmp.i, %cmp33.i
  br i1 %or.cond96.i, label %cond.end.43.i, label %cond.false.36.i

cond.end.43.i:                                    ; preds = %cond.false.36.i, %cond.end.i
  %cond44.i = phi i64 [ %and42.i, %cond.false.36.i ], [ 32767, %cond.end.i ]
  %3 = load i16, i16* %arrayidx5.i, align 2, !tbaa !0
  %conv48.i = sext i16 %3 to i64
  %sext95.i = shl nuw i64 %cond44.i, 48
  %conv49.i = ashr exact i64 %sext95.i, 48
  %add50.i = add nsw i64 %conv48.i, %conv49.i
  %sub51.i = add nsw i64 %add50.i, 32768
  %cmp52.i = icmp ugt i64 %sub51.i, 65535
  %cmp55.i = icmp sgt i64 %add50.i, 0
  %conv58.i = select i1 %cmp55.i, i64 32767, i64 32768
  %cond61.i = select i1 %cmp52.i, i64 %conv58.i, i64 %add50.i
  %conv62.i = trunc i64 %cond61.i to i16
  %arrayidx65.i = getelementptr inbounds %struct.gsm_state, %struct.gsm_state* %S, i64 0, i32 8, i64 %indvars.iv105.i
  store i16 %conv62.i, i16* %arrayidx65.i, align 2, !tbaa !0
  %indvars.iv.next.i = add nsw i64 %indvars.iv.i, -1
  %tobool3.i = icmp eq i64 %indvars.iv.i, 0
  %indvars.iv.next106.i = add nsw i64 %indvars.iv105.i, -1
  br i1 %tobool3.i, label %for.end.i, label %for.body.i.46

for.end.i:                                        ; preds = %cond.end.43.i
  %conv27.i.lcssa = phi i16 [ %conv27.i, %cond.end.43.i ]
  %dec104.i = add nsw i32 %dec104.in.i, -1
  %incdec.ptr.i.51 = getelementptr inbounds i16, i16* %wt.addr.0102.i, i64 1
  store i16 %conv27.i.lcssa, i16* %arraydecay.i.400, align 2, !tbaa !0
  %incdec.ptr67.i = getelementptr inbounds i16, i16* %sr.addr.0103.i, i64 1
  store i16 %conv27.i.lcssa, i16* %sr.addr.0103.i, align 2, !tbaa !0
  %tobool.i = icmp eq i32 %dec104.i, 0
  br i1 %tobool.i, label %Short_term_synthesis_filtering.exit.exitStub, label %while.body.i

cond.false.36.i:                                  ; preds = %cond.end.i
  %conv37.i = sext i16 %1 to i64
  %sext93.i = shl i64 %cond26.i, 48
  %conv38.i = ashr exact i64 %sext93.i, 48
  %mul39.i = mul nsw i64 %conv38.i, %conv37.i
  %add40.i = add nsw i64 %mul39.i, 16384
  %shr41.94.i = lshr i64 %add40.i, 15
  %and42.i = and i64 %shr41.94.i, 65535
  br label %cond.end.43.i

cond.false.i:                                     ; preds = %for.body.i.46
  %conv10.i = sext i16 %1 to i64
  %conv11.i.47 = sext i16 %2 to i64
  %mul.i = mul nsw i64 %conv11.i.47, %conv10.i
  %add.i.48 = add nsw i64 %mul.i, 16384
  %shr.92.i = lshr i64 %add.i.48, 15
  %and.i = and i64 %shr.92.i, 65535
  br label %cond.end.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"short", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
