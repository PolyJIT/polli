
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/stencils/adi/adi.c.main_for.cond.1.preheader.i.37.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.1.preheader.i.37.pjit.scop([1024 x double]* %arraydecay, [1024 x double]* %arraydecay3, [1024 x double]* %arraydecay4)  {
newFuncRoot:
  br label %for.cond.1.preheader.i.37

kernel_adi.exit.exitStub:                         ; preds = %for.inc.252.i
  ret void

for.cond.1.preheader.i.37:                        ; preds = %for.inc.252.i, %newFuncRoot
  %t.011.i = phi i32 [ %inc253.i, %for.inc.252.i ], [ 0, %newFuncRoot ]
  br label %for.cond.4.preheader.i

for.cond.4.preheader.i:                           ; preds = %for.inc.51.i, %for.cond.1.preheader.i.37
  %indvars.iv13.i = phi i64 [ 0, %for.cond.1.preheader.i.37 ], [ %indvars.iv.next14.i, %for.inc.51.i ]
  br label %for.body.6.i

for.body.6.i:                                     ; preds = %for.body.6.i, %for.cond.4.preheader.i
  %indvars.iv.i.38 = phi i64 [ 1, %for.cond.4.preheader.i ], [ %indvars.iv.next.i.43, %for.body.6.i ]
  %arrayidx8.i.39 = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv13.i, i64 %indvars.iv.i.38
  %0 = load double, double* %arrayidx8.i.39, align 8, !tbaa !0
  %1 = add nsw i64 %indvars.iv.i.38, -1
  %arrayidx12.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv13.i, i64 %1
  %2 = load double, double* %arrayidx12.i, align 8, !tbaa !0
  %arrayidx16.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay3, i64 %indvars.iv13.i, i64 %indvars.iv.i.38
  %3 = load double, double* %arrayidx16.i, align 8, !tbaa !0
  %mul.i.40 = fmul double %2, %3
  %arrayidx21.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %indvars.iv13.i, i64 %1
  %4 = load double, double* %arrayidx21.i, align 8, !tbaa !0
  %div.i.41 = fdiv double %mul.i.40, %4
  %sub22.i = fsub double %0, %div.i.41
  store double %sub22.i, double* %arrayidx8.i.39, align 8, !tbaa !0
  %arrayidx30.i.42 = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %indvars.iv13.i, i64 %indvars.iv.i.38
  %5 = load double, double* %arrayidx30.i.42, align 8, !tbaa !0
  %6 = load double, double* %arrayidx16.i, align 8, !tbaa !0
  %mul39.i = fmul double %6, %6
  %7 = load double, double* %arrayidx21.i, align 8, !tbaa !0
  %div45.i = fdiv double %mul39.i, %7
  %sub46.i = fsub double %5, %div45.i
  store double %sub46.i, double* %arrayidx30.i.42, align 8, !tbaa !0
  %indvars.iv.next.i.43 = add nuw nsw i64 %indvars.iv.i.38, 1
  %exitcond.i.44 = icmp eq i64 %indvars.iv.next.i.43, 1024
  br i1 %exitcond.i.44, label %for.inc.51.i, label %for.body.6.i

for.inc.51.i:                                     ; preds = %for.body.6.i
  %indvars.iv.next14.i = add nuw nsw i64 %indvars.iv13.i, 1
  %exitcond15.i = icmp eq i64 %indvars.iv.next14.i, 1024
  br i1 %exitcond15.i, label %for.body.56.i.preheader, label %for.cond.4.preheader.i

for.body.56.i.preheader:                          ; preds = %for.inc.51.i
  br label %for.body.56.i

for.body.56.i:                                    ; preds = %for.body.56.i, %for.body.56.i.preheader
  %indvars.iv16.i = phi i64 [ %indvars.iv.next17.i, %for.body.56.i ], [ 0, %for.body.56.i.preheader ]
  %arrayidx61.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv16.i, i64 1023
  %8 = load double, double* %arrayidx61.i, align 8, !tbaa !0
  %arrayidx66.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %indvars.iv16.i, i64 1023
  %9 = load double, double* %arrayidx66.i, align 8, !tbaa !0
  %div67.i = fdiv double %8, %9
  store double %div67.i, double* %arrayidx61.i, align 8, !tbaa !0
  %indvars.iv.next17.i = add nuw nsw i64 %indvars.iv16.i, 1
  %exitcond18.i = icmp eq i64 %indvars.iv.next17.i, 1024
  br i1 %exitcond18.i, label %for.cond.79.preheader.i.preheader, label %for.body.56.i

for.cond.79.preheader.i.preheader:                ; preds = %for.body.56.i
  br label %for.cond.79.preheader.i

for.cond.79.preheader.i:                          ; preds = %for.inc.120.i, %for.cond.79.preheader.i.preheader
  %indvars.iv28.i = phi i64 [ %indvars.iv.next29.i, %for.inc.120.i ], [ 0, %for.cond.79.preheader.i.preheader ]
  br label %for.body.82.i

for.body.82.i:                                    ; preds = %for.body.82.i, %for.cond.79.preheader.i
  %indvars.iv19.i = phi i64 [ 0, %for.cond.79.preheader.i ], [ %indvars.iv.next20.i, %for.body.82.i ]
  %10 = sub nuw nsw i64 1022, %indvars.iv19.i
  %arrayidx88.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv28.i, i64 %10
  %11 = load double, double* %arrayidx88.i, align 8, !tbaa !0
  %12 = add nsw i64 %10, -1
  %arrayidx95.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv28.i, i64 %12
  %13 = load double, double* %arrayidx95.i, align 8, !tbaa !0
  %14 = sub nuw nsw i64 1024, %indvars.iv19.i
  %15 = add nsw i64 %14, -3
  %arrayidx101.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay3, i64 %indvars.iv28.i, i64 %15
  %16 = load double, double* %arrayidx101.i, align 8, !tbaa !0
  %mul102.i = fmul double %13, %16
  %sub103.i = fsub double %11, %mul102.i
  %17 = sub nuw nsw i64 1021, %indvars.iv19.i
  %arrayidx109.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %indvars.iv28.i, i64 %17
  %18 = load double, double* %arrayidx109.i, align 8, !tbaa !0
  %div110.i = fdiv double %sub103.i, %18
  %19 = add nsw i64 %14, -2
  %arrayidx116.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv28.i, i64 %19
  store double %div110.i, double* %arrayidx116.i, align 8, !tbaa !0
  %indvars.iv.next20.i = add nuw nsw i64 %indvars.iv19.i, 1
  %exitcond27.i = icmp eq i64 %indvars.iv.next20.i, 1022
  br i1 %exitcond27.i, label %for.inc.120.i, label %for.body.82.i

for.inc.120.i:                                    ; preds = %for.body.82.i
  %indvars.iv.next29.i = add nuw nsw i64 %indvars.iv28.i, 1
  %exitcond30.i = icmp eq i64 %indvars.iv.next29.i, 1024
  br i1 %exitcond30.i, label %for.cond.126.preheader.i.preheader, label %for.cond.79.preheader.i

for.cond.126.preheader.i.preheader:               ; preds = %for.inc.120.i
  br label %for.cond.126.preheader.i

for.cond.126.preheader.i:                         ; preds = %for.inc.181.i, %for.cond.126.preheader.i.preheader
  %indvars.iv34.i = phi i64 [ %indvars.iv.next35.i, %for.inc.181.i ], [ 1, %for.cond.126.preheader.i.preheader ]
  %20 = add nsw i64 %indvars.iv34.i, -1
  br label %for.body.128.i

for.body.128.i:                                   ; preds = %for.body.128.i, %for.cond.126.preheader.i
  %indvars.iv31.i = phi i64 [ 0, %for.cond.126.preheader.i ], [ %indvars.iv.next32.i, %for.body.128.i ]
  %arrayidx132.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %indvars.iv34.i, i64 %indvars.iv31.i
  %21 = load double, double* %arrayidx132.i, align 8, !tbaa !0
  %arrayidx137.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %20, i64 %indvars.iv31.i
  %22 = load double, double* %arrayidx137.i, align 8, !tbaa !0
  %arrayidx141.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay3, i64 %indvars.iv34.i, i64 %indvars.iv31.i
  %23 = load double, double* %arrayidx141.i, align 8, !tbaa !0
  %mul142.i = fmul double %22, %23
  %arrayidx147.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %20, i64 %indvars.iv31.i
  %24 = load double, double* %arrayidx147.i, align 8, !tbaa !0
  %div148.i = fdiv double %mul142.i, %24
  %sub149.i = fsub double %21, %div148.i
  store double %sub149.i, double* %arrayidx132.i, align 8, !tbaa !0
  %arrayidx157.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %indvars.iv34.i, i64 %indvars.iv31.i
  %25 = load double, double* %arrayidx157.i, align 8, !tbaa !0
  %26 = load double, double* %arrayidx141.i, align 8, !tbaa !0
  %mul166.i = fmul double %26, %26
  %27 = load double, double* %arrayidx147.i, align 8, !tbaa !0
  %div172.i = fdiv double %mul166.i, %27
  %sub173.i = fsub double %25, %div172.i
  store double %sub173.i, double* %arrayidx157.i, align 8, !tbaa !0
  %indvars.iv.next32.i = add nuw nsw i64 %indvars.iv31.i, 1
  %exitcond33.i = icmp eq i64 %indvars.iv.next32.i, 1024
  br i1 %exitcond33.i, label %for.inc.181.i, label %for.body.128.i

for.inc.181.i:                                    ; preds = %for.body.128.i
  %indvars.iv.next35.i = add nuw nsw i64 %indvars.iv34.i, 1
  %exitcond37.i = icmp eq i64 %indvars.iv.next35.i, 1024
  br i1 %exitcond37.i, label %for.body.186.i.preheader, label %for.cond.126.preheader.i

for.body.186.i.preheader:                         ; preds = %for.inc.181.i
  br label %for.body.186.i

for.body.186.i:                                   ; preds = %for.body.186.i, %for.body.186.i.preheader
  %indvars.iv38.i = phi i64 [ %indvars.iv.next39.i, %for.body.186.i ], [ 0, %for.body.186.i.preheader ]
  %arrayidx191.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 1023, i64 %indvars.iv38.i
  %28 = load double, double* %arrayidx191.i, align 8, !tbaa !0
  %arrayidx196.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 1023, i64 %indvars.iv38.i
  %29 = load double, double* %arrayidx196.i, align 8, !tbaa !0
  %div197.i = fdiv double %28, %29
  store double %div197.i, double* %arrayidx191.i, align 8, !tbaa !0
  %indvars.iv.next39.i = add nuw nsw i64 %indvars.iv38.i, 1
  %exitcond40.i = icmp eq i64 %indvars.iv.next39.i, 1024
  br i1 %exitcond40.i, label %for.cond.210.preheader.i.preheader, label %for.body.186.i

for.cond.210.preheader.i.preheader:               ; preds = %for.body.186.i
  br label %for.cond.210.preheader.i

for.cond.210.preheader.i:                         ; preds = %for.inc.249.i, %for.cond.210.preheader.i.preheader
  %indvars.iv44.i = phi i64 [ %indvars.iv.next45.i, %for.inc.249.i ], [ 0, %for.cond.210.preheader.i.preheader ]
  %30 = sub nuw nsw i64 1022, %indvars.iv44.i
  %31 = sub nuw nsw i64 1021, %indvars.iv44.i
  br label %for.body.212.i

for.body.212.i:                                   ; preds = %for.body.212.i, %for.cond.210.preheader.i
  %indvars.iv41.i = phi i64 [ 0, %for.cond.210.preheader.i ], [ %indvars.iv.next42.i, %for.body.212.i ]
  %arrayidx218.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %30, i64 %indvars.iv41.i
  %32 = load double, double* %arrayidx218.i, align 8, !tbaa !0
  %arrayidx224.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay, i64 %31, i64 %indvars.iv41.i
  %33 = load double, double* %arrayidx224.i, align 8, !tbaa !0
  %arrayidx230.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay3, i64 %31, i64 %indvars.iv41.i
  %34 = load double, double* %arrayidx230.i, align 8, !tbaa !0
  %mul231.i = fmul double %33, %34
  %sub232.i = fsub double %32, %mul231.i
  %arrayidx238.i = getelementptr inbounds [1024 x double], [1024 x double]* %arraydecay4, i64 %30, i64 %indvars.iv41.i
  %35 = load double, double* %arrayidx238.i, align 8, !tbaa !0
  %div239.i = fdiv double %sub232.i, %35
  store double %div239.i, double* %arrayidx218.i, align 8, !tbaa !0
  %indvars.iv.next42.i = add nuw nsw i64 %indvars.iv41.i, 1
  %exitcond43.i = icmp eq i64 %indvars.iv.next42.i, 1024
  br i1 %exitcond43.i, label %for.inc.249.i, label %for.body.212.i

for.inc.249.i:                                    ; preds = %for.body.212.i
  %indvars.iv.next45.i = add nuw nsw i64 %indvars.iv44.i, 1
  %exitcond49.i = icmp eq i64 %indvars.iv.next45.i, 1022
  br i1 %exitcond49.i, label %for.inc.252.i, label %for.cond.210.preheader.i

for.inc.252.i:                                    ; preds = %for.inc.249.i
  %inc253.i = add nuw nsw i32 %t.011.i, 1
  %exitcond50.i = icmp eq i32 %inc253.i, 50
  br i1 %exitcond50.i, label %kernel_adi.exit.exitStub, label %for.cond.1.preheader.i.37
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
