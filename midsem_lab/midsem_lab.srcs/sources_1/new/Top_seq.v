module Top_seq(
    input Clk_100M,          
    input clear,             
    input input_0,           
    output [7:0] out         
);
    
    wire Clk_20k;
    wire input_pulse;

    // Use clk_div to generate 20 kHz clock from 100 MHz
    clk_div #(.div_value(4999)) clk_div_inst (
        .clk(Clk_100M), 
        .reset(clear),          
        .clk_out(Clk_20k)
    );
    
    // Instantiate input pulse generator
    input_pulse input_pulse_inst (
        .Clk_200H(Clk_20k), 
        .inp(input_0),        
        .input_pulse(input_pulse)  
    );
    
    // Instantiate the FSM for counting sequence (0, 20, 10)
    fsm_11011 fsm_inst (
        .clk(input_pulse),       
        .reset(clear),           
        .out(out)                
    );

endmodule
