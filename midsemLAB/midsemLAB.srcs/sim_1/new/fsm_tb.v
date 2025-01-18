module fsm_tb();

    reg clk;                 // Base clock signal (50 MHz)
    reg reset;              // Reset signal
    wire [7:0] out;         // Output from the FSM

    // Instantiate the FSM for counting sequence (0, 20, 10)
    fsm_11011 fsm(
        .clk(clk),             // Connect the base clock
        .reset(reset),         // Connect reset signal
        .out(out)             // Output count signal
    );

    // Initialize signals
    initial begin
        clk = 1'b0;           // Initialize clock
        reset = 1'b1;         // Start with reset active
        #10 reset = 1'b0;     // Release reset after 10 time units
    end

    // Generate base clock (50 MHz)
    always #5 clk = ~clk;    // Toggles every 5 time units

    // Monitor the output (count and state) during the simulation
    initial begin
        $monitor("Time = %0t, Count = %0d, State = %0b", $time, out, present_state);
        #1000 $finish;        // Run the simulation for enough time to observe the FSM behavior
    end

endmodule
