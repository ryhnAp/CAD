`timescale 1ns/1ns
module Subtractor (
    i1,
    i2,
    en,
    out
);

    parameter size = 5;

    input en;
    input [size-1:0]i1;
    input [size-1:0]i2;

    output [size:0]out;

    assign out = (en == 1'b1) ? i1 - i2 : out;

endmodule