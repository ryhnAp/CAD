`timescale 1ns/1ns
module TB ();
    
    reg clk=1'b0, rst=1'b1;
    wire IJen, ALUop, read, write, initLine;
    wire writeVal, IJregen, fbeq, fb3j, isArith, enable, update;
    wire [size-1:0]val;
    wire [memsize-1:0]line;

    wire sign3j, signeq, done, sign, eq;

    Controller c(
    clk,
    rst,
    start,

    sign3j,
    signeq,
    done,
    sign,
    eq,
    
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
    update);

    Datapath dp(
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
    update,

    sign3j,
    signeq,
    done,
    sign,
    eq);



endmodule