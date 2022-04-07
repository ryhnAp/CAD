`timescale 1ns/1ns
`define EOF 32'hFFFF_FFFF 

module TB ();
    
    reg [24:0] Mem [0:63];

    initial $readmemb("input_0.txt",Mem);

    reg clk=1'b0, rst=1'b1;
    wire IJen, ALUop, read, write, initLine, waitCalNexti;
    wire writeVal, IJregen, fbeq, fb3j, isArith, enable, update, writeMemReg, ldTillPositive;
    wire [4:0]val;
    reg [24:0]line;
    wire readLine;
    reg start = 1'b0;

    wire sign3j, signeq, done, sign, eq;

    integer test, i;

    Controller c(
    clk,
    rst,
    start,

    sign3j,
    signeq,
    done,
    sign,
    eq,
    waitCalNexti,
    writeMemReg,

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
    readLine,
    ldTillPositive);

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
    waitCalNexti,
    writeMemReg,
    ldTillPositive,
    update,


    sign3j,
    signeq,
    done,
    sign,
    eq);

    always #20 clk = ~clk;

    initial begin

        #30 rst = 1'b0;
        start = 1'b1;
        test = $fopen("input_0.txt", "r");

        for(i = 0; i < 64; i= i+1) begin  
            line = Mem[i];
            #3000;
        end  
        #100;
        $stop;
    end


endmodule