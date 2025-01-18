module fsm_11011 (
    input clk,
    input reset,
    output reg [7:0] out  // 8-bit output
);

    // Define states using parameters
    parameter S0 = 2'b00;  // State for output 0
    parameter S1 = 2'b01;  // State for output 20
    parameter S2 = 2'b10;  // State for output 10
    
    // State registers
    reg [1:0] present_state, next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            present_state <= S0; // Reset to initial state
        end else begin
            present_state <= next_state; // Move to next state
        end
    end

    // Next state logic
    always @(*) begin
        case (present_state)
            S0: begin
                out = 8'b00000000; // Output 0
                next_state = S1; // Move to next state
            end
            S1: begin
                out = 8'b00010100; // Output 20
                next_state = S2; // Move to next state
            end
            S2: begin
                out = 8'b00001010; // Output 10
                next_state = S0; // Loop back to initial state
            end
            default: begin
                out = 8'b00000000; // Default output
                next_state = S0; // Default next state
            end
        endcase
    end
endmodule
