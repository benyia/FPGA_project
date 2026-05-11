//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Sun Apr 19 14:13:43 2026
//Host        : BenYia running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=12,numReposBlks=12,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=6,numPkgbdBlks=0,bdsource=USER,da_ps7_cnt=1,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
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
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR ADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DDR, AXI_ARBITRATION_SCHEME TDM, BURST_LENGTH 8, CAN_DEBUG false, CAS_LATENCY 11, CAS_WRITE_LATENCY 11, CS_ENABLED true, DATA_MASK_ENABLED true, DATA_WIDTH 8, MEMORY_TYPE COMPONENTS, MEM_ADDR_MAP ROW_COLUMN_BANK, SLOT Single, TIMEPERIOD_PS 1250" *) inout [14:0]DDR_addr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR BA" *) inout [2:0]DDR_ba;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CAS_N" *) inout DDR_cas_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CK_N" *) inout DDR_ck_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CK_P" *) inout DDR_ck_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CKE" *) inout DDR_cke;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CS_N" *) inout DDR_cs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DM" *) inout [3:0]DDR_dm;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQ" *) inout [31:0]DDR_dq;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQS_N" *) inout [3:0]DDR_dqs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQS_P" *) inout [3:0]DDR_dqs_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR ODT" *) inout DDR_odt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR RAS_N" *) inout DDR_ras_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR RESET_N" *) inout DDR_reset_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR WE_N" *) inout DDR_we_n;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRN" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME FIXED_IO, CAN_DEBUG false" *) inout FIXED_IO_ddr_vrn;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRP" *) inout FIXED_IO_ddr_vrp;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO MIO" *) inout [53:0]FIXED_IO_mio;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_CLK" *) inout FIXED_IO_ps_clk;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_PORB" *) inout FIXED_IO_ps_porb;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_SRSTB" *) inout FIXED_IO_ps_srstb;
  output en;
  output en_n;
  output eth_mdc;
  inout eth_mdio;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.LVDS_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.LVDS_CLK, CLK_DOMAIN design_1_lvds_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000" *) input lvds_clk;
  input lvds_csl;
  input lvds_data1;
  input lvds_data2;
  input net_rx_ctl;
  input net_rxc;
  input [3:0]net_rxd;
  output net_tx_ctl;
  output net_txc;
  output [3:0]net_txd;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.SYS_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.SYS_CLK, CLK_DOMAIN design_1_sys_clk, FREQ_HZ 50000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000" *) input sys_clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.SYS_RST_N RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.SYS_RST_N, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input sys_rst_n;

  wire [31:0]FIFO_trans_0_fifo_dout;
  wire FIFO_trans_0_fifo_rd_en;
  wire FIFO_trans_0_fifo_wr_en;
  wire FIFO_trans_0_tx_send_en;
  wire FIFO_write_0_fifo_clk;
  wire [15:0]FIFO_write_0_fifo_din;
  wire FIFO_write_0_fifo_wr_en;
  wire FIFO_write_0_rx_done;
  wire Net;
  wire clk_wiz_0_clk_100M;
  wire clk_wiz_0_clk_150M;
  wire clk_wiz_0_clk_200M;
  wire clk_wiz_0_clk_50M;
  wire clk_wiz_0_clk_75M;
  wire [15:0]fifo_rx_dout;
  wire fifo_rx_empty;
  wire fifo_rx_full;
  wire [12:0]fifo_rx_rd_data_count;
  wire lvds_clk_1;
  wire lvds_csl_1;
  wire lvds_data1_1;
  wire lvds_data2_1;
  wire [15:0]lvds_rx_0_dat_rx;
  wire lvds_rx_0_dat_update;
  wire lvds_rx_0_debug_rst;
  wire lvds_rx_0_en;
  wire lvds_rx_0_en_n;
  wire lvds_rx_0_framenew_rst;
  wire [7:0]lvds_rx_0_lineID;
  wire [15:0]lvds_rx_0_x;
  wire [15:0]lvds_rx_0_y;
  wire [15:0]lvds_rx_0_z;
  wire lvds_simulate_0_lvds_clk_out;
  wire lvds_simulate_0_lvds_csl_out;
  wire lvds_simulate_0_lvds_data1_out;
  wire lvds_simulate_0_lvds_data2_out;
  wire net_rx_ctl_0_1;
  wire net_rxc_0_1;
  wire [3:0]net_rxd_0_1;
  wire net_udp_loop_0_eth_link_ok;
  wire net_udp_loop_0_eth_mdc;
  wire net_udp_loop_0_fifo_clk;
  wire net_udp_loop_0_net_tx_ctl;
  wire net_udp_loop_0_net_txc;
  wire [3:0]net_udp_loop_0_net_txd;
  wire net_udp_loop_0_udp_tx_busy;
  wire [14:0]processing_system7_0_DDR_ADDR;
  wire [2:0]processing_system7_0_DDR_BA;
  wire processing_system7_0_DDR_CAS_N;
  wire processing_system7_0_DDR_CKE;
  wire processing_system7_0_DDR_CK_N;
  wire processing_system7_0_DDR_CK_P;
  wire processing_system7_0_DDR_CS_N;
  wire [3:0]processing_system7_0_DDR_DM;
  wire [31:0]processing_system7_0_DDR_DQ;
  wire [3:0]processing_system7_0_DDR_DQS_N;
  wire [3:0]processing_system7_0_DDR_DQS_P;
  wire processing_system7_0_DDR_ODT;
  wire processing_system7_0_DDR_RAS_N;
  wire processing_system7_0_DDR_RESET_N;
  wire processing_system7_0_DDR_WE_N;
  wire processing_system7_0_FIXED_IO_DDR_VRN;
  wire processing_system7_0_FIXED_IO_DDR_VRP;
  wire [53:0]processing_system7_0_FIXED_IO_MIO;
  wire processing_system7_0_FIXED_IO_PS_CLK;
  wire processing_system7_0_FIXED_IO_PS_PORB;
  wire processing_system7_0_FIXED_IO_PS_SRSTB;
  wire sys_clk_1;
  wire sys_rst_n_1;
  wire sys_rst_n_2;
  wire [15:0]vio_0_probe_out0;
  wire [0:0]vio_0_probe_out1;

  assign en = lvds_rx_0_en;
  assign en_n = lvds_rx_0_en_n;
  assign eth_mdc = net_udp_loop_0_eth_mdc;
  assign lvds_clk_1 = lvds_clk;
  assign lvds_csl_1 = lvds_csl;
  assign lvds_data1_1 = lvds_data1;
  assign lvds_data2_1 = lvds_data2;
  assign net_rx_ctl_0_1 = net_rx_ctl;
  assign net_rxc_0_1 = net_rxc;
  assign net_rxd_0_1 = net_rxd[3:0];
  assign net_tx_ctl = net_udp_loop_0_net_tx_ctl;
  assign net_txc = net_udp_loop_0_net_txc;
  assign net_txd[3:0] = net_udp_loop_0_net_txd;
  assign sys_clk_1 = sys_clk;
  assign sys_rst_n_2 = sys_rst_n;
  design_1_FIFO_trans_0_0 FIFO_trans_0
       (.clk(net_udp_loop_0_fifo_clk),
        .fifo_din(fifo_rx_dout),
        .fifo_dout(FIFO_trans_0_fifo_dout),
        .fifo_in_empty(fifo_rx_empty),
        .fifo_rd_en(FIFO_trans_0_fifo_rd_en),
        .fifo_wr_en(FIFO_trans_0_fifo_wr_en),
        .lvds_rst(lvds_rx_0_framenew_rst),
        .newframe_rst_in(FIFO_write_0_rx_done),
        .rst_n(sys_rst_n_1),
        .tx_send_en(FIFO_trans_0_tx_send_en),
        .udp_tx_busy(net_udp_loop_0_udp_tx_busy));
  design_1_FIFO_write_0_5 FIFO_write_0
       (.dat_rx(lvds_rx_0_dat_rx),
        .dat_update(lvds_rx_0_dat_update),
        .fifo_clk(FIFO_write_0_fifo_clk),
        .fifo_din(FIFO_write_0_fifo_din),
        .fifo_wr_en(FIFO_write_0_fifo_wr_en),
        .frame_rst_hp(lvds_rx_0_framenew_rst),
        .lvds_clk(lvds_simulate_0_lvds_clk_out),
        .lvds_csl(lvds_simulate_0_lvds_csl_out),
        .rst_n(sys_rst_n_1),
        .rx_done_hp(FIFO_write_0_rx_done));
  design_1_clk_wiz_0_0 clk_wiz_0
       (.clk_100M(clk_wiz_0_clk_100M),
        .clk_150M(clk_wiz_0_clk_150M),
        .clk_200M(clk_wiz_0_clk_200M),
        .clk_50M(clk_wiz_0_clk_50M),
        .clk_75M(clk_wiz_0_clk_75M),
        .clk_in1(sys_clk_1),
        .resetn(sys_rst_n_2));
  design_1_fifo_generator_0_0 fifo_rx
       (.din(FIFO_write_0_fifo_din),
        .dout(fifo_rx_dout),
        .empty(fifo_rx_empty),
        .full(fifo_rx_full),
        .rd_clk(net_udp_loop_0_fifo_clk),
        .rd_data_count(fifo_rx_rd_data_count),
        .rd_en(FIFO_trans_0_fifo_rd_en),
        .wr_clk(FIFO_write_0_fifo_clk),
        .wr_en(FIFO_write_0_fifo_wr_en));
  design_1_g_net_rest_n_0_0 g_net_rest_n_0
       (.clk(clk_wiz_0_clk_50M),
        .net_rst_n(sys_rst_n_1),
        .sysrstn(sys_rst_n_2));
  design_1_ila_0_0 ila_0
       (.clk(clk_wiz_0_clk_150M),
        .probe0(lvds_simulate_0_lvds_clk_out),
        .probe1(lvds_simulate_0_lvds_csl_out),
        .probe10(lvds_rx_0_z),
        .probe11(lvds_rx_0_dat_update),
        .probe2(lvds_rx_0_debug_rst),
        .probe3(lvds_rx_0_framenew_rst),
        .probe4(lvds_rx_0_dat_rx),
        .probe5(lvds_rx_0_lineID),
        .probe6(lvds_simulate_0_lvds_data1_out),
        .probe7(lvds_simulate_0_lvds_data2_out),
        .probe8(lvds_rx_0_x),
        .probe9(lvds_rx_0_y));
  design_1_system_ila_0_2 ila_FIFO_lvds
       (.clk(clk_wiz_0_clk_150M),
        .probe0(FIFO_write_0_fifo_clk),
        .probe1(FIFO_write_0_fifo_din),
        .probe10(fifo_rx_full),
        .probe2(FIFO_write_0_fifo_wr_en),
        .probe3(FIFO_write_0_rx_done),
        .probe4(fifo_rx_rd_data_count),
        .probe5(fifo_rx_empty),
        .probe6(fifo_rx_dout),
        .probe7(FIFO_trans_0_fifo_rd_en),
        .probe8(net_udp_loop_0_fifo_clk),
        .probe9(lvds_rx_0_framenew_rst));
  design_1_lvds_rx_0_0 lvds_rx_0
       (.dat_rx(lvds_rx_0_dat_rx),
        .dat_update(lvds_rx_0_dat_update),
        .debug_rst(lvds_rx_0_debug_rst),
        .en(lvds_rx_0_en),
        .en_in(net_udp_loop_0_eth_link_ok),
        .en_n(lvds_rx_0_en_n),
        .framenew_rst(lvds_rx_0_framenew_rst),
        .lineID(lvds_rx_0_lineID),
        .lvds_clk(lvds_simulate_0_lvds_clk_out),
        .lvds_csl(lvds_simulate_0_lvds_csl_out),
        .lvds_data1(lvds_simulate_0_lvds_data1_out),
        .lvds_data2(lvds_simulate_0_lvds_data2_out),
        .rst_n(sys_rst_n_1),
        .x(lvds_rx_0_x),
        .y(lvds_rx_0_y),
        .z(lvds_rx_0_z));
  design_1_lvds_simulate_0_0 lvds_simulate_0
       (.clk100M(clk_wiz_0_clk_100M),
        .clk75M(clk_wiz_0_clk_75M),
        .lvds_clk_in(lvds_clk_1),
        .lvds_clk_out(lvds_simulate_0_lvds_clk_out),
        .lvds_csl_in(lvds_csl_1),
        .lvds_csl_out(lvds_simulate_0_lvds_csl_out),
        .lvds_data1_in(lvds_data1_1),
        .lvds_data1_out(lvds_simulate_0_lvds_data1_out),
        .lvds_data2_in(lvds_data2_1),
        .lvds_data2_out(lvds_simulate_0_lvds_data2_out),
        .rst_n(sys_rst_n_1),
        .sel_sim(vio_0_probe_out1));
  design_1_net_udp_loop_0_0 net_udp_loop_0
       (.clk_200m(clk_wiz_0_clk_200M),
        .clk_50m(clk_wiz_0_clk_50M),
        .eth_link_ok(net_udp_loop_0_eth_link_ok),
        .eth_mdc(net_udp_loop_0_eth_mdc),
        .eth_mdio(eth_mdio),
        .fifo_clk(net_udp_loop_0_fifo_clk),
        .fifo_din(FIFO_trans_0_fifo_dout),
        .fifo_rst(1'b0),
        .fifo_wr_en(FIFO_trans_0_fifo_wr_en),
        .net_rx_ctl(net_rx_ctl_0_1),
        .net_rxc(net_rxc_0_1),
        .net_rxd(net_rxd_0_1),
        .net_tx_ctl(net_udp_loop_0_net_tx_ctl),
        .net_txc(net_udp_loop_0_net_txc),
        .net_txd(net_udp_loop_0_net_txd),
        .sys_rst_n(sys_rst_n_1),
        .udp_send_byte_num(vio_0_probe_out0),
        .udp_send_start(FIFO_trans_0_tx_send_en),
        .udp_tx_busy(net_udp_loop_0_udp_tx_busy));
  design_1_processing_system7_0_0 processing_system7_0
       (.DDR_Addr(DDR_addr[14:0]),
        .DDR_BankAddr(DDR_ba[2:0]),
        .DDR_CAS_n(DDR_cas_n),
        .DDR_CKE(DDR_cke),
        .DDR_CS_n(DDR_cs_n),
        .DDR_Clk(DDR_ck_p),
        .DDR_Clk_n(DDR_ck_n),
        .DDR_DM(DDR_dm[3:0]),
        .DDR_DQ(DDR_dq[31:0]),
        .DDR_DQS(DDR_dqs_p[3:0]),
        .DDR_DQS_n(DDR_dqs_n[3:0]),
        .DDR_DRSTB(DDR_reset_n),
        .DDR_ODT(DDR_odt),
        .DDR_RAS_n(DDR_ras_n),
        .DDR_VRN(FIXED_IO_ddr_vrn),
        .DDR_VRP(FIXED_IO_ddr_vrp),
        .DDR_WEB(DDR_we_n),
        .MIO(FIXED_IO_mio[53:0]),
        .PS_CLK(FIXED_IO_ps_clk),
        .PS_PORB(FIXED_IO_ps_porb),
        .PS_SRSTB(FIXED_IO_ps_srstb));
  design_1_vio_0_0 vio_0
       (.clk(clk_wiz_0_clk_150M),
        .probe_in0(net_udp_loop_0_eth_link_ok),
        .probe_out0(vio_0_probe_out0),
        .probe_out1(vio_0_probe_out1));
endmodule
