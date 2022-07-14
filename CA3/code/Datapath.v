`timescale 1ps/1ps
module Datapath (
    clk,
    rst,
    IJen,
    ALUop,
    read,
    write,
    initLine,
    line,
    writeVal,
    IJregen,
    fb3j,
    fbeq,
    isArith,
    enable,
    waitCalNexti,
    writeMemReg,
    ldTillPositive,
    update,//enable for updating i,j after being checked and update "i"  

    sign3j,
    signeq,
    done,
    sign,
    eq, 
    mem,
    firstread,
    ok
);
    parameter size = 5;
    parameter memsize = 25;

    parameter initValIJ = 3;

    input clk, rst, firstread;
    input IJen, ALUop, read, write, initLine, writeMemReg;
    input writeVal, IJregen, fbeq, fb3j, isArith, enable, update, waitCalNexti, ldTillPositive, ok;
    input [memsize-1:0]line;
    output [24:0]mem;

    output sign3j, signeq, done, sign, eq;

    wire [2:0]i;
    wire [2:0]j;
    wire [4:0]iMult4;
    wire [2:0]iReg;
    wire [2:0]jReg;
    wire [4:0]iMult5;
    wire [4:0]memIdx;
    wire [4:0]iMult2;
    wire [4:0]iMult3;
    wire [4:0]lastIndex;
    wire [4:0]iNextMult2;
    wire [4:0]iNextPos;
    wire [4:0]iNextPosAdd5;
    wire [2:0]iAtLast;
    wire [2:0]convertedI;
    wire [2:0]convertedJ;
    wire [4:0]memIdxOut;
    wire [4:0]memInp;


    wire newVal;
    wire regVal;

    IJMux newI(jReg, convertedI);
    IJMux newJ(iReg, convertedJ);

    Shifter #(5) multiplyI4(.data({2'b00, convertedI}), .coefficient({2'b01}), .shifted(iMult4));

    Adder #(5) multiplyI5(.i1({2'b00, convertedI}), .i2(iMult4), .a(iMult5));

    Adder #(5) indexAdder(.i1(iMult5), .i2({2'b00, convertedJ}), .a(memIdx));

    Register #(5) indexMemReg(.clk(clk), .rst(rst), .ld(writeMemReg), .inputData(memIdx), 
        .outputData(memIdxOut));

    assign memInp = write ? memIdxOut: memIdx;

    MemoryBlock #(5,25) MB(.clk(clk), .rst(rst), .init(initLine), .line(line),
        .index(memInp), .val(regVal), .write(write), .read(read), .out(newVal), .mem(mem), .firstread(firstread), .ok(ok));

    Register #(1) valRegister(.clk(clk), .rst(rst), .ld(writeVal), .inputData(newVal), 
        .outputData(regVal));

    Register #(3) JRegister(.clk(clk), .rst(rst), .ld(IJregen), 
        .inputData(j), .outputData(jReg));

    Shifter #(5) multiplyI2(.data({2'b00, iReg}), .coefficient({2'b00}), .shifted(iMult2));

    Adder #(5) multiplyI3(.i1(iMult2), .i2({2'b00, iReg}), .a(iMult3));

    Register  #(5) regTillPositive(.clk(clk), .rst(rst), .ld(ldTillPositive), 
        .inputData(iNextPosAdd5), .outputData(iNextPos));

    assign sign = iNextPosAdd5[4];

    assign iNextPosAdd5 = (waitCalNexti) ? (iNextPos + 5'b00101): iNextMult2;

    Register #(5) registerLastIndex(.clk(clk), .rst(rst), .ld(ld_index), .inputData(memIdx), .outputData(lastIndex));

    Register #(3) IRegister(.clk(clk), .rst(rst), .ld(IJregen),
        .inputData(i), .outputData(iReg));
    
    assign iAtLast = (iNextPos == 5'b00000) ? 3'b000: (iNextPos == 5'b00001) ? 
        3'b011: (iNextPos == 5'b00010) ? 3'b001: (iNextPos == 5'b00011) ? 3'b100:
        3'b010;

    Subtractor #(5) twiceNextI(.i1({2'b00, jReg}), .i2(iMult3), .en(isArith), .out(iNextMult2));

    assign i = IJen ? 3'b011: update ? iAtLast : i;
    assign j = IJen ? 3'b011: update ? iReg : j;

    assign done = iReg[0] & iReg[1] & jReg[0] & jReg[1];
    
endmodule