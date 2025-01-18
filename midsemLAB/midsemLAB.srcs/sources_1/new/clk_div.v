module clk_div
#(
    parameter div_value = 1249  // Adjusted for 50 MHz to 20 kHz
)
(
    input clk,
    input reset,              // Reset signal
    output reg clk_out = 0    // Initialize clk_out
);

    reg [31:0] count_reg = 0;  // Counter for clock division

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_reg <= 0;      // Reset counter
            clk_out <= 0;        // Reset output clock
        end
        else begin
            if (count_reg == div_value) begin
                count_reg <= 0;     // Reset counter when limit is reached
                clk_out <= ~clk_out; // Toggle clock output
            end
            else begin
                count_reg <= count_reg + 1; // Increment counter
            end
        end
    end

endmodule
