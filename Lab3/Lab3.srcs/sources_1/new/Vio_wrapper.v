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


module Vio_wrapper(
    input Clk_100M
    );
    wire [7:0] Count;
    wire reset;
    Top_Count t1(.Clk_100M(Clk_100M), .reset(reset),.Count(Count));
    vio_0 v1 (
  .clk(Clk_100M),               
  .probe_in0(Count), 
  .probe_out0(reset)  
);

endmodule
