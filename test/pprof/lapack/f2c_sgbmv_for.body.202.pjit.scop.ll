
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'sgbmv.c.f2c_sgbmv_for.body.202.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_sgbmv_for.body.202.pjit.scop(i64 %ky.0, i64, i64, i64, float* %alpha, float* %incdec.ptr1, i64, i64, i64 %add110, i64, float* %add.ptr, float* %incdec.ptr)  {
newFuncRoot:
  br label %for.body.202

cleanup.loopexit.exitStub:                        ; preds = %for.end.228
  ret void

for.body.202:                                     ; preds = %for.end.228, %newFuncRoot
  %jy.0536 = phi i64 [ %ky.0, %newFuncRoot ], [ %add232, %for.end.228 ]
  %j.2534 = phi i64 [ 1, %newFuncRoot ], [ %inc234, %for.end.228 ]
  %sub204 = sub nsw i64 %j.2534, %0
  %add205 = add nsw i64 %j.2534, %1
  %cmp206 = icmp sle i64 %2, %add205
  %cond210 = select i1 %cmp206, i64 %2, i64 %add205
  %cmp211 = icmp sgt i64 %sub204, 1
  %cond215 = select i1 %cmp211, i64 %sub204, i64 1
  %cmp217.530 = icmp sgt i64 %cond215, %cond210
  br i1 %cmp217.530, label %for.end.228, label %for.body.218.lr.ph

for.end.228:                                      ; preds = %for.end.228.loopexit, %for.body.202
  %temp.0.lcssa = phi float [ 0.000000e+00, %for.body.202 ], [ %add225.lcssa, %for.end.228.loopexit ]
  %6 = load float, float* %alpha, align 4, !tbaa !0
  %mul229 = fmul float %temp.0.lcssa, %6
  %arrayidx230 = getelementptr inbounds float, float* %incdec.ptr1, i64 %jy.0536
  %7 = load float, float* %arrayidx230, align 4, !tbaa !0
  %add231 = fadd float %7, %mul229
  store float %add231, float* %arrayidx230, align 4, !tbaa !0
  %add232 = add nsw i64 %jy.0536, %3
  %inc234 = add nuw nsw i64 %j.2534, 1
  %exitcond = icmp eq i64 %j.2534, %4
  br i1 %exitcond, label %cleanup.loopexit.exitStub, label %for.body.202

for.body.218.lr.ph:                               ; preds = %for.body.202
  %sub203 = sub i64 %add110, %j.2534
  %mul220 = mul nsw i64 %j.2534, %5
  %add219 = add i64 %sub203, %mul220
  br label %for.body.218

for.body.218:                                     ; preds = %for.body.218, %for.body.218.lr.ph
  %temp.0532 = phi float [ 0.000000e+00, %for.body.218.lr.ph ], [ %add225, %for.body.218 ]
  %i__.6531 = phi i64 [ %cond215, %for.body.218.lr.ph ], [ %inc227, %for.body.218 ]
  %add221 = add i64 %add219, %i__.6531
  %arrayidx222 = getelementptr inbounds float, float* %add.ptr, i64 %add221
  %8 = load float, float* %arrayidx222, align 4, !tbaa !0
  %arrayidx223 = getelementptr inbounds float, float* %incdec.ptr, i64 %i__.6531
  %9 = load float, float* %arrayidx223, align 4, !tbaa !0
  %mul224 = fmul float %8, %9
  %add225 = fadd float %temp.0532, %mul224
  %inc227 = add nuw nsw i64 %i__.6531, 1
  %cmp217 = icmp slt i64 %i__.6531, %cond210
  br i1 %cmp217, label %for.body.218, label %for.end.228.loopexit

for.end.228.loopexit:                             ; preds = %for.body.218
  %add225.lcssa = phi float [ %add225, %for.body.218 ]
  br label %for.end.228
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
