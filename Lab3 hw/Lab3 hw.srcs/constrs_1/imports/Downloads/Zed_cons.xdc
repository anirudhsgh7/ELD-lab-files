## Clock
set_property PACKAGE_PIN A10 [get_ports Clk_100M]    # Connect to 100 MHz clock
set_property IOSTANDARD LVCMOS33 [get_ports Clk_100M]

## Counter Outputs
set_property PACKAGE_PIN C6 [get_ports Count[0]]     # Count[0]
set_property PACKAGE_PIN C5 [get_ports Count[1]]     # Count[1]
set_property PACKAGE_PIN C4 [get_ports Count[2]]     # Count[2]
set_property PACKAGE_PIN C3 [get_ports Count[3]]     # Count[3]
set_property PACKAGE_PIN C2 [get_ports Count[4]]     # Count[4]
set_property PACKAGE_PIN B2 [get_ports Count[5]]     # Count[5]
set_property PACKAGE_PIN A2 [get_ports Count[6]]     # Count[6]

## Control Signals
set_property PACKAGE_PIN D7 [get_ports UP]           # UP signal
set_property IOSTANDARD LVCMOS33 [get_ports UP]

set_property PACKAGE_PIN D8 [get_ports reset]        # reset signal
set_property IOSTANDARD LVCMOS33 [get_ports reset]

