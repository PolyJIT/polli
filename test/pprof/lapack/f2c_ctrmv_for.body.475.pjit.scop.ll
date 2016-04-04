
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polli-process-unprofitable -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'ctrmv.c.f2c_ctrmv_for.body.475.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.complex = type { float, float }

; Function Attrs: nounwind
define weak void @f2c_ctrmv_for.body.475.pjit.scop(i64, %struct.complex* %incdec.ptr, i1 %tobool484, i64, %struct.complex* %add.ptr, float* %r530, float* %i542)  {
newFuncRoot:
  br label %for.body.475

cleanup.loopexit2035.exitStub:                    ; preds = %if.end.627
  ret void

for.body.475:                                     ; preds = %if.end.627, %newFuncRoot
  %j.41909 = phi i64 [ %dec635, %if.end.627 ], [ %0, %newFuncRoot ]
  %arrayidx476 = getelementptr inbounds %struct.complex, %struct.complex* %incdec.ptr, i64 %j.41909
  %r477 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx476, i64 0, i32 0
  %2 = load float, float* %r477, align 4, !tbaa !0
  %i480 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx476, i64 0, i32 1
  %3 = load float, float* %i480, align 4, !tbaa !5
  br i1 %tobool484, label %if.then.485, label %for.cond.514.preheader

if.then.485:                                      ; preds = %for.body.475
  %mul486 = mul nsw i64 %j.41909, %1
  %add487 = add nsw i64 %mul486, %j.41909
  %arrayidx489 = getelementptr inbounds %struct.complex, %struct.complex* %add.ptr, i64 %add487
  %r490 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx489, i64 0, i32 0
  %4 = load float, float* %r490, align 4, !tbaa !0
  %mul491 = fmul float %2, %4
  %i494 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx489, i64 0, i32 1
  %5 = load float, float* %i494, align 4, !tbaa !5
  %mul495 = fmul float %3, %5
  %sub496 = fsub float %mul491, %mul495
  %mul501 = fmul float %2, %5
  %mul505 = fmul float %3, %4
  %add506 = fadd float %mul505, %mul501
  br label %for.cond.514.preheader

for.cond.514.preheader:                           ; preds = %if.then.485, %for.body.475
  %temp.sroa.62.1.ph = phi float [ %3, %for.body.475 ], [ %add506, %if.then.485 ]
  %temp.sroa.0.1.ph = phi float [ %2, %for.body.475 ], [ %sub496, %if.then.485 ]
  %cmp515.1896 = icmp sgt i64 %j.41909, 1
  br i1 %cmp515.1896, label %for.body.516.lr.ph, label %if.end.627

for.body.516.lr.ph:                               ; preds = %for.cond.514.preheader
  %mul517 = mul nsw i64 %j.41909, %1
  br label %for.body.516

for.body.516:                                     ; preds = %for.body.516, %for.body.516.lr.ph
  %i__.41899.in = phi i64 [ %j.41909, %for.body.516.lr.ph ], [ %i__.41899, %for.body.516 ]
  %temp.sroa.0.11898 = phi float [ %temp.sroa.0.1.ph, %for.body.516.lr.ph ], [ %add545, %for.body.516 ]
  %temp.sroa.62.11897 = phi float [ %temp.sroa.62.1.ph, %for.body.516.lr.ph ], [ %add549, %for.body.516 ]
  %i__.41899 = add nsw i64 %i__.41899.in, -1
  %add518 = add nsw i64 %i__.41899, %mul517
  %arrayidx519 = getelementptr inbounds %struct.complex, %struct.complex* %add.ptr, i64 %add518
  %r520 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx519, i64 0, i32 0
  %6 = load float, float* %r520, align 4, !tbaa !0
  %arrayidx521 = getelementptr inbounds %struct.complex, %struct.complex* %incdec.ptr, i64 %i__.41899
  %r522 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx521, i64 0, i32 0
  %7 = load float, float* %r522, align 4, !tbaa !0
  %mul523 = fmul float %6, %7
  %i525 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx519, i64 0, i32 1
  %8 = load float, float* %i525, align 4, !tbaa !5
  %i527 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx521, i64 0, i32 1
  %9 = load float, float* %i527, align 4, !tbaa !5
  %mul528 = fmul float %8, %9
  %sub529 = fsub float %mul523, %mul528
  %10 = load float, float* %r520, align 4, !tbaa !0
  %mul535 = fmul float %9, %10
  %11 = load float, float* %i525, align 4, !tbaa !5
  %12 = load float, float* %r522, align 4, !tbaa !0
  %mul540 = fmul float %11, %12
  %add541 = fadd float %mul535, %mul540
  %add545 = fadd float %temp.sroa.0.11898, %sub529
  %add549 = fadd float %temp.sroa.62.11897, %add541
  %cmp515 = icmp sgt i64 %i__.41899, 1
  br i1 %cmp515, label %for.body.516, label %for.cond.514.if.end.627.loopexit1884_crit_edge

for.cond.514.if.end.627.loopexit1884_crit_edge:   ; preds = %for.body.516
  %add549.lcssa = phi float [ %add549, %for.body.516 ]
  %add545.lcssa = phi float [ %add545, %for.body.516 ]
  %add541.lcssa = phi float [ %add541, %for.body.516 ]
  %sub529.lcssa = phi float [ %sub529, %for.body.516 ]
  store float %sub529.lcssa, float* %r530, align 4, !tbaa !0
  store float %add541.lcssa, float* %i542, align 4, !tbaa !5
  br label %if.end.627

if.end.627:                                       ; preds = %for.cond.514.if.end.627.loopexit1884_crit_edge, %for.cond.514.preheader
  %temp.sroa.0.1.lcssa = phi float [ %add545.lcssa, %for.cond.514.if.end.627.loopexit1884_crit_edge ], [ %temp.sroa.0.1.ph, %for.cond.514.preheader ]
  %temp.sroa.62.1.lcssa = phi float [ %add549.lcssa, %for.cond.514.if.end.627.loopexit1884_crit_edge ], [ %temp.sroa.62.1.ph, %for.cond.514.preheader ]
  store float %temp.sroa.0.1.lcssa, float* %r477, align 4, !tbaa !0
  store float %temp.sroa.62.1.lcssa, float* %i480, align 4, !tbaa !5
  %dec635 = add nsw i64 %j.41909, -1
  %cmp474 = icmp sgt i64 %j.41909, 1
  br i1 %cmp474, label %for.body.475, label %cleanup.loopexit2035.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 0}
!1 = !{!"", !2, i64 0, !2, i64 4}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!1, !2, i64 4}
