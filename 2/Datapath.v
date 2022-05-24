`timescale 1ns/1ns
module Datapath (
    clk,
    rst,

    //colpar
    colparIJrster,
    lineKcp,
    linePKcp,
    newSlice,
    colparDone,

    //rotate 
    sliceIdx,
    initRotate,
    lane,
    finishLane,
    newLane,

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
    ok,

    //reval
    initReval,
    slice,
    newSlice,

    //addRC
    A00,
    initARC,
    A00out

);
    parameter size = 5;
    parameter memsize = 25;
    parameter initValIJ = 3;

    // col parity
    input colparIJrster; // reseter for i,j in col parity
    input [memsize-1:0] lineKcp; // line k is current slice of A[i,j,k] in col parity
    input [memsize-1:0] linePKcp; // line k-1 is previous slice of A[i,j,k] in col parity

    output [memsize-1:0]newSlice;
    output colparDone;
    // col parity

    // rotate
    input [4:0] sliceIdx; // index in slice which represent what lane we are 
    input initRotate;
    input [63:0] lane;

    output finishLane;
    output [63:0] newLane; // setting new values
    // rotate

    // permutation
    input clk, rst, firstread;
    input IJen, ALUop, read, write, initLine, writeMemReg;
    input writeVal, IJregen, fbeq, fb3j, isArith, enable, update, waitCalNexti, ldTillPositive, ok;
    input [memsize-1:0]line;

    output [24:0]mem;
    output sign3j, signeq, done, sign, eq;
    // permutation

    // revaluate
    input initReval;
    input [24:0] slice;

    output [24:0] newSlice;
    // revaluate

    // add RC
    input [63:0] A00; // A[0,0]
    input initARC;

    output [63:0] A00out;
    // add RC

    // col parity ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    wire [2:0] cpI; // col parity i coordinate 
    wire [2:0] cpJ; // col parity j coordinate 
    wire [2:0] cpI_input; // col parity i coordinate 
    wire [2:0] cpJ_input; // col parity j coordinate 
    wire [4:0] cpJmult4; // col parity 4*j coordinate for line 
    wire [4:0] cpJmult5; // col parity 5*j coordinate for line 
    wire [4:0] cpIdx; // col parity A array(which is A[i,j,k] and current slice) index in line 
    wire [2:0] cpInew; // col parity i coordinate for next element
    wire [2:0] cpJnew; // col parity j coordinate for next element
    wire [2:0] Jincreaser; // count 5 column then increase j to calculate next row
    wire [2:0] increasedJ; // count 5 column then increase j to calculate next row
    wire prevSlice, currSlice;

    assign cpI_input = colparIJrster ? 3'd0 : cpInew;
    assign cpJ_input = colparIJrster ? 3'd0 : cpJnew;
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

    // Register #(3) colparNewIReg(.clk(clk), .rst(rst), .ld(1'b1), .inputData(cpInew), 
    //     .outputData(cpI));
    // Register #(3) colparNewJReg(.clk(clk), .rst(rst), .ld(1'b1), .inputData(cpJnew), 
    //     .outputData(cpJ));

    assign colparDone = (cpIdx == 5'd64);

    // end of col parity ~~~~~~~~~~~~~~~~~~~~~~~

    // rotate ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    reg [23:0] tTable [5:0] = {6'd1, 6'd3, 6'd6, 6'd10, 6'd15, 6'd21, 6'd28, 6'd36, 6'd45, 6'd55, 6'd2, 6'd14, 6'd27, 6'd41, 6'd56, 6'd8, 6'd25, 6'd43, 6'd62, 6'd18, 6'd39, 6'd61, 6'd20, 6'd44};
    wire [6:0] zCounter; // z dimention counter
    wire [6:0] zCounterInput; // z dimention counter
    wire [6:0] zCal; // z dimention calculation
    wire [6:0] zMod; // z - tTable is negative or more than 63 then remode


    assign zCounterInput = initRotate ? 7'd0 : zCounter + 7'd1;
    Register #(7) ZCounterInReg(.clk(clk), .rst(rst), .ld(initRotate), .inputData(zCounterInput), 
        .outputData(zCounter));

    assign zCal = zCounter - tTable[sliceIdx]; 
    assign zMod = zCal ? zCal + 7'd64 : zCal;
    assign newLane[zCounter] = (sliceIdx == 5'd0) ? lane[zCounter] : lane[zMod];
    assign finishLane = zCounter == 7'd64;

    // end of rotate ~~~~~~~~~~~~~~~~~~~~~~~~~~~

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


    // revaluate ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    wire [2:0] xR; // x for reval func
    wire [2:0] yR; // y for reval func
    wire [2:0] xp2; // x+2 value for reval func
    wire [2:0] xp1; // x+1 value for reval func
    wire [2:0] xR_input; // x for reval func
    wire [2:0] yR_input; // y for reval func
    

    assign xR_input = initReval ? 3'd0 : (xR == 3'd4 ? 3'd0  : xR + 1);
    assign yR_input = initReval ? 3'd0 : (xR == 3'd4 ? yR+3'd1  : yR);

    Register #(3) XRegister(.clk(clk), .rst(rst), .ld(initReval),
        .inputData(xR_input), .outputData(xR));
    Register #(3) YRegister(.clk(clk), .rst(rst), .ld(initReval),
        .inputData(yR_input), .outputData(yR));

    assign xp2 = xR == 3'd3 ? 3'd0 : (xR == 3'd4 ? 3'd0 : xR + 3'd2); 
    assign xp1 = xR == 3'd4 ? 3'd0 : xR + 3'd1; 

    assign newSlice[5*xR + yR] = slice[5*xR + yR] ^ ((~slice[5*xp1 + yR]) & slice[5*xp2 + yR]) 

    // end of revaluate ~~~~~~~~~~~~~~~~~~~~~~~~

    // addRC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    wire [4:0] roundIdx;
    wire [4:0] roundIdx_input;

    assign roundIdx_input = initARC ? 5'd0 : roundIdx + 5'd1 ;

    Register #(5) ARCRegister(.clk(clk), .rst(rst), .ld(initARC),
        .inputData(roundIdx_input), .outputData(roundIdx));

    reg [23:0] round [63:0] = {
            16'x0000000000000001, 16'x000000008000808B,
            16'x0000000000008082, 16'x800000000000008B,
            16'x800000000000808A, 16'x8000000000008089,
            16'x8000000080008000, 16'x8000000000008003,
            16'x000000000000808B, 16'x8000000000008002,
            16'x0000000080000001, 16'x8000000000000080,
            16'x8000000080008081, 16'x000000000000800A,
            16'x8000000000008009, 16'x800000008000000A,
            16'x000000000000008A, 16'x8000000080008081,
            16'x0000000000000088, 16'x8000000000008080,
            16'x0000000080008009, 16'x0000000080000001,
            16'x000000008000000A, 16'x8000000080008008};

    assign A00out = A00 ^ round[roundIdx];
    

    // end of addRC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

endmodule