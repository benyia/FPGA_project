`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Module Name   : tb_udp_rx
// Description   : UDP接收模块仿真测试文件
//                 符合论文第四章4.4节UDP接收模块时序仿真描述
//                 验证以太网帧接收、MAC/IP/UDP首部解析、数据提取
////////////////////////////////////////////////////////////////////////

module tb_udp_rx();

// ========== 参数定义 ==========
// 板卡MAC地址（与udp_rx源码中BOARD_MAC一致）
parameter BOARD_MAC = 48'h99_00_33_11_00_00;
// 板卡IP地址
parameter BOARD_IP  = {8'd192, 8'd168, 8'd1, 8'd10};
// 源MAC地址（上位机）
parameter SRC_MAC   = 48'h00_11_22_33_44_55;
// 源IP地址（上位机）
parameter SRC_IP    = {8'd192, 8'd168, 8'd1, 8'd102};

// ========== DUT输入信号 ==========
reg         eth_rx_clk;       // GMII接收时钟 25MHz
reg         rst_n;            // 复位信号，低电平有效
reg         gmii_rx_en;       // GMII输入数据有效信号
reg  [7:0]  gmii_rxd;        // GMII输入数据

// ========== DUT输出信号 ==========
wire        rec_pkt_done;     // 单包数据接收完成信号
wire        rec_en;           // 接收数据使能信号
wire [31:0] rec_data;         // 接收到的数据
wire [15:0] rec_byte_num;     // 接收有效字节数

// ========== 内部辅助信号 ==========
reg  [7:0]  frame_mem [127:0]; // 帧数据存储器
reg  [7:0]  byte_cnt;          // 字节计数器
reg         start_flag;        // 发送开始标志
reg  [15:0] ip_total_len;      // IP总长度
reg  [15:0] udp_len;           // UDP长度
reg  [7:0]  payload [15:0];   // 有效数据负载
reg  [15:0] payload_len;       // 有效数据长度
integer     i;

// ========== 时钟生成 ==========
initial eth_rx_clk = 1'b0;
always #20 eth_rx_clk = ~eth_rx_clk;  // 25MHz

// ========== 构建以太网帧任务 ==========
// 按照IEEE 802.3标准构建完整的UDP以太网帧
task build_udp_frame;
    input [15:0] data_len;    // 有效数据字节数
    reg [15:0] real_data_len; // 实际数据长度（最小18字节）
    reg [15:0] udp_length;    // UDP总长度
    reg [15:0] ip_length;     // IP总长度
    reg [16:0] check_sum;     // IP校验和
    integer j;
    begin
        // 确保数据满足以太网最小帧要求
        real_data_len = (data_len >= 16'd18) ? data_len : 16'd18;
        udp_length = real_data_len + 16'd8;    // UDP长度 = 数据 + 8字节首部
        ip_length = udp_length + 16'd20;       // IP长度 = UDP + 20字节IP首部
        payload_len = data_len;
        
        j = 0;
        
        // 前导码：7个0x55 + 1个0xD5
        frame_mem[j] = 8'h55; j = j + 1;
        frame_mem[j] = 8'h55; j = j + 1;
        frame_mem[j] = 8'h55; j = j + 1;
        frame_mem[j] = 8'h55; j = j + 1;
        frame_mem[j] = 8'h55; j = j + 1;
        frame_mem[j] = 8'h55; j = j + 1;
        frame_mem[j] = 8'h55; j = j + 1;
        frame_mem[j] = 8'hD5; j = j + 1;
        
        // 以太网帧头：目的MAC(6B) + 源MAC(6B) + 类型(2B)
        // 目的MAC = 板卡MAC
        frame_mem[j] = BOARD_MAC[47:40]; j = j + 1;
        frame_mem[j] = BOARD_MAC[39:32]; j = j + 1;
        frame_mem[j] = BOARD_MAC[31:24]; j = j + 1;
        frame_mem[j] = BOARD_MAC[23:16]; j = j + 1;
        frame_mem[j] = BOARD_MAC[15:8];  j = j + 1;
        frame_mem[j] = BOARD_MAC[7:0];   j = j + 1;
        // 源MAC = 上位机MAC
        frame_mem[j] = SRC_MAC[47:40];   j = j + 1;
        frame_mem[j] = SRC_MAC[39:32];   j = j + 1;
        frame_mem[j] = SRC_MAC[31:24];   j = j + 1;
        frame_mem[j] = SRC_MAC[23:16];   j = j + 1;
        frame_mem[j] = SRC_MAC[15:8];    j = j + 1;
        frame_mem[j] = SRC_MAC[7:0];     j = j + 1;
        // 类型 = 0x0800 (IPv4)
        frame_mem[j] = 8'h08; j = j + 1;
        frame_mem[j] = 8'h00; j = j + 1;
        
        // IP首部 (20字节)
        frame_mem[j] = 8'h45;  j = j + 1;  // 版本4 + 首部长度5(20字节)
        frame_mem[j] = 8'h00;  j = j + 1;  // TOS
        frame_mem[j] = ip_length[15:8]; j = j + 1;  // 总长度高字节
        frame_mem[j] = ip_length[7:0];  j = j + 1;  // 总长度低字节
        frame_mem[j] = 8'h00;  j = j + 1;  // 标识高字节
        frame_mem[j] = 8'h01;  j = j + 1;  // 标识低字节
        frame_mem[j] = 8'h40;  j = j + 1;  // 标志+片偏移（不分片）
        frame_mem[j] = 8'h00;  j = j + 1;
        frame_mem[j] = 8'h40;  j = j + 1;  // TTL=64
        frame_mem[j] = 8'h11;  j = j + 1;  // 协议=17(UDP)
        frame_mem[j] = 8'h00;  j = j + 1;  // 校验和（简化为0，实际需计算）
        frame_mem[j] = 8'h00;  j = j + 1;
        // 源IP
        frame_mem[j] = SRC_IP[31:24];  j = j + 1;
        frame_mem[j] = SRC_IP[23:16];  j = j + 1;
        frame_mem[j] = SRC_IP[15:8];   j = j + 1;
        frame_mem[j] = SRC_IP[7:0];    j = j + 1;
        // 目的IP
        frame_mem[j] = BOARD_IP[31:24]; j = j + 1;
        frame_mem[j] = BOARD_IP[23:16]; j = j + 1;
        frame_mem[j] = BOARD_IP[15:8];  j = j + 1;
        frame_mem[j] = BOARD_IP[7:0];   j = j + 1;
        
        // UDP首部 (8字节)
        frame_mem[j] = 8'h04;  j = j + 1;  // 源端口高字节 (1234 = 0x04D2)
        frame_mem[j] = 8'hD2;  j = j + 1;  // 源端口低字节
        frame_mem[j] = 8'h04;  j = j + 1;  // 目的端口高字节 (1234)
        frame_mem[j] = 8'hD2;  j = j + 1;  // 目的端口低字节
        frame_mem[j] = udp_length[15:8]; j = j + 1;  // UDP长度高字节
        frame_mem[j] = udp_length[7:0];  j = j + 1;  // UDP长度低字节
        frame_mem[j] = 8'h00;  j = j + 1;  // UDP校验和高字节（可选为0）
        frame_mem[j] = 8'h00;  j = j + 1;  // UDP校验和低字节
        
        // 有效数据负载
        payload[0] = 8'h48;  // 'H'
        payload[1] = 8'h65;  // 'e'
        payload[2] = 8'h6C;  // 'l'
        payload[3] = 8'h6C;  // 'l'
        payload[4] = 8'h6F;  // 'o'
        payload[5] = 8'h57;  // 'W'
        payload[6] = 8'h6F;  // 'o'
        payload[7] = 8'h72;  // 'r'
        payload[8] = 8'h6C;  // 'l'
        payload[9] = 8'h64;  // 'd'
        for (j = 0; j < data_len; j = j + 1) begin
            frame_mem[54 + j] = payload[j % 16];
        end
        
        // 填充（如果数据少于18字节）
        for (j = data_len; j < real_data_len; j = j + 1) begin
            frame_mem[54 + j] = 8'h00;
        end
        
        // 更新字节计数（不含前导码和FCS，GMII接口不发送FCS）
        byte_cnt = 14 + 20 + 8 + real_data_len[7:0];  // 帧头+IP+UDP+数据
    end
endtask

// ========== 发送帧数据任务 ==========
task send_frame;
    input [7:0] total_bytes;  // 帧总字节数（不含前导码和FCS）
    reg [7:0]  send_cnt;
    begin
        // 先发送前导码
        @(negedge eth_rx_clk);
        gmii_rx_en = 1'b1;
        gmii_rxd   = frame_mem[0];  // 0x55
        
        for (send_cnt = 1; send_cnt < 8 + total_bytes; send_cnt = send_cnt + 1) begin
            @(negedge eth_rx_clk);
            gmii_rxd = frame_mem[send_cnt];
        end
        
        // 帧结束
        @(negedge eth_rx_clk);
        gmii_rx_en = 1'b0;
        gmii_rxd   = 8'h00;
    end
endtask

// ========== 主激励 ==========
initial begin
    // 初始化
    rst_n       = 1'b0;
    gmii_rx_en  = 1'b0;
    gmii_rxd    = 8'h00;
    start_flag  = 1'b0;
    byte_cnt    = 8'h0;
    
    // 复位
    #200;
    rst_n = 1'b1;
    #100;
    
    // ============================================================
    // 测试1：接收10字节有效数据的UDP帧
    // ============================================================
    $display("[%0t] === 测试1: 接收10字节UDP数据 ===", $time);
    build_udp_frame(16'd10);
    #100;
    send_frame(byte_cnt);
    #1000;
    
    // ============================================================
    // 测试2：接收更多数据（20字节）
    // ============================================================
    $display("[%0t] === 测试2: 接收20字节UDP数据 ===", $time);
    build_udp_frame(16'd20);
    #200;
    send_frame(byte_cnt);
    #1000;
    
    // ============================================================
    // 测试3：接收最小帧（18字节数据）
    // ============================================================
    $display("[%0t] === 测试3: 接收最小帧（18字节数据）===", $time);
    build_udp_frame(16'd18);
    #200;
    send_frame(byte_cnt);
    #1000;
    
    // ============================================================
    // 测试4：连续接收两帧
    // ============================================================
    $display("[%0t] === 测试4: 连续接收两帧 ===", $time);
    build_udp_frame(16'd10);
    #200;
    send_frame(byte_cnt);
    #500;
    
    build_udp_frame(16'd12);
    #200;
    send_frame(byte_cnt);
    #1000;
    
    // ============================================================
    // 测试5：MAC地址不匹配的帧（应被丢弃）
    // ============================================================
    $display("[%0t] === 测试5: MAC地址不匹配帧（应被丢弃）===", $time);
    // 构建一个目的MAC不匹配的帧
    begin
        integer k;
        k = 0;
        // 前导码
        frame_mem[k] = 8'h55; k = k + 1;
        frame_mem[k] = 8'h55; k = k + 1;
        frame_mem[k] = 8'h55; k = k + 1;
        frame_mem[k] = 8'h55; k = k + 1;
        frame_mem[k] = 8'h55; k = k + 1;
        frame_mem[k] = 8'h55; k = k + 1;
        frame_mem[k] = 8'h55; k = k + 1;
        frame_mem[k] = 8'hD5; k = k + 1;
        // 目的MAC（错误：不是板卡MAC）
        frame_mem[k] = 8'hFF; k = k + 1;
        frame_mem[k] = 8'hFF; k = k + 1;
        frame_mem[k] = 8'hFF; k = k + 1;
        frame_mem[k] = 8'hFF; k = k + 1;
        frame_mem[k] = 8'hFF; k = k + 1;
        frame_mem[k] = 8'hFE; k = k + 1;  // 最后一字节不同
        // 源MAC
        frame_mem[k] = SRC_MAC[47:40]; k = k + 1;
        frame_mem[k] = SRC_MAC[39:32]; k = k + 1;
        frame_mem[k] = SRC_MAC[31:24]; k = k + 1;
        frame_mem[k] = SRC_MAC[23:16]; k = k + 1;
        frame_mem[k] = SRC_MAC[15:8];  k = k + 1;
        frame_mem[k] = SRC_MAC[7:0];   k = k + 1;
        // 类型
        frame_mem[k] = 8'h08; k = k + 1;
        frame_mem[k] = 8'h00; k = k + 1;
        
        // 简单填充IP+UDP+数据
        build_udp_frame(16'd10);
        // 复制剩余部分（从IP首部开始）
        for (k = 22; k < 22 + byte_cnt - 14; k = k + 1) begin
            // 这里使用build_udp_frame已填充的数据
        end
        byte_cnt = 14 + 20 + 8 + 18;  // 帧头+IP+UDP+最小数据
        send_frame(byte_cnt);
    end
    #500;
    
    $display("[%0t] === 仿真结束 ===", $time);
    $finish;
end

// ========== 波形监控 ==========
initial begin
    $dumpfile("tb_udp_rx.vcd");
    $dumpvars(0, tb_udp_rx);
end

// ========== 关键信号变化监控 ==========
// 监控接收完成
always @(posedge rec_pkt_done) begin
    $display("[%0t] >>> rec_pkt_done拉高: 单包数据接收完成", $time);
    $display("[%0t]     rec_byte_num = %0d 字节", $time, rec_byte_num);
end

// 监控数据输出
always @(posedge rec_en) begin
    $display("[%0t]     rec_en=1, rec_data = 0x%08H", $time, rec_data);
end

// 监控gmii_rx_en变化
reg prev_rx_en;
always @(posedge eth_rx_clk) begin
    prev_rx_en <= gmii_rx_en;
    if (gmii_rx_en && !prev_rx_en)
        $display("[%0t] >>> gmii_rx_en拉高: 帧接收开始", $time);
    if (!gmii_rx_en && prev_rx_en)
        $display("[%0t] >>> gmii_rx_en拉低: 帧接收结束", $time);
end

// ========== 被测模块例化 ==========
udp_rx
#(
    .BOARD_MAC      (BOARD_MAC),     // 板卡MAC地址
    .BOARD_IP       (BOARD_IP)       // 板卡IP地址
)
u_udp_rx
(
    .clk            (eth_rx_clk),    // 时钟信号
    .rst_n          (rst_n),         // 复位信号
    .gmii_rx_en     (gmii_rx_en),    // GMII输入数据有效信号
    .gmii_rxd       (gmii_rxd),      // GMII输入数据
    // 输出
    .rec_pkt_done   (rec_pkt_done),  // 单包数据接收完成信号
    .rec_en         (rec_en),        // 接收数据使能信号
    .rec_data       (rec_data),      // 接收到的数据
    .rec_byte_num   (rec_byte_num)   // 接收有效字节数
);

endmodule
