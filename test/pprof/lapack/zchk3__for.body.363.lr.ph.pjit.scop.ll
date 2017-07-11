
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'zblat3.c.zchk3__for.body.363.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.doublecomplex = type { double, double }

; Function Attrs: nounwind
define weak void @zchk3__for.body.363.lr.ph.pjit.scop(i64, i64, %struct.doublecomplex* %incdec.ptr5, %struct.doublecomplex* %add.ptr, %struct.doublecomplex* %add.ptr8, double, double, i64, i64)  {
newFuncRoot:
  br label %for.body.363.lr.ph

for.cond.356.for.end.413_crit_edge.loopexit.exitStub: ; preds = %for.inc.411
  ret void

for.body.363.lr.ph:                               ; preds = %for.inc.411, %newFuncRoot
  %j.1751 = phi i64 [ %inc412, %for.inc.411 ], [ 1, %newFuncRoot ]
  %mul364 = mul nsw i64 %j.1751, %0
  %sub366 = add nsw i64 %j.1751, -1
  %mul367 = mul nsw i64 %sub366, %1
  %mul378 = mul nsw i64 %sub366, %1
  br label %for.body.363

for.body.363:                                     ; preds = %for.body.363, %for.body.363.lr.ph
  %inc409772 = phi i64 [ 1, %for.body.363.lr.ph ], [ %inc409, %for.body.363 ]
  %add365 = add nsw i64 %inc409772, %mul364
  %add368 = add nsw i64 %inc409772, %mul367
  %arrayidx369 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %incdec.ptr5, i64 %add368
  %6 = bitcast %struct.doublecomplex* %arrayidx369 to i64*
  %7 = load i64, i64* %6, align 8, !tbaa !0
  %arrayidx371 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %add.ptr, i64 %add365
  %8 = bitcast %struct.doublecomplex* %arrayidx371 to i64*
  store i64 %7, i64* %8, align 8, !tbaa !0
  %i374 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx369, i64 0, i32 1
  %9 = bitcast double* %i374 to i64*
  %10 = load i64, i64* %9, align 8, !tbaa !5
  %i376 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx371, i64 0, i32 1
  %11 = bitcast double* %i376 to i64*
  store i64 %10, i64* %11, align 8, !tbaa !5
  %add379 = add nsw i64 %inc409772, %mul378
  %add381 = add nsw i64 %inc409772, %mul364
  %arrayidx383 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %add.ptr8, i64 %add381
  %r384 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx383, i64 0, i32 0
  %12 = load double, double* %r384, align 8, !tbaa !0
  %mul385 = fmul double %2, %12
  %i388 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx383, i64 0, i32 1
  %13 = load double, double* %i388, align 8, !tbaa !5
  %mul389 = fmul double %3, %13
  %sub390 = fsub double %mul385, %mul389
  %mul395 = fmul double %2, %13
  %mul399 = fmul double %3, %12
  %add400 = fadd double %mul399, %mul395
  %arrayidx403 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %incdec.ptr5, i64 %add379
  %r404 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx403, i64 0, i32 0
  store double %sub390, double* %r404, align 8, !tbaa !0
  %i407 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx403, i64 0, i32 1
  store double %add400, double* %i407, align 8, !tbaa !5
  %inc409 = add nuw nsw i64 %inc409772, 1
  %exitcond = icmp eq i64 %inc409, %4
  br i1 %exitcond, label %for.inc.411, label %for.body.363

for.inc.411:                                      ; preds = %for.body.363
  %inc412 = add nuw nsw i64 %j.1751, 1
  %exitcond781 = icmp eq i64 %j.1751, %5
  br i1 %exitcond781, label %for.cond.356.for.end.413_crit_edge.loopexit.exitStub, label %for.body.363.lr.ph
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 0}
!1 = !{!"", !2, i64 0, !2, i64 8}
!2 = !{!"double", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!1, !2, i64 8}
