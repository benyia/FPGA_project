module uart_rx(
    input               clk         ,  //ϵͳʱ��
    input               rst_n       ,  //ϵͳ��λ������Ч

    input               uart_rxd    ,  //UART���ն˿�
    output  reg         uart_rx_done,  //UART��������ź�?
    output  reg  [7:0]  uart_rx_data   //UART���յ�������
    );

//parameter define
parameter CLK_FREQ    = 50000000;         //ϵͳʱ��Ƶ��
parameter UART_BPS    = 115200  ;         //���ڲ�����
localparam BAUD_CNT_MAX = CLK_FREQ/UART_BPS;//Ϊ�õ�ָ�������ʣ���ϵͳʱ�Ӽ���BPS_CNT��

//reg define
reg          uart_rxd_d0;  //uart_rxd�ӳ�һ��ʱ������������ź�?
reg          uart_rxd_d1;  //uart_rxd�ӳ�����ʱ������������ź�?
reg          uart_rxd_d2;  //uart_rxd�ӳ�����ʱ������������ź�?
reg          rx_flag    ;  //���չ��̱�־�ź�
reg  [3:0 ]  rx_cnt     ;  //�������ݼ�����
reg  [15:0]  baud_cnt   ;  //�����ʼ�����
reg  [7:0 ]  rx_data_t  ;  //�������ݼĴ���

//wire define
wire        start_en;

//������ն˿��½���?(��ʼλ)���õ�һ��ʱ�����ڵ������ź�
assign start_en = uart_rxd_d2 & (~uart_rxd_d1) & (~rx_flag);

//����첽�źŵ�ͬ������?
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        uart_rxd_d0 <= 1'b0;
        uart_rxd_d1 <= 1'b0;
        uart_rxd_d2 <= 1'b0;
    end
    else begin
        uart_rxd_d0 <= uart_rxd;
        uart_rxd_d1 <= uart_rxd_d0;
        uart_rxd_d2 <= uart_rxd_d1;
    end
end

//�����ձ�־��ֵ
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rx_flag <= 1'b0;
    else if(start_en)    //��⵽��ʼ�?
        rx_flag <= 1'b1; //���չ����У���־�ź�rx_flag����
    //��ֹͣλһ���ʱ�򣬼����չ��̽�������־�ź�rx_flag����
    else if((rx_cnt == 4'd9) && (baud_cnt == BAUD_CNT_MAX/2 - 16'b1))
        rx_flag <= 1'b0;
    else
        rx_flag <= rx_flag;
end        

//�����ʵļ�������ֵ
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        baud_cnt <= 16'd0;
    else if(rx_flag) begin     //���ڽ��չ���ʱ�������ʼ�������baud_cnt������ѭ������
        if(baud_cnt < BAUD_CNT_MAX - 16'b1)
            baud_cnt <= baud_cnt + 16'b1;
        else 
            baud_cnt <= 16'd0; //�����ﵽһ�����������ں�����
    end    
    else
        baud_cnt <= 16'd0;     //���չ��̽���ʱ����������
end

//�Խ������ݼ�������rx_cnt�����и�ֵ
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rx_cnt <= 4'd0;
    else if(rx_flag) begin                  //���ڽ��չ���ʱrx_cnt�Ž��м���
        if(baud_cnt == BAUD_CNT_MAX - 16'b1) //�������ʼ�����������һ������������ʱ
            rx_cnt <= rx_cnt + 4'b1;        //�������ݼ�������1
        else
            rx_cnt <= rx_cnt;
    end
    else
        rx_cnt <= 4'd0;                     //���չ��̽���ʱ����������
end        

//����rx_cnt���Ĵ�rxd�˿ڵ�����
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rx_data_t <= 8'b0;
    else if(rx_flag) begin                            //ϵͳ���ڽ��չ���ʱ
        if(baud_cnt == BAUD_CNT_MAX/2 - 16'b1) begin  //�ж�baud_cnt�Ƿ����������λ���м�?
           case(rx_cnt)
               4'd1 : rx_data_t[0] <= uart_rxd_d2;    //�Ĵ����ݵ�����?
               4'd2 : rx_data_t[1] <= uart_rxd_d2;
               4'd3 : rx_data_t[2] <= uart_rxd_d2;
               4'd4 : rx_data_t[3] <= uart_rxd_d2;
               4'd5 : rx_data_t[4] <= uart_rxd_d2;
               4'd6 : rx_data_t[5] <= uart_rxd_d2;
               4'd7 : rx_data_t[6] <= uart_rxd_d2;
               4'd8 : rx_data_t[7] <= uart_rxd_d2;   //�Ĵ����ݵĸߵ�λ
               default : ;
            endcase  
        end
        else
            rx_data_t <= rx_data_t;
    end
    else
        rx_data_t <= 8'b0;
end        

//����������źźͽ��յ������ݸ��?
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        uart_rx_done <= 1'b0;
        uart_rx_data <= 8'b0;
    end
    //���������ݼ�����������ֹͣλ����baud_cnt������ֹͣλ���м�ʱ
    else if(rx_cnt == 4'd9 && baud_cnt == BAUD_CNT_MAX/2 - 16'b1) begin
        uart_rx_done <= 1'b1     ;  //���߽�������ź�?
        uart_rx_data <= rx_data_t;  //����UART���յ������ݽ��и�ֵ
    end    
    else begin
        uart_rx_done <= 1'b0;
        uart_rx_data <= uart_rx_data;
    end
end

endmodule