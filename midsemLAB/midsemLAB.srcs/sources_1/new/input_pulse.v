module input_pulse(
    input Clk_200H, 
    input inp,        // Single input
    output reg input_pulse // Declare input_pulse as reg
);

    reg prev_inp; // Previous state of the input

    always @(posedge Clk_200H) begin
        // Detect rising edge of the input
        if (inp && !prev_inp) begin
            input_pulse <= 1'b1; // Generate pulse on rising edge
        end else begin
            input_pulse <= 1'b0;  // Reset pulse
        end

        // Update previous state of the input
        prev_inp <= inp;
    end
endmodule
