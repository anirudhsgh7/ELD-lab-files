`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2024 10:12:25
// Design Name: 
// Module Name: pulse_tb
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


module pulse_tb(

    );

    reg Clk_200H, inp_0, inp_1;
    wire input_pulse, FF1_reg, FF2_reg, FF3_reg;
    
    input_pulse tb0(.Clk_200H(Clk_200H), .inp_0(inp_0), .inp_1(inp_1),
                    .FF1_reg(FF1_reg), .FF2_reg(FF2_reg), .FF3_reg(FF3_reg), .input_pulse(input_pulse));
                    
    initial
    begin
        Clk_200H = 1'b0;
        inp_0 = 1'b0;
        inp_1 = 1'b1;
    end
    
    initial
    begin
        #2.4 inp_1=1'b1;
        #0.5 inp_1=1'b0;
        #0.5 inp_1=1'b1;
        #0.5 inp_1=1'b0;
        #0.5 inp_1=1'b1;
        #0.5 inp_1=1'b0;
        #0.5 inp_1=1'b1;
        #0.5 inp_1=1'b0;
        
        @(posedge Clk_200H) inp_1=1'b1;
        @(posedge Clk_200H) inp_1=1'b1;
        @(posedge Clk_200H) inp_1=1'b1;
        @(negedge Clk_200H) inp_1=1'b0;
        @(posedge Clk_200H) inp_0=1'b1;
        
        #0.5 inp_0=1'b0;
        #0.5 inp_0=1'b1;
        #0.5 inp_0=1'b0;
        #0.5 inp_0=1'b1;
        #0.5 inp_0=1'b0;
        #0.5 inp_0=1'b1;
        #0.5 inp_0=1'b0;
        
        @(posedge Clk_200H) inp_0=1'b1;
        @(posedge Clk_200H) inp_0=1'b1;
        @(posedge Clk_200H) inp_0=1'b0;
        
        #100 $finish;
    end
    
    always #2.5 Clk_200H = ~Clk_200H;
                       
endmodule