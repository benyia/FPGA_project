`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2024 03:05:24 PM
// Design Name: 
// Module Name: udp_tx
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

 module udp_tx 
 #(
 //参数定义,具体数值根据实际由顶层写入
  parameter SRC_MAC   =  48'b0 , //发送端(以本模块角度)MAC地址
  parameter SRC_IP    =  32'b0 , //发送端(以本模块角度)IP地址
  parameter DES_MAC   =  48'b0 , //接收端(以本模块角度)MAC地址 
  parameter DES_IP    =  32'b0 , //接收端(以本模块角度)IP地址  
  parameter IP_VER    =  4'b0  , //IP首部 协议版本
  parameter IP_HL     =  4'b0  , //IP首部 首部的长度
  parameter IP_TOS    =  8'b0  , //IP首部 服务类型
  parameter IP_ID     =  16'b0 , //IP首部 ID标识
  parameter IP_FLAG   =  3'b0  , //IP首部 FLAGS
  parameter IP_OFFSET =  13'b0 , //IP首部 分片偏移量
  parameter IP_TIME   =  8'b0  , //IP首部 生存时间
  parameter IP_PRT    =  8'b0    //IP首部 协议号
  )
 (
 input                 clk         , //input,时钟
 input                 rst_n       , //input,异步复位
 input                 tx_en       , //input,发送使能
 input        [15:0]   ipchecksum  , //input,16bits,ipchecksum模组计算结果
 input        [31:0]   crc_value   , //input,32bits,CRC模组计算结果
 input        [15:0]   datanum     , //input,16bits,此次需要传输的数据量,以Bytes为单位
 input        [7:0]    tx_data     , //input,8bits,待发送的数据
 output reg            ipsum_en    , //output,使能IP首部checksum值计算
 output reg            tx_on       , //output,帧发送状态标识
 output reg            txdata_on   , //output,发送数据状态标识,仅包含UDP数据部分
 output reg            tx_done     , //output,一帧发送完成
 output reg            crc_en      , //output,使能CRC32计算
 output reg   [7:0]    gmii_txd      //output,8bits,gmii数据发送        
  );
    
  localparam   SRC_PORT=16'd8000   ;
  localparam   DES_PORT=16'd8080   ;
    
  // 按照协议中的帧格式划分状态机    
  localparam  IDLE      = 7'b000_0001 ; //空闲状态
  localparam  PREAMBLE  = 7'b000_0010 ; //前导码+帧起始界定符
  localparam  MAC_HEAD  = 7'b000_0100 ; //MAC帧头: DA+SA+T/L
  localparam  IP_HEAD   = 7'b000_1000 ; //IP首部
  localparam  UDP_HEAD  = 7'b001_0000 ; //UDP首部
  localparam  DATA_ON   = 7'b010_0000 ; //发送数据
  localparam  FCS       = 7'b100_0000 ; //CRC校验值  

  reg   tx_en_a        ; //发送使能状态寄存
  reg   tx_en_b        ; //发送使能状态寄存
  wire  tx_en_posedge  ; //发送使能上升沿侦测
  always @(posedge clk or negedge rst_n)
  if(!rst_n)  begin tx_en_a<=1'b0; tx_en_a<=1'b0; end
  else        begin tx_en_a<=tx_en;tx_en_b<=tx_en_a; end  
  assign  tx_en_posedge=tx_en_a&&(!tx_en_b);
  
  reg  [6:0]  current_state ;
  reg  [6:0]  next_state    ; 
  //三段式状态机
 //描述状态转移 
  always @(posedge clk or negedge rst_n)
  if(!rst_n)   current_state<=IDLE;
  else         current_state<=next_state; 
   
  reg  state_shift  ; //状态转移标志 
  //判断状态转移条件
  always @(*) 
   case(current_state)
    IDLE     : if(state_shift) next_state=PREAMBLE; else next_state=current_state;                                                  
    PREAMBLE : if(state_shift) next_state=MAC_HEAD; else next_state=current_state;                                               
    MAC_HEAD : if(state_shift) next_state=IP_HEAD;  else next_state=current_state;                                               
    IP_HEAD  : if(state_shift) next_state=UDP_HEAD; else next_state=current_state;                                                
    UDP_HEAD : if(state_shift) next_state=DATA_ON;  else next_state=current_state;                                               
    DATA_ON  : if(state_shift) next_state=FCS;      else next_state=current_state;                                           
    FCS      : if(state_shift) next_state=IDLE;     else next_state=current_state;                                  
    default  : next_state=IDLE;       
   endcase  
  
  reg    [15:0]   cnt         ; //各状态下发送顺序计数
  wire   [15:0]   udp_num     ; //udp数据包总字节数
  wire   [15:0]   ip_ttl      ; //ip数据包总字节数
  reg    [15:0]   txbyte_cnt  ; //累加需传送的data bytes数量
  
  assign udp_num=8+datanum;  //UDP首部+UDP待传输的数据
  assign ip_ttl =20+udp_num; //IP首部+UDP字段
   
   //各状态下数据输出    
    always @(posedge clk or negedge rst_n)
      if(!rst_n) begin state_shift<=1'b0; gmii_txd<=8'b0; cnt<=16'b0;tx_on<=1'b0;txbyte_cnt<=3'b0; crc_en<=1'b0; txdata_on<=1'b0; end
      else
       case(next_state) 
       //按照帧各字段定义,逐个发送;发送的时间标识使用对时钟计数的cnt; 
         IDLE :   begin tx_done<=1'b0; tx_on<=1'b0;
                        if(tx_en_posedge) state_shift<=1'b1; else begin state_shift<=1'b0; gmii_txd<=8'b0; end end
        PREAMBLE: begin tx_on<=1'b1;
                   if(cnt==7) begin state_shift<=1'b1; cnt<=16'b0; gmii_txd<=8'hd5;    end
                   else       begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=8'h55; end 
                  end                
        MAC_HEAD: begin crc_en<=1'b1;  //从字段开始需要计算CRC,使能CRC模块计算
                  case(cnt)
                  0:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=DES_MAC[47:40]; end
                  1:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=DES_MAC[39:32]; end
                  2:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=DES_MAC[31:24]; end
                  3:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=DES_MAC[23:16]; end
                  4:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=DES_MAC[15:8];  end
                  5:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=DES_MAC[7:0];   end
                  6:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=SRC_MAC[47:40]; end
                  7:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=SRC_MAC[39:32]; end
                  8:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=SRC_MAC[31:24]; end
                  9:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=SRC_MAC[23:16]; end
                  10: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=SRC_MAC[15:8];  end
                  11: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=SRC_MAC[7:0];   end
                  12: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=8'h08;          end  // 0x0800:此传输帧使用IP协议；(0806ARP协议)
                  13: begin state_shift<=1'b1; cnt<=16'b0;    gmii_txd<=8'h00;          end
                  endcase end                                  
         IP_HEAD:  begin case(cnt)                 
                  0:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<={IP_VER,IP_HL}; ipsum_en<=1'b1; end  //使能IPchecksum值的计算
                  1:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<={IP_TOS};                       end    
                  2:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=ip_ttl[15:8];                   end   
                  3:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=ip_ttl[7:0];                    end  
                  4:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=IP_ID[15:8];                    end   
                  5:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=IP_ID[7:0];                     end  
                  6:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<={IP_FLAG,IP_OFFSET[12:8]};      end   
                  7:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=IP_OFFSET[7:0];                 end  
                  8:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=IP_TIME;                        end   
                  9:  begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=IP_PRT;                         end   
                  10: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=(ipchecksum[15:8]);             end   
                  11: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=(ipchecksum[7:0]);              end  
                  12: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=(SRC_IP[31:24]);                end
                  13: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=(SRC_IP[23:16]);                end
                  14: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=(SRC_IP[15:8]);                 end
                  15: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=(SRC_IP[7:0]);                  end
                  16: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=(DES_IP[31:24]);                end
                  17: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=(DES_IP[23:16]);                end
                  18: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=(DES_IP[15:8]);                 end
                  19: begin state_shift<=1'b1; cnt<=16'b0;    gmii_txd<=(DES_IP[7:0]); ipsum_en<=1'b0;  end
                  endcase end                  
       UDP_HEAD:  begin 
                   case(cnt)                          
                    0: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=SRC_PORT[15:8];            end   //源端口号
                    1: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=SRC_PORT[7:0] ;            end
                    2: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=DES_PORT[15:8];            end   //目的端口号
                    3: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=DES_PORT[7:0] ;            end                
                    4: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=udp_num[15:8] ;            end   
                    5: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=udp_num[7:0];              end
                    6: begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=8'h00;  txdata_on<=1'b1;   end   
                    7: begin state_shift<=1'b1; cnt<=16'b0;    gmii_txd<=8'h00;                     end                
                   endcase 
                  end     
      DATA_ON:  if(cnt<(datanum-1)) begin state_shift<=1'b0; cnt<=cnt+1'b1; gmii_txd<=tx_data; end
                else begin state_shift<=1'b1; cnt<=16'b0; txdata_on<=1'b0; gmii_txd<=tx_data;  end                                                                     
         FCS :  begin crc_en<=1'b0;  
                 if(cnt<3) begin cnt<=cnt+1'b1; state_shift<=1'b0;end 
                 else begin cnt<=3'b0; state_shift<=1'b1;end 
                 case (cnt)
                  0: gmii_txd<=crc_value[7:0]; 
                  1: gmii_txd<=crc_value[15:8];
                  2: gmii_txd<=crc_value[23:16];
                  3: begin gmii_txd<=crc_value[31:24];tx_done<=1'b1;   end
                 endcase
                 end                      
       endcase       
       
     ila_0 ila_0_tx 
     (
	   .clk(clk),            // input wire clk
	   .probe0(next_state),  // input wire [7:0]  probe0  
	   .probe1(gmii_txd),    // input wire [7:0]  probe1 
	   .probe2(tx_en),       // input wire [0:0]  probe2 
	   .probe3(tx_on),       // input wire [0:0]  probe3 
	   .probe4(tx_done),     // input wire [0:0]  probe4 
	   .probe5(cnt)          // input wire [15:0]  probe5
       );     
                       
 endmodule
