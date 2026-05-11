// (c) Copyright 1995-2026 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:FIFO_write:1.0
// IP Revision: 1

(* X_CORE_INFO = "FIFO_write,Vivado 2020.2" *)
(* CHECK_LICENSE_TYPE = "design_1_FIFO_write_0_5,FIFO_write,{}" *)
(* CORE_GENERATION_INFO = "design_1_FIFO_write_0_5,FIFO_write,{x_ipProduct=Vivado 2020.2,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=FIFO_write,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_FIFO_write_0_5 (
  lvds_clk,
  lvds_csl,
  rst_n,
  dat_rx,
  dat_update,
  frame_rst_hp,
  fifo_clk,
  fifo_din,
  fifo_wr_en,
  chksum,
  rx_dat_cnt,
  rx_done_hp
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME lvds_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 lvds_clk CLK" *)
input wire lvds_clk;
input wire lvds_csl;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst_n RST" *)
input wire rst_n;
input wire [15 : 0] dat_rx;
input wire dat_update;
input wire frame_rst_hp;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME fifo_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN design_1_FIFO_write_0_5_fifo_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 fifo_clk CLK" *)
output wire fifo_clk;
output wire [15 : 0] fifo_din;
output wire fifo_wr_en;
output wire [15 : 0] chksum;
output wire [15 : 0] rx_dat_cnt;
output wire rx_done_hp;

  FIFO_write inst (
    .lvds_clk(lvds_clk),
    .lvds_csl(lvds_csl),
    .rst_n(rst_n),
    .dat_rx(dat_rx),
    .dat_update(dat_update),
    .frame_rst_hp(frame_rst_hp),
    .fifo_clk(fifo_clk),
    .fifo_din(fifo_din),
    .fifo_wr_en(fifo_wr_en),
    .chksum(chksum),
    .rx_dat_cnt(rx_dat_cnt),
    .rx_done_hp(rx_done_hp)
  );
endmodule
