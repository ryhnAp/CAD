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
    input [size-1:0]inputData;
    input inputData_;

    output reg [size-1:0]outputData;
    output reg outputData_;

    always @(posedge clk, posedge rst) begin
        if(rst)
        {
            outputData_ = 1'b0;
            outputData = {size{1'b0}};
        }
        else if (ld)
        {
            outputData_ = inputData_;
            outputData = inputData;
        }
    end

endmodule