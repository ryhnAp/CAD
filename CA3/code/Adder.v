`timescale 1ps/1ps
module Adder (
    i1,
    i2,
    a
);
    parameter size = 5;

    input [size-1:0]i1;
    input [size-1:0]i2;

    output [size:0]a;

    assign a = i1 + i2;

endmodule
