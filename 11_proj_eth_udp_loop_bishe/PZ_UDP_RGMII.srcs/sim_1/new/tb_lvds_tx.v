`timescale  1ns/1ps
////////////////////////////////////////////////////////////////////////
// Module Name   : tb_lvds_tx
// Description   : LVDS发送模块仿真测试文件
//                 符合论文第四章LVDS发送模块时序仿真描述
//                 验证帧头(0x146F EB90)发送、时间戳嵌入、FIFO点云数据读取、
//                 2bit×8=16bit串并转换输出、校验和计算、帧尾(0xAABBCCDD)发送
//                 以及restart上升沿触发、lvds_busy忙标志、fifo_empty填充逻辑
////////////////////////////////////////////////////////////////////////

module tb_lvds_tx();

// ========== 参数定义 ==========
parameter CLK75_PERIOD  = 13.333;     // 75MHz时钟周期 ~13.333ns
parameter CLK100_PERIOD = 10;         // 100MHz时钟周期 10ns
parameter PTS_PFRAME    = 16'd1200;   // 每帧最小点数量

// ========== DUT输入信号 ==========
reg         clk;              // 系统时钟 75MHz
reg         rst_n;            // 复位信号，低电平有效
reg         restart;          // 门控信号，上升沿启动发送
reg  [55:0] timestramp;       // 时间戳
reg  [15:0] line_id;          // 激光线ID
reg  [15:0] pts_pFrame;       // 每线最小点数量
reg  [47:0] fifo_data;        // FIFO数据输入 (16bit×3, xyz)
reg         fifo_empty;       // FIFO空标志

// ========== DUT输出信号 ==========
wire        lvds_rst;         // 复位信号输出
wire        fifo_read_next;   // FIFO读请求
wire        lvds_busy;        // 忙标志 (1=忙)
wire        lvds_clk;         // LVDS时钟输出
wire        lvds_csl;         // LVDS片选
wire        lvds_data1;       // LVDS数据线1 (高)
wire        lvds_data2;       // LVDS数据线2 (低)
wire        lvds_en;          // LVDS芯片使能
wire [31:0] send_pts_cnt;     // 已发送点计数

// ========== 内部监控信号 ==========
reg  [15:0] recv_data;        // 接收到的16bit数据（从lvds_data1/data2解码）
reg  [2:0]  recv_bit_cnt;     // 接收位计数器
reg  [15:0] cksum_monitor;    // 校验和监控
reg  [31:0] frame_cnt;        // 帧计数
reg        last_csl;          // 上一次csl值

// ========== 75MHz时钟生成 ==========
initial clk = 1'b0;
always #(CLK75_PERIOD/2) clk = ~clk;

// ========== 模拟FIFO数据 ==========
reg [31:0] pts_counter;       // 点计数器
reg [15:0] x_data, y_data, z_data;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pts_counter <= 32'd0;
        x_data <= 16'h1100;
        y_data <= 16'h2200;
        z_data <= 16'h3300;
        fifo_data <= 48'h1100_2200_3300;
        fifo_empty <= 1'b0;
    end
    else if (fifo_read_next) begin
        pts_counter <= pts_counter + 32'd1;
        fifo_data <= {x_data, y_data, z_data};
        // 每120个点递增一次，模拟lvds_simulate中的逻辑
        if (pts_counter % 120 == 119) begin
            x_data <= x_data + 16'h0011;
            y_data <= y_data + 16'h0011;
            z_data <= z_data + 16'h0011;
        end
        // 当发送点数超过阈值时模拟FIFO空
        if (pts_counter >= 32'd1200)
            fifo_empty <= 1'b1;
        else
            fifo_empty <= 1'b0;
    end
end

// ========== LVDS数据解码监控 ==========
// 从lvds_data1/data2双线解码出16bit数据
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        recv_data <= 16'd0;
        recv_bit_cnt <= 3'd0;
        last_csl <= 1'b1;
    end
    else begin
        last_csl <= lvds_csl;
        if (lvds_csl == 1'b0) begin
            // csl低有效，正在发送数据
            // 每个时钟周期从data1和data2各取1bit
            recv_data[15 - {recv_bit_cnt, 1'b0}] <= lvds_data1;
            recv_data[14 - {recv_bit_cnt, 1'b0}] <= lvds_data2;
            if (recv_bit_cnt == 3'd7)
                recv_bit_cnt <= 3'd0;
            else
                recv_bit_cnt <= recv_bit_cnt + 3'd1;
        end
        else begin
            recv_bit_cnt <= 3'd0;
        end
    end
end

// ========== 主激励 ==========
initial begin
    // 初始化
    rst_n       = 1'b0;
    restart     = 1'b0;
    timestramp  = 56'd0;
    line_id     = 16'd0;
    pts_pFrame  = PTS_PFRAME;
    fifo_data   = 48'h1100_2200_3300;
    fifo_empty  = 1'b0;
    pts_counter = 32'd0;
    x_data      = 16'h1100;
    y_data      = 16'h2200;
    z_data      = 16'h3300;
    
    // 复位
    #200;
    rst_n = 1'b1;
    #100;
    
    // ============================================================
    // 阶段1：单帧发送测试（restart上升沿触发）
    // ============================================================
    $display("[%0t] === 阶段1: 单帧发送测试（restart上升沿触发）===", $time);
    timestramp = 56'h0001_0002_0003_0105_00;
    line_id    = 16'd5;
    
    // 产生restart上升沿脉冲
    restart = 1'b1;
    #(CLK75_PERIOD);
    restart = 1'b0;
    
    // 等待发送完成（lvds_busy拉低）
    wait(lvds_busy == 1'b0);
    $display("[%0t] === 阶段1: 发送完成, send_pts_cnt=%0d ===", $time, send_pts_cnt);
    #2000;
    
    // ============================================================
    // 阶段2：修改时间戳和线ID再次发送
    // ============================================================
    $display("[%0t] === 阶段2: 不同时间戳/线ID发送测试 ===", $time);
    timestramp = 56'h000A_000B_000C_0A0F_00;
    line_id    = 16'd10;
    
    // 重置FIFO状态
    pts_counter = 32'd0;
    fifo_empty  = 1'b0;
    x_data = 16'h4400;
    y_data = 16'h5500;
    z_data = 16'h6600;
    
    restart = 1'b1;
    #(CLK75_PERIOD);
    restart = 1'b0;
    
    wait(lvds_busy == 1'b0);
    $display("[%0t] === 阶段2: 发送完成, send_pts_cnt=%0d ===", $time, send_pts_cnt);
    #2000;
    
    // ============================================================
    // 阶段3：FIFO提前为空测试（pts_pFrame设小，验证无效值填充）
    // ============================================================
    $display("[%0t] === 阶段3: FIFO提前为空测试（验证0x7FFF填充）===", $time);
    pts_pFrame  = 16'd5;     // 只需要5个点
    pts_counter = 32'd0;
    fifo_empty  = 1'b0;
    timestramp  = 56'h0000_0000_0000_0001_00;
    line_id     = 16'd1;
    x_data = 16'h1100;
    y_data = 16'h2200;
    z_data = 16'h3300;
    
    restart = 1'b1;
    #(CLK75_PERIOD);
    restart = 1'b0;
    
    wait(lvds_busy == 1'b0);
    $display("[%0t] === 阶段3: 发送完成, send_pts_cnt=%0d ===", $time, send_pts_cnt);
    #2000;
    
    // ============================================================
    // 阶段4：连续发送两帧测试
    // ============================================================
    $display("[%0t] === 阶段4: 连续发送两帧测试 ===", $time);
    pts_pFrame  = PTS_PFRAME;
    timestramp  = 56'h0001_0002_0003_0004_00;
    line_id     = 16'd1;
    pts_counter = 32'd0;
    fifo_empty  = 1'b0;
    x_data = 16'h1100;
    y_data = 16'h2200;
    z_data = 16'h3300;
    
    // 第一帧
    restart = 1'b1;
    #(CLK75_PERIOD);
    restart = 1'b0;
    wait(lvds_busy == 1'b0);
    $display("[%0t] === 阶段4: 第一帧发送完成 ===", $time);
    #500;
    
    // 第二帧
    timestramp  = 56'h0002_0003_0004_0005_00;
    line_id     = 16'd2;
    pts_counter = 32'd0;
    fifo_empty  = 1'b0;
    x_data = 16'h1111;
    y_data = 16'h2222;
    z_data = 16'h3333;
    
    restart = 1'b1;
    #(CLK75_PERIOD);
    restart = 1'b0;
    wait(lvds_busy == 1'b0);
    $display("[%0t] === 阶段4: 第二帧发送完成 ===", $time);
    #2000;
    
    // ============================================================
    // 阶段5：复位测试
    // ============================================================
    $display("[%0t] === 阶段5: 复位测试 ===", $time);
    rst_n = 1'b0;
    #200;
    rst_n = 1'b1;
    #100;
    
    pts_counter = 32'd0;
    fifo_empty  = 1'b0;
    restart = 1'b1;
    #(CLK75_PERIOD);
    restart = 1'b0;
    
    wait(lvds_busy == 1'b0);
    $display("[%0t] === 阶段5: 复位后发送完成 ===", $time);
    #2000;
    
    $display("[%0t] === 仿真结束 ===", $time);
    $finish;
end

// ========== 波形监控 ==========
initial begin
    $dumpfile("tb_lvds_tx.vcd");
    $dumpvars(0, tb_lvds_tx);
end

// ========== 关键信号变化监控 ==========
// 监控lvds_busy变化
always @(lvds_busy) begin
    $display("[%0t] lvds_busy变化: %b (%s)", $time, lvds_busy, 
             lvds_busy ? "开始发送" : "发送完成");
end

// 监控lvds_rst输出
always @(lvds_rst) begin
    $display("[%0t] lvds_rst变化: %b", $time, lvds_rst);
end

// 监控FIFO读请求
always @(posedge fifo_read_next) begin
    $display("[%0t] fifo_read_next=1, fifo_data=0x%012H, fifo_empty=%b, send_pts_cnt=%0d",
             $time, fifo_data, fifo_empty, send_pts_cnt);
end

// 监控lvds_en（应常为1）
initial begin
    #500;
    if (lvds_en !== 1'b1)
        $display("[%0t] WARNING: lvds_en应为1!", $time);
end

// 监控片选信号变化（帧起始/结束标志）
always @(lvds_csl) begin
    if (lvds_csl == 1'b0)
        $display("[%0t] >>> CSL拉低: 帧数据发送开始", $time);
    else
        $display("[%0t] >>> CSL拉高: 帧数据发送结束", $time);
end

// ========== 被测模块例化 ==========
lvds_tx u_lvds_tx (
    .clk            (clk),             // 系统时钟
    .rst_n          (rst_n),           // 异步复位，低电平有效
    .restart        (restart),         // 门控信号，上升沿启动发送
    .timestramp     (timestramp),      // 时间戳
    .line_id        (line_id),         // 激光线ID
    .pts_pFrame     (pts_pFrame),      // 每线最小点数量
    // FIFO read接口
    .lvds_rst       (lvds_rst),        // 复位信号输出
    .fifo_read_next (fifo_read_next),  // FIFO读请求
    .fifo_data      (fifo_data),       // FIFO数据输入
    .fifo_empty     (fifo_empty),      // FIFO空标志
    .lvds_busy      (lvds_busy),       // 忙标志
    // LVDS芯片接口
    .lvds_clk       (lvds_clk),        // LVDS时钟输出
    .lvds_csl       (lvds_csl),        // LVDS片选
    .lvds_data1     (lvds_data1),      // LVDS数据线1(高)
    .lvds_data2     (lvds_data2),      // LVDS数据线2(低)
    .lvds_en        (lvds_en),         // LVDS芯片使能
    .send_pts_cnt   (send_pts_cnt)     // 已发送点计数
);

endmodule
