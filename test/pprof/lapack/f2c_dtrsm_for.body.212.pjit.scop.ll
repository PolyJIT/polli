; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 2 regions require runtime support:

; ModuleID = 'dtrsm.c.f2c_dtrsm_for.body.212.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_dtrsm_for.body.212.pjit.scop(i1 %cmp214.1102, i64, i64, i1 %tobool235, double* %alpha, double* %add.ptr3, i64, double* %add.ptr, i64)  {
newFuncRoot:
  br label %for.body.212

cleanup.loopexit1237.exitStub:                    ; preds = %for.inc.248
  ret void

for.body.212:                                     ; preds = %for.inc.248, %newFuncRoot
  %j.31105 = phi i64 [ 1, %newFuncRoot ], [ %inc249, %for.inc.248 ]
  br i1 %cmp214.1102, label %for.inc.248, label %for.body.215.lr.ph

for.inc.248:                                      ; preds = %for.inc.248.loopexit1236, %for.inc.248.loopexit, %for.body.212
  %inc249 = add nuw nsw i64 %j.31105, 1
  %exitcond1205 = icmp eq i64 %j.31105, %0
  br i1 %exitcond1205, label %cleanup.loopexit1237.exitStub, label %for.body.212

for.body.215.lr.ph:                               ; preds = %for.body.212
  %mul216 = mul nsw i64 %j.31105, %1
  br i1 %tobool235, label %for.body.215.us.preheader, label %for.body.215.preheader

for.body.215.us.preheader:                        ; preds = %for.body.215.lr.ph
  br label %for.body.215.us

for.body.215.us:                                  ; preds = %if.end.241.us, %for.body.215.us.preheader
  %indvars.iv1201 = phi i64 [ %indvars.iv.next1202, %if.end.241.us ], [ 1, %for.body.215.us.preheader ]
  %4 = load double, double* %alpha, align 8, !tbaa !0
  %add217.us = add nsw i64 %indvars.iv1201, %mul216
  %arrayidx218.us = getelementptr inbounds double, double* %add.ptr3, i64 %add217.us
  %5 = load double, double* %arrayidx218.us, align 8, !tbaa !0
  %mul219.us = fmul double %4, %5
  %cmp222.1099.us = icmp sgt i64 %indvars.iv1201, 1
  br i1 %cmp222.1099.us, label %for.body.223.lr.ph.us, label %if.end.241.us

for.body.223.lr.ph.us:                            ; preds = %for.body.215.us
  %mul224.us = mul nsw i64 %indvars.iv1201, %2
  br label %for.body.223.us

for.body.223.us:                                  ; preds = %for.body.223.us, %for.body.223.lr.ph.us
  %temp.01101.us = phi double [ %mul219.us, %for.body.223.lr.ph.us ], [ %sub231.us, %for.body.223.us ]
  %k.21100.us = phi i64 [ 1, %for.body.223.lr.ph.us ], [ %inc233.us, %for.body.223.us ]
  %add225.us = add nsw i64 %k.21100.us, %mul224.us
  %arrayidx226.us = getelementptr inbounds double, double* %add.ptr, i64 %add225.us
  %6 = load double, double* %arrayidx226.us, align 8, !tbaa !0
  %add228.us = add nsw i64 %k.21100.us, %mul216
  %arrayidx229.us = getelementptr inbounds double, double* %add.ptr3, i64 %add228.us
  %7 = load double, double* %arrayidx229.us, align 8, !tbaa !0
  %mul230.us = fmul double %6, %7
  %sub231.us = fsub double %temp.01101.us, %mul230.us
  %inc233.us = add nuw nsw i64 %k.21100.us, 1
  %exitcond1203 = icmp eq i64 %inc233.us, %indvars.iv1201
  br i1 %exitcond1203, label %if.end.241.us.loopexit, label %for.body.223.us

if.end.241.us.loopexit:                           ; preds = %for.body.223.us
  %sub231.us.lcssa = phi double [ %sub231.us, %for.body.223.us ]
  br label %if.end.241.us

if.end.241.us:                                    ; preds = %if.end.241.us.loopexit, %for.body.215.us
  %temp.0.lcssa.us = phi double [ %mul219.us, %for.body.215.us ], [ %sub231.us.lcssa, %if.end.241.us.loopexit ]
  store double %temp.0.lcssa.us, double* %arrayidx218.us, align 8, !tbaa !0
  %indvars.iv.next1202 = add nuw nsw i64 %indvars.iv1201, 1
  %exitcond1204 = icmp eq i64 %indvars.iv.next1202, %3
  br i1 %exitcond1204, label %for.inc.248.loopexit, label %for.body.215.us

for.inc.248.loopexit:                             ; preds = %if.end.241.us
  br label %for.inc.248

for.body.215.preheader:                           ; preds = %for.body.215.lr.ph
  br label %for.body.215

for.body.215:                                     ; preds = %if.then.236, %for.body.215.preheader
  %indvars.iv1197 = phi i64 [ %indvars.iv.next1198, %if.then.236 ], [ 1, %for.body.215.preheader ]
  %8 = load double, double* %alpha, align 8, !tbaa !0
  %add217 = add nsw i64 %indvars.iv1197, %mul216
  %arrayidx218 = getelementptr inbounds double, double* %add.ptr3, i64 %add217
  %9 = load double, double* %arrayidx218, align 8, !tbaa !0
  %mul219 = fmul double %8, %9
  %cmp222.1099 = icmp sgt i64 %indvars.iv1197, 1
  br i1 %cmp222.1099, label %for.body.223.lr.ph, label %if.then.236

for.body.223.lr.ph:                               ; preds = %for.body.215
  %mul224 = mul nsw i64 %indvars.iv1197, %2
  br label %for.body.223

for.body.223:                                     ; preds = %for.body.223, %for.body.223.lr.ph
  %temp.01101 = phi double [ %mul219, %for.body.223.lr.ph ], [ %sub231, %for.body.223 ]
  %k.21100 = phi i64 [ 1, %for.body.223.lr.ph ], [ %inc233, %for.body.223 ]
  %add225 = add nsw i64 %k.21100, %mul224
  %arrayidx226 = getelementptr inbounds double, double* %add.ptr, i64 %add225
  %10 = load double, double* %arrayidx226, align 8, !tbaa !0
  %add228 = add nsw i64 %k.21100, %mul216
  %arrayidx229 = getelementptr inbounds double, double* %add.ptr3, i64 %add228
  %11 = load double, double* %arrayidx229, align 8, !tbaa !0
  %mul230 = fmul double %10, %11
  %sub231 = fsub double %temp.01101, %mul230
  %inc233 = add nuw nsw i64 %k.21100, 1
  %exitcond1199 = icmp eq i64 %inc233, %indvars.iv1197
  br i1 %exitcond1199, label %if.then.236.loopexit, label %for.body.223

if.then.236.loopexit:                             ; preds = %for.body.223
  %sub231.lcssa = phi double [ %sub231, %for.body.223 ]
  br label %if.then.236

if.then.236:                                      ; preds = %if.then.236.loopexit, %for.body.215
  %temp.0.lcssa = phi double [ %mul219, %for.body.215 ], [ %sub231.lcssa, %if.then.236.loopexit ]
  %mul237 = mul nsw i64 %indvars.iv1197, %2
  %add238 = add nsw i64 %mul237, %indvars.iv1197
  %arrayidx239 = getelementptr inbounds double, double* %add.ptr, i64 %add238
  %12 = load double, double* %arrayidx239, align 8, !tbaa !0
  %div240 = fdiv double %temp.0.lcssa, %12
  store double %div240, double* %arrayidx218, align 8, !tbaa !0
  %indvars.iv.next1198 = add nuw nsw i64 %indvars.iv1197, 1
  %exitcond1200 = icmp eq i64 %indvars.iv.next1198, %3
  br i1 %exitcond1200, label %for.inc.248.loopexit1236, label %for.body.215

for.inc.248.loopexit1236:                         ; preds = %if.then.236
  br label %for.inc.248
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
