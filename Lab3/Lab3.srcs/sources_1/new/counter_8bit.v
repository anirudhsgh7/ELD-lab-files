`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2024 09:50:38
// Design Name: 
// Module Name: counter_8bit
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


module counter_8bit(
    input Clk_1Hz,
    input reset,
    output [6:0] Count,
    input UP
    );
    reg [6:0] PS, NS;
    always@(posedge Clk_1Hz or posedge reset)
    begin
        if (reset)
            PS <= 7'd0;
        else
            PS <= NS;
    end    
    always@(*)
    begin
        if (UP)
            if (PS==7'd85)
                NS=0;
            else
                NS= PS+7'd1;
        else
            if (PS==7'd0)
                NS=7'd85;
            else
                NS=PS-7'd1;
    end
    
    assign Count = PS;
   
    
endmodule
