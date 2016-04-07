
; RUN: opt -load LLVMPolyJIT.so -O3 -jitable -polli-process-unprofitable -polli  -no-recompilation -polli-analyze -disable-output -stats < %s 2>&1 | FileCheck %s

; CHECK: 6 polyjit          - Number of jitable SCoPs

; ModuleID = '../delete_atoms.cpp._ZN9LAMMPS_NS11DeleteAtoms16recount_topologyEv_for.body.lr.ph.split.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define weak void @_ZN9LAMMPS_NS11DeleteAtoms16recount_topologyEv_for.body.lr.ph.split.pjit.scop(i1 %tobool19, i32*, i64* %nbonds, i1 %tobool26, i1 %tobool33, i32, i32*, i64* %nimpropers, i32*, i64* %ndihedrals, i32*, i64* %nangles)  {
newFuncRoot:
  br label %for.body.lr.ph.split

if.end.99.exitStub:                               ; preds = %if.end.99.loopexit269, %if.end.99.loopexit268
  ret void

for.body.lr.ph.split:                             ; preds = %newFuncRoot
  br i1 %tobool19, label %if.then.18.us228.preheader, label %if.then.18.preheader

if.then.18.us228.preheader:                       ; preds = %for.body.lr.ph.split
  br label %if.then.18.us228

if.then.18.us228:                                 ; preds = %for.inc.us251, %if.then.18.us228.preheader
  %indvars.iv256 = phi i64 [ %indvars.iv.next257, %for.inc.us251 ], [ 0, %if.then.18.us228.preheader ]
  %arrayidx.us.230 = getelementptr inbounds i32, i32* %0, i64 %indvars.iv256
  %5 = load i32, i32* %arrayidx.us.230, align 4, !tbaa !0
  %conv.us.231 = sext i32 %5 to i64
  %6 = load i64, i64* %nbonds, align 8, !tbaa !4
  %add.us.232 = add nsw i64 %6, %conv.us.231
  store i64 %add.us.232, i64* %nbonds, align 8, !tbaa !4
  br i1 %tobool26, label %if.end.32.us245, label %if.then.27.us240

if.end.32.us245:                                  ; preds = %if.then.27.us240, %if.then.18.us228
  br i1 %tobool33, label %for.inc.us251, label %if.then.34.us246

for.inc.us251:                                    ; preds = %if.then.34.us246, %if.end.32.us245
  %indvars.iv.next257 = add nuw nsw i64 %indvars.iv256, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next257 to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %1
  br i1 %exitcond, label %if.end.99.loopexit268, label %if.then.18.us228

if.end.99.loopexit268:                            ; preds = %for.inc.us251
  br label %if.end.99.exitStub

if.then.34.us246:                                 ; preds = %if.end.32.us245
  %arrayidx36.us.248 = getelementptr inbounds i32, i32* %2, i64 %indvars.iv256
  %7 = load i32, i32* %arrayidx36.us.248, align 4, !tbaa !0
  %conv37.us.249 = sext i32 %7 to i64
  %8 = load i64, i64* %nimpropers, align 8, !tbaa !4
  %add38.us.250 = add nsw i64 %8, %conv37.us.249
  store i64 %add38.us.250, i64* %nimpropers, align 8, !tbaa !4
  br label %for.inc.us251

if.then.27.us240:                                 ; preds = %if.then.18.us228
  %arrayidx29.us.242 = getelementptr inbounds i32, i32* %3, i64 %indvars.iv256
  %9 = load i32, i32* %arrayidx29.us.242, align 4, !tbaa !0
  %conv30.us.243 = sext i32 %9 to i64
  %10 = load i64, i64* %ndihedrals, align 8, !tbaa !4
  %add31.us.244 = add nsw i64 %10, %conv30.us.243
  store i64 %add31.us.244, i64* %ndihedrals, align 8, !tbaa !4
  br label %if.end.32.us245

if.then.18.preheader:                             ; preds = %for.body.lr.ph.split
  br label %if.then.18

if.then.18:                                       ; preds = %for.inc, %if.then.18.preheader
  %indvars.iv260 = phi i64 [ %indvars.iv.next261, %for.inc ], [ 0, %if.then.18.preheader ]
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %indvars.iv260
  %11 = load i32, i32* %arrayidx, align 4, !tbaa !0
  %conv = sext i32 %11 to i64
  %12 = load i64, i64* %nbonds, align 8, !tbaa !4
  %add = add nsw i64 %12, %conv
  store i64 %add, i64* %nbonds, align 8, !tbaa !4
  %arrayidx22 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv260
  %13 = load i32, i32* %arrayidx22, align 4, !tbaa !0
  %conv23 = sext i32 %13 to i64
  %14 = load i64, i64* %nangles, align 8, !tbaa !4
  %add24 = add nsw i64 %14, %conv23
  store i64 %add24, i64* %nangles, align 8, !tbaa !4
  br i1 %tobool26, label %if.end.32, label %if.then.27

if.end.32:                                        ; preds = %if.then.27, %if.then.18
  br i1 %tobool33, label %for.inc, label %if.then.34

for.inc:                                          ; preds = %if.then.34, %if.end.32
  %indvars.iv.next261 = add nuw nsw i64 %indvars.iv260, 1
  %lftr.wideiv272 = trunc i64 %indvars.iv.next261 to i32
  %exitcond273 = icmp eq i32 %lftr.wideiv272, %1
  br i1 %exitcond273, label %if.end.99.loopexit269, label %if.then.18

if.end.99.loopexit269:                            ; preds = %for.inc
  br label %if.end.99.exitStub

if.then.34:                                       ; preds = %if.end.32
  %arrayidx36 = getelementptr inbounds i32, i32* %2, i64 %indvars.iv260
  %15 = load i32, i32* %arrayidx36, align 4, !tbaa !0
  %conv37 = sext i32 %15 to i64
  %16 = load i64, i64* %nimpropers, align 8, !tbaa !4
  %add38 = add nsw i64 %16, %conv37
  store i64 %add38, i64* %nimpropers, align 8, !tbaa !4
  br label %for.inc

if.then.27:                                       ; preds = %if.then.18
  %arrayidx29 = getelementptr inbounds i32, i32* %3, i64 %indvars.iv260
  %17 = load i32, i32* %arrayidx29, align 4, !tbaa !0
  %conv30 = sext i32 %17 to i64
  %18 = load i64, i64* %ndihedrals, align 8, !tbaa !4
  %add31 = add nsw i64 %18, %conv30
  store i64 %add31, i64* %ndihedrals, align 8, !tbaa !4
  br label %if.end.32
}

attributes #0 = { "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"long", !2, i64 0}
