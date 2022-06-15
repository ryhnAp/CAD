`timescale 1ns/1ns
module C2Adder (
    i1,
    i2,
    o
);
    parameter size = 5;
    
    input [size-1:0]i1;
    input [size-1:0]i2;
    output [size:0]o;
    
    wire [size-1:0]sum;
    wire [size:0]carry;
    
    assign carry[0] = 1'b0;
    
    genvar k;
    generate
        for(k=0;k<5;k=k+1)
                begin
                C2 #(2) oneBitAdder(.D0({i1[k],carry[k]}),.D1({i1[k],carry[k]}),.D2(2'b01),.D3(2'b10),.A1(i1[k]),.B1(i2[k]),.A0(carry[k]),.B0(carry[k]),.out({carry[k+1],sum[k]}));
                end
    endgenerate
    
    assign o = {carry[size], sum};

endmodule

