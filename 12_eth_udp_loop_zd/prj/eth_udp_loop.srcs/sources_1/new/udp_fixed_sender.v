//********************************************************************//
// 固定数据 UDP 发送器
// 每 2 秒发送一次固定的 1012 字节 UDP 负载
//********************************************************************//
module udp_fixed_sender (
    input            clk,          // 125MHz GMII 时钟
    input            rst_n,
    output reg       tx_start_en,  // 发送开始脉冲
    input            tx_req,       // UDP 模块请求下一个字节
    output reg [7:0] tx_data,      // 输出数据字节
    output reg [15:0] tx_byte_num, // 总字节数 = 1012
    input            tx_done       // UDP 发送完成信号
);

    // 2 秒计数：125MHz * 2 = 250_000_000
    localparam TIME_2S = 250_000_000;
    reg [31:0] timer_cnt;
    reg timer_overflow;   // 定时器溢出标志（仅作组合逻辑判断）

    reg [2:0] state;      // 增加一位，避免综合为锁存器
    localparam IDLE       = 3'b001;
    localparam SEND_START = 3'b010;
    localparam SEND_DATA  = 3'b011;
    localparam WAIT_DONE  = 3'b100;

    reg [10:0] byte_index;   // 0 ~ 1011
    reg [7:0] fixed_rom [0:1011];   // 1012 字节 ROM

    // 从外部 HEX 文件加载固定数据（使用绝对路径）
    initial begin
        $readmemh("E:/1study_project/FPGA_project/12_eth_udp_loop_zd/rtl/fixed_data.hex", fixed_rom);
    end

    // 定时器 + 状态机（统一 always 块，避免 multi-driver）
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_cnt <= 0;
            timer_overflow <= 0;
            state <= IDLE;
            tx_start_en <= 0;
            byte_index <= 0;
            tx_data <= 0;
            tx_byte_num <= 0;
        end else begin
            // 定时器逻辑（独立于状态机，但只在这里赋值）
            if (timer_cnt >= TIME_2S - 1) begin
                timer_cnt <= 0;
                timer_overflow <= 1;
            end else begin
                timer_cnt <= timer_cnt + 1;
                timer_overflow <= 0;
            end

            // 状态机
            case (state)
                IDLE: begin
                    tx_start_en <= 0;
                    if (timer_overflow) begin
                        state <= SEND_START;
                        byte_index <= 0;
                        tx_byte_num <= 16'd1012;
                    end
                end

                SEND_START: begin
                    tx_start_en <= 1;
                    state <= SEND_DATA;
                end

                SEND_DATA: begin
                    tx_start_en <= 0;
                    if (tx_req) begin
                        tx_data <= fixed_rom[byte_index];
                        if (byte_index == 1011) begin
                            state <= WAIT_DONE;
                        end else begin
                            byte_index <= byte_index + 1;
                        end
                    end
                end

                WAIT_DONE: begin
                    if (tx_done) begin
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule