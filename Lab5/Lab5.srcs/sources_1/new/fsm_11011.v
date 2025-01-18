`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2024 10:03:29
// Design Name: 
// Module Name: fsm_11011
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fsm_11011(

    input input_pulse,
    input clear,
    input inp_1,
    output reg out=0,
    output reg [2:0] present_state
    );

    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100;
 
    reg [2:0] next_state;    
    always@(posedge input_pulse or posedge clear)
    begin
        if (clear==1'b1)
            present_state <= S0;
        else
            present_state <= next_state;
    end
    
    always@(*) begin
        next_state=present_state;
        case(present_state)
            S0: if(inp_1 == 1'b1)
                    next_state = S1;
                else
                    next_state = S0;
            S1: if(inp_1 == 1'b1)
                    next_state = S2;
                else
                    next_state = S0;
            S2: if(inp_1 == 1'b0)
                    next_state = S3;
                else
                    next_state = S2;
            S3: if(inp_1 == 1'b1)
                    next_state = S4;
                else
                    next_state = S0;
            S4: if(inp_1 == 1'b1)
                    next_state = S4;
                else
                    next_state = S0;
            default: next_state = S0;
        endcase
    end
    
    always@(posedge input_pulse) begin
        if(present_state == S4 && inp_1 == 1'b1)
            out <= 1;
        else
            out <= 0;
    end

endmodule
