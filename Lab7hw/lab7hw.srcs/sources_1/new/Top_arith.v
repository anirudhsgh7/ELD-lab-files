`timescale 1ns / 1ps


module Top_arith(
    input Clk_100M,
    input [31:0] x_data,
    input x_valid,
    output x_ready,
    input [31:0] y_data,
    input y_valid,
    output y_ready,
    input [31:0] t_data,
    input t_valid,
    output t_ready,
    input [31:0] data2,
    input valid2,
    output ready2,
    output [31:0] M_data,
    output M_valid,
    input M_ready
);
    
    wire xy_res_valid, xy_res_ready;
    wire [31:0] xy_res_data;
    wire ln_t_valid, ln_t_ready;
    wire [31:0] ln_t_data;
    wire mult_res_valid, mult_res_ready;
    wire [31:0] mult_res_data;
    wire div_res_valid, div_res_ready;
    wire [31:0] div_res_data;
    wire sqrt_res_valid, sqrt_res_ready;
    wire [31:0] sqrt_res_data;
    
    // Step 1: Division (x / y)
    FP_div div_xy (
        .aclk(Clk_100M),                                  
        .s_axis_a_tvalid(x_valid),            
        .s_axis_a_tready(x_ready),            
        .s_axis_a_tdata(x_data),              
        .s_axis_b_tvalid(y_valid),            
        .s_axis_b_tready(y_ready),            
        .s_axis_b_tdata(y_data),              
        .m_axis_result_tvalid(xy_res_valid),  
        .m_axis_result_tready(xy_res_ready),  
        .m_axis_result_tdata(xy_res_data)    
    );

    // Step 2: Logarithm (ln(t))
    FP_log log_t (
        .aclk(Clk_100M),                                  
        .s_axis_a_tvalid(t_valid),            
        .s_axis_a_tready(t_ready),            
        .s_axis_a_tdata(t_data),              
        .m_axis_result_tvalid(ln_t_valid),  
        .m_axis_result_tready(ln_t_ready),  
        .m_axis_result_tdata(ln_t_data)    
    );

    // Step 3: Multiply (2 * ln(t))
    FP_mul mul (
        .aclk(Clk_100M),
        .s_axis_a_tvalid(ln_t_valid),
        .s_axis_a_tready(ln_t_ready),
        .s_axis_a_tdata(ln_t_data),
        .s_axis_b_tvalid(valid2), // Use valid2 signal to indicate data2 is valid
        .s_axis_b_tready(ready2), // Assuming ready2 is ready to receive data
        .s_axis_b_tdata(data2),    // This should be '2' represented in the appropriate format
        .m_axis_result_tvalid(mult_res_valid),
        .m_axis_result_tready(mult_res_ready),
        .m_axis_result_tdata(mult_res_data)
    );

    // Step 4: Divide (2 * ln(t) / y)
    FP_div div_ln_t (
        .aclk(Clk_100M),                                  
        .s_axis_a_tvalid(mult_res_valid),            
        .s_axis_a_tready(mult_res_ready),            
        .s_axis_a_tdata(mult_res_data),              
        .s_axis_b_tvalid(y_valid),            
        .s_axis_b_tready(y_ready),            
        .s_axis_b_tdata(y_data),              
        .m_axis_result_tvalid(div_res_valid),  
        .m_axis_result_tready(div_res_ready),  
        .m_axis_result_tdata(div_res_data)    
    );
    
    // Step 5: Square root (sqrt(2 * ln(t) / y))
    FP_root sqrt (
        .aclk(Clk_100M),                                  
        .s_axis_a_tvalid(div_res_valid),            
        .s_axis_a_tready(div_res_ready),            
        .s_axis_a_tdata(div_res_data),              
        .m_axis_result_tvalid(sqrt_res_valid),  
        .m_axis_result_tready(sqrt_res_ready),  
        .m_axis_result_tdata(sqrt_res_data)    
    );
    
    // Step 6: Addition (z = (x / y) + sqrt(2 * ln(t) / y))
    FP_add add (
        .aclk(Clk_100M),                                  
        .s_axis_a_tvalid(sqrt_res_valid),            
        .s_axis_a_tready(sqrt_res_ready),            
        .s_axis_a_tdata(sqrt_res_data),              
        .s_axis_b_tvalid(xy_res_valid),            
        .s_axis_b_tready(xy_res_ready),            
        .s_axis_b_tdata(xy_res_data),              
        .m_axis_result_tvalid(M_valid),  
        .m_axis_result_tready(M_ready),  
        .m_axis_result_tdata(M_data)    
    );

endmodule