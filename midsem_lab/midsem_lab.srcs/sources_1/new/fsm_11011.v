module fsm_11011 (
    input clk,
    input reset,
    output reg [7:0] out,  
    output reg [1:0] current_state // Expose current state for testing
);

    parameter S0 = 2'b00;  
    parameter S1 = 2'b01;  
    parameter S2 = 2'b10;  
    
    reg [1:0] present_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            present_state <= S0; 
        end else begin
            present_state <= next_state; 
        end
        current_state = present_state;  // Expose present state as current_state
    end

    always @(*) begin
        case (present_state)
            S0: begin
                out = 8'b00000000; 
                next_state = S1; 
            end
            S1: begin
                out = 8'b00010100; 
                next_state = S2; 
            end
            S2: begin
                out = 8'b00001010; 
                next_state = S0; 
            end
            default: begin
                out = 8'b00000000; 
                next_state = S0; 
            end
        endcase
    end
endmodule
