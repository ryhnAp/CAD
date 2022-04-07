`timescale 1ns/1ns
module MemoryBlock (
    clk,
    rst,
    init,
    line,
    index, 
    val, 
    write, 
    read,
    out
);
    parameter size = 5;
    parameter memsize = 25;

    input clk, rst;
    input init;
    input [size-1:0]index;
    input [memsize-1:0]line;
    input val;
    input write, read;

    output out;

    reg [memsize-1:0]mem;

    always @(posedge clk, posedge rst) begin
        if(write)
            mem[24 - index] <= val;

        if(init)
            mem = line;
    end
    
    assign out = (read == 1'b1) ? mem[24 - index] : out;

endmodule