`timescale 1ns / 1ps

module arith_test();

    reg M_ready, x_valid, y_valid, t_valid, valid2, Clk_100M;
    reg [31:0] x_data, y_data, t_data, data2;
    wire x_ready, y_ready, t_ready, ready2, M_valid;
    wire [31:0] M_data;
    
    Top_arith t1(
        .Clk_100M(Clk_100M),
        .x_data(x_data),
        .x_valid(x_valid),
        .x_ready(x_ready),
        .y_data(y_data),
        .y_valid(y_valid),
        .y_ready(y_ready),
        .t_data(t_data),
        .t_valid(t_valid),
        .data2(data2),
        .valid2(valid2),
        .ready2(ready2),
        .t_ready(t_ready),
        .M_data(M_data),
        .M_valid(M_valid),
        .M_ready(M_ready)
    );

    initial begin
        M_ready = 0;
        x_valid = 0;
        y_valid = 0;
        t_valid = 0;
        valid2 = 0;
        Clk_100M = 0;
        x_data = 0;
        y_data = 0;
        t_data = 0;
        data2 = 0;
    end
    
    always #5 Clk_100M = ~Clk_100M;
    
    initial begin
        #20 x_data = 32'b01000000000000000000000000000000; // x = 2.0
        x_valid = 1;
        M_ready = 1;

        while (x_ready == 0) x_valid = 1;
        
        #5 x_valid = 0;
        
        @(posedge M_valid);
        #5 M_ready = 0;
    end
    
    initial begin
        #20 y_data = 32'b01000000010000000000000000000000; // y = 3.0
        y_valid = 1;

        while (y_ready == 0) y_valid = 1;
        
        #5 y_valid = 0;
    end
    
    initial begin
        #20 t_data = 32'b01000000101000000000000000000000; // t = 5.0
        t_valid = 1;

        while (t_ready == 0) t_valid = 1;
        
        #5 t_valid = 0;
    end
    
    initial begin
        #20 data2 = 32'b01000000000000000000000000000000; 
        valid2 = 1;

        while (ready2 == 0) valid2 = 1;
        
        #5 valid2 = 0;
    end
    
endmodule