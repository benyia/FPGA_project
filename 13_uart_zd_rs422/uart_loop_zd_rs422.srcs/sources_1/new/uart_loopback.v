module uart_loopback(
    input            sys_clk  ,
    input            sys_rst_n,
    input            uart_rxd ,
    output           uart_txd
    );

parameter CLK_FREQ = 50000000;
parameter UART_BPS = 115200;

wire         uart_rx_done;
wire  [7:0]  uart_rx_data;
wire         uart_tx_busy;

localparam FIXED_DATA_BYTES = 13;   // 改为 13 字节：AA + 11字节数据 + BB
localparam S_IDLE      = 2'b00;
localparam S_START     = 2'b01;
localparam S_WAIT_END  = 2'b10;

reg  [1:0] tx_state;
reg  [3:0] tx_index;
reg        tx_en_pulse;
reg  [7:0] tx_data_reg;
reg        send_fixed_req;
reg  [39:0] rx_seq;
reg        seq_detected;
reg        uart_tx_busy_dly;
wire       tx_busy_falling = uart_tx_busy_dly & ~uart_tx_busy;

// UART 接收模块实例化
uart_rx #(.CLK_FREQ(CLK_FREQ), .UART_BPS(UART_BPS))
    u_uart_rx(
        .clk(sys_clk), .rst_n(sys_rst_n),
        .uart_rxd(uart_rxd),
        .uart_rx_done(uart_rx_done),
        .uart_rx_data(uart_rx_data)
    );

// UART 发送模块实例化
uart_tx #(.CLK_FREQ(CLK_FREQ), .UART_BPS(UART_BPS))
    u_uart_tx(
        .clk(sys_clk), .rst_n(sys_rst_n),
        .uart_tx_en(tx_en_pulse),
        .uart_tx_data(tx_data_reg),
        .uart_txd(uart_txd),
        .uart_tx_busy(uart_tx_busy)
    );

// 延迟 busy 信号
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        uart_tx_busy_dly <= 1'b0;
    else
        uart_tx_busy_dly <= uart_tx_busy;
end

// 序列检测：55 00 01 01 57
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        rx_seq <= 40'b0;
        seq_detected <= 1'b0;
    end
    else begin
        if(uart_rx_done) begin
            rx_seq <= {rx_seq[31:0], uart_rx_data};
            if({rx_seq[31:0], uart_rx_data} == {8'h55,8'h00,8'h01,8'h01,8'h57})
                seq_detected <= 1'b1;
            else
                seq_detected <= 1'b0;
        end
        else
            seq_detected <= 1'b0;
    end
end

// 发送请求
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        send_fixed_req <= 1'b0;
    else if(seq_detected && tx_state == S_IDLE)
        send_fixed_req <= 1'b1;
    else if(tx_state != S_IDLE)
        send_fixed_req <= 1'b0;
    else
        send_fixed_req <= send_fixed_req;
end

// 状态机：发送13字节（帧头 + 原11字节 + 帧尾）
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        tx_state    <= S_IDLE;
        tx_index    <= 4'd0;
        tx_en_pulse <= 1'b0;
        tx_data_reg <= 8'b0;
    end
    else begin
        case(tx_state)
            S_IDLE: begin
                tx_en_pulse <= 1'b0;
                if(send_fixed_req) begin
                    tx_index <= 4'd0;
                    tx_state <= S_START;
                end
            end

            S_START: begin
                // 根据索引取出要发送的字节
                case(tx_index)
                    // 帧头
                    4'd0  : tx_data_reg <= 8'hAA;
                    // 原11字节数据（20 26 04 29 08 11 36 CC DD EE FF）
                    4'd1  : tx_data_reg <= 8'h20;
                    4'd2  : tx_data_reg <= 8'h26;
                    4'd3  : tx_data_reg <= 8'h04;
                    4'd4  : tx_data_reg <= 8'h29;
                    4'd5  : tx_data_reg <= 8'h08;
                    4'd6  : tx_data_reg <= 8'h11;
                    4'd7  : tx_data_reg <= 8'h36;
                    4'd8  : tx_data_reg <= 8'hCC;
                    4'd9  : tx_data_reg <= 8'hDD;
                    4'd10 : tx_data_reg <= 8'hEE;
                    4'd11 : tx_data_reg <= 8'hFF;
                    // 帧尾
                    4'd12 : tx_data_reg <= 8'hBB;
                    default: tx_data_reg <= 8'h00;
                endcase
                tx_en_pulse <= 1'b1;
                tx_state    <= S_WAIT_END;
            end

            S_WAIT_END: begin
                tx_en_pulse <= 1'b0;
                if(tx_busy_falling) begin
                    if(tx_index == FIXED_DATA_BYTES - 1)
                        tx_state <= S_IDLE;
                    else begin
                        tx_index <= tx_index + 1'b1;
                        tx_state <= S_START;
                    end
                end
            end

            default: tx_state <= S_IDLE;
        endcase
    end
end
ila_0 u_ila_0 (
    .clk(sys_clk),              // 采样时钟 = 系统时钟50MHz

    // === 基本信号 ===
    .probe0(sys_rst_n),         // 复位信号
    .probe1(uart_rxd),          // RS-422接收（来自上位机）
    .probe2(uart_txd),          // RS-422发送（发回上位机）
    .probe3(uart_rx_done),      // 接收完成标志
    .probe4(uart_tx_busy),      // 发送忙标志
    .probe5(tx_busy_falling),   // 发送完成检测（busy下降沿）
    
    // === 数据信号 ===
    .probe6(seq_detected),      // 序列检测到标志（55 00 01 01 57）
    .probe7(uart_rx_data),      // 接收到的1字节数据
    .probe8(tx_data_reg),       // 待发送的1字节数据
    
    // === 状态机信号 ===
    .probe9(tx_state),          // 发送状态机 [1:0]
    .probe10(tx_index),         // 发送字节索引 [3:0]
    
    // === 发送使能 ===
    .probe11(tx_en_pulse)       // UART发送使能脉冲
);
endmodule