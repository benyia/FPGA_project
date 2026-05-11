`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2024 07:17:11 PM
// Design Name: 
// Module Name: udp_loop_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module udp_loop_top
(
 input          clk          , //全局时钟
 input          rst_n        , //异步复位
 input  [3:0]   rgmii_rxd    , //PHY芯片发送的数据
 input          rgmii_rxctrl , //PHY芯片发送的控制信号
 input          rgmii_rxclk  , //PHY芯片发送的时钟:125Mhz,25Mhz,2.5Mhz2c
 output [3:0]   rgmii_txd    , //FPGA发送给PHY的数据                    
 output         rgmii_txctrl , //FPGA发送给PHY的控制信号                  
 output         rgmii_txclk    //FPGA发送给PHY的时钟:125Mhz,25Mhz,2.5Mhz
 );
     
 //parameter define  
 //rx和tx模组地址参数赋值需要对调
 parameter SRC_MAC = 48'h2c_4d_54_29_05_58       ; //调试电脑MAC地址  
 parameter SRC_IP  = {8'd192,8'd168,8'd0,8'd101} ; //调试电脑IP地址
 parameter DES_MAC = 48'h11_11_11_11_11_11       ; //FPGA MAC地址  
 parameter DES_IP  = {8'd192,8'd168,8'd0,8'd100} ; //FPGA IP地址  
  
 wire  clk_200m    ; 
 wire  clk_125mhz  ;
 wire  clk_phase   ;  //频率125Mhz,有相位调整                       
 clk_wiz_0 clk_wiz_0
 (
                        // Clock out ports
 .clk_out1(clk_125mhz), // output clk_out1
 .clk_out2(clk_200m)  , // output clk_out2
 .clk_out3(clk_phase) , // output clk_out3
                        // Status and control signals
 .resetn(rst_n)       , // input resetn
 .locked()            , // output locked
                        // Clock in ports
 .clk_in1(clk)          // input clk_in1
  );
  
 wire        rxdata_on        ;
 wire [7:0]  rx_data          ;
 wire        rx_done          ;
 wire        rgmii_rxclkbufg  ; 
 wire [15:0] udpnum           ;
  udp_rx_top 
  //参数定义,具体数值根据实际由顶层写入
  #(   
  .SRC_MAC (SRC_MAC) , //发送端MAC地址(以本模块角度)
  .SRC_IP  (SRC_IP)  , //发送端IP地址 (以本模块角度)
  .DES_MAC (DES_MAC) , //接收端MAC地址(以本模块角度)
  .DES_IP  (DES_IP)    //接收端IP地址 (以本模块角度)
   )  
  udp_rx_top 
 (
  .clk_200m        (clk_200m)        , //input,IDELEY模块使用的200m参考时钟     
  .rst_n           (rst_n)           , //input,异步复位                    
  .rgmii_rxd       (rgmii_rxd)       , //input,4bits,RGIMII输入数据        
  .rgmii_rxctrl    (rgmii_rxctrl)    , //input,RGIMII输入控制信号            
  .rgmii_rxclk     (rgmii_rxclk)     , //input,RGIMII输入时钟              
  .rgmii_rxclkbufg (rgmii_rxclkbufg) , //output,RGIMII输入时钟连接至全局时钟网络    
//  .rx_on()                          ,
  .rxdata_on       (rxdata_on)       , //output，正在接收数据标识（不含帧头等信息）            
  .rx_data         (rx_data)         , //output,8bits,接收到source发送的数据         
  .udpnum          (udpnum)          , //output,16bits,udp字段的总字节数(含首部)       
  .rx_done         (rx_done)           //output，接收完成                                         
  );
  
 wire   [7:0]  tx_data   ;
 wire          txdata_on ;
 udp_tx_top
 #(      
 .SRC_MAC   (DES_MAC)  , //发送端MAC地址(以本模块角度)  
 .SRC_IP    (DES_IP)   , //发送端IP地址 (以本模块角度)  
 .DES_MAC   (SRC_MAC)  , //接收端MAC地址(以本模块角度)  
 .DES_IP    (SRC_IP)   , //接收端IP地址 (以本模块角度)  
 .IP_VER    (4'h4)     , //IP首部 协议版本    IPV4           
 .IP_HL     (4'h5)     , //IP首部 首部的长度  ip首部字节数5*4      
 .IP_TOS    (8'h0)     , //IP首部 服务类型                   
 .IP_ID     (16'h3f48) , //IP首部 ID标识      本实验中定义       
 .IP_FLAG   (3'b0)     , //IP首部 FLAGS                  
 .IP_OFFSET (13'b0)    , //IP首部 分片偏移量                  
 .IP_TIME   (8'h80)    , //IP首部 生存时间                   
 .IP_PRT    (8'h11)      //IP首部 协议号      UDP协议 17(十进制) 
  ) 
 udp_tx_top 
 (
 .clk_125mhz  (clk_125mhz)    , //input,125Mhz时钟                       
 .clk_phase   (clk_phase)     , //input,125Mhz时钟相移                     
 .rst_n       (rst_n)         , //input,异步复位                           
 .tx_en       (rx_done)       , //input,启动发送                           
 .tx_data     (tx_data)       , //input,8bits,待传输的数据,不含任何首部等数据             
 .datanum     (udpnum-8)      , //input,要传输的数据bytes数量,不包含任何首部,减去UDP头部8字节           
 .tx_on       ()              , //output,帧发送状态标识                       
 .txdata_on   (txdata_on)    , //output,UDP数据发送状态标识                   
 .rgmii_txd   (rgmii_txd)     , //output,4bits,RGMII接口数据通道             
 .rgmii_txclk (rgmii_txclk)   , //output,RGMII接口时钟通道                   
 .rgmii_txctrl(rgmii_txctrl)    //output,RGMII接口控制通道                   
  );
  
  wire   [7:0]     fifo_dout ;
  assign  tx_data=(txdata_on)?fifo_dout:8'b0;
                             
  fifo_generator_0 fifo_generator_0 
  (
  .rst           (!rst_n)         , // input wire rst
  .wr_clk        (rgmii_rxclkbufg), // input wire wr_clk
  .rd_clk        (clk_125mhz)     , // input wire rd_clk
  .din           (rx_data)        , // input wire [7 : 0] din
  .wr_en         (rxdata_on)      , // input wire wr_en
  .rd_en         (txdata_on)      , // input wire rd_en
  .dout          (fifo_dout)      , // output wire [7 : 0] dout
  .full          ()               , // output wire full
  .empty         ()               , // output wire empty
  .rd_data_count ()               , // output wire [9 : 0] rd_data_count
  .wr_data_count ()               , // output wire [9 : 0] wr_data_count
  .wr_rst_busy   ()               , // output wire wr_rst_busy
  .rd_rst_busy   ()                 // output wire rd_rst_busy
   );

  endmodule
