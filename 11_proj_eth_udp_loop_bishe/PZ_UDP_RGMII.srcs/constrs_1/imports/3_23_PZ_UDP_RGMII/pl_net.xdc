create_clock -period 8.000 -name eth_rxc [get_ports net_rxc]

set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports sys_clk]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports sys_rst_n]

set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {eth_mdc }]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {eth_mdio}]

set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports net_rxc]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports net_rx_ctl]
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports {net_rxd[0]}]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports {net_rxd[1]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {net_rxd[2]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {net_rxd[3]}]

set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33} [get_ports net_txc]
set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33} [get_ports net_tx_ctl]
set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVCMOS33} [get_ports {net_txd[0]}]
set_property -dict {PACKAGE_PIN P20 IOSTANDARD LVCMOS33} [get_ports {net_txd[1]}]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS33} [get_ports {net_txd[2]}]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33} [get_ports {net_txd[3]}]


set_property SLEW FAST [get_ports net_txc]
set_property SLEW FAST [get_ports net_tx_ctl]
set_property SLEW FAST [get_ports {net_txd[*]}]

#  
#set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports sys_clk]
#set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports sysrstn]

set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports lvds_clk]
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports lvds_csl]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports lvds_data1]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports lvds_data2]
#set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports en]
#set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports en_n]
#set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports dat_update]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of_objects [get_ports lvds_clk]] 



