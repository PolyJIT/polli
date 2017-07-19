
; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:

; ModuleID = '/local/hdd/pjtest/pj-collect/SPEC2006/speccpu2006/benchspec/CPU2006/400.perlbench/src/regcomp.c.S_cl_and_if.then.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.regnode_charclass_class = type { i8, i8, i16, i32, [32 x i8], [4 x i8] }

; Function Attrs: nounwind
define weak void @S_cl_and_if.then.pjit.scop(i32 %conv, %struct.regnode_charclass_class* %and_with, %struct.regnode_charclass_class* %cl)  {
newFuncRoot:
  br label %if.then

if.end.54.exitStub:                               ; preds = %if.end.54.loopexit165, %if.end.54.loopexit
  ret void

if.then:                                          ; preds = %newFuncRoot
  %and25 = and i32 %conv, 4
  %tobool26 = icmp eq i32 %and25, 0
  br i1 %tobool26, label %for.body.40.preheader, label %for.body.preheader

for.body.40.preheader:                            ; preds = %if.then
  br label %for.body.40

for.body.40:                                      ; preds = %for.body.40, %for.body.40.preheader
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body.40 ], [ 0, %for.body.40.preheader ]
  %arrayidx43 = getelementptr inbounds %struct.regnode_charclass_class, %struct.regnode_charclass_class* %and_with, i64 0, i32 4, i64 %indvars.iv
  %0 = load i8, i8* %arrayidx43, align 1, !tbaa !0
  %arrayidx47 = getelementptr inbounds %struct.regnode_charclass_class, %struct.regnode_charclass_class* %cl, i64 0, i32 4, i64 %indvars.iv
  %1 = load i8, i8* %arrayidx47, align 1, !tbaa !0
  %and49151 = and i8 %1, %0
  store i8 %and49151, i8* %arrayidx47, align 1, !tbaa !0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 32
  br i1 %exitcond, label %if.end.54.loopexit, label %for.body.40

if.end.54.loopexit:                               ; preds = %for.body.40
  br label %if.end.54.exitStub

for.body.preheader:                               ; preds = %if.then
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.preheader
  %indvars.iv162 = phi i64 [ %indvars.iv.next163, %for.body ], [ 0, %for.body.preheader ]
  %arrayidx = getelementptr inbounds %struct.regnode_charclass_class, %struct.regnode_charclass_class* %and_with, i64 0, i32 4, i64 %indvars.iv162
  %2 = load i8, i8* %arrayidx, align 1, !tbaa !0
  %neg = xor i8 %2, -1
  %arrayidx33 = getelementptr inbounds %struct.regnode_charclass_class, %struct.regnode_charclass_class* %cl, i64 0, i32 4, i64 %indvars.iv162
  %3 = load i8, i8* %arrayidx33, align 1, !tbaa !0
  %and35 = and i8 %3, %neg
  store i8 %and35, i8* %arrayidx33, align 1, !tbaa !0
  %indvars.iv.next163 = add nuw nsw i64 %indvars.iv162, 1
  %exitcond164 = icmp eq i64 %indvars.iv.next163, 32
  br i1 %exitcond164, label %if.end.54.loopexit165, label %for.body

if.end.54.loopexit165:                            ; preds = %for.body
  br label %if.end.54.exitStub
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C/C++ TBAA"}
