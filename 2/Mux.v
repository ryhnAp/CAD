`timescale 1ns/1ns
module Mux (
    i1,
    i2,
    sel,
    out
);

    parameter size = 5;

    input [size-1:0]i1;
    input [size-1:0]i2;
    input sel;

    output [size:0]out;

    assign out = (sel == 1'b0) ? i1 : i2;

endmodule