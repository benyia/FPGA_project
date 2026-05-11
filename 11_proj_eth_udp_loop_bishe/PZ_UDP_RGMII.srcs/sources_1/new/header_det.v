`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/01 12:09:58
// Design Name: 
// Module Name: header_det
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


module header_det(
    input clk_in,
    input rstn,
    input send_en,
    input fifo_rd_in,
    input [31:0] fifo_dat,
    input udp_tx_busy,
    output fifo_rd_out,
    output reg send_en_out    
    );
    parameter HEADER = 32'heb90aa55;
    reg send_en_last;
    reg header_found;
    reg fifo_rd;
    reg [4:0] stat;
    reg stat_next;
    assign fifo_rd_out = header_found ? fifo_rd_in:fifo_rd;
    
    always@(posedge clk_in) send_en_last<=send_en;
    
    //状态转移
    always@(posedge clk_in) begin
        case(stat) 
            0: begin  //idle
                if(send_en_last==0 && send_en == 1) 
                      stat<=stat + 1;   //帧头检测
                else
                     stat <= stat;
            end
            1: begin  //header 检测
                  if(stat_next==1)
                       stat<=stat + 1;
                  else
                     stat <= stat;  
            end
            2: begin   //输出 start
                  if(stat_next==1)
                       stat<=0;
                  else
                     stat <= stat;                   
            end
            default:
               stat <= 0;
            
        endcase
    end
    
    
    // 输出（组合逻辑改为assign，消除latch）
    always@(*) begin
        case(stat)
              0: begin
                  header_found = 1;  
                  fifo_rd = 0;
                  send_en_out = 0;  
                  stat_next = 0; 
              end
              
              1: begin  //检测头部
                    header_found = 0;       
                    send_en_out = 0;             
                     if(fifo_dat != HEADER) begin   
                        fifo_rd = 1;
                        stat_next = 0; 
                    end
                    else begin
                         fifo_rd = 0;           
                         stat_next = 1; 
                    end
              end          
              2: begin  //输出起始信号
                    send_en_out = 1;
                    header_found = 1;
                    stat_next = 1;                 
              end     
              default: begin
                    stat_next = 0; 
                    header_found = 1;
                    send_en_out = 0;
                     fifo_rd = 0;
              end
         
       endcase

     end
    
endmodule
