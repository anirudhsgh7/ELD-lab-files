`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2024 22:15:46
// Design Name: 
// Module Name: Top_arith
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top_arith(
    input Clk_100M,
    input [31:0] S_data,
    input S_valid,
    output S_ready,
    output [31:0] M_data,
    output M_valid,
    input M_ready
    );

    wire int_valid, int_ready;
    wire [31:0] int_data;

    FP_log l1 (
        .aclk(Clk_100M),                  // input wire aclk
        .s_axis_a_tvalid(S_valid),        // input wire s_axis_a_tvalid
        .s_axis_a_tready(S_ready),        // output wire s_axis_a_tready
        .s_axis_a_tdata(S_data),          // input wire [31 : 0] s_axis_a_tdata
        .m_axis_result_tvalid(int_valid), // output wire m_axis_result_tvalid
        .m_axis_result_tready(int_ready), // input wire m_axis_result_tready
        .m_axis_result_tdata(int_data)    // output wire [31 : 0] m_axis_result_tdata
    );

    FP_recip r1 (
        .aclk(Clk_100M),                  // input wire aclk
        .s_axis_a_tvalid(int_valid),      // input wire s_axis_a_tvalid
        .s_axis_a_tready(int_ready),      // output wire s_axis_a_tready
        .s_axis_a_tdata(int_data),        // input wire [31 : 0] s_axis_a_tdata
        .m_axis_result_tvalid(M_valid),   // output wire m_axis_result_tvalid
        .m_axis_result_tready(M_ready),   // input wire m_axis_result_tready
        .m_axis_result_tdata(M_data)      // output wire [31 : 0] m_axis_result_tdata
    );

endmodule