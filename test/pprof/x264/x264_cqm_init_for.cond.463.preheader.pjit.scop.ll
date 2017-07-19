; RUN: opt -load LLVMPolly.so -load LLVMPolyJIT.so -O3  -polli  -polli-no-recompilation -polli-analyze -disable-output < %s 2>&1 | FileCheck %s

; CHECK: 1 regions require runtime support:


; ModuleID = 'common/set.c.x264_cqm_init_for.cond.463.preheader.pjit.scop.prototype'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.x264_t = type { %struct.x264_param_t, [129 x %struct.x264_t*], [16 x %struct.x264_t*], i32, i32, i32, i32, i32, i32, %struct.x264_threadpool_t*, %struct.x264_threadpool_t*, i32, i32, %struct.anon.3, i8*, i32, %struct.x264_t*, i32, i32, i32, i32, i32, i32, i64, i32, i64, i64, i64, i64, i64, i64, i64, i32, i64, i32, [4 x [16 x i32]*], [4 x [64 x i32]*], [4 x [16 x i32]*], [4 x [64 x i32]*], [4 x [16 x i16]*], [4 x [64 x i16]*], [4 x [16 x i16]*], [4 x [64 x i16]*], [4 x [16 x i16]*], [4 x [64 x i16]*], [4 x [64 x i16]]*, [70 x i16*], [70 x [4 x i16*]], i8*, [8 x i8], %struct.x264_slice_header_t, [1 x %struct.x264_sps_t], [1 x %struct.x264_pps_t], i32, %struct.x264_slice_header_t, %struct.x264_cabac_t, %struct.anon.9, %struct.x264_frame*, %struct.x264_frame*, [2 x i32], [2 x [19 x %struct.x264_frame*]], [2 x %struct.x264_frame*], [2 x i32], i32, i32, i64, %struct.anon.10, %struct.anon.11, %struct.x264_ratecontrol_t*, %struct.anon.14, [64 x i16]*, [64 x i32]*, i32*, [16 x i8], [4 x [64 x i16]], [2 x [4 x [64 x i32]]], [2 x [4 x i32]], [7 x i8], i8*, i8*, [5 x [3 x i8*]], [2 x [2 x [8 x [4 x i8]]]*], [7 x void (i8*)*], [12 x void (i8*, i8*)*], [12 x void (i8*)*], [7 x void (i8*)*], [7 x void (i8*)*], [7 x void (i8*)*], void (i8*, i8*, i32, i32)*, %struct.x264_pixel_function_t, %struct.x264_mc_functions_t, %struct.x264_dct_function_t, %struct.x264_zigzag_function_t, %struct.x264_zigzag_function_t, %struct.x264_zigzag_function_t, %struct.x264_quant_function_t, %struct.x264_deblock_function_t, %struct.x264_bitstream_function_t, %struct.x264_lookahead_t*, [8 x i8] }
%struct.x264_param_t = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, %struct.anon, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i8*, [16 x i8], [16 x i8], [16 x i8], [16 x i8], [64 x i8], [64 x i8], [64 x i8], [64 x i8], void (i8*, i32, i8*, %struct.__va_list_tag*)*, i8*, i32, i32, i8*, %struct.anon.0, %struct.anon.1, %struct.anon.2, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i8*, i8*, i32, i32, i32, i32, i32, void (i8*)*, void (%struct.x264_t*, %struct.x264_nal_t*, i8*)* }
%struct.anon = type { i32, i32, i32, i32, i32, i32, i32, i32, i32 }
%struct.__va_list_tag = type { i32, i32, i8*, i8* }
%struct.anon.0 = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, float, float, i32, i32, i32, [2 x i32], i32, i32 }
%struct.anon.1 = type { i32, i32, i32, i32, i32, i32, float, float, float, i32, i32, float, float, float, i32, i32, float, i32, i32, i32, i8*, i32, i8*, float, float, float, %struct.x264_zone_t*, i32, i8* }
%struct.x264_zone_t = type { i32, i32, i32, i32, float, %struct.x264_param_t* }
%struct.anon.2 = type { i32, i32, i32, i32 }
%struct.x264_nal_t = type { i32, i32, i32, i32, i32, i32, i8*, i32 }
%struct.x264_threadpool_t = type opaque
%struct.anon.3 = type { i32, i32, %struct.x264_nal_t*, i32, i8*, %struct.bs_s }
%struct.bs_s = type { i8*, i8*, i8*, i64, i32, i32 }
%struct.x264_sps_t = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, %struct.anon.4, i32, %struct.anon.5, i32, i32 }
%struct.anon.4 = type { i32, i32, i32, i32 }
%struct.anon.5 = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, %struct.anon.6, i32, i32, i32, i32, i32, i32, i32, i32, i32 }
%struct.anon.6 = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }
%struct.x264_pps_t = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [8 x i8*] }
%struct.x264_slice_header_t = type { %struct.x264_sps_t*, %struct.x264_pps_t*, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [2 x i32], i32, i32, i32, i32, i32, [2 x i32], [2 x [16 x %struct.anon.7]], i32, [12 x i8], [32 x [3 x %struct.x264_weight_t]], i32, i32, [16 x %struct.anon.8], i32, i32, i32, i32, i32, i32, i32, i32, [8 x i8] }
%struct.anon.7 = type { i32, i32 }
%struct.x264_weight_t = type { [8 x i16], [8 x i16], i32, i32, i32, void (i8*, i64, i8*, i64, %struct.x264_weight_t*, i32)**, [8 x i8] }
%struct.anon.8 = type { i32, i32 }
%struct.x264_cabac_t = type { i32, i32, i32, i32, i8*, i8*, i8*, [8 x i8], i32, [1024 x i8], [12 x i8] }
%struct.anon.9 = type { %struct.x264_frame**, [2 x %struct.x264_frame**], %struct.x264_frame**, [18 x %struct.x264_frame*], i32, i32, i32, i32, i32, i32, i32, i32, i32, i64, i64, [2 x i64], i64, i64, i32, i32 }
%struct.x264_frame = type { i8*, i32, [2 x i32], i32, i32, i32, i64, i64, i64, i64, float, i64, i64, i64, %struct.x264_param_t*, i32, i32, i64, i32, i32, i32, i32, i8, i8, i8, float, float, float, i32, i32, i32, [3 x i32], [3 x i32], [3 x i32], i32, i32, i32, [3 x i8*], [3 x i8*], [3 x [4 x i8*]], [3 x [4 x i8*]], [4 x i8*], i16*, [4 x i8*], [4 x i8*], [4 x i8*], [16 x [3 x %struct.x264_weight_t]], [16 x i8*], i32, %struct.x264_frame*, i8*, i8*, [2 x [2 x i16]*], [2 x i16]*, [2 x [17 x [2 x i16]*]], i8*, i8*, [18 x [18 x i16*]], [2 x [17 x i32*]], [2 x i8*], [2 x i32], [2 x [16 x i32]], [2 x i16], [18 x [18 x i32]], [18 x [18 x i32]], i32, [18 x i32], [18 x [18 x i32*]], i32*, i32*, float*, float*, float*, float*, i32, i16*, i16*, i16*, i32, [18 x float], [3 x i32], [3 x i64], %struct.x264_hrd_t, [251 x i8], [251 x i32], [251 x double], i64, i64, i32, i32, i32, i32, i32, i32, float, i32, i32, i32, i32, %struct.x264_sei_t, i8*, i8*, void (i8*)* }
%struct.x264_hrd_t = type { double, double, double, double }
%struct.x264_sei_t = type { i32, %struct.x264_sei_payload_t*, void (i8*)* }
%struct.x264_sei_payload_t = type { i32, i32, i8* }
%struct.anon.10 = type { [3 x [16 x i16]], [2 x [8 x i16]], [12 x [64 x i16]], [48 x [16 x i16]] }
%struct.anon.11 = type { i32, i32, i32, i32, i32, i32, i32, i32, [2 x i32], [2 x i32], i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [2 x i32], [2 x i32], [3 x i32], [3 x i32], [2 x i32], [2 x i32], [3 x i32], [3 x i32], [4 x i8], [2 x [2 x i16]], [3 x i32], [3 x i32], i32, [4 x i32], [16 x i32], i32, i32, i32, [2 x i32], i32, i32, i32, [2 x i32], i32, i32, i32, i32, i32, i32, %struct.x264_left_table_t*, i32, i32, i32, i32, i8*, i8*, i8*, i8*, i16*, [8 x i8]*, [48 x i8]*, i8*, [2 x [2 x i16]*], [2 x [8 x [2 x i8]]*], [2 x i8*], [2 x [32 x [2 x i16]*]], i8*, i8*, i16*, i8*, [16 x i8*], i32, i32, [4 x i8], i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [8 x i8], %struct.anon.12, %struct.anon.13, i32, i32, i32, i32, i32, i32, i32, i32, [2 x [2 x i32]], i32, i32, [2 x [2 x [32 x [4 x i16]]]], [4 x i16]*, [2 x [2 x [32 x [4 x i8]]]], [4 x i8]*, [18 x i8], i32, [34 x i8], [14 x i8] }
%struct.x264_left_table_t = type { [4 x i8], [4 x i8], [4 x i8], [4 x i8], [4 x i8] }
%struct.anon.12 = type { [768 x i8], [1664 x i8], [256 x i8], [256 x i8], [3 x [64 x i16]], [15 x [16 x i16]], [4 x i32], [4 x i32], i32, i32, [8 x i8], [4 x [64 x i16]], [16 x [16 x i16]], [16 x i8], [9 x i64], [24 x i8], [32 x i32], [3 x i8*], [3 x i8*], [3 x i8*], [2 x i32], [2 x [32 x [12 x i8*]]], [32 x i8*], [2 x [16 x i16*]], [3 x i32] }
%struct.anon.13 = type { [40 x i8], [8 x i8], [120 x i8], [2 x [40 x i8]], [8 x i8], [2 x [40 x [2 x i16]]], [2 x [40 x [2 x i8]]], [40 x i8], [2 x [4 x [2 x i16]]], [2 x [4 x i8]], i32, [2 x i16], i32, i32, i32, i32, [2 x [3 x [2 x i16]]], [2 x [3 x i8]], [8 x [4 x i8]]* }
%struct.x264_ratecontrol_t = type opaque
%struct.anon.14 = type { [3 x i32], [3 x i64], [3 x double], [17 x i32], [3 x double], [3 x double], [3 x double], [3 x double], [3 x double], [3 x double], [3 x double], [3 x [19 x i64]], [2 x [17 x i64]], [2 x i64], [2 x [2 x [32 x i64]]], [6 x i64], [4 x [13 x i64]], [3 x i64], [2 x i32], [2 x i32], [2 x i32], %struct.x264_frame_stat_t }
%struct.x264_frame_stat_t = type { i32, i32, i32, [19 x i32], i32, i32, i32, [2 x i32], [2 x [32 x i32]], [17 x i32], [6 x i32], [4 x [13 x i32]], [3 x i32], [2 x i32], [3 x i64], double, i32 }
%struct.x264_pixel_function_t = type { [8 x i32 (i8*, i64, i8*, i64)*], [8 x i32 (i8*, i64, i8*, i64)*], [8 x i32 (i8*, i64, i8*, i64)*], [7 x i32 (i8*, i64, i8*, i64)*], [4 x i32 (i8*, i64, i8*, i64)*], [8 x i32 (i8*, i64, i8*, i64)*], [8 x i32 (i8*, i64, i8*, i64)*], [8 x i32 (i8*, i64, i8*, i64)*], [7 x void (i8*, i8*, i8*, i8*, i64, i32*)*], [7 x void (i8*, i8*, i8*, i8*, i8*, i64, i32*)*], [8 x i32 (i8*, i64, i8*, i64)*], i32 (i8*, i64, i32)*, i32 (i8*, i64, i8*, i64, i32)*, [1 x i64 (i8*, i64, i8*, i64)*], [4 x i64 (i8*, i64)*], [4 x i32 (i8*, i64, i8*, i64, i32*)*], [4 x i64 (i8*, i64)*], void (i8*, i64, i8*, i64, i32, i32, i64*, i64*)*, void (i8*, i64, i8*, i64, [4 x i32]*)*, float ([4 x i32]*, [4 x i32]*, i32)*, [7 x void (i8*, i8*, i8*, i8*, i64, i32*)*], [7 x void (i8*, i8*, i8*, i8*, i8*, i64, i32*)*], [7 x void (i8*, i8*, i8*, i8*, i64, i32*)*], [7 x void (i8*, i8*, i8*, i8*, i8*, i64, i32*)*], [7 x i32 (i32*, i16*, i32, i16*, i16*, i32, i32)*], void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, void (i8*, i8*, i32*)*, i32 (i8*, i8*, i16*)*, i32 (i8*, i8*, i16*)*, i32 (i8*, i8*, i16*)*, i32 (i8*, i8*, i8*, i16*, i16*)*, i32 (i8*, i8*, i8*, i16*, i16*)*, i32 (i8*, i8*, i8*, i16*, i16*)* }
%struct.x264_mc_functions_t = type { void (i8*, i64, i8**, i64, i32, i32, i32, i32, %struct.x264_weight_t*)*, i8* (i8*, i64*, i8**, i64, i32, i32, i32, i32, %struct.x264_weight_t*)*, void (i8*, i8*, i64, i8*, i64, i32, i32, i32, i32)*, [12 x void (i8*, i64, i8*, i64, i8*, i64, i32)*], [7 x void (i8*, i64, i8*, i64, i32)*], void (i8*, i64, i8*, i64, i32)*, void (i8*, i64, i8*, i8*, i32)*, void (i8*, i8*, i64, i32)*, void (i8*, i8*, i64, i32)*, void (i8*, i64, i8*, i64, i32, i32)*, void (i8*, i64, i8*, i64, i32, i32)*, void (i8*, i64, i8*, i64, i8*, i64, i32, i32)*, void (i8*, i64, i8*, i64, i8*, i64, i32, i32)*, void (i8*, i64, i8*, i64, i8*, i64, i8*, i64, i32, i32, i32)*, void (i8*, i64, i8*, i64, i32*, i64, i32, i32)*, void (i8*, i8*, i8*, i8*, i64, i32, i32, i16*)*, void (i8*, i64, i8*, i64, i32)*, void (i8*, i64, i8*, i64, i32)*, void (i8*, i64, i8*, i64, i32)*, void (i8*, i64, i32)*, i8* (i8*, i8*, i64)*, void (i8*, i64)*, void (i16*, i8*, i64)*, void (i16*, i8*, i64)*, void (i16*, i16*, i64)*, void (i16*, i64)*, void (i8*, i8*, i8*, i8*, i8*, i64, i64, i32, i32)*, void (i8*, i64, i8*, i64, %struct.x264_weight_t*, i32)**, void (i8*, i64, i8*, i64, %struct.x264_weight_t*, i32)**, void (i8*, i64, i8*, i64, %struct.x264_weight_t*, i32)**, void (%struct.x264_t*, %struct.x264_weight_t*)*, void (i16*, i16*, i16*, i16*, i16*, float*, i32)*, void (%struct.x264_t*, i16*, [2 x i16]*, i16*, i16*, i32, i32, i32, i32)* }
%struct.x264_dct_function_t = type { void (i16*, i8*, i8*)*, void (i8*, i16*)*, void ([16 x i16]*, i8*, i8*)*, void (i16*, i8*, i8*)*, void (i8*, [16 x i16]*)*, void (i8*, i16*)*, void (i16*, i8*, i8*)*, void ([16 x i16]*, i8*, i8*)*, void (i8*, [16 x i16]*)*, void (i8*, i16*)*, void (i16*, i8*, i8*)*, void (i8*, i16*)*, void ([64 x i16]*, i8*, i8*)*, void (i8*, [64 x i16]*)*, void (i16*)*, void (i16*)*, void (i16*, [16 x i16]*)* }
%struct.x264_zigzag_function_t = type { void (i16*, i16*)*, void (i16*, i16*)*, i32 (i16*, i8*, i8*)*, i32 (i16*, i8*, i8*)*, i32 (i16*, i8*, i8*, i16*)*, void (i16*, i16*, i8*)* }
%struct.x264_quant_function_t = type { i32 (i16*, i16*, i16*)*, i32 (i16*, i16*, i16*)*, i32 ([16 x i16]*, i16*, i16*)*, i32 (i16*, i32, i32)*, i32 (i16*, i32, i32)*, void (i16*, [64 x i32]*, i32)*, void (i16*, [16 x i32]*, i32)*, void (i16*, [16 x i32]*, i32)*, void (i16*, [16 x i16]*, [16 x i32]*, i32)*, void (i16*, [16 x i32]*, i32)*, i32 (i16*, i32)*, i32 (i16*, i32)*, void (i16*, i32*, i16*, i32)*, i32 (i16*)*, i32 (i16*)*, i32 (i16*)*, [14 x i32 (i16*)*], i32 (i16*)*, i32 (i16*)*, [13 x i32 (i16*, %struct.x264_run_level_t*)*], i32 (i16*, %struct.x264_run_level_t*)*, i32 (i16*, %struct.x264_run_level_t*)*, i32 (i32*, i8*, i32, i32, i16*, i16*, i16*, i8*, i8*, i64, i16, i32)*, i32 (i32*, i8*, i32, i32, i16*, i16*, i16*, i8*, i8*, i64, i16, i32)*, i32 (i32*, i8*, i32, i32, i16*, i16*, i16*, i8*, i8*, i64, i16, i32, i16*, i32)*, i32 (i32*, i8*, i32, i32, i16*, i16*, i16*, i8*, i8*, i64, i16, i32, i16*, i32)*, i32 (i32*, i8*, i32, i32, i16*, i16*, i16*, i8*, i8*, i64, i16, i32)*, i32 (i32*, i8*, i32, i32, i16*, i16*, i16*, i8*, i8*, i64, i16)* }
%struct.x264_run_level_t = type { i32, i32, [8 x i8], [18 x i16], [12 x i8] }
%struct.x264_deblock_function_t = type { [2 x void (i8*, i64, i32, i32, i8*)*], [2 x void (i8*, i64, i32, i32, i8*)*], void (i8*, i64, i32, i32, i8*)*, void (i8*, i64, i32, i32, i8*)*, [2 x void (i8*, i64, i32, i32)*], [2 x void (i8*, i64, i32, i32)*], void (i8*, i64, i32, i32)*, void (i8*, i64, i32, i32)*, void (i8*, i64, i32, i32, i8*)*, void (i8*, i64, i32, i32, i8*)*, void (i8*, i64, i32, i32, i8*)*, void (i8*, i64, i32, i32, i8*)*, void (i8*, i64, i32, i32)*, void (i8*, i64, i32, i32)*, void (i8*, i64, i32, i32)*, void (i8*, i64, i32, i32)*, void (i8*, [40 x i8]*, [40 x [2 x i16]]*, [8 x [4 x i8]]*, i32, i32)* }
%struct.x264_bitstream_function_t = type { i8* (i8*, i8*, i8*)*, void (i16*, i32, i64, %struct.x264_cabac_t*)*, void (i16*, i32, i64, %struct.x264_cabac_t*)*, void (i16*, i32, i64, %struct.x264_cabac_t*)* }
%struct.x264_lookahead_t = type { i8, i8, i8, i32, i32, %struct.x264_frame*, i32, %struct.x264_sync_frame_list_t, %struct.x264_sync_frame_list_t, %struct.x264_sync_frame_list_t }
%struct.x264_sync_frame_list_t = type { %struct.x264_frame**, i32, i32, i32, i32, i32 }

; Function Attrs: nounwind
define weak void @x264_cqm_init_for.cond.463.preheader.pjit.scop(%struct.x264_t* %h, [6 x [16 x i32]]* %def_dequant4, [6 x [16 x i32]]* %def_quant4, [4 x [6 x [16 x i32]]]* %quant4_mf)  {
newFuncRoot:
  br label %for.cond.463.preheader

for.cond.603.preheader.loopexit.exitStub:         ; preds = %for.cond.cleanup.466.3
  ret void

for.cond.463.preheader:                           ; preds = %for.cond.cleanup.466.3, %newFuncRoot
  %indvars.iv1767 = phi i64 [ %indvars.iv.next1768, %for.cond.cleanup.466.3 ], [ 0, %newFuncRoot ]
  %arrayidx477 = getelementptr inbounds %struct.x264_t, %struct.x264_t* %h, i64 0, i32 52, i64 0, i32 17, i64 0
  %arrayidx485 = getelementptr inbounds %struct.x264_t, %struct.x264_t* %h, i64 0, i32 35, i64 0
  br label %for.body.467

for.body.467:                                     ; preds = %for.body.467, %for.cond.463.preheader
  %indvars.iv1761 = phi i64 [ 0, %for.cond.463.preheader ], [ %indvars.iv.next1762, %for.body.467 ]
  %arrayidx471 = getelementptr inbounds [6 x [16 x i32]], [6 x [16 x i32]]* %def_dequant4, i64 0, i64 %indvars.iv1767, i64 %indvars.iv1761
  %0 = load i32, i32* %arrayidx471, align 4, !tbaa !0
  %1 = load i8*, i8** %arrayidx477, align 8, !tbaa !4
  %arrayidx478 = getelementptr inbounds i8, i8* %1, i64 %indvars.iv1761
  %2 = load i8, i8* %arrayidx478, align 1, !tbaa !6
  %conv479 = zext i8 %2 to i32
  %mul480 = mul nsw i32 %conv479, %0
  %3 = load [16 x i32]*, [16 x i32]** %arrayidx485, align 8, !tbaa !4
  %arrayidx487 = getelementptr inbounds [16 x i32], [16 x i32]* %3, i64 %indvars.iv1767, i64 %indvars.iv1761
  store i32 %mul480, i32* %arrayidx487, align 4, !tbaa !0
  %arrayidx491 = getelementptr inbounds [6 x [16 x i32]], [6 x [16 x i32]]* %def_quant4, i64 0, i64 %indvars.iv1767, i64 %indvars.iv1761
  %4 = load i32, i32* %arrayidx491, align 4, !tbaa !0
  %mul492 = shl i32 %4, 4
  %5 = load i8*, i8** %arrayidx477, align 8, !tbaa !4
  %arrayidx499 = getelementptr inbounds i8, i8* %5, i64 %indvars.iv1761
  %6 = load i8, i8* %arrayidx499, align 1, !tbaa !6
  %conv500 = zext i8 %6 to i32
  %shr501.1594 = lshr i32 %conv500, 1
  %add502 = add nsw i32 %shr501.1594, %mul492
  %div = sdiv i32 %add502, %conv500
  %arrayidx516 = getelementptr inbounds [4 x [6 x [16 x i32]]], [4 x [6 x [16 x i32]]]* %quant4_mf, i64 0, i64 0, i64 %indvars.iv1767, i64 %indvars.iv1761
  store i32 %div, i32* %arrayidx516, align 4, !tbaa !0
  %indvars.iv.next1762 = add nuw nsw i64 %indvars.iv1761, 1
  %exitcond1763 = icmp eq i64 %indvars.iv.next1762, 16
  br i1 %exitcond1763, label %for.cond.cleanup.466, label %for.body.467

for.cond.cleanup.466:                             ; preds = %for.body.467
  %arrayidx477.1 = getelementptr inbounds %struct.x264_t, %struct.x264_t* %h, i64 0, i32 52, i64 0, i32 17, i64 1
  %arrayidx485.1 = getelementptr inbounds %struct.x264_t, %struct.x264_t* %h, i64 0, i32 35, i64 1
  br label %for.body.467.1

for.body.467.1:                                   ; preds = %for.body.467.1, %for.cond.cleanup.466
  %indvars.iv1761.1 = phi i64 [ 0, %for.cond.cleanup.466 ], [ %indvars.iv.next1762.1, %for.body.467.1 ]
  %arrayidx471.1 = getelementptr inbounds [6 x [16 x i32]], [6 x [16 x i32]]* %def_dequant4, i64 0, i64 %indvars.iv1767, i64 %indvars.iv1761.1
  %7 = load i32, i32* %arrayidx471.1, align 4, !tbaa !0
  %8 = load i8*, i8** %arrayidx477.1, align 8, !tbaa !4
  %arrayidx478.1 = getelementptr inbounds i8, i8* %8, i64 %indvars.iv1761.1
  %9 = load i8, i8* %arrayidx478.1, align 1, !tbaa !6
  %conv479.1 = zext i8 %9 to i32
  %mul480.1 = mul nsw i32 %conv479.1, %7
  %10 = load [16 x i32]*, [16 x i32]** %arrayidx485.1, align 8, !tbaa !4
  %arrayidx487.1 = getelementptr inbounds [16 x i32], [16 x i32]* %10, i64 %indvars.iv1767, i64 %indvars.iv1761.1
  store i32 %mul480.1, i32* %arrayidx487.1, align 4, !tbaa !0
  %arrayidx491.1 = getelementptr inbounds [6 x [16 x i32]], [6 x [16 x i32]]* %def_quant4, i64 0, i64 %indvars.iv1767, i64 %indvars.iv1761.1
  %11 = load i32, i32* %arrayidx491.1, align 4, !tbaa !0
  %mul492.1 = shl i32 %11, 4
  %12 = load i8*, i8** %arrayidx477.1, align 8, !tbaa !4
  %arrayidx499.1 = getelementptr inbounds i8, i8* %12, i64 %indvars.iv1761.1
  %13 = load i8, i8* %arrayidx499.1, align 1, !tbaa !6
  %conv500.1 = zext i8 %13 to i32
  %shr501.1594.1 = lshr i32 %conv500.1, 1
  %add502.1 = add nsw i32 %shr501.1594.1, %mul492.1
  %div.1 = sdiv i32 %add502.1, %conv500.1
  %arrayidx516.1 = getelementptr inbounds [4 x [6 x [16 x i32]]], [4 x [6 x [16 x i32]]]* %quant4_mf, i64 0, i64 1, i64 %indvars.iv1767, i64 %indvars.iv1761.1
  store i32 %div.1, i32* %arrayidx516.1, align 4, !tbaa !0
  %indvars.iv.next1762.1 = add nuw nsw i64 %indvars.iv1761.1, 1
  %exitcond1763.1 = icmp eq i64 %indvars.iv.next1762.1, 16
  br i1 %exitcond1763.1, label %for.cond.cleanup.466.1, label %for.body.467.1

for.cond.cleanup.466.1:                           ; preds = %for.body.467.1
  %arrayidx477.2 = getelementptr inbounds %struct.x264_t, %struct.x264_t* %h, i64 0, i32 52, i64 0, i32 17, i64 2
  %arrayidx485.2 = getelementptr inbounds %struct.x264_t, %struct.x264_t* %h, i64 0, i32 35, i64 2
  br label %for.body.467.2

for.body.467.2:                                   ; preds = %for.body.467.2, %for.cond.cleanup.466.1
  %indvars.iv1761.2 = phi i64 [ 0, %for.cond.cleanup.466.1 ], [ %indvars.iv.next1762.2, %for.body.467.2 ]
  %arrayidx471.2 = getelementptr inbounds [6 x [16 x i32]], [6 x [16 x i32]]* %def_dequant4, i64 0, i64 %indvars.iv1767, i64 %indvars.iv1761.2
  %14 = load i32, i32* %arrayidx471.2, align 4, !tbaa !0
  %15 = load i8*, i8** %arrayidx477.2, align 8, !tbaa !4
  %arrayidx478.2 = getelementptr inbounds i8, i8* %15, i64 %indvars.iv1761.2
  %16 = load i8, i8* %arrayidx478.2, align 1, !tbaa !6
  %conv479.2 = zext i8 %16 to i32
  %mul480.2 = mul nsw i32 %conv479.2, %14
  %17 = load [16 x i32]*, [16 x i32]** %arrayidx485.2, align 8, !tbaa !4
  %arrayidx487.2 = getelementptr inbounds [16 x i32], [16 x i32]* %17, i64 %indvars.iv1767, i64 %indvars.iv1761.2
  store i32 %mul480.2, i32* %arrayidx487.2, align 4, !tbaa !0
  %arrayidx491.2 = getelementptr inbounds [6 x [16 x i32]], [6 x [16 x i32]]* %def_quant4, i64 0, i64 %indvars.iv1767, i64 %indvars.iv1761.2
  %18 = load i32, i32* %arrayidx491.2, align 4, !tbaa !0
  %mul492.2 = shl i32 %18, 4
  %19 = load i8*, i8** %arrayidx477.2, align 8, !tbaa !4
  %arrayidx499.2 = getelementptr inbounds i8, i8* %19, i64 %indvars.iv1761.2
  %20 = load i8, i8* %arrayidx499.2, align 1, !tbaa !6
  %conv500.2 = zext i8 %20 to i32
  %shr501.1594.2 = lshr i32 %conv500.2, 1
  %add502.2 = add nsw i32 %shr501.1594.2, %mul492.2
  %div.2 = sdiv i32 %add502.2, %conv500.2
  %arrayidx516.2 = getelementptr inbounds [4 x [6 x [16 x i32]]], [4 x [6 x [16 x i32]]]* %quant4_mf, i64 0, i64 2, i64 %indvars.iv1767, i64 %indvars.iv1761.2
  store i32 %div.2, i32* %arrayidx516.2, align 4, !tbaa !0
  %indvars.iv.next1762.2 = add nuw nsw i64 %indvars.iv1761.2, 1
  %exitcond1763.2 = icmp eq i64 %indvars.iv.next1762.2, 16
  br i1 %exitcond1763.2, label %for.cond.cleanup.466.2, label %for.body.467.2

for.cond.cleanup.466.2:                           ; preds = %for.body.467.2
  %arrayidx477.3 = getelementptr inbounds %struct.x264_t, %struct.x264_t* %h, i64 0, i32 52, i64 0, i32 17, i64 3
  %arrayidx485.3 = getelementptr inbounds %struct.x264_t, %struct.x264_t* %h, i64 0, i32 35, i64 3
  br label %for.body.467.3

for.body.467.3:                                   ; preds = %for.body.467.3, %for.cond.cleanup.466.2
  %indvars.iv1761.3 = phi i64 [ 0, %for.cond.cleanup.466.2 ], [ %indvars.iv.next1762.3, %for.body.467.3 ]
  %arrayidx471.3 = getelementptr inbounds [6 x [16 x i32]], [6 x [16 x i32]]* %def_dequant4, i64 0, i64 %indvars.iv1767, i64 %indvars.iv1761.3
  %21 = load i32, i32* %arrayidx471.3, align 4, !tbaa !0
  %22 = load i8*, i8** %arrayidx477.3, align 8, !tbaa !4
  %arrayidx478.3 = getelementptr inbounds i8, i8* %22, i64 %indvars.iv1761.3
  %23 = load i8, i8* %arrayidx478.3, align 1, !tbaa !6
  %conv479.3 = zext i8 %23 to i32
  %mul480.3 = mul nsw i32 %conv479.3, %21
  %24 = load [16 x i32]*, [16 x i32]** %arrayidx485.3, align 8, !tbaa !4
  %arrayidx487.3 = getelementptr inbounds [16 x i32], [16 x i32]* %24, i64 %indvars.iv1767, i64 %indvars.iv1761.3
  store i32 %mul480.3, i32* %arrayidx487.3, align 4, !tbaa !0
  %arrayidx491.3 = getelementptr inbounds [6 x [16 x i32]], [6 x [16 x i32]]* %def_quant4, i64 0, i64 %indvars.iv1767, i64 %indvars.iv1761.3
  %25 = load i32, i32* %arrayidx491.3, align 4, !tbaa !0
  %mul492.3 = shl i32 %25, 4
  %26 = load i8*, i8** %arrayidx477.3, align 8, !tbaa !4
  %arrayidx499.3 = getelementptr inbounds i8, i8* %26, i64 %indvars.iv1761.3
  %27 = load i8, i8* %arrayidx499.3, align 1, !tbaa !6
  %conv500.3 = zext i8 %27 to i32
  %shr501.1594.3 = lshr i32 %conv500.3, 1
  %add502.3 = add nsw i32 %shr501.1594.3, %mul492.3
  %div.3 = sdiv i32 %add502.3, %conv500.3
  %arrayidx516.3 = getelementptr inbounds [4 x [6 x [16 x i32]]], [4 x [6 x [16 x i32]]]* %quant4_mf, i64 0, i64 3, i64 %indvars.iv1767, i64 %indvars.iv1761.3
  store i32 %div.3, i32* %arrayidx516.3, align 4, !tbaa !0
  %indvars.iv.next1762.3 = add nuw nsw i64 %indvars.iv1761.3, 1
  %exitcond1763.3 = icmp eq i64 %indvars.iv.next1762.3, 16
  br i1 %exitcond1763.3, label %for.cond.cleanup.466.3, label %for.body.467.3

for.cond.cleanup.466.3:                           ; preds = %for.body.467.3
  %indvars.iv.next1768 = add nuw nsw i64 %indvars.iv1767, 1
  %exitcond1769 = icmp eq i64 %indvars.iv.next1768, 6
  br i1 %exitcond1769, label %for.cond.603.preheader.loopexit.exitStub, label %for.cond.463.preheader
}

attributes #0 = { nounwind "polyjit-global-count"="0" "polyjit-jit-candidate" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !5, i64 0}
!5 = !{!"any pointer", !2, i64 0}
!6 = !{!2, !2, i64 0}
