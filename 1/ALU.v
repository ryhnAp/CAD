`timescale 1ns/1ns
module ALU (
    in1,
    in2,
    ALUop,
    iseq,
    res,
    sign
);
    parameter ZERO = 0;
    parameter ONE = 1;
    parameter size = 5;

    input [size-1:0]in1;
    input [size-1:0]in2;
    input ALUop, iseq;

    output reg [size:0]res;
    output sign;

    case (ALUop)
        ZERO: res = iseq ? (in2 - 5) : (in1 - 5);
        ONE:  res = iseq ? (in2 + 5) : (in1 + 5);
    endcase
    assign sign = res[size];

endmodule