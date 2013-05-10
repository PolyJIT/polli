; ModuleID = 'scevtest.s'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1

define i32 @main() nounwind uwtable {
  %A = alloca [1024 x i32], align 16
  br label %.split

.split:                                           ; preds = %0
  %1 = call i32 @rand() nounwind
  br label %3

.preheader4:                                      ; preds = %3
  %2 = srem i32 %1, 100
  br label %11

; <label>:3                                       ; preds = %3, %.split
  %indvars.iv15 = phi i64 [ 0, %.split ], [ %indvars.iv.next16, %3 ]
  %4 = shl nsw i64 %indvars.iv15, 1
  %5 = trunc i64 %indvars.iv15 to i32
  %6 = mul nsw i32 %5, %5
  %7 = sext i32 %6 to i64
  %8 = getelementptr inbounds [1024 x i32]* %A, i64 0, i64 %7
  %9 = trunc i64 %4 to i32
  store i32 %9, i32* %8, align 4
  %indvars.iv.next16 = add i64 %indvars.iv15, 1
  %lftr.wideiv17 = trunc i64 %indvars.iv.next16 to i32
  %exitcond18 = icmp eq i32 %lftr.wideiv17, 11
  br i1 %exitcond18, label %.preheader4, label %3

.preheader2:                                      ; preds = %11
  %10 = sext i32 %2 to i64
  br label %18

; <label>:11                                      ; preds = %11, %.preheader4
  %indvars.iv11 = phi i64 [ 0, %.preheader4 ], [ %indvars.iv.next12, %11 ]
  %12 = shl nsw i64 %indvars.iv11, 1
  %13 = trunc i64 %indvars.iv11 to i32
  %14 = mul nsw i32 %2, %13
  %15 = sext i32 %14 to i64
  %16 = getelementptr inbounds [1024 x i32]* %A, i64 0, i64 %15
  %17 = trunc i64 %12 to i32
  store i32 %17, i32* %16, align 4
  %indvars.iv.next12 = add i64 %indvars.iv11, 1
  %lftr.wideiv13 = trunc i64 %indvars.iv.next12 to i32
  %exitcond14 = icmp eq i32 %lftr.wideiv13, 11
  br i1 %exitcond14, label %.preheader2, label %11

.preheader:                                       ; preds = %18
  br label %23

; <label>:18                                      ; preds = %18, %.preheader2
  %indvars.iv7 = phi i64 [ 0, %.preheader2 ], [ %indvars.iv.next8, %18 ]
  %19 = shl nsw i64 %indvars.iv7, 1
  %20 = add nsw i64 %10, %indvars.iv7
  %21 = getelementptr inbounds [1024 x i32]* %A, i64 0, i64 %20
  %22 = trunc i64 %19 to i32
  store i32 %22, i32* %21, align 4
  %indvars.iv.next8 = add i64 %indvars.iv7, 1
  %lftr.wideiv9 = trunc i64 %indvars.iv.next8 to i32
  %exitcond10 = icmp eq i32 %lftr.wideiv9, 11
  br i1 %exitcond10, label %.preheader, label %18

; <label>:23                                      ; preds = %23, %.preheader
  %indvars.iv = phi i64 [ 0, %.preheader ], [ %indvars.iv.next, %23 ]
  %24 = trunc i64 %indvars.iv to i32
  %25 = mul nsw i32 %24, %24
  %26 = sext i32 %25 to i64
  %27 = getelementptr inbounds [1024 x i32]* %A, i64 0, i64 %26
  %28 = load i32* %27, align 4
  %29 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([3 x i8]* @.str, i64 0, i64 0), i32 %28)
  %indvars.iv.next = add i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, 11
  br i1 %exitcond, label %30, label %23

; <label>:30                                      ; preds = %23
  %31 = getelementptr inbounds [1024 x i32]* %A, i64 0, i64 2
  %32 = load i32* %31, align 8
  ret i32 %32
}

declare i32 @rand() nounwind

declare i32 @printf(i8* nocapture, ...) nounwind
