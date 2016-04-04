
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/JM/ldecod/mbuffer.c.dpb_combine_field_for.cond.4.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.storable_picture = type { i32, i32, i32, i32, i32, [50 x [6 x [33 x i64]]], [50 x [6 x [33 x i64]]], [50 x [6 x [33 x i64]]], [50 x [6 x [33 x i64]]], i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16**, i16***, i8*, i16**, i8***, i64***, i64***, i16****, i8**, i8**, %struct.storable_picture*, %struct.storable_picture*, %struct.storable_picture*, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [2 x i32], i32, %struct.DecRefPicMarking_s*, i32 }
%struct.DecRefPicMarking_s = type { i32, i32, i32, i32, i32, %struct.DecRefPicMarking_s* }

; Function Attrs: nounwind
define weak void @dpb_combine_field_for.cond.4.preheader.pjit.scop(%struct.storable_picture*, %struct.storable_picture*, %struct.storable_picture*, i64)  {
newFuncRoot:
  br label %for.cond.4.preheader

for.cond.68.preheader.loopexit.exitStub:          ; preds = %for.inc.65
  ret void

for.cond.4.preheader:                             ; preds = %for.inc.65, %newFuncRoot
  %indvars.iv737 = phi i64 [ %indvars.iv.next738, %for.inc.65 ], [ 0, %newFuncRoot ]
  br label %for.body.7

for.body.7:                                       ; preds = %for.body.7, %for.cond.4.preheader
  %indvars.iv730 = phi i64 [ 0, %for.cond.4.preheader ], [ %indvars.iv.next731, %for.body.7 ]
  %4 = shl nsw i64 %indvars.iv730, 1
  %arrayidx11 = getelementptr inbounds %struct.storable_picture, %struct.storable_picture* %0, i64 0, i32 5, i64 %indvars.iv737, i64 1, i64 %4
  %5 = load i64, i64* %arrayidx11, align 8, !tbaa !0
  %div = sdiv i64 %5, 2
  %mul12 = shl nsw i64 %div, 1
  %arrayidx20 = getelementptr inbounds %struct.storable_picture, %struct.storable_picture* %1, i64 0, i32 5, i64 %indvars.iv737, i64 1, i64 %4
  %6 = load i64, i64* %arrayidx20, align 8, !tbaa !0
  %div21 = sdiv i64 %6, 2
  %mul22 = shl nsw i64 %div21, 1
  %cmp.i.707 = icmp slt i64 %mul12, %mul22
  %cond.i.708 = select i1 %cmp.i.707, i64 %mul12, i64 %mul22
  %arrayidx29 = getelementptr inbounds %struct.storable_picture, %struct.storable_picture* %2, i64 0, i32 5, i64 %indvars.iv737, i64 1, i64 %indvars.iv730
  store i64 %cond.i.708, i64* %arrayidx29, align 8, !tbaa !0
  %indvars.iv.next731 = add nuw nsw i64 %indvars.iv730, 1
  %exitcond = icmp eq i64 %indvars.iv.next731, 16
  br i1 %exitcond, label %for.body.33.preheader, label %for.body.7

for.body.33.preheader:                            ; preds = %for.body.7
  br label %for.body.33

for.body.33:                                      ; preds = %for.body.33, %for.body.33.preheader
  %indvars.iv733 = phi i64 [ %indvars.iv.next734, %for.body.33 ], [ 0, %for.body.33.preheader ]
  %7 = shl nsw i64 %indvars.iv733, 1
  %arrayidx41 = getelementptr inbounds %struct.storable_picture, %struct.storable_picture* %0, i64 0, i32 5, i64 %indvars.iv737, i64 0, i64 %7
  %8 = load i64, i64* %arrayidx41, align 8, !tbaa !0
  %div42 = sdiv i64 %8, 2
  %mul43 = shl nsw i64 %div42, 1
  %arrayidx51 = getelementptr inbounds %struct.storable_picture, %struct.storable_picture* %1, i64 0, i32 5, i64 %indvars.iv737, i64 0, i64 %7
  %9 = load i64, i64* %arrayidx51, align 8, !tbaa !0
  %div52 = sdiv i64 %9, 2
  %mul53 = shl nsw i64 %div52, 1
  %cmp.i.705 = icmp slt i64 %mul43, %mul53
  %cond.i.706 = select i1 %cmp.i.705, i64 %mul43, i64 %mul53
  %arrayidx61 = getelementptr inbounds %struct.storable_picture, %struct.storable_picture* %2, i64 0, i32 5, i64 %indvars.iv737, i64 0, i64 %indvars.iv733
  store i64 %cond.i.706, i64* %arrayidx61, align 8, !tbaa !0
  %indvars.iv.next734 = add nuw nsw i64 %indvars.iv733, 1
  %exitcond736 = icmp eq i64 %indvars.iv.next734, 16
  br i1 %exitcond736, label %for.inc.65, label %for.body.33

for.inc.65:                                       ; preds = %for.body.33
  %indvars.iv.next738 = add nuw nsw i64 %indvars.iv737, 1
  %cmp = icmp slt i64 %indvars.iv737, %3
  br i1 %cmp, label %for.cond.4.preheader, label %for.cond.68.preheader.loopexit.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"long long", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
