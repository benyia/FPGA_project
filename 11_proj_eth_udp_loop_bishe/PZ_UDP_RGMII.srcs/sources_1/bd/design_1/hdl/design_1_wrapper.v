//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Sun Apr 19 14:13:43 2026
//Host        : BenYia running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    en,
    en_n,
    eth_mdc,
    eth_mdio,
    lvds_clk,
    lvds_csl,
    lvds_data1,
    lvds_data2,
    net_rx_ctl,
    net_rxc,
    net_rxd,
    net_tx_ctl,
    net_txc,
    net_txd,
    sys_clk,
    sys_rst_n);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output en;
  output en_n;
  output eth_mdc;
  inout eth_mdio;
  input lvds_clk;
  input lvds_csl;
  input lvds_data1;
  input lvds_data2;
  input net_rx_ctl;
  input net_rxc;
  input [3:0]net_rxd;
  output net_tx_ctl;
  output net_txc;
  output [3:0]net_txd;
  input sys_clk;
  input sys_rst_n;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire en;
  wire en_n;
  wire eth_mdc;
  wire eth_mdio;
  wire lvds_clk;
  wire lvds_csl;
  wire lvds_data1;
  wire lvds_data2;
  wire net_rx_ctl;
  wire net_rxc;
  wire [3:0]net_rxd;
  wire net_tx_ctl;
  wire net_txc;
  wire [3:0]net_txd;
  wire sys_clk;
  wire sys_rst_n;

  design_1 design_1_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .en(en),
        .en_n(en_n),
        .eth_mdc(eth_mdc),
        .eth_mdio(eth_mdio),
        .lvds_clk(lvds_clk),
        .lvds_csl(lvds_csl),
        .lvds_data1(lvds_data1),
        .lvds_data2(lvds_data2),
        .net_rx_ctl(net_rx_ctl),
        .net_rxc(net_rxc),
        .net_rxd(net_rxd),
        .net_tx_ctl(net_tx_ctl),
        .net_txc(net_txc),
        .net_txd(net_txd),
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n));
endmodule
