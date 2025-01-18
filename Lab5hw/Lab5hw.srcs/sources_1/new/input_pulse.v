module input_pulse(
    input Clk_200H, 
    input inp_0,    // Input 0
    input inp_1,    // Input 1
    output input_pulse  // Declare input_pulse as reg
);

    wire inp_or;
    reg FF1_reg, FF2_reg, FF3_reg;
    reg FF1_next, FF2_next, FF3_next;
    
    assign inp_or = inp_0 | inp_1;
    
    always @ (posedge Clk_200H)
    begin
        FF1_reg <= FF1_next;
        FF2_reg <= FF2_next;
        FF3_reg <= FF3_next;    
    end
    
    always @ (*)
        FF1_next = inp_or;
        
    always @ (*)
        FF2_next = FF1_reg;
        
    always @ (*)
        FF3_next = FF2_reg;
        
    assign input_pulse = FF1_reg & FF2_reg & ~FF3_reg;
    
endmodule
