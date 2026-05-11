`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/17 16:41:20
// Design Name: 
// Module Name: lvds_rx
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


module lvds_rx(
    input wire rst_n,
    input wire en_in,
    input wire lvds_clk,  // LVDS时钟正端，75M
    input wire lvds_csl,  // LVDS 片选
    input wire lvds_data1,// LVDS数据1正端  ， 高
    input wire lvds_data2,// LVDS数据2正端 ， 低

    output reg [15:0] dat_rx, //数据输出
    output reg dat_update,
    output reg framenew_rst,  //新一帧到来标志信号
    output wire en,
    output wire en_n ,
    output [4:0] rx_cnt_debug ,
    output reg [15:0] rx_pts_cnt,
    //
    //debug 查看发送数
    output reg debug_rst,
    output reg [7:0] lineID,
    output reg [15:0] x,
    output reg [15:0] y,
    output reg [15:0] z

    );
     
    assign en = en_in; //    assign en = 1;
    assign en_n = ~en_in;  //    assign en_n = 0;  
    
//    reg [31:0] datrx_cnt;    
    
 reg [15:0] chksum; 
 //计数器 -- ？
//always @ (posedge clk or negedge rst_n) begin
//    if(!rst_n)
//        datrx_cnt <= 32'd0;
//    else if(datrx_cnt < 32'd600)  //
//        datrx_cnt <= datrx_cnt + 1'b1;
//    else
//        datrx_cnt <= 32'd0;
//end

//输出启动信号,高脉冲

reg lvds_csl_last;
always@(posedge lvds_clk)  lvds_csl_last<=lvds_csl;  
always @ (posedge lvds_clk ) begin
    if(rst_n==0) begin framenew_rst<=0;  end
    else if(lvds_csl_last == 1 && lvds_csl == 0) begin   //接收完毕
        framenew_rst<=1;
    end
    else 
        framenew_rst<=0;
end

//数据接收 双通道 16bits
reg [15:0]rx_data_buf;
reg [4:0] rx_cnt;  //lvds接收bit计数

assign rx_cnt_debug = rx_cnt;
always@(negedge lvds_clk ) begin
    if(framenew_rst==1) begin
        rx_pts_cnt<=0;    
    end
    else if(dat_update==1) begin
        rx_pts_cnt<=rx_pts_cnt+1;
    end

end

always@(negedge lvds_clk or negedge rst_n)  begin  //下降沿接收
     if(rst_n==0) begin
            rx_data_buf<=0;    
            rx_cnt<=0;
            dat_update<=0;
            dat_rx<=0;
            
        end
     else if(lvds_csl==0) begin  //接收使能
        if(rx_cnt<7) begin
            rx_data_buf<= {rx_data_buf[13:0],lvds_data1,lvds_data2};      //接收数据0~6
            rx_cnt<=rx_cnt+1; 
           dat_update<=0;
        end
        else if(rx_cnt==7) begin                 //接收7
            dat_update<=1;
            dat_rx<={rx_data_buf[13:0],lvds_data1,lvds_data2};
            rx_cnt<=0;
            
        end    
        else begin
             rx_cnt<=0;
             rx_data_buf<=0;
        end
     end
     else begin
        dat_update<=0;
        rx_cnt<=0;
        rx_data_buf<=0;
     end
end
//debug 查看发送数
//reg debug_rst;
//reg [7:0] lineID;

always@(negedge lvds_clk  )   begin
    if(rx_pts_cnt==6 && rx_cnt == 2) begin
        lineID<=dat_rx[7:0];    
        debug_rst<=1;
        end
    else begin
        lineID<=lineID;
        debug_rst<=0;
    end   
end

//输出xyz
always@(negedge lvds_clk  )   begin
    if(rx_pts_cnt>=8 && rx_pts_cnt<=10+1200*3 && rx_cnt == 2) begin
        if((rx_pts_cnt-16'd8)%3==0)
            x<=dat_rx;
        else if((rx_pts_cnt-16'd8)%3==1)
            y<=dat_rx;
         else 
            z<=dat_rx;
    end   
end

endmodule
