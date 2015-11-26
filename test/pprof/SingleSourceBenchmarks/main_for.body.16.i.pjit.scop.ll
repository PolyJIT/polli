
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/solvers/dynprog/dynprog.c.main_for.body.16.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.16.i.pjit.scop([50 x [50 x i32]]* %arraydecay6, [50 x i32]* %arraydecay, [50 x i32]* %arraydecay3)  {
newFuncRoot:
  br label %for.body.16.i

for.end.79.i.exitStub:                            ; preds = %for.cond.13.loopexit.i
  ret void

for.body.16.i:                                    ; preds = %for.cond.13.loopexit.i, %newFuncRoot
  %indvars.iv41 = phi i32 [ %indvars.iv.next42, %for.cond.13.loopexit.i ], [ 1, %newFuncRoot ]
  %indvars.iv31.i = phi i64 [ %indvars.iv.next32.i, %for.cond.13.loopexit.i ], [ 0, %newFuncRoot ]
  %indvars.iv24.i = phi i64 [ %indvars.iv.next25.i, %for.cond.13.loopexit.i ], [ 1, %newFuncRoot ]
  %indvars.iv.next32.i = add nuw nsw i64 %indvars.iv31.i, 1
  br label %for.body.20.i

for.body.20.i:                                    ; preds = %for.end.57.i, %for.body.16.i
  %indvars.iv43 = phi i32 [ %indvars.iv.next44, %for.end.57.i ], [ %indvars.iv41, %for.body.16.i ]
  %indvars.iv26.i = phi i64 [ %indvars.iv.next27.i, %for.end.57.i ], [ %indvars.iv24.i, %for.body.16.i ]
  %arrayidx26.i = getelementptr inbounds [50 x [50 x i32]], [50 x [50 x i32]]* %arraydecay6, i64 %indvars.iv31.i, i64 %indvars.iv26.i, i64 %indvars.iv31.i
  store i32 0, i32* %arrayidx26.i, align 4, !tbaa !0
  %cmp30.3.i = icmp slt i64 %indvars.iv.next32.i, %indvars.iv26.i
  br i1 %cmp30.3.i, label %for.body.31.i.preheader, label %for.end.57.i

for.body.31.i.preheader:                          ; preds = %for.body.20.i
  br label %for.body.31.i

for.body.31.i:                                    ; preds = %for.body.31.i, %for.body.31.i.preheader
  %indvars.iv16.i = phi i64 [ %indvars.iv.next17.i, %for.body.31.i ], [ %indvars.iv24.i, %for.body.31.i.preheader ]
  %0 = add nsw i64 %indvars.iv16.i, -1
  %arrayidx38.i = getelementptr inbounds [50 x [50 x i32]], [50 x [50 x i32]]* %arraydecay6, i64 %indvars.iv31.i, i64 %indvars.iv26.i, i64 %0
  %1 = load i32, i32* %arrayidx38.i, align 4, !tbaa !0
  %arrayidx42.i = getelementptr inbounds [50 x i32], [50 x i32]* %arraydecay, i64 %indvars.iv31.i, i64 %indvars.iv16.i
  %2 = load i32, i32* %arrayidx42.i, align 4, !tbaa !0
  %add43.i = add nsw i32 %2, %1
  %arrayidx47.i = getelementptr inbounds [50 x i32], [50 x i32]* %arraydecay, i64 %indvars.iv16.i, i64 %indvars.iv26.i
  %3 = load i32, i32* %arrayidx47.i, align 4, !tbaa !0
  %add48.i = add nsw i32 %add43.i, %3
  %arrayidx54.i = getelementptr inbounds [50 x [50 x i32]], [50 x [50 x i32]]* %arraydecay6, i64 %indvars.iv31.i, i64 %indvars.iv26.i, i64 %indvars.iv16.i
  store i32 %add48.i, i32* %arrayidx54.i, align 4, !tbaa !0
  %indvars.iv.next17.i = add nuw nsw i64 %indvars.iv16.i, 1
  %lftr.wideiv45 = trunc i64 %indvars.iv.next17.i to i32
  %exitcond46 = icmp eq i32 %lftr.wideiv45, %indvars.iv43
  br i1 %exitcond46, label %for.end.57.i.loopexit, label %for.body.31.i

for.end.57.i.loopexit:                            ; preds = %for.body.31.i
  br label %for.end.57.i

for.end.57.i:                                     ; preds = %for.end.57.i.loopexit, %for.body.20.i
  %4 = add nsw i64 %indvars.iv26.i, -1
  %arrayidx64.i = getelementptr inbounds [50 x [50 x i32]], [50 x [50 x i32]]* %arraydecay6, i64 %indvars.iv31.i, i64 %indvars.iv26.i, i64 %4
  %5 = load i32, i32* %arrayidx64.i, align 4, !tbaa !0
  %arrayidx68.i = getelementptr inbounds [50 x i32], [50 x i32]* %arraydecay3, i64 %indvars.iv31.i, i64 %indvars.iv26.i
  %6 = load i32, i32* %arrayidx68.i, align 4, !tbaa !0
  %add69.i = add nsw i32 %6, %5
  %arrayidx73.i = getelementptr inbounds [50 x i32], [50 x i32]* %arraydecay, i64 %indvars.iv31.i, i64 %indvars.iv26.i
  store i32 %add69.i, i32* %arrayidx73.i, align 4, !tbaa !0
  %indvars.iv.next27.i = add nuw nsw i64 %indvars.iv26.i, 1
  %indvars.iv.next44 = add nuw nsw i32 %indvars.iv43, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next27.i to i32
  %exitcond = icmp eq i32 %lftr.wideiv, 50
  br i1 %exitcond, label %for.cond.13.loopexit.i, label %for.body.20.i

for.cond.13.loopexit.i:                           ; preds = %for.end.57.i
  %indvars.iv.next25.i = add nuw nsw i64 %indvars.iv24.i, 1
  %indvars.iv.next42 = add nuw nsw i32 %indvars.iv41, 1
  %exitcond33.i = icmp eq i64 %indvars.iv.next32.i, 49
  br i1 %exitcond33.i, label %for.end.79.i.exitStub, label %for.body.16.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
