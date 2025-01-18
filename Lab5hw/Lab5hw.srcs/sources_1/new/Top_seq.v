`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2024 09:22:26
// Design Name: 
// Module Name: Top_seq
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


module Top_seq(
    input Clk_100M,
    input clear,
    input input_1,
    input input_0,
    output out,
    output [2:0] present_state
    );
    
    wire Clk_5M, Clk_200H;
    wire input_pulse;
  clk_wiz_0 Clk_in0
   (
    // Clock out ports
    .clk_out1(Clk_5M),     // output clk_out1
   // Clock in ports
    .clk_in1(Clk_100M));      // input clk_in1    
    
    clk_div #(.div_value(12499)) in2(.clk(Clk_5M), .clk_out(Clk_200H));
    
    input_pulse in3(.Clk_200H(Clk_200H), .inp_0(input_0), .inp_1(input_1), .input_pulse(input_pulse));
    fsm_11011 in4(.input_pulse(input_pulse), .clear(clear), .inp_1(input_1), .out(out), .present_state(present_state));

endmodule
