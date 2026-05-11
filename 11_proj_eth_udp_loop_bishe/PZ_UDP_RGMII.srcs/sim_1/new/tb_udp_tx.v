`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Module Name   : tb_udp_tx
// Description   : UDP发送模块仿真测试文件
//                 符合论文第四章4.4节UDP发送模块时序仿真描述
//                 验证以太网帧封装与发送流程：
//                 IDLE→CHECK_SUM→PREAMBLE→ETH_HEAD→IP_HEAD→TX_DATA→CRC
////////////////////////////////////////////////////////////////////////

module tb_udp_tx();

// ========== 参数定义 ==========
// 板卡MAC地址（与udp_tx源码中BOARD_MAC一致）
parameter BOARD_MAC = 48'h99_00_33_11_00_00;
// 板卡IP地址
parameter BOARD_IP  = {8'd192, 8'd168, 8'd1, 8'd10};
// 目的MAC地址（与udp_tx源码中DES_MAC一致，广播地址）
parameter DES_MAC   = 48'hFF_FF_FF_FF_FF_FF;
// 目的IP地址（与udp_tx源码中DES_IP一致）
parameter DES_IP    = {8'd192, 8'd168, 8'd1, 8'd112};

// ========== DUT输入信号 ==========
reg         eth_tx_clk;       // GMII发送时钟 25MHz(100Mbps)
reg         rst_n;            // 复位信号，低电平有效
reg         tx_start_en;      // 以太网开始发送信号
reg  [31:0] tx_data;          // 以太网待发送数据
reg  [15:0] tx_byte_num;      // 以太网发送的有效字节数
wire [31:0] crc_data_w;       // CRC校验数据
wire [31:0] crc_next_w;       // CRC下次校验完成数据

// ========== DUT输出信号 ==========
wire        tx_done;          // 以太网发送完成信号
wire        tx_req;           // 读数据请求信号
wire        gmii_tx_en;       // GMII输出数据有效信号
wire [7:0]  gmii_txd;        // GMII输出数据
wire        crc_en;           // CRC开始校验使能
wire        crc_clr;          // CRC数据复位信号

// ========== 内部辅助信号 ==========
reg  [31:0] data_mem [7:0];   // 发送数据存储器（扩大以支持更多数据）
reg  [15:0] cnt_data;         // 发送数据计数器
reg  [7:0]  tx_data_cnt;      // 发送字节计数（用于监控）

// ========== 时钟生成 ==========
// 25MHz GMII发送时钟（100Mbps模式下）
initial eth_tx_clk = 1'b0;
always #20 eth_tx_clk = ~eth_tx_clk;

// ========== 初始化数据存储器 ==========
integer init_idx;
initial begin
    for (init_idx = 0; init_idx < 8; init_idx = init_idx + 1)
        data_mem[init_idx] = 32'h0;
    data_mem[0] = 32'h68_74_74_70;  // "http"
    data_mem[1] = 32'h3A_2F_2F_77;  // "://w"
    data_mem[2] = 32'h77_77_00_00;  // "ww"
end

// ========== 发送数据计数器 ==========
always @(posedge eth_tx_clk or negedge rst_n) begin
    if (!rst_n)
        cnt_data <= 16'd0;
    else if (tx_req)
        cnt_data <= cnt_data + 16'd1;
    else
        cnt_data <= cnt_data;
end

// ========== 发送数据选择 ==========
always @(posedge eth_tx_clk or negedge rst_n) begin
    if (!rst_n)
        tx_data <= 32'h0;
    else if (tx_req)
        tx_data <= data_mem[cnt_data[2:0]];  // 取低3位防止越界
end

// ========== 主激励 ==========
initial begin
    // 初始化
    rst_n       = 1'b0;
    tx_start_en = 1'b0;
    tx_byte_num = 16'd10;     // 发送10字节有效数据
    cnt_data    = 16'd0;
    
    // 复位
    #200;
    rst_n = 1'b1;
    #100;
    
    // ============================================================
    // 测试1：单包UDP数据发送（10字节有效数据）
    // ============================================================
    $display("[%0t] === 测试1: 单包UDP发送（10字节有效数据）===", $time);
    tx_start_en = 1'b1;
    #40;  // 保持2个时钟周期
    tx_start_en = 1'b0;
    
    // 等待发送完成
    wait(tx_done == 1'b1);
    #100;
    $display("[%0t] === 测试1: 发送完成 ===", $time);
    #500;
    
    // ============================================================
    // 测试2：发送更多数据（40字节）
    // ============================================================
    $display("[%0t] === 测试2: 发送40字节数据 ===", $time);
    tx_byte_num = 16'd40;
    cnt_data    = 16'd0;
    
    // 重新填充数据存储器（模拟更多数据）
    data_mem[0] <= 32'h41_42_43_44;  // "ABCD"
    data_mem[1] <= 32'h45_46_47_48;  // "EFGH"
    data_mem[2] <= 32'h49_4A_4B_4C;  // "IJKL"
    
    tx_start_en = 1'b1;
    #40;
    tx_start_en = 1'b0;
    
    wait(tx_done == 1'b1);
    #100;
    $display("[%0t] === 测试2: 发送完成 ===", $time);
    #500;
    
    // ============================================================
    // 测试3：最小帧测试（18字节数据，满足以太网最小帧要求）
    // ============================================================
    $display("[%0t] === 测试3: 最小帧测试（18字节）===", $time);
    tx_byte_num = 16'd18;
    cnt_data    = 16'd0;
    
    tx_start_en = 1'b1;
    #40;
    tx_start_en = 1'b0;
    
    wait(tx_done == 1'b1);
    #100;
    $display("[%0t] === 测试3: 发送完成 ===", $time);
    #500;
    
    // ============================================================
    // 测试4：连续发送测试
    // ============================================================
    $display("[%0t] === 测试4: 连续发送两包数据 ===", $time);
    tx_byte_num = 16'd10;
    cnt_data    = 16'd0;
    data_mem[0] <= 32'h68_74_74_70;
    data_mem[1] <= 32'h3A_2F_2F_77;
    data_mem[2] <= 32'h77_77_00_00;
    
    // 第一包
    tx_start_en = 1'b1;
    #40;
    tx_start_en = 1'b0;
    wait(tx_done == 1'b1);
    #200;
    
    // 第二包
    tx_start_en = 1'b1;
    #40;
    tx_start_en = 1'b0;
    wait(tx_done == 1'b1);
    #200;
    
    $display("[%0t] === 测试4: 连续发送完成 ===", $time);
    #500;
    
    $display("[%0t] === 仿真结束 ===", $time);
    $finish;
end

// ========== 波形监控 ==========
initial begin
    $dumpfile("tb_udp_tx.vcd");
    $dumpvars(0, tb_udp_tx);
end

// ========== 关键信号变化监控 ==========
// 监控gmii_tx_en变化（帧发送起止）
reg prev_tx_en;
always @(posedge eth_tx_clk) begin
    prev_tx_en <= gmii_tx_en;
    if (gmii_tx_en && !prev_tx_en)
        $display("[%0t] >>> 帧发送开始: gmii_tx_en拉高", $time);
    if (!gmii_tx_en && prev_tx_en)
        $display("[%0t] >>> 帧发送结束: gmii_tx_en拉低", $time);
end

// 监控tx_req（数据请求）
always @(posedge tx_req) begin
    $display("[%0t]     tx_req拉高，请求数据 cnt_data=%0d", $time, cnt_data);
end

// 监控tx_done
always @(posedge tx_done) begin
    $display("[%0t]     tx_done拉高，单包发送完成", $time);
end

// 监控CRC
always @(posedge crc_en) begin
    $display("[%0t]     crc_en拉高，开始CRC校验计算", $time);
end

always @(posedge crc_clr) begin
    $display("[%0t]     crc_clr拉高，CRC校验值复位", $time);
end

// ========== 被测模块例化 ==========
udp_tx
#(
    .BOARD_MAC      (BOARD_MAC),     // 板卡MAC地址
    .BOARD_IP       (BOARD_IP),      // 板卡IP地址
    .DES_MAC        (DES_MAC),       // 目的MAC地址
    .DES_IP         (DES_IP)         // 目的IP地址
)
u_udp_tx
(
    .clk            (eth_tx_clk),    // 时钟信号
    .rst_n          (rst_n),         // 复位信号
    .tx_start_en    (tx_start_en),   // 发送开始信号
    .tx_data        (tx_data),       // 发送数据
    .tx_byte_num    (tx_byte_num),   // 发送有效字节数
    .crc_data       (crc_data_w),    // CRC校验数据
    .crc_next       (crc_next_w[7:0]), // CRC下次校验完成数据(8bit)
    // 输出
    .tx_done        (tx_done),       // 发送完成信号
    .tx_req         (tx_req),        // 读数据请求信号
    .gmii_tx_en     (gmii_tx_en),    // GMII输出数据有效信号
    .gmii_txd       (gmii_txd),      // GMII输出数据
    .crc_en         (crc_en),        // CRC校验使能
    .crc_clr        (crc_clr)        // CRC复位信号
);

// ========== CRC32校验模块例化 ==========
crc32_d8 u_crc32_d8
(
    .clk            (eth_tx_clk),    // 时钟信号
    .rst_n          (rst_n),         // 复位信号
    .data           (gmii_txd),      // 待校验数据
    .crc_en         (crc_en),        // CRC使能
    .crc_clr        (crc_clr),       // CRC复位
    .crc_data       (crc_data_w),    // CRC校验数据
    .crc_next       (crc_next_w)     // CRC下次校验完成数据
);

endmodule
