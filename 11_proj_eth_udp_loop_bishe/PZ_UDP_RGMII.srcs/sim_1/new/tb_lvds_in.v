`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/11 10:13:49
// Design Name: 
// Module Name: tb_lvds_in
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


module tb_lvds_in(
    );

    parameter   CYCLE   =   20;  //50M 
    parameter   CYCLE2   =   13;  // 76.9M 
    
    reg clk ;
    reg clk75M;
    reg rst_n;
    reg clk100M;
       
    //lvds
    wire lvds_clk;  // LVDS时钟正端，75M
    wire lvds_csl;  // LVDS 片选
    wire lvds_data1;// LVDS数据1正端  ， 高
    wire lvds_data2;// LVDS数据2正端 ， 低
//    reg fifo_empty;
   //
//   reg [55:0] timestramp;
//   reg  [7:0]  line_id;
//   reg  lvds_restart ;
//   wire fifo_read_next;
//   reg [47:0]  fifo_data;   //16*3,xyz
//   wire [31:0] send_pts_cnt;
   always #(CYCLE/2) clk=~clk; 
   always #(CYCLE2/2) clk75M = ~clk75M; 
   always #5 clk100M = ~clk100M; 
 
// // lvds发送
//    reg [31:0] cnt;
//    always@(posedge clk100M) begin
//        if(cnt<32'd78125)
//            cnt<=cnt+1;            
//         else   begin
//            cnt<=0;
//            line_id<=line_id+1;
//            timestramp<=timestramp+32'd1000000;
//         end
         
//         if(cnt>32'd78125-2)   begin
//            lvds_restart<=1;     
//            end
//         else
//            lvds_restart<=0;
//    end
    
//    //数据读取计数
//    always@(posedge clk) begin
//        if(send_pts_cnt==32'd1200)
//            fifo_empty=1;   
//        else if(lvds_restart==1)
//            fifo_empty=0; 
//    end
  
    initial begin
        clk = 0;
        clk75M = 0;  
        clk100M = 0;
        rst_n = 0;
//        timestramp = 0;
//        line_id =0;
//        fifo_empty=0;
        # 100;
        rst_n = 1; 
//        lvds_restart=1;
        # 10;                  
    end
// //模拟FIFO数据输出
//   reg [31:0] read_pts_cnt;
//   reg [15:0] x;
//   reg [15:0] y;
//   reg [15:0] z;
// always@(posedge lvds_clk)  begin
//   if(rst_n==0) begin
//         read_pts_cnt<=0;
//         x<=16'h1100;
//         y<=16'h2200;
//         z<=16'h3300;
//     end
//   else if(lvds_csl==1) begin
//         read_pts_cnt<=0;
//         x<=16'h1100;
//         y<=16'h2200;
//         z<=16'h3300;
//   end
//   else if(fifo_read_next==1) begin  
//      read_pts_cnt<=read_pts_cnt+1;
//      fifo_data<={x,y,z}; 
//      if(read_pts_cnt%120==119) begin
//        x<=x+16'h0011;    //每120个点变一次
//        y<=y+16'h0011;
//        z<=z+16'h0011;
//      end
         
//   end
// end     

// lvds_tx lvds_tx_inst(
//    .clk(clk75M),          // 系统时钟, 
//    .rst_n(rst_n),        // 异步复位，低电平有效
//    .restart(lvds_restart),           // 门控信号，单周期脉冲信号，上升沿启动发送
//    .timestramp(timestramp),
//    .line_id(line_id), //激光线ID
//    //fifo read接口
////    output reg lvds_rst, //复位信号输出
//    .fifo_read_next(fifo_read_next),
//    .fifo_data(fifo_data),
//    .fifo_empty(fifo_empty),
////    output reg lvds_busy,  //1:busy
//    //LVDS芯片接口
//    .send_pts_cnt(send_pts_cnt),
//    .lvds_clk(lvds_clk)   ,  // LVDS时钟正端，75M
//    .lvds_csl(lvds_csl)   ,  // LVDS 片选
//    .lvds_data1(lvds_data1), // LVDS数据1正端  ， 高
//    .lvds_data2(lvds_data2) // LVDS数据2正端 ， 低
////    output wire lvds_en     // LVDS芯片使能
//);

  wire en;
  wire en_n;
  wire eth_mdc;
  wire eth_mdio;
//  wire lvds_clk;
//  wire lvds_csl;
//  wire lvds_data1;
//  wire lvds_data2;
  wire net_rx_ctl;
  wire net_rxc;
  wire [3:0]net_rxd;
  wire net_tx_ctl;
  wire net_txc;
  wire [3:0]net_txd;
  wire sys_clk;
  wire sys_rst_n;

  design_1 design_1_i
       (.en(en),
        .en_n(en_n),
        .eth_mdc(eth_mdc),
        .eth_mdio(eth_mdio),
        .lvds_clk(lvds_clk),
        .lvds_csl(lvds_csl),
        .lvds_data1(lvds_data1),
        .lvds_data2(lvds_data2),
        .net_rx_ctl(net_rx_ctl),
        .net_rxc(clk100M),
        .net_rxd(net_rxd),
        .net_tx_ctl(net_tx_ctl),
        .net_txc(net_txc),
        .net_txd(net_txd),
        .sys_clk(clk),
        .sys_rst_n(rst_n));


endmodule



