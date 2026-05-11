`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2024 02:49:24 PM
// Design Name: 
// Module Name: udp_rx_top
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


module udp_rx_top
#(
 parameter SRC_MAC = 48'b0, //发送端(以本模块角度)MAC地址   
 parameter SRC_IP  = 32'b0, //发送端(以本模块角度)IP地址    
 parameter DES_MAC = 48'b0, //接收端(以本模块角度)MAC地址  
 parameter DES_IP  = 32'b0  //接收端(以本模块角度)IP地址   
 )
(
 input         clk_200m        , //input,IDELEY模块使用的200m参考时钟
 input         rst_n           , //input,异步复位
 input  [3:0]  rgmii_rxd       , //input,4bits,RGIMII输入数据
 input         rgmii_rxctrl    , //input,RGIMII输入控制信号              
 input         rgmii_rxclk     , //input,RGIMII输入时钟          
 output        rgmii_rxclkbufg , //output,RGIMII输入时钟连接至全局时钟网络 

 //output          rx_on         , 
 output          rxdata_on       , //output，正在接收数据标识（不含帧头等信息）        
 output  [7:0]   rx_data         , //output,8bits,接收到source发送的数据    
 output  [15:0]  udpnum          , //output,16bits,udp字段的总字节数(含首部)   
 output          rx_done           //output，接收完成
 );
    
 wire  [7:0]   gmii_rxd    ; //gmii格式数据
 wire          gmii_rxval  ; //gmii数据有效标识        
 
 rgmii_to_gmii rgmii_to_gmii
 (
 .clk_200m       (clk_200m)       , //input,IDELAY模块使用的200Mhz参考时钟      
 .rst_n          (rst_n)          , //input,异步复位                       
 .rgmii_rxd      (rgmii_rxd)      , //input,4bits,RGIMII输入数据           
 .rgmii_rxclk    (rgmii_rxclk)    , //input,RGIMII输入控制信号               
 .rgmii_rxctrl   (rgmii_rxctrl)   , //input,RGIMII输入时钟                 
 .gmii_rxval     (gmii_rxval)     , //output,GMII数据有效标识                
 .gmii_rxd       (gmii_rxd)       , //output,8bits,GMII数据              
 .rgmii_rxclkbufg(rgmii_rxclkbufg)  //output,rgmii_rxclk全局时钟           
  );
                
 udp_rx 
 //参数定义,具体数值根据实际由顶层写入
 #(
  .SRC_MAC (SRC_MAC) , //发送端(以本模块角度)MAC地址
  .SRC_IP  (SRC_IP)  , //发送端(以本模块角度)IP地址 
  .DES_MAC (DES_MAC) , //接收端(以本模块角度)MAC地址
  .DES_IP  (DES_IP)    //接收端(以本模块角度)IP地址 
  )
 udp_rx
 (
 .clk       (rgmii_rxclkbufg) , //input,                                             
 .rst_n     (rst_n)           , //input,                                                            
 .gmii_rxd  (gmii_rxd)        , //input,8bits,接收gmii格式数据                             
 .gmii_rxval(gmii_rxval)      , //input,接收数据有效标识                                    
 .udpnum    (udpnum)          , //output,16bits,接收到的传输数据+udp头部的bytes数量（8）           
 .rxdata_on (rxdata_on)       , //output，正在接收数据标识（不含帧头等信息）                          
 .rx_data   (rx_data)         , //output,8bits,接收到source发送的数据                       
 .rx_done   (rx_done)           //output，接收完成                                       
 );                  
endmodule
