`timescale 1ns/1ns
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
    update,//enable for updating i,j after being checked and update "i"  

    sign3j,
    signeq,
    done,
    sign,
    eq
);
    parameter size = 5;
    parameter memsize = 25;

    parameter initValIJ = 3;

    input clk, rst;
    input IJen, ALUop, read, write, initLine;
    input writeVal, IJregen, fbeq, fb3j, isArith, enable, update;
    input [memsize-1:0]line;

    output sign3j, signeq, done, sign, eq;

    wire [size-3:0]i;
    wire [size-3:0]j;
    wire [size-3:0]iReg;
    wire [size-3:0]jReg;
    wire [size-3:0]iIdx;
    wire [size-3:0]jIdx;
    wire [size-1:0]ii;
    wire [size-1:0]iii;
    wire [size-1:0]memIdx;
    wire [size-1:0]jj;
    wire [size-1:0]jjReg;
    wire [size-1:0]jjRegDec;
    wire [size-1:0]ALUout;
    wire [size-1:0]subOut;
    wire [size-1:0]subDec;
    wire [size-1:0]shiftOut;
    wire [size-1:0]mux3j;
    wire [size-1:0]muxi;

    wire [size-1:0]o1;
    wire [size-1:0]o2;
    wire [size-1:0]o3;
    wire [size-1:0]o4;

    wire temp1;
    wire temp2;
    wire temp3;

    // wire val;
    wire sign;
    wire newVal;
    wire regVal;

    Initer #(3) Iiniter(.clk(clk), .rst(rst), .val(initValIJ),
        .en(IJen), .outreg(i));
    Initer #(3) Jiniter(.clk(clk), .rst(rst), .val(initValIJ),
        .en(IJen), .outreg(j));
    
    IJMux #(3) IMUXconverter(.select(i),.out(iIdx));
    IJMux #(3) JMUXconverter(.select(j),.out(jIdx));

    Shifter #(5) iIdxShifter(.data({2'b00, iIdx}), .coefficient({2'b01}), .shifted(ii));

    Adder #(5) row5Coeff(.i1({2'b00, iIdx}), .i2(ii), .a(iii));

    Adder #(5) indexAdder(.i1(iii), .i2({2'b00, jIdx}), .a(memIdx));

    MemoryBlock #(5,25) MB(.clk(clk), .rst(rst), .init(initLine), .line(line),
        .index(memIdx), .val(regVal), .write(write), .read(read), .out(newVal));

    Register valRegister(.clk(clk), .rst(rst), .ld(writeVal), .inputData(newVal), 
        .inputData_(2'b00), .outputData(regVal), .outputData_(temp1));

    Register newJRegister(.clk(clk), .rst(rst), .ld(IJregen), .inputData(i), 
        .inputData_(2'b00), .outputData(jReg), .outputData_(temp2));

    Shifter #(5) jIdxShifter(.data({2'b00, jReg}), .coefficient({2'b00}), .shifted(jj));

    Adder #(5) jRegAdder(.i1(jj), .i2({2'b00, jReg}), .a(jjReg));

    Adder #(5) jRegDec5Adder(.i1(jjReg), .i2({5'b11011}), .a({sign3j, jjRegDec})); // decrease 5 for sign j reg part

    Mux #(5) Jfeedback(.i1(jjRegDec), .i2(ALUout), .sel(fb3j), .out(mux3j));

    ALU alu(.in1(mux3j), .in2(muxi), .ALUop(ALUop), 
        .iseq(isArith|fbeq), .res(ALUout), .sign(sign));

    Register newIRegister(.clk(clk), .rst(rst), .ld(IJregen), .inputData(shiftOut), 
        .inputData_(2'b00), .outputData(iReg), .outputData_(temp3));

    Subtractor #(5) iRegAdder(.i1(j), .i2(ALUout), .en(isArith), .out(subOut));

    Subtractor #(5) iRegDec5Adder(.i1(subOut), .i2(5'd5), .en(isArith), .out({signeq, subDec}));

    Mux #(5) Ifeedback(.i1(subDec), .i2(ALUout), .sel(fbeq), .out(muxi));

    Multiplexer #(5) ALUMUX(.res(ALUout), .enable(enable),
        .o1(o1), .o2(o2), .o3(o3), .o4(o4));

    assign eq = o1 | o2;

    Shifter #(5) rightShifter(.data(o4), .coefficient(2'b10), .shifted(shiftOut));

    assign done = (shiftOut[0]&jReg[0])&(shiftOut[1]&jReg[1]); 

    assign i = update ? shiftOut : i;
    assign j = update ? jReg : j;
    
endmodule