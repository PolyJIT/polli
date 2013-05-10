; RUN: %polliBinDir/polli < %s | FileCheck %s -check-prefix=INNER
; RUN: %polliBinDir/polli < %s | FileCheck %s -check-prefix=OUTER
; RUN: %polliBinDir/polli -polly-allow-nonaffine < %s | FileCheck %s -check-prefix=ALLOW

; ModuleID = 'simple_non_linear_it_var_access_fct.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %A = alloca [1024 x i32], align 16
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc4, %entry
  %0 = load i32* %i, align 4
  %cmp = icmp slt i32 %0, 32
  br i1 %cmp, label %for.body, label %for.end6

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond1

for.cond1:                                        ; preds = %for.inc, %for.body
  %1 = load i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 32
  br i1 %cmp2, label %for.body3, label %for.end

for.body3:                                        ; preds = %for.cond1
  %2 = load i32* %i, align 4
  %3 = load i32* %j, align 4
  %add = add nsw i32 %2, %3
  %4 = load i32* %i, align 4
  %5 = load i32* %j, align 4
  %mul = mul nsw i32 %4, %5
  %idxprom = sext i32 %mul to i64
  %arrayidx = getelementptr inbounds [1024 x i32]* %A, i32 0, i64 %idxprom
  store i32 %add, i32* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body3
  %6 = load i32* %j, align 4
  %inc = add nsw i32 %6, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond1

for.end:                                          ; preds = %for.cond1
  br label %for.inc4

for.inc4:                                         ; preds = %for.end
  %7 = load i32* %i, align 4
  %inc5 = add nsw i32 %7, 1
  store i32 %inc5, i32* %i, align 4
  br label %for.cond

for.end6:                                         ; preds = %for.cond
  %8 = load i32* %retval
  ret i32 %8
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }

; INNER: [polli] rejected region: for.cond1 => for.end
; INNER:         reason:  non affine access function.
; INNER:         details: {0,+,{0,+,sizeof(i32)}<%for.cond>}<%for.cond1>

; OUTER: [polli] rejected region: for.cond => for.end6
; OUTER:         reason:  non affine access function.
; OUTER:         details: {0,+,{0,+,sizeof(i32)}<%for.cond>}<%for.cond1>

; ALLOW: [polli] rejected region: for.cond => for.end6
; ALLOW:         reason:  non affine access function.
; ALLOW:         details: {0,+,{0,+,sizeof(i32)}<%for.cond>}<%for.cond1>
; ALLOW: [polli] invalid non affine SCoP! for.cond => for.end6