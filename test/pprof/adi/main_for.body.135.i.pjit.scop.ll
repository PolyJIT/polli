
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'adi.dir/adi.c.main_for.body.135.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.body.135.i.pjit.scop(double*, double*, double*, double*)  {
newFuncRoot:
  br label %for.body.135.i

for.inc.245.i.exitStub:                           ; preds = %for.inc.242.i
  ret void

for.body.135.i:                                   ; preds = %for.inc.242.i, %newFuncRoot
  %indvars.iv33.i = phi i64 [ %indvars.iv.next34.i, %for.inc.242.i ], [ 1, %newFuncRoot ]
  %4 = mul nuw nsw i64 %indvars.iv33.i, 1000
  %arrayidx137.i = getelementptr inbounds double, double* %0, i64 %4
  store double 1.000000e+00, double* %arrayidx137.i, align 8, !tbaa !0
  %arrayidx140.i = getelementptr inbounds double, double* %1, i64 %4
  store double 0.000000e+00, double* %arrayidx140.i, align 8, !tbaa !0
  %5 = bitcast double* %arrayidx137.i to i64*
  %6 = load i64, i64* %5, align 8, !tbaa !0
  %arrayidx146.i = getelementptr inbounds double, double* %2, i64 %4
  %7 = bitcast double* %arrayidx146.i to i64*
  store i64 %6, i64* %7, align 8, !tbaa !0
  %8 = add nsw i64 %4, -1000
  %arrayidx170.i = getelementptr inbounds double, double* %3, i64 %8
  %arrayidx177.i = getelementptr inbounds double, double* %3, i64 %4
  %indvars.iv.next34.i = add nuw nsw i64 %indvars.iv33.i, 1
  %9 = mul nuw nsw i64 %indvars.iv.next34.i, 1000
  %arrayidx184.i = getelementptr inbounds double, double* %3, i64 %9
  br label %for.body.152.i

for.body.152.i:                                   ; preds = %for.body.152.i, %for.body.135.i
  %indvars.iv26.i = phi i64 [ 1, %for.body.135.i ], [ %indvars.iv.next27.i, %for.body.152.i ]
  %10 = add nsw i64 %indvars.iv26.i, -1
  %arrayidx158.i = getelementptr inbounds double, double* %arrayidx140.i, i64 %10
  %11 = load double, double* %arrayidx158.i, align 8, !tbaa !0
  %mul159.i = fmul double %11, 0x408F400000000001
  %add1606.i = fsub double 0x409F440000000001, %mul159.i
  %div161.i = fdiv double 0x408F400000000001, %add1606.i
  %arrayidx165.i = getelementptr inbounds double, double* %arrayidx140.i, i64 %indvars.iv26.i
  store double %div161.i, double* %arrayidx165.i, align 8, !tbaa !0
  %arrayidx171.i = getelementptr inbounds double, double* %arrayidx170.i, i64 %indvars.iv26.i
  %12 = load double, double* %arrayidx171.i, align 8, !tbaa !0
  %mul172.i = fmul double %12, 0x409F400000000001
  %arrayidx178.i = getelementptr inbounds double, double* %arrayidx177.i, i64 %indvars.iv26.i
  %13 = load double, double* %arrayidx178.i, align 8, !tbaa !0
  %mul179.i = fmul double %13, 0x40AF3E0000000001
  %add1807.i = fsub double %mul172.i, %mul179.i
  %arrayidx185.i = getelementptr inbounds double, double* %arrayidx184.i, i64 %indvars.iv26.i
  %14 = load double, double* %arrayidx185.i, align 8, !tbaa !0
  %mul186.i = fmul double %14, 0x409F400000000001
  %sub1878.i = fadd double %add1807.i, %mul186.i
  %arrayidx192.i = getelementptr inbounds double, double* %arrayidx146.i, i64 %10
  %15 = load double, double* %arrayidx192.i, align 8, !tbaa !0
  %mul193.i = fmul double %15, 0x408F400000000001
  %sub1949.i = fadd double %sub1878.i, %mul193.i
  %16 = load double, double* %arrayidx158.i, align 8, !tbaa !0
  %mul200.i = fmul double %16, 0x408F400000000001
  %add20110.i = fsub double 0x409F440000000001, %mul200.i
  %div202.i = fdiv double %sub1949.i, %add20110.i
  %arrayidx206.i = getelementptr inbounds double, double* %arrayidx146.i, i64 %indvars.iv26.i
  store double %div202.i, double* %arrayidx206.i, align 8, !tbaa !0
  %indvars.iv.next27.i = add nuw nsw i64 %indvars.iv26.i, 1
  %exitcond29.i = icmp eq i64 %indvars.iv.next27.i, 999
  br i1 %exitcond29.i, label %for.end.209.i, label %for.body.152.i

for.end.209.i:                                    ; preds = %for.body.152.i
  %arrayidx214.i = getelementptr inbounds double, double* %arrayidx137.i, i64 999
  store double 1.000000e+00, double* %arrayidx214.i, align 8, !tbaa !0
  br label %for.body.219.i

for.body.219.i:                                   ; preds = %for.body.219.i, %for.end.209.i
  %indvars.iv30.i = phi i64 [ 998, %for.end.209.i ], [ %indvars.iv.next31.i, %for.body.219.i ]
  %arrayidx223.i = getelementptr inbounds double, double* %arrayidx140.i, i64 %indvars.iv30.i
  %17 = load double, double* %arrayidx223.i, align 8, !tbaa !0
  %18 = add nuw nsw i64 %indvars.iv30.i, 1
  %arrayidx228.i = getelementptr inbounds double, double* %arrayidx137.i, i64 %18
  %19 = load double, double* %arrayidx228.i, align 8, !tbaa !0
  %mul229.i = fmul double %17, %19
  %arrayidx233.i = getelementptr inbounds double, double* %arrayidx146.i, i64 %indvars.iv30.i
  %20 = load double, double* %arrayidx233.i, align 8, !tbaa !0
  %add234.i = fadd double %mul229.i, %20
  %arrayidx238.i = getelementptr inbounds double, double* %arrayidx137.i, i64 %indvars.iv30.i
  store double %add234.i, double* %arrayidx238.i, align 8, !tbaa !0
  %indvars.iv.next31.i = add nsw i64 %indvars.iv30.i, -1
  %cmp217.i = icmp sgt i64 %indvars.iv30.i, 1
  br i1 %cmp217.i, label %for.body.219.i, label %for.inc.242.i

for.inc.242.i:                                    ; preds = %for.body.219.i
  %exitcond36.i = icmp eq i64 %indvars.iv.next34.i, 999
  br i1 %exitcond36.i, label %for.inc.245.i.exitStub, label %for.body.135.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
