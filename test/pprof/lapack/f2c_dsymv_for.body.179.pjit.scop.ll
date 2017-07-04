
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'dsymv.c.f2c_dsymv_for.body.179.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_dsymv_for.body.179.pjit.scop(double* %alpha, double* %incdec.ptr, i64, double* %add.ptr, double* %incdec.ptr1, i64, i64)  {
newFuncRoot:
  br label %for.body.179

cleanup.loopexit.exitStub:                        ; preds = %for.end.206
  ret void

for.body.179:                                     ; preds = %for.end.206, %newFuncRoot
  %j.2506 = phi i64 [ 1, %newFuncRoot ], [ %add188, %for.end.206 ]
  %3 = load double, double* %alpha, align 8, !tbaa !0
  %arrayidx180 = getelementptr inbounds double, double* %incdec.ptr, i64 %j.2506
  %4 = load double, double* %arrayidx180, align 8, !tbaa !0
  %mul181 = fmul double %3, %4
  %mul182 = mul nsw i64 %j.2506, %0
  %add183 = add nsw i64 %mul182, %j.2506
  %arrayidx184 = getelementptr inbounds double, double* %add.ptr, i64 %add183
  %5 = load double, double* %arrayidx184, align 8, !tbaa !0
  %mul185 = fmul double %mul181, %5
  %arrayidx186 = getelementptr inbounds double, double* %incdec.ptr1, i64 %j.2506
  %6 = load double, double* %arrayidx186, align 8, !tbaa !0
  %add187 = fadd double %6, %mul185
  store double %add187, double* %arrayidx186, align 8, !tbaa !0
  %add188 = add nuw nsw i64 %j.2506, 1
  %cmp190.502 = icmp slt i64 %j.2506, %1
  br i1 %cmp190.502, label %for.body.191.preheader, label %for.end.206

for.body.191.preheader:                           ; preds = %for.body.179
  br label %for.body.191

for.body.191:                                     ; preds = %for.body.191, %for.body.191.preheader
  %temp2.2504 = phi double [ %add203, %for.body.191 ], [ 0.000000e+00, %for.body.191.preheader ]
  %i__.6503 = phi i64 [ %inc205, %for.body.191 ], [ %add188, %for.body.191.preheader ]
  %add193 = add nsw i64 %i__.6503, %mul182
  %arrayidx194 = getelementptr inbounds double, double* %add.ptr, i64 %add193
  %7 = load double, double* %arrayidx194, align 8, !tbaa !0
  %mul195 = fmul double %mul181, %7
  %arrayidx196 = getelementptr inbounds double, double* %incdec.ptr1, i64 %i__.6503
  %8 = load double, double* %arrayidx196, align 8, !tbaa !0
  %add197 = fadd double %8, %mul195
  store double %add197, double* %arrayidx196, align 8, !tbaa !0
  %9 = load double, double* %arrayidx194, align 8, !tbaa !0
  %arrayidx201 = getelementptr inbounds double, double* %incdec.ptr, i64 %i__.6503
  %10 = load double, double* %arrayidx201, align 8, !tbaa !0
  %mul202 = fmul double %9, %10
  %add203 = fadd double %temp2.2504, %mul202
  %inc205 = add nuw nsw i64 %i__.6503, 1
  %exitcond = icmp eq i64 %i__.6503, %1
  br i1 %exitcond, label %for.end.206.loopexit, label %for.body.191

for.end.206.loopexit:                             ; preds = %for.body.191
  %add203.lcssa = phi double [ %add203, %for.body.191 ]
  br label %for.end.206

for.end.206:                                      ; preds = %for.end.206.loopexit, %for.body.179
  %temp2.2.lcssa = phi double [ 0.000000e+00, %for.body.179 ], [ %add203.lcssa, %for.end.206.loopexit ]
  %11 = load double, double* %alpha, align 8, !tbaa !0
  %mul207 = fmul double %temp2.2.lcssa, %11
  %12 = load double, double* %arrayidx186, align 8, !tbaa !0
  %add209 = fadd double %12, %mul207
  store double %add209, double* %arrayidx186, align 8, !tbaa !0
  %exitcond549 = icmp eq i64 %j.2506, %2
  br i1 %exitcond549, label %cleanup.loopexit.exitStub, label %for.body.179
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
