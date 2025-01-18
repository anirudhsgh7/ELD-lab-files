`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2024 09:35:37
// Design Name: 
// Module Name: clk_div
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


module clk_div
#(

    parameter div_value=124999 // div value [GivenFrequency (5MHz)/2*RequiredFrequency) - 1

//510-6/2200)-1-124999
)

(
    input clk,
    output reg clk_out

);

    reg [31:0] count_reg=0, count_next = 0;

    always@(posedge clk) begin
        if(count_next==div_value)
            count_reg <= 0;

    else
        count_reg <= count_next;
    end

    always @(*)
    begin
    count_next=count_reg + 1;
    end


    always@(posedge clk)
    begin

    if (count_next==div_value)
        clk_out<= -clk_out;
    else 
        clk_out <= clk_out;
    end    
endmodule
