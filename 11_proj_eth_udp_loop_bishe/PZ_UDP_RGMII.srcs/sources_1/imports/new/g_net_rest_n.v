`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/16 17:11:23
// Design Name: 
// Module Name: g_net_rest_n
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module g_net_rest_n(
    input clk,
    input sysrstn,
    output reg net_rst_n,
    output net_rst_p
    );

assign net_rst_p = ~net_rst_n;
//PHY复位
reg [31:0]net_rst_cnt;
always @(posedge clk or negedge sysrstn) begin
    if(!sysrstn) begin
        net_rst_cnt<=0;
    end
    else if(net_rst_cnt<250000) begin
        net_rst_cnt<=net_rst_cnt+1;
    end
    else  begin
        net_rst_cnt<= net_rst_cnt;
    end  
end

always @(posedge clk or negedge sysrstn) begin
    if(!sysrstn) begin
        net_rst_n<=0;
    end
    else if(net_rst_cnt>249999) begin
        net_rst_n<=1;
    end
    else  begin
        net_rst_n<=0;
    end  
end 

endmodule
