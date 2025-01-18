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

module pulse_tb();

    reg Clk_200H;           // Base clock signal (200 Hz)
    reg inp_0;              // Single input
    wire input_pulse;       // Output pulse

    // Instantiate the input_pulse module
    input_pulse tb0(
        .Clk_200H(Clk_200H), 
        .inp(inp_0),         // Use single input
        .input_pulse(input_pulse) // Output pulse
    );
                    
    // Initialize signals
    initial begin
        Clk_200H = 1'b0;     // Initialize clock
        inp_0 = 1'b0;        // Start with input low
    end
    
    // Generate test input signals
    initial begin
        #2.4 inp_0 = 1'b1;   // Set input high
        #0.5 inp_0 = 1'b0;   // Set input low
        #0.5 inp_0 = 1'b1;   // Set input high
        #0.5 inp_0 = 1'b0;   // Set input low
        #0.5 inp_0 = 1'b1;   // Set input high
        #0.5 inp_0 = 1'b0;   // Set input low
        
        // Additional pulse testing
        @(posedge Clk_200H) inp_0 = 1'b1;
        @(posedge Clk_200H) inp_0 = 1'b1;
        @(negedge Clk_200H) inp_0 = 1'b0; // Change input on negative edge
        @(posedge Clk_200H) inp_0 = 1'b1; // Set input high again
        
        #0.5 inp_0 = 1'b0;  // Set input low
        #0.5 inp_0 = 1'b1;  // Set input high
        #0.5 inp_0 = 1'b0;  // Set input low
        
        #100 $finish;        // End simulation
    end
    
    // Generate clock signal
    always #2.5 Clk_200H = ~Clk_200H;  // Toggles every 2.5 time units to simulate 200 Hz clock
                       
endmodule
