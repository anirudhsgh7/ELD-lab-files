module top_wrapper(
    input aclk,
    input aresetn,

    input [31:0] in_data,    // Input Data Stream
    input in_valid,
    input in_last,
    output in_ready,

    input [7:0] config_data, // Config Data Stream
    input config_valid,
    output config_ready,

    output [31:0] out_data,  // Output Data Stream
    output out_valid,
    output out_last,
    input out_ready
);

// Wires for internal connections
wire [63:0] data_fft;   // FFT IP takes 64-bit data, so padding the upper 32-bits with 0's.
assign data_fft[63:32] = 32'd0;
assign data_fft[31:0] = in_data; // Real Data from the Input Stream

wire [63:0] out_fft; // Output of FFT is 64-bit

// Additional event signals
wire event_frame_started,
     event_tlast_unexpected,
     event_tlast_missing,
     event_status_channel_halt,
     event_data_in_channel_halt,
     event_data_out_channel_halt;

// FFT IP instantiation
FFT FFT_IP(
    .aclk(aclk),                    // input wire aclk
    .aresetn(aresetn),              // input wire aresetn

    .s_axis_config_tdata(config_data),   // input wire [7 : 0] config_tdata
    .s_axis_config_tvalid(config_valid), // input wire config_tvalid
    .s_axis_config_tready(config_ready), // output wire config_tready

    .s_axis_data_tdata(data_fft),       // input wire [63 : 0] data_tdata
    .s_axis_data_tvalid(in_valid),      // input wire data_tvalid
    .s_axis_data_tready(in_ready),      // output wire data_tready
    .s_axis_data_tlast(in_last),        // input wire data_tlast

    .m_axis_data_tdata(out_fft),        // output wire [63 : 0] out_data_tdata
    .m_axis_data_tvalid(out_valid),     // output wire out_data_tvalid
    .m_axis_data_tready(out_ready),     // input wire out_data_tready
    .m_axis_data_tlast(out_last),       // output wire out_data_tlast

    .event_frame_started(event_frame_started),           // output wire event_frame_started
    .event_tlast_unexpected(event_tlast_unexpected),     // output wire event_tlast_unexpected
    .event_tlast_missing(event_tlast_missing),           // output wire event_tlast_missing
    .event_status_channel_halt(event_status_channel_halt), // output wire event_status_channel_halt
    .event_data_in_channel_halt(event_data_in_channel_halt), // output wire event_data_in_channel_halt
    .event_data_out_channel_halt(event_data_out_channel_halt) // output wire event_data_out_channel_halt
);

// Assign the output from the FFT to the lower 32 bits of the output data
assign out_data = out_fft[31:0]; // Last 32-bit being displayed, as real part is needed.

endmodule
