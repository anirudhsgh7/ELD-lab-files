// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Wed Sep 11 10:49:55 2024
// Host        : DESKTOP-UKD76RS running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {C:/Users/aniru/Desktop/ELD/Lab3 hw/Lab3
//               hw.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v}
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(Clk_8M, Clk_100M)
/* synthesis syn_black_box black_box_pad_pin="Clk_8M,Clk_100M" */;
  output Clk_8M;
  input Clk_100M;
endmodule
