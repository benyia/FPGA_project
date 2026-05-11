
module key_led(
    input               sys_clk   ,  //系统时钟
    input               sys_rst_n ,  //系统复位，低电平有效

    input        [1:0]  key       ,  //按键
    output  reg  [1:0]  led          //LED灯
);

//parameter define
parameter  CNT_MAX = 25'd2500_0000;    //LED灯闪烁频率

//reg define
reg         [24:0]      cnt;                      //计数器
reg                     led_flag;                 //LED控制信号

//计数器计时0.5s
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt <= 25'd0;
    else if(cnt < (CNT_MAX - 25'd1))
        cnt <= cnt + 25'd1;
    else
        cnt <= 25'd0;
end

//每隔500ms就更改LED的闪烁状态
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led_flag <= 1'b0;
    else if(cnt == (CNT_MAX - 25'd1))
        led_flag <= ~led_flag;
end

//根据按键的状态以及LED的闪烁状态来赋值LED
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 2'b00;
    else case(key)
        2'b10 :  //如果按键0被按下，则两个LED交替闪烁
            if(led_flag == 1'b0)
                led <= 2'b01;
            else
                led <= 2'b10;
        2'b01 :  //如果按键1被按下，则两个LED同时亮灭交替
            if(led_flag == 1'b0)
                led <= 2'b11;
            else
                led <= 2'b00;
        2'b11 :  //如果两个按键都未被按下，则两个LED都保持长灭
                led <= 2'b00;
        default: ;
    endcase
end

endmodule
