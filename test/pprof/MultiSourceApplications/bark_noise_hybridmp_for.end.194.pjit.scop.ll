
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceApplications/test-suite/MultiSource/Applications/oggenc/oggenc.c.bark_noise_hybridmp_for.end.194.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @bark_noise_hybridmp_for.end.194.pjit.scop(i32 %fixed, float*, float*, float*, float*, float*, float %offset, float* %noise, float %D.1.lcssa, float %B.1.lcssa, float %A.1.lcssa, i32 %n)  {
newFuncRoot:
  br label %for.end.194

cleanup.exitStub:                                 ; preds = %cleanup.loopexit, %for.cond.322.preheader, %for.end.194
  ret void

for.end.194:                                      ; preds = %newFuncRoot
  %cmp195 = icmp slt i32 %fixed, 1
  br i1 %cmp195, label %cleanup.exitStub, label %for.cond.199.preheader

for.cond.199.preheader:                           ; preds = %for.end.194
  %div200 = sdiv i32 %fixed, 2
  %cmp203.672 = icmp slt i32 %div200, %fixed
  br i1 %cmp203.672, label %if.end.206.preheader, label %for.cond.263.preheader

if.end.206.preheader:                             ; preds = %for.cond.199.preheader
  %5 = sub i32 %div200, %fixed
  %6 = sext i32 %5 to i64
  %7 = zext i32 %div200 to i64
  %8 = sub i32 %fixed, %div200
  br label %if.end.206

if.end.206:                                       ; preds = %for.inc.259, %if.end.206.preheader
  %indvars.iv730 = phi i64 [ 0, %if.end.206.preheader ], [ %indvars.iv.next731, %for.inc.259 ]
  %indvars.iv727 = phi i64 [ %6, %if.end.206.preheader ], [ %indvars.iv.next728, %for.inc.259 ]
  %add201675 = phi i32 [ %div200, %if.end.206.preheader ], [ %22, %for.inc.259 ]
  %x.4674 = phi float [ 0.000000e+00, %if.end.206.preheader ], [ %add261, %for.inc.259 ]
  %idxprom207 = sext i32 %add201675 to i64
  %arrayidx208 = getelementptr inbounds float, float* %0, i64 %idxprom207
  %9 = load float, float* %arrayidx208, align 4
  %10 = sub nsw i64 0, %indvars.iv727
  %arrayidx211 = getelementptr inbounds float, float* %0, i64 %10
  %11 = load float, float* %arrayidx211, align 4
  %add212 = fadd float %9, %11
  %arrayidx214 = getelementptr inbounds float, float* %1, i64 %idxprom207
  %12 = load float, float* %arrayidx214, align 4
  %arrayidx217 = getelementptr inbounds float, float* %1, i64 %10
  %13 = load float, float* %arrayidx217, align 4
  %sub218 = fsub float %12, %13
  %arrayidx220 = getelementptr inbounds float, float* %2, i64 %idxprom207
  %14 = load float, float* %arrayidx220, align 4
  %arrayidx223 = getelementptr inbounds float, float* %2, i64 %10
  %15 = load float, float* %arrayidx223, align 4
  %add224 = fadd float %14, %15
  %arrayidx226 = getelementptr inbounds float, float* %3, i64 %idxprom207
  %16 = load float, float* %arrayidx226, align 4
  %arrayidx229 = getelementptr inbounds float, float* %3, i64 %10
  %17 = load float, float* %arrayidx229, align 4
  %add230 = fadd float %16, %17
  %arrayidx232 = getelementptr inbounds float, float* %4, i64 %idxprom207
  %18 = load float, float* %arrayidx232, align 4
  %arrayidx235 = getelementptr inbounds float, float* %4, i64 %10
  %19 = load float, float* %arrayidx235, align 4
  %sub236 = fsub float %18, %19
  %mul237 = fmul float %add224, %add230
  %mul238 = fmul float %sub218, %sub236
  %sub239 = fsub float %mul237, %mul238
  %mul240 = fmul float %add212, %sub236
  %mul241 = fmul float %sub218, %add230
  %sub242 = fsub float %mul240, %mul241
  %mul243 = fmul float %add212, %add224
  %mul244 = fmul float %sub218, %sub218
  %sub245 = fsub float %mul243, %mul244
  %mul246 = fmul float %x.4674, %sub242
  %add247 = fadd float %sub239, %mul246
  %div248 = fdiv float %add247, %sub245
  %sub249 = fsub float %div248, %offset
  %arrayidx251 = getelementptr inbounds float, float* %noise, i64 %indvars.iv730
  %20 = load float, float* %arrayidx251, align 4
  %cmp252 = fcmp olt float %sub249, %20
  br i1 %cmp252, label %if.then.254, label %for.inc.259

if.then.254:                                      ; preds = %if.end.206
  store float %sub249, float* %arrayidx251, align 4
  br label %for.inc.259

for.inc.259:                                      ; preds = %if.then.254, %if.end.206
  %indvars.iv.next731 = add nuw nsw i64 %indvars.iv730, 1
  %add261 = fadd float %x.4674, 1.000000e+00
  %21 = add nuw nsw i64 %indvars.iv.next731, %7
  %indvars.iv.next728 = add nsw i64 %indvars.iv727, 1
  %22 = trunc i64 %21 to i32
  %lftr.wideiv748 = trunc i64 %indvars.iv.next731 to i32
  %exitcond749 = icmp eq i32 %lftr.wideiv748, %8
  br i1 %exitcond749, label %for.cond.263.preheader.loopexit, label %if.end.206

for.cond.263.preheader.loopexit:                  ; preds = %for.inc.259
  %add261.lcssa = phi float [ %add261, %for.inc.259 ]
  %sub245.lcssa = phi float [ %sub245, %for.inc.259 ]
  %sub242.lcssa = phi float [ %sub242, %for.inc.259 ]
  %sub239.lcssa = phi float [ %sub239, %for.inc.259 ]
  %23 = sub i32 %fixed, %div200
  br label %for.cond.263.preheader

for.cond.263.preheader:                           ; preds = %for.cond.263.preheader.loopexit, %for.cond.199.preheader
  %x.4.lcssa = phi float [ 0.000000e+00, %for.cond.199.preheader ], [ %add261.lcssa, %for.cond.263.preheader.loopexit ]
  %D.2.lcssa = phi float [ %D.1.lcssa, %for.cond.199.preheader ], [ %sub245.lcssa, %for.cond.263.preheader.loopexit ]
  %B.2.lcssa = phi float [ %B.1.lcssa, %for.cond.199.preheader ], [ %sub242.lcssa, %for.cond.263.preheader.loopexit ]
  %A.2.lcssa = phi float [ %A.1.lcssa, %for.cond.199.preheader ], [ %sub239.lcssa, %for.cond.263.preheader.loopexit ]
  %i.4.lcssa = phi i32 [ 0, %for.cond.199.preheader ], [ %23, %for.cond.263.preheader.loopexit ]
  %add265.662 = add nsw i32 %i.4.lcssa, %div200
  %cmp267.663 = icmp slt i32 %add265.662, %n
  br i1 %cmp267.663, label %if.end.270.preheader, label %for.cond.322.preheader

if.end.270.preheader:                             ; preds = %for.cond.263.preheader
  %24 = add i32 %i.4.lcssa, %div200
  %25 = sext i32 %24 to i64
  %26 = sext i32 %fixed to i64
  %27 = sext i32 %i.4.lcssa to i64
  %28 = sub i32 %n, %div200
  br label %if.end.270

if.end.270:                                       ; preds = %for.inc.318, %if.end.270.preheader
  %indvars.iv723 = phi i64 [ %27, %if.end.270.preheader ], [ %indvars.iv.next724, %for.inc.318 ]
  %indvars.iv720 = phi i64 [ %25, %if.end.270.preheader ], [ %indvars.iv.next721, %for.inc.318 ]
  %x.5665 = phi float [ %x.4.lcssa, %if.end.270.preheader ], [ %add320, %for.inc.318 ]
  %29 = sub nsw i64 %indvars.iv720, %26
  %arrayidx272 = getelementptr inbounds float, float* %0, i64 %indvars.iv720
  %30 = load float, float* %arrayidx272, align 4
  %arrayidx274 = getelementptr inbounds float, float* %0, i64 %29
  %31 = load float, float* %arrayidx274, align 4
  %sub275 = fsub float %30, %31
  %arrayidx277 = getelementptr inbounds float, float* %1, i64 %indvars.iv720
  %32 = load float, float* %arrayidx277, align 4
  %arrayidx279 = getelementptr inbounds float, float* %1, i64 %29
  %33 = load float, float* %arrayidx279, align 4
  %sub280 = fsub float %32, %33
  %arrayidx282 = getelementptr inbounds float, float* %2, i64 %indvars.iv720
  %34 = load float, float* %arrayidx282, align 4
  %arrayidx284 = getelementptr inbounds float, float* %2, i64 %29
  %35 = load float, float* %arrayidx284, align 4
  %sub285 = fsub float %34, %35
  %arrayidx287 = getelementptr inbounds float, float* %3, i64 %indvars.iv720
  %36 = load float, float* %arrayidx287, align 4
  %arrayidx289 = getelementptr inbounds float, float* %3, i64 %29
  %37 = load float, float* %arrayidx289, align 4
  %sub290 = fsub float %36, %37
  %arrayidx292 = getelementptr inbounds float, float* %4, i64 %indvars.iv720
  %38 = load float, float* %arrayidx292, align 4
  %arrayidx294 = getelementptr inbounds float, float* %4, i64 %29
  %39 = load float, float* %arrayidx294, align 4
  %sub295 = fsub float %38, %39
  %mul296 = fmul float %sub285, %sub290
  %mul297 = fmul float %sub280, %sub295
  %sub298 = fsub float %mul296, %mul297
  %mul299 = fmul float %sub275, %sub295
  %mul300 = fmul float %sub280, %sub290
  %sub301 = fsub float %mul299, %mul300
  %mul302 = fmul float %sub275, %sub285
  %mul303 = fmul float %sub280, %sub280
  %sub304 = fsub float %mul302, %mul303
  %mul305 = fmul float %x.5665, %sub301
  %add306 = fadd float %sub298, %mul305
  %div307 = fdiv float %add306, %sub304
  %sub308 = fsub float %div307, %offset
  %arrayidx310 = getelementptr inbounds float, float* %noise, i64 %indvars.iv723
  %40 = load float, float* %arrayidx310, align 4
  %cmp311 = fcmp olt float %sub308, %40
  br i1 %cmp311, label %if.then.313, label %for.inc.318

if.then.313:                                      ; preds = %if.end.270
  store float %sub308, float* %arrayidx310, align 4
  br label %for.inc.318

for.inc.318:                                      ; preds = %if.then.313, %if.end.270
  %add320 = fadd float %x.5665, 1.000000e+00
  %indvars.iv.next721 = add nsw i64 %indvars.iv720, 1
  %indvars.iv.next724 = add nsw i64 %indvars.iv723, 1
  %lftr.wideiv725 = trunc i64 %indvars.iv.next724 to i32
  %exitcond726 = icmp eq i32 %lftr.wideiv725, %28
  br i1 %exitcond726, label %for.cond.322.preheader.loopexit, label %if.end.270

for.cond.322.preheader.loopexit:                  ; preds = %for.inc.318
  %add320.lcssa = phi float [ %add320, %for.inc.318 ]
  %sub304.lcssa = phi float [ %sub304, %for.inc.318 ]
  %sub301.lcssa = phi float [ %sub301, %for.inc.318 ]
  %sub298.lcssa = phi float [ %sub298, %for.inc.318 ]
  br label %for.cond.322.preheader

for.cond.322.preheader:                           ; preds = %for.cond.322.preheader.loopexit, %for.cond.263.preheader
  %x.5.lcssa = phi float [ %x.4.lcssa, %for.cond.263.preheader ], [ %add320.lcssa, %for.cond.322.preheader.loopexit ]
  %D.3.lcssa = phi float [ %D.2.lcssa, %for.cond.263.preheader ], [ %sub304.lcssa, %for.cond.322.preheader.loopexit ]
  %B.3.lcssa = phi float [ %B.2.lcssa, %for.cond.263.preheader ], [ %sub301.lcssa, %for.cond.322.preheader.loopexit ]
  %A.3.lcssa = phi float [ %A.2.lcssa, %for.cond.263.preheader ], [ %sub298.lcssa, %for.cond.322.preheader.loopexit ]
  %i.5.lcssa = phi i32 [ %i.4.lcssa, %for.cond.263.preheader ], [ %28, %for.cond.322.preheader.loopexit ]
  %cmp323.659 = icmp slt i32 %i.5.lcssa, %n
  br i1 %cmp323.659, label %for.body.325.preheader, label %cleanup.exitStub

for.body.325.preheader:                           ; preds = %for.cond.322.preheader
  %41 = sext i32 %i.5.lcssa to i64
  br label %for.body.325

for.body.325:                                     ; preds = %for.inc.339, %for.body.325.preheader
  %indvars.iv = phi i64 [ %41, %for.body.325.preheader ], [ %indvars.iv.next, %for.inc.339 ]
  %x.6661 = phi float [ %x.5.lcssa, %for.body.325.preheader ], [ %add341, %for.inc.339 ]
  %mul326 = fmul float %B.3.lcssa, %x.6661
  %add327 = fadd float %A.3.lcssa, %mul326
  %div328 = fdiv float %add327, %D.3.lcssa
  %sub329 = fsub float %div328, %offset
  %arrayidx331 = getelementptr inbounds float, float* %noise, i64 %indvars.iv
  %42 = load float, float* %arrayidx331, align 4
  %cmp332 = fcmp olt float %sub329, %42
  br i1 %cmp332, label %if.then.334, label %for.inc.339

if.then.334:                                      ; preds = %for.body.325
  store float %sub329, float* %arrayidx331, align 4
  br label %for.inc.339

for.inc.339:                                      ; preds = %if.then.334, %for.body.325
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %add341 = fadd float %x.6661, 1.000000e+00
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %n
  br i1 %exitcond, label %cleanup.loopexit, label %for.body.325

cleanup.loopexit:                                 ; preds = %for.inc.339
  br label %cleanup.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }
