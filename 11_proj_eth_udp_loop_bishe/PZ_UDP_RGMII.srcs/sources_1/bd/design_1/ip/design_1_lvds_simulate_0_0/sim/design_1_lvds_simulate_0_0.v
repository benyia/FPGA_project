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


// IP VLNV: xilinx.com:module_ref:lvds_simulate:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_lvds_simulate_0_0 (
  clk100M,
  clk75M,
  rst_n,
  sel_sim,
  lvds_clk_in,
  lvds_csl_in,
  lvds_data1_in,
  lvds_data2_in,
  lvds_clk_out,
  lvds_csl_out,
  lvds_data1_out,
  lvds_data2_out
);

input wire clk100M;
input wire clk75M;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst_n RST" *)
input wire rst_n;
input wire sel_sim;
input wire lvds_clk_in;
input wire lvds_csl_in;
input wire lvds_data1_in;
input wire lvds_data2_in;
output wire lvds_clk_out;
output wire lvds_csl_out;
output wire lvds_data1_out;
output wire lvds_data2_out;

  lvds_simulate inst (
    .clk100M(clk100M),
    .clk75M(clk75M),
    .rst_n(rst_n),
    .sel_sim(sel_sim),
    .lvds_clk_in(lvds_clk_in),
    .lvds_csl_in(lvds_csl_in),
    .lvds_data1_in(lvds_data1_in),
    .lvds_data2_in(lvds_data2_in),
    .lvds_clk_out(lvds_clk_out),
    .lvds_csl_out(lvds_csl_out),
    .lvds_data1_out(lvds_data1_out),
    .lvds_data2_out(lvds_data2_out)
  );
endmodule
