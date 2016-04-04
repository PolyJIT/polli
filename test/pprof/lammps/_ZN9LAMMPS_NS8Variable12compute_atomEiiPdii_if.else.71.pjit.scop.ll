
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polli-process-unprofitable -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '../variable.cpp._ZN9LAMMPS_NS8Variable12compute_atomEiiPdii_if.else.71.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZN9LAMMPS_NS8Variable12compute_atomEiiPdii_if.else.71.pjit.scop(i1 %cmp35, i1 %cmp37.190, i32 %stride, i32*, i32, double* %result, i32, double* %vstore.0)  {
newFuncRoot:
  br label %if.else.71

if.end.120.exitStub:                              ; preds = %if.end.120.loopexit227, %for.cond.100.preheader, %if.end.120.loopexit226, %for.cond.76.preheader
  ret void

if.else.71:                                       ; preds = %newFuncRoot
  br i1 %cmp35, label %for.cond.76.preheader, label %for.cond.100.preheader

for.cond.76.preheader:                            ; preds = %if.else.71
  br i1 %cmp37.190, label %for.body.79.preheader, label %if.end.120.exitStub

for.body.79.preheader:                            ; preds = %for.cond.76.preheader
  %3 = sext i32 %stride to i64
  br label %for.body.79

for.body.79:                                      ; preds = %if.end.92, %for.body.79.preheader
  %indvars.iv215 = phi i64 [ 0, %for.body.79.preheader ], [ %indvars.iv.next216, %if.end.92 ]
  %indvars.iv213 = phi i64 [ 0, %for.body.79.preheader ], [ %indvars.iv.next214, %if.end.92 ]
  %arrayidx81 = getelementptr inbounds i32, i32* %0, i64 %indvars.iv213
  %4 = load i32, i32* %arrayidx81, align 4, !tbaa !0
  %and82 = and i32 %4, %1
  %tobool83 = icmp eq i32 %and82, 0
  br i1 %tobool83, label %if.else.89, label %if.then.84

if.else.89:                                       ; preds = %for.body.79
  %arrayidx91 = getelementptr inbounds double, double* %result, i64 %indvars.iv215
  store double 0.000000e+00, double* %arrayidx91, align 8, !tbaa !4
  br label %if.end.92

if.end.92:                                        ; preds = %if.then.84, %if.else.89
  %indvars.iv.next216 = add i64 %indvars.iv215, %3
  %indvars.iv.next214 = add nuw nsw i64 %indvars.iv213, 1
  %lftr.wideiv230 = trunc i64 %indvars.iv.next214 to i32
  %exitcond231 = icmp eq i32 %lftr.wideiv230, %2
  br i1 %exitcond231, label %if.end.120.loopexit226, label %for.body.79

if.end.120.loopexit226:                           ; preds = %if.end.92
  br label %if.end.120.exitStub

if.then.84:                                       ; preds = %for.body.79
  %arrayidx86 = getelementptr inbounds double, double* %vstore.0, i64 %indvars.iv213
  %5 = bitcast double* %arrayidx86 to i64*
  %6 = load i64, i64* %5, align 8, !tbaa !4
  %arrayidx88 = getelementptr inbounds double, double* %result, i64 %indvars.iv215
  %7 = bitcast double* %arrayidx88 to i64*
  store i64 %6, i64* %7, align 8, !tbaa !4
  br label %if.end.92

for.cond.100.preheader:                           ; preds = %if.else.71
  br i1 %cmp37.190, label %for.body.103.preheader, label %if.end.120.exitStub

for.body.103.preheader:                           ; preds = %for.cond.100.preheader
  %8 = sext i32 %stride to i64
  br label %for.body.103

for.body.103:                                     ; preds = %if.end.114, %for.body.103.preheader
  %indvars.iv221 = phi i64 [ 0, %for.body.103.preheader ], [ %indvars.iv.next222, %if.end.114 ]
  %indvars.iv219 = phi i64 [ 0, %for.body.103.preheader ], [ %indvars.iv.next220, %if.end.114 ]
  %arrayidx105 = getelementptr inbounds i32, i32* %0, i64 %indvars.iv219
  %9 = load i32, i32* %arrayidx105, align 4, !tbaa !0
  %and106 = and i32 %9, %1
  %tobool107 = icmp eq i32 %and106, 0
  br i1 %tobool107, label %if.end.114, label %if.then.108

if.end.114:                                       ; preds = %if.then.108, %for.body.103
  %indvars.iv.next222 = add i64 %indvars.iv221, %8
  %indvars.iv.next220 = add nuw nsw i64 %indvars.iv219, 1
  %lftr.wideiv232 = trunc i64 %indvars.iv.next220 to i32
  %exitcond233 = icmp eq i32 %lftr.wideiv232, %2
  br i1 %exitcond233, label %if.end.120.loopexit227, label %for.body.103

if.end.120.loopexit227:                           ; preds = %if.end.114
  br label %if.end.120.exitStub

if.then.108:                                      ; preds = %for.body.103
  %arrayidx110 = getelementptr inbounds double, double* %vstore.0, i64 %indvars.iv219
  %10 = load double, double* %arrayidx110, align 8, !tbaa !4
  %arrayidx112 = getelementptr inbounds double, double* %result, i64 %indvars.iv221
  %11 = load double, double* %arrayidx112, align 8, !tbaa !4
  %add113 = fadd double %10, %11
  store double %add113, double* %arrayidx112, align 8, !tbaa !4
  br label %if.end.114
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"double", !2, i64 0}
