
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'libavfilter/af_afade.c.fade_samples_s16_for.body.us.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @fade_samples_s16_for.body.us.pjit.scop(i64, i64 %start, double %conv1.i, i1 %cmp3.28, i16*, i16*, i32 %channels, i32 %nb_samples)  {
newFuncRoot:
  br label %for.body.us

for.end.16.loopexit.exitStub:                     ; preds = %for.end.us
  ret void

for.body.us:                                      ; preds = %for.end.us, %newFuncRoot
  %indvars.iv35 = phi i64 [ %indvars.iv.next36, %for.end.us ], [ 0, %newFuncRoot ]
  %k.032.us = phi i32 [ %k.1.lcssa.us, %for.end.us ], [ 0, %newFuncRoot ]
  %3 = mul nsw i64 %indvars.iv35, %0
  %add.us = add nsw i64 %3, %start
  %conv.i.us = sitofp i64 %add.us to double
  %div.i.us = fdiv nsz double %conv.i.us, %conv1.i
  %cmp.i.us = fcmp nsz olt double %div.i.us, 1.000000e+00
  %phitmp.i.us = fcmp olt double %div.i.us, 0.000000e+00
  %cond.i.us = and i1 %cmp.i.us, %phitmp.i.us
  %4 = xor i1 %cmp.i.us, true
  %brmerge.i.us = or i1 %phitmp.i.us, %4
  %.mux.i.us = select i1 %cond.i.us, double 0.000000e+00, double 1.000000e+00
  %cond26.i.us = select i1 %brmerge.i.us, double %.mux.i.us, double %div.i.us
  %mul27.i.us = fmul nsz double %cond26.i.us, 0x400921FB54442D18
  %div28.i.us = fmul nsz double %mul27.i.us, 5.000000e-01
  %call.i.us = tail call double @sin(double %div28.i.us) #2
  br i1 %cmp3.28, label %for.body.5.us.preheader, label %for.end.us

for.body.5.us.preheader:                          ; preds = %for.body.us
  %5 = sext i32 %k.032.us to i64
  br label %for.body.5.us

for.body.5.us:                                    ; preds = %for.body.5.us, %for.body.5.us.preheader
  %indvars.iv = phi i64 [ %5, %for.body.5.us.preheader ], [ %indvars.iv.next, %for.body.5.us ]
  %c.029.us = phi i32 [ 0, %for.body.5.us.preheader ], [ %inc.us, %for.body.5.us ]
  %arrayidx6.us = getelementptr inbounds i16, i16* %1, i64 %indvars.iv
  %6 = load i16, i16* %arrayidx6.us, align 2, !tbaa !0
  %conv8.us = sitofp i16 %6 to double
  %mul9.us = fmul nsz double %call.i.us, %conv8.us
  %conv10.us = fptosi double %mul9.us to i16
  %arrayidx12.us = getelementptr inbounds i16, i16* %2, i64 %indvars.iv
  store i16 %conv10.us, i16* %arrayidx12.us, align 2, !tbaa !0
  %inc.us = add nuw nsw i32 %c.029.us, 1
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i32 %inc.us, %channels
  br i1 %exitcond, label %for.end.us.loopexit, label %for.body.5.us

for.end.us.loopexit:                              ; preds = %for.body.5.us
  %7 = add i32 %k.032.us, %channels
  br label %for.end.us

for.end.us:                                       ; preds = %for.end.us.loopexit, %for.body.us
  %k.1.lcssa.us = phi i32 [ %k.032.us, %for.body.us ], [ %7, %for.end.us.loopexit ]
  %indvars.iv.next36 = add nuw nsw i64 %indvars.iv35, 1
  %lftr.wideiv48 = trunc i64 %indvars.iv.next36 to i32
  %exitcond49 = icmp eq i32 %lftr.wideiv48, %nb_samples
  br i1 %exitcond49, label %for.end.16.loopexit.exitStub, label %for.body.us
}

; Function Attrs: nounwind readnone
declare double @sin(double) #1

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }
attributes #1 = { nounwind readnone "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone }

!0 = !{!1, !1, i64 0}
!1 = !{!"short", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
