
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'gdalwarpkernel.cpp._ZL14GWKGetPixelRowP14GDALWarpKerneliiiPdS1_S1__if.end.442.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.GDALWarpKernel = type { i32 (...)**, i8**, i32, i32, i32, i32, i32, i32, i32, i8**, i32**, i32*, float*, i32, i32, i8**, i32*, float*, double, double, double, double, i32, i32, i32, i32, i32, i32, i32, i32, i32 (i8*, i32, i32, double*, double*, double*, i32*)*, i8*, i32 (double, i8*, i8*)*, i8*, double, double, double*, i8* }

; Function Attrs: nounwind
define weak void @_ZL14GWKGetPixelRowP14GDALWarpKerneliiiPdS1_S1__if.end.442.pjit.scop(%class.GDALWarpKernel* %poWK, i32 %nHalfSrcLen, i32 %mul, double* %padfDensity, i32 %iSrcOffset, i32* %bHasValid.10.lcssa.out, i32* %bHasValid.13.lcssa.out)  {
newFuncRoot:
  br label %if.end.442

cleanup.exitStub:                                 ; preds = %cleanup.loopexit923, %for.cond.468.preheader, %cleanup.loopexit, %for.cond.445.preheader
  store i32 %bHasValid.10.lcssa, i32* %bHasValid.10.lcssa.out
  store i32 %bHasValid.13.lcssa, i32* %bHasValid.13.lcssa.out
  ret void

if.end.442:                                       ; preds = %newFuncRoot
  %pafUnifiedSrcDensity = getelementptr inbounds %class.GDALWarpKernel, %class.GDALWarpKernel* %poWK, i64 0, i32 12
  %0 = load float*, float** %pafUnifiedSrcDensity, align 8, !tbaa !0
  %cmp443 = icmp eq float* %0, null
  %cmp446.806 = icmp sgt i32 %nHalfSrcLen, 0
  br i1 %cmp443, label %for.cond.445.preheader, label %for.cond.468.preheader

for.cond.445.preheader:                           ; preds = %if.end.442
  br i1 %cmp446.806, label %for.body.447.preheader, label %cleanup.exitStub

for.body.447.preheader:                           ; preds = %for.cond.445.preheader
  %1 = sext i32 %mul to i64
  br label %for.body.447

for.body.447:                                     ; preds = %for.inc.464, %for.body.447.preheader
  %indvars.iv = phi i64 [ 0, %for.body.447.preheader ], [ %indvars.iv.next, %for.inc.464 ]
  %bHasValid.8807 = phi i32 [ 0, %for.body.447.preheader ], [ %bHasValid.10, %for.inc.464 ]
  %arrayidx449 = getelementptr inbounds double, double* %padfDensity, i64 %indvars.iv
  %2 = load double, double* %arrayidx449, align 8, !tbaa !9
  %cmp450 = fcmp ogt double %2, 1.000000e-09
  br i1 %cmp450, label %if.then.451, label %if.end.454

if.then.451:                                      ; preds = %for.body.447
  store double 1.000000e+00, double* %arrayidx449, align 8, !tbaa !9
  br label %if.end.454

if.end.454:                                       ; preds = %if.then.451, %for.body.447
  %bHasValid.9 = phi i32 [ 1, %if.then.451 ], [ %bHasValid.8807, %for.body.447 ]
  %3 = or i64 %indvars.iv, 1
  %arrayidx457 = getelementptr inbounds double, double* %padfDensity, i64 %3
  %4 = load double, double* %arrayidx457, align 8, !tbaa !9
  %cmp458 = fcmp ogt double %4, 1.000000e-09
  br i1 %cmp458, label %if.then.459, label %for.inc.464

if.then.459:                                      ; preds = %if.end.454
  store double 1.000000e+00, double* %arrayidx457, align 8, !tbaa !9
  br label %for.inc.464

for.inc.464:                                      ; preds = %if.then.459, %if.end.454
  %bHasValid.10 = phi i32 [ 1, %if.then.459 ], [ %bHasValid.9, %if.end.454 ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 2
  %cmp446 = icmp slt i64 %indvars.iv.next, %1
  br i1 %cmp446, label %for.body.447, label %cleanup.loopexit

cleanup.loopexit:                                 ; preds = %for.inc.464
  %bHasValid.10.lcssa = phi i32 [ %bHasValid.10, %for.inc.464 ]
  br label %cleanup.exitStub

for.cond.468.preheader:                           ; preds = %if.end.442
  br i1 %cmp446.806, label %for.body.470.lr.ph, label %cleanup.exitStub

for.body.470.lr.ph:                               ; preds = %for.cond.468.preheader
  %add493 = add i32 %iSrcOffset, 1
  %5 = sext i32 %iSrcOffset to i64
  %6 = sext i32 %mul to i64
  br label %for.body.470

for.body.470:                                     ; preds = %if.end.502, %for.body.470.lr.ph
  %indvars.iv857 = phi i64 [ 0, %for.body.470.lr.ph ], [ %indvars.iv.next858, %if.end.502 ]
  %bHasValid.11810 = phi i32 [ 0, %for.body.470.lr.ph ], [ %bHasValid.13, %if.end.502 ]
  %arrayidx472 = getelementptr inbounds double, double* %padfDensity, i64 %indvars.iv857
  %7 = load double, double* %arrayidx472, align 8, !tbaa !9
  %cmp473 = fcmp ogt double %7, 1.000000e-09
  br i1 %cmp473, label %if.then.474, label %if.end.482

if.then.474:                                      ; preds = %for.body.470
  %8 = add nsw i64 %indvars.iv857, %5
  %9 = load float*, float** %pafUnifiedSrcDensity, align 8, !tbaa !0
  %arrayidx478 = getelementptr inbounds float, float* %9, i64 %8
  %10 = load float, float* %arrayidx478, align 4, !tbaa !10
  %conv479 = fpext float %10 to double
  store double %conv479, double* %arrayidx472, align 8, !tbaa !9
  br label %if.end.482

if.end.482:                                       ; preds = %if.then.474, %for.body.470
  %11 = load double, double* %arrayidx472, align 8, !tbaa !9
  %cmp485 = fcmp ogt double %11, 1.000000e-09
  %12 = or i64 %indvars.iv857, 1
  %arrayidx490 = getelementptr inbounds double, double* %padfDensity, i64 %12
  %13 = load double, double* %arrayidx490, align 8, !tbaa !9
  %cmp491 = fcmp ogt double %13, 1.000000e-09
  br i1 %cmp491, label %if.then.492, label %if.end.502

if.then.492:                                      ; preds = %if.end.482
  %14 = trunc i64 %indvars.iv857 to i32
  %add494 = add i32 %add493, %14
  %idxprom495 = sext i32 %add494 to i64
  %15 = load float*, float** %pafUnifiedSrcDensity, align 8, !tbaa !0
  %arrayidx497 = getelementptr inbounds float, float* %15, i64 %idxprom495
  %16 = load float, float* %arrayidx497, align 4, !tbaa !10
  %conv498 = fpext float %16 to double
  store double %conv498, double* %arrayidx490, align 8, !tbaa !9
  br label %if.end.502

if.end.502:                                       ; preds = %if.then.492, %if.end.482
  %17 = load double, double* %arrayidx490, align 8, !tbaa !9
  %cmp506 = fcmp ogt double %17, 1.000000e-09
  %18 = or i1 %cmp485, %cmp506
  %bHasValid.13 = select i1 %18, i32 1, i32 %bHasValid.11810
  %indvars.iv.next858 = add nuw nsw i64 %indvars.iv857, 2
  %cmp469 = icmp slt i64 %indvars.iv.next858, %6
  br i1 %cmp469, label %for.body.470, label %cleanup.loopexit923

cleanup.loopexit923:                              ; preds = %if.end.502
  %bHasValid.13.lcssa = phi i32 [ %bHasValid.13, %if.end.502 ]
  br label %cleanup.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 72}
!1 = !{!"_ZTS14GDALWarpKernel", !2, i64 8, !5, i64 16, !6, i64 20, !7, i64 24, !7, i64 28, !7, i64 32, !7, i64 36, !7, i64 40, !2, i64 48, !2, i64 56, !2, i64 64, !2, i64 72, !7, i64 80, !7, i64 84, !2, i64 88, !2, i64 96, !2, i64 104, !8, i64 112, !8, i64 120, !8, i64 128, !8, i64 136, !7, i64 144, !7, i64 148, !7, i64 152, !7, i64 156, !7, i64 160, !7, i64 164, !7, i64 168, !7, i64 172, !2, i64 176, !2, i64 184, !2, i64 192, !2, i64 200, !8, i64 208, !8, i64 216, !2, i64 224, !2, i64 232}
!2 = !{!"any pointer", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!"_ZTS15GDALResampleAlg", !3, i64 0}
!6 = !{!"_ZTS12GDALDataType", !3, i64 0}
!7 = !{!"int", !3, i64 0}
!8 = !{!"double", !3, i64 0}
!9 = !{!8, !8, i64 0}
!10 = !{!11, !11, i64 0}
!11 = !{!"float", !3, i64 0}
