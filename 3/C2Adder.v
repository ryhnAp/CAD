`timescale 1ns/1ns
module C2Adder (
    i1,
    i2,
    o
);
    parameter size = 5;
    
    input [size-1:0]i1;
    input [size-1:0]i2;
    output [size-1:0]o;
    
    wire [size:0]sum;
    wire [size:0]carry;
    
    assign sum[0] = 1'b0;
    assign carry[0] = 1'b0;
    
    genvar k;
    generate
        for(k=0;k<8;k=k+2)
                begin
                C2 #(2) oneBitAdder(.D00({i1[k],carry[k]}),.D01({i1[k],carry[k]}),.D10(2'b01),.D11(2'b10),.A1(i1[k]),.B1(i2[k]),.A0(carry[k]),.B0(carry[k]),.out({carry[k+1],sum[k]}));
                end
    endgenerate
    
    assign o = sum;

endmodule

