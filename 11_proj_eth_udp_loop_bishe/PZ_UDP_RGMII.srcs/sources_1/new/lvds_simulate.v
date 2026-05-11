`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/14 08:51:24
// Design Name: 
// Module Name: lvds_simulate
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


module lvds_simulate(
    input clk100M,
    input clk75M,
    input rst_n,
    input sel_sim,
    // lvds in
    input   lvds_clk_in,        // LVDS时钟正端，75M
    input   lvds_csl_in,        // LVDS 片选
    input   lvds_data1_in,     // LVDS数据1正端  ， 高
    input   lvds_data2_in,    // LVDS数据2正端 ， 低
        //lvds out
    output lvds_clk_out,        // LVDS时钟正端，75M
    output lvds_csl_out,        // LVDS 片选
    output lvds_data1_out,     // LVDS数据1正端  ， 高
    output lvds_data2_out    // LVDS数据2正端 ， 低

    );
   

   
   wire  lvds_clk;        // LVDS时钟正端，75M
   wire  lvds_csl;        // LVDS 片选
   wire  lvds_data1;     // LVDS数据1正端  ， 高
   wire  lvds_data2;   // LVDS数据2正端 ， 低

   assign lvds_clk_out = sel_sim==1 ? lvds_clk : lvds_clk_in;
   assign lvds_csl_out = sel_sim==1 ? lvds_csl : lvds_csl_in;
   assign lvds_data1_out = sel_sim==1 ? lvds_data1 : lvds_data1_in;
   assign lvds_data2_out = sel_sim==1 ? lvds_data2 : lvds_data2_in;
   //
   reg  fifo_empty;
   reg [55:0] timestramp;
   reg  [7:0]  line_id;
   reg  lvds_restart ;
   wire fifo_read_next;
   reg [47:0]  fifo_data;           //16*3,xyz
   wire [31:0] send_pts_cnt;
 
 // lvds发送重启
reg [31:0] cnt;
always@(posedge clk100M) begin
        if(rst_n==0) begin
            line_id<=0;
            timestramp<=0;
        end
        if(cnt<32'd78125)
            cnt<=cnt+1;            
        else   begin
            cnt<=0;
            line_id<=line_id+1;
            timestramp<=timestramp+32'd1000000;
         end
         
         if(cnt>32'd78125-2)   begin
            lvds_restart<=1;     
            end
         else
            lvds_restart<=0;
 end 
    
    //数据读取计数
    always@(posedge lvds_clk) begin
        if(send_pts_cnt>=32'd1200)
            fifo_empty=1;   
        else //if(lvds_restart==1)
            fifo_empty=0; 
    end
   
 //模拟FIFO数据输出
   reg [31:0] read_pts_cnt;
   reg [15:0] x;
   reg [15:0] y;
   reg [15:0] z;
 always@(posedge lvds_clk)  begin
   if(rst_n==0) begin
         read_pts_cnt<=0;
         x<=16'h1100;
         y<=16'h2200;
         z<=16'h3300;
     end
   else if(lvds_csl==1) begin
         read_pts_cnt<=0;
         x<=16'h1100;
         y<=16'h2200;
         z<=16'h3300; 
   end
   else if(fifo_read_next==1) begin  
      read_pts_cnt<=read_pts_cnt+1;
      fifo_data<={x,y,z}; 
      if(read_pts_cnt%120==119) begin
        x<=x+16'h0011;    //每120个点变一次
        y<=y+16'h0011;
        z<=z+16'h0011;
      end
         
   end
 end     

lvds_tx lvds_tx_inst(
   .clk(clk75M),          // 系统时钟, 
   .rst_n(rst_n),        // 异步复位，低电平有效
   .restart(lvds_restart),           // 门控信号，单周期脉冲信号，上升沿启动发送
   .timestramp(timestramp),
   .line_id(line_id), //激光线ID
   .pts_pFrame(16'd1200), //每线最小点数量
   //fifo read接口
   .lvds_rst(), //复位信号输出（未使用）
   .fifo_read_next(fifo_read_next),
   .fifo_data(fifo_data),
   .fifo_empty(fifo_empty),
   .lvds_busy(),  //1:busy（未使用）
   //LVDS芯片接口
   .lvds_clk(lvds_clk)   ,  // LVDS时钟正端，75M
   .lvds_csl(lvds_csl)   ,  // LVDS 片选
   .lvds_data1(lvds_data1), // LVDS数据1正端  ， 高
   .lvds_data2(lvds_data2), // LVDS数据2正端 ， 低
   .lvds_en(),    // LVDS芯片使能（未使用）
   .send_pts_cnt(send_pts_cnt)
);
  
endmodule



