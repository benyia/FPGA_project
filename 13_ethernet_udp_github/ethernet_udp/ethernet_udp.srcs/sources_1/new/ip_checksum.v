`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2024 11:39:13 AM
// Design Name: 
// Module Name: ip_checksum
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

module ip_checksum 
  #(
  //参数定义,具体数值根据实际由顶层写入
   parameter  IP_VER    = 4'b0  , //IP首部 协议版本   
   parameter  IP_HL     = 4'b0  , //IP首部 首部的长度  
   parameter  IP_TOS    = 8'b0  , //IP首部 服务类型   
   parameter  IP_ID     = 16'b0 , //IP首部 ID标识   
   parameter  IP_FLAG   = 3'b0  , //IP首部 FLAGS  
   parameter  IP_OFFSET = 13'b0 , //IP首部 分片偏移量  
   parameter  IP_TIME   = 8'b0  , //IP首部 生存时间   
   parameter  IP_PRT    = 8'b0  , //IP首部 协议号    
   parameter  IP_SRC    = 32'b0 , //发送端(以本模块角度)IP地址     
   parameter  IP_DES    = 32'b0   //接收端(以本模块角度)IP地址    
  )
  (
   input            clk          , //input,时钟
   input            rst_n        , //input,异步复位
   input            ipsum_en     , //input,使能IPSUM值计算
   input   [15:0]   ip_ttl       , //input,16bits,IP封包总长度
   output  [15:0]   ip_checksum    //output,16bits,IP封包checksum值计算结果
   );
   
   reg     [31:0]   sumtemp    ;  
   wire    [31:0]   sumtemp_a  ;
   wire    [15:0]   sumtemp_b  ;
   
   //1.IP首部以16bits为单位全部累加(IP校验和设置为0)
   //2.累加和的前16bits和后16bits相加两次,来消除掉前16bits有进位的情况
   //3.即使有进位,相加两次之后前16bits已经是全0,把后16bits取反即为IP CHECKSUM值
   always@(posedge clk or negedge rst_n)
  	if(!rst_n) sumtemp<= 32'd0; 		
  	else if(ipsum_en)
  		 sumtemp <= {IP_VER,IP_HL,IP_TOS}+ip_ttl+IP_ID+
  			        {IP_FLAG,IP_OFFSET}+{IP_TIME,IP_PRT}+
  			        IP_SRC[31:16]+IP_SRC[15:0]+IP_DES[31:16]+IP_DES[15:0];
      	else sumtemp <= 32'd0;
  		  
  	assign sumtemp_a = sumtemp[31:16]+sumtemp[15:0];
  	assign sumtemp_b = sumtemp_a[31:16]+sumtemp_a[15:0]; 
  	assign ip_checksum = ~sumtemp_b;
    
endmodule
  