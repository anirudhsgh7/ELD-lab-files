`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2024 09:22:26
// Design Name: 
// Module Name: Top_seq
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

module Top_seq(
    input Clk_100M,          // Input clock (100 MHz)
    input clear,             // Reset signal
    input input_0,           // Single input signal
    output [7:0] out         // Output from FSM
);
    
    wire Clk_5M, Clk_200H;
    wire input_pulse;

    // Instantiate clock wizard to generate 5 MHz clock from 100 MHz
    clk_wiz_0 Clk_in0 (
        .clk_out1(Clk_5M),     // Output 5 MHz clock
        .clk_in1(Clk_100M)     // Input 100 MHz clock
    );  
    
    // Instantiate clock divider to generate 200 Hz clock from 5 MHz
    clk_div #(.div_value(12499)) clk_div_inst (
        .clk(Clk_5M), 
        .reset(clear),          // Connect the reset signal to the clock divider
        .clk_out(Clk_200H)
    );
    
    // Instantiate input pulse generator
    input_pulse input_pulse_inst (
        .Clk_200H(Clk_200H), 
        .inp(input_0),         // Use single input
        .input_pulse(input_pulse)  // Generate the input pulse
    );
    
    // Instantiate the FSM for counting sequence (0, 20, 10)
    fsm_11011 fsm_inst (
        .clk(input_pulse),       // Connect the input pulse to the FSM
        .reset(clear),           // Connect reset signal
        .out(out)                // Output count signal
    );

endmodule
