; RUN: %polliBinDir/polli < %s | FileCheck %s

; ModuleID = 'simple_invalid_scop.ll'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

define i32 @main(i32 %argc, i8** %argv) nounwind uwtable {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8**, align 8
  %A = alloca [128 x i32], align 16
  %i = alloca i32, align 4
  store i32 0, i32* %1
  store i32 %argc, i32* %2, align 4
  store i8** %argv, i8*** %3, align 8
  store i32 0, i32* %i, align 4
  br label %4

; <label>:4                                       ; preds = %16, %0
  %5 = load i32* %i, align 4
  %6 = icmp slt i32 %5, 32
  br i1 %6, label %7, label %19

; <label>:7                                       ; preds = %4
  %8 = call i32 @rand() nounwind
  %9 = srem i32 %8, 1024
  %10 = sext i32 %9 to i64
  %11 = getelementptr inbounds [128 x i32]* %A, i32 0, i64 %10
  %12 = load i32* %11, align 4
  %13 = load i32* %i, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds [128 x i32]* %A, i32 0, i64 %14
  store i32 %12, i32* %15, align 4
  br label %16

; <label>:16                                      ; preds = %7
  %17 = load i32* %i, align 4
  %18 = add nsw i32 %17, 1
  store i32 %18, i32* %i, align 4
  br label %4

; <label>:19                                      ; preds = %4
  %20 = load i32* %1
  ret i32 %20
}

declare i32 @rand() nounwind

; CHECK:  [polli] preoptimizing: main
; CHECK:  [polli] finding SCoPs in main
; CHECK:  [polli] rejected region: %1 => %10
