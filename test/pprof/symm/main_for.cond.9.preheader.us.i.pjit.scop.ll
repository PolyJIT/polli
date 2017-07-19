
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'symm.dir/symm.c.main_for.cond.9.preheader.us.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.9.preheader.us.i.pjit.scop(double* %arrayidx.i.126, double* %arrayidx16.i, double*, double*, i32 %indvars.iv146, double* %arrayidx36.us.i, double* %arrayidx47.us.i)  {
newFuncRoot:
  br label %for.cond.9.preheader.us.i

for.inc.59.i.loopexit.exitStub:                   ; preds = %for.cond.9.for.end_crit_edge.us.i
  ret void

for.cond.9.preheader.us.i:                        ; preds = %for.cond.9.for.end_crit_edge.us.i, %newFuncRoot
  %indvars.iv15.i = phi i64 [ %indvars.iv.next16.i, %for.cond.9.for.end_crit_edge.us.i ], [ 0, %newFuncRoot ]
  %arrayidx13.us.i = getelementptr inbounds double, double* %arrayidx.i.126, i64 %indvars.iv15.i
  br label %for.body.11.us.i

for.body.11.us.i:                                 ; preds = %for.body.11.us.i, %for.cond.9.preheader.us.i
  %indvars.iv10.i = phi i64 [ 0, %for.cond.9.preheader.us.i ], [ %indvars.iv.next11.i, %for.body.11.us.i ]
  %temp2.03.us.i = phi double [ 0.000000e+00, %for.cond.9.preheader.us.i ], [ %add33.us.i, %for.body.11.us.i ]
  %2 = load double, double* %arrayidx13.us.i, align 8, !tbaa !0
  %mul.us.i = fmul double %2, 1.500000e+00
  %arrayidx17.us.i = getelementptr inbounds double, double* %arrayidx16.i, i64 %indvars.iv10.i
  %3 = load double, double* %arrayidx17.us.i, align 8, !tbaa !0
  %mul18.us.i = fmul double %mul.us.i, %3
  %4 = mul nuw nsw i64 %indvars.iv10.i, 1200
  %arrayidx21.us.i = getelementptr inbounds double, double* %0, i64 %4
  %arrayidx22.us.i = getelementptr inbounds double, double* %arrayidx21.us.i, i64 %indvars.iv15.i
  %5 = load double, double* %arrayidx22.us.i, align 8, !tbaa !0
  %add23.us.i = fadd double %5, %mul18.us.i
  store double %add23.us.i, double* %arrayidx22.us.i, align 8, !tbaa !0
  %arrayidx26.us.i = getelementptr inbounds double, double* %1, i64 %4
  %arrayidx27.us.i = getelementptr inbounds double, double* %arrayidx26.us.i, i64 %indvars.iv15.i
  %6 = load double, double* %arrayidx27.us.i, align 8, !tbaa !0
  %7 = load double, double* %arrayidx17.us.i, align 8, !tbaa !0
  %mul32.us.i = fmul double %6, %7
  %add33.us.i = fadd double %temp2.03.us.i, %mul32.us.i
  %indvars.iv.next11.i = add nuw nsw i64 %indvars.iv10.i, 1
  %lftr.wideiv148 = trunc i64 %indvars.iv.next11.i to i32
  %exitcond149 = icmp eq i32 %lftr.wideiv148, %indvars.iv146
  br i1 %exitcond149, label %for.cond.9.for.end_crit_edge.us.i, label %for.body.11.us.i

for.cond.9.for.end_crit_edge.us.i:                ; preds = %for.body.11.us.i
  %add33.us.i.lcssa = phi double [ %add33.us.i, %for.body.11.us.i ]
  %arrayidx37.us.i = getelementptr inbounds double, double* %arrayidx36.us.i, i64 %indvars.iv15.i
  %8 = load double, double* %arrayidx37.us.i, align 8, !tbaa !0
  %mul38.us.i = fmul double %8, 1.200000e+00
  %9 = load double, double* %arrayidx13.us.i, align 8, !tbaa !0
  %mul43.us.i = fmul double %9, 1.500000e+00
  %10 = load double, double* %arrayidx47.us.i, align 8, !tbaa !0
  %mul48.us.i = fmul double %mul43.us.i, %10
  %add49.us.i = fadd double %mul38.us.i, %mul48.us.i
  %mul50.us.i = fmul double %add33.us.i.lcssa, 1.500000e+00
  %add51.us.i = fadd double %mul50.us.i, %add49.us.i
  store double %add51.us.i, double* %arrayidx37.us.i, align 8, !tbaa !0
  %indvars.iv.next16.i = add nuw nsw i64 %indvars.iv15.i, 1
  %exitcond17.i = icmp eq i64 %indvars.iv.next16.i, 1200
  br i1 %exitcond17.i, label %for.inc.59.i.loopexit.exitStub, label %for.cond.9.preheader.us.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
