
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'gdalgeoloc.cpp.GDALCreateGeoLocTransformer_for.cond.42.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @GDALCreateGeoLocTransformer_for.cond.42.preheader.i.pjit.scop(i1 %cmp43.161.i, double*, i64 %conv.i.218, double**, i32 %call.i.217, i32 %call3.call2.i)  {
newFuncRoot:
  br label %for.cond.42.preheader.i

if.end.55.i.loopexit.exitStub:                    ; preds = %for.inc.52.i
  ret void

for.cond.42.preheader.i:                          ; preds = %for.inc.52.i, %newFuncRoot
  %indvars.iv169.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next170.i, %for.inc.52.i ]
  br i1 %cmp43.161.i, label %for.body.44.lr.ph.i, label %for.inc.52.i

for.body.44.lr.ph.i:                              ; preds = %for.cond.42.preheader.i
  %arrayidx.i = getelementptr inbounds double, double* %0, i64 %indvars.iv169.i
  %2 = bitcast double* %arrayidx.i to i64*
  %3 = mul nsw i64 %indvars.iv169.i, %conv.i.218
  %4 = load double*, double** %1, align 8, !tbaa !0
  br label %for.body.44.i

for.body.44.i:                                    ; preds = %for.body.44.i, %for.body.44.lr.ph.i
  %indvars.iv.i = phi i64 [ 0, %for.body.44.lr.ph.i ], [ %indvars.iv.next.i, %for.body.44.i ]
  %5 = load i64, i64* %2, align 8, !tbaa !8
  %6 = add nsw i64 %indvars.iv.i, %3
  %arrayidx48.i = getelementptr inbounds double, double* %4, i64 %6
  %7 = bitcast double* %arrayidx48.i to i64*
  store i64 %5, i64* %7, align 8, !tbaa !8
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %lftr.wideiv280 = trunc i64 %indvars.iv.next.i to i32
  %exitcond281 = icmp eq i32 %lftr.wideiv280, %call.i.217
  br i1 %exitcond281, label %for.inc.52.i.loopexit, label %for.body.44.i

for.inc.52.i.loopexit:                            ; preds = %for.body.44.i
  br label %for.inc.52.i

for.inc.52.i:                                     ; preds = %for.inc.52.i.loopexit, %for.cond.42.preheader.i
  %indvars.iv.next170.i = add nuw nsw i64 %indvars.iv169.i, 1
  %lftr.wideiv282 = trunc i64 %indvars.iv.next170.i to i32
  %exitcond283 = icmp eq i32 %lftr.wideiv282, %call3.call2.i
  br i1 %exitcond283, label %if.end.55.i.loopexit.exitStub, label %for.cond.42.preheader.i
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !5, i64 176}
!1 = !{!"_ZTS23GDALGeoLocTransformInfo", !2, i64 0, !6, i64 48, !6, i64 52, !6, i64 56, !3, i64 64, !5, i64 112, !5, i64 120, !5, i64 128, !5, i64 136, !5, i64 144, !5, i64 152, !6, i64 160, !6, i64 164, !5, i64 168, !5, i64 176, !6, i64 184, !7, i64 192, !7, i64 200, !7, i64 208, !7, i64 216, !7, i64 224, !5, i64 232}
!2 = !{!"_ZTS19GDALTransformerInfo", !3, i64 0, !5, i64 8, !5, i64 16, !5, i64 24, !5, i64 32, !5, i64 40}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!"any pointer", !3, i64 0}
!6 = !{!"int", !3, i64 0}
!7 = !{!"double", !3, i64 0}
!8 = !{!7, !7, i64 0}
