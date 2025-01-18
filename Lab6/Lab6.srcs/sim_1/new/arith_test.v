`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2024 22:22:09
// Design Name: 
// Module Name: arith_test
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


module arith_test(

    );
    
    reg Clk_100M, S_valid, M_ready;
    reg [31:0] S_data;
    wire M_valid, S_ready;
    wire [31:0] M_data;
    
    
Top_arith t1(
    .Clk_100M(Clk_100M),
    .S_data(S_data),
    .S_valid(S_valid),
    .S_ready(S_ready),
    .M_data(M_data),
    .M_valid(M_valid),
    .M_ready(M_ready)
    );
    
    initial begin
        Clk_100M=0;
        S_valid=0;
        S_data=0;
        M_ready=0;
    end
    
    always
        #5 Clk_100M= ~Clk_100M;
        
    initial begin
    S_data = 32'b01000000101000000000000000000000;
    S_valid = 1;
    while(S_ready == 0)
        S_valid = 1;
    #5 S_valid = 0;
    @(posedge M_valid);
    #10 $stop;
    end    
    
endmodule
