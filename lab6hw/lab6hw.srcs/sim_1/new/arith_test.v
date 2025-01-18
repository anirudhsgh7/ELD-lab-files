module arith_test;

    reg Clk_100M, S_valid, M_ready;
    reg [31:0] S_data, Y_data;
    wire M_valid, S_ready;
    wire [31:0] M_data;

    // Intermediate wires for debugging
    wire [31:0] log_data, sqrt_data, recip_ln_data, add_data;
    wire log_valid, sqrt_valid, recip_ln_valid, add_valid;

    Top_arith t1 (
        .Clk_100M(Clk_100M),
        .S_data(S_data),
        .Y_data(Y_data),       // y input for ln(y)
        .S_valid(S_valid),
        .S_ready(S_ready),
        .M_data(M_data),       // Final result including constant 1.5
        .M_valid(M_valid),     // Final result valid signal
        .M_ready(M_ready)
    );

    initial begin
        Clk_100M = 0;
        S_valid = 0;
        S_data = 0;
        Y_data = 0;
        M_ready = 1;  // Ready for output
    end

    always #5 Clk_100M = ~Clk_100M; // Clock generation

    initial begin
        S_data = 32'b01000000101000000000000000000000; // 5.0 in IEEE 754 (x input)
        Y_data = 32'b01000000010000000000000000000000; // 3.0 in IEEE 754 (y input)
        S_valid = 1; // Assert valid
        wait(S_ready); // Wait for S_ready
        #5 S_valid = 0; // De-assert valid after S_ready is high
        // Wait for final result with constant 1.5 added
        @(posedge M_valid);
        #10 $stop; // Stop the simulation
    end

endmodule
