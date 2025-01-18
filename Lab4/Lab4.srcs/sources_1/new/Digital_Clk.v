`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2024 09:45:59
// Design Name: 
// Module Name: Digital_Clk
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


module Digital_Clk(
    input Clk_1Hz,
    input reset,
    output [5:0]Sec_count,
    output [5:0]Min_count
    );
    
    reg [5:0] Sec_count_reg= 6'd0;
    reg [5:0] Sec_count_next;
    
    always @(posedge Clk_1Hz or posedge reset)
    begin
        if(reset)
            Sec_count_reg <=6'd0;
        else
            Sec_count_reg <= Sec_count_next;
    end
    always @(*)
    begin
        if (Sec_count_reg == 6'd59)
            Sec_count_next =6'd0;
        else
            Sec_count_next=Sec_count_reg +1'd1;
    end
    
    reg [5:0] Min_count_next;
    reg [5:0] Min_count_reg = 6'd0;
    always @(posedge Clk_1Hz or posedge reset)
    begin
        if(reset)
            Min_count_reg <=6'd0;
        else
            Min_count_reg <=Min_count_next;
    end
    
    always@(*)
    begin
        if (Sec_count_reg ==6'd59)
            if (Min_count_reg == 6'd59)
                Min_count_next =6'd0;
            else
                Min_count_next = Min_count_reg +1'b1;
        else
            Min_count_next = Min_count_reg;
    end
    assign Sec_count=Sec_count_reg;
    assign Min_count=Min_count_reg;
    
endmodule