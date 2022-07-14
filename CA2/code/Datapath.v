`timescale 1ns/1ns
module Datapath (
    clk,
    rst,

    //colpar
    colparIJrster,
    lineKcp,
    newSlice,
    colparDone,
    ld_ij_par,
    ld_prev,

    //rotate
    lane,
    newLane,
    finishLane,
    laneid,
    initRotate,
    en_rotate, 
    
    //permutation
    firstread, 
    IJen, 
    ALUop, 
    read, 
    write, 
    initLine, 
    writeMemReg,
    writeVal, 
    IJregen, 
    fbeq, 
    fb3j, 
    isArith, 
    enable, 
    update, 
    waitCalNexti, 
    ldTillPositive, 
    ok, 
    line,
    mem,
    sign3j,
    signeq, 
    done, 
    sign, 
    eq

    
);

    parameter size = 5;
    parameter memsize = 25;
    parameter initValIJ = 3;
    
    input firstread;
    input IJen, ALUop, read, write, initLine, writeMemReg;
    input writeVal, IJregen, fbeq, fb3j, isArith, enable, update, waitCalNexti, ldTillPositive, ok;
    input [memsize-1:0]line;

    output [24:0]mem;
    output sign3j, signeq, done, sign, eq;


    input colparIJrster, ld_ij_par, clk, rst, initRotate, en_rotate;
    input [memsize-1:0] lineKcp, ld_prev;

    output [memsize-1:0] newSlice;
    output colparDone;

    input [63:0] lane;
    output [63:0] newLane;
    output finishLane;
    input [4:0] laneid;



    ColParModule ins_col_par(.clk(clk), .rst(rst), .colparIJrster(colparIJrster), 
        .lineKcp(lineKcp), .newSlice(newSlice), .colparDone(colparDone), .ld_ij_par(ld_ij_par),
        .ld_prev(ld_prev));
    
    RotateModule ins_rotate_module(.clk(clk), .rst(rst), .laneid(laneid), .lane(lane),
    .newLane(newLane), .finishLane(finishLane), .en_rotate(en_rotate), .initRotate(initRotate));

    EncoderModule encoder_module(clk, rst, firstread, IJen, ALUop, read, write, initLine, writeMemReg,
    writeVal, IJregen, fbeq, fb3j, isArith, enable, update, waitCalNexti, ldTillPositive, ok, line);


endmodule