
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'encoder/ratecontrol.c.x264_ratecontrol_new_for.body.225.us.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @x264_ratecontrol_new_for.body.225.us.i.pjit.scop(float %sub213.i, float %mul229.i, i32*, i64, float %cond.i.1707, float*, i32, float %div204.i, i64)  {
newFuncRoot:
  br label %for.body.225.us.i

for.cond.cleanup.224.i.loopexit.exitStub:         ; preds = %for.cond.cleanup.274.us.i
  ret void

for.body.225.us.i:                                ; preds = %for.cond.cleanup.274.us.i, %newFuncRoot
  %indvars.iv476.i = phi i64 [ 0, %newFuncRoot ], [ %indvars.iv.next477.i, %for.cond.cleanup.274.us.i ]
  %dstinsrc.0406.us.i = phi float [ %sub213.i, %newFuncRoot ], [ %add288.us.i, %for.cond.cleanup.274.us.i ]
  %sub230.us.i = fsub fast float %dstinsrc.0406.us.i, %mul229.i
  %conv231.us.i = fptosi float %sub230.us.i to i32
  %arrayidx237.us.i = getelementptr inbounds i32, i32* %0, i64 %indvars.iv476.i
  store i32 %conv231.us.i, i32* %arrayidx237.us.i, align 4, !tbaa !0
  %5 = mul nsw i64 %indvars.iv476.i, %1
  %6 = zext i32 %conv231.us.i to i64
  br label %for.body.242.us.i

for.body.242.us.i:                                ; preds = %for.body.242.us.i, %for.body.225.us.i
  %indvars.iv465.i = phi i64 [ 0, %for.body.225.us.i ], [ %indvars.iv.next466.i, %for.body.242.us.i ]
  %sum.0401.us.i = phi float [ 0.000000e+00, %for.body.225.us.i ], [ %add267.us.i, %for.body.242.us.i ]
  %7 = add nuw nsw i64 %indvars.iv465.i, %6
  %8 = trunc i64 %7 to i32
  %conv244.us.i = sitofp i32 %8 to float
  %sub245.us.i = fsub fast float %conv244.us.i, %dstinsrc.0406.us.i
  %fabsf.us.i = call float @fabsf(float %sub245.us.i) #1
  %conv250.us.i = fmul fast float %fabsf.us.i, %cond.i.1707
  %sub251.us.i = fsub fast float 1.000000e+00, %conv250.us.i
  %cmp252.us.i = fcmp fast ogt float %sub251.us.i, 0.000000e+00
  %cond258.us.i = select i1 %cmp252.us.i, float %sub251.us.i, float 0.000000e+00
  %9 = add nsw i64 %indvars.iv465.i, %5
  %arrayidx266.us.i = getelementptr inbounds float, float* %2, i64 %9
  store float %cond258.us.i, float* %arrayidx266.us.i, align 4, !tbaa !4
  %add267.us.i = fadd fast float %cond258.us.i, %sum.0401.us.i
  %indvars.iv.next466.i = add nuw nsw i64 %indvars.iv465.i, 1
  %lftr.wideiv2006 = trunc i64 %indvars.iv.next466.i to i32
  %exitcond2007 = icmp eq i32 %lftr.wideiv2006, %3
  br i1 %exitcond2007, label %for.body.275.lr.ph.us.i, label %for.body.242.us.i

for.body.275.lr.ph.us.i:                          ; preds = %for.body.242.us.i
  %add267.us.i.lcssa = phi float [ %add267.us.i, %for.body.242.us.i ]
  %div269.us.i = fdiv fast float 1.000000e+00, %add267.us.i.lcssa
  br label %for.body.275.us.i

for.body.275.us.i:                                ; preds = %for.body.275.us.i, %for.body.275.lr.ph.us.i
  %indvars.iv471.i = phi i64 [ 0, %for.body.275.lr.ph.us.i ], [ %indvars.iv.next472.i, %for.body.275.us.i ]
  %10 = add nsw i64 %indvars.iv471.i, %5
  %arrayidx283.us.i = getelementptr inbounds float, float* %2, i64 %10
  %11 = load float, float* %arrayidx283.us.i, align 4, !tbaa !4
  %mul284.us.i = fmul fast float %11, %div269.us.i
  store float %mul284.us.i, float* %arrayidx283.us.i, align 4, !tbaa !4
  %indvars.iv.next472.i = add nuw nsw i64 %indvars.iv471.i, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next472.i to i32
  %exitcond2008 = icmp eq i32 %lftr.wideiv, %3
  br i1 %exitcond2008, label %for.cond.cleanup.274.us.i, label %for.body.275.us.i

for.cond.cleanup.274.us.i:                        ; preds = %for.body.275.us.i
  %add288.us.i = fadd fast float %dstinsrc.0406.us.i, %div204.i
  %indvars.iv.next477.i = add nuw nsw i64 %indvars.iv476.i, 1
  %exitcond1924 = icmp eq i64 %indvars.iv.next477.i, %4
  br i1 %exitcond1924, label %for.cond.cleanup.224.i.loopexit.exitStub, label %for.body.225.us.i
}

declare float @fabsf(float)

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }
attributes #1 = { nounwind readnone "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="true" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"float", !2, i64 0}
