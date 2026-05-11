`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/09 10:27:42
// Design Name: 
// Module Name: FIFO_write
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


module FIFO_write(
  input lvds_clk,    //lvds clk 
  input lvds_csl,
  input rst_n,
  input [15:0] dat_rx,  //数据，上升沿采样
  input dat_update ,   //高脉冲，数据接收,上升沿采样
  input frame_rst_hp,   //高脉冲，
          //fifo
//     output                fifo_rst_hp,
    output               fifo_clk,     
    output     [15:0]    fifo_din,
    output      reg      fifo_wr_en,
    
    //标记输出
    output    reg [15:0] chksum,
    output   [15:0] rx_dat_cnt,
    output    reg        rx_done_hp   //UDP发送使能
    );

    assign fifo_clk = lvds_clk;
    assign fifo_din = dat_rx;
//    assign fifo_rst_hp = ~rst_n;
reg [7:0] fifo_state;
reg [15:0] dat_rx_last;

//记录接收字节及数量
reg [15:0] rx_cnt;  //记录接收数据次数
reg [15:0] rx_cnt_last;  //标记数据变化

assign rx_dat_cnt = rx_cnt;
always@(posedge lvds_clk or negedge rst_n)  begin  //下降沿接收
     if(rst_n==0 ) begin
            rx_cnt<=16'h0;       //空闲状态           
            dat_rx_last<=16'h0;
      end
      else if(frame_rst_hp ==1) begin
         rx_cnt<=0;  
         dat_rx_last<=16'h0;
      end   
      else if(rx_cnt<16'hffff) begin   //进入接受流程
          if(dat_update == 1)  begin
              rx_cnt<=rx_cnt+1;             
              dat_rx_last<=dat_rx;
          end
      end   
end

//接收数据

 always@(posedge lvds_clk) begin 
     if(rst_n==0 ) begin         
            rx_cnt_last<=16'h0;            
      end
      else if(frame_rst_hp ==1) begin
         rx_cnt_last<=16'h0;
      end   
      else
        rx_cnt_last<=rx_cnt;  
  
   end
 
always@(posedge lvds_clk or negedge rst_n)  begin  //上升降沿接收
     if(rst_n==0 ) begin           //启动              
            rx_done_hp<=0;                    
      end
      else if(frame_rst_hp==1)  begin
         fifo_state<=1;
         rx_done_hp<=0; 
         end
      else if(fifo_state == 1)  begin    //接收数据             
              if(rx_cnt_last!=rx_cnt)   //写入数据 
                    fifo_wr_en<=1;
              else
                    fifo_wr_en<=0;  
             //检测结束               
             //if((dat_rx_last==16'hAABB && dat_rx==16'hCCDD) || rx_cnt>16'd3615 )   
             if(lvds_csl == 1 || (dat_rx_last==16'hAABB && dat_rx==16'hCCDD) )
             begin  
                  fifo_state<=fifo_state+1;
                  rx_done_hp<=1;   
                  fifo_wr_en<=0; 
             end                      
      end
      else if(fifo_state == 2)  begin    //结束    
             fifo_state<=fifo_state+1;  
             rx_done_hp<=1;    //个周期高电平，
             fifo_wr_en<=1;   //多写数据，用于分割
      end
      else if(fifo_state == 3)  begin    //结束    
             fifo_state<=fifo_state+1;  
             rx_done_hp<=1;    //个周期高电平，
             fifo_wr_en<=1; 
      end
      else if(fifo_state == 4)  begin    //结束    
             fifo_state<=fifo_state+1;  
             rx_done_hp<=1;    //个周期高电平，
             fifo_wr_en<=1; 
      end
      else if(fifo_state == 5)  begin    //结束      
             rx_done_hp<=0;
             fifo_wr_en<=0; 
      end
end
 
 //计算chksum
 always@(posedge lvds_clk or negedge rst_n)  begin  //下降沿接收
     if(rst_n==0) begin           //启动  
            chksum<=0;         
      end
     else if(frame_rst_hp ==1) begin
            chksum<=0;
      end
      else if(rx_cnt >= 3 && rx_cnt <= 3605)  begin
        chksum<=chksum + dat_rx ; 
     end
 end
 
 endmodule