; ModuleID = 'ptr.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }

@stderr = external global %struct._IO_FILE*
@.str = private unnamed_addr constant [45 x i8] c"foo: %d,   %g,   %d,   %d,   %d,   %d,   %d\0A\00", align 1
@.str1 = private unnamed_addr constant [46 x i8] c"pack: %d,   %g,   %d,   %d,   %d,   %d,   %d\0A\00", align 1
@main.A = private unnamed_addr constant [5 x i32] [i32 1, i32 2, i32 3, i32 4, i32 5], align 16
@.str2 = private unnamed_addr constant [46 x i8] c"main: %d,   %g,   %d,   %d,   %d,   %d,   %d\0A\00", align 1

define void @foo(i32 %argc, [3 x i8*]* nocapture %argv) nounwind uwtable {
  %1 = getelementptr inbounds [3 x i8*]* %argv, i64 0, i64 0
  double %2 = load i8** %1, align 8, !tbaa !0
  %3 = getelementptr inbounds [3 x i8*]* %argv, i64 0, i64 1
  %4 = load i8** %3, align 8, !tbaa !0
  %5 = bitcast i8* %4 to i32*
  %6 = getelementptr inbounds [3 x i8*]* %argv, i64 0, i64 2
  %7 = load i8** %6, align 8, !tbaa !0
  br label %8

; <label>:8                                       ; preds = %8, %0
  %indvars.iv = phi i64 [ 0, %0 ], [ %indvars.iv.next, %8 ]
  %9 = tail call i64 @random() nounwind
  %10 = mul nsw i64 %9, %indvars.iv
  %11 = trunc i64 %10 to i32
  %12 = getelementptr inbounds i32* %5, i64 %indvars.iv
  store i32 %11, i32* %12, align 4, !tbaa !3
  %indvars.iv.next = add i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, 5
  br i1 %exitcond, label %13, label %8

; <label>:13                                      ; preds = %8
  %14 = bitcast i8* %2 to i32*
  %15 = bitcast i8* %7 to double*
  %16 = load %struct._IO_FILE** @stderr, align 8, !tbaa !0
  %17 = load i32* %14, align 4, !tbaa !3
  %18 = load double* %15, align 8, !tbaa !4
  %19 = load i32* %5, align 4, !tbaa !3
  %20 = getelementptr inbounds i8* %4, i64 4
  %21 = bitcast i8* %20 to i32*
  %22 = load i32* %21, align 4, !tbaa !3
  %23 = getelementptr inbounds i8* %4, i64 8
  %24 = bitcast i8* %23 to i32*
  %25 = load i32* %24, align 4, !tbaa !3
  %26 = getelementptr inbounds i8* %4, i64 12
  %27 = bitcast i8* %26 to i32*
  %28 = load i32* %27, align 4, !tbaa !3
  %29 = getelementptr inbounds i8* %4, i64 16
  %30 = bitcast i8* %29 to i32*
  %31 = load i32* %30, align 4, !tbaa !3
  %32 = tail call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %16, i8* getelementptr inbounds ([45 x i8]* @.str, i64 0, i64 0), i32 %17, double %18, i32 %19, i32 %22, i32 %25, i32 %28, i32 %31) nounwind
  ret void
}

declare i64 @random() nounwind

declare i32 @fprintf(%struct._IO_FILE* nocapture, i8* nocapture, ...) nounwind

define void @pack(i32 %_n, double %_m, i32* %_A) nounwind uwtable {
  %1 = alloca i32, align 4
  %2 = alloca double, align 8
  %params = alloca [3 x i8*], align 16
  store i32 %_n, i32* %1, align 4, !tbaa !3
  store double %_m, double* %2, align 8, !tbaa !4
  %3 = bitcast i32* %1 to i8*
  %4 = getelementptr inbounds [3 x i8*]* %params, i64 0, i64 0
  store i8* %3, i8** %4, align 16, !tbaa !0
  %5 = bitcast i32* %_A to i8*
  %6 = getelementptr inbounds [3 x i8*]* %params, i64 0, i64 1
  store i8* %5, i8** %6, align 8, !tbaa !0
  %7 = bitcast double* %2 to i8*
  %8 = getelementptr inbounds [3 x i8*]* %params, i64 0, i64 2
  store i8* %7, i8** %8, align 16, !tbaa !0
  %9 = load i8** %4, align 16, !tbaa !0
  %10 = bitcast i8* %9 to i32*
  %11 = load i8** %6, align 8, !tbaa !0
  %12 = bitcast i8* %11 to i32*
  %13 = load i32* %10, align 4, !tbaa !3
  %14 = load double* %2, align 8, !tbaa !4
  %15 = load %struct._IO_FILE** @stderr, align 8, !tbaa !0
  %16 = load i32* %12, align 4, !tbaa !3
  %17 = getelementptr inbounds i8* %11, i64 4
  %18 = bitcast i8* %17 to i32*
  %19 = load i32* %18, align 4, !tbaa !3
  %20 = getelementptr inbounds i8* %11, i64 8
  %21 = bitcast i8* %20 to i32*
  %22 = load i32* %21, align 4, !tbaa !3
  %23 = getelementptr inbounds i8* %11, i64 12
  %24 = bitcast i8* %23 to i32*
  %25 = load i32* %24, align 4, !tbaa !3
  %26 = getelementptr inbounds i8* %11, i64 16
  %27 = bitcast i8* %26 to i32*
  %28 = load i32* %27, align 4, !tbaa !3
  %29 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %15, i8* getelementptr inbounds ([46 x i8]* @.str1, i64 0, i64 0), i32 %13, double %14, i32 %16, i32 %19, i32 %22, i32 %25, i32 %28) nounwind
  call void @foo(i32 undef, [3 x i8*]* %params)
  ret void
}

define i32 @main(i32 %argc, i8** nocapture %argv) nounwind uwtable {
  %A = alloca [5 x i32], align 16
  %1 = bitcast [5 x i32]* %A to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %1, i8* bitcast ([5 x i32]* @main.A to i8*), i64 20, i32 16, i1 false)
  %2 = load %struct._IO_FILE** @stderr, align 8, !tbaa !0
  %3 = getelementptr inbounds [5 x i32]* %A, i64 0, i64 0
  %4 = load i32* %3, align 16, !tbaa !3
  %5 = getelementptr inbounds [5 x i32]* %A, i64 0, i64 1
  %6 = load i32* %5, align 4, !tbaa !3
  %7 = getelementptr inbounds [5 x i32]* %A, i64 0, i64 2
  %8 = load i32* %7, align 8, !tbaa !3
  %9 = getelementptr inbounds [5 x i32]* %A, i64 0, i64 3
  %10 = load i32* %9, align 4, !tbaa !3
  %11 = getelementptr inbounds [5 x i32]* %A, i64 0, i64 4
  %12 = load i32* %11, align 16, !tbaa !3
  %13 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %2, i8* getelementptr inbounds ([46 x i8]* @.str2, i64 0, i64 0), i32 5, double 1.000000e+01, i32 %4, i32 %6, i32 %8, i32 %10, i32 %12) nounwind
  call void @pack(i32 5, double 1.000000e+01, i32* %3)
  ret i32 0
}

declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture, i64, i32, i1) nounwind

!0 = metadata !{metadata !"any pointer", metadata !1}
!1 = metadata !{metadata !"omnipotent char", metadata !2}
!2 = metadata !{metadata !"Simple C/C++ TBAA"}
!3 = metadata !{metadata !"int", metadata !1}
!4 = metadata !{metadata !"double", metadata !1}
