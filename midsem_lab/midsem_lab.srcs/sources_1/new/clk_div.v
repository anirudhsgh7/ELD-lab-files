module clk_div
#(
    parameter div_value = 4999  // Adjusted for 100 MHz to 20 kHz
)
(
    input clk,
    input reset,              
    output reg clk_out = 0    
);

    reg [31:0] count_reg = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_reg <= 0;    
            clk_out <= 0;      
        end
        else begin
            if (count_reg == div_value) begin
                count_reg <= 0;    
                clk_out <= ~clk_out; 
            end
            else begin
                count_reg <= count_reg + 1; 
            end
        end
    end

endmodule
