`timescale 1ps/1ps
module S1 (
    D0,
    D1,
    D2,
    D3,
    A1,
    B1,
    A0,
    CLR,
    clk,
    out
);
    parameter size = 5;

    input clk;
    input [size-1:0]D0;
    input [size-1:0]D1;
    input [size-1:0]D2;
    input [size-1:0]D3;
    input A1, B1, A0, CLR;

    output reg [size - 1:0] out;

    wire [size-1:0]C2out;

    C2 C2_MUT(D0,D1,D2,D3,A1,B1,A0,CLR,C2out);

    always @(posedge clk, posedge CLR, C2out) begin
        if(CLR) begin
            out = {size{1'b0}};
        end
        else begin
            out = C2out;
        end
        
    end
    
endmodule