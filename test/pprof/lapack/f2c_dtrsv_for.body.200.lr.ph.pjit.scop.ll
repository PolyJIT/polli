
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'dtrsv.c.f2c_dtrsv_for.body.200.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_dtrsv_for.body.200.lr.ph.pjit.scop(i64 %call40, double* %incdec.ptr, i64, double* %add.ptr, i64)  {
newFuncRoot:
  br label %for.body.200.lr.ph

cleanup.exitStub:                                 ; preds = %cleanup.loopexit695, %cleanup.loopexit
  ret void

for.body.200.lr.ph:                               ; preds = %newFuncRoot
  %tobool215 = icmp eq i64 %call40, 0
  br i1 %tobool215, label %for.body.200.us.preheader, label %for.body.200.preheader

for.body.200.us.preheader:                        ; preds = %for.body.200.lr.ph
  br label %for.body.200.us

for.body.200.us:                                  ; preds = %if.end.221.us, %for.body.200.us.preheader
  %indvars.iv = phi i64 [ %indvars.iv.next, %if.end.221.us ], [ 1, %for.body.200.us.preheader ]
  %arrayidx201.us = getelementptr inbounds double, double* %incdec.ptr, i64 %indvars.iv
  %2 = load double, double* %arrayidx201.us, align 8, !tbaa !0
  %cmp204.598.us = icmp sgt i64 %indvars.iv, 1
  br i1 %cmp204.598.us, label %for.body.205.lr.ph.us, label %if.end.221.us

for.body.205.lr.ph.us:                            ; preds = %for.body.200.us
  %mul206.us = mul nsw i64 %indvars.iv, %0
  br label %for.body.205.us

for.body.205.us:                                  ; preds = %for.body.205.us, %for.body.205.lr.ph.us
  %temp.0600.us = phi double [ %2, %for.body.205.lr.ph.us ], [ %sub211.us, %for.body.205.us ]
  %i__.4599.us = phi i64 [ 1, %for.body.205.lr.ph.us ], [ %inc213.us, %for.body.205.us ]
  %add207.us = add nsw i64 %i__.4599.us, %mul206.us
  %arrayidx208.us = getelementptr inbounds double, double* %add.ptr, i64 %add207.us
  %3 = load double, double* %arrayidx208.us, align 8, !tbaa !0
  %arrayidx209.us = getelementptr inbounds double, double* %incdec.ptr, i64 %i__.4599.us
  %4 = load double, double* %arrayidx209.us, align 8, !tbaa !0
  %mul210.us = fmul double %3, %4
  %sub211.us = fsub double %temp.0600.us, %mul210.us
  %inc213.us = add nuw nsw i64 %i__.4599.us, 1
  %exitcond = icmp eq i64 %inc213.us, %indvars.iv
  br i1 %exitcond, label %if.end.221.us.loopexit, label %for.body.205.us

if.end.221.us.loopexit:                           ; preds = %for.body.205.us
  %sub211.us.lcssa = phi double [ %sub211.us, %for.body.205.us ]
  br label %if.end.221.us

if.end.221.us:                                    ; preds = %if.end.221.us.loopexit, %for.body.200.us
  %temp.0.lcssa.us = phi double [ %2, %for.body.200.us ], [ %sub211.us.lcssa, %if.end.221.us.loopexit ]
  store double %temp.0.lcssa.us, double* %arrayidx201.us, align 8, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond674 = icmp eq i64 %indvars.iv, %1
  br i1 %exitcond674, label %cleanup.loopexit, label %for.body.200.us

cleanup.loopexit:                                 ; preds = %if.end.221.us
  br label %cleanup.exitStub

for.body.200.preheader:                           ; preds = %for.body.200.lr.ph
  br label %for.body.200

for.body.200:                                     ; preds = %if.then.216, %for.body.200.preheader
  %indvars.iv675 = phi i64 [ %indvars.iv.next676, %if.then.216 ], [ 1, %for.body.200.preheader ]
  %arrayidx201 = getelementptr inbounds double, double* %incdec.ptr, i64 %indvars.iv675
  %5 = load double, double* %arrayidx201, align 8, !tbaa !0
  %cmp204.598 = icmp sgt i64 %indvars.iv675, 1
  br i1 %cmp204.598, label %for.body.205.lr.ph, label %if.then.216

for.body.205.lr.ph:                               ; preds = %for.body.200
  %mul206 = mul nsw i64 %indvars.iv675, %0
  br label %for.body.205

for.body.205:                                     ; preds = %for.body.205, %for.body.205.lr.ph
  %temp.0600 = phi double [ %5, %for.body.205.lr.ph ], [ %sub211, %for.body.205 ]
  %i__.4599 = phi i64 [ 1, %for.body.205.lr.ph ], [ %inc213, %for.body.205 ]
  %add207 = add nsw i64 %i__.4599, %mul206
  %arrayidx208 = getelementptr inbounds double, double* %add.ptr, i64 %add207
  %6 = load double, double* %arrayidx208, align 8, !tbaa !0
  %arrayidx209 = getelementptr inbounds double, double* %incdec.ptr, i64 %i__.4599
  %7 = load double, double* %arrayidx209, align 8, !tbaa !0
  %mul210 = fmul double %6, %7
  %sub211 = fsub double %temp.0600, %mul210
  %inc213 = add nuw nsw i64 %i__.4599, 1
  %exitcond677 = icmp eq i64 %inc213, %indvars.iv675
  br i1 %exitcond677, label %if.then.216.loopexit, label %for.body.205

if.then.216.loopexit:                             ; preds = %for.body.205
  %sub211.lcssa = phi double [ %sub211, %for.body.205 ]
  br label %if.then.216

if.then.216:                                      ; preds = %if.then.216.loopexit, %for.body.200
  %temp.0.lcssa = phi double [ %5, %for.body.200 ], [ %sub211.lcssa, %if.then.216.loopexit ]
  %mul217 = mul nsw i64 %indvars.iv675, %0
  %add218 = add nsw i64 %mul217, %indvars.iv675
  %arrayidx219 = getelementptr inbounds double, double* %add.ptr, i64 %add218
  %8 = load double, double* %arrayidx219, align 8, !tbaa !0
  %div220 = fdiv double %temp.0.lcssa, %8
  store double %div220, double* %arrayidx201, align 8, !tbaa !0
  %indvars.iv.next676 = add nuw nsw i64 %indvars.iv675, 1
  %exitcond678 = icmp eq i64 %indvars.iv675, %1
  br i1 %exitcond678, label %cleanup.loopexit695, label %for.body.200

cleanup.loopexit695:                              ; preds = %if.then.216
  br label %cleanup.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
