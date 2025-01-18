set_property SRC_FILE_INFO {cfile:C:/Users/aniru/Desktop/ELD/midsemLAB/midsemLAB.srcs/constrs_1/new/zybo.xdc rfile:../../../midsemLAB.srcs/constrs_1/new/zybo.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:8 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { Clk_100M }]; #IO_L12P_T1_MRCC_35 Sch=sysclk
set_property src_info {type:XDC file:1 line:9 export:INPUT save:INPUT read:READ} [current_design]
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { Clk_100M }];
