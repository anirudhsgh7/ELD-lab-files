`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2024 09:51:24
// Design Name: 
// Module Name: Top_Count
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


module Top_Count(
    input Clk_100M,
    input reset,
    output [6:0] Count,
    input UP
    );
    wire Clk_8M, Clk_1Hz;
    clk_wiz_0 cd(.Clk_8M(Clk_8M),.Clk_100M(Clk_100M));      

    clk_div_rtl cd1(.Clk_8M(Clk_8M),.Clk_1Hz(Clk_1Hz));
    
    counter_8bit c1(.Clk_1Hz(Clk_1Hz),.reset(reset),.Count(Count),.UP(UP));

endmodule
