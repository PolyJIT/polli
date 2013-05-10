; ModuleID = 'nl.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-unknown-linux-gnu"

define i32 @foo(i32 %p, i32 %q) nounwind {
entry:
  %p.addr = alloca i32, align 4
  %q.addr = alloca i32, align 4
  %A = alloca [128 x i32], align 16
  %i = alloca i32, align 4
  %i4 = alloca i32, align 4
  store i32 %p, i32* %p.addr, align 4
  call void @llvm.dbg.declare(metadata !{i32* %p.addr}, metadata !7), !dbg !8
  store i32 %q, i32* %q.addr, align 4
  call void @llvm.dbg.declare(metadata !{i32* %q.addr}, metadata !9), !dbg !10
  call void @llvm.dbg.declare(metadata !{[128 x i32]* %A}, metadata !11), !dbg !16
  call void @llvm.dbg.declare(metadata !{i32* %i}, metadata !17), !dbg !19
  store i32 0, i32* %i, align 4, !dbg !20
  br label %for.cond, !dbg !20

for.cond:                                         ; preds = %for.inc, %entry
  %tmp = load i32* %i, align 4, !dbg !20
  %cmp = icmp slt i32 %tmp, 128, !dbg !20
  br i1 %cmp, label %for.body, label %for.end, !dbg !20

for.body:                                         ; preds = %for.cond
  %call = call i32 @rand() nounwind, !dbg !21
  %rem = srem i32 %call, 1024, !dbg !21
  %tmp1 = load i32* %i, align 4, !dbg !21
  %idxprom = sext i32 %tmp1 to i64, !dbg !21
  %arrayidx = getelementptr inbounds [128 x i32]* %A, i32 0, i64 %idxprom, !dbg !21
  store i32 %rem, i32* %arrayidx, align 4, !dbg !21
  br label %for.inc, !dbg !23

for.inc:                                          ; preds = %for.body
  %tmp2 = load i32* %i, align 4, !dbg !24
  %inc = add nsw i32 %tmp2, 1, !dbg !24
  store i32 %inc, i32* %i, align 4, !dbg !24
  br label %for.cond, !dbg !24

for.end:                                          ; preds = %for.cond
  call void @llvm.dbg.declare(metadata !{i32* %i4}, metadata !25), !dbg !27
  store i32 0, i32* %i4, align 4, !dbg !28
  br label %for.cond5, !dbg !28

for.cond5:                                        ; preds = %for.inc18, %for.end
  %tmp6 = load i32* %i4, align 4, !dbg !28
  %cmp7 = icmp slt i32 %tmp6, 64, !dbg !28
  br i1 %cmp7, label %for.body8, label %for.end21, !dbg !28

for.body8:                                        ; preds = %for.cond5
  %tmp9 = load i32* %i4, align 4, !dbg !29
  %idxprom10 = sext i32 %tmp9 to i64, !dbg !29
  %arrayidx11 = getelementptr inbounds [128 x i32]* %A, i32 0, i64 %idxprom10, !dbg !29
  %tmp12 = load i32* %arrayidx11, align 4, !dbg !29
  %tmp13 = load i32* %i4, align 4, !dbg !29
  %tmp14 = load i32* %q.addr, align 4, !dbg !29
  %tmp15 = load i32* %p.addr, align 4, !dbg !29
  %mul = mul nsw i32 %tmp14, %tmp15, !dbg !29
  %add = add nsw i32 %tmp13, %mul, !dbg !29
  %idxprom16 = sext i32 %add to i64, !dbg !29
  %arrayidx17 = getelementptr inbounds [128 x i32]* %A, i32 0, i64 %idxprom16, !dbg !29
  store i32 %tmp12, i32* %arrayidx17, align 4, !dbg !29
  br label %for.inc18, !dbg !31

for.inc18:                                        ; preds = %for.body8
  %tmp19 = load i32* %i4, align 4, !dbg !32
  %inc20 = add nsw i32 %tmp19, 1, !dbg !32
  store i32 %inc20, i32* %i4, align 4, !dbg !32
  br label %for.cond5, !dbg !32

for.end21:                                        ; preds = %for.cond5
  ret i32 0, !dbg !33
}

declare void @llvm.dbg.declare(metadata, metadata) nounwind readnone

declare i32 @rand() nounwind

define i32 @main() nounwind {
entry:
  %retval = alloca i32, align 4
  store i32 0, i32* %retval
  %call = call i32 @foo(i32 3, i32 6), !dbg !34
  %call1 = call i32 @foo(i32 1, i32 4), !dbg !36
  %call2 = call i32 @foo(i32 2, i32 5), !dbg !37
  ret i32 0, !dbg !38
}

!llvm.dbg.sp = !{!0, !6}

!0 = metadata !{i32 589870, i32 0, metadata !1, metadata !"foo", metadata !"foo", metadata !"", metadata !1, i32 5, metadata !3, i1 false, i1 true, i32 0, i32 0, i32 0, i32 256, i1 false, i32 (i32, i32)* @foo, null} ; [ DW_TAG_subprogram ]
!1 = metadata !{i32 589865, metadata !"nl.c", metadata !"/home/simbuerg/prj/tmp/non-linear", metadata !2} ; [ DW_TAG_file_type ]
!2 = metadata !{i32 589841, i32 0, i32 12, metadata !"nl.c", metadata !"/home/simbuerg/prj/tmp/non-linear", metadata !"clang version 3.0 (trunk 129351)", i1 true, i1 false, metadata !"", i32 0} ; [ DW_TAG_compile_unit ]
!3 = metadata !{i32 589845, metadata !1, metadata !"", metadata !1, i32 0, i64 0, i64 0, i32 0, i32 0, i32 0, metadata !4, i32 0, i32 0} ; [ DW_TAG_subroutine_type ]
!4 = metadata !{metadata !5}
!5 = metadata !{i32 589860, metadata !2, metadata !"int", null, i32 0, i64 32, i64 32, i64 0, i32 0, i32 5} ; [ DW_TAG_base_type ]
!6 = metadata !{i32 589870, i32 0, metadata !1, metadata !"main", metadata !"main", metadata !"", metadata !1, i32 19, metadata !3, i1 false, i1 true, i32 0, i32 0, i32 0, i32 0, i1 false, i32 ()* @main, null} ; [ DW_TAG_subprogram ]
!7 = metadata !{i32 590081, metadata !0, metadata !"p", metadata !1, i32 16777221, metadata !5, i32 0} ; [ DW_TAG_arg_variable ]
!8 = metadata !{i32 5, i32 13, metadata !0, null}
!9 = metadata !{i32 590081, metadata !0, metadata !"q", metadata !1, i32 33554437, metadata !5, i32 0} ; [ DW_TAG_arg_variable ]
!10 = metadata !{i32 5, i32 20, metadata !0, null}
!11 = metadata !{i32 590080, metadata !12, metadata !"A", metadata !1, i32 6, metadata !13, i32 0} ; [ DW_TAG_auto_variable ]
!12 = metadata !{i32 589835, metadata !0, i32 5, i32 23, metadata !1, i32 0} ; [ DW_TAG_lexical_block ]
!13 = metadata !{i32 589825, metadata !2, metadata !"", metadata !2, i32 0, i64 4096, i64 32, i32 0, i32 0, metadata !5, metadata !14, i32 0, i32 0} ; [ DW_TAG_array_type ]
!14 = metadata !{metadata !15}
!15 = metadata !{i32 589857, i64 0, i64 127}      ; [ DW_TAG_subrange_type ]
!16 = metadata !{i32 6, i32 7, metadata !12, null}
!17 = metadata !{i32 590080, metadata !18, metadata !"i", metadata !1, i32 8, metadata !5, i32 0} ; [ DW_TAG_auto_variable ]
!18 = metadata !{i32 589835, metadata !12, i32 8, i32 3, metadata !1, i32 1} ; [ DW_TAG_lexical_block ]
!19 = metadata !{i32 8, i32 12, metadata !18, null}
!20 = metadata !{i32 8, i32 3, metadata !12, null}
!21 = metadata !{i32 9, i32 5, metadata !22, null}
!22 = metadata !{i32 589835, metadata !18, i32 8, i32 27, metadata !1, i32 2} ; [ DW_TAG_lexical_block ]
!23 = metadata !{i32 10, i32 3, metadata !22, null}
!24 = metadata !{i32 8, i32 22, metadata !18, null}
!25 = metadata !{i32 590080, metadata !26, metadata !"i", metadata !1, i32 12, metadata !5, i32 0} ; [ DW_TAG_auto_variable ]
!26 = metadata !{i32 589835, metadata !12, i32 12, i32 3, metadata !1, i32 3} ; [ DW_TAG_lexical_block ]
!27 = metadata !{i32 12, i32 12, metadata !26, null}
!28 = metadata !{i32 12, i32 3, metadata !12, null}
!29 = metadata !{i32 13, i32 5, metadata !30, null}
!30 = metadata !{i32 589835, metadata !26, i32 12, i32 26, metadata !1, i32 4} ; [ DW_TAG_lexical_block ]
!31 = metadata !{i32 14, i32 3, metadata !30, null}
!32 = metadata !{i32 12, i32 21, metadata !26, null}
!33 = metadata !{i32 16, i32 3, metadata !12, null}
!34 = metadata !{i32 20, i32 3, metadata !35, null}
!35 = metadata !{i32 589835, metadata !6, i32 19, i32 12, metadata !1, i32 5} ; [ DW_TAG_lexical_block ]
!36 = metadata !{i32 21, i32 3, metadata !35, null}
!37 = metadata !{i32 22, i32 3, metadata !35, null}
!38 = metadata !{i32 24, i32 3, metadata !35, null}
