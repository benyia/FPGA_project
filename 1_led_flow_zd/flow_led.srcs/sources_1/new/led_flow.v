
module flow_led(
    input               sys_clk  ,  //系统时钟
    input               sys_rst_n,  //系统复位，低电平有效

    output  reg  [1:0]  led         //LED灯
);

//reg define
reg  [24:0]  cnt ;                  //计数器

//计数器计时0.5s
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt <= 25'd0;
    else if(cnt < (25'd2500_0000 - 25'd1))
        cnt <= cnt + 25'd1;
    else
        cnt <= 25'd0;
end

//对LED灯进行移位控制，以输出2位LED的状态
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 2'b01;
    else if(cnt == (25'd2500_0000 - 25'd1))
        led <= {led[0],led[1]};
    else
        led <= led;
end

endmodule
