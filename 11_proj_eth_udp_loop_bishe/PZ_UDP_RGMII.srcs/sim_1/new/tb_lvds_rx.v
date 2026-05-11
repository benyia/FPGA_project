`timescale  1ns/1ps
////////////////////////////////////////////////////////////////////////
// Module Name   : tb_lvds_rx
// Description   : LVDS接收模块仿真测试文件
//                 完全模拟lvds_tx的发送时序：
//                 - 发送端在posedge lvds_clk更新数据和csl（非阻塞赋值）
//                 - 接收端在negedge lvds_clk采样数据
//                 - bit_cnt=0时输出data[15:14]，依次到bit_cnt=7输出[1:0]
//                 - csl拉低与第一个有效数据出现在同一时钟沿
////////////////////////////////////////////////////////////////////////

module tb_lvds_rx();

// ========== 参数定义 ==========
parameter LVDS_CLK_PERIOD = 13.333;   // 75MHz时钟周期 ~13.333ns
parameter FRAME_HEAD_H   = 16'h146F; // 帧头高16位
parameter FRAME_HEAD_L   = 16'hEB90; // 帧头低16位

// ========== DUT输入信号 ==========
reg         rst_n;            // 复位信号，低电平有效
reg         en_in;            // 使能输入
reg         lvds_clk;         // LVDS时钟，75MHz
reg         lvds_csl;         // LVDS片选信号（低有效）
reg         lvds_data1;       // LVDS数据1（高位）
reg         lvds_data2;       // LVDS数据2（低位）

// ========== DUT输出信号 ==========
wire [15:0] dat_rx;           // 接收数据输出
wire        dat_update;       // 数据更新脉冲
wire        framenew_rst;     // 新一帧到来标志信号
wire        en;               // 使能输出
wire        en_n;             // 使能反相输出
wire [4:0]  rx_cnt_debug;    // 接收计数调试
wire [15:0] rx_pts_cnt;      // 接收点计数
wire        debug_rst;        // 调试复位标志
wire [7:0]  lineID;          // 线ID
wire [15:0] x;               // X坐标
wire [15:0] y;               // Y坐标
wire [15:0] z;               // Z坐标

// ========== LVDS 75MHz时钟生成 ==========
initial lvds_clk = 1'b0;
always #(LVDS_CLK_PERIOD/2) lvds_clk = ~lvds_clk;

// ========== 发送单个16bit数据任务 ==========
// 模拟lvds_tx的bit级发送时序：
//   tx在posedge lvds_clk用非阻塞赋值更新数据线
//   这里在posedge后#1设置数据，模拟非阻塞赋值延迟
//   接收端在之后的negedge采样时数据已稳定
//
//   bit_cnt=0: data[15:14]  bit_cnt=1: data[13:12]  ...  bit_cnt=7: data[1:0]
task lvds_send_16bit;
    input [15:0] data;
    integer i;
    begin
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge lvds_clk);
            #1;
            lvds_data1 = data[15 - i*2];     // bit_cnt=i时输出高位
            lvds_data2 = data[14 - i*2];     // bit_cnt=i时输出低位
        end
    end
endtask

// ========== 发送完整LVDS帧 ==========
// 完全模拟lvds_tx的帧发送流程：
//   send_state 0~1: 准备阶段，csl=1，数据线为0
//   send_state 2:   csl拉低，同时开始输出第一个16bit（帧头高16位0x146F）
//   send_state 3:   输出帧头低16位（0xEB90）
//   send_state 4~6: 时间戳（4个16bit）
//   send_state 7:   预留（1个16bit）
//   send_state 8~11: 点云数据（每点3个16bit：X/Y/Z）
//   send_state 12:  校验和
//   send_state 13~14: 帧尾0xAABBCCDD
//   send_state 15~16: 发送完毕，csl拉高
task lvds_send_frame;
    integer pts;
    reg [15:0] cksum;
    begin
        cksum = 0;
        
        // 模拟lvds_tx send_state 0~1：准备阶段，csl=1
        // tx在此期间data_reg=0，数据线上无有效数据
        @(posedge lvds_clk); #1;
        lvds_data1 = 0; lvds_data2 = 0;   // send_state 0
        @(posedge lvds_clk); #1;
        lvds_data1 = 0; lvds_data2 = 0;   // send_state 1
        
        // send_state>=2：csl拉低，开始发送有效数据
        // 在lvds_tx中，send_state=2时 csl<=0 且 bit_cnt=0，同时输出data_reg[15:14]
        // 所以csl拉低和第一个有效数据位在同一时钟沿
        @(posedge lvds_clk);
        #1;
        lvds_csl = 1'b0;   // csl拉低，开始发送
        // 同时输出帧头0x146F的最高2位
        lvds_data1 = FRAME_HEAD_H[15];
        lvds_data2 = FRAME_HEAD_H[14];
        
        // 继续发送0x146F的剩余位（bit_cnt=1~7）
        // （bit_cnt=0已在上面发送）
        begin : send_head_h
            integer i;
            for (i = 1; i < 8; i = i + 1) begin
                @(posedge lvds_clk);
                #1;
                lvds_data1 = FRAME_HEAD_H[15 - i*2];
                lvds_data2 = FRAME_HEAD_H[14 - i*2];
            end
        end
        cksum = cksum + FRAME_HEAD_H;
        
        // 发送帧头低16位：0xEB90
        lvds_send_16bit(FRAME_HEAD_L);
        cksum = cksum + FRAME_HEAD_L;
        
        // 发送时间戳（4个16bit，对应tx send_state 3~6）
        lvds_send_16bit(16'h0001);  // 时间戳[55:40]
        lvds_send_16bit(16'h0002);  // 时间戳[39:24]
        lvds_send_16bit(16'h0003);  // 时间戳[23:8]
        lvds_send_16bit(16'h0105);  // 时间戳[7:0] + 线ID[7:0]
        cksum = cksum + 16'h0001 + 16'h0002 + 16'h0003 + 16'h0105;
        
        // 发送预留字节（对应tx send_state 7）
        lvds_send_16bit(16'h0000);
        
        // 发送点云数据（对应tx send_state 8~11，模拟3个点的XYZ坐标）
        lvds_send_16bit(16'h1100);  // X1
        lvds_send_16bit(16'h2200);  // Y1
        lvds_send_16bit(16'h3300);  // Z1
        cksum = cksum + 16'h1100 + 16'h2200 + 16'h3300;
        
        lvds_send_16bit(16'h1111);  // X2
        lvds_send_16bit(16'h2211);  // Y2
        lvds_send_16bit(16'h3311);  // Z2
        cksum = cksum + 16'h1111 + 16'h2211 + 16'h3311;
        
        lvds_send_16bit(16'h1122);  // X3
        lvds_send_16bit(16'h2222);  // Y3
        lvds_send_16bit(16'h3322);  // Z3
        cksum = cksum + 16'h1122 + 16'h2222 + 16'h3322;
        
        // 发送校验和（对应tx send_state 12）
        lvds_send_16bit(cksum);
        
        // 发送帧尾：0xAABB CCDD（对应tx send_state 13~14）
        lvds_send_16bit(16'hAABB);
        lvds_send_16bit(16'hCCDD);
        
        // 模拟lvds_tx send_state 15~16：发送完毕，csl拉高
        @(posedge lvds_clk);
        #1;
        lvds_csl = 1'b1;   // csl拉高，帧结束
        lvds_data1 = 1'b0;
        lvds_data2 = 1'b0;
    end
endtask

// ========== 主激励 ==========
initial begin
    // 初始化
    rst_n       = 1'b0;
    en_in       = 1'b0;
    lvds_csl    = 1'b1;     // 片选无效
    lvds_data1  = 1'b0;
    lvds_data2  = 1'b0;
    
    // 复位
    #200;
    rst_n = 1'b1;
    #100;
    
    // 阶段1：使能LVDS接收，发送单帧数据
    $display("[%0t] === 阶段1: 使能LVDS接收，发送单帧数据 ===", $time);
    en_in = 1'b1;
    #50;
    lvds_send_frame();
    #1000;
    
    // 阶段2：连续发送多帧数据，验证帧间切换
    $display("[%0t] === 阶段2: 连续发送多帧数据 ===", $time);
    lvds_send_frame();
    #500;
    lvds_send_frame();
    #1000;
    
    // 阶段3：片选信号测试（不拉低csl，不应有数据输出）
    $display("[%0t] === 阶段3: 片选无效时发送数据（不应有dat_update脉冲）===", $time);
    lvds_csl = 1'b1;
    lvds_data1 = 1'b0;
    lvds_data2 = 1'b0;
    #500;
    
    // 阶段4：重新使能并接收
    $display("[%0t] === 阶段4: 重新使能并接收数据 ===", $time);
    lvds_send_frame();
    #1000;
    
    // 阶段5：复位测试
    $display("[%0t] === 阶段5: 复位测试 ===", $time);
    rst_n = 1'b0;
    #200;
    rst_n = 1'b1;
    #100;
    lvds_send_frame();
    #1000;
    
    $display("[%0t] === 仿真结束 ===", $time);
    $finish;
end

// ========== 波形监控 ==========
initial begin
    $dumpfile("tb_lvds_rx.vcd");
    $dumpvars(0, tb_lvds_rx);
end

// ========== 数据有效性检查 ==========
always @(posedge dat_update) begin
    $display("[%0t] 数据更新: dat_rx=0x%04H, rx_pts_cnt=%0d, rx_cnt_debug=%0d",
             $time, dat_rx, rx_pts_cnt, rx_cnt_debug);
end

// ========== 帧标志监控 ==========
always @(posedge framenew_rst) begin
    $display("[%0t] 新帧到来标志: framenew_rst=1, lineID=0x%02H",
             $time, lineID);
end

// ========== 被测模块例化 ==========
lvds_rx u_lvds_rx (
    .rst_n          (rst_n),
    .en_in          (en_in),
    .lvds_clk       (lvds_clk),
    .lvds_csl       (lvds_csl),
    .lvds_data1     (lvds_data1),
    .lvds_data2     (lvds_data2),
    .dat_rx         (dat_rx),
    .dat_update     (dat_update),
    .framenew_rst   (framenew_rst),
    .en             (en),
    .en_n           (en_n),
    .rx_cnt_debug   (rx_cnt_debug),
    .rx_pts_cnt     (rx_pts_cnt),
    .debug_rst      (debug_rst),
    .lineID         (lineID),
    .x              (x),
    .y              (y),
    .z              (z)
);

endmodule
