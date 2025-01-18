`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2024 10:01:21
// Design Name: 
// Module Name: input_pulse
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


module input_pulse(
    input Clk_200H, 
    input inp_0, // To give input as 0 input inp_1, 
    input inp_1, // To give input as 1 output input_pulse
    output input_pulse
);

    reg Q = 0;
    reg D = 0;

    wire inp_pulse;

    assign inp_pulse = inp_0 | inp_1;

    always@(posedge Clk_200H) begin
        Q <= D;
       
    end

    always@(*) begin 
        D = inp_pulse;

    end
    assign input_pulse = Q;

endmodule
