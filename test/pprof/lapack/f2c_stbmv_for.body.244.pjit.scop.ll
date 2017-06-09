
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'stbmv.c.f2c_stbmv_for.body.244.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_stbmv_for.body.244.pjit.scop(i64, float* %incdec.ptr, i64, i64 %add239, float* %add.ptr, i64)  {
newFuncRoot:
  br label %for.body.244

cleanup.loopexit843.exitStub:                     ; preds = %for.end.273
  ret void

for.body.244:                                     ; preds = %for.end.273, %newFuncRoot
  %j.4767 = phi i64 [ %dec276, %for.end.273 ], [ %0, %newFuncRoot ]
  %arrayidx245 = getelementptr inbounds float, float* %incdec.ptr, i64 %j.4767
  %3 = load float, float* %arrayidx245, align 4, !tbaa !0
  %mul249 = mul nsw i64 %j.4767, %1
  %add250 = add nsw i64 %mul249, %add239
  %arrayidx251 = getelementptr inbounds float, float* %add.ptr, i64 %add250
  %4 = load float, float* %arrayidx251, align 4, !tbaa !0
  %mul252 = fmul float %3, %4
  %sub254 = sub nsw i64 %j.4767, %2
  %cmp255 = icmp sgt i64 %sub254, 1
  %cond259 = select i1 %cmp255, i64 %sub254, i64 1
  %cmp262.763 = icmp sgt i64 %j.4767, %cond259
  br i1 %cmp262.763, label %for.body.263.lr.ph, label %for.end.273

for.body.263.lr.ph:                               ; preds = %for.body.244
  %sub246 = sub i64 %add239, %j.4767
  %mul265 = mul nsw i64 %j.4767, %1
  %add264 = add i64 %sub246, %mul265
  br label %for.body.263

for.body.263:                                     ; preds = %for.body.263, %for.body.263.lr.ph
  %i__.4765.in = phi i64 [ %j.4767, %for.body.263.lr.ph ], [ %i__.4765, %for.body.263 ]
  %temp.1764 = phi float [ %mul252, %for.body.263.lr.ph ], [ %add270, %for.body.263 ]
  %i__.4765 = add nsw i64 %i__.4765.in, -1
  %add266 = add i64 %add264, %i__.4765
  %arrayidx267 = getelementptr inbounds float, float* %add.ptr, i64 %add266
  %5 = load float, float* %arrayidx267, align 4, !tbaa !0
  %arrayidx268 = getelementptr inbounds float, float* %incdec.ptr, i64 %i__.4765
  %6 = load float, float* %arrayidx268, align 4, !tbaa !0
  %mul269 = fmul float %5, %6
  %add270 = fadd float %temp.1764, %mul269
  %cmp262 = icmp sgt i64 %i__.4765, %cond259
  br i1 %cmp262, label %for.body.263, label %for.end.273.loopexit

for.end.273.loopexit:                             ; preds = %for.body.263
  %add270.lcssa = phi float [ %add270, %for.body.263 ]
  br label %for.end.273

for.end.273:                                      ; preds = %for.end.273.loopexit, %for.body.244
  %temp.1.lcssa = phi float [ %mul252, %for.body.244 ], [ %add270.lcssa, %for.end.273.loopexit ]
  store float %temp.1.lcssa, float* %arrayidx245, align 4, !tbaa !0
  %dec276 = add nsw i64 %j.4767, -1
  %cmp243 = icmp sgt i64 %j.4767, 1
  br i1 %cmp243, label %for.body.244, label %cleanup.loopexit843.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
