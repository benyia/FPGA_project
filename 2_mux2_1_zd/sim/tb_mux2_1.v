//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           tb_mux2_1
// Created by:          正点原子
// Created date:        2025年10月9日09:40:02
// Version:             V1.0
// Descriptions:        2选一选择器模块仿真激励文件
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
`timescale 1ns / 1ps

module tb_mux2_1(
);

//reg define
reg in1;
reg in2;
reg sel;

//wire define
wire out;

//initial语句是不可以被综合的,一般只在testbench中表达而不在RTL代码中表达
initial
    begin           //在仿真中begin...end块中的内容都是顺序执行的
        in1 = 1'b0; //初始状态赋值
        in2 = 1'b0;
        sel = 1'b0;
        #100        //经过100ns的延时
        in1 = 1'b0; //100ns时的输入值
        in2 = 1'b0;
        sel = 1'b1;
        #100        //经过200ns的延时
        in1 = 1'b0; //200ns时的输入值
        in2 = 1'b1;
        sel = 1'b0;
        #100        //经过300ns的延时
        in1 = 1'b0; //300ns时的输入值
        in2 = 1'b1;
        sel = 1'b1;
        #100        //经过400ns的延时
        in1 = 1'b1; //400ns时的输入值
        in2 = 1'b0;
        sel = 1'b0;
        #100        //经过500ns的延时
        in1 = 1'b1; //500ns时的输入值
        in2 = 1'b0;
        sel = 1'b1;
        #100        //经过600ns的延时
        in1 = 1'b1; //600ns时的输入值
        in2 = 1'b1;
        sel = 1'b1;
    end

//例化2选一选择器模块
mux2_1 u_mux2_1(
    .in1(in1),    //输入信号in1
    .in2(in2),    //输入信号in2
    .sel(sel),    //选择控制信号sel

    .out(out)     //输出信号out
    );

endmodule
