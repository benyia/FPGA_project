module net_udp_loop(
    input              clk_200m  ,   
    input              clk_50m  ,  
    input              sys_rst_n , //系统复位信号，低电平有效 
    //KSZ9031_RGMII接口   
    output             eth_mdc  ,
    inout              eth_mdio ,     
    input              net_rxc   , //KSZ9031_RGMII接收数据时钟
    input              net_rx_ctl, //KSZ9031RGMII输入数据有效信号
    input       [3:0]  net_rxd   , //KSZ9031RGMII输入数据
    output             net_txc   , //KSZ9031RGMII发送数据时钟    
    output             net_tx_ctl, //KSZ9031RGMII输出数据有效信号
    output      [3:0]  net_txd   , //KSZ9031RGMII输出数据          
    output             net_rst_n ,  //KSZ9031芯片复位信号，低电平有效   
    
    //fifo写入接口
    input       fifo_rst,
    output      fifo_clk,
    input       fifo_wr_en,
    input       [31:0] fifo_din    ,
    output      fifo_empty,
    output      fifo_full,
    //
    input               udp_send_start,
    input       [15:0]  udp_send_byte_num,
    output   [11:0]  fifo_data_cnt,
    
    output     udp_tx_done,  //发送完成，高脉冲
    output      udp_tx_busy,
    output      eth_link_ok
    );

//parameter define
parameter  IDELAY_VALUE = 0;
parameter  BOARD_MAC = 48'h99_00_33_11_00_00;     
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};  
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;       
parameter  DES_IP    = {8'd255,8'd255,8'd255,8'd255};  

parameter  DES_UDP_PORT    = 16'd9020;  
parameter  BOARD_UDP_PORT    = 16'd9010;  

//wire define
            
wire          gmii_rx_clk; //GMII接收时钟
wire          gmii_rx_en ; //GMII接收数据有效信号
wire  [7:0]   gmii_rxd   ; //GMII接收数据
wire          gmii_tx_clk; //GMII发送时钟
wire          gmii_tx_en ; //GMII发送数据使能信号
wire  [7:0]   gmii_txd   ; //GMII发送数据     

wire          arp_gmii_tx_en; //ARP GMII输出数据有效信号 
wire  [7:0]   arp_gmii_txd  ; //ARP GMII输出数据
wire          arp_rx_done   ; //ARP接收完成信号
wire          arp_rx_type   ; //ARP接收类型 0:请求  1:应答
wire  [47:0]  src_mac       ; //接收到目的MAC地址
wire  [31:0]  src_ip        ; //接收到目的IP地址    
wire          arp_tx_en     ; //ARP发送使能信号
wire          arp_tx_type   ; //ARP发送类型 0:请求  1:应答
wire  [47:0]  des_mac       ; //发送的目标MAC地址
wire  [31:0]  des_ip        ; //发送的目标IP地址   
wire          arp_tx_done   ; //ARP发送完成信号

wire          udp_gmii_tx_en; //UDP GMII输出数据有效信号 
wire  [7:0]   udp_gmii_txd  ; //UDP GMII输出数据
wire          rec_pkt_done  ; //UDP单包数据接收完成信号
wire          rec_en        ; //UDP接收的数据使能信号
wire  [31:0]  rec_data      ; //UDP接收的数据
wire  [15:0]  rec_byte_num  ; //UDP接收的有效字节数 单位:byte 
wire  [15:0]  tx_byte_num   ; //UDP发送的有效字节数 单位:byte 
//wire          udp_tx_done   ; //UDP发送完成信号
wire          tx_req        ; //UDP读数据请求信号
wire  [31:0]  tx_data       ; //UDP待发送数据


wire tx_start_en;
wire link_error;
///////////////////////main code////////////////////////////////
assign fifo_clk = gmii_rx_clk;
assign eth_link_ok = ~link_error;

assign tx_start_en = rec_pkt_done;
assign tx_byte_num = rec_byte_num;
assign des_mac = src_mac;
assign des_ip = src_ip;


(* IODELAY_GROUP = "rgmii_delay" *) 
IDELAYCTRL  IDELAYCTRL_inst (
    .RDY(),                      // 1-bit output: Ready output
    .REFCLK(clk_200m),         // 1-bit input: Reference clock input
    .RST(1'b0)                   // 1-bit input: Active high reset input
);


//KSZ9031_phy复位
net_rstn u_net_rstn(
    .clk       (clk_50m       ),
    .sysrstn   (sys_rst_n     ),
    .net_rst_n (net_rst_n     )
);

RTL8211_Config_IP inst_RTL8211_Config_IP_0 (
  .sys_clk(clk_200m),    // input wire sys_clk
  .sys_rstn(net_rst_n),  // input wire sys_rstn
  .eth_mdc(eth_mdc),    // output wire eth_mdc
  .eth_mdio(eth_mdio), // inout wire eth_mdio
  .link_error(link_error),
  .led()                // output wire led（未使用）
);
//GMII接口转RGMII接口
gmii_to_rgmii 
    #(
     .IDELAY_VALUE (IDELAY_VALUE)
     )
    u_gmii_to_rgmii(
    .idelay_clk    (clk_200m    ),

    .gmii_rx_clk   (gmii_rx_clk ),
    .gmii_rx_en    (gmii_rx_en  ),
    .gmii_rxd      (gmii_rxd    ),
    .gmii_tx_clk   (gmii_tx_clk ),
    .gmii_tx_en    (gmii_tx_en  ),
    .gmii_txd      (gmii_txd    ),
    
    .rgmii_rxc     (net_rxc     ),
    .rgmii_rx_ctl  (net_rx_ctl  ),
    .rgmii_rxd     (net_rxd     ),
    .rgmii_txc     (net_txc     ),
    .rgmii_tx_ctl  (net_tx_ctl  ),
    .rgmii_txd     (net_txd     )
    );

//ARP通信
arp                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
   u_arp(
    .rst_n         (sys_rst_n  ),
                    
    .gmii_rx_clk   (gmii_rx_clk),
    .gmii_rx_en    (gmii_rx_en ),
    .gmii_rxd      (gmii_rxd   ),
    .gmii_tx_clk   (gmii_tx_clk),
    .gmii_tx_en    (arp_gmii_tx_en ),
    .gmii_txd      (arp_gmii_txd),
                    
    .arp_rx_done   (arp_rx_done),
    .arp_rx_type   (arp_rx_type),
    .src_mac       (src_mac    ),
    .src_ip        (src_ip     ),
    .arp_tx_en     (arp_tx_en  ),
    .arp_tx_type   (arp_tx_type),
    .des_mac       (des_mac    ),
    .des_ip        (des_ip     ),
    .tx_done       (arp_tx_done)
    );

wire fifo_rd_out;
wire send_en_out;
header_det header_det_inst(
    .clk_in(gmii_rx_clk),
    .rstn(sys_rst_n),
    .send_en(udp_send_start),
    .fifo_rd_in(tx_req),
    .fifo_dat(tx_data),
    .fifo_rd_out(fifo_rd_out),
    .send_en_out(send_en_out)    ,
    .udp_tx_busy(udp_tx_busy)
    );
    

//UDP通信
udp                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   ),
    .DES_UDP_PORT (DES_UDP_PORT) , 
    .BOARD_UDP_PORT (BOARD_UDP_PORT)  
    )
   u_udp(
    .rst_n         (sys_rst_n   ),  
    
    .gmii_rx_clk   (gmii_rx_clk ),           
    .gmii_rx_en    (gmii_rx_en  ),         
    .gmii_rxd      (gmii_rxd    ),                   
    .gmii_tx_clk   (gmii_tx_clk ), 
    .gmii_tx_en    (udp_gmii_tx_en),         
    .gmii_txd      (udp_gmii_txd),  

    .rec_pkt_done  (rec_pkt_done),    
    .rec_en        (rec_en      ),     
    .rec_data      (rec_data    ),         
    .rec_byte_num  (rec_byte_num),      
    .tx_start_en   ( send_en_out ), //.tx_start_en   (udp_send_start ),  //.tx_start_en   (tx_start_en ),        
    .tx_data       (tx_data     ),         
    .tx_byte_num   (udp_send_byte_num ),   //.tx_byte_num   (tx_byte_num ),   
    .tx_done       (udp_tx_done ),        
    .tx_req        (tx_req),   // .tx_req        (tx_req      ) ,
    .udp_tx_busy(udp_tx_busy)  //add          
    ); 

//FIFO
fifo_4096x32 u_fifo_4096x32(
//    .clk      (gmii_rx_clk),  // input wire clk
      .rst      (1'b0),  // input wire rst
//    .din      (fifo_din  ), //.din      (rec_data  ),  // input wire [31 : 0] din
//    .wr_en    (fifo_wr_en    ),//.wr_en    (rec_en    ),  // input wire wr_en
//    .rd_en    (tx_req    ),  // input wire rd_en
//    .dout     (tx_data   ),  // output wire [31 : 0] dout
//    .data_count(fifo_data_cnt)  // output wire [11 : 0] data_count
    
  .wr_clk(gmii_rx_clk),                // input wire wr_clk
  .rd_clk(gmii_rx_clk),                // input wire rd_clk
  .din(fifo_din),                      // input wire [31 : 0] din
  .wr_en(fifo_wr_en),                  // input wire wr_en
  .rd_en(fifo_rd_out),    //.rd_en(tx_req),                  // input wire rd_en
  .dout(tx_data),                    // output wire [31 : 0] dout
  .full(fifo_full),                    // output wire full
  .empty(fifo_empty),                  // output wire empty
  .rd_data_count(fifo_data_cnt)  // output wire [11 : 0] rd_data_count
    );  
      
ila_udp ila_udp_inst (
	.clk(gmii_rx_clk), // input wire clk


	.probe0(udp_send_start), // input wire [0:0]  probe0  
	.probe1(tx_req), // input wire [0:0]  probe1 
	.probe2(tx_data), // input wire [31:0]  probe2 
	.probe3(fifo_data_cnt), // input wire [11:0]  probe3 
	.probe4(fifo_rst) ,   // input wire [0:0]  probe4
	.probe5(fifo_full) ,
	.probe6(fifo_rd_out) ,
	.probe7(send_en_out) 
);

//以太网控制模块
net_ctrl u_net_ctrl(
    .clk            (gmii_rx_clk),
    .rst_n          (sys_rst_n),

    .arp_rx_done    (arp_rx_done   ),
    .arp_rx_type    (arp_rx_type   ),
    .arp_tx_en      (arp_tx_en     ),
    .arp_tx_type    (arp_tx_type   ),
    .arp_tx_done    (arp_tx_done   ),
    .arp_gmii_tx_en (arp_gmii_tx_en),
    .arp_gmii_txd   (arp_gmii_txd  ),
                     
    .udp_gmii_tx_en (udp_gmii_tx_en),
    .udp_gmii_txd   (udp_gmii_txd  ),
                     
    .gmii_tx_en     (gmii_tx_en    ),
    .gmii_txd       (gmii_txd      )
    );

endmodule