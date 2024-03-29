`timescale 1ps/1ps
module FDatapath ( // fpga implement of datapath
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
    wire [2:0]iRegSaved;
    wire [2:0]jReg;
    wire [2:0]jRegSaved;
    wire [4:0]iMult5;
    wire [4:0]memIdx;
    wire [4:0]iMult2;
    wire [4:0]iMult3;
    wire [4:0]lastIndex;
    wire [4:0]lastIndexSaved;
    wire [4:0]iNextMult2;
    wire [4:0]iNextPos;
    wire [4:0]iNextPosSaved;
    wire [4:0]iNextPosAdd5;
    wire [2:0]iAtLast;
    wire [2:0]convertedI;
    wire [2:0]convertedJ;
    wire [4:0]memIdxOut;
    wire [4:0]memIdxOutSaved;
    wire [4:0]memInp;


    wire newVal;
    wire regVal;
    wire regValSaved;

    C2 #(3) newI(.D0({1'b0, 1'b1, jReg[0]}),.D1({3'b0}),.D2({~jReg[0], 1'b0, 1'b0}),.D3({3'b001}),.A1(jReg[2]),.B1(jReg[1]),.A0(~jReg[0]),.B0(jReg[2]),.out(convertedI));
    C2 #(3) newJ(.D0({1'b0, 1'b1, iReg[0]}),.D1({3'b0}),.D2({~iReg[0], 1'b0, 1'b0}),.D3({3'b001}),.A1(iReg[2]),.B1(iReg[1]),.A0(~iReg[0]),.B0(iReg[2]),.out(convertedJ));

    C2Adder #(5) multiplyI5(.i1({2'b00, convertedI}), .i2({convertedI, 2'b00}), .o(iMult5));
    C2Adder #(5) indexAdder(.i1(iMult5), .i2({2'b00, convertedJ}), .o(memIdx));

    assign memIdxOutSaved = memIdxOut;
    S2 #(5) indexMemReg(.D0(5'b0),.D1(5'b0),.D2(memIdxOutSaved),.D3(memIdx),.A1(1'b1),.B1(1'b1),.A0(writeMemReg),.B0(writeMemReg),.CLR(rst),.clk(clk),.out(memIdxOut));

    assign memInp = write ? memIdxOut: memIdx;

    MemoryBlock #(5,25) MB(.clk(clk), .rst(rst), .init(initLine), .line(line),
        .index(memInp), .val(regVal), .write(write), .read(read), .out(newVal), .mem(mem), .firstread(firstread), .ok(ok));

    assign regValSaved = regVal;
    S2 #(1) valRegister(.D0(5'b0),.D1(5'b0),.D2(regValSaved),.D3(newVal),.A1(1'b1),.B1(1'b1),.A0(writeVal),.B0(writeVal),.CLR(rst),.clk(clk),.out(regVal));

    assign jRegSaved = jReg;
    S2 #(5) JRegister(.D0(5'b0),.D1(5'b0),.D2(jRegSaved),.D3(j),.A1(1'b1),.B1(1'b1),.A0(IJregen),.B0(IJregen),.CLR(rst),.clk(clk),.out(jReg));

    C2Adder #(5) multiplyI3(.i1({1'b0, iReg, 1'b0}), .i2({2'b00, iReg}), .o(iMult3));

    assign iNextPosSaved = iNextPos;
    S2 #(5) regTillPositive(.D0(5'd0),.D1(5'd0),.D2(iNextPosSaved),.D3(iNextPosAdd5),.A1(1'b1),.B1(1'b1),.A0(ldTillPositive),.B0(ldTillPositive),.CLR(rst),.clk(clk),.out(iNextPos));

    assign sign = iNextPosAdd5[4];

    assign iNextPosAdd5 = (waitCalNexti) ? (iNextPos + 5'b00101): iNextMult2;

    assign lastIndexSaved = lastIndex;
    S2 #(5) registerLastIndex(.D0(5'b0),.D1(5'b0),.D2(lastIndexSaved),.D3(memIdx),.A1(1'b1),.B1(1'b1),.A0(ld_index),.B0(ld_index),.CLR(rst),.clk(clk),.out(lastIndex));

    assign iRegSaved = iReg;
    S2 #(3) IRegister(.D0(3'b0),.D1(3'b0),.D2(iRegSaved),.D3(i),.A1(1'b1),.B1(1'b1),.A0(IJregen),.B0(IJregen),.CLR(rst),.clk(clk),.out(iReg));
    
    assign iAtLast = (iNextPos == 5'b00000) ? 3'b000: (iNextPos == 5'b00001) ? 
        3'b011: (iNextPos == 5'b00010) ? 3'b001: (iNextPos == 5'b00011) ? 3'b100:
        3'b010;

    C2Adder #(5) twiceNextI(.i1({2'b00, jReg}), .i2(~iMult3 + 1), .o(iNextMult2));

    assign i = IJen ? 3'b011: update ? iAtLast : i;
    assign j = IJen ? 3'b011: update ? iReg : j;

    assign done = iReg[0] & iReg[1] & jReg[0] & jReg[1];
    
endmodule