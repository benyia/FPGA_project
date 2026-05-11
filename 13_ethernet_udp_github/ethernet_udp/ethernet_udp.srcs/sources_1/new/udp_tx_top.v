`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2024 03:00:52 PM
// Design Name: 
// Module Name: udp_tx_top
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

module udp_tx_top
#(      
  parameter  SRC_MAC  = 48'b0    , //发送端(以本模块角度)MAC地址           
  parameter  SRC_IP   = 32'b0    , //发送端(以本模块角度)IP地址          
  parameter  DES_MAC  = 48'b0    , //接收端(以本模块角度)MAC地址         
  parameter  DES_IP   = 32'b0    , //接收端(以本模块角度)IP地址          
  parameter  IP_VER   = 4'h4     , //IP首部 协议版本    IPV4
  parameter  IP_HL    = 4'h5     , //IP首部 首部的长度  ip首部字节数5*4
  parameter  IP_TOS   = 8'h0     , //IP首部 服务类型                
  parameter  IP_ID    = 16'h3f48 , //IP首部 ID标识      本实验中定义            
  parameter  IP_FLAG  = 3'b0     , //IP首部 FLAGS               
  parameter  IP_OFFSET= 13'b0    , //IP首部 分片偏移量               
  parameter  IP_TIME  = 8'h80    , //IP首部 生存时间                
  parameter  IP_PRT   = 8'h11      //IP首部 协议号      UDP协议 17(十进制) 
  ) 
 (
  input            clk_125mhz   , //input,125Mhz时钟
  input            clk_phase    , //input,125Mhz时钟相移
  input            rst_n        , //input,异步复位
  input            tx_en        , //input,启动发送
  input    [7:0]   tx_data      , //input,8bits,待传输的数据,不含任何首部等数据
  input    [15:0]  datanum      , //input,要传输的数据bytes数量,不包含任何首部
  output           tx_on        , //output,帧发送状态标识
  output           txdata_on    , //output,UDP数据发送状态标识
  output   [3:0]   rgmii_txd    , //output,4bits,RGMII接口数据通道     
  output           rgmii_txclk  , //output,RGMII接口时钟通道      
  output           rgmii_txctrl   //output,RGMII接口控制通道 
   );
     
  wire    [31:0]   crc_value   ;
  wire             crc_en      ;
  wire             ipsum_en    ;
  wire    [15:0]   ipchecksum  ;
  wire    [7:0]    gmii_txd    ;
  wire             tx_done     ;

   udp_tx 
   #(      
    .SRC_MAC  (SRC_MAC)  , //发送端(以本模块角度)MAC地址            
    .SRC_IP   (SRC_IP)   , //发送端(以本模块角度)IP地址             
    .DES_MAC  (DES_MAC)  , //接收端(以本模块角度)MAC地址            
    .DES_IP   (DES_IP)   , //接收端(以本模块角度)IP地址             
    .IP_VER   (IP_VER)   , //IP首部 协议版本    IPV4           
    .IP_HL    (IP_HL)    , //IP首部 首部的长度  ip首部字节数5*4      
    .IP_TOS   (IP_TOS)   , //IP首部 服务类型                   
    .IP_ID    (IP_ID)    , //IP首部 ID标识      本实验中定义       
    .IP_FLAG  (IP_FLAG)  , //IP首部 FLAGS                  
    .IP_OFFSET(IP_OFFSET), //IP首部 分片偏移量                  
    .IP_TIME  (IP_TIME)  , //IP首部 生存时间                   
    .IP_PRT   (IP_PRT)     //IP首部 协议号      UDP协议 17(十进制) 
   )
   udp_tx 
   ( 
   .clk        (clk_125mhz) , //input,时钟                                  
   .rst_n      (rst_n)      , //input,异步复位                                
   .tx_en      (tx_en)      , //input,发送使能                                
   .ipchecksum (ipchecksum) , //input,16bits,ipchecksum模组计算结果             
   .crc_value  (crc_value)  , //input,32bits,CRC模组计算结果                    
   .datanum    (datanum)    , //input,16bits,此次需要传输的数据量,以Bytes为单位         
   .tx_data    (tx_data)    , //input,8bits,待发送的数据                        
   .ipsum_en   (ipsum_en)   , //output,使能IP首部checksum值计算                  
   .tx_on      (tx_on)      , //output,帧发送状态标识                             
   .txdata_on  (txdata_on)  , //output,发送数据状态标识,仅包含UDP数据部分                
   .tx_done    (tx_done)    , //output,一帧发送完成                             
   .crc_en     (crc_en)     , //output,使能CRC32计算                          
   .gmii_txd   (gmii_txd)     //output,8bits,gmii数据发送                     
    );
       
  gmii_to_rgmii gmii_to_rgmii
  (
  .clk_phase    (clk_phase)    ,  //input,时钟              
  .rst_n        (rst_n)        ,  //input,异步复位                 
  .gmii_txd     (gmii_txd)     ,  //input,8bits,GMII输入数据       
  .gmii_txen    (tx_on)        ,  //input,GMII数据发送使能           
  .gmii_txerr   (tx_on^1'b0)   ,  //input,GMII数据txen异或tx_er    
  .rgmii_txclk  (rgmii_txclk)  ,  //output,RGMII接口时钟通道         
  .rgmii_txctrl (rgmii_txctrl) ,  //output,RGMII接口控制通道         
  .rgmii_txd    (rgmii_txd)       //output,4bits,RGMII接口数据通道   
   );    
          
  ip_checksum 
   #(
   .IP_VER   (IP_VER)    , //IP首部 协议版本    IPV4           
   .IP_HL    (IP_HL)     , //IP首部 首部的长度  ip首部字节数5*4      
   .IP_TOS   (IP_TOS)    , //IP首部 服务类型                   
   .IP_ID    (IP_ID)     , //IP首部 ID标识      本实验中定义       
   .IP_FLAG  (IP_FLAG)   , //IP首部 FLAGS                  
   .IP_OFFSET(IP_OFFSET) , //IP首部 分片偏移量                  
   .IP_TIME  (IP_TIME)   , //IP首部 生存时间                   
   .IP_PRT   (IP_PRT)    , //IP首部 协议号      UDP协议 17(十进制) 
   .IP_SRC   (SRC_IP)    , //发送端(以本模块角度)IP地址  
   .IP_DES   (DES_IP)      //接收端(以本模块角度)IP地址
    ) 
   ip_checksum
   (  
   .clk         (clk_125mhz)  , //input,时钟                       
   .rst_n       (rst_n)       , //input,异步复位                     
   .ipsum_en    (ipsum_en)    , //input,使能IPSUM值计算               
   .ip_ttl      (datanum+28)  , //input,16bits,IP封包总长度           
   .ip_checksum (ipchecksum)    //output,16bits,IP封包checksum值计算结果
    );
 
   crc32 crc32
   (
   .clk         (clk_phase) , //input,时钟                        
   .rst_n       (rst_n)     , //input,异步复位                    
   .data_in     (gmii_txd)  , //input,待CRC计算数据                
   .crc_en      (crc_en)    , //input,使能CRC计算                 
   .crc_default (tx_done)   , //input,将CRC值恢复为默认值             
   .crc_value   (crc_value)   //output,32bits,计算出的32bits CRC值 
    );
 endmodule
