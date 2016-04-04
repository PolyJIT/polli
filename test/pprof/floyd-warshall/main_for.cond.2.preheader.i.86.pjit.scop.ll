
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'floyd-warshall.dir/floyd-warshall.c.main_for.cond.2.preheader.i.86.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.2.preheader.i.86.pjit.scop(i32*)  {
newFuncRoot:
  br label %for.cond.2.preheader.i.86

kernel_floyd_warshall.exit.exitStub:              ; preds = %for.inc.40.i
  ret void

for.cond.2.preheader.i.86:                        ; preds = %for.inc.40.i, %newFuncRoot
  %indvars.iv7.i = phi i64 [ %indvars.iv.next8.i, %for.inc.40.i ], [ 0, %newFuncRoot ]
  %1 = mul nuw nsw i64 %indvars.iv7.i, 2800
  %arrayidx16.i = getelementptr inbounds i32, i32* %0, i64 %1
  br label %for.cond.5.preheader.i

for.cond.5.preheader.i:                           ; preds = %for.inc.37.i, %for.cond.2.preheader.i.86
  %indvars.iv4.i.87 = phi i64 [ 0, %for.cond.2.preheader.i.86 ], [ %indvars.iv.next5.i.92, %for.inc.37.i ]
  %2 = mul nuw nsw i64 %indvars.iv4.i.87, 2800
  %arrayidx.i.88 = getelementptr inbounds i32, i32* %0, i64 %2
  %arrayidx13.i = getelementptr inbounds i32, i32* %arrayidx.i.88, i64 %indvars.iv7.i
  br label %for.body.7.i

for.body.7.i:                                     ; preds = %for.body.7.i, %for.cond.5.preheader.i
  %indvars.iv.i.89 = phi i64 [ 0, %for.cond.5.preheader.i ], [ %indvars.iv.next.i.90, %for.body.7.i ]
  %arrayidx9.i = getelementptr inbounds i32, i32* %arrayidx.i.88, i64 %indvars.iv.i.89
  %3 = load i32, i32* %arrayidx9.i, align 4, !tbaa !0
  %4 = load i32, i32* %arrayidx13.i, align 4, !tbaa !0
  %arrayidx17.i = getelementptr inbounds i32, i32* %arrayidx16.i, i64 %indvars.iv.i.89
  %5 = load i32, i32* %arrayidx17.i, align 4, !tbaa !0
  %add18.i = add nsw i32 %5, %4
  %cmp19.i = icmp slt i32 %3, %add18.i
  %.add18.i = select i1 %cmp19.i, i32 %3, i32 %add18.i
  store i32 %.add18.i, i32* %arrayidx9.i, align 4, !tbaa !0
  %indvars.iv.next.i.90 = add nuw nsw i64 %indvars.iv.i.89, 1
  %exitcond.i.91 = icmp eq i64 %indvars.iv.next.i.90, 2800
  br i1 %exitcond.i.91, label %for.inc.37.i, label %for.body.7.i

for.inc.37.i:                                     ; preds = %for.body.7.i
  %indvars.iv.next5.i.92 = add nuw nsw i64 %indvars.iv4.i.87, 1
  %exitcond6.i = icmp eq i64 %indvars.iv.next5.i.92, 2800
  br i1 %exitcond6.i, label %for.inc.40.i, label %for.cond.5.preheader.i

for.inc.40.i:                                     ; preds = %for.inc.37.i
  %indvars.iv.next8.i = add nuw nsw i64 %indvars.iv7.i, 1
  %exitcond9.i = icmp eq i64 %indvars.iv.next8.i, 2800
  br i1 %exitcond9.i, label %kernel_floyd_warshall.exit.exitStub, label %for.cond.2.preheader.i.86
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
