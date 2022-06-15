`timescale 1ns/1ns
module C2 (
    D00,
    D01,
    D10,
    D11,
    A1,
    B1,
    A0,
    B0,
    out
);
    parameter size = 5;

    input [size-1:0]D00;
    input [size-1:0]D01;
    input [size-1:0]D10;
    input [size-1:0]D11;
    input A1, B1, A0, B0;
    output [size-1:0]out;

    wire [1:0]S;

    assign S[0] = A0&B0;
    assign S[1] = A1|B1;

    assign out = S == 2'd0 ? D00 : 
                (S == 2'd1 ? D01 :
                (S == 2'd2 ? D10 : D11 ));

   
endmodule