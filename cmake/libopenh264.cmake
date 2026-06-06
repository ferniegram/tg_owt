add_library(libopenh264 OBJECT EXCLUDE_FROM_ALL)
init_target(libopenh264)
add_library(tg_owt::libopenh264 ALIAS libopenh264)

set(openh264_loc ${third_party_loc}/openh264)

execute_process(
    COMMAND sh codec/common/generate_version.sh ${openh264_loc}
    WORKING_DIRECTORY ${openh264_loc}
)

set(COMMON_SRCS
    codec/common/src/common_tables.cpp
    codec/common/src/copy_mb.cpp
    codec/common/src/cpu.cpp
    codec/common/src/crt_util_safe_x.cpp
    codec/common/src/deblocking_common.cpp
    codec/common/src/expand_pic.cpp
    codec/common/src/intra_pred_common.cpp
    codec/common/src/mc.cpp
    codec/common/src/memory_align.cpp
    codec/common/src/sad_common.cpp
    codec/common/src/utils.cpp
    codec/common/src/welsCodecTrace.cpp
    codec/common/src/WelsTaskThread.cpp
    codec/common/src/WelsThread.cpp
    codec/common/src/WelsThreadLib.cpp
    codec/common/src/WelsThreadPool.cpp
)

set(DECODER_SRCS
    codec/decoder/core/src/au_parser.cpp
    codec/decoder/core/src/bit_stream.cpp
    codec/decoder/core/src/cabac_decoder.cpp
    codec/decoder/core/src/deblocking.cpp
    codec/decoder/core/src/decode_mb_aux.cpp
    codec/decoder/core/src/decode_slice.cpp
    codec/decoder/core/src/decoder.cpp
    codec/decoder/core/src/decoder_core.cpp
    codec/decoder/core/src/decoder_data_tables.cpp
    codec/decoder/core/src/error_concealment.cpp
    codec/decoder/core/src/fmo.cpp
    codec/decoder/core/src/get_intra_predictor.cpp
    codec/decoder/core/src/manage_dec_ref.cpp
    codec/decoder/core/src/memmgr_nal_unit.cpp
    codec/decoder/core/src/mv_pred.cpp
    codec/decoder/core/src/parse_mb_syn_cabac.cpp
    codec/decoder/core/src/parse_mb_syn_cavlc.cpp
    codec/decoder/core/src/pic_queue.cpp
    codec/decoder/core/src/rec_mb.cpp
    codec/decoder/core/src/wels_decoder_thread.cpp
    codec/decoder/plus/src/welsDecoderExt.cpp
)

set(ENCODER_SRCS
    codec/encoder/core/src/au_set.cpp
    codec/encoder/core/src/deblocking.cpp
    codec/encoder/core/src/decode_mb_aux.cpp
    codec/encoder/core/src/encode_mb_aux.cpp
    codec/encoder/core/src/encoder.cpp
    codec/encoder/core/src/encoder_data_tables.cpp
    codec/encoder/core/src/encoder_ext.cpp
    codec/encoder/core/src/get_intra_predictor.cpp
    codec/encoder/core/src/md.cpp
    codec/encoder/core/src/mv_pred.cpp
    codec/encoder/core/src/nal_encap.cpp
    codec/encoder/core/src/paraset_strategy.cpp
    codec/encoder/core/src/picture_handle.cpp
    codec/encoder/core/src/ratectl.cpp
    codec/encoder/core/src/ref_list_mgr_svc.cpp
    codec/encoder/core/src/sample.cpp
    codec/encoder/core/src/set_mb_syn_cabac.cpp
    codec/encoder/core/src/set_mb_syn_cavlc.cpp
    codec/encoder/core/src/slice_multi_threading.cpp
    codec/encoder/core/src/svc_base_layer_md.cpp
    codec/encoder/core/src/svc_enc_slice_segment.cpp
    codec/encoder/core/src/svc_encode_mb.cpp
    codec/encoder/core/src/svc_encode_slice.cpp
    codec/encoder/core/src/svc_mode_decision.cpp
    codec/encoder/core/src/svc_motion_estimate.cpp
    codec/encoder/core/src/svc_set_mb_syn_cabac.cpp
    codec/encoder/core/src/svc_set_mb_syn_cavlc.cpp
    codec/encoder/core/src/wels_preprocess.cpp
    codec/encoder/core/src/wels_task_base.cpp
    codec/encoder/core/src/wels_task_encoder.cpp
    codec/encoder/core/src/wels_task_management.cpp
    codec/encoder/plus/src/welsEncoderExt.cpp
)

set(PROCESSING_SRCS
    codec/processing/src/adaptivequantization/AdaptiveQuantization.cpp
    codec/processing/src/backgrounddetection/BackgroundDetection.cpp
    codec/processing/src/common/memory.cpp
    codec/processing/src/common/WelsFrameWork.cpp
    codec/processing/src/common/WelsFrameWorkEx.cpp
    codec/processing/src/complexityanalysis/ComplexityAnalysis.cpp
    codec/processing/src/denoise/denoise.cpp
    codec/processing/src/denoise/denoise_filter.cpp
    codec/processing/src/downsample/downsample.cpp
    codec/processing/src/downsample/downsamplefuncs.cpp
    codec/processing/src/imagerotate/imagerotate.cpp
    codec/processing/src/imagerotate/imagerotatefuncs.cpp
    codec/processing/src/scenechangedetection/SceneChangeDetection.cpp
    codec/processing/src/scrolldetection/ScrollDetection.cpp
    codec/processing/src/scrolldetection/ScrollDetectionFuncs.cpp
    codec/processing/src/vaacalc/vaacalcfuncs.cpp
    codec/processing/src/vaacalc/vaacalculation.cpp
)

nice_target_sources(libopenh264 ${openh264_loc}
PRIVATE
    ${COMMON_SRCS}
    ${DECODER_SRCS}
    ${ENCODER_SRCS}
    ${PROCESSING_SRCS}
)

target_compile_definitions(libopenh264 
PRIVATE 
    HAVE_CONFIG_H
    GENERATED_VERSION_HEADER
    NDEBUG 
    USE_ASM
    # ARM
)

target_include_directories(libopenh264
PUBLIC
    $<BUILD_INTERFACE:${openh264_loc}/codec/api>
    $<INSTALL_INTERFACE:${webrtc_includedir}/third_party/openh264/codec/api>
PRIVATE
    ${openh264_loc}/codec/api/wels
    ${openh264_loc}/codec/common/inc
)


foreach(src ${DECODER_SRCS})
    set_property(SOURCE ${openh264_loc}/${src} APPEND_STRING PROPERTY COMPILE_FLAGS 
        " -I${openh264_loc}/codec/decoder/core/inc -I${openh264_loc}/codec/decoder/plus/inc"
    )
endforeach()

foreach(src ${ENCODER_SRCS})
    set_property(SOURCE ${openh264_loc}/${src} APPEND_STRING PROPERTY COMPILE_FLAGS 
        " -I${openh264_loc}/codec/encoder/core/inc -I${openh264_loc}/codec/encoder/plus/inc -I${openh264_loc}/codec/processing/interface"
    )
endforeach()

foreach(src ${PROCESSING_SRCS})
    set_property(SOURCE ${openh264_loc}/${src} APPEND_STRING PROPERTY COMPILE_FLAGS 
        " -I${openh264_loc}/codec/processing/interface -I${openh264_loc}/codec/processing/src/common -I${openh264_loc}/codec/processing/src/adaptivequantization -I${openh264_loc}/codec/processing/src/downsample -I${openh264_loc}/codec/processing/src/scrolldetection -I${openh264_loc}/codec/processing/src/vaacalc"
    )
endforeach()
