
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'mvt.dir/mvt.c.main_for.cond.24.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.24.preheader.i.pjit.scop(double*, double*, double*)  {
newFuncRoot:
  br label %for.cond.24.preheader.i

kernel_mvt.exit.exitStub:                         ; preds = %for.inc.42.i
  ret void

for.cond.24.preheader.i:                          ; preds = %for.inc.42.i, %newFuncRoot
  %indvars.iv5.i = phi i64 [ %indvars.iv.next6.i, %for.inc.42.i ], [ 0, %newFuncRoot ]
  %arrayidx28.i = getelementptr inbounds double, double* %0, i64 %indvars.iv5.i
  br label %for.body.26.i

for.body.26.i:                                    ; preds = %for.body.26.i, %for.cond.24.preheader.i
  %indvars.iv.i.133 = phi i64 [ 0, %for.cond.24.preheader.i ], [ %indvars.iv.next.i.134, %for.body.26.i ]
  %3 = load double, double* %arrayidx28.i, align 8, !tbaa !0
  %4 = mul nuw nsw i64 %indvars.iv.i.133, 2000
  %arrayidx31.i = getelementptr inbounds double, double* %1, i64 %4
  %arrayidx32.i = getelementptr inbounds double, double* %arrayidx31.i, i64 %indvars.iv5.i
  %5 = load double, double* %arrayidx32.i, align 8, !tbaa !0
  %arrayidx34.i = getelementptr inbounds double, double* %2, i64 %indvars.iv.i.133
  %6 = load double, double* %arrayidx34.i, align 8, !tbaa !0
  %mul35.i = fmul double %5, %6
  %add36.i = fadd double %3, %mul35.i
  store double %add36.i, double* %arrayidx28.i, align 8, !tbaa !0
  %indvars.iv.next.i.134 = add nuw nsw i64 %indvars.iv.i.133, 1
  %exitcond.i.135 = icmp eq i64 %indvars.iv.next.i.134, 2000
  br i1 %exitcond.i.135, label %for.inc.42.i, label %for.body.26.i

for.inc.42.i:                                     ; preds = %for.body.26.i
  %indvars.iv.next6.i = add nuw nsw i64 %indvars.iv5.i, 1
  %exitcond7.i = icmp eq i64 %indvars.iv.next6.i, 2000
  br i1 %exitcond7.i, label %kernel_mvt.exit.exitStub, label %for.cond.24.preheader.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
