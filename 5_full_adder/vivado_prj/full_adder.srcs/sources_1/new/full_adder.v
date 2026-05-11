`timescale 1ns / 1ps

module full_adder(


    input       wire       in1,
    input       wire       in2,
    input       wire       cin,

    output      wire       sum,
    output      wire       cout

    );

wire        sum0    ;
wire        cout0   ;
wire        cout1   ;

assign cout = (cout0 | cout1);
half_adder half_adder0 
(
    .in1     (in1),
    .in2     (in2),
    .sum     (sum0),
    .count   (cout0)
);


half_adder half_adder1 
(
    .in1     (sum0),
    .in2     (cin),
    .sum     (sum),
    .count   (cout1)
);


endmodule
