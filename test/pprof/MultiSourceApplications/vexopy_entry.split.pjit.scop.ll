
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false -polly-detect-keep-going -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/sgefa/blas.c.vexopy_entry.split.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @vexopy_entry.split.pjit.scop(i32 %n, i32 %itype, float* %v, float* %y, float* %x)  {
newFuncRoot:
  br label %entry.split

cleanup.exitStub:                                 ; preds = %cleanup.loopexit44, %for.cond.6.preheader, %cleanup.loopexit, %for.cond.preheader, %entry.split
  ret void

entry.split:                                      ; preds = %newFuncRoot
  %cmp = icmp slt i32 %n, 1
  br i1 %cmp, label %cleanup.exitStub, label %if.end

if.end:                                           ; preds = %entry.split
  %cmp1 = icmp eq i32 %itype, 1
  %cmp3.32 = icmp sgt i32 %n, 0
  br i1 %cmp1, label %for.cond.preheader, label %for.cond.6.preheader

for.cond.preheader:                               ; preds = %if.end
  br i1 %cmp3.32, label %for.body.preheader, label %cleanup.exitStub

for.body.preheader:                               ; preds = %for.cond.preheader
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.preheader
  %i.036 = phi i32 [ %inc, %for.body ], [ 0, %for.body.preheader ]
  %v.addr.035 = phi float* [ %incdec.ptr5, %for.body ], [ %v, %for.body.preheader ]
  %y.addr.034 = phi float* [ %incdec.ptr4, %for.body ], [ %y, %for.body.preheader ]
  %x.addr.033 = phi float* [ %incdec.ptr, %for.body ], [ %x, %for.body.preheader ]
  %0 = load float, float* %x.addr.033, align 4, !tbaa !0
  %1 = load float, float* %y.addr.034, align 4, !tbaa !0
  %add = fadd float %0, %1
  store float %add, float* %v.addr.035, align 4, !tbaa !0
  %inc = add nuw nsw i32 %i.036, 1
  %incdec.ptr = getelementptr inbounds float, float* %x.addr.033, i64 1
  %incdec.ptr4 = getelementptr inbounds float, float* %y.addr.034, i64 1
  %incdec.ptr5 = getelementptr inbounds float, float* %v.addr.035, i64 1
  %exitcond = icmp eq i32 %inc, %n
  br i1 %exitcond, label %cleanup.loopexit, label %for.body

cleanup.loopexit:                                 ; preds = %for.body
  br label %cleanup.exitStub

for.cond.6.preheader:                             ; preds = %if.end
  br i1 %cmp3.32, label %for.body.8.preheader, label %cleanup.exitStub

for.body.8.preheader:                             ; preds = %for.cond.6.preheader
  br label %for.body.8

for.body.8:                                       ; preds = %for.body.8, %for.body.8.preheader
  %i.141 = phi i32 [ %inc10, %for.body.8 ], [ 0, %for.body.8.preheader ]
  %v.addr.140 = phi float* [ %incdec.ptr13, %for.body.8 ], [ %v, %for.body.8.preheader ]
  %y.addr.139 = phi float* [ %incdec.ptr12, %for.body.8 ], [ %y, %for.body.8.preheader ]
  %x.addr.138 = phi float* [ %incdec.ptr11, %for.body.8 ], [ %x, %for.body.8.preheader ]
  %2 = load float, float* %x.addr.138, align 4, !tbaa !0
  %3 = load float, float* %y.addr.139, align 4, !tbaa !0
  %sub = fsub float %2, %3
  store float %sub, float* %v.addr.140, align 4, !tbaa !0
  %inc10 = add nuw nsw i32 %i.141, 1
  %incdec.ptr11 = getelementptr inbounds float, float* %x.addr.138, i64 1
  %incdec.ptr12 = getelementptr inbounds float, float* %y.addr.139, i64 1
  %incdec.ptr13 = getelementptr inbounds float, float* %v.addr.140, i64 1
  %exitcond43 = icmp eq i32 %inc10, %n
  br i1 %exitcond43, label %cleanup.loopexit44, label %for.body.8

cleanup.loopexit44:                               ; preds = %for.body.8
  br label %cleanup.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
