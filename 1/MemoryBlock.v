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
    out, 
    mem
);
    parameter size = 5;
    parameter memsize = 25;

    input clk, rst;
    input init;
    input [size-1:0]index;
    wire [size-1:0]ind_new;
    input [memsize-1:0]line;
    input val;
    input write, read;

    output out;

    assign ind_new = ~index + (5'b11000) + 1;

    output reg [memsize-1:0]mem;

    always @(posedge clk, posedge rst) begin
        if(write)
            mem[ind_new] <= (ind_new == 5'b01010) ? val: out;

        if(init)
            mem = line;
    end
    
    assign out = (read == 1'b1) ? mem[ind_new] : out;

endmodule