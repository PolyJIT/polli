
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'libavfilter/avf_showcqt.c.plot_cqt_for.body.399.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @plot_cqt_for.body.399.pjit.scop(i64, float %div403, i64, i8*, [1920 x [4 x float]]* %result, [1920 x float]* %rcp_result, i64, i64)  {
newFuncRoot:
  br label %for.body.399

for.end.453.exitStub:                             ; preds = %for.end.450
  ret void

for.body.399:                                     ; preds = %for.end.450, %newFuncRoot
  %indvars.iv75 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next76, %for.end.450 ]
  %5 = sub nsw i64 %0, %indvars.iv75
  %6 = trunc i64 %5 to i32
  %conv401 = sitofp i32 %6 to float
  %mul404 = fmul nsz float %div403, %conv401
  %7 = mul nsw i64 %indvars.iv75, %1
  %add.ptr = getelementptr inbounds i8, i8* %2, i64 %7
  br label %for.body.409

for.body.409:                                     ; preds = %if.end.447, %for.body.399
  %indvars.iv73 = phi i64 [ 0, %for.body.399 ], [ %indvars.iv.next74, %if.end.447 ]
  %lineptr.013 = phi i8* [ %add.ptr, %for.body.399 ], [ %lineptr.1, %if.end.447 ]
  %arrayidx413 = getelementptr inbounds [1920 x [4 x float]], [1920 x [4 x float]]* %result, i64 0, i64 %indvars.iv73, i64 3
  %8 = load float, float* %arrayidx413, align 4, !tbaa !0
  %cmp414 = fcmp nsz ugt float %8, %mul404
  br i1 %cmp414, label %if.else, label %if.then.416

if.else:                                          ; preds = %for.body.409
  %sub422 = fsub nsz float %8, %mul404
  %arrayidx424 = getelementptr inbounds [1920 x float], [1920 x float]* %rcp_result, i64 0, i64 %indvars.iv73
  %9 = load float, float* %arrayidx424, align 4, !tbaa !0
  %mul425 = fmul nsz float %sub422, %9
  %arrayidx428 = getelementptr inbounds [1920 x [4 x float]], [1920 x [4 x float]]* %result, i64 0, i64 %indvars.iv73, i64 0
  %10 = load float, float* %arrayidx428, align 16, !tbaa !0
  %mul429 = fmul nsz float %mul425, %10
  %add430 = fadd nsz float %mul429, 5.000000e-01
  %conv431 = fptoui float %add430 to i8
  %incdec.ptr432 = getelementptr inbounds i8, i8* %lineptr.013, i64 1
  store i8 %conv431, i8* %lineptr.013, align 1, !tbaa !4
  %arrayidx435 = getelementptr inbounds [1920 x [4 x float]], [1920 x [4 x float]]* %result, i64 0, i64 %indvars.iv73, i64 1
  %11 = load float, float* %arrayidx435, align 4, !tbaa !0
  %mul436 = fmul nsz float %mul425, %11
  %add437 = fadd nsz float %mul436, 5.000000e-01
  %conv438 = fptoui float %add437 to i8
  %incdec.ptr439 = getelementptr inbounds i8, i8* %lineptr.013, i64 2
  store i8 %conv438, i8* %incdec.ptr432, align 1, !tbaa !4
  %arrayidx442 = getelementptr inbounds [1920 x [4 x float]], [1920 x [4 x float]]* %result, i64 0, i64 %indvars.iv73, i64 2
  %12 = load float, float* %arrayidx442, align 8, !tbaa !0
  %mul443 = fmul nsz float %mul425, %12
  %add444 = fadd nsz float %mul443, 5.000000e-01
  %conv445 = fptoui float %add444 to i8
  store i8 %conv445, i8* %incdec.ptr439, align 1, !tbaa !4
  br label %if.end.447

if.end.447:                                       ; preds = %if.then.416, %if.else
  %lineptr.1 = getelementptr inbounds i8, i8* %lineptr.013, i64 3
  %indvars.iv.next74 = add nuw nsw i64 %indvars.iv73, 1
  %cmp407 = icmp slt i64 %indvars.iv.next74, %3
  br i1 %cmp407, label %for.body.409, label %for.end.450

for.end.450:                                      ; preds = %if.end.447
  %indvars.iv.next76 = add nuw nsw i64 %indvars.iv75, 1
  %cmp397 = icmp sgt i64 %4, %indvars.iv.next76
  br i1 %cmp397, label %for.body.399, label %for.end.453.exitStub

if.then.416:                                      ; preds = %for.body.409
  %incdec.ptr = getelementptr inbounds i8, i8* %lineptr.013, i64 1
  store i8 0, i8* %lineptr.013, align 1, !tbaa !4
  %incdec.ptr417 = getelementptr inbounds i8, i8* %lineptr.013, i64 2
  store i8 0, i8* %incdec.ptr, align 1, !tbaa !4
  store i8 0, i8* %incdec.ptr417, align 1, !tbaa !4
  br label %if.end.447
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!2, !2, i64 0}
