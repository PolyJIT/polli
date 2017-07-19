
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'sgemm.c.f2c_sgemm_for.body.190.lr.ph.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_sgemm_for.body.190.lr.ph.pjit.scop(i64, float* %add.ptr, i64 %mul194, float* %add.ptr3, i64, float* %beta, float* %alpha, i64 %mul205, float* %add.ptr6, i64)  {
newFuncRoot:
  br label %for.body.190.lr.ph

for.inc.222.loopexit706.exitStub:                 ; preds = %for.inc.219
  ret void

for.body.190.lr.ph:                               ; preds = %for.inc.219, %newFuncRoot
  %i__.5635 = phi i64 [ %inc220, %for.inc.219 ], [ 1, %newFuncRoot ]
  %mul191 = mul nsw i64 %i__.5635, %0
  br label %for.body.190

for.body.190:                                     ; preds = %for.body.190, %for.body.190.lr.ph
  %temp.0633 = phi float [ 0.000000e+00, %for.body.190.lr.ph ], [ %add198, %for.body.190 ]
  %l.1632 = phi i64 [ 1, %for.body.190.lr.ph ], [ %inc200, %for.body.190 ]
  %add192 = add nsw i64 %l.1632, %mul191
  %arrayidx193 = getelementptr inbounds float, float* %add.ptr, i64 %add192
  %3 = load float, float* %arrayidx193, align 4, !tbaa !0
  %add195 = add nsw i64 %l.1632, %mul194
  %arrayidx196 = getelementptr inbounds float, float* %add.ptr3, i64 %add195
  %4 = load float, float* %arrayidx196, align 4, !tbaa !0
  %mul197 = fmul float %3, %4
  %add198 = fadd float %temp.0633, %mul197
  %inc200 = add nuw nsw i64 %l.1632, 1
  %exitcond682 = icmp eq i64 %l.1632, %1
  br i1 %exitcond682, label %for.end.201, label %for.body.190

for.end.201:                                      ; preds = %for.body.190
  %add198.lcssa = phi float [ %add198, %for.body.190 ]
  %5 = load float, float* %beta, align 4, !tbaa !0
  %cmp202 = fcmp oeq float %5, 0.000000e+00
  %6 = load float, float* %alpha, align 4, !tbaa !0
  %mul204 = fmul float %add198.lcssa, %6
  %add206 = add nsw i64 %i__.5635, %mul205
  %arrayidx207 = getelementptr inbounds float, float* %add.ptr6, i64 %add206
  br i1 %cmp202, label %for.inc.219, label %if.else.208

for.inc.219:                                      ; preds = %if.else.208, %for.end.201
  %storemerge.600 = phi float [ %add214, %if.else.208 ], [ %mul204, %for.end.201 ]
  store float %storemerge.600, float* %arrayidx207, align 4, !tbaa !0
  %inc220 = add nuw nsw i64 %i__.5635, 1
  %exitcond683 = icmp eq i64 %inc220, %2
  br i1 %exitcond683, label %for.inc.222.loopexit706.exitStub, label %for.body.190.lr.ph

if.else.208:                                      ; preds = %for.end.201
  %7 = load float, float* %arrayidx207, align 4, !tbaa !0
  %mul213 = fmul float %5, %7
  %add214 = fadd float %mul204, %mul213
  br label %for.inc.219
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
