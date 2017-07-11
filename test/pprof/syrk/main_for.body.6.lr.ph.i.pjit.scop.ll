
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'syrk.dir/syrk.c.main_for.body.6.lr.ph.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.6.lr.ph.i.pjit.scop(double*, double*)  {
newFuncRoot:
  br label %for.body.6.lr.ph.i

kernel_syrk.exit.exitStub:                        ; preds = %for.inc.36.i
  ret void

for.body.6.lr.ph.i:                               ; preds = %for.inc.36.i, %newFuncRoot
  %indvars.iv121 = phi i32 [ 1, %newFuncRoot ], [ %indvars.iv.next122, %for.inc.36.i ]
  %indvars.iv20.i = phi i64 [ %indvars.iv.next21.i, %for.inc.36.i ], [ 0, %newFuncRoot ]
  %2 = mul nuw nsw i64 %indvars.iv20.i, 1200
  %arrayidx.i.106 = getelementptr inbounds double, double* %0, i64 %2
  br label %for.body.6.i.109

for.body.6.i.109:                                 ; preds = %for.body.6.i.109, %for.body.6.lr.ph.i
  %indvars.iv.i.107 = phi i64 [ %indvars.iv.next.i.108, %for.body.6.i.109 ], [ 0, %for.body.6.lr.ph.i ]
  %arrayidx8.i = getelementptr inbounds double, double* %arrayidx.i.106, i64 %indvars.iv.i.107
  %3 = load double, double* %arrayidx8.i, align 8, !tbaa !0
  %mul.i = fmul double %3, 1.200000e+00
  store double %mul.i, double* %arrayidx8.i, align 8, !tbaa !0
  %indvars.iv.next.i.108 = add nuw nsw i64 %indvars.iv.i.107, 1
  %lftr.wideiv119 = trunc i64 %indvars.iv.next.i.108 to i32
  %exitcond120 = icmp eq i32 %lftr.wideiv119, %indvars.iv121
  br i1 %exitcond120, label %for.cond.9.preheader.i, label %for.body.6.i.109

for.cond.9.preheader.i:                           ; preds = %for.body.6.i.109
  %4 = mul nuw nsw i64 %indvars.iv20.i, 1000
  %arrayidx17.i = getelementptr inbounds double, double* %1, i64 %4
  br label %for.body.14.lr.ph.i

for.body.14.lr.ph.i:                              ; preds = %for.inc.33.i.112, %for.cond.9.preheader.i
  %indvars.iv16.i = phi i64 [ 0, %for.cond.9.preheader.i ], [ %indvars.iv.next17.i, %for.inc.33.i.112 ]
  %arrayidx18.i = getelementptr inbounds double, double* %arrayidx17.i, i64 %indvars.iv16.i
  br label %for.body.14.i

for.body.14.i:                                    ; preds = %for.body.14.i, %for.body.14.lr.ph.i
  %indvars.iv10.i = phi i64 [ %indvars.iv.next11.i, %for.body.14.i ], [ 0, %for.body.14.lr.ph.i ]
  %5 = load double, double* %arrayidx18.i, align 8, !tbaa !0
  %mul19.i = fmul double %5, 1.500000e+00
  %6 = mul nuw nsw i64 %indvars.iv10.i, 1000
  %arrayidx22.i = getelementptr inbounds double, double* %1, i64 %6
  %arrayidx23.i = getelementptr inbounds double, double* %arrayidx22.i, i64 %indvars.iv16.i
  %7 = load double, double* %arrayidx23.i, align 8, !tbaa !0
  %mul24.i = fmul double %mul19.i, %7
  %arrayidx28.i.110 = getelementptr inbounds double, double* %arrayidx.i.106, i64 %indvars.iv10.i
  %8 = load double, double* %arrayidx28.i.110, align 8, !tbaa !0
  %add29.i = fadd double %8, %mul24.i
  store double %add29.i, double* %arrayidx28.i.110, align 8, !tbaa !0
  %indvars.iv.next11.i = add nuw nsw i64 %indvars.iv10.i, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next11.i to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %indvars.iv121
  br i1 %exitcond, label %for.inc.33.i.112, label %for.body.14.i

for.inc.33.i.112:                                 ; preds = %for.body.14.i
  %indvars.iv.next17.i = add nuw nsw i64 %indvars.iv16.i, 1
  %exitcond18.i = icmp eq i64 %indvars.iv.next17.i, 1000
  br i1 %exitcond18.i, label %for.inc.36.i, label %for.body.14.lr.ph.i

for.inc.36.i:                                     ; preds = %for.inc.33.i.112
  %indvars.iv.next21.i = add nuw nsw i64 %indvars.iv20.i, 1
  %indvars.iv.next122 = add nuw nsw i32 %indvars.iv121, 1
  %exitcond22.i = icmp eq i64 %indvars.iv.next21.i, 1200
  br i1 %exitcond22.i, label %kernel_syrk.exit.exitStub, label %for.body.6.lr.ph.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
