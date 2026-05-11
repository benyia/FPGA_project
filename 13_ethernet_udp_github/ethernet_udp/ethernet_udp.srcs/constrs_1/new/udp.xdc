# Timing Assertions Section
# Primary clocks
# Virtual clocks
# Generated clocks
# Clock Groups
# Bus Skew constraints
# Input and output delay constraints
## Timing Exceptions Section
# False Paths
# Max Delay / Min Delay
# Multicycle Paths
# Case Analysis
# Disable Timing


create_clock -period 20.000 -waveform {0.000 10.000} [get_ports clk]

create_clock -period 8.000 -waveform {1.500 5.500} [get_ports rgmii_rxclk]

create_clock -period 8.000 -name rgmii_rxclk_vir -waveform {0.000 4.000}

#create_generated_clock -name rgmii_rxclkbufg -source [get_ports rgmii_rxclk] -multiply_by 1 [get_pins udp_rx_top/rgmii_to_gmii/rgmii_rxclkbufg]
create_generated_clock -name rgmii_rxclkbufg -source [get_ports rgmii_rxclk] -multiply_by 1 [get_nets -hierarchical *bufg*]

create_generated_clock -name rgmii_rxclkbufio -source [get_ports rgmii_rxclk] -multiply_by 1 [get_nets -hierarchical *bufio*]

set_input_delay -clock rgmii_rxclk_vir -max 0.000 [get_ports {rgmii_rxctrl {rgmii_rxd[0]} {rgmii_rxd[1]} {rgmii_rxd[2]} {rgmii_rxd[3]}}]

set_input_delay -clock rgmii_rxclk_vir -min 0.000 [get_ports {rgmii_rxctrl {rgmii_rxd[0]} {rgmii_rxd[1]} {rgmii_rxd[2]} {rgmii_rxd[3]}}]

set_input_delay -clock rgmii_rxclk_vir -clock_fall -max -add_delay 0.000 [get_ports {rgmii_rxctrl {rgmii_rxd[0]} {rgmii_rxd[1]} {rgmii_rxd[2]} {rgmii_rxd[3]}}]

set_input_delay -clock rgmii_rxclk_vir -clock_fall -min -add_delay 0.000 [get_ports {rgmii_rxctrl {rgmii_rxd[0]} {rgmii_rxd[1]} {rgmii_rxd[2]} {rgmii_rxd[3]}}]


set_false_path -setup -rise_from [get_clocks rgmii_rxclk_vir] -fall_to [get_clocks rgmii_rxclk]

set_false_path -setup -fall_from [get_clocks rgmii_rxclk_vir] -rise_to [get_clocks rgmii_rxclk]

set_false_path -hold -rise_from [get_clocks rgmii_rxclk_vir] -rise_to [get_clocks rgmii_rxclk]

set_false_path -hold -fall_from [get_clocks rgmii_rxclk_vir] -fall_to [get_clocks rgmii_rxclk]

#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[0]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[1]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[2]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[3]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[4]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[5]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[6]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[7]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[8]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[9]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[10]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[11]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[12]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[13]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[14]/C}]
#set_false_path -from [get_pins {udp_rx_top/udp_rx/udpnum_reg[15]/C}]





set_false_path -from [get_clocks rgmii_rxclkbufg] -to [get_clocks [get_clocks -of_objects [get_pins clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_125mhz]
