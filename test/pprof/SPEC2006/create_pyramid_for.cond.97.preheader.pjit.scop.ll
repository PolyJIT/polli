
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polli-process-unprofitable -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/464.h264ref/src/explicit_gop.c.create_pyramid_for.cond.97.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.GOP_DATA = type { i32, i32, i32, i32, i32, i32 }

; Function Attrs: nounwind
define weak void @create_pyramid_for.cond.97.preheader.pjit.scop(i32, %struct.GOP_DATA*)  {
newFuncRoot:
  br label %for.cond.97.preheader

if.end.200.exitStub:                              ; preds = %if.end.200.loopexit319
  ret void

for.cond.97.preheader:                            ; preds = %for.inc.197, %newFuncRoot
  %indvars.iv320 = phi i32 [ %0, %newFuncRoot ], [ %indvars.iv.next321, %for.inc.197 ]
  %cmp98.291 = icmp sgt i32 %indvars.iv320, 1
  br i1 %cmp98.291, label %for.body.100.preheader, label %for.inc.197

for.body.100.preheader:                           ; preds = %for.cond.97.preheader
  br label %for.body.100

for.body.100:                                     ; preds = %if.end.193, %for.body.100.preheader
  %indvars.iv309 = phi i64 [ %indvars.iv.next310, %if.end.193 ], [ 1, %for.body.100.preheader ]
  %pyramid_layer103 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 4
  %2 = load i32, i32* %pyramid_layer103, align 4, !tbaa !0
  %3 = add nsw i64 %indvars.iv309, -1
  %pyramid_layer107 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %3, i32 4
  %4 = load i32, i32* %pyramid_layer107, align 4, !tbaa !0
  %cmp108 = icmp sgt i32 %2, %4
  br i1 %cmp108, label %if.then.110, label %if.end.193

if.then.110:                                      ; preds = %for.body.100
  %display_no114 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %3, i32 1
  %5 = load i32, i32* %display_no114, align 4, !tbaa !5
  %display_no117 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 1
  %6 = load i32, i32* %display_no117, align 4, !tbaa !5
  store i32 %6, i32* %display_no114, align 4, !tbaa !5
  %display_no124 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 1
  store i32 %5, i32* %display_no124, align 4, !tbaa !5
  %pyramid_layer128 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %3, i32 4
  %7 = load i32, i32* %pyramid_layer128, align 4, !tbaa !0
  %pyramid_layer131 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 4
  %8 = load i32, i32* %pyramid_layer131, align 4, !tbaa !0
  store i32 %8, i32* %pyramid_layer128, align 4, !tbaa !0
  %pyramid_layer138 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 4
  store i32 %7, i32* %pyramid_layer138, align 4, !tbaa !0
  %reference_idc142 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %3, i32 2
  %9 = load i32, i32* %reference_idc142, align 4, !tbaa !6
  %reference_idc145 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 2
  %10 = load i32, i32* %reference_idc145, align 4, !tbaa !6
  store i32 %10, i32* %reference_idc142, align 4, !tbaa !6
  %reference_idc152 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 2
  store i32 %9, i32* %reference_idc152, align 4, !tbaa !6
  %slice_type156 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %3, i32 0
  %11 = load i32, i32* %slice_type156, align 4, !tbaa !7
  %slice_type159 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 0
  %12 = load i32, i32* %slice_type159, align 4, !tbaa !7
  store i32 %12, i32* %slice_type156, align 4, !tbaa !7
  %slice_type166 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 0
  store i32 %11, i32* %slice_type166, align 4, !tbaa !7
  %slice_qp = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %3, i32 3
  %13 = load i32, i32* %slice_qp, align 4, !tbaa !8
  %slice_qp172 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 3
  %14 = load i32, i32* %slice_qp172, align 4, !tbaa !8
  store i32 %14, i32* %slice_qp, align 4, !tbaa !8
  %slice_qp179 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 3
  store i32 %13, i32* %slice_qp179, align 4, !tbaa !8
  %pyramidPocDelta = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %3, i32 5
  %15 = load i32, i32* %pyramidPocDelta, align 4, !tbaa !9
  %pyramidPocDelta185 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 5
  %16 = load i32, i32* %pyramidPocDelta185, align 4, !tbaa !9
  store i32 %16, i32* %pyramidPocDelta, align 4, !tbaa !9
  %pyramidPocDelta192 = getelementptr inbounds %struct.GOP_DATA, %struct.GOP_DATA* %1, i64 %indvars.iv309, i32 5
  store i32 %15, i32* %pyramidPocDelta192, align 4, !tbaa !9
  br label %if.end.193

if.end.193:                                       ; preds = %if.then.110, %for.body.100
  %indvars.iv.next310 = add nuw nsw i64 %indvars.iv309, 1
  %lftr.wideiv322 = trunc i64 %indvars.iv.next310 to i32
  %exitcond323 = icmp eq i32 %lftr.wideiv322, %indvars.iv320
  br i1 %exitcond323, label %for.inc.197.loopexit, label %for.body.100

for.inc.197.loopexit:                             ; preds = %if.end.193
  br label %for.inc.197

for.inc.197:                                      ; preds = %for.inc.197.loopexit, %for.cond.97.preheader
  %indvars.iv.next321 = add nsw i32 %indvars.iv320, -1
  %cmp94 = icmp sgt i32 %indvars.iv320, 1
  br i1 %cmp94, label %for.cond.97.preheader, label %if.end.200.loopexit319

if.end.200.loopexit319:                           ; preds = %for.inc.197
  br label %if.end.200.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 16}
!1 = !{!"", !2, i64 0, !2, i64 4, !2, i64 8, !2, i64 12, !2, i64 16, !2, i64 20}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!1, !2, i64 4}
!6 = !{!1, !2, i64 8}
!7 = !{!1, !2, i64 0}
!8 = !{!1, !2, i64 12}
!9 = !{!1, !2, i64 20}
