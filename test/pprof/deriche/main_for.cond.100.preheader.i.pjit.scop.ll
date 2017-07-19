
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'deriche.dir/deriche.c.main_for.cond.100.preheader.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @main_for.cond.100.preheader.i.pjit.scop(float*, float*, float*)  {
newFuncRoot:
  br label %for.cond.100.preheader.i

for.cond.126.preheader.i.preheader.exitStub:      ; preds = %for.inc.120.i
  ret void

for.cond.100.preheader.i:                         ; preds = %for.inc.120.i, %newFuncRoot
  %indvars.iv44.i = phi i64 [ %indvars.iv.next45.i, %for.inc.120.i ], [ 0, %newFuncRoot ]
  %3 = mul nuw nsw i64 %indvars.iv44.i, 2160
  %arrayidx105.i = getelementptr inbounds float, float* %0, i64 %3
  %arrayidx109.i = getelementptr inbounds float, float* %1, i64 %3
  %arrayidx115.i = getelementptr inbounds float, float* %2, i64 %3
  br label %for.body.102.i

for.body.102.i:                                   ; preds = %for.body.102.i, %for.cond.100.preheader.i
  %indvars.iv41.i = phi i64 [ 0, %for.cond.100.preheader.i ], [ %indvars.iv.next42.i, %for.body.102.i ]
  %arrayidx106.i = getelementptr inbounds float, float* %arrayidx105.i, i64 %indvars.iv41.i
  %4 = load float, float* %arrayidx106.i, align 4, !tbaa !0
  %arrayidx110.i = getelementptr inbounds float, float* %arrayidx109.i, i64 %indvars.iv41.i
  %5 = load float, float* %arrayidx110.i, align 4, !tbaa !0
  %add111.i = fadd float %4, %5
  %arrayidx116.i = getelementptr inbounds float, float* %arrayidx115.i, i64 %indvars.iv41.i
  store float %add111.i, float* %arrayidx116.i, align 4, !tbaa !0
  %indvars.iv.next42.i = add nuw nsw i64 %indvars.iv41.i, 1
  %exitcond43.i = icmp eq i64 %indvars.iv.next42.i, 2160
  br i1 %exitcond43.i, label %for.inc.120.i, label %for.body.102.i

for.inc.120.i:                                    ; preds = %for.body.102.i
  %indvars.iv.next45.i = add nuw nsw i64 %indvars.iv44.i, 1
  %exitcond46.i = icmp eq i64 %indvars.iv.next45.i, 4096
  br i1 %exitcond46.i, label %for.cond.126.preheader.i.preheader.exitStub, label %for.cond.100.preheader.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
