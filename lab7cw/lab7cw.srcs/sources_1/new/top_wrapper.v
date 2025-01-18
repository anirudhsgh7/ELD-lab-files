module top_wrapper(
    input clock,
    input resetn,

    input [63:0] ffti_data,    // Input Data Stream (Complex)
    input ffti_valid,
    input ffti_last,
    output ffti_ready,

    input [7:0] c_data, // Config Data Stream
    input c_valid,
    output c_ready,

    output [63:0] ffto_data,  // Output Data Stream (Complex)
    output ffto_valid,
    output ffto_last,
    input ffto_ready
);

    // Internal Wires for FFT Module
    wire [63:0] data_fft;
    assign data_fft = ffti_data; // Direct pass for now

    wire [63:0] out_fft; // Output of FFT is 64-bit

    // FFT IP instantiation (Assuming your FFT module is defined elsewhere)
    FFT FFT_IP(
        .clock(clock),                    // input wire clock
        .resetn(resetn),                  // input wire resetn

        .s_axis_config_tdata(c_data),    // input wire [7 : 0] config_tdata
        .s_axis_config_tvalid(c_valid),   // input wire config_tvalid
        .s_axis_config_tready(c_ready),   // output wire config_tready

        .s_axis_data_tdata(data_fft),     // input wire [63 : 0] data_tdata
        .s_axis_data_tvalid(ffti_valid),  // input wire data_tvalid
        .s_axis_data_tready(ffti_ready),  // output wire data_tready
        .s_axis_data_tlast(ffti_last),    // input wire data_tlast

        .m_axis_data_tdata(out_fft),      // output wire [63 : 0] out_data_tdata
        .m_axis_data_tvalid(ffto_valid),   // output wire out_data_tvalid
        .m_axis_data_tready(ffto_ready),   // input wire out_data_tready
        .m_axis_data_tlast(ffto_last)      // output wire out_data_tlast
    );

    // Assign output data from FFT to output wires
    assign ffto_data = out_fft; // Pass FFT output

endmodule
