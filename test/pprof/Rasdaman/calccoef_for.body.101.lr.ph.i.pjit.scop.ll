
; RUN: opt -load LLVMPolyJIT.so -O3  -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = 'gdal_crs.c.calccoef_for.body.101.lr.ph.i.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @calccoef_for.body.101.lr.ph.i.pjit.scop(i32, i64, double*, i32)  {
newFuncRoot:
  br label %for.body.101.lr.ph.i

for.end.123.i.loopexit.exitStub:                  ; preds = %for.inc.121.i
  ret void

for.body.101.lr.ph.i:                             ; preds = %for.inc.121.i, %newFuncRoot
  %indvars.iv117 = phi i32 [ %indvars.iv.next118, %for.inc.121.i ], [ 2, %newFuncRoot ]
  %add105.i = add nsw i32 %indvars.iv117, -1
  %mul112.i = mul nsw i32 %add105.i, %0
  br label %for.body.101.i

for.body.101.i:                                   ; preds = %for.body.101.i, %for.body.101.lr.ph.i
  %indvars.iv.i.101 = phi i64 [ 1, %for.body.101.lr.ph.i ], [ %indvars.iv.next.i.102, %for.body.101.i ]
  %4 = add nsw i64 %indvars.iv.i.101, -1
  %5 = mul nsw i64 %4, %1
  %6 = trunc i64 %5 to i32
  %sub106.i = add i32 %6, %add105.i
  %idxprom107.i = sext i32 %sub106.i to i64
  %arrayidx109.i = getelementptr inbounds double, double* %2, i64 %idxprom107.i
  %7 = bitcast double* %arrayidx109.i to i64*
  %8 = load i64, i64* %7, align 8, !tbaa !0
  %9 = add nuw nsw i64 %indvars.iv.i.101, 4294967295
  %10 = trunc i64 %9 to i32
  %sub114.i = add i32 %10, %mul112.i
  %idxprom115.i = sext i32 %sub114.i to i64
  %arrayidx117.i = getelementptr inbounds double, double* %2, i64 %idxprom115.i
  %11 = bitcast double* %arrayidx117.i to i64*
  store i64 %8, i64* %11, align 8, !tbaa !0
  %indvars.iv.next.i.102 = add nuw nsw i64 %indvars.iv.i.101, 1
  %lftr.wideiv119 = trunc i64 %indvars.iv.next.i.102 to i32
  %exitcond120 = icmp eq i32 %lftr.wideiv119, %indvars.iv117
  br i1 %exitcond120, label %for.inc.121.i, label %for.body.101.i

for.inc.121.i:                                    ; preds = %for.body.101.i
  %indvars.iv.next118 = add nuw nsw i32 %indvars.iv117, 1
  %exitcond110 = icmp eq i32 %indvars.iv117, %3
  br i1 %exitcond110, label %for.end.123.i.loopexit.exitStub, label %for.body.101.lr.ph.i
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
