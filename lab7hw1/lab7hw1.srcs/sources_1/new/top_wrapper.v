`timescale 1ns / 1ps

module top_wrapper(
    input Clk_100M,
    input aresetn,
    input [7:0] c_data,
    input c_valid,
    output c_ready,
    input [63:0] ffti_data,
    input ffti_valid,
    output ffti_ready,
    input ffti_last,
    input ffto_ready,
    output ffto_valid,
    output ffto_last,
    output [63:0] ffto_data,
    output event_frame_started,
    output event_tlast_unexpected,
    output event_tlast_missing,
    output event_status_channel_halt,
    output event_data_in_channel_halt,
    output event_data_out_channel_halt
);
    // Instantiate the FFT IP core
    FFT FFT_32 (
        .aclk(Clk_100M),                                                // input wire aclk
        .aresetn(aresetn),                                               // input wire aresetn
        .s_axis_config_tdata(c_data),                                    // input wire [7 : 0] s_axis_config_tdata
        .s_axis_config_tvalid(c_valid),                                  // input wire s_axis_config_tvalid
        .s_axis_config_tready(c_ready),                                  // output wire s_axis_config_tready
        .s_axis_data_tdata(ffti_data),                                   // input wire [63 : 0] s_axis_data_tdata
        .s_axis_data_tvalid(ffti_valid),                                 // input wire s_axis_data_tvalid
        .s_axis_data_tready(ffti_ready),                                 // output wire s_axis_data_tready
        .s_axis_data_tlast(ffti_last),                                   // input wire s_axis_data_tlast
        .m_axis_data_tdata(ffto_data),                                   // output wire [63 : 0] m_axis_data_tdata
        .m_axis_data_tvalid(ffto_valid),                                 // output wire m_axis_data_tvalid
        .m_axis_data_tready(ffto_ready),                                 // input wire m_axis_data_tready
        .m_axis_data_tlast(ffto_last),                                   // output wire m_axis_data_tlast
        .event_frame_started(event_frame_started),                       // output wire event_frame_started
        .event_tlast_unexpected(event_tlast_unexpected),                 // output wire event_tlast_unexpected
        .event_tlast_missing(event_tlast_missing),                       // output wire event_tlast_missing
        .event_status_channel_halt(event_status_channel_halt),           // output wire event_status_channel_halt
        .event_data_in_channel_halt(event_data_in_channel_halt),         // output wire event_data_in_channel_halt
        .event_data_out_channel_halt(event_data_out_channel_halt)        // output wire event_data_out_channel_halt
    );

endmodule
