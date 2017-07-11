
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'trisolv.dir/trisolv.c.main_for.body.i.109.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.i.109.pjit.scop(double*, double*, double*)  {
newFuncRoot:
  br label %for.body.i.109

kernel_trisolv.exit.exitStub:                     ; preds = %for.end.i
  ret void

for.body.i.109:                                   ; preds = %for.end.i, %newFuncRoot
  %indvars.iv118 = phi i32 [ 0, %newFuncRoot ], [ %indvars.iv.next119, %for.end.i ]
  %indvars.iv6.i = phi i64 [ %indvars.iv.next7.i, %for.end.i ], [ 0, %newFuncRoot ]
  %arrayidx.i.107 = getelementptr inbounds double, double* %0, i64 %indvars.iv6.i
  %3 = bitcast double* %arrayidx.i.107 to i64*
  %4 = load i64, i64* %3, align 8, !tbaa !0
  %arrayidx5.i.108 = getelementptr inbounds double, double* %1, i64 %indvars.iv6.i
  %5 = bitcast double* %arrayidx5.i.108 to i64*
  store i64 %4, i64* %5, align 8, !tbaa !0
  %cmp7.1.i = icmp sgt i64 %indvars.iv6.i, 0
  br i1 %cmp7.1.i, label %for.body.8.lr.ph.i, label %for.end.i

for.body.8.lr.ph.i:                               ; preds = %for.body.i.109
  %6 = mul nuw nsw i64 %indvars.iv6.i, 2000
  %arrayidx11.i = getelementptr inbounds double, double* %2, i64 %6
  br label %for.body.8.i

for.body.8.i:                                     ; preds = %for.body.8.i, %for.body.8.lr.ph.i
  %indvars.iv.i.110 = phi i64 [ 0, %for.body.8.lr.ph.i ], [ %indvars.iv.next.i.112, %for.body.8.i ]
  %arrayidx12.i = getelementptr inbounds double, double* %arrayidx11.i, i64 %indvars.iv.i.110
  %7 = load double, double* %arrayidx12.i, align 8, !tbaa !0
  %arrayidx14.i = getelementptr inbounds double, double* %1, i64 %indvars.iv.i.110
  %8 = load double, double* %arrayidx14.i, align 8, !tbaa !0
  %mul.i.111 = fmul double %7, %8
  %9 = load double, double* %arrayidx5.i.108, align 8, !tbaa !0
  %sub.i = fsub double %9, %mul.i.111
  store double %sub.i, double* %arrayidx5.i.108, align 8, !tbaa !0
  %indvars.iv.next.i.112 = add nuw nsw i64 %indvars.iv.i.110, 1
  %lftr.wideiv120 = trunc i64 %indvars.iv.next.i.112 to i32
  %exitcond121 = icmp eq i32 %lftr.wideiv120, %indvars.iv118
  br i1 %exitcond121, label %for.end.i.loopexit, label %for.body.8.i

for.end.i.loopexit:                               ; preds = %for.body.8.i
  br label %for.end.i

for.end.i:                                        ; preds = %for.end.i.loopexit, %for.body.i.109
  %10 = load double, double* %arrayidx5.i.108, align 8, !tbaa !0
  %11 = mul nuw nsw i64 %indvars.iv6.i, 2000
  %arrayidx21.i = getelementptr inbounds double, double* %2, i64 %11
  %arrayidx22.i = getelementptr inbounds double, double* %arrayidx21.i, i64 %indvars.iv6.i
  %12 = load double, double* %arrayidx22.i, align 8, !tbaa !0
  %div.i.113 = fdiv double %10, %12
  store double %div.i.113, double* %arrayidx5.i.108, align 8, !tbaa !0
  %indvars.iv.next7.i = add nuw nsw i64 %indvars.iv6.i, 1
  %indvars.iv.next119 = add nuw nsw i32 %indvars.iv118, 1
  %exitcond8.i = icmp eq i64 %indvars.iv.next7.i, 2000
  br i1 %exitcond8.i, label %kernel_trisolv.exit.exitStub, label %for.body.i.109
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
