`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/25/2024 02:41:48 PM
// Design Name: 
// Module Name: crc32
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


module crc32
(
 input            clk          , //input,时钟                        
 input            rst_n        , //input,异步复位                      
 input   [7:0]    data_in      , //input,待CRC计算数据                
 input            crc_en       , //input,使能CRC计算            
 input            crc_default  , //input,将CRC值恢复为默认值 
 output  [31:0]   crc_value      //output,32bits,计算出的32bits CRC值
  );
  
   reg      [31:0]   crc_temp             ;    //计算出的CRC值暂存
   wire     [7:0]    data_r               ;
 
  //依crc 函数计算规则,输入的8bits先进行按位反转 
  assign data_r= {data_in[0],data_in[1],data_in[2],data_in[3],data_in[4],data_in[5],data_in[6],data_in[7]};

  //将crc值与data_in 带入函数进行计算
  //crc32的初始值为32'hffff_ffff
  always @(posedge clk or negedge rst_n)
    begin
      if(!rst_n)            crc_temp <= 32'hffff_ffff;       
      else if(crc_default)  crc_temp <= 32'hffff_ffff;              
           else if(crc_en)  crc_temp <= crc(crc_temp, data_r);                  
                else        crc_temp   <= crc_temp;
     end  

  // CRC polynomial coefficients: 
  //x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
  // CRC width:                   32 bits
  // Input word width:            8 bits

  function  [31:0] crc;
    input   [31:0] crcIn;
    input   [7:0]  data;
    begin
     crc[0]  = data[6] ^ data[0] ^ crcIn[24] ^ crcIn[30];                                                                                                                                    
     crc[1]  = data[7] ^ data[6] ^ data[1] ^ data[0] ^ crcIn[24] ^ crcIn[25] ^ crcIn[30] ^ crcIn[31];                                                                                                      
     crc[2]  = data[7] ^ data[6] ^ data[2] ^ data[1] ^ data[0] ^ crcIn[24] ^ crcIn[25] ^ crcIn[26] ^ crcIn[30] ^ crcIn[31];                                                                                       
     crc[3]  = data[7] ^ data[3] ^ data[2] ^ data[1] ^ crcIn[25] ^ crcIn[26] ^ crcIn[27] ^ crcIn[31];                                                                                                      
     crc[4]  = data[6] ^ data[4] ^ data[3] ^ data[2] ^ data[0] ^ crcIn[24] ^ crcIn[26] ^ crcIn[27] ^ crcIn[28] ^ crcIn[30];                                                                                       
     crc[5]  = data[7] ^ data[6] ^ data[5] ^ data[4] ^ data[3] ^ data[1] ^ data[0] ^ crcIn[24] ^ crcIn[25] ^ crcIn[27] ^ crcIn[28] ^ crcIn[29] ^ crcIn[30] ^ crcIn[31];                                                         
     crc[6]  = data[7] ^ data[6] ^ data[5] ^ data[4] ^ data[2] ^ data[1] ^ crcIn[25] ^ crcIn[26] ^ crcIn[28] ^ crcIn[29] ^ crcIn[30] ^ crcIn[31];                                                                        
     crc[7]  = data[7] ^ data[5] ^ data[3] ^ data[2] ^ data[0] ^ crcIn[24] ^ crcIn[26] ^ crcIn[27] ^ crcIn[29] ^ crcIn[31];                                                                                       
     crc[8]  = data[4] ^ data[3] ^ data[1] ^ data[0] ^ crcIn[0] ^ crcIn[24] ^ crcIn[25] ^ crcIn[27] ^ crcIn[28];                                                                                               
     crc[9]  = data[5] ^ data[4] ^ data[2] ^ data[1] ^ crcIn[1] ^ crcIn[25] ^ crcIn[26] ^ crcIn[28] ^ crcIn[29];                                                                                               
     crc[10] = data[5] ^ data[3] ^ data[2] ^ data[0] ^ crcIn[2] ^ crcIn[24] ^ crcIn[26] ^ crcIn[27] ^ crcIn[29];                                                                                              
     crc[11] = data[4] ^ data[3] ^ data[1] ^ data[0] ^ crcIn[3] ^ crcIn[24] ^ crcIn[25] ^ crcIn[27] ^ crcIn[28];                                                                                              
     crc[12] = data[6] ^ data[5] ^ data[4] ^ data[2] ^ data[1] ^ data[0] ^ crcIn[4] ^ crcIn[24] ^ crcIn[25] ^ crcIn[26] ^ crcIn[28] ^ crcIn[29] ^ crcIn[30];                                                                
     crc[13] = data[7] ^ data[6] ^ data[5] ^ data[3] ^ data[2] ^ data[1] ^ crcIn[5] ^ crcIn[25] ^ crcIn[26] ^ crcIn[27] ^ crcIn[29] ^ crcIn[30] ^ crcIn[31];                                                                
     crc[14] = data[7] ^ data[6] ^ data[4] ^ data[3] ^ data[2] ^ crcIn[6] ^ crcIn[26] ^ crcIn[27] ^ crcIn[28] ^ crcIn[30] ^ crcIn[31];                                                                               
     crc[15] = data[7] ^ data[5] ^ data[4] ^ data[3] ^ crcIn[7] ^ crcIn[27] ^ crcIn[28] ^ crcIn[29] ^ crcIn[31];                                                                                              
     crc[16] = data[5] ^ data[4] ^ data[0] ^ crcIn[8] ^ crcIn[24] ^ crcIn[28] ^ crcIn[29];                                                                                                             
     crc[17] = data[6] ^ data[5] ^ data[1] ^ crcIn[9] ^ crcIn[25] ^ crcIn[29] ^ crcIn[30];                                                                                                             
     crc[18] = data[7] ^ data[6] ^ data[2] ^ crcIn[10] ^ crcIn[26] ^ crcIn[30] ^ crcIn[31];                                                                                                            
     crc[19] = data[7] ^ data[3] ^ crcIn[11] ^ crcIn[27] ^ crcIn[31];                                                                                                                           
     crc[20] = data[4] ^ crcIn[12] ^ crcIn[28];                                                                                                                                          
     crc[21] = data[5] ^ crcIn[13] ^ crcIn[29];                                                                                                                                          
     crc[22] = data[0] ^ crcIn[14] ^ crcIn[24];                                                                                                                                          
     crc[23] = data[6] ^ data[1] ^ data[0] ^ crcIn[15] ^ crcIn[24] ^ crcIn[25] ^ crcIn[30];                                                                                                            
     crc[24] = data[7] ^ data[2] ^ data[1] ^ crcIn[16] ^ crcIn[25] ^ crcIn[26] ^ crcIn[31];                                                                                                            
     crc[25] = data[3] ^ data[2] ^ crcIn[17] ^ crcIn[26] ^ crcIn[27];                                                                                                                           
     crc[26] = data[6] ^ data[4] ^ data[3] ^ data[0] ^ crcIn[18] ^ crcIn[24] ^ crcIn[27] ^ crcIn[28] ^ crcIn[30];                                                                                             
     crc[27] = data[7] ^ data[5] ^ data[4] ^ data[1] ^ crcIn[19] ^ crcIn[25] ^ crcIn[28] ^ crcIn[29] ^ crcIn[31];                                                                                             
     crc[28] = data[6] ^ data[5] ^ data[2] ^ crcIn[20] ^ crcIn[26] ^ crcIn[29] ^ crcIn[30];                                                                                                            
     crc[29] = data[7] ^ data[6] ^ data[3] ^ crcIn[21] ^ crcIn[27] ^ crcIn[30] ^ crcIn[31];                                                                                                            
     crc[30] = data[7] ^ data[4] ^ crcIn[22] ^ crcIn[28] ^ crcIn[31];                                                                                                                           
     crc[31] = data[5] ^ crcIn[23] ^ crcIn[29];                                                                                                                                          
  end
 endfunction
 
 //依crc32计算规则,函数计算出的结果首先需按位反转;其次需与给定值32'hffff_ffff异或,也就是按位取反.
     assign crc_value = ~{crc_temp[00],crc_temp[01],crc_temp[02],crc_temp[03],crc_temp[04],crc_temp[05],crc_temp[06],crc_temp[07],
                      crc_temp[08],crc_temp[09],crc_temp[10],crc_temp[11],crc_temp[12],crc_temp[13],crc_temp[14],crc_temp[15],
                      crc_temp[16],crc_temp[17],crc_temp[18],crc_temp[19],crc_temp[20],crc_temp[21],crc_temp[22],crc_temp[23],
                      crc_temp[24],crc_temp[25],crc_temp[26],crc_temp[27],crc_temp[28],crc_temp[29],crc_temp[30],crc_temp[31]};

endmodule
