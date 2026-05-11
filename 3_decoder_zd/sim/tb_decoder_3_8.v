//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           tb_decoder_3_8
// Created by:          正点原子
// Created date:        2025年10月11日10:40:02
// Version:             V1.0
// Descriptions:        3-8译码器模块仿真激励文件
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

`timescale 1ns / 1ns

module tb_decoder_3_8();

//define reg
reg        A;
reg        B;
reg        C;

//define wire
wire [7:0] out;

//信号初始化
initial begin
    A = 0; B = 0; C = 0;
    #201
    A = 0; B = 0; C = 1;
    #200
    A = 0; B = 1; C = 0;
    #200
    A = 0; B = 1; C = 1;
    #200
    A = 1; B = 0; C = 0;
    #200
    A = 1; B = 0; C = 1;
    #200
    A = 1; B = 1; C = 0;
    #200
    A = 1; B = 1; C = 1;
    #200
    A = 0; B = 0; C = 0;
end

//例化3-8译码器模块
decoder3_8 decoder3_8_inst(
    .A  (A),
    .B  (B),
    .C  (C),

    .out(out)
    );

endmodule
