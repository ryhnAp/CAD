`timescale 1ps/1ps
module C1 (
    A0,
    A1,
    SA,
    B0,
    B1,
    SB,
    S0,
    S1,
    F
);
    parameter size = 5;

    input [size-1:0]A0;
    input [size-1:0]A1;
    input [size-1:0]B0;
    input [size-1:0]B1;
    input SA, SB, S0, S1;
    output [size-1:0]F;

    wire [size-1:0]F1;
    wire [size-1:0]F2;
    wire S2;

    assign F1 = SA ? A1 : A0;
    assign F2 = SB ? B1 : B0;
    assign S2 = S0 | S1;

    assign #2000 F = S2 ? F2 : F1;

   
endmodule