`timescale 1ps/1ps
module Shifter (
    data,
    coefficient,
    shifted
);
    parameter size = 5;

    input [size-1:0]data;
    input [1:0]coefficient;

    output reg [size-1:0]shifted;

    parameter [1:0] 
        LEFT2 = 2'b00,
        LEFT4 = 2'b01,
        RIGHT = 2'b10;

    always @(*) begin
        case (coefficient)
            LEFT2: shifted = data << 1'b1;
            LEFT4: shifted = data << 2'b10;
            RIGHT: shifted = data >> 1'b1;
        endcase
    end

endmodule