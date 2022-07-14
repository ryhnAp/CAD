`timescale 1ps/1ps
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
    mem,
    firstread,
    ok
);
    parameter size = 5;
    parameter memsize = 25;

    input clk, rst, ok;
    input init;
    input [size-1:0]index;
    wire [size-1:0]ind_new;
    input [memsize-1:0]line;
    input val;
    input write, read, firstread;

    output out;

    assign ind_new = ~index + (5'b11000) + 1;

    reg [memsize-1:0]mem2;
    output reg [memsize-1:0]mem;

    always @(posedge clk, posedge rst) begin
        if(write)
            mem2[ind_new] <= out;

        if(init)
            mem2 = line;
    end
    
    assign out = (firstread == 1'b1) ? line[ind_new] : (read == 1'b0) ? out: (ind_new == 5'b11000) ? val: mem2[ind_new];
    assign mem = ok  ? mem2: mem;
endmodule