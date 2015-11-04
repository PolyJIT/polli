
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'interface_gtp.c.gtp_print_vertices_entry.split.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @gtp_print_vertices_entry.split.pjit.scop(i32* %ri, i32* %rj, i32 %n, i32* %movei, i32* %movej, i8** %.out, i8** %.out1)  {
newFuncRoot:
  br label %entry.split

for.cond.preheader.exitStub:                      ; preds = %for.cond.preheader.loopexit, %entry.split
  store i8* %0, i8** %.out
  store i8* %1, i8** %.out1
  ret void

entry.split:                                      ; preds = %newFuncRoot
  %0 = bitcast i32* %ri to i8*
  call void @llvm.lifetime.start(i64 4, i8* %0) #2
  %1 = bitcast i32* %rj to i8*
  call void @llvm.lifetime.start(i64 4, i8* %1) #2
  %cmp.71.i = icmp sgt i32 %n, 1
  br i1 %cmp.71.i, label %for.cond.1.preheader.preheader.i, label %for.cond.preheader.exitStub

for.cond.1.preheader.preheader.i:                 ; preds = %entry.split
  %2 = sext i32 %n to i64
  br label %for.cond.1.preheader.i

for.cond.1.preheader.i:                           ; preds = %for.cond.loopexit.i, %for.cond.1.preheader.preheader.i
  %indvars.iv73.i = phi i64 [ %2, %for.cond.1.preheader.preheader.i ], [ %indvars.iv.next74.i, %for.cond.loopexit.i ]
  %indvars.iv.next74.i = add nsw i64 %indvars.iv73.i, -1
  %arrayidx5.i = getelementptr inbounds i32, i32* %movei, i64 %indvars.iv.next74.i
  %arrayidx26.i = getelementptr inbounds i32, i32* %movej, i64 %indvars.iv.next74.i
  br label %for.body.3.i

for.body.3.i:                                     ; preds = %for.inc.i, %for.cond.1.preheader.i
  %indvars.iv.i = phi i64 [ 0, %for.cond.1.preheader.i ], [ %indvars.iv.next.i, %for.inc.i ]
  %arrayidx.i = getelementptr inbounds i32, i32* %movei, i64 %indvars.iv.i
  %3 = load i32, i32* %arrayidx.i, align 4, !tbaa !0
  %4 = load i32, i32* %arrayidx5.i, align 4, !tbaa !0
  %cmp6.i = icmp sgt i32 %3, %4
  br i1 %cmp6.i, label %if.then.i, label %lor.lhs.false.i

if.then.i:                                        ; preds = %land.lhs.true.i, %for.body.3.i
  %5 = load i32, i32* %arrayidx5.i, align 4, !tbaa !0
  %6 = load i32, i32* %arrayidx.i, align 4, !tbaa !0
  store i32 %6, i32* %arrayidx5.i, align 4, !tbaa !0
  store i32 %5, i32* %arrayidx.i, align 4, !tbaa !0
  %7 = load i32, i32* %arrayidx26.i, align 4, !tbaa !0
  %arrayidx28.i = getelementptr inbounds i32, i32* %movej, i64 %indvars.iv.i
  %8 = load i32, i32* %arrayidx28.i, align 4, !tbaa !0
  store i32 %8, i32* %arrayidx26.i, align 4, !tbaa !0
  store i32 %7, i32* %arrayidx28.i, align 4, !tbaa !0
  br label %for.inc.i

for.inc.i:                                        ; preds = %land.lhs.true.i, %lor.lhs.false.i, %if.then.i
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %cmp2.i = icmp slt i64 %indvars.iv.next.i, %indvars.iv.next74.i
  br i1 %cmp2.i, label %for.body.3.i, label %for.cond.loopexit.i

for.cond.loopexit.i:                              ; preds = %for.inc.i
  %cmp.i = icmp sgt i64 %indvars.iv.next74.i, 1
  br i1 %cmp.i, label %for.cond.1.preheader.i, label %for.cond.preheader.loopexit

for.cond.preheader.loopexit:                      ; preds = %for.cond.loopexit.i
  br label %for.cond.preheader.exitStub

lor.lhs.false.i:                                  ; preds = %for.body.3.i
  %cmp11.i = icmp eq i32 %3, %4
  br i1 %cmp11.i, label %land.lhs.true.i, label %for.inc.i

land.lhs.true.i:                                  ; preds = %lor.lhs.false.i
  %arrayidx13.i = getelementptr inbounds i32, i32* %movej, i64 %indvars.iv.i
  %9 = load i32, i32* %arrayidx13.i, align 4, !tbaa !0
  %10 = load i32, i32* %arrayidx26.i, align 4, !tbaa !0
  %cmp16.i = icmp sgt i32 %9, %10
  br i1 %cmp16.i, label %if.then.i, label %for.inc.i
}

; Function Attrs: nounwind argmemonly
declare void @llvm.lifetime.start(i64, i8* nocapture) #1

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }
attributes #1 = { nounwind argmemonly }
attributes #2 = { nounwind }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
