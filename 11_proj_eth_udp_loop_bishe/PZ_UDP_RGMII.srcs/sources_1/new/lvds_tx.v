`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/09 21:04:36
// Design Name: 
// Module Name: LVDS
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

module lvds_tx (
    input wire clk,          // 系统时钟, 
    input wire rst_n,        // 异步复位，低电平有效
    input wire restart,           // 门控信号，单周期脉冲信号，上升沿启动发送
    input wire [55:0] timestramp,
    input [15:0] line_id, //激光线ID
    input [15:0] pts_pFrame, //每线最小点数量，
    //fifo read接口
    output reg lvds_rst, //复位信号输出
    output reg fifo_read_next,
    input [47:0] fifo_data,
    input fifo_empty,
    output reg lvds_busy,  //1:busy
    //LVDS芯片接口
    output wire lvds_clk,  // LVDS时钟正端，75M
    output reg lvds_csl,  // LVDS 片选
    output reg lvds_data1,// LVDS数据1正端  ， 高
    output reg lvds_data2,// LVDS数据2正端 ， 低
    output wire lvds_en  ,   // LVDS芯片使能
    output reg [31:0] send_pts_cnt
);

    reg [15:0] data_reg;     // 数据寄存器
    reg [47:0] fifo_data_buf;
    reg [7:0]  bit_cnt;       // 位计数器（16位数据，分8个周期传输）

//    reg [31:0] data_cnt;     //发送数据计数
//    reg [31:0] data_len_reg;

    assign lvds_en = 1;
    assign lvds_clk = clk;
    reg [15:0] frame_cnt;
    reg [7:0] en_last;
//    assign  lvds_rst = en_last==2 ? 1:0;  //同步复位信号
    //发送数据
    //restart 同步处理：将异步restart信号同步到clk域
    reg restart_sync1;
    reg restart_sync2;
    always @(posedge clk) begin
        restart_sync1 <= restart;
        restart_sync2 <= restart_sync1;
    end
    // 检测restart上升沿
    wire restart_rise = (restart_sync2 == 0) && (restart_sync1 == 1);

    always @(posedge clk) begin
        if (restart_rise) begin
            en_last  <= 1;
            lvds_rst <= 1;
        end
        else if (en_last == 1) begin
            en_last <= en_last + 1;
        end
        else begin
            en_last  <= 0;
            lvds_rst <= 0;
        end
    end  
    
   reg [7:0]  send_state;   //发送控制
//   reg [31:0] send_pts_cnt;
   reg [15:0] ck_sum;
   
    //数据切换
 always @(posedge lvds_clk or negedge rst_n) begin  
     if (!rst_n) begin     // 重新启动  
          fifo_read_next <= 0;            
     end
     else begin
        if(bit_cnt==0 && send_state==8) 
            fifo_read_next<=1;
        else 
            fifo_read_next<=0;
     end
  end  
    reg flag_send_nan;  //标记发送无效值
   //发送控制 一次16位（2字节）
   always @(posedge lvds_clk or negedge rst_n) begin                 
        if (!rst_n) begin     // 重新启动  
            send_state <= 8'hff;  
            frame_cnt<=1;     
            send_pts_cnt<=0;     
            ck_sum<=0;
            lvds_busy<=0;
            flag_send_nan<=0;
        end
        else if(lvds_rst==1) begin  //启动发送
           send_state <= 8'h0;
           ck_sum<=0;
           lvds_busy<=1;
           send_pts_cnt<=0;
           flag_send_nan<=0;
        end
        else  begin  
            case(send_state)     //启动发送
                8'd0: begin                
                    data_reg <= 16'h0;
                    send_state <= send_state + 1; 
                end
                8'd1: begin         //帧头0x146F EB90                                   
                     //if(bit_cnt==7)  
                     begin                
                        data_reg <= 16'h146F;   
                        send_state <= send_state + 1;     
                        frame_cnt<=frame_cnt+1;                    
                        end                         
                      end
                8'd2:  begin       //帧头0x146F EB90                     
                    if(bit_cnt==7)  begin  
                        data_reg <= 16'hEB90;                    
                        send_state <= send_state + 1; 
                        end                    
                    end
                8'd3:  begin     //时间戳1          
                    if(bit_cnt==7)  begin  
                        data_reg <= timestramp[55:40];  // 拼接线ID
                        send_state <= send_state + 1;  
                        end                   
                    end
                8'd4:  begin       //时间戳2
                    if(bit_cnt==7)  begin  
                        data_reg <= timestramp[39:24];                    
                        send_state <= send_state + 1; 
                        end
                    end
                8'd5:  begin          //时间戳3
                    if(bit_cnt==7)  begin  
                        data_reg <= timestramp[23:8];
                        send_state <= send_state + 1; 
                        end
                    end
                8'd6:   begin         //时间戳4
                    if(bit_cnt==7)  begin  
                        data_reg <= {timestramp[7:0],line_id[7:0]};
                        send_state <= send_state + 1;                  
                        end
                    end
               8'd7:   begin         //发送 预留
                    if(bit_cnt==7)  begin  
                        data_reg <= 0; 
                        send_state <= send_state + 1; 
                        end
                    end    
                8'd8: begin          //距离发送 N -- 1B          正常读取         
                    if(bit_cnt==6) begin
                        fifo_data_buf <= fifo_data;      //读入fifo数据                                 
                    end
                    else if(bit_cnt==7) begin     //载入待发送数据              
                       data_reg<= fifo_data_buf[47:32]; //赋值给发送data_reg
                       send_pts_cnt<=send_pts_cnt+1;
                       send_state <= send_state + 2; 
                       ck_sum<=ck_sum+data_reg;
                    end                    
                 end 
                 8'd9:  begin  //  //距离发送 N -- 1B     （输入无效值）
                        if(bit_cnt==6) begin
                            fifo_data_buf <= 48'h7fff7fff7fff;      // 写入无效值                           
                        end
                        else if(bit_cnt==7) begin     //载入待发送数据              
                           data_reg<= fifo_data_buf[47:32]; //赋值给发送data_reg
                           send_pts_cnt<=send_pts_cnt+1;
                           send_state <= send_state + 1; 
                           ck_sum<=ck_sum+data_reg;
                        end  
                 end                
                 8'd10: begin          //距离发送 N ---2B
                    if(bit_cnt==7) begin
                        data_reg<= fifo_data_buf[31:16];
                        send_state <= send_state + 1;
                        ck_sum<=ck_sum+data_reg;
                    end                     
                     end
                  8'd11: begin          //距离发送 N ----3B
                    if(bit_cnt==7) begin                
                        data_reg<= fifo_data_buf[15:0];
                        ck_sum<=ck_sum+data_reg;
                        if(fifo_empty==0) begin       //检查数量是否够   
                            send_state <= 8;                       
                        end
                        else begin   //满                          
                            if(send_pts_cnt<pts_pFrame)           
                               send_state <= 9;     
                            else
                               send_state <= send_state + 1;   
                        end
                    end               
                     end    
                     
                8'd12:  begin             //校验和
                     if(bit_cnt==7)  begin  
                        data_reg <= ck_sum;
                        send_state <= send_state + 1; 
                        end
                    end
                8'd13:   begin        //帧尾	0xAABBCCDD
                    if(bit_cnt==7)  begin  
                        data_reg <= 16'hAABB;
                        send_state <= send_state + 1; 
                        end
                    end
                8'd14: begin          //帧尾	0xAABBCCDD
                    if(bit_cnt==7)  begin  
                        data_reg <= 16'hCCDD;
                        send_state <= send_state + 1; 
                        end
                    end
                8'd15: begin
                    if(bit_cnt==7)  begin  //等待发送完毕
                        data_reg <= 16'h0;   
                        send_state <= send_state + 1;
                        end
                    end
                  8'd16: begin  //空闲
                       send_state <= send_state;
                       lvds_busy<=0;
                  end
                default: send_state <= send_state;
            endcase
        end    
    end  
    
    //数据发送
    always @(posedge lvds_clk or negedge rst_n) begin                 
        if (!rst_n || en_last==1) begin    
            bit_cnt <= 0 ;
            lvds_csl<=1;
            lvds_data1<=0;
            lvds_data2<=0;
        end
        else if(send_state>=2 && send_state<=8'd15 ) begin  // 重新启动   
                lvds_csl<=0;
                if(bit_cnt<7) begin
                    bit_cnt<=bit_cnt+1;                
                end
                else begin
                     bit_cnt<=0; 
                end  
                              
                lvds_data1 <= data_reg[15-bit_cnt*2];   //更新lvds数据线
                lvds_data2 <= data_reg[14-bit_cnt*2];                  
        end   
        else  begin
             lvds_csl<=1;
        end   
    end
    
endmodule