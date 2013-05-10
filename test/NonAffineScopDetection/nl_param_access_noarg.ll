; ModuleID = 'nl_param_access_noarg.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define i32 @foo(i64 %n) #0 {
entry:
  %retval = alloca i32, align 4
  %n.addr = alloca i64, align 8
  %A = alloca [128 x i64], align 16
  %m = alloca i64, align 8
  %i = alloca i64, align 8
  store i64 %n, i64* %n.addr, align 8
  %0 = load i64* %n.addr, align 8
  store i64 %0, i64* %m, align 8
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i64* %i, align 8
  %cmp = icmp slt i64 %1, 32
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %2 = load i64* %i, align 8
  %3 = load i64* %m, align 8
  %add = add nsw i64 %2, %3
  %4 = load i64* %i, align 8
  %5 = load i64* %m, align 8
  %mul = mul nsw i64 %4, %5
  %arrayidx = getelementptr inbounds [128 x i64]* %A, i32 0, i64 %mul
  store i64 %add, i64* %arrayidx, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %6 = load i64* %i, align 8
  %inc = add nsw i64 %6, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %7 = load i32* %retval
  ret i32 %7
}

define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  %call = call i32 @foo(i64 3)
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
