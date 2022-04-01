`timescale 1ns/1ns
module IJMux (
    select,
    out
);
    parameter size = 3;
    input [size-1:0]select;
    output reg [size-1:0]out;
    
    parameter [size-1:0] 
        ZERO = 3'b000,
        ONE = 3'b001,
        TWO = 3'b010,
        THREE = 3'b011,
        FOUR = 3'b100;

    case (select)
        ZERO:  out = TWO;
        ONE:   out = THREE;
        TWO:   out = FOUR;
        THREE: out = ZERO;
        FOUR:  out = ONE;
        default: 
    endcase


endmodule