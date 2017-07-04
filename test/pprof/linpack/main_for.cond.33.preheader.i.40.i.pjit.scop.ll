
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'linpack.c.main_for.cond.33.preheader.i.40.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.33.preheader.i.40.i.pjit.scop(double* %add.ptr.i, double*)  {
newFuncRoot:
  br label %for.cond.33.preheader.i.40.i

matgen.exit51.i.exitStub:                         ; preds = %for.inc.49.i.50.i
  ret void

for.cond.33.preheader.i.40.i:                     ; preds = %for.inc.49.i.50.i, %newFuncRoot
  %indvars.iv9.i.39.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next10.i.48.i, %for.inc.49.i.50.i ]
  %1 = mul nuw nsw i64 %indvars.iv9.i.39.i, 10240
  br label %for.body.36.i.47.i

for.body.36.i.47.i:                               ; preds = %for.body.36.i.47.i, %for.cond.33.preheader.i.40.i
  %indvars.iv.i.41.i = phi i64 [ 0, %for.cond.33.preheader.i.40.i ], [ %indvars.iv.next.i.45.i, %for.body.36.i.47.i ]
  %arrayidx38.i.42.i = getelementptr inbounds double, double* %add.ptr.i, i64 %indvars.iv.i.41.i
  %2 = load double, double* %arrayidx38.i.42.i, align 8, !tbaa !0
  %3 = add nuw nsw i64 %indvars.iv.i.41.i, %1
  %arrayidx42.i.43.i = getelementptr inbounds double, double* %0, i64 %3
  %4 = load double, double* %arrayidx42.i.43.i, align 8, !tbaa !0
  %add43.i.44.i = fadd double %2, %4
  store double %add43.i.44.i, double* %arrayidx38.i.42.i, align 8, !tbaa !0
  %indvars.iv.next.i.45.i = add nuw nsw i64 %indvars.iv.i.41.i, 1
  %exitcond.i.46.i = icmp eq i64 %indvars.iv.next.i.45.i, 5120
  br i1 %exitcond.i.46.i, label %for.inc.49.i.50.i, label %for.body.36.i.47.i

for.inc.49.i.50.i:                                ; preds = %for.body.36.i.47.i
  %indvars.iv.next10.i.48.i = add nuw nsw i64 %indvars.iv9.i.39.i, 1
  %exitcond12.i.49.i = icmp eq i64 %indvars.iv.next10.i.48.i, 5120
  br i1 %exitcond12.i.49.i, label %matgen.exit51.i.exitStub, label %for.cond.33.preheader.i.40.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
