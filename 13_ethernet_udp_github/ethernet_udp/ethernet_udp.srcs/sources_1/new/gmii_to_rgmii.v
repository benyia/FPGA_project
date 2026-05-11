`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2024 02:58:14 PM
// Design Name: 
// Module Name: gmii_to_rgmii
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

module gmii_to_rgmii
(
 input          clk_phase     ,
 input          rst_n         , //input,异步复位 
 input  [7:0]   gmii_txd      , //input,8bits,GMII输入数据    
 input          gmii_txen     , //input,GMII数据发送使能      
 input          gmii_txerr    , //input,GMII数据txen异或tx_er       
 output         rgmii_txclk   , //output,RGMII接口时钟通道         
 output         rgmii_txctrl  , //output,RGMII接口控制通道       
 output [3:0]   rgmii_txd       //output,4bits,RGMII接口数据通道     
 );
 
  //使用generate语句生成4个数据通道的ODDR模块,这种编写方式看起来比较简洁,当然也可以逐个编写    
  generate    
  genvar i;
   for(i=0;i<4;i=i+1) 
    begin: rgmii_txdbus
    ODDR 
    #(
     .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
     .INIT        (1'b0)             , // Initial value of Q: 1'b0 or 1'b1
     .SRTYPE      ("SYNC")            // Set/Reset type: "SYNC" or "ASYNC" 
      ) 
     ODDR_inst 
     (
     .Q (rgmii_txd[i]) , // 1-bit DDR output
     .C (clk_phase)    , // 1-bit clock input
     .CE(1'b1)         , // 1-bit clock enable input
     .D1(gmii_txd[i])  , // 1-bit data input (positive edge)
     .D2(gmii_txd[4+i]), // 1-bit data input (negative edge)
     .R (1'b0)         , // 1-bit reset
     .S (1'b0)           // 1-bit set
      );                 
    end
  endgenerate   
  
  //clk经过oddr的目的在于保持与data信号同样的延迟, Xilinx推荐方案 
    ODDR 
    #(
   .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
   .INIT(1'b0),                      // Initial value of Q: 1'b0 or 1'b1
   .SRTYPE("SYNC")                  // Set/Reset type: "SYNC" or "ASYNC" 
     )
    ODDR_clk 
    (
    .Q (rgmii_txclk), // 1-bit DDR output
    .C (clk_phase)  , // 1-bit clock input 
    .CE(1'b1)       , // 1-bit clock enable input
    .D1(1'b1)       , // 1-bit data input (positive edge)
    .D2(1'b0)       , // 1-bit data input (negative edge)
    .R (1'b0)       , // 1-bit reset
    .S (1'b0)         // 1-bit set
     ); 
  
  //生成RGMII控制通道,上升沿和下降沿的赋值按照协议规定
    ODDR 
    #(
   .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
   .INIT        (1'b0)             , // Initial value of Q: 1'b0 or 1'b1
   .SRTYPE      ("SYNC")            // Set/Reset type: "SYNC" or "ASYNC" 
    )
    ODDR_ctrl 
    (
    .Q (rgmii_txctrl),  // 1-bit DDR output
    .C (clk_phase)   ,  // 1-bit clock input
    .CE(1'b1)        ,  // 1-bit clock enable input
    .D1(gmii_txen)   ,  // 1-bit data input (positive edge)
    .D2(gmii_txerr)  ,  // 1-bit data input (negative edge)
    .R (1'b0)        ,  // 1-bit reset
    .S (1'b0)           // 1-bit set
     ); 
     
endmodule
