
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'zsyrk.c.f2c_zsyrk_for.body.536.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.doublecomplex = type { double, double }

; Function Attrs: nounwind
define weak void @f2c_zsyrk_for.body.536.lr.ph.pjit.scop(i64, i64 %mul539, %struct.doublecomplex* %add.ptr, i64, double* %r580, double* %i583, i64 %mul586, double* %r, double* %i591, %struct.doublecomplex* %add.ptr3, i64 %indvars.iv1479, i64 %mul611, double* %i616, double* %i635)  {
newFuncRoot:
  br label %for.body.536.lr.ph

for.inc.669.loopexit1507.exitStub:                ; preds = %for.inc.666
  ret void

for.body.536.lr.ph:                               ; preds = %for.inc.666, %newFuncRoot
  %i__.101415 = phi i64 [ %inc667, %for.inc.666 ], [ 1, %newFuncRoot ]
  %mul537 = mul nsw i64 %i__.101415, %0
  br label %for.body.536

for.body.536:                                     ; preds = %for.body.536, %for.body.536.lr.ph
  %temp.sroa.0.01412 = phi double [ 0.000000e+00, %for.body.536.lr.ph ], [ %add567, %for.body.536 ]
  %temp.sroa.22.01411 = phi double [ 0.000000e+00, %for.body.536.lr.ph ], [ %add571, %for.body.536 ]
  %l.21410 = phi i64 [ 1, %for.body.536.lr.ph ], [ %inc578, %for.body.536 ]
  %add538 = add nsw i64 %l.21410, %mul537
  %add540 = add nsw i64 %l.21410, %mul539
  %arrayidx541 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %add.ptr, i64 %add538
  %r542 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx541, i64 0, i32 0
  %2 = load double, double* %r542, align 8, !tbaa !0
  %arrayidx543 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %add.ptr, i64 %add540
  %r544 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx543, i64 0, i32 0
  %3 = load double, double* %r544, align 8, !tbaa !0
  %mul545 = fmul double %2, %3
  %i547 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx541, i64 0, i32 1
  %4 = load double, double* %i547, align 8, !tbaa !5
  %i549 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx543, i64 0, i32 1
  %5 = load double, double* %i549, align 8, !tbaa !5
  %mul550 = fmul double %4, %5
  %sub551 = fsub double %mul545, %mul550
  %mul557 = fmul double %2, %5
  %mul562 = fmul double %3, %4
  %add563 = fadd double %mul562, %mul557
  %add567 = fadd double %temp.sroa.0.01412, %sub551
  %add571 = fadd double %temp.sroa.22.01411, %add563
  %inc578 = add nuw nsw i64 %l.21410, 1
  %exitcond1475 = icmp eq i64 %l.21410, %1
  br i1 %exitcond1475, label %for.end.579, label %for.body.536

for.end.579:                                      ; preds = %for.body.536
  %add571.lcssa = phi double [ %add571, %for.body.536 ]
  %add567.lcssa = phi double [ %add567, %for.body.536 ]
  %6 = load double, double* %r580, align 8, !tbaa !0
  %cmp581 = fcmp oeq double %6, 0.000000e+00
  br i1 %cmp581, label %land.lhs.true.582, label %if.else.610

land.lhs.true.582:                                ; preds = %for.end.579
  %7 = load double, double* %i583, align 8, !tbaa !5
  %cmp584 = fcmp oeq double %7, 0.000000e+00
  br i1 %cmp584, label %if.then.585, label %if.else.610

if.then.585:                                      ; preds = %land.lhs.true.582
  %add587 = add nsw i64 %i__.101415, %mul586
  %8 = load double, double* %r, align 8, !tbaa !0
  %mul590 = fmul double %add567.lcssa, %8
  %9 = load double, double* %i591, align 8, !tbaa !5
  %mul593 = fmul double %add571.lcssa, %9
  %sub594 = fsub double %mul590, %mul593
  %mul598 = fmul double %add571.lcssa, %8
  %mul601 = fmul double %add567.lcssa, %9
  %add602 = fadd double %mul598, %mul601
  %arrayidx605 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %add.ptr3, i64 %add587
  %r606 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx605, i64 0, i32 0
  store double %sub594, double* %r606, align 8, !tbaa !0
  %i609 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx605, i64 0, i32 1
  store double %add602, double* %i609, align 8, !tbaa !5
  br label %for.inc.666

for.inc.666:                                      ; preds = %if.else.610, %if.then.585
  %inc667 = add nuw nsw i64 %i__.101415, 1
  %exitcond1478 = icmp eq i64 %inc667, %indvars.iv1479
  br i1 %exitcond1478, label %for.inc.669.loopexit1507.exitStub, label %for.body.536.lr.ph

if.else.610:                                      ; preds = %land.lhs.true.582, %for.end.579
  %add612 = add nsw i64 %i__.101415, %mul611
  %10 = load double, double* %r, align 8, !tbaa !0
  %mul615 = fmul double %add567.lcssa, %10
  %11 = load double, double* %i616, align 8, !tbaa !5
  %mul618 = fmul double %add571.lcssa, %11
  %sub619 = fsub double %mul615, %mul618
  %mul623 = fmul double %add571.lcssa, %10
  %mul626 = fmul double %add567.lcssa, %11
  %add627 = fadd double %mul623, %mul626
  %12 = load double, double* %r580, align 8, !tbaa !0
  %arrayidx632 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %add.ptr3, i64 %add612
  %r633 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx632, i64 0, i32 0
  %13 = load double, double* %r633, align 8, !tbaa !0
  %mul634 = fmul double %12, %13
  %14 = load double, double* %i635, align 8, !tbaa !5
  %i637 = getelementptr inbounds %struct.doublecomplex, %struct.doublecomplex* %arrayidx632, i64 0, i32 1
  %15 = load double, double* %i637, align 8, !tbaa !5
  %mul638 = fmul double %14, %15
  %sub639 = fsub double %mul634, %mul638
  %mul644 = fmul double %12, %15
  %mul648 = fmul double %13, %14
  %add649 = fadd double %mul648, %mul644
  %add653 = fadd double %sub619, %sub639
  %add657 = fadd double %add627, %add649
  store double %add653, double* %r633, align 8, !tbaa !0
  store double %add657, double* %i637, align 8, !tbaa !5
  br label %for.inc.666
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !2, i64 0}
!1 = !{!"", !2, i64 0, !2, i64 8}
!2 = !{!"double", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!1, !2, i64 8}
