`timescale 1ns / 1ps

module tb_full_adder();

reg             in1     ;
reg             in2     ;
reg             cin     ;

wire            sum     ;
wire            cout   ;


initial begin
    in1 <= 1'b0;
    in2 <= 1'b0;
    cin <= 1'b0;
    
end
always #10 in1={$random}%2;
always #10 in2={$random}%2;
always #10 cin={$random}%2;
initial begin
    $timeformat(-9, 1, " ns", 6);
    $monitor("At time %t: in1 = %b, in2 = %b, cin = %b => sum = %b, cout = %b", $time, in1, in2, cin, sum, cout);
end

full_adder full_adder_inst (
    .in1     (in1),
    .in2     (in2),
    .cin     (cin),

    .sum     (sum),
    .cout   (cout)
);



endmodule
