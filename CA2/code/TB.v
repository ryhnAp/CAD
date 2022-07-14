`timescale 1ns/1ns
`define EOF 32'hFFFF_FFFF 

module TB ();
    
    //col parity
    wire colparIJrster;
    reg [24:0] lineKcp;

    wire [24:0]newSlice;
    wire colparDone, ld_ij_par;
    //col parity

    //rotate
    wire [4:0] sliceIdx; // index in slice which represent what lane we are 
    wire initRotate;
    reg [63:0] lane;

    wire finishLane;
    reg next_lane;
    wire [63:0] newLane; // setting new values
    //rotate

    //permutation
    reg [24:0] Mem [0:63];
    reg [24:0] Mem2[0:63];


    reg [63:0] laneMem [0:24];

    reg [4:0]laneid;
    reg clk=1'b0, rst=1'b1, newLine = 1'b1;
    wire IJen, ALUop, read, write, initLine, waitCalNexti;
    wire writeVal, IJregen, fbeq, fb3j, isArith, enable, update, writeMemReg, ldTillPositive;
    wire [4:0]val;
    reg [24:0]line;
    wire [24:0]mem;
    wire readLine, firstread, ld_prev;
    reg start = 1'b0, next_par = 1'b0;

    reg [5:0]count = 6'b000000;

    reg [8*11:0]inFileName = "input_0.txt";
    reg [8*12:0]outFileName = "output_0.txt";

    wire sign3j, signeq, done, sign, eq, ok;

    integer test, i, outFile, testCounts=3, k, m, n, j;
    //permutation

    // revaluate
    wire initReval;
    reg [24:0] slice;
    wire [5:0] revalDim;// revaluate dimension

    wire [24:0] revalNewSlice;
    wire revalDone;
    // revaluate

    // add RC
    reg [63:0] A00; // A[0,0]
    wire initARC;

    wire [63:0] A00out;
    wire addRCDone, en_rotate;
    // add RC

    Controller c(
    clk,
    rst,
    start,
    // col parity 
    colparDone,
    colparIJrster,
    KCP,
    ld_ij_par,
    // rotate
    sliceIdx,
    initRotate,
    finishLane,
    // permut
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
    count,
    firstread,
    ok,
    // reval
    initReval,
    revalDim,
    revalDone,
    // add rc
    addRCDone,
    initARC,
    next_par,
    ld_prev,
    next_lane,
    en_rotate
    );

    Datapath dp(
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


    always #20 clk = ~clk;

    initial begin
        for (k = 0; k < testCounts ; k = k+1) begin

            $sformat(inFileName, "input_%0d.txt", k);
            $sformat(outFileName, "output_%0d.txt", k);
            $readmemb(inFileName,Mem);

            #30 rst = 1'b0;
            start = 1'b1;

            test = $fopen(inFileName, "r");
            outFile = $fopen(outFileName, "w");

            for(i = 0; i < 64; i= i+1) begin 
                lineKcp = Mem[i];
                #60 
                    next_par = 1'b0;
                #1500;
                Mem[i] = newSlice;
                next_par = 1'b1;
            end  

        //rotate

            for(i = 0; i < 25; i= i+1) begin 
                lane = 64'd0;
                laneid = i;
                for(j = 0; j < 64; j = j + 1) begin
                    lane[j] = Mem[j][i]; 
                end
                #60 
                    next_lane = 1'b0;
                #80000;
                laneMem[i] = newLane;
                next_lane = 1'b1;
            end

            for (m = 0; m < 25 ; m = m+1) begin
                for (n = 0; n < 64 ; n = n+1) begin
                    Mem[n][m] = laneMem[m][n];
                end 
            end 

            count = 6'd0;
            rst = 1'b1;
            #80 rst = 1'b0;

            for(i = 0; i < 64; i= i+1) begin  
                line = Mem[i];
                #20000;
                Mem2[i] = mem;
                count = count + 1;
            end 

             for(i = 0; i < 64; i= i+1) begin  
                Mem[i] = Mem2[i];
            end 
            /*
            lane = laneMem[sliceIdx];
            if (finishLane) begin
                laneMem[sliceIdx] = newLane;
            end

            if (sliceIdx == 5'd24) begin
                for (m = 0; m < 25 ; m = m+1) begin
                    for (n = 0; n < 64 ; n = n+1) begin
                        Mem[n][m] = laneMem[m][n];
                    end 
                end 
            end

            for(i = 0; i < 64; i= i+1) begin  
                line = Mem[i];
                #20000;
                Mem[i] = mem;
                count = count + 1;
            end  
            slice = Mem[revalDim];
            if (revalDone) begin
                Mem[revalDim] = revalNewSlice;
            end

            for (n = 0; n < 64 ; n = n+1) begin
                A00[n] = Mem[n][0];
            end
            
            if (addRCDone) begin
                for (n = 0; n < 64 ; n = n+1) begin
                    Mem[n][0] = A00out[n];
                end 
            end

            */
            for(i = 0; i < 64; i= i+1) begin  
                $fwriteb(outFile, Mem[i]);
                $fdisplay(outFile, "");
            end  

            $fclose(test);
            $fclose(outFile);
        end
        #9000
        $stop;
    end

endmodule