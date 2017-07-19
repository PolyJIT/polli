
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/cyclic_reduction.c.hypre_CyclicReduction_for.body.1455.lr.ph.us.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_CyclicReduction_for.body.1455.lr.ph.us.us.pjit.scop(i32 %Ai.33790.us, i32 %xi.63789.us, i32 %xci.03788.us, double* %add.ptr867, double* %call886, double* %add.ptr939, double* %call946, double* %add.ptr999, double* %add.ptr879, i64, i32, i32, i32 %sub1482, i32, i32 %cond1173, i32, i32* %add1480.us.us.out, i32* %add1483.us.us.out, i32* %add1486.us.us.out)  {
newFuncRoot:
  br label %for.body.1455.lr.ph.us.us

for.cond.1450.for.end.1489_crit_edge.us.loopexit.exitStub: ; preds = %for.cond.1453.for.end.1477_crit_edge.us.us
  store i32 %add1480.us.us, i32* %add1480.us.us.out
  store i32 %add1483.us.us, i32* %add1483.us.us.out
  store i32 %add1486.us.us, i32* %add1486.us.us.out
  ret void

for.body.1455.lr.ph.us.us:                        ; preds = %for.cond.1453.for.end.1477_crit_edge.us.us, %newFuncRoot
  %Ai.43782.us.us = phi i32 [ %add1480.us.us, %for.cond.1453.for.end.1477_crit_edge.us.us ], [ %Ai.33790.us, %newFuncRoot ]
  %xi.73781.us.us = phi i32 [ %add1483.us.us, %for.cond.1453.for.end.1477_crit_edge.us.us ], [ %xi.63789.us, %newFuncRoot ]
  %xci.13780.us.us = phi i32 [ %add1486.us.us, %for.cond.1453.for.end.1477_crit_edge.us.us ], [ %xci.03788.us, %newFuncRoot ]
  %loopj.53779.us.us = phi i32 [ %inc1488.us.us, %for.cond.1453.for.end.1477_crit_edge.us.us ], [ 0, %newFuncRoot ]
  %5 = sext i32 %Ai.43782.us.us to i64
  %6 = sext i32 %xi.73781.us.us to i64
  %7 = sext i32 %xci.13780.us.us to i64
  br label %for.body.1455.us.us

for.body.1455.us.us:                              ; preds = %for.body.1455.us.us, %for.body.1455.lr.ph.us.us
  %indvars.iv4240 = phi i64 [ %indvars.iv.next4241, %for.body.1455.us.us ], [ %7, %for.body.1455.lr.ph.us.us ]
  %indvars.iv4238 = phi i64 [ %indvars.iv.next4239, %for.body.1455.us.us ], [ %6, %for.body.1455.lr.ph.us.us ]
  %indvars.iv4236 = phi i64 [ %indvars.iv.next4237, %for.body.1455.us.us ], [ %5, %for.body.1455.lr.ph.us.us ]
  %loopi.53771.us.us = phi i32 [ %inc1476.us.us, %for.body.1455.us.us ], [ 0, %for.body.1455.lr.ph.us.us ]
  %arrayidx1457.us.us = getelementptr inbounds double, double* %add.ptr867, i64 %indvars.iv4238
  %8 = load double, double* %arrayidx1457.us.us, align 8, !tbaa !0
  %arrayidx1459.us.us = getelementptr inbounds double, double* %call886, i64 %indvars.iv4236
  %9 = load double, double* %arrayidx1459.us.us, align 8, !tbaa !0
  %arrayidx1461.us.us = getelementptr inbounds double, double* %add.ptr939, i64 %indvars.iv4238
  %10 = load double, double* %arrayidx1461.us.us, align 8, !tbaa !0
  %mul1462.us.us = fmul double %9, %10
  %sub1463.us.us = fsub double %8, %mul1462.us.us
  %arrayidx1465.us.us = getelementptr inbounds double, double* %call946, i64 %indvars.iv4236
  %11 = load double, double* %arrayidx1465.us.us, align 8, !tbaa !0
  %arrayidx1467.us.us = getelementptr inbounds double, double* %add.ptr999, i64 %indvars.iv4238
  %12 = load double, double* %arrayidx1467.us.us, align 8, !tbaa !0
  %mul1468.us.us = fmul double %11, %12
  %sub1469.us.us = fsub double %sub1463.us.us, %mul1468.us.us
  %arrayidx1471.us.us = getelementptr inbounds double, double* %add.ptr879, i64 %indvars.iv4240
  store double %sub1469.us.us, double* %arrayidx1471.us.us, align 8, !tbaa !0
  %inc1476.us.us = add nuw nsw i32 %loopi.53771.us.us, 1
  %indvars.iv.next4237 = add i64 %indvars.iv4236, %0
  %indvars.iv.next4239 = add i64 %indvars.iv4238, %0
  %indvars.iv.next4241 = add nsw i64 %indvars.iv4240, 1
  %exitcond4242 = icmp eq i32 %inc1476.us.us, %1
  br i1 %exitcond4242, label %for.cond.1453.for.end.1477_crit_edge.us.us, label %for.body.1455.us.us

for.cond.1453.for.end.1477_crit_edge.us.us:       ; preds = %for.body.1455.us.us
  %add1480.us.us = add i32 %2, %Ai.43782.us.us
  %13 = add i32 %sub1482, %3
  %add1483.us.us = add i32 %13, %xi.73781.us.us
  %add1486.us.us = add i32 %xci.13780.us.us, %cond1173
  %inc1488.us.us = add nuw nsw i32 %loopj.53779.us.us, 1
  %exitcond4246 = icmp eq i32 %inc1488.us.us, %4
  br i1 %exitcond4246, label %for.cond.1450.for.end.1489_crit_edge.us.loopexit.exitStub, label %for.body.1455.lr.ph.us.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
