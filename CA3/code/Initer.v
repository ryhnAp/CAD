`timescale 1ps/1ps
module Initer (
    clk,
    rst,
    val,
    en,
    outreg
);
    parameter size = 3;
    
    input clk, rst;
    input en;
    input [size-1:0]val;

    output reg [size-1:0]outreg;

    always @(posedge clk, posedge rst) begin
        if(rst)
            outreg = {size{1'b0}};
        
        else if (en)
            outreg = val;
    end

endmodule