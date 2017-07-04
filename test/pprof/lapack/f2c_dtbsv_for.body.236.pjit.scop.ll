
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'dtbsv.c.f2c_dtbsv_for.body.236.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_dtbsv_for.body.236.pjit.scop(double* %incdec.ptr, i64, i64 %add231, i64, double* %add.ptr, i64)  {
newFuncRoot:
  br label %for.body.236

cleanup.loopexit846.exitStub:                     ; preds = %if.then.260
  ret void

for.body.236:                                     ; preds = %if.then.260, %newFuncRoot
  %j.4765 = phi i64 [ %inc268, %if.then.260 ], [ 1, %newFuncRoot ]
  %arrayidx237 = getelementptr inbounds double, double* %incdec.ptr, i64 %j.4765
  %3 = load double, double* %arrayidx237, align 8, !tbaa !0
  %sub239 = sub nsw i64 %j.4765, %0
  %cmp241 = icmp sgt i64 %sub239, 1
  %cond245 = select i1 %cmp241, i64 %sub239, i64 1
  %cmp247.761 = icmp slt i64 %cond245, %j.4765
  br i1 %cmp247.761, label %for.body.248.lr.ph, label %if.then.260

for.body.248.lr.ph:                               ; preds = %for.body.236
  %sub238 = sub i64 %add231, %j.4765
  %mul250 = mul nsw i64 %j.4765, %1
  %add249 = add i64 %sub238, %mul250
  br label %for.body.248

for.body.248:                                     ; preds = %for.body.248, %for.body.248.lr.ph
  %temp.0763 = phi double [ %3, %for.body.248.lr.ph ], [ %sub255, %for.body.248 ]
  %i__.4762 = phi i64 [ %cond245, %for.body.248.lr.ph ], [ %inc257, %for.body.248 ]
  %add251 = add i64 %add249, %i__.4762
  %arrayidx252 = getelementptr inbounds double, double* %add.ptr, i64 %add251
  %4 = load double, double* %arrayidx252, align 8, !tbaa !0
  %arrayidx253 = getelementptr inbounds double, double* %incdec.ptr, i64 %i__.4762
  %5 = load double, double* %arrayidx253, align 8, !tbaa !0
  %mul254 = fmul double %4, %5
  %sub255 = fsub double %temp.0763, %mul254
  %inc257 = add nuw nsw i64 %i__.4762, 1
  %cmp247 = icmp slt i64 %inc257, %j.4765
  br i1 %cmp247, label %for.body.248, label %if.then.260.loopexit

if.then.260.loopexit:                             ; preds = %for.body.248
  %sub255.lcssa = phi double [ %sub255, %for.body.248 ]
  br label %if.then.260

if.then.260:                                      ; preds = %if.then.260.loopexit, %for.body.236
  %temp.0.lcssa = phi double [ %3, %for.body.236 ], [ %sub255.lcssa, %if.then.260.loopexit ]
  %mul261 = mul nsw i64 %j.4765, %1
  %add262 = add nsw i64 %mul261, %add231
  %arrayidx263 = getelementptr inbounds double, double* %add.ptr, i64 %add262
  %6 = load double, double* %arrayidx263, align 8, !tbaa !0
  %div264 = fdiv double %temp.0.lcssa, %6
  store double %div264, double* %arrayidx237, align 8, !tbaa !0
  %inc268 = add nuw nsw i64 %j.4765, 1
  %exitcond839 = icmp eq i64 %j.4765, %2
  br i1 %exitcond839, label %cleanup.loopexit846.exitStub, label %for.body.236
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
