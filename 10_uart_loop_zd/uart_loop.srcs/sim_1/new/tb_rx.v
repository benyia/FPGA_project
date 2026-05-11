`timescale 1ns / 1ps

module tb_rs422_receiver();

// 参数定义
localparam CLK_PERIOD = 20;          // 50MHz时钟周期 (20ns)
localparam BAUD_RATE = 9600;
localparam BIT_TIME = 1000000000 / BAUD_RATE;  // 纳秒单位
localparam BIT_TIME_TICKS = BIT_TIME / CLK_PERIOD;  // 每比特时钟周期数

// 测试信号
reg         clk         = 0;
reg         rst_n       = 0;
reg         rx_in       = 1;        // 空闲状态为高电平
wire [7:0]  rx_data;
wire        rx_valid;

// 实例化接收模块 (假设模块名为 rs422_receiver)
rs422_receiver #(
    .BAUD_RATE(9600),
    .CLK_FREQ(50000000)
) uut (
    .clk        (clk),
    .rst_n      (rst_n),
    .rx_in      (rx_in),
    .rx_data    (rx_data),
    .rx_valid   (rx_valid)
);

// 时钟生成
always #(CLK_PERIOD/2) clk = ~clk;

// 发送一帧串行数据 (LSB优先)
task send_byte;
    input [7:0] data;
    integer i;
    begin
        // 起始位 (低电平)
        rx_in = 0;
        #(BIT_TIME);
        
        // 8位数据位 (LSB优先)
        for (i = 0; i < 8; i = i + 1) begin
            rx_in = data[i];
            #(BIT_TIME);
        end
        
        // 停止位 (高电平)
        rx_in = 1;
        #(BIT_TIME);
        
        // 等待一个比特时间，确保接收模块完全处理
        #(BIT_TIME);
    end
endtask

// 发送多字节数据
task send_multiple_bytes;
    input [7:0] data1, data2, data3;
    begin
        send_byte(data1);
        send_byte(data2);
        send_byte(data3);
    end
endtask

// 验证函数
task verify_data;
    input [7:0] expected;
    input [7:0] actual;
    input [31:0] test_num;
    begin
        if (actual == expected)
            $display("Test %0d PASSED: Expected 0x%02X, Got 0x%02X", test_num, expected, actual);
        else
            $display("Test %0d FAILED: Expected 0x%02X, Got 0x%02X", test_num, expected, actual);
    end
endtask

// 主测试流程
initial begin
    $display("=========================================");
    $display("RS-422 Receiver Testbench Started");
    $display("Baud Rate: 9600 bps, Clock: 50MHz");
    $display("Frame Format: 1 Start + 8 Data (LSB) + 1 Stop");
    $display("=========================================\n");
    
    // 初始复位
    rst_n = 0;
    repeat(10) @(posedge clk);
    rst_n = 1;
    repeat(5) @(posedge clk);
    
    // 等待接收模块稳定
    #(BIT_TIME * 2);
    
    // ========== 测试1: 发送0x55 ==========
    $display("\n>>> Test 1: Send 0x55 (01010101)");
    send_byte(8'h55);
    
    // 等待接收完成
    wait(rx_valid);
    @(posedge clk);
    verify_data(8'h55, rx_data, 1);
    wait(!rx_valid);
    #(BIT_TIME * 2);
    
    // ========== 测试2: 发送0xAA ==========
    $display("\n>>> Test 2: Send 0xAA (10101010)");
    send_byte(8'hAA);
    
    wait(rx_valid);
    @(posedge clk);
    verify_data(8'hAA, rx_data, 2);
    wait(!rx_valid);
    #(BIT_TIME * 2);
    
    // ========== 测试3: 连续发送多字节 ==========
    $display("\n>>> Test 3: Continuous Multi-Byte Transmission");
    $display("Sending: 0x01, 0x02, 0x03 sequentially");
    
    send_multiple_bytes(8'h01, 8'h02, 8'h03);
    
    // 验证第一个字节
    wait(rx_valid);
    @(posedge clk);
    verify_data(8'h01, rx_data, "3.1");
    wait(!rx_valid);
    #(BIT_TIME);
    
    // 验证第二个字节
    wait(rx_valid);
    @(posedge clk);
    verify_data(8'h02, rx_data, "3.2");
    wait(!rx_valid);
    #(BIT_TIME);
    
    // 验证第三个字节
    wait(rx_valid);
    @(posedge clk);
    verify_data(8'h03, rx_data, "3.3");
    wait(!rx_valid);
    
    // ========== 额外测试: 边界条件 ==========
    $display("\n>>> Extra Test: Send 0x00 (all zeros)");
    send_byte(8'h00);
    wait(rx_valid);
    @(posedge clk);
    verify_data(8'h00, rx_data, "Extra 1");
    wait(!rx_valid);
    #(BIT_TIME * 2);
    
    $display("\n>>> Extra Test: Send 0xFF (all ones)");
    send_byte(8'hFF);
    wait(rx_valid);
    @(posedge clk);
    verify_data(8'hFF, rx_data, "Extra 2");
    wait(!rx_valid);
    
    // ========== 测试结束 ==========
    #(BIT_TIME * 10);
    $display("\n=========================================");
    $display("All tests completed!");
    $display("=========================================");
    $finish;
end

// 监控接收数据输出
always @(posedge clk) begin
    if (rx_valid)
        $display("Time %0t ns: rx_data = 0x%02X, rx_valid = 1", $time, rx_data);
end

// 波形文件生成 (可选)
initial begin
    $dumpfile("tb_rs422_receiver.vcd");
    $dumpvars(0, tb_rs422_receiver);
end

endmodule