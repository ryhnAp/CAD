`timescale 1ns/1ns
module Datapath (
    clk,
    rst,

    //colpar
    colparIJrster,
    lineKcp,
    linePKcp,
    newSlice,

    //permutation
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

    // col parity
    input colparIJrster; // reseter for i,j in col parity
    input [memsize-1:0] lineKcp; // line k is current slice of A[i,j,k] in col parity
    input [memsize-1:0] linePKcp; // line k-1 is previous slice of A[i,j,k] in col parity

    output [memsize-1:0]newSlice;
    // col parity

    // permutation
    input clk, rst, firstread;
    input IJen, ALUop, read, write, initLine, writeMemReg;
    input writeVal, IJregen, fbeq, fb3j, isArith, enable, update, waitCalNexti, ldTillPositive, ok;
    input [memsize-1:0]line;

    output [24:0]mem;
    output sign3j, signeq, done, sign, eq;
    // permutation

    // col parity ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    wire [2:0] cpI; // col parity i coordinate 
    wire [2:0] cpJ; // col parity j coordinate 
    wire [4:0] cpJmult4; // col parity 4*j coordinate for line 
    wire [4:0] cpJmult5; // col parity 5*j coordinate for line 
    wire [4:0] cpIdx; // col parity A array(which is A[i,j,k] and current slice) index in line 
    wire [2:0] cpInew; // col parity i coordinate for next element
    wire [2:0] cpJnew; // col parity j coordinate for next element
    wire [2:0] Jincreaser; // count 5 column then increase j to calculate next row
    wire [2:0] increasedJ; // count 5 column then increase j to calculate next row
    wire prevSlice, currSlice;


    Initer #(3) colparIiniter(.clk(clk), .rst(rst), .val(3'd0), .en(colparIJrster), .outreg(cpI));
    Initer #(3) colparJiniter(.clk(clk), .rst(rst), .val(3'd0), .en(colparIJrster), .outreg(cpJ));
    Initer #(3) colparJcounter(.clk(clk), .rst(rst), .val(3'd2), .en(colparIJrster), .outreg(Jincreaser)); // from 2 -> 7 co is one then we count five time

    Shifter #(5) colparMultiplyJ4(.data({2'b00, cpJ}), .coefficient({2'b01}), .shifted(cpJmult4));
    Adder #(5) colparMultiplyJ5(.i1({2'b00, cpJ}), .i2(cpJmult4), .a(cpJmult5));
    Adder #(5) colparIndexAdder(.i1(cpJmult5), .i2({2'b00, cpI}), .a(cpIdx));

    assign currSlice = (cpI == 3'd0) ? 1'b0 : lineKcp[5'd20+cpI-1'd1] ^ lineKcp[5'd15+cpI-1'd1] ^ lineKcp[5'd10+cpI-1'd1] ^ lineKcp[5'd5+cpI-1'd1] ^ lineKcp[cpI-1'd1];
    assign prevSlice = (cpI == 3'b100) ? 1'b0 : linePKcp[5'd20+cpI+1'd1] ^ linePKcp[5'd15+cpI+1'd1] ^ linePKcp[5'd10+cpI+1'd1] ^ linePKcp[5'd5+cpI+1'd1] ^ linePKcp[cpI+1'd1];

    assign newSlice[cpIdx] = lineKcp[cpIdx] ^ currSlice ^ prevSlice;

    Adder #(3) colparIndexAdder(.i1(Jincreaser), .i2(1'b1), .a(increasedJ));

    assign cpInew = (cpI == 3'd0) ? 3'd1: (cpI == 3'd1) ? 3'd2: 
        (cpI == 3'd2) ? 3'd3: (cpI == 3'd3) ? 3'd4:
        (cpI == 3'd4) ? 3'd0: 3'd0;
    
    assign cpJnew = &increasedJ ? ((cpJ == 3'b100) ? 3'd0 : cpJ + 1'b1) : cpJ;

    Register #(3) colparNewIReg(.clk(clk), .rst(rst), .ld(1'b1), .inputData(cpInew), 
        .outputData(cpI));
    Register #(3) colparNewJReg(.clk(clk), .rst(rst), .ld(1'b1), .inputData(cpJnew), 
        .outputData(cpJ));

    // end of col parity ~~~~~~~~~~~~~~~~~~~~~~~


    // permutation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
    
    // end of permutation ~~~~~~~~~~~~~~~~~~~~~~


endmodule