
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polli-process-unprofitable -polly-process-unprofitable -polly-only-scop-detection -polly-delinearize=false - -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = 'l1bdataset.cpp._ZL11L1BInterpolPdiiii_entry.split.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @_ZL11L1BInterpolPdiiii_entry.split.pjit.scop([5 x double]* %x, [5 x double]* %y, i32 %knownStep, i32 %knownFirst, double* %vals, i32 %numKnown, i32 %numPoints, i8** %.out, i8** %.out1, i32* %mul38.out, i32* %add39.out)  {
newFuncRoot:
  br label %entry.split

for.cond.52.preheader.exitStub:                   ; preds = %for.cond.52.preheader.loopexit, %for.cond.17.preheader
  store i8* %0, i8** %.out
  store i8* %1, i8** %.out1
  store i32 %mul38, i32* %mul38.out
  store i32 %add39, i32* %add39.out
  ret void

entry.split:                                      ; preds = %newFuncRoot
  %0 = bitcast [5 x double]* %x to i8*
  call void @llvm.lifetime.start(i64 40, i8* %0) #2
  %1 = bitcast [5 x double]* %y to i8*
  call void @llvm.lifetime.start(i64 40, i8* %1) #2
  %2 = sext i32 %knownStep to i64
  %3 = sext i32 %knownFirst to i64
  %conv = sitofp i32 %knownFirst to double
  %arrayidx = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 0
  store double %conv, double* %arrayidx, align 16, !tbaa !0
  %arrayidx4 = getelementptr inbounds double, double* %vals, i64 %3
  %4 = bitcast double* %arrayidx4 to i64*
  %5 = load i64, i64* %4, align 8, !tbaa !0
  %6 = bitcast [5 x double]* %y to i64*
  store i64 %5, i64* %6, align 16, !tbaa !0
  %7 = add nsw i64 %2, %3
  %8 = trunc i64 %7 to i32
  %conv.1 = sitofp i32 %8 to double
  %arrayidx.1 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 1
  store double %conv.1, double* %arrayidx.1, align 8, !tbaa !0
  %arrayidx4.1 = getelementptr inbounds double, double* %vals, i64 %7
  %9 = bitcast double* %arrayidx4.1 to i64*
  %10 = load i64, i64* %9, align 8, !tbaa !0
  %arrayidx6.1 = getelementptr inbounds [5 x double], [5 x double]* %y, i64 0, i64 1
  %11 = bitcast double* %arrayidx6.1 to i64*
  store i64 %10, i64* %11, align 8, !tbaa !0
  %12 = shl nsw i64 %2, 1
  %13 = add nsw i64 %12, %3
  %14 = trunc i64 %13 to i32
  %conv.2 = sitofp i32 %14 to double
  %arrayidx.2 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 2
  store double %conv.2, double* %arrayidx.2, align 16, !tbaa !0
  %arrayidx4.2 = getelementptr inbounds double, double* %vals, i64 %13
  %15 = bitcast double* %arrayidx4.2 to i64*
  %16 = load i64, i64* %15, align 8, !tbaa !0
  %arrayidx6.2 = getelementptr inbounds [5 x double], [5 x double]* %y, i64 0, i64 2
  %17 = bitcast double* %arrayidx6.2 to i64*
  store i64 %16, i64* %17, align 16, !tbaa !0
  %18 = mul nsw i64 %2, 3
  %19 = add nsw i64 %18, %3
  %20 = trunc i64 %19 to i32
  %conv.3 = sitofp i32 %20 to double
  %arrayidx.3 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 3
  store double %conv.3, double* %arrayidx.3, align 8, !tbaa !0
  %arrayidx4.3 = getelementptr inbounds double, double* %vals, i64 %19
  %21 = bitcast double* %arrayidx4.3 to i64*
  %22 = load i64, i64* %21, align 8, !tbaa !0
  %arrayidx6.3 = getelementptr inbounds [5 x double], [5 x double]* %y, i64 0, i64 3
  %23 = bitcast double* %arrayidx6.3 to i64*
  store i64 %22, i64* %23, align 8, !tbaa !0
  %24 = shl nsw i64 %2, 2
  %25 = add nsw i64 %24, %3
  %26 = trunc i64 %25 to i32
  %conv.4 = sitofp i32 %26 to double
  %arrayidx.4 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 4
  store double %conv.4, double* %arrayidx.4, align 16, !tbaa !0
  %arrayidx4.4 = getelementptr inbounds double, double* %vals, i64 %25
  %27 = bitcast double* %arrayidx4.4 to i64*
  %28 = load i64, i64* %27, align 8, !tbaa !0
  %arrayidx6.4 = getelementptr inbounds [5 x double], [5 x double]* %y, i64 0, i64 4
  %29 = bitcast double* %arrayidx6.4 to i64*
  store i64 %28, i64* %29, align 16, !tbaa !0
  %cmp8.217 = icmp sgt i32 %knownFirst, 0
  br i1 %cmp8.217, label %for.body.9.preheader, label %for.cond.17.preheader

for.body.9.preheader:                             ; preds = %entry.split
  br label %for.body.9

for.body.9:                                       ; preds = %_ZL16LagrangeInterpolPKdS0_di.exit, %for.body.9.preheader
  %indvars.iv240 = phi i64 [ %indvars.iv.next241, %_ZL16LagrangeInterpolPKdS0_di.exit ], [ 0, %for.body.9.preheader ]
  %30 = trunc i64 %indvars.iv240 to i32
  %conv11 = sitofp i32 %30 to double
  br label %for.cond.1.preheader.i

for.cond.1.preheader.i:                           ; preds = %for.inc.i.4, %for.body.9
  %indvars.iv40.i = phi i64 [ 0, %for.body.9 ], [ %indvars.iv.next41.i, %for.inc.i.4 ]
  %y0.038.i = phi double [ 0.000000e+00, %for.body.9 ], [ %add.i, %for.inc.i.4 ]
  %arrayidx6.i = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 %indvars.iv40.i
  %cmp4.i = icmp eq i64 %indvars.iv40.i, 0
  br i1 %cmp4.i, label %for.inc.i, label %if.end.i

for.inc.i:                                        ; preds = %if.end.i, %for.cond.1.preheader.i
  %L.1.i = phi double [ 1.000000e+00, %for.cond.1.preheader.i ], [ %div.i, %if.end.i ]
  %cmp4.i.1 = icmp eq i64 %indvars.iv40.i, 1
  br i1 %cmp4.i.1, label %for.inc.i.1, label %if.end.i.1

for.inc.i.1:                                      ; preds = %if.end.i.1, %for.inc.i
  %L.1.i.1 = phi double [ %L.1.i, %for.inc.i ], [ %div.i.1, %if.end.i.1 ]
  %cmp4.i.2 = icmp eq i64 %indvars.iv40.i, 2
  br i1 %cmp4.i.2, label %for.inc.i.2, label %if.end.i.2

for.inc.i.2:                                      ; preds = %if.end.i.2, %for.inc.i.1
  %L.1.i.2 = phi double [ %L.1.i.1, %for.inc.i.1 ], [ %div.i.2, %if.end.i.2 ]
  %cmp4.i.3 = icmp eq i64 %indvars.iv40.i, 3
  br i1 %cmp4.i.3, label %for.inc.i.3, label %if.end.i.3

for.inc.i.3:                                      ; preds = %if.end.i.3, %for.inc.i.2
  %L.1.i.3 = phi double [ %L.1.i.2, %for.inc.i.2 ], [ %div.i.3, %if.end.i.3 ]
  %cmp4.i.4 = icmp eq i64 %indvars.iv40.i, 4
  br i1 %cmp4.i.4, label %for.inc.i.4, label %if.end.i.4

for.inc.i.4:                                      ; preds = %if.end.i.4, %for.inc.i.3
  %L.1.i.4 = phi double [ %L.1.i.3, %for.inc.i.3 ], [ %div.i.4, %if.end.i.4 ]
  %arrayidx11.i = getelementptr inbounds [5 x double], [5 x double]* %y, i64 0, i64 %indvars.iv40.i
  %31 = load double, double* %arrayidx11.i, align 8, !tbaa !0
  %mul12.i = fmul double %L.1.i.4, %31
  %add.i = fadd double %y0.038.i, %mul12.i
  %indvars.iv.next41.i = add nuw nsw i64 %indvars.iv40.i, 1
  %exitcond239 = icmp eq i64 %indvars.iv.next41.i, 5
  br i1 %exitcond239, label %_ZL16LagrangeInterpolPKdS0_di.exit, label %for.cond.1.preheader.i

_ZL16LagrangeInterpolPKdS0_di.exit:               ; preds = %for.inc.i.4
  %add.i.lcssa = phi double [ %add.i, %for.inc.i.4 ]
  %arrayidx13 = getelementptr inbounds double, double* %vals, i64 %indvars.iv240
  store double %add.i.lcssa, double* %arrayidx13, align 8, !tbaa !0
  %indvars.iv.next241 = add nuw nsw i64 %indvars.iv240, 1
  %lftr.wideiv249 = trunc i64 %indvars.iv.next241 to i32
  %exitcond = icmp eq i32 %lftr.wideiv249, %knownFirst
  br i1 %exitcond, label %for.cond.17.preheader.loopexit, label %for.body.9

for.cond.17.preheader.loopexit:                   ; preds = %_ZL16LagrangeInterpolPKdS0_di.exit
  br label %for.cond.17.preheader

for.cond.17.preheader:                            ; preds = %for.cond.17.preheader.loopexit, %entry.split
  %sub = add nsw i32 %numKnown, -5
  %32 = sext i32 %sub to i64
  %33 = sext i32 %knownStep to i64
  %34 = sext i32 %knownFirst to i64
  %35 = mul nsw i64 %33, %32
  %36 = add nsw i64 %35, %34
  %37 = trunc i64 %36 to i32
  %conv23 = sitofp i32 %37 to double
  %arrayidx25 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 0
  store double %conv23, double* %arrayidx25, align 16, !tbaa !0
  %arrayidx31 = getelementptr inbounds double, double* %vals, i64 %36
  %38 = bitcast double* %arrayidx31 to i64*
  %39 = load i64, i64* %38, align 8, !tbaa !0
  %40 = bitcast [5 x double]* %y to i64*
  store i64 %39, i64* %40, align 16, !tbaa !0
  %41 = add nsw i64 %32, 1
  %42 = mul nsw i64 %41, %33
  %43 = add nsw i64 %42, %34
  %44 = trunc i64 %43 to i32
  %conv23.1 = sitofp i32 %44 to double
  %arrayidx25.1 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 1
  store double %conv23.1, double* %arrayidx25.1, align 8, !tbaa !0
  %arrayidx31.1 = getelementptr inbounds double, double* %vals, i64 %43
  %45 = bitcast double* %arrayidx31.1 to i64*
  %46 = load i64, i64* %45, align 8, !tbaa !0
  %arrayidx33.1 = getelementptr inbounds [5 x double], [5 x double]* %y, i64 0, i64 1
  %47 = bitcast double* %arrayidx33.1 to i64*
  store i64 %46, i64* %47, align 8, !tbaa !0
  %48 = add nsw i64 %32, 2
  %49 = mul nsw i64 %48, %33
  %50 = add nsw i64 %49, %34
  %51 = trunc i64 %50 to i32
  %conv23.2 = sitofp i32 %51 to double
  %arrayidx25.2 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 2
  store double %conv23.2, double* %arrayidx25.2, align 16, !tbaa !0
  %arrayidx31.2 = getelementptr inbounds double, double* %vals, i64 %50
  %52 = bitcast double* %arrayidx31.2 to i64*
  %53 = load i64, i64* %52, align 8, !tbaa !0
  %arrayidx33.2 = getelementptr inbounds [5 x double], [5 x double]* %y, i64 0, i64 2
  %54 = bitcast double* %arrayidx33.2 to i64*
  store i64 %53, i64* %54, align 16, !tbaa !0
  %55 = add nsw i64 %32, 3
  %56 = mul nsw i64 %55, %33
  %57 = add nsw i64 %56, %34
  %58 = trunc i64 %57 to i32
  %conv23.3 = sitofp i32 %58 to double
  %arrayidx25.3 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 3
  store double %conv23.3, double* %arrayidx25.3, align 8, !tbaa !0
  %arrayidx31.3 = getelementptr inbounds double, double* %vals, i64 %57
  %59 = bitcast double* %arrayidx31.3 to i64*
  %60 = load i64, i64* %59, align 8, !tbaa !0
  %arrayidx33.3 = getelementptr inbounds [5 x double], [5 x double]* %y, i64 0, i64 3
  %61 = bitcast double* %arrayidx33.3 to i64*
  store i64 %60, i64* %61, align 8, !tbaa !0
  %62 = add nsw i64 %32, 4
  %63 = mul nsw i64 %62, %33
  %64 = add nsw i64 %63, %34
  %65 = trunc i64 %64 to i32
  %conv23.4 = sitofp i32 %65 to double
  %arrayidx25.4 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 4
  store double %conv23.4, double* %arrayidx25.4, align 16, !tbaa !0
  %arrayidx31.4 = getelementptr inbounds double, double* %vals, i64 %64
  %66 = bitcast double* %arrayidx31.4 to i64*
  %67 = load i64, i64* %66, align 8, !tbaa !0
  %arrayidx33.4 = getelementptr inbounds [5 x double], [5 x double]* %y, i64 0, i64 4
  %68 = bitcast double* %arrayidx33.4 to i64*
  store i64 %67, i64* %68, align 16, !tbaa !0
  %sub37 = add nsw i32 %numKnown, -1
  %mul38 = mul nsw i32 %sub37, %knownStep
  %add39 = add nsw i32 %mul38, %knownFirst
  %cmp41.214 = icmp slt i32 %add39, %numPoints
  br i1 %cmp41.214, label %for.body.42.preheader, label %for.cond.52.preheader.exitStub

for.body.42.preheader:                            ; preds = %for.cond.17.preheader
  %69 = add i32 %numKnown, -1
  %70 = mul i32 %69, %knownStep
  %71 = add i32 %70, %knownFirst
  %72 = sext i32 %71 to i64
  br label %for.body.42

for.body.42:                                      ; preds = %_ZL16LagrangeInterpolPKdS0_di.exit210, %for.body.42.preheader
  %indvars.iv229 = phi i64 [ %72, %for.body.42.preheader ], [ %indvars.iv.next230, %_ZL16LagrangeInterpolPKdS0_di.exit210 ]
  %73 = trunc i64 %indvars.iv229 to i32
  %conv45 = sitofp i32 %73 to double
  br label %for.cond.1.preheader.i.186

for.cond.1.preheader.i.186:                       ; preds = %for.inc.i.202.4, %for.body.42
  %indvars.iv40.i.184 = phi i64 [ 0, %for.body.42 ], [ %indvars.iv.next41.i.207, %for.inc.i.202.4 ]
  %y0.038.i.185 = phi double [ 0.000000e+00, %for.body.42 ], [ %add.i.206, %for.inc.i.202.4 ]
  %arrayidx6.i.187 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 %indvars.iv40.i.184
  %cmp4.i.190 = icmp eq i64 %indvars.iv40.i.184, 0
  br i1 %cmp4.i.190, label %for.inc.i.202, label %if.end.i.197

for.inc.i.202:                                    ; preds = %if.end.i.197, %for.cond.1.preheader.i.186
  %L.1.i.198 = phi double [ 1.000000e+00, %for.cond.1.preheader.i.186 ], [ %div.i.196, %if.end.i.197 ]
  %cmp4.i.190.1 = icmp eq i64 %indvars.iv40.i.184, 1
  br i1 %cmp4.i.190.1, label %for.inc.i.202.1, label %if.end.i.197.1

for.inc.i.202.1:                                  ; preds = %if.end.i.197.1, %for.inc.i.202
  %L.1.i.198.1 = phi double [ %L.1.i.198, %for.inc.i.202 ], [ %div.i.196.1, %if.end.i.197.1 ]
  %cmp4.i.190.2 = icmp eq i64 %indvars.iv40.i.184, 2
  br i1 %cmp4.i.190.2, label %for.inc.i.202.2, label %if.end.i.197.2

for.inc.i.202.2:                                  ; preds = %if.end.i.197.2, %for.inc.i.202.1
  %L.1.i.198.2 = phi double [ %L.1.i.198.1, %for.inc.i.202.1 ], [ %div.i.196.2, %if.end.i.197.2 ]
  %cmp4.i.190.3 = icmp eq i64 %indvars.iv40.i.184, 3
  br i1 %cmp4.i.190.3, label %for.inc.i.202.3, label %if.end.i.197.3

for.inc.i.202.3:                                  ; preds = %if.end.i.197.3, %for.inc.i.202.2
  %L.1.i.198.3 = phi double [ %L.1.i.198.2, %for.inc.i.202.2 ], [ %div.i.196.3, %if.end.i.197.3 ]
  %cmp4.i.190.4 = icmp eq i64 %indvars.iv40.i.184, 4
  br i1 %cmp4.i.190.4, label %for.inc.i.202.4, label %if.end.i.197.4

for.inc.i.202.4:                                  ; preds = %if.end.i.197.4, %for.inc.i.202.3
  %L.1.i.198.4 = phi double [ %L.1.i.198.3, %for.inc.i.202.3 ], [ %div.i.196.4, %if.end.i.197.4 ]
  %arrayidx11.i.204 = getelementptr inbounds [5 x double], [5 x double]* %y, i64 0, i64 %indvars.iv40.i.184
  %74 = load double, double* %arrayidx11.i.204, align 8, !tbaa !0
  %mul12.i.205 = fmul double %L.1.i.198.4, %74
  %add.i.206 = fadd double %y0.038.i.185, %mul12.i.205
  %indvars.iv.next41.i.207 = add nuw nsw i64 %indvars.iv40.i.184, 1
  %exitcond228 = icmp eq i64 %indvars.iv.next41.i.207, 5
  br i1 %exitcond228, label %_ZL16LagrangeInterpolPKdS0_di.exit210, label %for.cond.1.preheader.i.186

_ZL16LagrangeInterpolPKdS0_di.exit210:            ; preds = %for.inc.i.202.4
  %add.i.206.lcssa = phi double [ %add.i.206, %for.inc.i.202.4 ]
  %arrayidx48 = getelementptr inbounds double, double* %vals, i64 %indvars.iv229
  store double %add.i.206.lcssa, double* %arrayidx48, align 8, !tbaa !0
  %indvars.iv.next230 = add nsw i64 %indvars.iv229, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next230 to i32
  %exitcond231 = icmp eq i32 %lftr.wideiv, %numPoints
  br i1 %exitcond231, label %for.cond.52.preheader.loopexit, label %for.body.42

for.cond.52.preheader.loopexit:                   ; preds = %_ZL16LagrangeInterpolPKdS0_di.exit210
  br label %for.cond.52.preheader.exitStub

if.end.i.197.4:                                   ; preds = %for.inc.i.202.3
  %arrayidx.i.192.4 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 4
  %75 = load double, double* %arrayidx.i.192.4, align 16, !tbaa !0
  %sub.i.193.4 = fsub double %conv45, %75
  %mul.i.194.4 = fmul double %L.1.i.198.3, %sub.i.193.4
  %76 = load double, double* %arrayidx6.i.187, align 8, !tbaa !0
  %sub9.i.195.4 = fsub double %76, %75
  %div.i.196.4 = fdiv double %mul.i.194.4, %sub9.i.195.4
  br label %for.inc.i.202.4

if.end.i.197.3:                                   ; preds = %for.inc.i.202.2
  %arrayidx.i.192.3 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 3
  %77 = load double, double* %arrayidx.i.192.3, align 8, !tbaa !0
  %sub.i.193.3 = fsub double %conv45, %77
  %mul.i.194.3 = fmul double %L.1.i.198.2, %sub.i.193.3
  %78 = load double, double* %arrayidx6.i.187, align 8, !tbaa !0
  %sub9.i.195.3 = fsub double %78, %77
  %div.i.196.3 = fdiv double %mul.i.194.3, %sub9.i.195.3
  br label %for.inc.i.202.3

if.end.i.197.2:                                   ; preds = %for.inc.i.202.1
  %arrayidx.i.192.2 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 2
  %79 = load double, double* %arrayidx.i.192.2, align 16, !tbaa !0
  %sub.i.193.2 = fsub double %conv45, %79
  %mul.i.194.2 = fmul double %L.1.i.198.1, %sub.i.193.2
  %80 = load double, double* %arrayidx6.i.187, align 8, !tbaa !0
  %sub9.i.195.2 = fsub double %80, %79
  %div.i.196.2 = fdiv double %mul.i.194.2, %sub9.i.195.2
  br label %for.inc.i.202.2

if.end.i.197.1:                                   ; preds = %for.inc.i.202
  %arrayidx.i.192.1 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 1
  %81 = load double, double* %arrayidx.i.192.1, align 8, !tbaa !0
  %sub.i.193.1 = fsub double %conv45, %81
  %mul.i.194.1 = fmul double %L.1.i.198, %sub.i.193.1
  %82 = load double, double* %arrayidx6.i.187, align 8, !tbaa !0
  %sub9.i.195.1 = fsub double %82, %81
  %div.i.196.1 = fdiv double %mul.i.194.1, %sub9.i.195.1
  br label %for.inc.i.202.1

if.end.i.197:                                     ; preds = %for.cond.1.preheader.i.186
  %arrayidx.i.192 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 0
  %83 = load double, double* %arrayidx.i.192, align 16, !tbaa !0
  %sub.i.193 = fsub double %conv45, %83
  %84 = load double, double* %arrayidx6.i.187, align 8, !tbaa !0
  %sub9.i.195 = fsub double %84, %83
  %div.i.196 = fdiv double %sub.i.193, %sub9.i.195
  br label %for.inc.i.202

if.end.i.4:                                       ; preds = %for.inc.i.3
  %arrayidx.i.4 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 4
  %85 = load double, double* %arrayidx.i.4, align 16, !tbaa !0
  %sub.i.4 = fsub double %conv11, %85
  %mul.i.4 = fmul double %L.1.i.3, %sub.i.4
  %86 = load double, double* %arrayidx6.i, align 8, !tbaa !0
  %sub9.i.4 = fsub double %86, %85
  %div.i.4 = fdiv double %mul.i.4, %sub9.i.4
  br label %for.inc.i.4

if.end.i.3:                                       ; preds = %for.inc.i.2
  %arrayidx.i.3 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 3
  %87 = load double, double* %arrayidx.i.3, align 8, !tbaa !0
  %sub.i.3 = fsub double %conv11, %87
  %mul.i.3 = fmul double %L.1.i.2, %sub.i.3
  %88 = load double, double* %arrayidx6.i, align 8, !tbaa !0
  %sub9.i.3 = fsub double %88, %87
  %div.i.3 = fdiv double %mul.i.3, %sub9.i.3
  br label %for.inc.i.3

if.end.i.2:                                       ; preds = %for.inc.i.1
  %arrayidx.i.2 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 2
  %89 = load double, double* %arrayidx.i.2, align 16, !tbaa !0
  %sub.i.2 = fsub double %conv11, %89
  %mul.i.2 = fmul double %L.1.i.1, %sub.i.2
  %90 = load double, double* %arrayidx6.i, align 8, !tbaa !0
  %sub9.i.2 = fsub double %90, %89
  %div.i.2 = fdiv double %mul.i.2, %sub9.i.2
  br label %for.inc.i.2

if.end.i.1:                                       ; preds = %for.inc.i
  %arrayidx.i.1 = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 1
  %91 = load double, double* %arrayidx.i.1, align 8, !tbaa !0
  %sub.i.1 = fsub double %conv11, %91
  %mul.i.1 = fmul double %L.1.i, %sub.i.1
  %92 = load double, double* %arrayidx6.i, align 8, !tbaa !0
  %sub9.i.1 = fsub double %92, %91
  %div.i.1 = fdiv double %mul.i.1, %sub9.i.1
  br label %for.inc.i.1

if.end.i:                                         ; preds = %for.cond.1.preheader.i
  %arrayidx.i = getelementptr inbounds [5 x double], [5 x double]* %x, i64 0, i64 0
  %93 = load double, double* %arrayidx.i, align 16, !tbaa !0
  %sub.i = fsub double %conv11, %93
  %94 = load double, double* %arrayidx6.i, align 8, !tbaa !0
  %sub9.i = fsub double %94, %93
  %div.i = fdiv double %sub.i, %sub9.i
  br label %for.inc.i
}

; Function Attrs: nounwind argmemonly
declare void @llvm.lifetime.start(i64, i8* nocapture) #1

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }
attributes #1 = { nounwind argmemonly }
attributes #2 = { nounwind }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
