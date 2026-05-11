//****************************************Copyright (c)***********************************//
// 修改者：用户
// 修改说明：去掉回环，改为固定数据定时发送（每2秒一次，1012字节）
// 原正点原子顶层模块，基于版本 V1.0 修改
//****************************************************************************************//

module eth_udp_loop(
    input              sys_clk   , // 系统时钟（50MHz 或 200MHz，由 PLL 产生 200MHz 给 IDELAY）
    input              sys_rst_n , // 系统复位，低有效
    // 以太网 RGMII 接口   
    input              eth_rxc   , // RGMII 接收时钟
    input              eth_rx_ctl, // RGMII 接收控制信号
    input       [3:0]  eth_rxd   , // RGMII 接收数据
    output             eth_txc   , // RGMII 发送时钟    
    output             eth_tx_ctl, // RGMII 发送控制信号
    output      [3:0]  eth_txd   , // RGMII 发送数据          
    output             eth_rst_n   // 以太网 PHY 复位，低有效
);

//============== 参数定义 ==============//
// 开发板 MAC 地址
parameter BOARD_MAC       = 48'h00_11_22_33_44_55;
// 开发板 IP 地址 192.168.1.10
parameter BOARD_IP        = {8'd192, 8'd168, 8'd1, 8'd10};
// 上位机（目的）MAC 地址 -- 直接固定，不需要 ARP 解析
parameter DES_MAC_FIXED   = 48'h00_11_22_33_44_55;   // 请修改为你的上位机 MAC
// 上位机（目的）IP 地址 192.168.1.102
parameter DES_IP_FIXED    = {8'd192, 8'd168, 8'd1, 8'd102};
// 输入数据 IO 延时（不变）
parameter IDELAY_VALUE    = 0;

//============== 内部信号 ==============//
wire          clk_200m          ; // 200MHz 时钟，用于 IDELAY
wire          locked            ; // PLL 锁定

// GMII 接口信号
wire          gmii_rx_clk       ; // GMII 接收时钟（来自 PHY）
wire          gmii_rx_dv        ; // GMII 接收数据有效
wire  [7:0]   gmii_rxd          ; // GMII 接收数据
wire          gmii_tx_clk       ; // GMII 发送时钟（125MHz）
wire          gmii_tx_en        ; // GMII 发送使能
wire  [7:0]   gmii_txd          ; // GMII 发送数据

// ARP 模块接口（保留，用于响应 ping 等，但不影响 UDP 发送）
wire          arp_gmii_tx_en    ;
wire  [7:0]   arp_gmii_txd      ;
wire          arp_rx_done       ;
wire          arp_rx_type       ;
wire  [47:0]  src_mac           ;
wire  [31:0]  src_ip            ;
wire          arp_tx_en         ;
wire          arp_tx_type       ;
wire  [47:0]  des_mac_arp       ; // 来自 ARP 的目的 MAC（UDP 不使用）
wire  [31:0]  des_ip_arp        ; // 来自 ARP 的目的 IP（UDP 不使用）
wire          arp_tx_done       ;

// ICMP 模块接口（保留，可响应 ping）
wire          icmp_gmii_tx_en   ;
wire  [7:0]   icmp_gmii_txd     ;
wire          icmp_rec_pkt_done ;
wire          icmp_rec_en       ;
wire  [7:0]   icmp_rec_data     ;
wire  [15:0]  icmp_rec_byte_num ;
wire  [15:0]  icmp_tx_byte_num  ;
wire          icmp_tx_done      ;
wire          icmp_tx_req       ;
wire  [7:0]   icmp_tx_data      ;
wire          icmp_tx_start_en  ;

// UDP 模块接口
wire          udp_gmii_tx_en    ;
wire  [7:0]   udp_gmii_txd      ;
wire          udp_tx_done       ;
wire          udp_tx_req        ;
wire  [7:0]   udp_tx_data       ; // 来自固定发送模块
wire  [15:0]  udp_tx_byte_num   ; // 固定 1012
wire          udp_tx_start_en   ; // 来自固定发送模块

// 固定发送模块与 UDP 模块的连接
wire          fixed_tx_start_en ;
wire  [7:0]   fixed_tx_data     ;
wire  [15:0]  fixed_tx_byte_num ;
wire          fixed_tx_req      ; // 连接到 udp_tx_req
wire          fixed_tx_done     ; // 连接到 udp_tx_done

//============== 模块例化 ==============//

// 时钟管理（200MHz 给 IDELAY）
clk_wiz_0 u_clk_wiz_0 (
    .clk_out1 (clk_200m),
    .reset    (~sys_rst_n),
    .locked   (locked),
    .clk_in1  (sys_clk)
);

// GMII <-> RGMII 转换
gmii_to_rgmii #(
    .IDELAY_VALUE (IDELAY_VALUE)
) u_gmii_to_rgmii (
    .idelay_clk    (clk_200m),
    .gmii_rx_clk   (gmii_rx_clk),
    .gmii_rx_dv    (gmii_rx_dv),
    .gmii_rxd      (gmii_rxd),
    .gmii_tx_clk   (gmii_tx_clk),
    .gmii_tx_en    (gmii_tx_en),
    .gmii_txd      (gmii_txd),
    .rgmii_rxc     (eth_rxc),
    .rgmii_rx_ctl  (eth_rx_ctl),
    .rgmii_rxd     (eth_rxd),
    .rgmii_txc     (eth_txc),
    .rgmii_tx_ctl  (eth_tx_ctl),
    .rgmii_txd     (eth_txd)
);

// ARP 模块（保留，用于接收 ARP 请求并应答，保持网络通畅）
arp #(
    .BOARD_MAC      (BOARD_MAC),
    .BOARD_IP       (BOARD_IP),
    .DES_MAC_DEFAULT(48'hff_ff_ff_ff_ff_ff),
    .DES_IP_DEFAULT (DES_IP_FIXED)
) u_arp (
    .rst_n          (sys_rst_n),
    .gmii_rx_clk    (gmii_rx_clk),
    .gmii_rx_dv     (gmii_rx_dv),
    .gmii_rxd       (gmii_rxd),
    .gmii_tx_clk    (gmii_tx_clk),
    .gmii_tx_en     (arp_gmii_tx_en),
    .gmii_txd       (arp_gmii_txd),
    .arp_rx_done    (arp_rx_done),
    .arp_rx_type    (arp_rx_type),
    .src_mac        (src_mac),
    .src_ip         (src_ip),
    .arp_tx_en      (arp_tx_en),
    .arp_tx_type    (arp_tx_type),
    .des_mac        (des_mac_arp),
    .des_ip         (des_ip_arp),
    .tx_done        (arp_tx_done)
);

// ICMP 模块（保留，可响应 ping）
icmp #(
    .BOARD_MAC      (BOARD_MAC),
    .BOARD_IP       (BOARD_IP),
    .DES_MAC_DEFAULT(48'hff_ff_ff_ff_ff_ff),
    .DES_IP_DEFAULT (DES_IP_FIXED)
) u_icmp (
    .rst_n          (sys_rst_n),
    .gmii_rx_clk    (gmii_rx_clk),
    .gmii_rx_dv     (gmii_rx_dv),
    .gmii_rxd       (gmii_rxd),
    .gmii_tx_clk    (gmii_tx_clk),
    .gmii_tx_en     (icmp_gmii_tx_en),
    .gmii_txd       (icmp_gmii_txd),
    .rec_pkt_done   (icmp_rec_pkt_done),
    .rec_en         (icmp_rec_en),
    .rec_data       (icmp_rec_data),
    .rec_byte_num   (icmp_rec_byte_num),
    .tx_start_en    (icmp_tx_start_en),
    .tx_data        (icmp_tx_data),
    .tx_byte_num    (icmp_tx_byte_num),
    .des_mac        (des_mac_arp),   // 复用 ARP 解析出的目的 MAC
    .des_ip         (des_ip_arp),
    .tx_done        (icmp_tx_done),
    .tx_req         (icmp_tx_req)
);

// UDP 模块（用于发送固定数据）
udp #(
    .BOARD_MAC      (BOARD_MAC),
    .BOARD_IP       (BOARD_IP),
    .DES_MAC_DEFAULT(DES_MAC_FIXED),   // 直接使用固定目的 MAC
    .DES_IP_DEFAULT (DES_IP_FIXED)
) u_udp (
    .rst_n          (sys_rst_n),
    .gmii_rx_clk    (gmii_rx_clk),
    .gmii_rx_dv     (gmii_rx_dv),
    .gmii_rxd       (gmii_rxd),
    .gmii_tx_clk    (gmii_tx_clk),
    .gmii_tx_en     (udp_gmii_tx_en),
    .gmii_txd       (udp_gmii_txd),
    // 接收端口不使用（回环已去掉）
    .rec_pkt_done   (),
    .rec_en         (),
    .rec_data       (),
    .rec_byte_num   (),
    // 发送端口连接固定发送模块
    .tx_start_en    (fixed_tx_start_en),
    .tx_data        (fixed_tx_data),
    .tx_byte_num    (fixed_tx_byte_num),
    .des_mac        (DES_MAC_FIXED),   // 固定 MAC
    .des_ip         (DES_IP_FIXED),
    .tx_done        (fixed_tx_done),
    .tx_req         (fixed_tx_req)
);

// 固定数据发送模块（每2秒发送1012字节）
udp_fixed_sender u_udp_fixed_sender (
    .clk           (gmii_rx_clk),      // 125MHz
    .rst_n         (sys_rst_n),
    .tx_start_en   (fixed_tx_start_en),
    .tx_req        (fixed_tx_req),
    .tx_data       (fixed_tx_data),
    .tx_byte_num   (fixed_tx_byte_num),
    .tx_done       (fixed_tx_done)
);

// 以太网发送通道选择器（优先级：ARP > ICMP > UDP）
wire tx_en_sel;
wire [7:0] txd_sel;

assign tx_en_sel = arp_gmii_tx_en ? 1'b1 :
                   icmp_gmii_tx_en ? 1'b1 :
                   udp_gmii_tx_en  ? 1'b1 : 1'b0;
assign txd_sel  = arp_gmii_tx_en ? arp_gmii_txd :
                  icmp_gmii_tx_en ? icmp_gmii_txd :
                  udp_gmii_txd;

// 连接到 GMII 发送接口
assign gmii_tx_en = tx_en_sel;
assign gmii_txd   = txd_sel;

// PHY 复位
assign eth_rst_n = sys_rst_n;

endmodule