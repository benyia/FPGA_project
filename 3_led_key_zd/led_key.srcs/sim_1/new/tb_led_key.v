`timescale 1ns / 1ns        //仿真单位/仿真精度

module tb_key_led();

//parameter define
parameter  CLK_PERIOD = 20; //时钟周期 20ns

//reg define
reg           sys_clk;
reg           sys_rst_n;
reg   [1:0]   key;

//wire define
wire  [1:0]   led;

//信号初始化
initial begin
    sys_clk <= 1'b0;
    sys_rst_n <= 1'b0;
    key <= 2'b11;
    #200
    sys_rst_n <= 1'b1;
//key信号变化
    #200
    key <= 2'b11;
    #1000
    key <= 2'b10;
    #2000
    key <= 2'b11;  
    #1000
    key <= 2'b01;
end

//产生时钟
always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

//例化待测设计
key_led  u_key_led(
    .sys_clk      (sys_clk),
    .sys_rst_n    (sys_rst_n),
    .key          (key),
    .led          (led)
    );

endmodule

