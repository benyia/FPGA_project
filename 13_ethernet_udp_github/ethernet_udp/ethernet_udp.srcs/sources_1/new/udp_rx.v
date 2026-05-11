`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2024 08:37:29 AM
// Design Name: 
// Module Name: udp_rx
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


module udp_rx 
 //参数定义,具体数值根据实际由顶层写入
#(
 parameter SRC_MAC = 48'b0 ,  //发送端MAC地址(以本模块角度)   
 parameter SRC_IP  = 32'b0 ,  //发送端IP地址 (以本模块角度)
 parameter DES_MAC = 48'b0 ,  //接收端MAC地址(以本模块角度)
 parameter DES_IP  = 32'b0    //接收端IP地址 (以本模块角度)
  )
 (
  input                clk        , //input,
  input                rst_n      , //input,
  input        [7:0]   gmii_rxd   , //input,8bits,接收gmii格式数据
  input                gmii_rxval , //input,接收数据有效标识
  output  reg  [15:0]  udpnum     , //output,16bits,接收到的传输数据+udp头部的bytes数量（8）
  output  reg          rxdata_on  , //output，正在接收数据标识（不含帧头等信息）
  output  reg  [7:0]   rx_data    , //output,8bits,接收到source发送的数据
  output  reg          rx_done      //output，接收完成                       
  );
    
   localparam  IDLE      = 8'b0000_0001  ;  //空闲状态
   localparam  PREAMBLE  = 8'b0000_0010  ;  //接收前导码+帧起始界定符
   localparam  MAC_HEAD  = 8'b0000_0100  ;  //接收MAC帧头: DA+SA+T/L
   localparam  IP_HEAD   = 8'b0000_1000  ;  //接收IP首部
   localparam  UDP_HEAD  = 8'b0001_0000  ;  //接收UDP首部
   localparam  DATA_ON   = 8'b0010_0000  ;  //接收数据
   localparam  FCS       = 8'b0100_0000  ;  //CRC校验值
   localparam  ERROR     = 8'b1000_0000  ;  //接收过程中如果有错误,则进入此状态,直到本次                           
                                            //数据包结束,再回到idle状态   
                                             
   reg  [15:0] cnt           ; //各状态下发送顺序计数
   reg  [3:0]  ipheadnum     ; //接收到的IP头部总长度
   reg  [31:0] desip         ; //接收到的目的 IP                                                                

   reg  [7:0]  current_state ;
   reg  [7:0]  next_state    ;
   reg         state_shift   ; //状态机转换标志
   reg         err_detect    ; //侦测到传输错误标志
 //描述状态转移 
   always @(posedge clk or negedge rst_n)
   if(!rst_n)   current_state<=IDLE; else  current_state<=next_state;
     
   //判断状态转移条件
   always @(*) 
   begin
     case(current_state)
     IDLE    : if(err_detect)  next_state=ERROR;          //识别到error后,进入ERROR state
               else if(state_shift) next_state=PREAMBLE;  //识别状态切换,进入下一个状态                
                    else next_state=current_state;        //否则停留在此状态                                   
     PREAMBLE: if(err_detect)  next_state=ERROR;
               else if(state_shift) next_state=MAC_HEAD;                         
                    else next_state=current_state;                                      
     MAC_HEAD: if(err_detect)  next_state=ERROR;
               else if(state_shift) next_state=IP_HEAD;                         
                    else next_state=current_state;                                
     IP_HEAD : if(err_detect)  next_state=ERROR;
               else if(state_shift) next_state=UDP_HEAD;                         
                    else next_state=current_state;                   
     UDP_HEAD: if(err_detect)  next_state=ERROR;
               else if(state_shift) next_state=DATA_ON;                         
                    else next_state=current_state;                    
     DATA_ON : if(err_detect)  next_state=ERROR;
               else if(state_shift) next_state=FCS;                         
                    else next_state=current_state; 
     FCS     : if(err_detect)  next_state=ERROR;
               else if(state_shift) next_state=IDLE;                         
                    else next_state=current_state;                      
     ERROR   : if(state_shift) next_state=IDLE;       
               else next_state=current_state;                  
       default : next_state=IDLE;       
      endcase 
    end    
    
   always @(posedge clk or negedge rst_n)
     if(!rst_n)  begin cnt<=16'b0; state_shift<=1'b0; err_detect<=1'b0; ipheadnum<=4'b0;
                       udpnum<=16'b0;desip<=32'b0;rx_data<=8'b0; rxdata_on<=1'b0; rx_done<=1'b0; end              
     else  case(next_state)   
             IDLE  : begin cnt<=16'b0; rx_done<=1'b0;
                      //发送数据的顺序是LSB最低位第一个发,所以接收到的数据是0x55 
                       if(gmii_rxd==8'h55)  state_shift<=1'b1; else begin  state_shift<=1'b0; end end//识别到有效数据,进入前导码状态                                       
           PREAMBLE: begin state_shift<=1'b0;                                    
                       if(gmii_rxval)                                              
                         begin $display ("PREAMBLE is : %h  when cnt is:%d",gmii_rxd,cnt); //打印信息确认仿真结果
                           cnt<=cnt+1'b1;
                           case(cnt)
                     0,1,2,3,4,5:if(gmii_rxd!=8'h55) err_detect<=1'b1; //第一个55在IDLE状态下识别,此处还有剩下的6个Bytes
                               6:if(gmii_rxd!=8'hd5) err_detect<=1'b1; //比对定界符
                                 else begin state_shift<=1'b1; cnt<=16'b0; end
                         default: begin state_shift<=1'b0; err_detect<=1'b0; end               
                            endcase
                           end                                         
                        else err_detect<=1'b1;                                          
                       end                                                                             
           MAC_HEAD: begin state_shift<=1'b0; 
                       if(gmii_rxval) 
                          begin $display("MAC_HEAD is : %h  when cnt is:%d",gmii_rxd,cnt);
                          cnt<=cnt+1'b1;    
                          case(cnt)
                          0: if(gmii_rxd!=DES_MAC[47:40]) err_detect<=1'b1; //识别目的地址
                          1: if(gmii_rxd!=DES_MAC[39:32]) err_detect<=1'b1; 
                          2: if(gmii_rxd!=DES_MAC[31:24]) err_detect<=1'b1;   
                          3: if(gmii_rxd!=DES_MAC[23:16]) err_detect<=1'b1; 
                          4: if(gmii_rxd!=DES_MAC[15:8])  err_detect<=1'b1;  
                          5: if(gmii_rxd!=DES_MAC[7:0])   err_detect<=1'b1; 
                         12: if(gmii_rxd!=8'h08)          err_detect<=1'b1; //0800:IPV4协议
                         13: if(gmii_rxd!==8'h00)         err_detect<=1'b1;
                             else begin state_shift<=1'b1; cnt<=16'b0; end  
                    default: begin state_shift<=1'b0; err_detect<=1'b0; end 
                          endcase
                          end                                                                   
                        else err_detect<=1'b1;
                     end
             IP_HEAD: begin state_shift<=1'b0; 
                       if(gmii_rxval) 
                          begin $display("IP_HEAD is : %h  when cnt is:%d",gmii_rxd,cnt);
                           cnt<=cnt+1'b1;
                           case(cnt)
                             0:  ipheadnum<=gmii_rxd[3:0];      //接收IP首部总长度                                   
                      16,17,18:  desip<={desip[23:0],gmii_rxd};  //识别比对目的 IP 
                            19:  begin desip={desip[23:0],gmii_rxd};
                                 if(desip!=DES_IP) err_detect<=1'b1; 
                        //ipheadnum以32bits为单位,此处是以8bits为单位,所以右移两位   
                        //因为IP首部有可能存在可选字段,此处判断如果没有可选字段就跳转下一个状态                       
                                 else if(({ipheadnum,2'b0}-1'b1)==19) begin state_shift<=1'b1; cnt<=16'b0; end end 
                        //如果有IP首部的数量大于20,就在等待直到计数值到达IP首部声明的数量再跳转
         {ipheadnum,2'b0}-1'b1: begin state_shift<=1'b1; cnt<=16'b0; end                                           
                       default:  begin state_shift<=1'b0; err_detect<=1'b0; end
                            endcase
                          end                             
                         else err_detect<=1'b1;
                 end                   
           UDP_HEAD: begin state_shift<=1'b0;
                       if(gmii_rxval)
                         begin $display("UDP_HEAD is : %h  when cnt is:%d",gmii_rxd,cnt);
                           cnt<=cnt+1'b1;
                           case(cnt)
                        //记录UDP首部声明的词UDP字段的长度
                             4: udpnum[15:8]<=gmii_rxd; 
                             5: udpnum[7:0]<=gmii_rxd;
                             7: begin state_shift<=1'b1; cnt<=16'b0; end 
                       default: begin state_shift<=1'b0; end 
                            endcase
                           end  
                         else err_detect<=1'b1; 
                       end                          
           DATA_ON: begin state_shift<=1'b0;
                      if(gmii_rxval)
                         begin  $display("DATA is : %h  when cnt is:%d",gmii_rxd,cnt);
                           //udpnum需减去UDP首部的8字节才是数据字节数 
                           if(cnt<(udpnum-8)) begin rx_data<=gmii_rxd; rxdata_on<=1'b1; cnt<=cnt+1'b1;end                                                             
                           else begin state_shift<=1'b1; cnt<=16'b0; rxdata_on<=1'b0; rx_data<=8'b0; end
                         end 
                      else err_detect<=1'b1; end                            
             FCS :begin state_shift<=1'b0; //仅做状态预留,接收端未进行校验                             
                        if(cnt==3) begin state_shift<=1'b1;rx_done<=1'b1;cnt<=16'b0;end
                        else begin state_shift<=1'b0;cnt<=cnt+1'b1; end  end                                                                  
            ERROR :begin state_shift<=1'b0; err_detect<=1'b0;
                    if(gmii_rxval) state_shift<=1'b0; else state_shift<=1'b1; end                                    
         endcase  
         
    ila_0 ila_0_rx 
    (
	.clk(clk),             // input wire clk
	.probe0(gmii_rxd),     // input wire [7:0]  probe0  
	.probe1(next_state),   // input wire [7:0]  probe1 
	.probe2(gmii_rxval),   // input wire [0:0]  probe2
    .probe3(state_shift),  // input wire [0:0]  probe3 
	.probe4(err_detect),   // input wire [0:0]  probe4
	.probe5(cnt)           // input wire [15:0]  probe5
     ); 
      
 endmodule
