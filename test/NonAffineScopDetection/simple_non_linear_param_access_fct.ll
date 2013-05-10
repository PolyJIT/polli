; RUN: %polliBinDir/polli < %s | FileCheck %s
; RUN: %polliBinDir/polli -polly-allow-nonaffine < %s | FileCheck %s -check-prefix=ALLOW

; ModuleID = 'simple_non_linear_param_access_fct.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %A = alloca [1024 x i32], align 16
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  %call = call i32 @rand() #2
  %rem = srem i32 %call, 32
  store i32 %rem, i32* %n, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32* %i, align 4
  %1 = load i32* %n, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %2 = load i32* %i, align 4
  %3 = load i32* %n, align 4
  %4 = load i32* %i, align 4
  %mul = mul nsw i32 %3, %4
  %idxprom = sext i32 %mul to i64
  %arrayidx = getelementptr inbounds [1024 x i32]* %A, i32 0, i64 %idxprom
  store i32 %2, i32* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %5 = load i32* %i, align 4
  %inc = add nsw i32 %5, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %6 = load i32* %retval
  ret i32 %6
}

declare i32 @rand() #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

; CHECK: [polli] rejected region: for.cond => for.end
; CHECK:         reason:  non affine access function.
; CHECK:         details: ((sext i32 {0,+,%rem}<%for.cond> to i64) * sizeof(i32))<nsw>

; ALLOW: [polli] rejected region: for.cond => for.end
; ALLOW:         reason:  non affine access function.
; ALLOW:         details: ((sext i32 {0,+,%rem}<%for.cond> to i64) * sizeof(i32))<nsw>
; ALLOW: [polli] valid non affine SCoP! for.cond => for.end