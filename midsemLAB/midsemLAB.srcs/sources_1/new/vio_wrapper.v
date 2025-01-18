`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2024 12:35:40
// Design Name: 
// Module Name: vio_wrapper
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

module vio_wrapper(
    input clk
);
    
    wire clear, inp_0, out;
    wire [1:0] present_state;  // Adjusted to match your FSM state representation
   
    vio_0 vio_in0 (
        .clk(clk),                // Input wire clk
        .probe_in0(out),         // Input wire for output count
        .probe_in1(present_state), // Input wire for current state
        .probe_out0(clear),      // Output wire for reset signal
        .probe_out1(inp_0)       // Output wire for input signal
    );

    Top_seq vin2(
        .Clk_100M(clk),          // Connect the 100 MHz clock
        .clear(clear),           // Connect reset signal
        .input_0(inp_0),         // Connect single input signal
        .out(out)                // Connect output from FSM
        // present_state is not needed here as Top_seq does not have it anymore
    );
    
endmodule
