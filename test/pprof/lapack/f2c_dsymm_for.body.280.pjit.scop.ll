
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'dsymm.c.f2c_dsymm_for.body.280.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @f2c_dsymm_for.body.280.pjit.scop(double* %alpha, i64 %mul238, double* %add.ptr, i64, double* %add.ptr3, i64 %mul300, double* %add.ptr6, i64, i64 %indvars.iv767)  {
newFuncRoot:
  br label %for.body.280

for.end.309.loopexit784.exitStub:                 ; preds = %for.inc.307
  ret void

for.body.280:                                     ; preds = %for.inc.307, %newFuncRoot
  %k.2664 = phi i64 [ %inc308, %for.inc.307 ], [ 1, %newFuncRoot ]
  %2 = load double, double* %alpha, align 8, !tbaa !0
  %add284 = add nsw i64 %k.2664, %mul238
  %.pn.638.in = getelementptr inbounds double, double* %add.ptr, i64 %add284
  %.pn.638 = load double, double* %.pn.638.in, align 8, !tbaa !0
  %temp1.0 = fmul double %2, %.pn.638
  %mul296 = mul nsw i64 %k.2664, %0
  br label %for.body.295

for.body.295:                                     ; preds = %for.body.295, %for.body.280
  %i__.6662 = phi i64 [ 1, %for.body.280 ], [ %inc305, %for.body.295 ]
  %add297 = add nsw i64 %i__.6662, %mul296
  %arrayidx298 = getelementptr inbounds double, double* %add.ptr3, i64 %add297
  %3 = load double, double* %arrayidx298, align 8, !tbaa !0
  %mul299 = fmul double %temp1.0, %3
  %add301 = add nsw i64 %i__.6662, %mul300
  %arrayidx302 = getelementptr inbounds double, double* %add.ptr6, i64 %add301
  %4 = load double, double* %arrayidx302, align 8, !tbaa !0
  %add303 = fadd double %4, %mul299
  store double %add303, double* %arrayidx302, align 8, !tbaa !0
  %inc305 = add nuw nsw i64 %i__.6662, 1
  %exitcond761 = icmp eq i64 %i__.6662, %1
  br i1 %exitcond761, label %for.inc.307, label %for.body.295

for.inc.307:                                      ; preds = %for.body.295
  %inc308 = add nuw nsw i64 %k.2664, 1
  %exitcond762 = icmp eq i64 %inc308, %indvars.iv767
  br i1 %exitcond762, label %for.end.309.loopexit784.exitStub, label %for.body.280
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
