
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli -polli-process-unprofitable  -polli-no-recompilation -polli-analyze -disable-output < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'strmv.c.f2c_strmv_for.body.201.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_strmv_for.body.201.lr.ph.pjit.scop(i64 %call40, i64, float* %incdec.ptr, i64, float* %add.ptr)  {
newFuncRoot:
  br label %for.body.201.lr.ph

cleanup.exitStub:                                 ; preds = %cleanup.loopexit691, %cleanup.loopexit
  ret void

for.body.201.lr.ph:                               ; preds = %newFuncRoot
  %tobool203 = icmp eq i64 %call40, 0
  br i1 %tobool203, label %for.body.201.us.preheader, label %for.body.201.preheader

for.body.201.us.preheader:                        ; preds = %for.body.201.lr.ph
  br label %for.body.201.us

for.body.201.us:                                  ; preds = %for.end.222.us, %for.body.201.us.preheader
  %j.4604.us = phi i64 [ %dec225.us, %for.end.222.us ], [ %0, %for.body.201.us.preheader ]
  %arrayidx202.us = getelementptr inbounds float, float* %incdec.ptr, i64 %j.4604.us
  %2 = load float, float* %arrayidx202.us, align 4, !tbaa !0
  %cmp212.600.us = icmp sgt i64 %j.4604.us, 1
  br i1 %cmp212.600.us, label %for.body.213.lr.ph.us, label %for.end.222.us

for.body.213.lr.ph.us:                            ; preds = %for.body.201.us
  %mul214.us = mul nsw i64 %j.4604.us, %1
  br label %for.body.213.us

for.body.213.us:                                  ; preds = %for.body.213.us, %for.body.213.lr.ph.us
  %i__.4602.us.in = phi i64 [ %j.4604.us, %for.body.213.lr.ph.us ], [ %i__.4602.us, %for.body.213.us ]
  %temp.1601.us = phi float [ %2, %for.body.213.lr.ph.us ], [ %add219.us, %for.body.213.us ]
  %i__.4602.us = add nsw i64 %i__.4602.us.in, -1
  %add215.us = add nsw i64 %i__.4602.us, %mul214.us
  %arrayidx216.us = getelementptr inbounds float, float* %add.ptr, i64 %add215.us
  %3 = load float, float* %arrayidx216.us, align 4, !tbaa !0
  %arrayidx217.us = getelementptr inbounds float, float* %incdec.ptr, i64 %i__.4602.us
  %4 = load float, float* %arrayidx217.us, align 4, !tbaa !0
  %mul218.us = fmul float %3, %4
  %add219.us = fadd float %temp.1601.us, %mul218.us
  %cmp212.us = icmp sgt i64 %i__.4602.us, 1
  br i1 %cmp212.us, label %for.body.213.us, label %for.end.222.us.loopexit

for.end.222.us.loopexit:                          ; preds = %for.body.213.us
  %add219.us.lcssa = phi float [ %add219.us, %for.body.213.us ]
  br label %for.end.222.us

for.end.222.us:                                   ; preds = %for.end.222.us.loopexit, %for.body.201.us
  %temp.1.lcssa.us = phi float [ %2, %for.body.201.us ], [ %add219.us.lcssa, %for.end.222.us.loopexit ]
  store float %temp.1.lcssa.us, float* %arrayidx202.us, align 4, !tbaa !0
  %dec225.us = add nsw i64 %j.4604.us, -1
  %cmp200.us = icmp sgt i64 %j.4604.us, 1
  br i1 %cmp200.us, label %for.body.201.us, label %cleanup.loopexit

cleanup.loopexit:                                 ; preds = %for.end.222.us
  br label %cleanup.exitStub

for.body.201.preheader:                           ; preds = %for.body.201.lr.ph
  br label %for.body.201

for.body.201:                                     ; preds = %for.end.222, %for.body.201.preheader
  %j.4604 = phi i64 [ %dec225, %for.end.222 ], [ %0, %for.body.201.preheader ]
  %arrayidx202 = getelementptr inbounds float, float* %incdec.ptr, i64 %j.4604
  %5 = load float, float* %arrayidx202, align 4, !tbaa !0
  %mul205 = mul nsw i64 %j.4604, %1
  %add206 = add nsw i64 %mul205, %j.4604
  %arrayidx207 = getelementptr inbounds float, float* %add.ptr, i64 %add206
  %6 = load float, float* %arrayidx207, align 4, !tbaa !0
  %mul208 = fmul float %5, %6
  %cmp212.600 = icmp sgt i64 %j.4604, 1
  br i1 %cmp212.600, label %for.body.213.lr.ph, label %for.end.222

for.body.213.lr.ph:                               ; preds = %for.body.201
  %mul214 = mul nsw i64 %j.4604, %1
  br label %for.body.213

for.body.213:                                     ; preds = %for.body.213, %for.body.213.lr.ph
  %i__.4602.in = phi i64 [ %j.4604, %for.body.213.lr.ph ], [ %i__.4602, %for.body.213 ]
  %temp.1601 = phi float [ %mul208, %for.body.213.lr.ph ], [ %add219, %for.body.213 ]
  %i__.4602 = add nsw i64 %i__.4602.in, -1
  %add215 = add nsw i64 %i__.4602, %mul214
  %arrayidx216 = getelementptr inbounds float, float* %add.ptr, i64 %add215
  %7 = load float, float* %arrayidx216, align 4, !tbaa !0
  %arrayidx217 = getelementptr inbounds float, float* %incdec.ptr, i64 %i__.4602
  %8 = load float, float* %arrayidx217, align 4, !tbaa !0
  %mul218 = fmul float %7, %8
  %add219 = fadd float %temp.1601, %mul218
  %cmp212 = icmp sgt i64 %i__.4602, 1
  br i1 %cmp212, label %for.body.213, label %for.end.222.loopexit

for.end.222.loopexit:                             ; preds = %for.body.213
  %add219.lcssa = phi float [ %add219, %for.body.213 ]
  br label %for.end.222

for.end.222:                                      ; preds = %for.end.222.loopexit, %for.body.201
  %temp.1.lcssa = phi float [ %mul208, %for.body.201 ], [ %add219.lcssa, %for.end.222.loopexit ]
  store float %temp.1.lcssa, float* %arrayidx202, align 4, !tbaa !0
  %dec225 = add nsw i64 %j.4604, -1
  %cmp200 = icmp sgt i64 %j.4604, 1
  br i1 %cmp200, label %for.body.201, label %cleanup.loopexit691

cleanup.loopexit691:                              ; preds = %for.end.222
  br label %cleanup.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
