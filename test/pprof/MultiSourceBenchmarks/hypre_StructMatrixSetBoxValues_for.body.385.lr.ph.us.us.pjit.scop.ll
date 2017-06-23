
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/struct_matrix.c.hypre_StructMatrixSetBoxValues_for.body.385.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_StructMatrixSetBoxValues_for.body.385.lr.ph.us.us.pjit.scop(i32 %datai.01181.us, i32 %dvali.01180.us, double* %values, double* %add.ptr, i64, i32, i32 %cond466, i32 %sub400, i32, i32, i32* %add398.us.us.out, i32* %add401.us.us.out)  {
newFuncRoot:
  br label %for.body.385.lr.ph.us.us

for.cond.380.for.end.404_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.383.for.end.395_crit_edge.us.us
  store i32 %add398.us.us, i32* %add398.us.us.out
  store i32 %add401.us.us, i32* %add401.us.us.out
  ret void

for.body.385.lr.ph.us.us:                         ; preds = %for.cond.383.for.end.395_crit_edge.us.us, %newFuncRoot
  %datai.11175.us.us = phi i32 [ %add398.us.us, %for.cond.383.for.end.395_crit_edge.us.us ], [ %datai.01181.us, %newFuncRoot ]
  %dvali.11174.us.us = phi i32 [ %add401.us.us, %for.cond.383.for.end.395_crit_edge.us.us ], [ %dvali.01180.us, %newFuncRoot ]
  %loopj.11173.us.us = phi i32 [ %inc403.us.us, %for.cond.383.for.end.395_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %4 = sext i32 %datai.11175.us.us to i64
  %5 = sext i32 %dvali.11174.us.us to i64
  br label %for.body.385.us.us

for.body.385.us.us:                               ; preds = %for.body.385.us.us, %for.body.385.lr.ph.us.us
  %indvars.iv1370 = phi i64 [ %indvars.iv.next1371, %for.body.385.us.us ], [ %5, %for.body.385.lr.ph.us.us ]
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body.385.us.us ], [ %4, %for.body.385.lr.ph.us.us ]
  %loopi.11168.us.us = phi i32 [ %inc394.us.us, %for.body.385.us.us ], [ 0, %for.body.385.lr.ph.us.us ]
  %arrayidx387.us.us = getelementptr inbounds double, double* %values, i64 %indvars.iv1370
  %6 = load double, double* %arrayidx387.us.us, align 8, !tbaa !0
  %arrayidx389.us.us = getelementptr inbounds double, double* %add.ptr, i64 %indvars.iv
  %7 = load double, double* %arrayidx389.us.us, align 8, !tbaa !0
  %add390.us.us = fadd double %6, %7
  store double %add390.us.us, double* %arrayidx389.us.us, align 8, !tbaa !0
  %inc394.us.us = add nuw nsw i32 %loopi.11168.us.us, 1
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %indvars.iv.next1371 = add i64 %indvars.iv1370, %0
  %exitcond1372 = icmp eq i32 %inc394.us.us, %1
  br i1 %exitcond1372, label %for.cond.383.for.end.395_crit_edge.us.us, label %for.body.385.us.us

for.cond.383.for.end.395_crit_edge.us.us:         ; preds = %for.body.385.us.us
  %add398.us.us = add i32 %datai.11175.us.us, %cond466
  %8 = add i32 %sub400, %2
  %add401.us.us = add i32 %8, %dvali.11174.us.us
  %inc403.us.us = add nuw nsw i32 %loopj.11173.us.us, 1
  %exitcond1375 = icmp eq i32 %inc403.us.us, %3
  br i1 %exitcond1375, label %for.cond.380.for.end.404_crit_edge.us.loopexit.exitStub, label %for.body.385.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
