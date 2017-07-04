
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/kernels/trmm/trmm.c.main_for.body.6.lr.ph.us.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.6.lr.ph.us.i.pjit.scop([1024 x double]* %arraydecay2, i64 %indvars.iv12.i, [1024 x double]* %arraydecay, i32 %indvars.iv31)  {
newFuncRoot:
  br label %for.body.6.lr.ph.us.i

for.inc.21.i.exitStub:                            ; preds = %for.cond.4.for.inc.18_crit_edge.us.i
  ret void

for.body.6.lr.ph.us.i:                            ; preds = %for.cond.4.for.inc.18_crit_edge.us.i, %newFuncRoot
  %indvars.iv9.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next10.i, %for.cond.4.for.inc.18_crit_edge.us.i ]
  %arrayidx17.us.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay2, i64 %indvars.iv12.i, i64 %indvars.iv9.i
  br label %for.body.6.us.i

for.body.6.us.i:                                  ; preds = %for.body.6.us.i, %for.body.6.lr.ph.us.i
  %indvars.iv.i.23 = phi i64 [ 0, %for.body.6.lr.ph.us.i ], [ %indvars.iv.next.i.24, %for.body.6.us.i ]
  %arrayidx8.us.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv12.i, i64 %indvars.iv.i.23
  %0 = load double, double* %arrayidx8.us.i, align 8, !tbaa !0
  %mul.us.i = fmul double %0, 3.241200e+04
  %arrayidx12.us.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay2, i64 %indvars.iv9.i, i64 %indvars.iv.i.23
  %1 = load double, double* %arrayidx12.us.i, align 8, !tbaa !0
  %mul13.us.i = fmul double %mul.us.i, %1
  %2 = load double, double* %arrayidx17.us.i, align 8, !tbaa !0
  %add.us.i = fadd double %2, %mul13.us.i
  store double %add.us.i, double* %arrayidx17.us.i, align 8, !tbaa !0
  %indvars.iv.next.i.24 = add nuw nsw i64 %indvars.iv.i.23, 1
  %lftr.wideiv33 = trunc i64 %indvars.iv.next.i.24 to i32
  %exitcond34 = icmp eq i32 %lftr.wideiv33, %indvars.iv31
  br i1 %exitcond34, label %for.cond.4.for.inc.18_crit_edge.us.i, label %for.body.6.us.i

for.cond.4.for.inc.18_crit_edge.us.i:             ; preds = %for.body.6.us.i
  %indvars.iv.next10.i = add nuw nsw i64 %indvars.iv9.i, 1
  %exitcond11.i = icmp eq i64 %indvars.iv.next10.i, 1024
  br i1 %exitcond11.i, label %for.inc.21.i.exitStub, label %for.body.6.lr.ph.us.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
