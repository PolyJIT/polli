
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'cblat3.c.cchk3__for.body.363.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.complex = type { float, float }

; Function Attrs: nounwind
define weak void @cchk3__for.body.363.lr.ph.pjit.scop(i64, i64, %struct.complex* %incdec.ptr5, %struct.complex* %add.ptr, %struct.complex* %add.ptr8, float, float, i64, i64)  {
newFuncRoot:
  br label %for.body.363.lr.ph

for.cond.356.for.end.413_crit_edge.loopexit.exitStub: ; preds = %for.inc.411
  ret void

for.body.363.lr.ph:                               ; preds = %for.inc.411, %newFuncRoot
  %j.1753 = phi i64 [ %inc412, %for.inc.411 ], [ 1, %newFuncRoot ]
  %mul364 = mul nsw i64 %j.1753, %0
  %sub366 = add nsw i64 %j.1753, -1
  %mul367 = mul nsw i64 %sub366, %1
  %mul378 = mul nsw i64 %sub366, %1
  br label %for.body.363

for.body.363:                                     ; preds = %for.body.363, %for.body.363.lr.ph
  %inc409774 = phi i64 [ 1, %for.body.363.lr.ph ], [ %inc409, %for.body.363 ]
  %add365 = add nsw i64 %inc409774, %mul364
  %add368 = add nsw i64 %inc409774, %mul367
  %arrayidx369 = getelementptr inbounds %struct.complex, %struct.complex* %incdec.ptr5, i64 %add368
  %6 = bitcast %struct.complex* %arrayidx369 to i32*
  %7 = load i32, i32* %6, align 4, !tbaa !0
  %arrayidx371 = getelementptr inbounds %struct.complex, %struct.complex* %add.ptr, i64 %add365
  %8 = bitcast %struct.complex* %arrayidx371 to i32*
  store i32 %7, i32* %8, align 4, !tbaa !0
  %i374 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx369, i64 0, i32 1
  %9 = bitcast float* %i374 to i32*
  %10 = load i32, i32* %9, align 4, !tbaa !5
  %i376 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx371, i64 0, i32 1
  %11 = bitcast float* %i376 to i32*
  store i32 %10, i32* %11, align 4, !tbaa !5
  %add379 = add nsw i64 %inc409774, %mul378
  %add381 = add nsw i64 %inc409774, %mul364
  %arrayidx383 = getelementptr inbounds %struct.complex, %struct.complex* %add.ptr8, i64 %add381
  %r384 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx383, i64 0, i32 0
  %12 = load float, float* %r384, align 4, !tbaa !0
  %mul385 = fmul float %2, %12
  %i388 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx383, i64 0, i32 1
  %13 = load float, float* %i388, align 4, !tbaa !5
  %mul389 = fmul float %3, %13
  %sub390 = fsub float %mul385, %mul389
  %mul395 = fmul float %2, %13
  %mul399 = fmul float %3, %12
  %add400 = fadd float %mul399, %mul395
  %arrayidx403 = getelementptr inbounds %struct.complex, %struct.complex* %incdec.ptr5, i64 %add379
  %r404 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx403, i64 0, i32 0
  store float %sub390, float* %r404, align 4, !tbaa !0
  %i407 = getelementptr inbounds %struct.complex, %struct.complex* %arrayidx403, i64 0, i32 1
  store float %add400, float* %i407, align 4, !tbaa !5
  %inc409 = add nuw nsw i64 %inc409774, 1
  %exitcond = icmp eq i64 %inc409, %4
  br i1 %exitcond, label %for.inc.411, label %for.body.363

for.inc.411:                                      ; preds = %for.body.363
  %inc412 = add nuw nsw i64 %j.1753, 1
  %exitcond783 = icmp eq i64 %j.1753, %5
  br i1 %exitcond783, label %for.cond.356.for.end.413_crit_edge.loopexit.exitStub, label %for.body.363.lr.ph
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 0}
!1 = !{!"", !2, i64 0, !2, i64 4}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!1, !2, i64 4}
