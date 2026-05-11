`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/10 13:43:57
// Design Name: 
// Module Name: FIFO_trans
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
//读取fifo，并做协议转换后，写入新的fifo

module FIFO_trans(

  input                   clk,    // fifo 时钟
  input                   rst_n,
  input                   lvds_rst,
  input                   newframe_rst_in,  //高脉冲, lvds开启新一帧接收
  //input                   udp_tx_done,  //udp发送完成，高脉冲
  input                   udp_tx_busy,  //忙标记
    //fifo --  
  input          [15:0]   fifo_din,             //输入fifo数据
  input                   fifo_in_empty,        //输入fifo计数
  output                  fifo_rd_en,         //输入fifo 读使能
  output         [31:0]   fifo_dout,  //输出
  output   reg            fifo_wr_en, //输出
  output   reg   [15:0]   rx_cnt,   //记录已接收数据数量（2bytes），从1开始。
  output   reg            tx_send_en ,           //UDP发送使能
  output   reg   [7:0]    line_ID ,  //记录线ID 0~127
  output   reg   [15:0]    X,
  output   reg   [15:0]    Y,
  output   reg   [15:0]    Z
  
   // output  reg  fifo_rst        //fifo复位
    );
parameter SEND_TIMES = 8'D10 ;  //发送次数
reg            fifo_rd_en1;
reg [7:0]  fifo_send_cnt;      //拆分计数
reg [7:0]  udpsend_pack_cnt;  //发送udp计数
 reg  fifo_wr_one_done;  //fifo写入1帧完成    
//数据刷入fifo, 保存完整协议
//reg buf32_byte_cnt;   //接收byte计数
//reg buf32_byte_cnt_last;
reg [7:0]  fifo_rd_state;   //fifo接收状态，主要是头部信息接收
reg [31:0] fifo_buf32;  //输出缓存
assign  fifo_dout = fifo_buf32;  //输出fifo
//assign  tx_send_en = fifo_wr_one_done;

assign fifo_rd_en = (fifo_in_empty==0) ? fifo_rd_en1:0;

//读取FIFO数据--计数
reg         newframe_rst_last;  //记录上一个，检测边沿
reg         newframe_rst;  // 检测边沿
reg [15:0]  fifo_din_last;  //上一次读取值

reg [15:0] rx_cnt_last;  //标记数据修改

//always@(posedge clk) rx_cnt_last<=rx_cnt; 

always@(posedge clk or posedge newframe_rst_in) begin
    if(newframe_rst_in==1 ) begin
        newframe_rst<=1; 
        end
    else  begin
        newframe_rst<=0;    
    end
end
always@(posedge clk) newframe_rst_last<=newframe_rst; 
always@(posedge clk) begin
    if(fifo_rd_en1==1) begin
        fifo_din_last<=fifo_din;
    end  
end
//reg [31:0]  header;  //记录头部
reg [55:0]  timestramp;  //记录时间戳
//reg [7:0]   line_ID;  //记录线ID 0~127
//reg [1:0]   rx_xyz_flag; //标记到的是xyz 0~2

//  ******************   读FIFO数据 头部   ******************   
always@(posedge clk or negedge rst_n)  begin  //上升沿接收
     if(rst_n==0) begin
            fifo_rd_state<=0;       
            rx_cnt<=0;  
            rx_cnt_last<=0;   
               
     end
     else if(newframe_rst_last == 0 && newframe_rst == 1)  //新一个   
      begin
            fifo_rd_state<=0;       
            rx_cnt<=0; 
            rx_cnt_last<=0;   
                        
      end      
      else if(fifo_rd_state==0)  begin  //帧头识别
            if(fifo_din_last== 16'h146F && fifo_din == 16'HEB90) begin
                fifo_rd_state<=fifo_rd_state+1;    //进入接收状态        
                rx_cnt<=3;   
            end
      end 
      else if(fifo_rd_state == 1 && fifo_rd_en1==1)  begin           //头部接收
           if(rx_cnt<16'hffff)  begin
                rx_cnt<=rx_cnt+1;  
                rx_cnt_last<=rx_cnt; 
            end
      end  
//      else if(fifo_rd_state == 2 && fifo_rd_en1==1)  begin   // 其余数据接收            
//            //if(rx_cnt>=367 || (fifo_din_last== 16'hAABB && fifo_din == 16'HCCDD))  begin  //120*3+7    
          
//       end       
 end
 
 //接收头部
 always@(posedge clk ) begin
          case(rx_cnt)             
//             16'd1: begin    header[31:16] = fifo_din;             end  //接收 
//             16'd2: begin   header[15:0 ] = fifo_din; timestramp<=0; end
             16'd3: begin   timestramp[55:40]<= fifo_din;           end
             16'd4: begin   timestramp[39:24]<= fifo_din;           end
             16'd5: begin   timestramp[23:8]<= fifo_din;            end
             16'd6: begin   timestramp[7:0]<= fifo_din[15:8];   line_ID <= fifo_din[7:0];       end
             16'd7: begin           end  //预留            
          endcase 
 end
 
 //发送分包数量 计数
  reg [7:0] fifo_wr_state;  //写入状态
 always@(posedge clk) begin
    if(rst_n==0 || rx_cnt == 3)
        fifo_send_cnt<=0;
    else if(fifo_wr_state == 12)
        fifo_send_cnt<=fifo_send_cnt+1; 
 end
 
 //发送点云计数
 reg [15:0] tx_pts_cnt;
 always@(posedge clk) begin
      if(rst_n==0) begin
        tx_pts_cnt<=0;
      end
      else if(newframe_rst_last == 0 && newframe_rst == 1)  //新一个   
      begin
         tx_pts_cnt<=0;
      end
      else  begin              //头部接收完毕
            if(fifo_wr_one_done == 1 && fifo_send_cnt<SEND_TIMES ) begin
                tx_pts_cnt<=0;
            end
            else if(rx_cnt>=7 & fifo_rd_en1==1)  begin
                tx_pts_cnt<=tx_pts_cnt+1;
            end
      end
 end
 
// reg udp_busy;
 reg udp_tx_busy_last;
 always@(posedge clk ) udp_tx_busy_last <= udp_tx_busy;
  
  //记录发送了多少udp包
always@(posedge clk or negedge rst_n)  begin  //上升沿接收
    if (!rst_n) begin  //新一帧，清空发送
        udpsend_pack_cnt<=0;
    end
    else if(rx_cnt == 3) begin
        udpsend_pack_cnt<=0;
    end   
    else if(udp_tx_busy_last==0 && udp_tx_busy==1 && udpsend_pack_cnt<8'd255)  begin        //else if(udp_tx_done==1 && udpsend_pack_cnt<8'd255)  begin        
         udpsend_pack_cnt<=udpsend_pack_cnt+1;         
     end
 end
       
 
 //启动udp发送控制
//reg [7:0] udp_start_cnt;
// always@(posedge clk ) begin   //计时
//    if(!rst_n) begin    
//        udp_start_cnt<=0;
//    end
//    if(udp_start_cnt<8'd200)
//        udp_start_cnt<=udp_start_cnt+1;
//    else if(tx_send_en==1)
//        udp_start_cnt<=0;
//    else
//        udp_start_cnt<=udp_start_cnt;
//end
 always@(posedge clk ) begin   //每200个周期检查一次
    if(!rst_n) begin      
        tx_send_en<=0;
    end
    if(udpsend_pack_cnt<fifo_send_cnt &&  udp_tx_busy==0)
        tx_send_en<=1;
    else
        tx_send_en<=0;
end

  
//  ******************   写FIFO数据   ******************  
 reg [3:0] fifo_cycle_index;  //一个点云写9个字节，一次存入4个字节，4*9=36，标记读取的字节数据，12个为一循环

 reg [7:0] cnt_tmp;
 always@(posedge clk or negedge rst_n)  begin  //上升沿接收
     if(rst_n==0) begin
        fifo_rd_en1<=0;              //开启读取      
        fifo_wr_one_done<=0;
        fifo_wr_state<=0;
     end
     else if (newframe_rst_last == 0 && newframe_rst == 1) begin            
            fifo_rd_en1<=1;              //开启读取      
            fifo_wr_one_done<=0;
         
            fifo_wr_state<=1;      //头部写入
      end
      else if(fifo_in_empty == 1) begin //fifo 空
            fifo_wr_state<=0;
            fifo_rd_en1<=0;        //关闭读 
      end
      else  begin    //接收数据
            case(fifo_wr_state)
              8'd0:  begin    //结束状态
                 fifo_rd_en1<=0;        //关闭读  
                 
              end
              8'd1: begin //帧头写入
                         if(rx_cnt>6 && tx_pts_cnt==0 ) begin      
                             fifo_wr_one_done<=0;    fifo_rd_en1<=0;     //停止读取
                             fifo_buf32<=32'HEB90AA55;   fifo_wr_en<=1;    //发送FIFO 新帧头  
                             fifo_wr_state<=fifo_wr_state+1;   
                          end  //发送头部
                          else begin
                              fifo_wr_en<=0; 
                              fifo_wr_one_done<=0;
                          end
              end
              8'd2: begin //写入0x55+时间戳 3B
                        fifo_buf32 <= { 8'H55,  timestramp[55:32] };   fifo_wr_en<=1; //发送FIFO  时间戳高 3B   
                         fifo_wr_state<=fifo_wr_state+1;  
              end    
              8'd3:begin //写入时间戳 4B  
                         //fifo_buf32 <= { timestramp[31:16],fifo_din};  fifo_wr_en<=1;         //发送FIFO 时间戳低4B   
                         fifo_buf32 <=  timestramp[31:0];  fifo_wr_en<=1;         //发送FIFO 时间戳低4B   
                          fifo_wr_state<=fifo_wr_state+1;  fifo_rd_en1<=1; 
              end  
              8'd4: begin
                         //fifo_buf32 <= { 16'h045A,8'h6A, line_ID };    fifo_wr_en<=1;    //发送包长度2B+6a+ID    
                         fifo_buf32 <= { line_ID,fifo_send_cnt,8'h6A, line_ID };    fifo_wr_en<=1;    //发送包长度2B+6a+ID    
                         
                          fifo_wr_state<=fifo_wr_state+1;  
                          fifo_cycle_index<=0;  
                          fifo_rd_en1<=1; 
              end            
              8'd5: begin //点云写入
                     if(fifo_cycle_index<4'd12) 
                               fifo_cycle_index <= fifo_cycle_index+1;   
                        else
                               fifo_cycle_index <= 0;      
                               
                        case(fifo_cycle_index)  //12个数据，4组点，对应一个循环（4，9公倍数）
                          4'd0: begin   fifo_buf32 <= { fifo_buf32[15:0], fifo_din};               fifo_wr_en<=0;   fifo_rd_en1<=1;  X<= fifo_din; end  //等待，先写入X
                                                              
                          4'd1: begin  fifo_buf32 <= { fifo_buf32[15:0], fifo_din};               fifo_wr_en<=1;                     Y<= fifo_din;      end     //写入 X,Y
                              
                          4'd2: begin  fifo_buf32 <= { fifo_din,8'hff,8'h6a};                      fifo_wr_en<=1;                    Z<= fifo_din;      end    // Z+FF+6A
                             
                          4'd3:  begin  fifo_buf32 <= { fifo_buf32[7:0], line_ID, fifo_din};       fifo_wr_en<=0;                    X<= fifo_din; end   //暂存
                                       
                          4'd4:  begin   fifo_buf32 <= { fifo_buf32[23:0],  fifo_din[15:8]};       fifo_wr_en<=1;                    Y<= fifo_din; end  //2 -- X+1/2Y
                                        
                          4'd5:  begin   fifo_buf32 <= { fifo_din_last[7:0], fifo_din, 8'hff};     fifo_wr_en<=1;                    Z<= fifo_din; end //1/2 Y+Z + 1B
                                  
                          4'd6:  begin   fifo_buf32 <= { 8'h6a,line_ID,fifo_din};                   fifo_wr_en<=1;                   X<= fifo_din; end //3 -- fs   
                                         
                                
                          4'd7:    begin    fifo_buf32 <= { fifo_buf32[15:0], fifo_din};            fifo_wr_en<=0;                   Y<= fifo_din;     end     // 
                                     
                          4'd8:   begin    fifo_buf32 <= { fifo_buf32[15:0], fifo_din};             fifo_wr_en<=1;                   Z<= fifo_din;    end         //fs                  
                                       
                          4'd9:  begin    fifo_buf32 <= { 8'hff,8'h6a,line_ID,fifo_din[15:8]};      fifo_wr_en<=1;                   X<= fifo_din;  end //fs     // 
                                      
                          4'd10:  begin   fifo_buf32 <= {  fifo_din_last[7:0], fifo_din, fifo_buf32[7:0]};    fifo_wr_en<=0;         Y<= fifo_din;        end //fs    // 
                                      
                          4'd11:  begin   fifo_buf32 <= {  fifo_buf32[31:8], fifo_din[15:8]};                 fifo_wr_en<=1;         Z<= fifo_din;
                                                   fifo_rd_en1<=0;                              //关闭读，要写2次 
                                   end             //     //新数据到来
                                         
                          4'd12:  begin  fifo_buf32 <= {  fifo_din_last[7:0], 8'hff,8'h6a,line_ID } ;               fifo_wr_en<=1;  fifo_rd_en1<=1;    end    //f多余状态，用于发送
                                     
                          default: begin  fifo_cycle_index<=0;  end
                        endcase    
                  //停止读取 
                  if(tx_pts_cnt%(120*3)==(120*3-1)) begin
                      fifo_rd_en1<=0;
                      fifo_wr_state<=fifo_wr_state+1; //进入下一个状态
                  end                     
              end
              8'd6:   begin fifo_buf32 <= {  fifo_buf32[31:8], fifo_din[15:8]};    fifo_wr_en<=1;  fifo_wr_state<=fifo_wr_state+1;   end    //尾部写入
              8'd7:   begin  fifo_buf32 <= {  fifo_din_last[7:0],8'hff, 16'h00} ;  fifo_wr_en<=1;  fifo_wr_state<=fifo_wr_state+1;  end  //尾部，2B  
              8'd8:   begin   fifo_buf32 <= 32'H0;                                 fifo_wr_en<=1;  fifo_wr_state<=fifo_wr_state+1;  end    // 6B
              8'd9:   begin   fifo_buf32 <= 32'H0;                                 fifo_wr_en<=1;  fifo_wr_state<=fifo_wr_state+1;  end    // 10B
              8'd10:  begin  fifo_buf32 <= 32'H0;                                  fifo_wr_en<=1;  fifo_wr_state<=fifo_wr_state+1;  end    // 14B 
              8'd11:  begin fifo_buf32 <= 32'H0000AABB;                               fifo_wr_en<=1;  fifo_wr_state<=fifo_wr_state+1;  end    // 18B 
              8'd12:  begin fifo_buf32 <= 32'HCCDD0000;                               fifo_wr_en<=1;  fifo_wr_state<=fifo_wr_state+1; //20B + 2B多于
                      fifo_wr_one_done<=1; 
                      fifo_wr_state<=fifo_wr_state+1;         
                       
                     
                 end    // 22B (多写入2个）
              8'd13: begin //等待udp发送完成
                     fifo_wr_one_done<=0; 
                     fifo_wr_en<=0; 
//                     tx_send_en <=1;
                     //if(udp_tx_done == 1) begin
                         fifo_wr_state<=1;    
                     //end
              end
              default: fifo_wr_state<=0;
             endcase      
        end
 end
 
 endmodule
