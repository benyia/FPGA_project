`timescale 1ns / 1ps

module tb_half_adder();

reg             in1     ;
reg             in2     ;

wire            sum     ;
wire            count   ;


initial begin
    in1 <= 1'b0;
    in2 <= 1'b0;
end
always #10 in1={$random}%2;
always #10 in2={$random}%2;

initial begin
    $timeformat(-9, 1, " ns", 6);
    $monitor("At time %t: in1 = %b, in2 = %b => sum = %b, count = %b", $time, in1, in2, sum, count);
end

half_adder half_adder_inst (
    .in1     (in1),
    .in2     (in2),
    .sum     (sum),
    .count   (count)
);



endmodule
