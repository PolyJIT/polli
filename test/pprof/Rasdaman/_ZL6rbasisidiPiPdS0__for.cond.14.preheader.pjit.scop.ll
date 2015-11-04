
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'intronurbs.cpp._ZL6rbasisidiPiPdS0__for.cond.14.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZL6rbasisidiPiPdS0__for.cond.14.preheader.pjit.scop(i32 %c, double** %_M_start.i.i.i, i32 %npts, i32 %add, i32* %x, double %t)  {
newFuncRoot:
  br label %for.cond.14.preheader

for.end.79.exitStub:                              ; preds = %for.end.79.loopexit, %for.cond.14.preheader
  ret void

for.cond.14.preheader:                            ; preds = %newFuncRoot
  %cmp15.217 = icmp slt i32 %c, 2
  br i1 %cmp15.217, label %for.end.79.exitStub, label %for.cond.17.preheader.lr.ph

for.cond.17.preheader.lr.ph:                      ; preds = %for.cond.14.preheader
  %0 = load double*, double** %_M_start.i.i.i, align 8, !tbaa !0
  %1 = add i32 %npts, %c
  %2 = sext i32 %add to i64
  %3 = add i32 %c, 1
  %4 = add i32 %1, -1
  br label %for.cond.17.preheader

for.cond.17.preheader:                            ; preds = %for.inc.77, %for.cond.17.preheader.lr.ph
  %indvars.iv246 = phi i32 [ %indvars.iv.next247, %for.inc.77 ], [ %4, %for.cond.17.preheader.lr.ph ]
  %indvars.iv233 = phi i64 [ %indvars.iv.next234, %for.inc.77 ], [ 2, %for.cond.17.preheader.lr.ph ]
  %cmp19.215 = icmp sgt i64 %2, %indvars.iv233
  br i1 %cmp19.215, label %for.body.20.lr.ph, label %for.inc.77

for.body.20.lr.ph:                                ; preds = %for.cond.17.preheader
  %5 = add nuw nsw i64 %indvars.iv233, 4294967295
  br label %for.body.20

for.body.20:                                      ; preds = %if.end.69, %for.body.20.lr.ph
  %indvars.iv226 = phi i64 [ %indvars.iv.next227, %if.end.69 ], [ 1, %for.body.20.lr.ph ]
  %add.ptr.i.209 = getelementptr inbounds double, double* %0, i64 %indvars.iv226
  %6 = load double, double* %add.ptr.i.209, align 8, !tbaa !6
  %cmp24 = fcmp une double %6, 0.000000e+00
  br i1 %cmp24, label %if.then.25, label %if.end.42

if.then.25:                                       ; preds = %for.body.20
  %arrayidx27 = getelementptr inbounds i32, i32* %x, i64 %indvars.iv226
  %7 = load i32, i32* %arrayidx27, align 4, !tbaa !8
  %conv28 = sitofp i32 %7 to double
  %sub29 = fsub double %t, %conv28
  %mul = fmul double %6, %sub29
  %sub34 = add nuw nsw i64 %5, %indvars.iv226
  %sext = shl i64 %sub34, 32
  %idxprom35 = ashr exact i64 %sext, 32
  %arrayidx36 = getelementptr inbounds i32, i32* %x, i64 %idxprom35
  %8 = load i32, i32* %arrayidx36, align 4, !tbaa !8
  %sub39 = sub nsw i32 %8, %7
  %conv40 = sitofp i32 %sub39 to double
  %div = fdiv double %mul, %conv40
  br label %if.end.42

if.end.42:                                        ; preds = %if.then.25, %for.body.20
  %d.0 = phi double [ %div, %if.then.25 ], [ 0.000000e+00, %for.body.20 ]
  %indvars.iv.next227 = add nuw nsw i64 %indvars.iv226, 1
  %add.ptr.i.205 = getelementptr inbounds double, double* %0, i64 %indvars.iv.next227
  %9 = load double, double* %add.ptr.i.205, align 8, !tbaa !6
  %cmp47 = fcmp une double %9, 0.000000e+00
  br i1 %cmp47, label %if.then.48, label %if.end.69

if.then.48:                                       ; preds = %if.end.42
  %10 = add nuw nsw i64 %indvars.iv226, %indvars.iv233
  %arrayidx51 = getelementptr inbounds i32, i32* %x, i64 %10
  %11 = load i32, i32* %arrayidx51, align 4, !tbaa !8
  %conv52 = sitofp i32 %11 to double
  %sub53 = fsub double %conv52, %t
  %mul58 = fmul double %9, %sub53
  %arrayidx64 = getelementptr inbounds i32, i32* %x, i64 %indvars.iv.next227
  %12 = load i32, i32* %arrayidx64, align 4, !tbaa !8
  %sub65 = sub nsw i32 %11, %12
  %conv66 = sitofp i32 %sub65 to double
  %div67 = fdiv double %mul58, %conv66
  br label %if.end.69

if.end.69:                                        ; preds = %if.then.48, %if.end.42
  %e.0 = phi double [ %div67, %if.then.48 ], [ 0.000000e+00, %if.end.42 ]
  %add70 = fadd double %d.0, %e.0
  %add.ptr.i.201 = getelementptr inbounds double, double* %0, i64 %indvars.iv226
  store double %add70, double* %add.ptr.i.201, align 8, !tbaa !6
  %lftr.wideiv248 = trunc i64 %indvars.iv.next227 to i32
  %exitcond249 = icmp eq i32 %lftr.wideiv248, %indvars.iv246
  br i1 %exitcond249, label %for.inc.77.loopexit, label %for.body.20

for.inc.77.loopexit:                              ; preds = %if.end.69
  br label %for.inc.77

for.inc.77:                                       ; preds = %for.inc.77.loopexit, %for.cond.17.preheader
  %indvars.iv.next234 = add nuw nsw i64 %indvars.iv233, 1
  %indvars.iv.next247 = add i32 %indvars.iv246, -1
  %lftr.wideiv250 = trunc i64 %indvars.iv.next234 to i32
  %exitcond251 = icmp eq i32 %lftr.wideiv250, %3
  br i1 %exitcond251, label %for.end.79.loopexit, label %for.cond.17.preheader

for.end.79.loopexit:                              ; preds = %for.inc.77
  br label %for.end.79.exitStub
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !3, i64 0}
!1 = !{!"_ZTSSt12_Vector_baseIdSaIdEE", !2, i64 0}
!2 = !{!"_ZTSNSt12_Vector_baseIdSaIdEE12_Vector_implE", !3, i64 0, !3, i64 8, !3, i64 16}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"double", !4, i64 0}
!8 = !{!9, !9, i64 0}
!9 = !{!"int", !4, i64 0}
