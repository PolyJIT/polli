; RUN: %polliBinDir/polli -debug-only="polyjit" -no-execution -l papi -l pprof -mcjit -polly-detect-keep-going -polly-detect-track-failures -jitable %s 2>&1 | FileCheck %s

; Function Attrs: nounwind uwtable
define float @TEST_3_NON_AFF_ACCESS(i64 %n) #0 {
entry:
  %n.addr = alloca i64, align 8
  %A = alloca [10240 x i64], align 16
  %B = alloca [10240 x double], align 16
  %C = alloca [10240 x float], align 16
  %i = alloca i64, align 8
  store i64 %n, i64* %n.addr, align 8
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i64* %i, align 8
  %cmp = icmp slt i64 %0, 10
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i64* %i, align 8
  %2 = load i64* %n.addr, align 8
  %3 = load i64* %i, align 8
  %mul = mul i64 %2, %3
  %arrayidx = getelementptr inbounds [10240 x i64]* %A, i32 0, i64 %mul
  store i64 %1, i64* %arrayidx, align 8
  %4 = load i64* %i, align 8
  %conv = sitofp i64 %4 to double
  %5 = load i64* %n.addr, align 8
  %6 = load i64* %i, align 8
  %mul1 = mul i64 %5, %6
  %arrayidx2 = getelementptr inbounds [10240 x double]* %B, i32 0, i64 %mul1
  store double %conv, double* %arrayidx2, align 8
  %7 = load i64* %n.addr, align 8
  %8 = load i64* %i, align 8
  %mul3 = mul i64 %7, %8
  %cmp4 = icmp ugt i64 %mul3, 0
  br i1 %cmp4, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %9 = load i64* %i, align 8
  %arrayidx6 = getelementptr inbounds [10240 x i64]* %A, i32 0, i64 %9
  %10 = load i64* %arrayidx6, align 8
  %conv7 = sitofp i64 %10 to double
  %11 = load i64* %i, align 8
  %arrayidx8 = getelementptr inbounds [10240 x double]* %B, i32 0, i64 %11
  %12 = load double* %arrayidx8, align 8
  %add = fadd double %conv7, %12
  %conv9 = fptrunc double %add to float
  %13 = load i64* %n.addr, align 8
  %14 = load i64* %i, align 8
  %mul10 = mul i64 %13, %14
  %arrayidx11 = getelementptr inbounds [10240 x float]* %C, i32 0, i64 %mul10
  store float %conv9, float* %arrayidx11, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %15 = load i64* %i, align 8
  %inc = add nsw i64 %15, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %16 = load i64* %n.addr, align 8
  %arrayidx12 = getelementptr inbounds [10240 x float]* %C, i32 0, i64 %16
  %17 = load float* %arrayidx12, align 4
  ret float %17
}

; Function Attrs: nounwind uwtable
define float @TEST_1_NON_AFF_LOOP_BOUND(i32 %n) #0 {
entry:
  %n.addr = alloca i32, align 4
  %A = alloca [10240 x i32], align 16
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 %n, i32* %n.addr, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc4, %entry
  %0 = load i32* %i, align 4
  %cmp = icmp slt i32 %0, 10
  br i1 %cmp, label %for.body, label %for.end6

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond1

for.cond1:                                        ; preds = %for.inc, %for.body
  %1 = load i32* %j, align 4
  %2 = load i32* %n.addr, align 4
  %3 = load i32* %i, align 4
  %mul = mul nsw i32 %2, %3
  %cmp2 = icmp slt i32 %1, %mul
  br i1 %cmp2, label %for.body3, label %for.end

for.body3:                                        ; preds = %for.cond1
  %4 = load i32* %i, align 4
  %5 = load i32* %i, align 4
  %idxprom = sext i32 %5 to i64
  %arrayidx = getelementptr inbounds [10240 x i32]* %A, i32 0, i64 %idxprom
  store i32 %4, i32* %arrayidx, align 4
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
  %8 = load i32* %n.addr, align 4
  %idxprom7 = sext i32 %8 to i64
  %arrayidx8 = getelementptr inbounds [10240 x i32]* %A, i32 0, i64 %idxprom7
  %9 = load i32* %arrayidx8, align 4
  %conv = sitofp i32 %9 to float
  ret float %conv
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %A = alloca [10240 x i32], align 16
  %B = alloca [10240 x double], align 16
  %C = alloca [10 x float], align 16
  %D = alloca [10240 x i8], align 16
  %result = alloca i32, align 4
  %i = alloca i32, align 4
  %i9 = alloca i32, align 4
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 0, i32* %result, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32* %i, align 4
  %cmp = icmp slt i32 %0, 10
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32* %i, align 4
  %conv = sext i32 %1 to i64
  %call = call float @TEST_3_NON_AFF_ACCESS(i64 %conv)
  %2 = load i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %arrayidx = getelementptr inbounds [10 x float]* %C, i32 0, i64 %idxprom
  store float %call, float* %arrayidx, align 4
  %3 = load i32* %i, align 4
  %call1 = call float @TEST_1_NON_AFF_LOOP_BOUND(i32 %3)
  %4 = load i32* %i, align 4
  %idxprom2 = sext i32 %4 to i64
  %arrayidx3 = getelementptr inbounds [10 x float]* %C, i32 0, i64 %idxprom2
  %5 = load float* %arrayidx3, align 4
  %add = fadd float %5, %call1
  store float %add, float* %arrayidx3, align 4
  %6 = load i32* %i, align 4
  %idxprom4 = sext i32 %6 to i64
  %arrayidx5 = getelementptr inbounds [10 x float]* %C, i32 0, i64 %idxprom4
  %7 = load float* %arrayidx5, align 4
  %8 = load i32* %result, align 4
  %conv6 = sitofp i32 %8 to float
  %add7 = fadd float %conv6, %7
  %conv8 = fptosi float %add7 to i32
  store i32 %conv8, i32* %result, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %9 = load i32* %i, align 4
  %inc = add nsw i32 %9, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  store i32 0, i32* %i9, align 4
  br label %for.cond10

for.cond10:                                       ; preds = %for.inc27, %for.end
  %10 = load i32* %i9, align 4
  %cmp11 = icmp slt i32 %10, 10
  br i1 %cmp11, label %for.body13, label %for.end29

for.body13:                                       ; preds = %for.cond10
  %11 = load i32* %i9, align 4
  %conv14 = sext i32 %11 to i64
  %call15 = call float @TEST_3_NON_AFF_ACCESS(i64 %conv14)
  %12 = load i32* %i9, align 4
  %idxprom16 = sext i32 %12 to i64
  %arrayidx17 = getelementptr inbounds [10 x float]* %C, i32 0, i64 %idxprom16
  store float %call15, float* %arrayidx17, align 4
  %13 = load i32* %i9, align 4
  %call18 = call float @TEST_1_NON_AFF_LOOP_BOUND(i32 %13)
  %14 = load i32* %i9, align 4
  %idxprom19 = sext i32 %14 to i64
  %arrayidx20 = getelementptr inbounds [10 x float]* %C, i32 0, i64 %idxprom19
  %15 = load float* %arrayidx20, align 4
  %add21 = fadd float %15, %call18
  store float %add21, float* %arrayidx20, align 4
  %16 = load i32* %i9, align 4
  %idxprom22 = sext i32 %16 to i64
  %arrayidx23 = getelementptr inbounds [10 x float]* %C, i32 0, i64 %idxprom22
  %17 = load float* %arrayidx23, align 4
  %18 = load i32* %result, align 4
  %conv24 = sitofp i32 %18 to float
  %add25 = fadd float %conv24, %17
  %conv26 = fptosi float %add25 to i32
  store i32 %conv26, i32* %result, align 4
  br label %for.inc27

for.inc27:                                        ; preds = %for.body13
  %19 = load i32* %i9, align 4
  %inc28 = add nsw i32 %19, 1
  store i32 %inc28, i32* %i9, align 4
  br label %for.cond10

for.end29:                                        ; preds = %for.cond10
  %20 = load i32* %result, align 4
  ret i32 %20
}

; CHECK:  [NSD]: Number of jitable Scops 1
