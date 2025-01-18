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
    output [5:0] Sec_count,
    output [5:0] Min_count
    );
    wire Clk_16M,Clk_1Hz;
     clk_wiz_0 cd//instance name
   (
    // Clock out ports
    .Clk_16M(Clk_16M),     // output Clk_8M
   // Clock in ports
    .Clk_100M(Clk_100M)); 
         // input Clk_100M
   
    clk_div_rtl cd1(
    .Clk_16M(Clk_16M),
    .Clk_1Hz(Clk_1Hz)
    );
    Digital_Clk(.Clk_1Hz(Clk_1Hz),.reset(reset),.Sec_count(Sec_count),.Min_count(Min_count));
    
   

 
   
endmodule