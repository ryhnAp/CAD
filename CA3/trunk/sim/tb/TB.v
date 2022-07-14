`timescale 1ns/1ns
`define EOF 32'hFFFF_FFFF 

module TB ();
    
    reg [24:0] Mem [0:63];


    reg clk=1'b0, rst=1'b1, newLine = 1'b1;
    wire IJen, ALUop, read, write, initLine, waitCalNexti;
    wire writeVal, IJregen, fbeq, fb3j, isArith, enable, update, writeMemReg, ldTillPositive;
    wire [4:0]val;
    reg [24:0]line;
    wire [24:0]mem;
    wire readLine, firstread;
    reg start = 1'b0;

    reg [5:0]count = 6'b000000;

    reg [8*18:0]inFileName = "./file/input_0.txt";
    reg [8*19:0]outFileName = "./file/output_0.txt";

    wire sign3j, signeq, done, sign, eq, ok;

    integer test, i, outFile, testCounts=3, k;

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
    ldTillPositive,
    count
    ,firstread, 
    ok);

    FDatapath fpga_dp(
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
    eq, 
    mem, 
    firstread,
    ok
    );


    always #20000 clk = ~clk;

    initial begin
        for (k = 0; k < testCounts ; k = k+1) begin
            $sformat(inFileName, "./file/input_%0d.txt", k);
            $sformat(outFileName, "./file/output_%0d.txt", k);
            $readmemb(inFileName,Mem);
            // inFileName[6] = k + "0";
            // outFileName[7] = k + "0";
            #30000 rst = 1'b0;
            start = 1'b1;
            test = $fopen(inFileName, "r");
            outFile = $fopen(outFileName, "w");
            count = 6'b000000;
            for(i = 0; i < 64; i= i+1) begin  
                line = Mem[i];
                #20000000;
                $fwriteb(outFile, mem);
                $fdisplay(outFile, "");
                count = count + 1;
            end  
            $fclose(test);
            $fclose(outFile);
        end
        #9000000;
        $stop;
    end

endmodule