
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'dsbmv.c.f2c_dsbmv_for.body.101.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_dsbmv_for.body.101.pjit.scop(double* %alpha, double* %incdec.ptr, i64, i64 %add94, i64, double* %add.ptr, double* %incdec.ptr1, i64)  {
newFuncRoot:
  br label %for.body.101

cleanup.loopexit649.exitStub:                     ; preds = %for.end.127
  ret void

for.body.101:                                     ; preds = %for.end.127, %newFuncRoot
  %j.0611 = phi i64 [ 1, %newFuncRoot ], [ %inc138, %for.end.127 ]
  %3 = load double, double* %alpha, align 8, !tbaa !0
  %arrayidx102 = getelementptr inbounds double, double* %incdec.ptr, i64 %j.0611
  %4 = load double, double* %arrayidx102, align 8, !tbaa !0
  %mul103 = fmul double %3, %4
  %sub105 = sub nsw i64 %j.0611, %0
  %cmp107 = icmp sgt i64 %sub105, 1
  %cond = select i1 %cmp107, i64 %sub105, i64 1
  %cmp109.606 = icmp slt i64 %cond, %j.0611
  br i1 %cmp109.606, label %for.body.110.lr.ph, label %for.end.127

for.body.110.lr.ph:                               ; preds = %for.body.101
  %sub104 = sub i64 %add94, %j.0611
  %mul112 = mul nsw i64 %j.0611, %1
  %add111 = add i64 %sub104, %mul112
  br label %for.body.110

for.body.110:                                     ; preds = %for.body.110, %for.body.110.lr.ph
  %temp2.0608 = phi double [ 0.000000e+00, %for.body.110.lr.ph ], [ %add124, %for.body.110 ]
  %i__.4607 = phi i64 [ %cond, %for.body.110.lr.ph ], [ %inc126, %for.body.110 ]
  %add113 = add i64 %add111, %i__.4607
  %arrayidx114 = getelementptr inbounds double, double* %add.ptr, i64 %add113
  %5 = load double, double* %arrayidx114, align 8, !tbaa !0
  %mul115 = fmul double %mul103, %5
  %arrayidx116 = getelementptr inbounds double, double* %incdec.ptr1, i64 %i__.4607
  %6 = load double, double* %arrayidx116, align 8, !tbaa !0
  %add117 = fadd double %6, %mul115
  store double %add117, double* %arrayidx116, align 8, !tbaa !0
  %7 = load double, double* %arrayidx114, align 8, !tbaa !0
  %arrayidx122 = getelementptr inbounds double, double* %incdec.ptr, i64 %i__.4607
  %8 = load double, double* %arrayidx122, align 8, !tbaa !0
  %mul123 = fmul double %7, %8
  %add124 = fadd double %temp2.0608, %mul123
  %inc126 = add nuw nsw i64 %i__.4607, 1
  %cmp109 = icmp slt i64 %inc126, %j.0611
  br i1 %cmp109, label %for.body.110, label %for.end.127.loopexit

for.end.127.loopexit:                             ; preds = %for.body.110
  %add124.lcssa = phi double [ %add124, %for.body.110 ]
  br label %for.end.127

for.end.127:                                      ; preds = %for.end.127.loopexit, %for.body.101
  %temp2.0.lcssa = phi double [ 0.000000e+00, %for.body.101 ], [ %add124.lcssa, %for.end.127.loopexit ]
  %arrayidx128 = getelementptr inbounds double, double* %incdec.ptr1, i64 %j.0611
  %9 = load double, double* %arrayidx128, align 8, !tbaa !0
  %mul129 = mul nsw i64 %j.0611, %1
  %add130 = add nsw i64 %mul129, %add94
  %arrayidx131 = getelementptr inbounds double, double* %add.ptr, i64 %add130
  %10 = load double, double* %arrayidx131, align 8, !tbaa !0
  %mul132 = fmul double %mul103, %10
  %add133 = fadd double %9, %mul132
  %11 = load double, double* %alpha, align 8, !tbaa !0
  %mul134 = fmul double %temp2.0.lcssa, %11
  %add135 = fadd double %add133, %mul134
  store double %add135, double* %arrayidx128, align 8, !tbaa !0
  %inc138 = add nuw nsw i64 %j.0611, 1
  %exitcond641 = icmp eq i64 %j.0611, %2
  br i1 %exitcond641, label %cleanup.loopexit649.exitStub, label %for.body.101
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
