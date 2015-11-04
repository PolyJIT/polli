
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/TSVC/Symbolics-flt/tsc.c.s176_for.cond.5.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.GlobalData = type { [32000 x float], [3 x i32], [4 x i8], [32000 x float], [5 x i32], [12 x i8], [32000 x float], [7 x i32], [4 x i8], [32000 x float], [11 x i32], [4 x i8], [32000 x float], [13 x i32], [12 x i8], [256 x [256 x float]], [17 x i32], [12 x i8], [256 x [256 x float]], [19 x i32], [4 x i8], [256 x [256 x float]], [23 x i32], [4 x i8], [256 x [256 x float]] }

; Function Attrs: nounwind
define weak void @s176_for.cond.5.preheader.pjit.scop(%struct.GlobalData* nonnull %global_data)  {
newFuncRoot:
  br label %for.cond.5.preheader

for.cond.cleanup.3.exitStub:                      ; preds = %for.cond.cleanup.7
  ret void

for.cond.5.preheader:                             ; preds = %for.cond.cleanup.7, %newFuncRoot
  %indvars.iv49 = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next50, %for.cond.cleanup.7 ]
  %0 = sub nuw nsw i64 15999, %indvars.iv49
  %arrayidx11 = getelementptr inbounds %struct.GlobalData, %struct.GlobalData* %global_data, i64 0, i32 6, i64 %indvars.iv49
  br label %for.body.8

for.body.8:                                       ; preds = %for.body.8, %for.cond.5.preheader
  %indvars.iv = phi i64 [ 0, %for.cond.5.preheader ], [ %indvars.iv.next, %for.body.8 ]
  %1 = add nuw nsw i64 %0, %indvars.iv
  %arrayidx = getelementptr inbounds %struct.GlobalData, %struct.GlobalData* %global_data, i64 0, i32 3, i64 %1
  %2 = load float, float* %arrayidx, align 4, !tbaa !0
  %3 = load float, float* %arrayidx11, align 4, !tbaa !0
  %mul12 = fmul float %2, %3
  %arrayidx14 = getelementptr inbounds %struct.GlobalData, %struct.GlobalData* %global_data, i64 0, i32 0, i64 %indvars.iv
  %4 = load float, float* %arrayidx14, align 4, !tbaa !0
  %add15 = fadd float %4, %mul12
  store float %add15, float* %arrayidx14, align 4, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 16000
  br i1 %exitcond, label %for.cond.cleanup.7, label %for.body.8

for.cond.cleanup.7:                               ; preds = %for.body.8
  %indvars.iv.next50 = add nuw nsw i64 %indvars.iv49, 1
  %exitcond52 = icmp eq i64 %indvars.iv.next50, 16000
  br i1 %exitcond52, label %for.cond.cleanup.3.exitStub, label %for.cond.5.preheader
}

attributes #0 = { nounwind "polyjit-global-count"="1" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
