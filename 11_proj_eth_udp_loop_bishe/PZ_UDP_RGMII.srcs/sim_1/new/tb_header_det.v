`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////
// Module Name   : tb_header_det
// Description   : 帧头检测模块仿真测试文件
//                 符合论文第四章header_det模块时序仿真描述
//                 验证帧头特征字(0xEB90AA55)检测、send_en上升沿触发、
//                 FIFO读控制权切换、send_en_out脉冲输出功能
////////////////////////////////////////////////////////////////////////

module tb_header_det();

// ========== 参数定义 ==========
parameter CLK_PERIOD = 20;          // 50MHz时钟周期 20ns
parameter HEADER     = 32'hEB90AA55; // 帧头特征字（与源码一致）

// ========== DUT输入信号 ==========
reg         clk_in;           // 时钟
reg         rstn;             // 复位
reg         send_en;          // 发送使能输入
reg         fifo_rd_in;       // FIFO读请求输入
reg  [31:0] fifo_dat;         // FIFO数据
reg         udp_tx_busy;      // UDP发送忙标志

// ========== DUT输出信号 ==========
wire        fifo_rd_out;      // FIFO读请求输出
wire        send_en_out;      // 发送使能输出

// ========== 内部辅助信号 ==========
reg  [15:0] cnt;              // 通用计数器
reg  [4:0]  test_phase;       // 测试阶段标记
reg  [31:0] data_seq [7:0];   // 数据序列存储器

// ========== 50MHz时钟生成 ==========
initial clk_in = 1'b0;
always #(CLK_PERIOD/2) clk_in = ~clk_in;

// ========== 主激励 ==========
initial begin
    // 初始化
    rstn        = 1'b0;
    send_en     = 1'b0;
    fifo_rd_in  = 1'b0;
    fifo_dat    = 32'h0000_0000;
    udp_tx_busy = 1'b0;
    cnt         = 16'd0;
    test_phase  = 5'd0;
    
    // 初始化数据序列
    data_seq[0] = 32'h0000_0001;  // 非帧头数据1
    data_seq[1] = 32'h0000_0002;  // 非帧头数据2
    data_seq[2] = 32'hEB90AA55;   // 帧头特征字
    data_seq[3] = 32'h1234_5678;  // 帧头后的有效数据1
    data_seq[4] = 32'h9ABC_DEF0;  // 帧头后的有效数据2
    data_seq[5] = 32'h0000_00FF;  // 帧头后的有效数据3
    data_seq[6] = 32'h0000_0000;  // 填充
    data_seq[7] = 32'h0000_0000;  // 填充
    
    // 复位
    #200;
    rstn = 1'b1;
    #100;
    
    // ============================================================
    // 阶段1：send_en上升沿触发，帧头在第一个FIFO数据中
    // ============================================================
    $display("[%0t] === 阶段1: send_en上升沿触发，帧头在首位置 ===", $time);
    test_phase = 5'd1;
    
    // 产生send_en上升沿
    send_en = 1'b1;
    #(CLK_PERIOD);
    send_en = 1'b0;
    
    // 模拟FIFO输出数据：先是非帧头，然后帧头
    fifo_dat = data_seq[0];  // 非帧头数据1
    #(CLK_PERIOD * 5);
    fifo_dat = data_seq[1];  // 非帧头数据2
    #(CLK_PERIOD * 5);
    fifo_dat = data_seq[2];  // 帧头特征字 0xEB90AA55
    #(CLK_PERIOD * 3);
    
    // 检测到帧头后，模拟FIFO持续输出有效数据
    fifo_rd_in = 1'b1;
    fifo_dat = data_seq[3];
    #(CLK_PERIOD * 3);
    fifo_dat = data_seq[4];
    #(CLK_PERIOD * 3);
    fifo_dat = data_seq[5];
    #(CLK_PERIOD * 5);
    fifo_rd_in = 1'b0;
    
    #500;
    
    // ============================================================
    // 阶段2：帧头不在首位置，需要跳过无效数据
    // ============================================================
    $display("[%0t] === 阶段2: 帧头不在首位置，跳过无效数据 ===", $time);
    test_phase = 5'd2;
    
    // 产生send_en上升沿
    send_en = 1'b1;
    #(CLK_PERIOD);
    send_en = 1'b0;
    
    // 模拟多个非帧头数据，然后才出现帧头
    fifo_dat = 32'hAAAA_0001;
    #(CLK_PERIOD * 3);
    fifo_dat = 32'hBBBB_0002;
    #(CLK_PERIOD * 3);
    fifo_dat = 32'hCCCC_0003;
    #(CLK_PERIOD * 3);
    fifo_dat = 32'hDDDD_0004;
    #(CLK_PERIOD * 3);
    // 出现帧头
    fifo_dat = HEADER;       // 0xEB90AA55
    #(CLK_PERIOD * 3);
    
    // 帧头后有效数据
    fifo_rd_in = 1'b1;
    fifo_dat = 32'hDEAD_BEEF;
    #(CLK_PERIOD * 3);
    fifo_dat = 32'hCAFE_BABE;
    #(CLK_PERIOD * 5);
    fifo_rd_in = 1'b0;
    
    #500;
    
    // ============================================================
    // 阶段3：无帧头数据（始终不匹配）
    // ============================================================
    $display("[%0t] === 阶段3: 无帧头数据（始终不匹配）===", $time);
    test_phase = 5'd3;
    
    send_en = 1'b1;
    #(CLK_PERIOD);
    send_en = 1'b0;
    
    // 持续输出非帧头数据
    fifo_dat = 32'h1111_1111;
    #(CLK_PERIOD * 5);
    fifo_dat = 32'h2222_2222;
    #(CLK_PERIOD * 5);
    fifo_dat = 32'h3333_3333;
    #(CLK_PERIOD * 5);
    
    #500;
    
    // ============================================================
    // 阶段4：连续两次send_en触发
    // ============================================================
    $display("[%0t] === 阶段4: 连续两次send_en触发 ===", $time);
    test_phase = 5'd4;
    
    // 第一次触发
    send_en = 1'b1;
    #(CLK_PERIOD);
    send_en = 1'b0;
    
    fifo_dat = HEADER;       // 直接给出帧头
    #(CLK_PERIOD * 3);
    fifo_rd_in = 1'b1;
    fifo_dat = 32'h5555_5555;
    #(CLK_PERIOD * 3);
    fifo_rd_in = 1'b0;
    #200;
    
    // 第二次触发
    send_en = 1'b1;
    #(CLK_PERIOD);
    send_en = 1'b0;
    
    fifo_dat = 32'h0000_0001;  // 先非帧头
    #(CLK_PERIOD * 3);
    fifo_dat = HEADER;         // 然后帧头
    #(CLK_PERIOD * 3);
    fifo_rd_in = 1'b1;
    fifo_dat = 32'h6666_6666;
    #(CLK_PERIOD * 5);
    fifo_rd_in = 1'b0;
    
    #500;
    
    // ============================================================
    // 阶段5：复位测试
    // ============================================================
    $display("[%0t] === 阶段5: 复位测试 ===", $time);
    test_phase = 5'd5;
    
    rstn = 1'b0;
    #200;
    rstn = 1'b1;
    #100;
    
    send_en = 1'b1;
    #(CLK_PERIOD);
    send_en = 1'b0;
    
    fifo_dat = HEADER;
    #(CLK_PERIOD * 3);
    fifo_rd_in = 1'b1;
    fifo_dat = 32'h7777_7777;
    #(CLK_PERIOD * 5);
    fifo_rd_in = 1'b0;
    
    #500;
    
    $display("[%0t] === 仿真结束 ===", $time);
    $finish;
end

// ========== 波形监控 ==========
initial begin
    $dumpfile("tb_header_det.vcd");
    $dumpvars(0, tb_header_det);
end

// ========== 关键信号变化监控 ==========
// 监控send_en_out脉冲
always @(posedge send_en_out) begin
    $display("[%0t] >>> send_en_out拉高: 帧头检测成功，触发UDP发送!", $time);
end

// 监控fifo_rd_out变化
reg prev_fifo_rd_out;
always @(posedge clk_in) begin
    prev_fifo_rd_out <= fifo_rd_out;
    if (fifo_rd_out && !prev_fifo_rd_out)
        $display("[%0t] >>> fifo_rd_out拉高", $time);
end

// 监控send_en上升沿
reg prev_send_en;
always @(posedge clk_in) begin
    prev_send_en <= send_en;
    if (send_en && !prev_send_en)
        $display("[%0t] >>> send_en上升沿检测", $time);
end

// 监控fifo_dat与帧头匹配
always @(posedge clk_in) begin
    if (fifo_dat == HEADER)
        $display("[%0t] >>> fifo_dat = 0x%08H (帧头匹配!)", $time, fifo_dat);
end

// ========== 被测模块例化 ==========
header_det u_header_det (
    .clk_in      (clk_in),       // 时钟
    .rstn        (rstn),         // 复位
    .send_en     (send_en),      // 发送使能输入
    .fifo_rd_in  (fifo_rd_in),   // FIFO读请求输入
    .fifo_dat    (fifo_dat),     // FIFO数据
    .udp_tx_busy (udp_tx_busy),  // UDP发送忙标志
    .fifo_rd_out (fifo_rd_out),  // FIFO读请求输出
    .send_en_out (send_en_out)   // 发送使能输出
);

endmodule
