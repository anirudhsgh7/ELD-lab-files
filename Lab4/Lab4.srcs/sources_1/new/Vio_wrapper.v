`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2024 10:33:17
// Design Name: 
// Module Name: Vio_wrapper
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


module VIO_wrapper(
    input Clk_100M
    );
    wire [5:0] Sec_count, Min_count;
    
    wire reset;
    Top_Count t1(.Clk_100M(Clk_100M),.reset(reset),.Sec_count(Sec_count),.Min_count(Min_count));
  vio_0 v1 (
  .clk(Clk_100M),                // input wire clk
  .probe_in0(Sec_count),    // input wire [5 : 0] probe_in0
  .probe_in1(Min_count),    // input wire [5 : 0] probe_in1
  .probe_out0(reset)  // output wire [0 : 0] probe_out0
);

ila_0 ila1 (
	.clk(Clk_100M), // input wire clk


	.probe0(Sec_count), // input wire [5:0]  probe0  
	.probe1(Min_count) // input wire [5:0]  probe1
);
endmodule
