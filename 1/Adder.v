`timescale 1ns/1ns
module Adder (
    i1,
    i2,
    a
);
    parameter size = 5;

    input [size-1:0]i1;
    input [size-1:0]i2;

    output [size:0]o;

    assign o = i1 + i2;

endmodule