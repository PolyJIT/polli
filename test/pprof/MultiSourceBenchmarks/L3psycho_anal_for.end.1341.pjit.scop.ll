
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/MiBench/consumer-lame/psymodel.c.L3psycho_anal_for.end.1341.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.III_psy_xmin = type { [22 x double], [13 x [3 x double]] }

; Function Attrs: nounwind
define weak void @L3psycho_anal_for.end.1341.pjit.scop(i32 %., i1* %cmp1342.out, [4 x %struct.III_psy_xmin]* nonnull %L3psycho_anal.thm, [12 x double]* nonnull %L3psycho_anal.mld_s, [4 x %struct.III_psy_xmin]* nonnull %L3psycho_anal.en, [21 x double]* nonnull %L3psycho_anal.mld_l)  {
newFuncRoot:
  br label %for.end.1341

if.end.1690.exitStub:                             ; preds = %if.end.1690.loopexit, %for.end.1341
  store i1 %cmp1342, i1* %cmp1342.out
  ret void

for.end.1341:                                     ; preds = %newFuncRoot
  %cmp1342 = icmp eq i32 %., 4
  br i1 %cmp1342, label %for.body.1354.preheader, label %if.end.1690.exitStub

for.body.1354.preheader:                          ; preds = %for.end.1341
  br label %for.body.1354

for.body.1354:                                    ; preds = %for.inc.1494, %for.body.1354.preheader
  %indvars.iv2850 = phi i64 [ %indvars.iv.next2851, %for.inc.1494 ], [ 0, %for.body.1354.preheader ]
  %arrayidx1356 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 0, i32 0, i64 %indvars.iv2850
  %0 = load double, double* %arrayidx1356, align 8, !tbaa !0
  %arrayidx1358 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 1, i32 0, i64 %indvars.iv2850
  %1 = load double, double* %arrayidx1358, align 8, !tbaa !0
  %mul1359 = fmul double %1, 1.580000e+00
  %cmp1360 = fcmp ugt double %0, %mul1359
  %mul1367 = fmul double %0, 1.580000e+00
  %cmp1368 = fcmp ugt double %1, %mul1367
  %or.cond2681 = or i1 %cmp1368, %cmp1360
  br i1 %or.cond2681, label %for.inc.1494, label %if.then.1370

for.inc.1494:                                     ; preds = %if.then.1370, %for.body.1354
  %indvars.iv.next2851 = add nuw nsw i64 %indvars.iv2850, 1
  %exitcond2852 = icmp eq i64 %indvars.iv.next2851, 21
  br i1 %exitcond2852, label %for.cond.1501.preheader.preheader, label %for.body.1354

for.cond.1501.preheader.preheader:                ; preds = %for.inc.1494
  br label %for.cond.1501.preheader

for.cond.1501.preheader:                          ; preds = %for.inc.1684.2, %for.cond.1501.preheader.preheader
  %indvars.iv2847 = phi i64 [ %indvars.iv.next2848, %for.inc.1684.2 ], [ 0, %for.cond.1501.preheader.preheader ]
  %arrayidx1530 = getelementptr inbounds [12 x double], [12 x double]* %L3psycho_anal.mld_s, i64 0, i64 %indvars.iv2847
  %arrayidx1508 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 0, i32 1, i64 %indvars.iv2847, i64 0
  %2 = load double, double* %arrayidx1508, align 8, !tbaa !0
  %arrayidx1512 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 1, i32 1, i64 %indvars.iv2847, i64 0
  %3 = load double, double* %arrayidx1512, align 8, !tbaa !0
  %mul1513 = fmul double %3, 1.580000e+00
  %cmp1514 = fcmp ugt double %2, %mul1513
  %mul1525 = fmul double %2, 1.580000e+00
  %cmp1526 = fcmp ugt double %3, %mul1525
  %or.cond2684 = or i1 %cmp1526, %cmp1514
  br i1 %or.cond2684, label %for.inc.1684, label %if.then.1528

for.inc.1684:                                     ; preds = %if.then.1528, %for.cond.1501.preheader
  %arrayidx1508.1 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 0, i32 1, i64 %indvars.iv2847, i64 1
  %4 = load double, double* %arrayidx1508.1, align 8, !tbaa !0
  %arrayidx1512.1 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 1, i32 1, i64 %indvars.iv2847, i64 1
  %5 = load double, double* %arrayidx1512.1, align 8, !tbaa !0
  %mul1513.1 = fmul double %5, 1.580000e+00
  %cmp1514.1 = fcmp ugt double %4, %mul1513.1
  %mul1525.1 = fmul double %4, 1.580000e+00
  %cmp1526.1 = fcmp ugt double %5, %mul1525.1
  %or.cond2684.1 = or i1 %cmp1526.1, %cmp1514.1
  br i1 %or.cond2684.1, label %for.inc.1684.1, label %if.then.1528.1

for.inc.1684.1:                                   ; preds = %if.then.1528.1, %for.inc.1684
  %arrayidx1508.2 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 0, i32 1, i64 %indvars.iv2847, i64 2
  %6 = load double, double* %arrayidx1508.2, align 8, !tbaa !0
  %arrayidx1512.2 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 1, i32 1, i64 %indvars.iv2847, i64 2
  %7 = load double, double* %arrayidx1512.2, align 8, !tbaa !0
  %mul1513.2 = fmul double %7, 1.580000e+00
  %cmp1514.2 = fcmp ugt double %6, %mul1513.2
  %mul1525.2 = fmul double %6, 1.580000e+00
  %cmp1526.2 = fcmp ugt double %7, %mul1525.2
  %or.cond2684.2 = or i1 %cmp1526.2, %cmp1514.2
  br i1 %or.cond2684.2, label %for.inc.1684.2, label %if.then.1528.2

for.inc.1684.2:                                   ; preds = %if.then.1528.2, %for.inc.1684.1
  %indvars.iv.next2848 = add nuw nsw i64 %indvars.iv2847, 1
  %exitcond2849 = icmp eq i64 %indvars.iv.next2848, 12
  br i1 %exitcond2849, label %if.end.1690.loopexit, label %for.cond.1501.preheader

if.end.1690.loopexit:                             ; preds = %for.inc.1684.2
  br label %if.end.1690.exitStub

if.then.1528.2:                                   ; preds = %for.inc.1684.1
  %8 = load double, double* %arrayidx1530, align 8, !tbaa !0
  %arrayidx1537.2 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.en, i64 0, i64 3, i32 1, i64 %indvars.iv2847, i64 2
  %9 = load double, double* %arrayidx1537.2, align 8, !tbaa !0
  %mul1538.2 = fmul double %8, %9
  %arrayidx1545.2 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 2, i32 1, i64 %indvars.iv2847, i64 2
  %10 = load double, double* %arrayidx1545.2, align 8, !tbaa !0
  %arrayidx1552.2 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 3, i32 1, i64 %indvars.iv2847, i64 2
  %11 = load double, double* %arrayidx1552.2, align 8, !tbaa !0
  %cmp1553.2 = fcmp olt double %11, %mul1538.2
  %.mul1538.2 = select i1 %cmp1553.2, double %11, double %mul1538.2
  %cmp1566.2 = fcmp ogt double %10, %.mul1538.2
  %cond1598.2 = select i1 %cmp1566.2, double %10, double %.mul1538.2
  %12 = load double, double* %arrayidx1530, align 8, !tbaa !0
  %arrayidx1607.2 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.en, i64 0, i64 2, i32 1, i64 %indvars.iv2847, i64 2
  %13 = load double, double* %arrayidx1607.2, align 8, !tbaa !0
  %mul1608.2 = fmul double %12, %13
  %14 = load double, double* %arrayidx1552.2, align 8, !tbaa !0
  %15 = load double, double* %arrayidx1545.2, align 8, !tbaa !0
  %cmp1623.2 = fcmp olt double %15, %mul1608.2
  %.mul1608.2 = select i1 %cmp1623.2, double %15, double %mul1608.2
  %cmp1636.2 = fcmp ogt double %14, %.mul1608.2
  %cond1668.2 = select i1 %cmp1636.2, double %14, double %.mul1608.2
  store double %cond1598.2, double* %arrayidx1545.2, align 8, !tbaa !0
  store double %cond1668.2, double* %arrayidx1552.2, align 8, !tbaa !0
  br label %for.inc.1684.2

if.then.1528.1:                                   ; preds = %for.inc.1684
  %16 = load double, double* %arrayidx1530, align 8, !tbaa !0
  %arrayidx1537.1 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.en, i64 0, i64 3, i32 1, i64 %indvars.iv2847, i64 1
  %17 = load double, double* %arrayidx1537.1, align 8, !tbaa !0
  %mul1538.1 = fmul double %16, %17
  %arrayidx1545.1 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 2, i32 1, i64 %indvars.iv2847, i64 1
  %18 = load double, double* %arrayidx1545.1, align 8, !tbaa !0
  %arrayidx1552.1 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 3, i32 1, i64 %indvars.iv2847, i64 1
  %19 = load double, double* %arrayidx1552.1, align 8, !tbaa !0
  %cmp1553.1 = fcmp olt double %19, %mul1538.1
  %.mul1538.1 = select i1 %cmp1553.1, double %19, double %mul1538.1
  %cmp1566.1 = fcmp ogt double %18, %.mul1538.1
  %cond1598.1 = select i1 %cmp1566.1, double %18, double %.mul1538.1
  %20 = load double, double* %arrayidx1530, align 8, !tbaa !0
  %arrayidx1607.1 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.en, i64 0, i64 2, i32 1, i64 %indvars.iv2847, i64 1
  %21 = load double, double* %arrayidx1607.1, align 8, !tbaa !0
  %mul1608.1 = fmul double %20, %21
  %22 = load double, double* %arrayidx1552.1, align 8, !tbaa !0
  %23 = load double, double* %arrayidx1545.1, align 8, !tbaa !0
  %cmp1623.1 = fcmp olt double %23, %mul1608.1
  %.mul1608.1 = select i1 %cmp1623.1, double %23, double %mul1608.1
  %cmp1636.1 = fcmp ogt double %22, %.mul1608.1
  %cond1668.1 = select i1 %cmp1636.1, double %22, double %.mul1608.1
  store double %cond1598.1, double* %arrayidx1545.1, align 8, !tbaa !0
  store double %cond1668.1, double* %arrayidx1552.1, align 8, !tbaa !0
  br label %for.inc.1684.1

if.then.1528:                                     ; preds = %for.cond.1501.preheader
  %24 = load double, double* %arrayidx1530, align 8, !tbaa !0
  %arrayidx1537 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.en, i64 0, i64 3, i32 1, i64 %indvars.iv2847, i64 0
  %25 = load double, double* %arrayidx1537, align 8, !tbaa !0
  %mul1538 = fmul double %24, %25
  %arrayidx1545 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 2, i32 1, i64 %indvars.iv2847, i64 0
  %26 = load double, double* %arrayidx1545, align 8, !tbaa !0
  %arrayidx1552 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 3, i32 1, i64 %indvars.iv2847, i64 0
  %27 = load double, double* %arrayidx1552, align 8, !tbaa !0
  %cmp1553 = fcmp olt double %27, %mul1538
  %.mul1538 = select i1 %cmp1553, double %27, double %mul1538
  %cmp1566 = fcmp ogt double %26, %.mul1538
  %cond1598 = select i1 %cmp1566, double %26, double %.mul1538
  %28 = load double, double* %arrayidx1530, align 8, !tbaa !0
  %arrayidx1607 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.en, i64 0, i64 2, i32 1, i64 %indvars.iv2847, i64 0
  %29 = load double, double* %arrayidx1607, align 8, !tbaa !0
  %mul1608 = fmul double %28, %29
  %30 = load double, double* %arrayidx1552, align 8, !tbaa !0
  %31 = load double, double* %arrayidx1545, align 8, !tbaa !0
  %cmp1623 = fcmp olt double %31, %mul1608
  %.mul1608 = select i1 %cmp1623, double %31, double %mul1608
  %cmp1636 = fcmp ogt double %30, %.mul1608
  %cond1668 = select i1 %cmp1636, double %30, double %.mul1608
  store double %cond1598, double* %arrayidx1545, align 8, !tbaa !0
  store double %cond1668, double* %arrayidx1552, align 8, !tbaa !0
  br label %for.inc.1684

if.then.1370:                                     ; preds = %for.body.1354
  %arrayidx1372 = getelementptr inbounds [21 x double], [21 x double]* %L3psycho_anal.mld_l, i64 0, i64 %indvars.iv2850
  %32 = load double, double* %arrayidx1372, align 8, !tbaa !0
  %arrayidx1377 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.en, i64 0, i64 3, i32 0, i64 %indvars.iv2850
  %33 = load double, double* %arrayidx1377, align 8, !tbaa !0
  %mul1378 = fmul double %32, %33
  %arrayidx1383 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 2, i32 0, i64 %indvars.iv2850
  %34 = load double, double* %arrayidx1383, align 8, !tbaa !0
  %arrayidx1388 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.thm, i64 0, i64 3, i32 0, i64 %indvars.iv2850
  %35 = load double, double* %arrayidx1388, align 8, !tbaa !0
  %cmp1389 = fcmp olt double %35, %mul1378
  %.mul1378 = select i1 %cmp1389, double %35, double %mul1378
  %cmp1400 = fcmp ogt double %34, %.mul1378
  %cond1426 = select i1 %cmp1400, double %34, double %.mul1378
  %36 = load double, double* %arrayidx1372, align 8, !tbaa !0
  %arrayidx1433 = getelementptr inbounds [4 x %struct.III_psy_xmin], [4 x %struct.III_psy_xmin]* %L3psycho_anal.en, i64 0, i64 2, i32 0, i64 %indvars.iv2850
  %37 = load double, double* %arrayidx1433, align 8, !tbaa !0
  %mul1434 = fmul double %36, %37
  %38 = load double, double* %arrayidx1388, align 8, !tbaa !0
  %39 = load double, double* %arrayidx1383, align 8, !tbaa !0
  %cmp1445 = fcmp olt double %39, %mul1434
  %.mul1434 = select i1 %cmp1445, double %39, double %mul1434
  %cmp1456 = fcmp ogt double %38, %.mul1434
  %cond1482 = select i1 %cmp1456, double %38, double %.mul1434
  store double %cond1426, double* %arrayidx1383, align 8, !tbaa !0
  store double %cond1482, double* %arrayidx1388, align 8, !tbaa !0
  br label %for.inc.1494
}

attributes #0 = { nounwind "polyjit-global-count"="4" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
