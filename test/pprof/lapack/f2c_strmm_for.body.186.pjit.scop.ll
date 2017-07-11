
; RUN: opt -load LLVMPolyJIT.so -O3  -polli -polli-process-unprofitable  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 2 regions require runtime support:

; ModuleID = 'strmm.c.f2c_strmm_for.body.186.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_strmm_for.body.186.pjit.scop(i1 %cmp188.960, i64, i1 %tobool193, i64, float* %add.ptr3, i64, float* %add.ptr, float* %alpha, i64)  {
newFuncRoot:
  br label %for.body.186

cleanup.loopexit1102.exitStub:                    ; preds = %for.inc.222
  ret void

for.body.186:                                     ; preds = %for.inc.222, %newFuncRoot
  %j.3964 = phi i64 [ 1, %newFuncRoot ], [ %inc223, %for.inc.222 ]
  br i1 %cmp188.960, label %for.body.189.lr.ph, label %for.inc.222

for.body.189.lr.ph:                               ; preds = %for.body.186
  %mul190 = mul nsw i64 %j.3964, %0
  br i1 %tobool193, label %for.body.189.us.preheader, label %for.body.189.preheader

for.body.189.us.preheader:                        ; preds = %for.body.189.lr.ph
  br label %for.body.189.us

for.body.189.us:                                  ; preds = %for.end.214.us, %for.body.189.us.preheader
  %indvars.iv1051 = phi i64 [ %indvars.iv.next1052, %for.end.214.us ], [ %1, %for.body.189.us.preheader ]
  %add191.us = add nsw i64 %indvars.iv1051, %mul190
  %arrayidx192.us = getelementptr inbounds float, float* %add.ptr3, i64 %add191.us
  %4 = load float, float* %arrayidx192.us, align 4, !tbaa !0
  %cmp202.957.us = icmp sgt i64 %indvars.iv1051, 1
  br i1 %cmp202.957.us, label %for.body.203.lr.ph.us, label %for.end.214.us

for.body.203.lr.ph.us:                            ; preds = %for.body.189.us
  %mul204.us = mul nsw i64 %indvars.iv1051, %2
  br label %for.body.203.us

for.body.203.us:                                  ; preds = %for.body.203.us, %for.body.203.lr.ph.us
  %temp.2959.us = phi float [ %4, %for.body.203.lr.ph.us ], [ %add211.us, %for.body.203.us ]
  %k.2958.us = phi i64 [ 1, %for.body.203.lr.ph.us ], [ %inc213.us, %for.body.203.us ]
  %add205.us = add nsw i64 %k.2958.us, %mul204.us
  %arrayidx206.us = getelementptr inbounds float, float* %add.ptr, i64 %add205.us
  %5 = load float, float* %arrayidx206.us, align 4, !tbaa !0
  %add208.us = add nsw i64 %k.2958.us, %mul190
  %arrayidx209.us = getelementptr inbounds float, float* %add.ptr3, i64 %add208.us
  %6 = load float, float* %arrayidx209.us, align 4, !tbaa !0
  %mul210.us = fmul float %5, %6
  %add211.us = fadd float %temp.2959.us, %mul210.us
  %inc213.us = add nuw nsw i64 %k.2958.us, 1
  %exitcond1053 = icmp eq i64 %inc213.us, %indvars.iv1051
  br i1 %exitcond1053, label %for.end.214.us.loopexit, label %for.body.203.us

for.end.214.us.loopexit:                          ; preds = %for.body.203.us
  %add211.us.lcssa = phi float [ %add211.us, %for.body.203.us ]
  br label %for.end.214.us

for.end.214.us:                                   ; preds = %for.end.214.us.loopexit, %for.body.189.us
  %temp.2.lcssa.us = phi float [ %4, %for.body.189.us ], [ %add211.us.lcssa, %for.end.214.us.loopexit ]
  %7 = load float, float* %alpha, align 4, !tbaa !0
  %mul215.us = fmul float %temp.2.lcssa.us, %7
  store float %mul215.us, float* %arrayidx192.us, align 4, !tbaa !0
  %indvars.iv.next1052 = add nsw i64 %indvars.iv1051, -1
  %cmp188.us = icmp sgt i64 %indvars.iv1051, 1
  br i1 %cmp188.us, label %for.body.189.us, label %for.inc.222.loopexit

for.inc.222.loopexit:                             ; preds = %for.end.214.us
  br label %for.inc.222

for.inc.222:                                      ; preds = %for.inc.222.loopexit1101, %for.inc.222.loopexit, %for.body.186
  %inc223 = add nuw nsw i64 %j.3964, 1
  %exitcond1054 = icmp eq i64 %j.3964, %3
  br i1 %exitcond1054, label %cleanup.loopexit1102.exitStub, label %for.body.186

for.body.189.preheader:                           ; preds = %for.body.189.lr.ph
  br label %for.body.189

for.body.189:                                     ; preds = %for.end.214, %for.body.189.preheader
  %indvars.iv1048 = phi i64 [ %indvars.iv.next1049, %for.end.214 ], [ %1, %for.body.189.preheader ]
  %add191 = add nsw i64 %indvars.iv1048, %mul190
  %arrayidx192 = getelementptr inbounds float, float* %add.ptr3, i64 %add191
  %8 = load float, float* %arrayidx192, align 4, !tbaa !0
  %mul195 = mul nsw i64 %indvars.iv1048, %2
  %add196 = add nsw i64 %mul195, %indvars.iv1048
  %arrayidx197 = getelementptr inbounds float, float* %add.ptr, i64 %add196
  %9 = load float, float* %arrayidx197, align 4, !tbaa !0
  %mul198 = fmul float %8, %9
  %cmp202.957 = icmp sgt i64 %indvars.iv1048, 1
  br i1 %cmp202.957, label %for.body.203.lr.ph, label %for.end.214

for.body.203.lr.ph:                               ; preds = %for.body.189
  %mul204 = mul nsw i64 %indvars.iv1048, %2
  br label %for.body.203

for.body.203:                                     ; preds = %for.body.203, %for.body.203.lr.ph
  %temp.2959 = phi float [ %mul198, %for.body.203.lr.ph ], [ %add211, %for.body.203 ]
  %k.2958 = phi i64 [ 1, %for.body.203.lr.ph ], [ %inc213, %for.body.203 ]
  %add205 = add nsw i64 %k.2958, %mul204
  %arrayidx206 = getelementptr inbounds float, float* %add.ptr, i64 %add205
  %10 = load float, float* %arrayidx206, align 4, !tbaa !0
  %add208 = add nsw i64 %k.2958, %mul190
  %arrayidx209 = getelementptr inbounds float, float* %add.ptr3, i64 %add208
  %11 = load float, float* %arrayidx209, align 4, !tbaa !0
  %mul210 = fmul float %10, %11
  %add211 = fadd float %temp.2959, %mul210
  %inc213 = add nuw nsw i64 %k.2958, 1
  %exitcond1050 = icmp eq i64 %inc213, %indvars.iv1048
  br i1 %exitcond1050, label %for.end.214.loopexit, label %for.body.203

for.end.214.loopexit:                             ; preds = %for.body.203
  %add211.lcssa = phi float [ %add211, %for.body.203 ]
  br label %for.end.214

for.end.214:                                      ; preds = %for.end.214.loopexit, %for.body.189
  %temp.2.lcssa = phi float [ %mul198, %for.body.189 ], [ %add211.lcssa, %for.end.214.loopexit ]
  %12 = load float, float* %alpha, align 4, !tbaa !0
  %mul215 = fmul float %temp.2.lcssa, %12
  store float %mul215, float* %arrayidx192, align 4, !tbaa !0
  %indvars.iv.next1049 = add nsw i64 %indvars.iv1048, -1
  %cmp188 = icmp sgt i64 %indvars.iv1048, 1
  br i1 %cmp188, label %for.body.189, label %for.inc.222.loopexit1101

for.inc.222.loopexit1101:                         ; preds = %for.end.214
  br label %for.inc.222
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
