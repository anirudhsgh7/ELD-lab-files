module Top_arith(
    input Clk_100M,
    input [31:0] S_data,     // x input (float 32-bit)
    input [31:0] Y_data,     // y input (float 32-bit) for ln(y)
    input S_valid,
    output S_ready,
    output [31:0] M_data,    // z output (float 32-bit)
    output M_valid,
    input M_ready
    );

    wire int_valid, int_ready;
    wire [31:0] int_data;    // Output of ln(y)

    wire sqrt_valid, sqrt_ready;
    wire [31:0] sqrt_data;   // Output of sqrt(x)

    wire recip_ln_valid, recip_ln_ready;
    wire [31:0] recip_ln_data;  // Output of 1/ln(y)
    
    wire add_valid, add_ready;
    wire [31:0] add_data;   // Final result z

    // Step 1: Compute ln(y)
    FP_log l1 (
        .aclk(Clk_100M),
        .s_axis_a_tvalid(S_valid),
        .s_axis_a_tready(S_ready),
        .s_axis_a_tdata(Y_data),  // Use y input instead of x for ln(y)
        .m_axis_result_tvalid(int_valid),
        .m_axis_result_tready(int_ready),
        .m_axis_result_tdata(int_data)
    );

    // Step 2: Compute sqrt(x)
    FP_root sqrt1 (
        .aclk(Clk_100M),
        .s_axis_a_tvalid(S_valid),   // x as input
        .s_axis_a_tready(sqrt_ready),
        .s_axis_a_tdata(S_data),     // Use x for sqrt(x)
        .m_axis_result_tvalid(sqrt_valid),
        .m_axis_result_tready(M_ready),  // Chain to output
        .m_axis_result_tdata(sqrt_data)
    );

    // Step 3: Compute 1/ln(y)
    FP_recip r1 (
        .aclk(Clk_100M),
        .s_axis_a_tvalid(int_valid),  
        .s_axis_a_tready(int_ready),
        .s_axis_a_tdata(int_data),     // ln(y) as input
        .m_axis_result_tvalid(recip_ln_valid),
        .m_axis_result_tready(recip_ln_ready),
        .m_axis_result_tdata(recip_ln_data)
    );

    // Step 4: Add sqrt(x) + 1/ln(y) + 1.5
    FP_add a1 (
        .aclk(Clk_100M),
        .s_axis_a_tvalid(sqrt_valid),
        .s_axis_a_tdata(sqrt_data),    // sqrt(x) as input
        .s_axis_b_tvalid(recip_ln_valid),
        .s_axis_b_tdata(recip_ln_data), // 1/ln(y) as input
        .m_axis_result_tvalid(add_valid),
        .m_axis_result_tready(add_ready),
        .m_axis_result_tdata(add_data)
    );
    
    // Final result adder: add sqrt(x) + 1/ln(y) + 1.5
    wire final_valid;
    wire [31:0] final_data;

// Instantiate an FP_add to add the constant 1.5 to add_data
    FP_constAdd constant_add (
        .aclk(Clk_100M),
        .s_axis_a_tvalid(add_valid),         // 'add_data' is valid
        .s_axis_a_tdata(add_data),           // Output from previous addition (sqrt + 1/ln)
        .s_axis_b_tvalid(1'b1),              // Constant is always valid
        .s_axis_b_tdata(32'h3FC00000),       // IEEE-754 representation of 1.5
        .m_axis_result_tvalid(final_valid),  // Valid output for final addition
        .m_axis_result_tdata(final_data)     // Final result
    );

    // Assign the final output
    assign M_data = final_data;
    assign M_valid = final_valid;

endmodule
