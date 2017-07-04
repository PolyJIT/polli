
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/point_relax.c.hypre_PointRelax_for.body.1521.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_PointRelax_for.body.1521.lr.ph.us.us.pjit.scop(i32 %Ai.32983.us, i32 %xi.32982.us, i32 %ti.32981.us, double* %add.ptr995, double* %add.ptr1052, double* %add.ptr591, i64, i32, i32, i32 %sub1540, i32, i32 %sub1543, i32, i32* %add1538.us.us.out, i32* %add1541.us.us.out, i32* %add1544.us.us.out)  {
newFuncRoot:
  br label %for.body.1521.lr.ph.us.us

for.cond.1514.for.end.1547_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.1518.for.end.1535_crit_edge.us.us
  store i32 %add1538.us.us, i32* %add1538.us.us.out
  store i32 %add1541.us.us, i32* %add1541.us.us.out
  store i32 %add1544.us.us, i32* %add1544.us.us.out
  ret void

for.body.1521.lr.ph.us.us:                        ; preds = %for.cond.1518.for.end.1535_crit_edge.us.us, %newFuncRoot
  %Ai.42975.us.us = phi i32 [ %add1538.us.us, %for.cond.1518.for.end.1535_crit_edge.us.us ], [ %Ai.32983.us, %newFuncRoot ]
  %xi.42974.us.us = phi i32 [ %add1541.us.us, %for.cond.1518.for.end.1535_crit_edge.us.us ], [ %xi.32982.us, %newFuncRoot ]
  %ti.42973.us.us = phi i32 [ %add1544.us.us, %for.cond.1518.for.end.1535_crit_edge.us.us ], [ %ti.32981.us, %newFuncRoot ]
  %loopj.52972.us.us = phi i32 [ %inc1546.us.us, %for.cond.1518.for.end.1535_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %5 = sext i32 %Ai.42975.us.us to i64
  %6 = sext i32 %xi.42974.us.us to i64
  %7 = sext i32 %ti.42973.us.us to i64
  br label %for.body.1521.us.us

for.body.1521.us.us:                              ; preds = %for.body.1521.us.us, %for.body.1521.lr.ph.us.us
  %indvars.iv3348 = phi i64 [ %indvars.iv.next3349, %for.body.1521.us.us ], [ %7, %for.body.1521.lr.ph.us.us ]
  %indvars.iv3346 = phi i64 [ %indvars.iv.next3347, %for.body.1521.us.us ], [ %6, %for.body.1521.lr.ph.us.us ]
  %indvars.iv3344 = phi i64 [ %indvars.iv.next3345, %for.body.1521.us.us ], [ %5, %for.body.1521.lr.ph.us.us ]
  %loopi.52964.us.us = phi i32 [ %inc1534.us.us, %for.body.1521.us.us ], [ 0, %for.body.1521.lr.ph.us.us ]
  %arrayidx1523.us.us = getelementptr inbounds double, double* %add.ptr995, i64 %indvars.iv3344
  %8 = load double, double* %arrayidx1523.us.us, align 8, !tbaa !0
  %arrayidx1525.us.us = getelementptr inbounds double, double* %add.ptr1052, i64 %indvars.iv3346
  %9 = load double, double* %arrayidx1525.us.us, align 8, !tbaa !0
  %mul1526.us.us = fmul double %8, %9
  %arrayidx1528.us.us = getelementptr inbounds double, double* %add.ptr591, i64 %indvars.iv3348
  %10 = load double, double* %arrayidx1528.us.us, align 8, !tbaa !0
  %sub1529.us.us = fsub double %10, %mul1526.us.us
  store double %sub1529.us.us, double* %arrayidx1528.us.us, align 8, !tbaa !0
  %inc1534.us.us = add nuw nsw i32 %loopi.52964.us.us, 1
  %indvars.iv.next3345 = add i64 %indvars.iv3344, %0
  %indvars.iv.next3347 = add i64 %indvars.iv3346, %0
  %indvars.iv.next3349 = add i64 %indvars.iv3348, %0
  %exitcond3350 = icmp eq i32 %inc1534.us.us, %1
  br i1 %exitcond3350, label %for.cond.1518.for.end.1535_crit_edge.us.us, label %for.body.1521.us.us

for.cond.1518.for.end.1535_crit_edge.us.us:       ; preds = %for.body.1521.us.us
  %add1538.us.us = add i32 %2, %Ai.42975.us.us
  %11 = add i32 %sub1540, %3
  %add1541.us.us = add i32 %11, %xi.42974.us.us
  %12 = add i32 %sub1543, %3
  %add1544.us.us = add i32 %12, %ti.42973.us.us
  %inc1546.us.us = add nuw nsw i32 %loopj.52972.us.us, 1
  %exitcond3354 = icmp eq i32 %inc1546.us.us, %4
  br i1 %exitcond3354, label %for.cond.1514.for.end.1547_crit_edge.us.loopexit.exitStub, label %for.body.1521.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
