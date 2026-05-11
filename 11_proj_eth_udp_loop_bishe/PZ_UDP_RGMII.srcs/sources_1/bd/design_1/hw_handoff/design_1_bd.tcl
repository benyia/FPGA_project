
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# FIFO_trans, FIFO_write, g_net_rest_n, lvds_rx, lvds_simulate, net_udp_loop

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-2
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]


  # Create ports
  set en [ create_bd_port -dir O en ]
  set en_n [ create_bd_port -dir O en_n ]
  set eth_mdc [ create_bd_port -dir O eth_mdc ]
  set eth_mdio [ create_bd_port -dir IO eth_mdio ]
  set lvds_clk [ create_bd_port -dir I -type clk lvds_clk ]
  set lvds_csl [ create_bd_port -dir I lvds_csl ]
  set lvds_data1 [ create_bd_port -dir I lvds_data1 ]
  set lvds_data2 [ create_bd_port -dir I lvds_data2 ]
  set net_rx_ctl [ create_bd_port -dir I net_rx_ctl ]
  set net_rxc [ create_bd_port -dir I net_rxc ]
  set net_rxd [ create_bd_port -dir I -from 3 -to 0 net_rxd ]
  set net_tx_ctl [ create_bd_port -dir O net_tx_ctl ]
  set net_txc [ create_bd_port -dir O net_txc ]
  set net_txd [ create_bd_port -dir O -from 3 -to 0 net_txd ]
  set sys_clk [ create_bd_port -dir I -type clk -freq_hz 50000000 sys_clk ]
  set sys_rst_n [ create_bd_port -dir I -type rst sys_rst_n ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $sys_rst_n

  # Create instance: FIFO_trans_0, and set properties
  set block_name FIFO_trans
  set block_cell_name FIFO_trans_0
  if { [catch {set FIFO_trans_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $FIFO_trans_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: FIFO_write_0, and set properties
  set block_name FIFO_write
  set block_cell_name FIFO_write_0
  if { [catch {set FIFO_write_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $FIFO_write_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKIN1_JITTER_PS {200.0} \
   CONFIG.CLKOUT1_JITTER {129.923} \
   CONFIG.CLKOUT1_PHASE_ERROR {154.678} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {150} \
   CONFIG.CLKOUT2_JITTER {124.134} \
   CONFIG.CLKOUT2_PHASE_ERROR {154.678} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {163.696} \
   CONFIG.CLKOUT3_PHASE_ERROR {154.678} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {50.000} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_JITTER {139.128} \
   CONFIG.CLKOUT4_PHASE_ERROR {154.678} \
   CONFIG.CLKOUT4_USED {true} \
   CONFIG.CLKOUT5_JITTER {148.365} \
   CONFIG.CLKOUT5_PHASE_ERROR {154.678} \
   CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {75} \
   CONFIG.CLKOUT5_USED {true} \
   CONFIG.CLK_OUT1_PORT {clk_150M} \
   CONFIG.CLK_OUT2_PORT {clk_200M} \
   CONFIG.CLK_OUT3_PORT {clk_50M} \
   CONFIG.CLK_OUT4_PORT {clk_100M} \
   CONFIG.CLK_OUT5_PORT {clk_75M} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {24.000} \
   CONFIG.MMCM_CLKIN1_PERIOD {20.000} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {6} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {24} \
   CONFIG.MMCM_CLKOUT3_DIVIDE {12} \
   CONFIG.MMCM_CLKOUT4_DIVIDE {16} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {5} \
   CONFIG.PRIM_IN_FREQ {50.000} \
   CONFIG.RESET_PORT {resetn} \
   CONFIG.RESET_TYPE {ACTIVE_LOW} \
 ] $clk_wiz_0

  # Create instance: fifo_rx, and set properties
  set fifo_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_rx ]
  set_property -dict [ list \
   CONFIG.Almost_Full_Flag {false} \
   CONFIG.Data_Count {false} \
   CONFIG.Data_Count_Width {13} \
   CONFIG.Empty_Threshold_Assert_Value {2} \
   CONFIG.Empty_Threshold_Negate_Value {3} \
   CONFIG.Enable_Reset_Synchronization {true} \
   CONFIG.Enable_Safety_Circuit {false} \
   CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
   CONFIG.Full_Flags_Reset_Value {0} \
   CONFIG.Full_Threshold_Assert_Value {8189} \
   CONFIG.Full_Threshold_Negate_Value {8188} \
   CONFIG.INTERFACE_TYPE {Native} \
   CONFIG.Input_Data_Width {16} \
   CONFIG.Input_Depth {8192} \
   CONFIG.Output_Data_Width {16} \
   CONFIG.Output_Depth {8192} \
   CONFIG.Performance_Options {Standard_FIFO} \
   CONFIG.Read_Data_Count {true} \
   CONFIG.Read_Data_Count_Width {13} \
   CONFIG.Reset_Pin {false} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.Use_Dout_Reset {false} \
   CONFIG.Write_Data_Count {false} \
   CONFIG.Write_Data_Count_Width {13} \
 ] $fifo_rx

  # Create instance: g_net_rest_n_0, and set properties
  set block_name g_net_rest_n
  set block_cell_name g_net_rest_n_0
  if { [catch {set g_net_rest_n_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $g_net_rest_n_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0 ]
  set_property -dict [ list \
   CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
   CONFIG.C_DATA_DEPTH {4096} \
   CONFIG.C_ENABLE_ILA_AXI_MON {false} \
   CONFIG.C_EN_STRG_QUAL {1} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {12} \
   CONFIG.C_PROBE0_MU_CNT {2} \
   CONFIG.C_PROBE10_MU_CNT {2} \
   CONFIG.C_PROBE10_WIDTH {16} \
   CONFIG.C_PROBE11_MU_CNT {2} \
   CONFIG.C_PROBE1_MU_CNT {2} \
   CONFIG.C_PROBE2_MU_CNT {2} \
   CONFIG.C_PROBE3_MU_CNT {2} \
   CONFIG.C_PROBE4_MU_CNT {2} \
   CONFIG.C_PROBE4_WIDTH {16} \
   CONFIG.C_PROBE5_MU_CNT {2} \
   CONFIG.C_PROBE5_WIDTH {8} \
   CONFIG.C_PROBE6_MU_CNT {2} \
   CONFIG.C_PROBE6_WIDTH {1} \
   CONFIG.C_PROBE7_MU_CNT {2} \
   CONFIG.C_PROBE7_WIDTH {1} \
   CONFIG.C_PROBE8_MU_CNT {2} \
   CONFIG.C_PROBE8_WIDTH {16} \
   CONFIG.C_PROBE9_MU_CNT {2} \
   CONFIG.C_PROBE9_WIDTH {16} \
 ] $ila_0

  # Create instance: ila_FIFO_lvds, and set properties
  set ila_FIFO_lvds [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 ila_FIFO_lvds ]
  set_property -dict [ list \
   CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
   CONFIG.C_BRAM_CNT {6} \
   CONFIG.C_DATA_DEPTH {4096} \
   CONFIG.C_EN_STRG_QUAL {1} \
   CONFIG.C_MON_TYPE {NATIVE} \
   CONFIG.C_NUM_OF_PROBES {11} \
   CONFIG.C_PROBE0_MU_CNT {2} \
   CONFIG.C_PROBE10_MU_CNT {2} \
   CONFIG.C_PROBE11_MU_CNT {2} \
   CONFIG.C_PROBE12_MU_CNT {2} \
   CONFIG.C_PROBE1_MU_CNT {2} \
   CONFIG.C_PROBE1_WIDTH {16} \
   CONFIG.C_PROBE2_MU_CNT {2} \
   CONFIG.C_PROBE3_MU_CNT {2} \
   CONFIG.C_PROBE4_MU_CNT {2} \
   CONFIG.C_PROBE4_WIDTH {13} \
   CONFIG.C_PROBE5_MU_CNT {2} \
   CONFIG.C_PROBE5_WIDTH {1} \
   CONFIG.C_PROBE6_MU_CNT {2} \
   CONFIG.C_PROBE6_WIDTH {16} \
   CONFIG.C_PROBE7_MU_CNT {2} \
   CONFIG.C_PROBE8_MU_CNT {2} \
   CONFIG.C_PROBE9_MU_CNT {2} \
   CONFIG.C_PROBE_WIDTH_PROPAGATION {MANUAL} \
 ] $ila_FIFO_lvds

  # Create instance: lvds_rx_0, and set properties
  set block_name lvds_rx
  set block_cell_name lvds_rx_0
  if { [catch {set lvds_rx_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $lvds_rx_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.INSERT_VIP {0} \
 ] [get_bd_pins /lvds_rx_0/framenew_rst]

  # Create instance: lvds_simulate_0, and set properties
  set block_name lvds_simulate
  set block_cell_name lvds_simulate_0
  if { [catch {set lvds_simulate_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $lvds_simulate_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: net_udp_loop_0, and set properties
  set block_name net_udp_loop
  set block_cell_name net_udp_loop_0
  if { [catch {set net_udp_loop_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $net_udp_loop_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
   CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
   CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
   CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
   CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_CLK0_FREQ {10000000} \
   CONFIG.PCW_CLK1_FREQ {10000000} \
   CONFIG.PCW_CLK2_FREQ {10000000} \
   CONFIG.PCW_CLK3_FREQ {10000000} \
   CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
   CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
   CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
   CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
   CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
   CONFIG.PCW_ENET0_ENET0_IO {<Select>} \
   CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {0} \
   CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {External} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
   CONFIG.PCW_ENET0_RESET_ENABLE {0} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET1_RESET_ENABLE {0} \
   CONFIG.PCW_ENET_RESET_ENABLE {0} \
   CONFIG.PCW_EN_CLK0_PORT {0} \
   CONFIG.PCW_EN_EMIO_ENET0 {0} \
   CONFIG.PCW_EN_EMIO_UART0 {0} \
   CONFIG.PCW_EN_ENET0 {0} \
   CONFIG.PCW_EN_QSPI {1} \
   CONFIG.PCW_EN_RST0_PORT {0} \
   CONFIG.PCW_EN_SDIO0 {1} \
   CONFIG.PCW_EN_UART0 {1} \
   CONFIG.PCW_EN_UART1 {0} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK_CLK0_BUF {FALSE} \
   CONFIG.PCW_FPGA_FCLK0_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK1_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
   CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {25} \
   CONFIG.PCW_IOPLL_CTRL_FBDIV {54} \
   CONFIG.PCW_IO_IO_PLL_FREQMHZ {1800.000} \
   CONFIG.PCW_MIO_10_DIRECTION {in} \
   CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_10_PULLUP {enabled} \
   CONFIG.PCW_MIO_10_SLEW {slow} \
   CONFIG.PCW_MIO_11_DIRECTION {out} \
   CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_11_PULLUP {enabled} \
   CONFIG.PCW_MIO_11_SLEW {slow} \
   CONFIG.PCW_MIO_1_DIRECTION {out} \
   CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_1_PULLUP {enabled} \
   CONFIG.PCW_MIO_1_SLEW {slow} \
   CONFIG.PCW_MIO_2_DIRECTION {inout} \
   CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_2_PULLUP {disabled} \
   CONFIG.PCW_MIO_2_SLEW {slow} \
   CONFIG.PCW_MIO_3_DIRECTION {inout} \
   CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_3_PULLUP {disabled} \
   CONFIG.PCW_MIO_3_SLEW {slow} \
   CONFIG.PCW_MIO_40_DIRECTION {inout} \
   CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_40_PULLUP {enabled} \
   CONFIG.PCW_MIO_40_SLEW {slow} \
   CONFIG.PCW_MIO_41_DIRECTION {inout} \
   CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_41_PULLUP {enabled} \
   CONFIG.PCW_MIO_41_SLEW {slow} \
   CONFIG.PCW_MIO_42_DIRECTION {inout} \
   CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_42_PULLUP {enabled} \
   CONFIG.PCW_MIO_42_SLEW {slow} \
   CONFIG.PCW_MIO_43_DIRECTION {inout} \
   CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_43_PULLUP {enabled} \
   CONFIG.PCW_MIO_43_SLEW {slow} \
   CONFIG.PCW_MIO_44_DIRECTION {inout} \
   CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_44_PULLUP {enabled} \
   CONFIG.PCW_MIO_44_SLEW {slow} \
   CONFIG.PCW_MIO_45_DIRECTION {inout} \
   CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_45_PULLUP {enabled} \
   CONFIG.PCW_MIO_45_SLEW {slow} \
   CONFIG.PCW_MIO_48_DIRECTION {out} \
   CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_48_PULLUP {enabled} \
   CONFIG.PCW_MIO_48_SLEW {slow} \
   CONFIG.PCW_MIO_49_DIRECTION {in} \
   CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_49_PULLUP {enabled} \
   CONFIG.PCW_MIO_49_SLEW {slow} \
   CONFIG.PCW_MIO_4_DIRECTION {inout} \
   CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_4_PULLUP {disabled} \
   CONFIG.PCW_MIO_4_SLEW {slow} \
   CONFIG.PCW_MIO_5_DIRECTION {inout} \
   CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_5_PULLUP {disabled} \
   CONFIG.PCW_MIO_5_SLEW {slow} \
   CONFIG.PCW_MIO_6_DIRECTION {out} \
   CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_6_PULLUP {disabled} \
   CONFIG.PCW_MIO_6_SLEW {slow} \
   CONFIG.PCW_MIO_TREE_PERIPHERALS {unassigned#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#unassigned#unassigned#unassigned#UART 0#UART 0#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned} \
   CONFIG.PCW_MIO_TREE_SIGNALS {unassigned#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#unassigned#unassigned#unassigned#rx#tx#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#clk#cmd#data[0]#data[1]#data[2]#data[3]#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned} \
   CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
   CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
   CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {9} \
   CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
   CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} \
   CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
   CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {9} \
   CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
   CONFIG.PCW_SD0_GRP_CD_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
   CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
   CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {18} \
   CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
   CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} \
   CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_UART0_UART0_IO {MIO 10 .. 11} \
   CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_UART1_UART1_IO {<Select>} \
   CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {18} \
   CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
   CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
   CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
   CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
   CONFIG.PCW_UIPARAM_DDR_CL {7} \
   CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
   CONFIG.PCW_UIPARAM_DDR_CWL {6} \
   CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
   CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
   CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
   CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125} \
   CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
   CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
   CONFIG.PCW_UIPARAM_DDR_T_FAW {40.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RC {48.75} \
   CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
   CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
   CONFIG.PCW_USE_M_AXI_GP0 {0} \
 ] $processing_system7_0

  # Create instance: vio_0, and set properties
  set vio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_0 ]
  set_property -dict [ list \
   CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
   CONFIG.C_NUM_PROBE_IN {1} \
   CONFIG.C_NUM_PROBE_OUT {2} \
   CONFIG.C_PROBE_OUT0_INIT_VAL {0x045A} \
   CONFIG.C_PROBE_OUT0_WIDTH {16} \
   CONFIG.C_PROBE_OUT1_INIT_VAL {0000} \
 ] $vio_0

  # Create interface connections
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]

  # Create port connections
  connect_bd_net -net FIFO_trans_0_fifo_dout [get_bd_pins FIFO_trans_0/fifo_dout] [get_bd_pins net_udp_loop_0/fifo_din]
  connect_bd_net -net FIFO_trans_0_fifo_rd_en [get_bd_pins FIFO_trans_0/fifo_rd_en] [get_bd_pins fifo_rx/rd_en] [get_bd_pins ila_FIFO_lvds/probe7]
  connect_bd_net -net FIFO_trans_0_fifo_wr_en [get_bd_pins FIFO_trans_0/fifo_wr_en] [get_bd_pins net_udp_loop_0/fifo_wr_en]
  connect_bd_net -net FIFO_trans_0_tx_send_en [get_bd_pins FIFO_trans_0/tx_send_en] [get_bd_pins net_udp_loop_0/udp_send_start]
  connect_bd_net -net FIFO_write_0_fifo_clk [get_bd_pins FIFO_write_0/fifo_clk] [get_bd_pins fifo_rx/wr_clk] [get_bd_pins ila_FIFO_lvds/probe0]
  connect_bd_net -net FIFO_write_0_fifo_din [get_bd_pins FIFO_write_0/fifo_din] [get_bd_pins fifo_rx/din] [get_bd_pins ila_FIFO_lvds/probe1]
  connect_bd_net -net FIFO_write_0_fifo_wr_en [get_bd_pins FIFO_write_0/fifo_wr_en] [get_bd_pins fifo_rx/wr_en] [get_bd_pins ila_FIFO_lvds/probe2]
  connect_bd_net -net FIFO_write_0_rx_done [get_bd_pins FIFO_trans_0/newframe_rst_in] [get_bd_pins FIFO_write_0/rx_done_hp] [get_bd_pins ila_FIFO_lvds/probe3]
  connect_bd_net -net Net [get_bd_ports eth_mdio] [get_bd_pins net_udp_loop_0/eth_mdio]
  connect_bd_net -net clk_wiz_0_clk_100M [get_bd_pins clk_wiz_0/clk_100M] [get_bd_pins lvds_simulate_0/clk100M]
  connect_bd_net -net clk_wiz_0_clk_150M [get_bd_pins clk_wiz_0/clk_150M] [get_bd_pins ila_0/clk] [get_bd_pins ila_FIFO_lvds/clk] [get_bd_pins vio_0/clk]
  connect_bd_net -net clk_wiz_0_clk_200M [get_bd_pins clk_wiz_0/clk_200M] [get_bd_pins net_udp_loop_0/clk_200m]
  connect_bd_net -net clk_wiz_0_clk_50M [get_bd_pins clk_wiz_0/clk_50M] [get_bd_pins g_net_rest_n_0/clk] [get_bd_pins net_udp_loop_0/clk_50m]
  connect_bd_net -net clk_wiz_0_clk_75M [get_bd_pins clk_wiz_0/clk_75M] [get_bd_pins lvds_simulate_0/clk75M]
  connect_bd_net -net fifo_rx_dout [get_bd_pins FIFO_trans_0/fifo_din] [get_bd_pins fifo_rx/dout] [get_bd_pins ila_FIFO_lvds/probe6]
  connect_bd_net -net fifo_rx_empty [get_bd_pins FIFO_trans_0/fifo_in_empty] [get_bd_pins fifo_rx/empty] [get_bd_pins ila_FIFO_lvds/probe5]
  connect_bd_net -net fifo_rx_full [get_bd_pins fifo_rx/full] [get_bd_pins ila_FIFO_lvds/probe10]
  connect_bd_net -net fifo_rx_rd_data_count [get_bd_pins fifo_rx/rd_data_count] [get_bd_pins ila_FIFO_lvds/probe4]
  connect_bd_net -net lvds_clk_1 [get_bd_ports lvds_clk] [get_bd_pins lvds_simulate_0/lvds_clk_in]
  connect_bd_net -net lvds_csl_1 [get_bd_ports lvds_csl] [get_bd_pins lvds_simulate_0/lvds_csl_in]
  connect_bd_net -net lvds_data1_1 [get_bd_ports lvds_data1] [get_bd_pins lvds_simulate_0/lvds_data1_in]
  connect_bd_net -net lvds_data2_1 [get_bd_ports lvds_data2] [get_bd_pins lvds_simulate_0/lvds_data2_in]
  connect_bd_net -net lvds_rx_0_dat_rx [get_bd_pins FIFO_write_0/dat_rx] [get_bd_pins ila_0/probe4] [get_bd_pins lvds_rx_0/dat_rx]
  connect_bd_net -net lvds_rx_0_dat_update [get_bd_pins FIFO_write_0/dat_update] [get_bd_pins ila_0/probe11] [get_bd_pins lvds_rx_0/dat_update]
  connect_bd_net -net lvds_rx_0_debug_rst [get_bd_pins ila_0/probe2] [get_bd_pins lvds_rx_0/debug_rst]
  connect_bd_net -net lvds_rx_0_en [get_bd_ports en] [get_bd_pins lvds_rx_0/en]
  connect_bd_net -net lvds_rx_0_en_n [get_bd_ports en_n] [get_bd_pins lvds_rx_0/en_n]
  connect_bd_net -net lvds_rx_0_framenew_rst [get_bd_pins FIFO_trans_0/lvds_rst] [get_bd_pins FIFO_write_0/frame_rst_hp] [get_bd_pins ila_0/probe3] [get_bd_pins ila_FIFO_lvds/probe9] [get_bd_pins lvds_rx_0/framenew_rst]
  connect_bd_net -net lvds_rx_0_lineID [get_bd_pins ila_0/probe5] [get_bd_pins lvds_rx_0/lineID]
  connect_bd_net -net lvds_rx_0_x [get_bd_pins ila_0/probe8] [get_bd_pins lvds_rx_0/x]
  connect_bd_net -net lvds_rx_0_y [get_bd_pins ila_0/probe9] [get_bd_pins lvds_rx_0/y]
  connect_bd_net -net lvds_rx_0_z [get_bd_pins ila_0/probe10] [get_bd_pins lvds_rx_0/z]
  connect_bd_net -net lvds_simulate_0_lvds_clk_out [get_bd_pins FIFO_write_0/lvds_clk] [get_bd_pins ila_0/probe0] [get_bd_pins lvds_rx_0/lvds_clk] [get_bd_pins lvds_simulate_0/lvds_clk_out]
  connect_bd_net -net lvds_simulate_0_lvds_csl_out [get_bd_pins FIFO_write_0/lvds_csl] [get_bd_pins ila_0/probe1] [get_bd_pins lvds_rx_0/lvds_csl] [get_bd_pins lvds_simulate_0/lvds_csl_out]
  connect_bd_net -net lvds_simulate_0_lvds_data1_out [get_bd_pins ila_0/probe6] [get_bd_pins lvds_rx_0/lvds_data1] [get_bd_pins lvds_simulate_0/lvds_data1_out]
  connect_bd_net -net lvds_simulate_0_lvds_data2_out [get_bd_pins ila_0/probe7] [get_bd_pins lvds_rx_0/lvds_data2] [get_bd_pins lvds_simulate_0/lvds_data2_out]
  connect_bd_net -net net_rx_ctl_0_1 [get_bd_ports net_rx_ctl] [get_bd_pins net_udp_loop_0/net_rx_ctl]
  connect_bd_net -net net_rxc_0_1 [get_bd_ports net_rxc] [get_bd_pins net_udp_loop_0/net_rxc]
  connect_bd_net -net net_rxd_0_1 [get_bd_ports net_rxd] [get_bd_pins net_udp_loop_0/net_rxd]
  connect_bd_net -net net_udp_loop_0_eth_link_ok [get_bd_pins lvds_rx_0/en_in] [get_bd_pins net_udp_loop_0/eth_link_ok] [get_bd_pins vio_0/probe_in0]
  connect_bd_net -net net_udp_loop_0_eth_mdc [get_bd_ports eth_mdc] [get_bd_pins net_udp_loop_0/eth_mdc]
  connect_bd_net -net net_udp_loop_0_fifo_clk [get_bd_pins FIFO_trans_0/clk] [get_bd_pins fifo_rx/rd_clk] [get_bd_pins ila_FIFO_lvds/probe8] [get_bd_pins net_udp_loop_0/fifo_clk]
  connect_bd_net -net net_udp_loop_0_net_tx_ctl [get_bd_ports net_tx_ctl] [get_bd_pins net_udp_loop_0/net_tx_ctl]
  connect_bd_net -net net_udp_loop_0_net_txc [get_bd_ports net_txc] [get_bd_pins net_udp_loop_0/net_txc]
  connect_bd_net -net net_udp_loop_0_net_txd [get_bd_ports net_txd] [get_bd_pins net_udp_loop_0/net_txd]
  connect_bd_net -net net_udp_loop_0_udp_tx_busy [get_bd_pins FIFO_trans_0/udp_tx_busy] [get_bd_pins net_udp_loop_0/udp_tx_busy]
  connect_bd_net -net sys_clk_1 [get_bd_ports sys_clk] [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net sys_rst_n_1 [get_bd_pins FIFO_trans_0/rst_n] [get_bd_pins FIFO_write_0/rst_n] [get_bd_pins g_net_rest_n_0/net_rst_n] [get_bd_pins lvds_rx_0/rst_n] [get_bd_pins lvds_simulate_0/rst_n] [get_bd_pins net_udp_loop_0/sys_rst_n]
  connect_bd_net -net sys_rst_n_2 [get_bd_ports sys_rst_n] [get_bd_pins clk_wiz_0/resetn] [get_bd_pins g_net_rest_n_0/sysrstn]
  connect_bd_net -net vio_0_probe_out0 [get_bd_pins net_udp_loop_0/udp_send_byte_num] [get_bd_pins vio_0/probe_out0]
  connect_bd_net -net vio_0_probe_out1 [get_bd_pins lvds_simulate_0/sel_sim] [get_bd_pins vio_0/probe_out1]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


