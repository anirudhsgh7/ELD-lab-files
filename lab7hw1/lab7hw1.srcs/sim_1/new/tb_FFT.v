`timescale 1ns / 1ps

module tb_fft();
    
    reg Clk_100M, aresetn;
    reg [7:0] c_data;
    reg c_valid;
    wire c_ready;
    reg [63:0] ffti_data;
    reg ffti_valid;
    wire ffti_ready;
    reg ffti_last;
    reg ffto_ready;
    wire ffto_valid, ffto_last;
    wire [63:0] ffto_data;
    wire event_frame_started, event_tlast_unexpected, event_tlast_missing;
    wire event_status_channel_halt;
    wire event_data_in_channel_halt;
    wire event_data_out_channel_halt;
    
    // Initializing signals
    initial begin
        Clk_100M = 0;
        aresetn = 0;
        c_valid = 0;
        ffti_last = 0;
        ffti_valid = 0;
        ffto_ready = 0;
        c_data = 0;
        ffti_data = 0;
    end

    // Clock generation
    always
    #5 Clk_100M = ~Clk_100M;
    
    // Reset and config signal initialization
    initial begin
        #50 aresetn = 1;
        #20 c_data = 1;
        c_valid = 1;
        
        while (c_ready == 0)
            #2 c_valid = 1;
            
        #10 c_valid = 0;
    end
    
    reg [31:0] inp_data_r [31:0];
    reg [31:0] inp_data_im [31:0];
    
    // Initializing input data
    initial begin
        inp_data_r[0] = 32'h3f800000;
        inp_data_r[1] = 32'h0;
        inp_data_r[2] = 32'h0;
        inp_data_r[3] = 32'h0;
        inp_data_r[4] = 32'h0;
        inp_data_r[5] = 32'h0;
        inp_data_r[6] = 32'h0;
        inp_data_r[7] = 32'h0;
        inp_data_r[8] = 32'h0;
        inp_data_r[9] = 32'h0;
        inp_data_r[10] = 32'h0;
        inp_data_r[11] = 32'h0;
        inp_data_r[12] = 32'h0;
        inp_data_r[13] = 32'h0;
        inp_data_r[14] = 32'h0;
        inp_data_r[15] = 32'h0;
        inp_data_r[16] = 32'h0;
        inp_data_r[17] = 32'h0;
        inp_data_r[18] = 32'h0;
        inp_data_r[19] = 32'h0;
        inp_data_r[20] = 32'h0;
        inp_data_r[21] = 32'h0;
        inp_data_r[22] = 32'h0;
        inp_data_r[23] = 32'h0;
        inp_data_r[24] = 32'h0;
        inp_data_r[25] = 32'h0;
        inp_data_r[26] = 32'h0;
        inp_data_r[27] = 32'h0;
        inp_data_r[28] = 32'h0;
        inp_data_r[29] = 32'h0;
        inp_data_r[30] = 32'h0;
        inp_data_r[31] = 32'h0;
        
        inp_data_im[0] = 32'h0;
        inp_data_im[1] = 32'h0;
        inp_data_im[2] = 32'h0;
        inp_data_im[3] = 32'h0;
        inp_data_im[4] = 32'h0;
        inp_data_im[5] = 32'h0;
        inp_data_im[6] = 32'h0;
        inp_data_im[7] = 32'h0;
        inp_data_im[8] = 32'h0;
        inp_data_im[9] = 32'h0;
        inp_data_im[10] = 32'h0;
        inp_data_im[11] = 32'h0;
        inp_data_im[12] = 32'h0;
        inp_data_im[13] = 32'h0;
        inp_data_im[14] = 32'h0;
        inp_data_im[15] = 32'h0;
        inp_data_im[16] = 32'h0;
        inp_data_im[17] = 32'h0;
        inp_data_im[18] = 32'h0;
        inp_data_im[19] = 32'h0;
        inp_data_im[20] = 32'h0;
        inp_data_im[21] = 32'h0;
        inp_data_im[22] = 32'h0;
        inp_data_im[23] = 32'h0;
        inp_data_im[24] = 32'h0;
        inp_data_im[25] = 32'h0;
        inp_data_im[26] = 32'h0;
        inp_data_im[27] = 32'h0;
        inp_data_im[28] = 32'h0;
        inp_data_im[29] = 32'h0;
        inp_data_im[30] = 32'h0;
        inp_data_im[31] = 32'h0;
    end
    
    integer i;
    // Sending FFT input data
    initial begin
        #100 for(i = 31; i >= 0; i=i-1)
        begin
            if (i==0)
                ffti_last = 1;
                
            ffti_data = {inp_data_im[i], inp_data_r[i]};
            ffti_valid = 1;
            
            while (ffti_ready == 0)
                #2 ffti_valid = 1;
            #10 ffti_valid = 0;
            ffti_last = 0;
        end
    end
    
    reg [31:0] outp_data_r [31:0];
    reg [31:0] outp_data_im [31:0];
    integer j;
    
    // Receiving FFT output data
    initial begin
        ffto_ready = 1;
        for(j = 31; j >= 0; j=j-1)
        begin
            #5 ffto_ready = 1;
            wait (ffto_valid == 1);
            
            {outp_data_im[j], outp_data_r[j]} = ffto_data;
            
            #10 ffto_ready = 0;
        end
    end
    
    // Instantiate the top_wrapper
    top_wrapper top (
        .Clk_100M(Clk_100M),
        .aresetn(aresetn),
        .c_data(c_data),
        .c_valid(c_valid),
        .c_ready(c_ready),
        .ffti_data(ffti_data),
        .ffti_valid(ffti_valid),
        .ffti_ready(ffti_ready),
        .ffti_last(ffti_last),
        .ffto_ready(ffto_ready),
        .ffto_valid(ffto_valid),
        .ffto_last(ffto_last),
        .ffto_data(ffto_data),
        .event_frame_started(event_frame_started),
        .event_tlast_unexpected(event_tlast_unexpected),
        .event_tlast_missing(event_tlast_missing),
        .event_status_channel_halt(event_status_channel_halt),
        .event_data_in_channel_halt(event_data_in_channel_halt),
        .event_data_out_channel_halt(event_data_out_channel_halt)
    );
endmodule
