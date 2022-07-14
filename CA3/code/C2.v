`timescale 1ps/1ps
module C2 (
    D0,
    D1,
    D2,
    D3,
    A1,
    B1,
    A0,
    B0,
    out
);
    parameter size = 5;

    input [size-1:0]D0;
    input [size-1:0]D1;
    input [size-1:0]D2;
    input [size-1:0]D3;
    input A1, B1, A0, B0;
    output [size-1:0]out;

    wire [1:0]S;

    assign S[0] = A0 & B0;
    assign S[1] = A1 | B1;

    assign #2500 out = (S == 2'd0) ? D0: (S == 2'd1) ? D1: (S == 2'd2) ? D2: D3;

   
endmodule