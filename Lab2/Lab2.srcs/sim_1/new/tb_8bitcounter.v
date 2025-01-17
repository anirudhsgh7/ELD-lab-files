`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2024 10:12:58
// Design Name: 
// Module Name: tb_8bitcounter
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


module tb_8bitcounter(
    );
    reg Clk_1Hz=0;
    reg reset=1;
    wire [6:0] Count;
    reg up =1;
    
    counter_8bit Cl(.Clk_1Hz(Clk_1Hz), .reset(reset), .Count(Count), .UP(up));   
    always
        #5 Clk_1Hz = ~ Clk_1Hz;        
    initial
    begin
        reset = 1;
        #100 reset = 0;
        #2000 $stop;
    end    
    always
        #960 up = ~up;       
endmodule
