`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2024 02:29:59 PM
// Design Name: 
// Module Name: udp_loop_top_tb
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
`define clk_period 20

module udp_loop_top_tb();

   reg          rst_n         ;
   reg   [3:0]  rgmii_rxd     ;
   reg          rgmii_rxctrl  ;
   reg          rgmii_rxclk   ;
   wire   [3:0] rgmii_txd     ;
   wire         rgmii_txctrl  ;
   wire         rgmii_txclk   ;  
   
   reg  [3:0]   ethernet_data[151:0]  ;
   initial $readmemh ("E:/work/FPGA/2023/2023/Project/XC7A35T-FGG484/HardwareTestCode/Realease/ethernet_udp/ethernet_udp.srcs/sim_1/new/dataloop.txt",ethernet_data);
   
   reg        clk ;
   initial    clk=0;
   always     #(`clk_period/2) clk = ~clk;  
    
   reg        clk_virtual ;    
   initial    clk_virtual=0;
   always #4  clk_virtual = ~clk_virtual; //设定Ethernet为1000M,则rxclk 为125Mhz,此为数据发送的虚拟时钟
   
   always rgmii_rxclk=#2 clk_virtual;     //模拟PHY芯片端clk 输出delay 2ns
   
   reg  start      ;
   reg  [6:0] cnt  ; //rxd数据传输的计数器,目的将存储的数据依次赋予rgmii_rxd

   always@(negedge clk_virtual or negedge rst_n)
   if(!rst_n) cnt<=7'b0;
     else if(start) 
     begin  if(cnt==7'd75)  #2 cnt<=7'b0;   //共152 4bits
            else  #2 cnt<=cnt+1'b1; end 
  
   always@(posedge clk_virtual)
   if(start) begin  rgmii_rxd<=ethernet_data[(cnt)*2]; rgmii_rxctrl<=1'b1; end
   else      begin rgmii_rxd<=4'b0; rgmii_rxctrl<=1'b0; end
   
   always@(negedge clk_virtual)
   if(start) rgmii_rxd<=ethernet_data[((cnt*2)+1'b1)];
   else      rgmii_rxd<=4'b0; 
  
   initial 
   begin
   rst_n<=0; 
   start<=1'b0;
   #1000 rst_n<=1;
   #800 start<=1'b1; 
   #608 start<=1'b0;   // 一组数据传输完毕    
   #800 start<=1'b1; 
   #608 start<=1'b0;   // 一组数据传输完毕
   #3000  
   $stop;
   end

 udp_loop_top udp_loop_top
 (
   .clk         (clk)            ,
   .rst_n       (rst_n)          ,
   .rgmii_rxd   (rgmii_rxd)      ,
   .rgmii_rxctrl(rgmii_rxctrl)   ,
   .rgmii_rxclk (rgmii_rxclk)    ,
   .rgmii_txd   (rgmii_txd   )   ,
   .rgmii_txctrl(rgmii_txctrl)   ,
   .rgmii_txclk (rgmii_txclk )  
  );
endmodule
