`timescale 1ns/1ns
module  my_register(
    clk,
    rst,
    ld,
    inputData,
    outputData,
);

    parameter size = 3;

    input clk, rst;
    input ld;
    input [size-1:0]inputData;

    output reg [size - 1:0] outputData;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            outputData = {size{1'b0}};
        end

        else if (ld) begin
            outputData = inputData;
        end
        
    end

endmodule