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
    parameter memSize = 25;

    input clk, rst;
    input init;
    input [size-1:0]index;
    input [memsize-1:0]line;
    input val;
    input write, read;

    output out;

    reg [memSize-1:0]mem;

    always @(posedge clk, posedge rst) begin
        if(write)
            mem[index] <= val;

        if(init)
            mem = line;
    end
    
    assign out = (read == 1'b1) ? mem[index] : out;

endmodule