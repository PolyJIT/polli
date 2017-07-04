
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SingleSourceBenchmarks/test-suite/SingleSource/Benchmarks/Polybench/linear-algebra/kernels/trisolv/trisolv.c.main_for.body.i.37.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.i.37.pjit.scop(double* %arraydecay4, double* %arraydecay3, [4000 x double]* %arraydecay)  {
newFuncRoot:
  br label %for.body.i.37

kernel_trisolv.exit.exitStub:                     ; preds = %for.end.i
  ret void

for.body.i.37:                                    ; preds = %for.end.i, %newFuncRoot
  %indvars.iv48 = phi i32 [ 0, %newFuncRoot ], [ %indvars.iv.next49, %for.end.i ]
  %indvars.iv7.i = phi i64 [ %indvars.iv.next8.i, %for.end.i ], [ 0, %newFuncRoot ]
  %arrayidx.i.36 = getelementptr inbounds double, double* %arraydecay4, i64 %indvars.iv7.i
  %0 = bitcast double* %arrayidx.i.36 to i64*
  %1 = load i64, i64* %0, align 8, !tbaa !0
  %arrayidx2.i = getelementptr inbounds double, double* %arraydecay3, i64 %indvars.iv7.i
  %2 = bitcast double* %arrayidx2.i to i64*
  store i64 %1, i64* %2, align 8, !tbaa !0
  %cmp4.1.i = icmp sgt i64 %indvars.iv7.i, 0
  %.cast.i = bitcast i64 %1 to double
  br i1 %cmp4.1.i, label %for.body.5.i.preheader, label %for.end.i

for.body.5.i.preheader:                           ; preds = %for.body.i.37
  br label %for.body.5.i

for.body.5.i:                                     ; preds = %for.body.5.i, %for.body.5.i.preheader
  %indvars.iv.i.38 = phi i64 [ %indvars.iv.next.i.40, %for.body.5.i ], [ 0, %for.body.5.i.preheader ]
  %3 = phi double [ %sub14.i, %for.body.5.i ], [ %.cast.i, %for.body.5.i.preheader ]
  %arrayidx11.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay, i64 %indvars.iv7.i, i64 %indvars.iv.i.38
  %4 = load double, double* %arrayidx11.i, align 8, !tbaa !0
  %arrayidx13.i = getelementptr inbounds double, double* %arraydecay3, i64 %indvars.iv.i.38
  %5 = load double, double* %arrayidx13.i, align 8, !tbaa !0
  %mul.i.39 = fmul double %4, %5
  %sub14.i = fsub double %3, %mul.i.39
  store double %sub14.i, double* %arrayidx2.i, align 8, !tbaa !0
  %indvars.iv.next.i.40 = add nuw nsw i64 %indvars.iv.i.38, 1
  %lftr.wideiv50 = trunc i64 %indvars.iv.next.i.40 to i32
  %exitcond51 = icmp eq i32 %lftr.wideiv50, %indvars.iv48
  br i1 %exitcond51, label %for.end.i.loopexit, label %for.body.5.i

for.end.i.loopexit:                               ; preds = %for.body.5.i
  %sub14.i.lcssa = phi double [ %sub14.i, %for.body.5.i ]
  br label %for.end.i

for.end.i:                                        ; preds = %for.end.i.loopexit, %for.body.i.37
  %.lcssa.i = phi double [ %.cast.i, %for.body.i.37 ], [ %sub14.i.lcssa, %for.end.i.loopexit ]
  %arrayidx22.i = getelementptr inbounds [4000 x double], [4000 x double]* %arraydecay, i64 %indvars.iv7.i, i64 %indvars.iv7.i
  %6 = load double, double* %arrayidx22.i, align 8, !tbaa !0
  %div.i.41 = fdiv double %.lcssa.i, %6
  store double %div.i.41, double* %arrayidx2.i, align 8, !tbaa !0
  %indvars.iv.next8.i = add nuw nsw i64 %indvars.iv7.i, 1
  %indvars.iv.next49 = add nuw nsw i32 %indvars.iv48, 1
  %exitcond9.i = icmp eq i64 %indvars.iv.next8.i, 4000
  br i1 %exitcond9.i, label %kernel_trisolv.exit.exitStub, label %for.body.i.37
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
