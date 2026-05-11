`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2024 02:58:55 PM
// Design Name: 
// Module Name: rgmii_to_gmii
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

module rgmii_to_gmii
(
 input         clk_200m        , //input,IDELAY模块使用的200Mhz参考时钟
 input         rst_n           , //input,异步复位
 input  [3:0]  rgmii_rxd       , //input,4bits,RGIMII输入数据         
 input         rgmii_rxclk     , //input,RGIMII输入控制信号       
 input         rgmii_rxctrl    , //input,RGIMII输入时钟         
 output        gmii_rxval      , //output,GMII数据有效标识
 output [7:0]  gmii_rxd        , //output,8bits,GMII数据
 output        rgmii_rxclkbufg   //output,rgmii_rxclk全局时钟
 );
    
  wire        gmii_rxdv        ; //rxctrl 在clk上升沿输出rx data valid有效标识
  wire        gmii_rxerr       ; //rxctrl 在clk上升沿输出gmii_rxerr=GMII_RX_ER (XOR) GMII_RX_DV
                                 //协议采用异或值的原因是减少正常传输的信号切换(即功率)
  wire        rgmii_rxclkbufio ; //rgmii_rxclk io区域时钟
  wire        rgmii_rxctrldly  ; //rgmii control信号延迟
  wire [3:0]  rgmii_rxddly     ; //rgmii 数据延迟
  wire        rgmii_rxclkdly   ; //rgmii 时钟信号延迟

 //rgmii 时钟信号进入全局时钟域控制FPGA LOGIC                        
  BUFG BUFG_rxclk 
  (
   .O(rgmii_rxclkbufg), // 1-bit output: Clock output
   .I(rgmii_rxclk)      // 1-bit input: Clock input
  ); 
 //rgmii 时钟信号进入IO时钟域取样输入的IO端口data 
  BUFIO BUFIO_rxclk 
   (
   .O(rgmii_rxclkbufio), // 1-bit output: Clock output (connect to I/O clock loads).
   .I(rgmii_rxclk)       // 1-bit input: Clock input (connect to an IBUF or BUFMR).
   ); 
  
  //为了调整数据通道和控制通道与时钟的时序(相位),将数据及控制信号接入IDELAY模块,进行时序调整.
  //UG471:if the IDELAYE2 or ODELAYE2 primitives are instantiated, the IDELAYCTRL module 
  //must also be instantiated
  (* IODELAY_GROUP =  "rgmii_rx" *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL   
   IDELAYCTRL IDELAYCTRL_clk 
   (
   .RDY    (),          // 1-bit output: Ready output
   .REFCLK (clk_200m),  // 1-bit input: Reference clock input
   .RST    (1'b0)       // 1-bit input: Active high reset input
   );
      //通过IODELAY GROUP 定义建立与下述IDELAYCTRL原语的联系                         
   (* IODELAY_GROUP = "rgmii_rx" *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTR 
   IDELAYE2
   #(
    .CINVCTRL_SEL         ("FALSE")  ,// Enable dynamic clock inversion (FALSE, TRUE)
    .DELAY_SRC            ("IDATAIN"),// Delay input (IDATAIN, DATAIN)
    .HIGH_PERFORMANCE_MODE("FALSE")  , // Reduced jitter ("TRUE"), Reduced power ("FALSE")
    .IDELAY_TYPE          ("FIXED")  , // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
    .IDELAY_VALUE         (0)         , // Input delay tap setting (0-31) //idelay value 25taps*78ps=2ns                                             
    .PIPE_SEL             ("FALSE")  , // Select pipelined mode, FALSE, TRUE
    .REFCLK_FREQUENCY     (200.0)     , // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
    .SIGNAL_PATTERN       ("DATA")     // DATA, CLOCK input signal
    )
   IDELAYE2_ctrl 
   (
   .CNTVALUEOUT(),               // 5-bit output: Counter value output
   .DATAOUT    (rgmii_rxctrldly),// 1-bit output: Delayed data output
   .C          (clk_200m)       ,// 1-bit input: Clock input
   .CE         (1'b0)           ,// 1-bit input: Active high enable increment/decrement input
   .CINVCTRL   (1'b0)           ,// 1-bit input: Dynamic clock inversion input
   .CNTVALUEIN (5'b0)           ,// 5-bit input: Counter value input
   .DATAIN     (1'b0)           ,// 1-bit input: Internal delay data input
   .IDATAIN    (rgmii_rxctrl)   ,// 1-bit input: Data input from the I/O
   .INC        (1'b0)           ,// 1-bit input: Increment / Decrement tap delay input
   .LD         (1'b0)           ,// 1-bit input: Load IDELAY_VALUE input
   .LDPIPEEN   (1'b0)           ,// 1-bit input: Enable PIPELINE register to load data input
   .REGRST     (1'b0)            // 1-bit input: Active-high reset tap-delay input
    ); 
 
  //使用generate语句生成4个数据通道的IDELAY模块,目的是代码的简洁,也可以逐个编写  
  //通过IODELAY GROUP 定义建立与下述IDELAYCTRL原语的联系        
  generate    
  genvar j;
  for(j=0;j<4;j=j+1) 
   begin: rgmii_rxddlybus  
    (* IODELAY_GROUP = "rgmii_rx" *)  // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTR 
    IDELAYE2 
    #(
    .CINVCTRL_SEL         ("FALSE")  , // Enable dynamic clock inversion (FALSE, TRUE)
    .DELAY_SRC            ("IDATAIN"), // Delay input (IDATAIN, DATAIN)
    .HIGH_PERFORMANCE_MODE("FALSE")  , // Reduced jitter ("TRUE"), Reduced power ("FALSE")
    .IDELAY_TYPE          ("FIXED")  , // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
    .IDELAY_VALUE         (0)         , // Input delay tap setting (0-31) //idelay value 25taps*78ps=2ns                                             
    .PIPE_SEL             ("FALSE")  , // Select pipelined mode, FALSE, TRUE
    .REFCLK_FREQUENCY     (200.0)     , // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
    .SIGNAL_PATTERN       ("DATA")     // DATA, CLOCK input signal
    )
    IDELAYE2_rxdly
    (
    .CNTVALUEOUT()              , // 5-bit output: Counter value output
    .DATAOUT   (rgmii_rxddly[j]), // 1-bit output: Delayed data output
    .C         (clk_200m)       , // 1-bit input: Clock input
    .CE        (1'b0)           , // 1-bit input: Active high enable increment/decrement input
    .CINVCTRL  (1'b0)           , // 1-bit input: Dynamic clock inversion input
    .CNTVALUEIN(5'b0)           , // 5-bit input: Counter value input
    .DATAIN    (1'b0)           , // 1-bit input: Internal delay data input
    .IDATAIN   (rgmii_rxd[j])   , // 1-bit input: Data input from the I/O
    .INC       (1'b0)           , // 1-bit input: Increment / Decrement tap delay input
    .LD        (1'b0)           , // 1-bit input: Load IDELAY_VALUE input
    .LDPIPEEN  (1'b0)           , // 1-bit input: Enable PIPELINE register to load data input
    .REGRST    (1'b0)             // 1-bit input: Active-high reset tap-delay input
    );
     end
     endgenerate 
  
  //rgmii接口是DDR信号,使用IDDR原语将DDR信号转换成SDR信号
  //rgmii rxctrl 数据提取为gmii_rxdv,gmii_rxerr    
  IDDR 
  #(
  .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                           //  or "SAME_EDGE_PIPELINED" 
  .INIT_Q1(1'b0),          // Initial value of Q1: 1'b0 or 1'b1
  .INIT_Q2(1'b0),          // Initial value of Q2: 1'b0 or 1'b1
  .SRTYPE ("SYNC")        // Set/Reset type: "SYNC" or "ASYNC" 
   )
   IDDR_rxctrl 
   (
  .Q1(gmii_rxdv)       , // 1-bit output for positive edge of clock
  .Q2(gmii_rxerr)      , // 1-bit output for negative edge of clock
  .C (rgmii_rxclkbufio), // 1-bit clock input
  .CE(1'b1)            , // 1-bit clock enable input
  .D (rgmii_rxctrldly) , // 1-bit DDR data input
  .R (!rst_n)          , // 1-bit reset
  .S (1'b0)              // 1-bit set
   );
  assign gmii_rxval=gmii_rxdv&gmii_rxerr;   //接收数据有效
 
   //提取出的数据bit位对应关系按照接口协议定义
   //将rgmii_rxddly0 提取出gmii_rxd[0]/gmii_rxd[4]
   //将rgmii rxddly1 提取出gmii_rxd[1]/gmii_rxd[5]
   //将rgmii rxddly2 提取出gmii_rxd[2]/gmii_rxd[6]
   //将rgmii rxddly3 提取出gmii_rxd[3]/gmii_rxd[7]    
  generate    
   genvar i;
   for(i=0;i<4;i=i+1) 
    begin: rgmii_rxdbus   
    IDDR 
   #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                             //  or "SAME_EDGE_PIPELINED" 
    .INIT_Q1(1'b0)   ,                       // Initial value of Q1: 1'b0 or 1'b1
    .INIT_Q2(1'b0)   ,                       // Initial value of Q2: 1'b0 or 1'b1
    .SRTYPE("SYNC")                         // Set/Reset type: "SYNC" or "ASYNC" 
    )
    IDDR_rxd
    (
    .Q1(gmii_rxd[i])     , // 1-bit output for positive edge of clock
    .Q2(gmii_rxd[4+i])   , // 1-bit output for negative edge of clock
    .C (rgmii_rxclkbufio), // 1-bit clock input
    .CE(1'b1)            , // 1-bit clock enable input
    .D (rgmii_rxddly[i]) , // 1-bit DDR data input
    .R (!rst_n)          , // 1-bit reset
    .S (1'b0)               // 1-bit set
    );
    end
   endgenerate 
     
endmodule
