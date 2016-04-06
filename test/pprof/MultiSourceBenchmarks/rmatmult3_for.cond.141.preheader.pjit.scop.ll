
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli -polly-only-scop-detection  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 polyjit          - Number of jitable SCoPs

; ModuleID = '/local/hdd/pjtest/pj-collect/MultiSourceBenchmarks/test-suite/MultiSource/Benchmarks/ASC_Sequoia/IRSmk/rmatmult3.c.rmatmult3_for.cond.141.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
define weak void @rmatmult3_for.cond.141.preheader.pjit.scop(i32, i1 %cmp142.540, i32, i32, i1 %cmp145.538, i32, i64, double*, double* %add.ptr39, double*, double* %add.ptr38, double*, double* %add.ptr52, double*, double* %add.ptr56, double*, double* %add.ptr, double*, double* %add.ptr63, double*, double* %add.ptr69, double*, double* %add.ptr68, double*, double* %add.ptr80, double*, double* %add.ptr84, double*, double* %add.ptr83, double*, double* %add.ptr91, double*, double* %add.ptr92, double*, double* %x, double*, double* %add.ptr93, double*, double* %add.ptr96, double*, double* %add.ptr95, double*, double* %add.ptr101, double*, double* %add.ptr107, double*, double* %add.ptr106, double*, double* %add.ptr118, double*, double* %add.ptr121, double*, double* %add.ptr103, double*, double* %add.ptr126, double*, double* %add.ptr131, double*, double* %add.ptr130, double*, double* %add.ptr140, double* %b, i32, i32, i32)  {
newFuncRoot:
  br label %for.cond.141.preheader

for.end.315.loopexit.exitStub:                    ; preds = %for.inc.313
  ret void

for.cond.141.preheader:                           ; preds = %for.inc.313, %newFuncRoot
  %kk.0544 = phi i32 [ %0, %newFuncRoot ], [ %inc314, %for.inc.313 ]
  br i1 %cmp142.540, label %for.cond.144.preheader.lr.ph, label %for.inc.313

for.cond.144.preheader.lr.ph:                     ; preds = %for.cond.141.preheader
  %mul147 = mul nsw i32 %kk.0544, %1
  br label %for.cond.144.preheader

for.cond.144.preheader:                           ; preds = %for.inc.310, %for.cond.144.preheader.lr.ph
  %jj.0541 = phi i32 [ %2, %for.cond.144.preheader.lr.ph ], [ %inc311, %for.inc.310 ]
  br i1 %cmp145.538, label %for.body.146.lr.ph, label %for.inc.310

for.body.146.lr.ph:                               ; preds = %for.cond.144.preheader
  %mul = mul nsw i32 %jj.0541, %3
  %add = add i32 %mul, %mul147
  br label %for.body.146

for.body.146:                                     ; preds = %for.body.146, %for.body.146.lr.ph
  %indvars.iv = phi i64 [ %4, %for.body.146.lr.ph ], [ %indvars.iv.next, %for.body.146 ]
  %35 = trunc i64 %indvars.iv to i32
  %add148 = add i32 %add, %35
  %idxprom = sext i32 %add148 to i64
  %arrayidx = getelementptr inbounds double, double* %5, i64 %idxprom
  %36 = load double, double* %arrayidx, align 8, !tbaa !0
  %arrayidx150 = getelementptr inbounds double, double* %add.ptr39, i64 %idxprom
  %37 = load double, double* %arrayidx150, align 8, !tbaa !0
  %mul151 = fmul double %36, %37
  %arrayidx153 = getelementptr inbounds double, double* %6, i64 %idxprom
  %38 = load double, double* %arrayidx153, align 8, !tbaa !0
  %arrayidx155 = getelementptr inbounds double, double* %add.ptr38, i64 %idxprom
  %39 = load double, double* %arrayidx155, align 8, !tbaa !0
  %mul156 = fmul double %38, %39
  %add157 = fadd double %mul151, %mul156
  %arrayidx159 = getelementptr inbounds double, double* %7, i64 %idxprom
  %40 = load double, double* %arrayidx159, align 8, !tbaa !0
  %arrayidx161 = getelementptr inbounds double, double* %add.ptr52, i64 %idxprom
  %41 = load double, double* %arrayidx161, align 8, !tbaa !0
  %mul162 = fmul double %40, %41
  %add163 = fadd double %add157, %mul162
  %arrayidx165 = getelementptr inbounds double, double* %8, i64 %idxprom
  %42 = load double, double* %arrayidx165, align 8, !tbaa !0
  %arrayidx167 = getelementptr inbounds double, double* %add.ptr56, i64 %idxprom
  %43 = load double, double* %arrayidx167, align 8, !tbaa !0
  %mul168 = fmul double %42, %43
  %add169 = fadd double %add163, %mul168
  %arrayidx171 = getelementptr inbounds double, double* %9, i64 %idxprom
  %44 = load double, double* %arrayidx171, align 8, !tbaa !0
  %arrayidx173 = getelementptr inbounds double, double* %add.ptr, i64 %idxprom
  %45 = load double, double* %arrayidx173, align 8, !tbaa !0
  %mul174 = fmul double %44, %45
  %add175 = fadd double %add169, %mul174
  %arrayidx177 = getelementptr inbounds double, double* %10, i64 %idxprom
  %46 = load double, double* %arrayidx177, align 8, !tbaa !0
  %arrayidx179 = getelementptr inbounds double, double* %add.ptr63, i64 %idxprom
  %47 = load double, double* %arrayidx179, align 8, !tbaa !0
  %mul180 = fmul double %46, %47
  %add181 = fadd double %add175, %mul180
  %arrayidx183 = getelementptr inbounds double, double* %11, i64 %idxprom
  %48 = load double, double* %arrayidx183, align 8, !tbaa !0
  %arrayidx185 = getelementptr inbounds double, double* %add.ptr69, i64 %idxprom
  %49 = load double, double* %arrayidx185, align 8, !tbaa !0
  %mul186 = fmul double %48, %49
  %add187 = fadd double %add181, %mul186
  %arrayidx189 = getelementptr inbounds double, double* %12, i64 %idxprom
  %50 = load double, double* %arrayidx189, align 8, !tbaa !0
  %arrayidx191 = getelementptr inbounds double, double* %add.ptr68, i64 %idxprom
  %51 = load double, double* %arrayidx191, align 8, !tbaa !0
  %mul192 = fmul double %50, %51
  %add193 = fadd double %add187, %mul192
  %arrayidx195 = getelementptr inbounds double, double* %13, i64 %idxprom
  %52 = load double, double* %arrayidx195, align 8, !tbaa !0
  %arrayidx197 = getelementptr inbounds double, double* %add.ptr80, i64 %idxprom
  %53 = load double, double* %arrayidx197, align 8, !tbaa !0
  %mul198 = fmul double %52, %53
  %add199 = fadd double %add193, %mul198
  %arrayidx201 = getelementptr inbounds double, double* %14, i64 %idxprom
  %54 = load double, double* %arrayidx201, align 8, !tbaa !0
  %arrayidx203 = getelementptr inbounds double, double* %add.ptr84, i64 %idxprom
  %55 = load double, double* %arrayidx203, align 8, !tbaa !0
  %mul204 = fmul double %54, %55
  %add205 = fadd double %add199, %mul204
  %arrayidx207 = getelementptr inbounds double, double* %15, i64 %idxprom
  %56 = load double, double* %arrayidx207, align 8, !tbaa !0
  %arrayidx209 = getelementptr inbounds double, double* %add.ptr83, i64 %idxprom
  %57 = load double, double* %arrayidx209, align 8, !tbaa !0
  %mul210 = fmul double %56, %57
  %add211 = fadd double %add205, %mul210
  %arrayidx213 = getelementptr inbounds double, double* %16, i64 %idxprom
  %58 = load double, double* %arrayidx213, align 8, !tbaa !0
  %arrayidx215 = getelementptr inbounds double, double* %add.ptr91, i64 %idxprom
  %59 = load double, double* %arrayidx215, align 8, !tbaa !0
  %mul216 = fmul double %58, %59
  %add217 = fadd double %add211, %mul216
  %arrayidx219 = getelementptr inbounds double, double* %17, i64 %idxprom
  %60 = load double, double* %arrayidx219, align 8, !tbaa !0
  %arrayidx221 = getelementptr inbounds double, double* %add.ptr92, i64 %idxprom
  %61 = load double, double* %arrayidx221, align 8, !tbaa !0
  %mul222 = fmul double %60, %61
  %add223 = fadd double %add217, %mul222
  %arrayidx225 = getelementptr inbounds double, double* %18, i64 %idxprom
  %62 = load double, double* %arrayidx225, align 8, !tbaa !0
  %arrayidx227 = getelementptr inbounds double, double* %x, i64 %idxprom
  %63 = load double, double* %arrayidx227, align 8, !tbaa !0
  %mul228 = fmul double %62, %63
  %add229 = fadd double %add223, %mul228
  %arrayidx231 = getelementptr inbounds double, double* %19, i64 %idxprom
  %64 = load double, double* %arrayidx231, align 8, !tbaa !0
  %arrayidx233 = getelementptr inbounds double, double* %add.ptr93, i64 %idxprom
  %65 = load double, double* %arrayidx233, align 8, !tbaa !0
  %mul234 = fmul double %64, %65
  %add235 = fadd double %add229, %mul234
  %arrayidx237 = getelementptr inbounds double, double* %20, i64 %idxprom
  %66 = load double, double* %arrayidx237, align 8, !tbaa !0
  %arrayidx239 = getelementptr inbounds double, double* %add.ptr96, i64 %idxprom
  %67 = load double, double* %arrayidx239, align 8, !tbaa !0
  %mul240 = fmul double %66, %67
  %add241 = fadd double %add235, %mul240
  %arrayidx243 = getelementptr inbounds double, double* %21, i64 %idxprom
  %68 = load double, double* %arrayidx243, align 8, !tbaa !0
  %arrayidx245 = getelementptr inbounds double, double* %add.ptr95, i64 %idxprom
  %69 = load double, double* %arrayidx245, align 8, !tbaa !0
  %mul246 = fmul double %68, %69
  %add247 = fadd double %add241, %mul246
  %arrayidx249 = getelementptr inbounds double, double* %22, i64 %idxprom
  %70 = load double, double* %arrayidx249, align 8, !tbaa !0
  %arrayidx251 = getelementptr inbounds double, double* %add.ptr101, i64 %idxprom
  %71 = load double, double* %arrayidx251, align 8, !tbaa !0
  %mul252 = fmul double %70, %71
  %add253 = fadd double %add247, %mul252
  %arrayidx255 = getelementptr inbounds double, double* %23, i64 %idxprom
  %72 = load double, double* %arrayidx255, align 8, !tbaa !0
  %arrayidx257 = getelementptr inbounds double, double* %add.ptr107, i64 %idxprom
  %73 = load double, double* %arrayidx257, align 8, !tbaa !0
  %mul258 = fmul double %72, %73
  %add259 = fadd double %add253, %mul258
  %arrayidx261 = getelementptr inbounds double, double* %24, i64 %idxprom
  %74 = load double, double* %arrayidx261, align 8, !tbaa !0
  %arrayidx263 = getelementptr inbounds double, double* %add.ptr106, i64 %idxprom
  %75 = load double, double* %arrayidx263, align 8, !tbaa !0
  %mul264 = fmul double %74, %75
  %add265 = fadd double %add259, %mul264
  %arrayidx267 = getelementptr inbounds double, double* %25, i64 %idxprom
  %76 = load double, double* %arrayidx267, align 8, !tbaa !0
  %arrayidx269 = getelementptr inbounds double, double* %add.ptr118, i64 %idxprom
  %77 = load double, double* %arrayidx269, align 8, !tbaa !0
  %mul270 = fmul double %76, %77
  %add271 = fadd double %add265, %mul270
  %arrayidx273 = getelementptr inbounds double, double* %26, i64 %idxprom
  %78 = load double, double* %arrayidx273, align 8, !tbaa !0
  %arrayidx275 = getelementptr inbounds double, double* %add.ptr121, i64 %idxprom
  %79 = load double, double* %arrayidx275, align 8, !tbaa !0
  %mul276 = fmul double %78, %79
  %add277 = fadd double %add271, %mul276
  %arrayidx279 = getelementptr inbounds double, double* %27, i64 %idxprom
  %80 = load double, double* %arrayidx279, align 8, !tbaa !0
  %arrayidx281 = getelementptr inbounds double, double* %add.ptr103, i64 %idxprom
  %81 = load double, double* %arrayidx281, align 8, !tbaa !0
  %mul282 = fmul double %80, %81
  %add283 = fadd double %add277, %mul282
  %arrayidx285 = getelementptr inbounds double, double* %28, i64 %idxprom
  %82 = load double, double* %arrayidx285, align 8, !tbaa !0
  %arrayidx287 = getelementptr inbounds double, double* %add.ptr126, i64 %idxprom
  %83 = load double, double* %arrayidx287, align 8, !tbaa !0
  %mul288 = fmul double %82, %83
  %add289 = fadd double %add283, %mul288
  %arrayidx291 = getelementptr inbounds double, double* %29, i64 %idxprom
  %84 = load double, double* %arrayidx291, align 8, !tbaa !0
  %arrayidx293 = getelementptr inbounds double, double* %add.ptr131, i64 %idxprom
  %85 = load double, double* %arrayidx293, align 8, !tbaa !0
  %mul294 = fmul double %84, %85
  %add295 = fadd double %add289, %mul294
  %arrayidx297 = getelementptr inbounds double, double* %30, i64 %idxprom
  %86 = load double, double* %arrayidx297, align 8, !tbaa !0
  %arrayidx299 = getelementptr inbounds double, double* %add.ptr130, i64 %idxprom
  %87 = load double, double* %arrayidx299, align 8, !tbaa !0
  %mul300 = fmul double %86, %87
  %add301 = fadd double %add295, %mul300
  %arrayidx303 = getelementptr inbounds double, double* %31, i64 %idxprom
  %88 = load double, double* %arrayidx303, align 8, !tbaa !0
  %arrayidx305 = getelementptr inbounds double, double* %add.ptr140, i64 %idxprom
  %89 = load double, double* %arrayidx305, align 8, !tbaa !0
  %mul306 = fmul double %88, %89
  %add307 = fadd double %add301, %mul306
  %arrayidx309 = getelementptr inbounds double, double* %b, i64 %idxprom
  store double %add307, double* %arrayidx309, align 8, !tbaa !0
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %32
  br i1 %exitcond, label %for.inc.310.loopexit, label %for.body.146

for.inc.310.loopexit:                             ; preds = %for.body.146
  br label %for.inc.310

for.inc.310:                                      ; preds = %for.inc.310.loopexit, %for.cond.144.preheader
  %inc311 = add nsw i32 %jj.0541, 1
  %exitcond546 = icmp eq i32 %inc311, %33
  br i1 %exitcond546, label %for.inc.313.loopexit, label %for.cond.144.preheader

for.inc.313.loopexit:                             ; preds = %for.inc.310
  br label %for.inc.313

for.inc.313:                                      ; preds = %for.inc.313.loopexit, %for.cond.141.preheader
  %inc314 = add nsw i32 %kk.0544, 1
  %exitcond547 = icmp eq i32 %inc314, %34
  br i1 %exitcond547, label %for.end.315.loopexit.exitStub, label %for.cond.141.preheader
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
