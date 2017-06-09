
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASCI_Purple/SMG2000/struct_matvec.c.hypre_StructMatvecCompute_for.body.1594.lr.ph.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @hypre_StructMatvecCompute_for.body.1594.lr.ph.us.pjit.scop(i32 %Ai.09040, i32 %xi.09039, i32 %yi.99038, double* %add.ptr762, i64, double* %add.ptr725, double* %add.ptr771, i64, double* %add.ptr780, i64, double* %add.ptr789, i64, double* %add.ptr798, i64, double* %add.ptr807, i64, double* %add.ptr816, i64, double* %add.ptr731, i64, i32, i32, i32 %sub1656, i32, i32 %sub1659, i32, i32* %add1654.us.out, i32* %add1657.us.out, i32* %add1660.us.out)  {
newFuncRoot:
  br label %for.body.1594.lr.ph.us

for.end.1663.loopexit.exitStub:                   ; preds = %for.cond.1592.for.end.1651_crit_edge.us
  store i32 %add1654.us, i32* %add1654.us.out
  store i32 %add1657.us, i32* %add1657.us.out
  store i32 %add1660.us, i32* %add1660.us.out
  ret void

for.body.1594.lr.ph.us:                           ; preds = %for.cond.1592.for.end.1651_crit_edge.us, %newFuncRoot
  %Ai.19032.us = phi i32 [ %add1654.us, %for.cond.1592.for.end.1651_crit_edge.us ], [ %Ai.09040, %newFuncRoot ]
  %xi.19031.us = phi i32 [ %add1657.us, %for.cond.1592.for.end.1651_crit_edge.us ], [ %xi.09039, %newFuncRoot ]
  %yi.109030.us = phi i32 [ %add1660.us, %for.cond.1592.for.end.1651_crit_edge.us ], [ %yi.99038, %newFuncRoot ]
  %loopj.79029.us = phi i32 [ %inc1662.us, %for.cond.1592.for.end.1651_crit_edge.us ], [ 0, %newFuncRoot ]
  %12 = sext i32 %Ai.19032.us to i64
  %13 = sext i32 %xi.19031.us to i64
  %14 = sext i32 %yi.109030.us to i64
  br label %for.body.1594.us

for.body.1594.us:                                 ; preds = %for.body.1594.us, %for.body.1594.lr.ph.us
  %indvars.iv9902 = phi i64 [ %14, %for.body.1594.lr.ph.us ], [ %indvars.iv.next9903, %for.body.1594.us ]
  %indvars.iv9893 = phi i64 [ %13, %for.body.1594.lr.ph.us ], [ %indvars.iv.next9894, %for.body.1594.us ]
  %indvars.iv9891 = phi i64 [ %12, %for.body.1594.lr.ph.us ], [ %indvars.iv.next9892, %for.body.1594.us ]
  %loopi.79021.us = phi i32 [ 0, %for.body.1594.lr.ph.us ], [ %inc1650.us, %for.body.1594.us ]
  %arrayidx1596.us = getelementptr inbounds double, double* %add.ptr762, i64 %indvars.iv9891
  %15 = load double, double* %arrayidx1596.us, align 8, !tbaa !0
  %16 = add nsw i64 %indvars.iv9893, %0
  %arrayidx1599.us = getelementptr inbounds double, double* %add.ptr725, i64 %16
  %17 = load double, double* %arrayidx1599.us, align 8, !tbaa !0
  %mul1600.us = fmul double %15, %17
  %arrayidx1602.us = getelementptr inbounds double, double* %add.ptr771, i64 %indvars.iv9891
  %18 = load double, double* %arrayidx1602.us, align 8, !tbaa !0
  %19 = add nsw i64 %indvars.iv9893, %1
  %arrayidx1605.us = getelementptr inbounds double, double* %add.ptr725, i64 %19
  %20 = load double, double* %arrayidx1605.us, align 8, !tbaa !0
  %mul1606.us = fmul double %18, %20
  %add1607.us = fadd double %mul1600.us, %mul1606.us
  %arrayidx1609.us = getelementptr inbounds double, double* %add.ptr780, i64 %indvars.iv9891
  %21 = load double, double* %arrayidx1609.us, align 8, !tbaa !0
  %22 = add nsw i64 %indvars.iv9893, %2
  %arrayidx1612.us = getelementptr inbounds double, double* %add.ptr725, i64 %22
  %23 = load double, double* %arrayidx1612.us, align 8, !tbaa !0
  %mul1613.us = fmul double %21, %23
  %add1614.us = fadd double %add1607.us, %mul1613.us
  %arrayidx1616.us = getelementptr inbounds double, double* %add.ptr789, i64 %indvars.iv9891
  %24 = load double, double* %arrayidx1616.us, align 8, !tbaa !0
  %25 = add nsw i64 %indvars.iv9893, %3
  %arrayidx1619.us = getelementptr inbounds double, double* %add.ptr725, i64 %25
  %26 = load double, double* %arrayidx1619.us, align 8, !tbaa !0
  %mul1620.us = fmul double %24, %26
  %add1621.us = fadd double %add1614.us, %mul1620.us
  %arrayidx1623.us = getelementptr inbounds double, double* %add.ptr798, i64 %indvars.iv9891
  %27 = load double, double* %arrayidx1623.us, align 8, !tbaa !0
  %28 = add nsw i64 %indvars.iv9893, %4
  %arrayidx1626.us = getelementptr inbounds double, double* %add.ptr725, i64 %28
  %29 = load double, double* %arrayidx1626.us, align 8, !tbaa !0
  %mul1627.us = fmul double %27, %29
  %add1628.us = fadd double %add1621.us, %mul1627.us
  %arrayidx1630.us = getelementptr inbounds double, double* %add.ptr807, i64 %indvars.iv9891
  %30 = load double, double* %arrayidx1630.us, align 8, !tbaa !0
  %31 = add nsw i64 %indvars.iv9893, %5
  %arrayidx1633.us = getelementptr inbounds double, double* %add.ptr725, i64 %31
  %32 = load double, double* %arrayidx1633.us, align 8, !tbaa !0
  %mul1634.us = fmul double %30, %32
  %add1635.us = fadd double %add1628.us, %mul1634.us
  %arrayidx1637.us = getelementptr inbounds double, double* %add.ptr816, i64 %indvars.iv9891
  %33 = load double, double* %arrayidx1637.us, align 8, !tbaa !0
  %34 = add nsw i64 %indvars.iv9893, %6
  %arrayidx1640.us = getelementptr inbounds double, double* %add.ptr725, i64 %34
  %35 = load double, double* %arrayidx1640.us, align 8, !tbaa !0
  %mul1641.us = fmul double %33, %35
  %add1642.us = fadd double %add1635.us, %mul1641.us
  %arrayidx1644.us = getelementptr inbounds double, double* %add.ptr731, i64 %indvars.iv9902
  %36 = load double, double* %arrayidx1644.us, align 8, !tbaa !0
  %add1645.us = fadd double %36, %add1642.us
  store double %add1645.us, double* %arrayidx1644.us, align 8, !tbaa !0
  %inc1650.us = add nuw nsw i32 %loopi.79021.us, 1
  %indvars.iv.next9892 = add i64 %indvars.iv9891, %7
  %indvars.iv.next9894 = add i64 %indvars.iv9893, %7
  %indvars.iv.next9903 = add i64 %indvars.iv9902, %7
  %exitcond9904 = icmp eq i32 %inc1650.us, %8
  br i1 %exitcond9904, label %for.cond.1592.for.end.1651_crit_edge.us, label %for.body.1594.us

for.cond.1592.for.end.1651_crit_edge.us:          ; preds = %for.body.1594.us
  %add1654.us = add i32 %9, %Ai.19032.us
  %37 = add i32 %sub1656, %10
  %add1657.us = add i32 %37, %xi.19031.us
  %38 = add i32 %sub1659, %10
  %add1660.us = add i32 %38, %yi.109030.us
  %inc1662.us = add nuw nsw i32 %loopj.79029.us, 1
  %exitcond9908 = icmp eq i32 %inc1662.us, %11
  br i1 %exitcond9908, label %for.end.1663.loopexit.exitStub, label %for.body.1594.lr.ph.us
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
