# Physical Constraints Section
# located anywhere in the file, preferably before or after the timing constraints
# or stored in a separate constraint file


set_property PACKAGE_PIN AA20 [get_ports {rgmii_rxd[0]}]
set_property PACKAGE_PIN AA19 [get_ports {rgmii_rxd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[0]}]
set_property PACKAGE_PIN AB22 [get_ports {rgmii_rxd[2]}]
set_property PACKAGE_PIN AB18 [get_ports {rgmii_rxd[3]}]
set_property PACKAGE_PIN U17 [get_ports {rgmii_txd[3]}]
set_property PACKAGE_PIN U18 [get_ports {rgmii_txd[2]}]
set_property PACKAGE_PIN V17 [get_ports {rgmii_txd[1]}]
set_property PACKAGE_PIN T18 [get_ports {rgmii_txd[0]}]

set_property PACKAGE_PIN AB20 [get_ports rgmii_rxctrl]
set_property PACKAGE_PIN AA18 [get_ports rgmii_txclk]
set_property PACKAGE_PIN W17 [get_ports rgmii_txctrl]

set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property IOSTANDARD LVCMOS33 [get_ports rgmii_rxclk]
set_property PACKAGE_PIN Y18 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii_rxctrl]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii_txclk]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii_txctrl]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property PACKAGE_PIN L1 [get_ports rst_n]

set_property PACKAGE_PIN W19 [get_ports rgmii_rxclk]

set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]

