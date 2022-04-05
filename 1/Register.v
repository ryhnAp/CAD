`timescale 1ns/1ns
module Register (
    clk,
    rst,
    ld,
    inputData,
    inputData_,
    outputData,
    outputData_
);
    parameter size = 2;

    input clk, rst;
    input ld;
    input [size-1:0]inputData_;
    input inputData;

    output reg [size-1:0]outputData_;
    output reg outputData;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            outputData = 1'b0;
            outputData_ = {size{1'b0}};
        end

        else if (ld) begin
            outputData = inputData;
            outputData_ = inputData_;
        end
        
    end

endmodule