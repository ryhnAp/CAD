`timescale 1ns/1ns
`define EOF 32'hFFFF_FFFF 

module TB ();
    
    //col parity
    wire colparIJrster;
    reg [24:0] lineKcp;
    reg [24:0] linePKcp;
    wire [5:0] KCP; // k dimension in cp

    wire [24:0]newSlice;
    wire colparDone;
    //col parity

    //rotate
    wire [4:0] sliceIdx; // index in slice which represent what lane we are 
    wire initRotate;
    reg [63:0] lane;

    wire finishLane;
    wire [63:0] newLane; // setting new values
    //rotate

    //permutation
    reg [24:0] Mem [0:63];

    reg [63:0] laneMem [0:24];


    reg clk=1'b0, rst=1'b1, newLine = 1'b1;
    wire IJen, ALUop, read, write, initLine, waitCalNexti;
    wire writeVal, IJregen, fbeq, fb3j, isArith, enable, update, writeMemReg, ldTillPositive;
    wire [4:0]val;
    reg [24:0]line;
    wire [24:0]mem;
    wire readLine, firstread;
    reg start = 1'b0;

    reg [5:0]count = 6'b000000;

    reg [8*11:0]inFileName = "input_0.txt";
    reg [8*12:0]outFileName = "output_0.txt";

    wire sign3j, signeq, done, sign, eq, ok;

    integer test, i, outFile, testCounts=3, k, m, n;
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
    wire addRCDone;
    // add RC

    Controller c(
    clk,
    rst,
    start,
    // col parity 
    colparDone,
    colparIJrster,
    KCP,
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
    initARC
    );

    Datapath dp(
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
    revalNewSlice,
    revalDone,

    //addRC
    A00,
    initARC,
    A00out,
    addRCDone

    );


    always #20 clk = ~clk;

    initial begin
        for (k = 0; k < testCounts ; k = k+1) begin
            $sformat(inFileName, "input_%0d.txt", k);
            $sformat(outFileName, "output_%0d.txt", k);
            $readmemb(inFileName,Mem);
            // inFileName[6] = k + "0";
            // outFileName[7] = k + "0";
            #30 rst = 1'b0;
            start = 1'b1;
            test = $fopen(inFileName, "r");
            outFile = $fopen(outFileName, "w");
            count = 6'b000000;
            for (m = 0; m < 25 ; m = m+1) begin
                for (n = 0; n < 64 ; n = n+1) begin
                    laneMem[m][n] = Mem[n][m];
                end 
            end
            // start
            if (KCP == 6'd0) begin
                linePKcp = 64'd0;
            end
            else begin
                linePKcp = Mem[KCP-6'd1];
            end
            lineKcp = Mem[KCP]; 
            if (KCP == 6'd64) begin
                
            end
            else begin
                if (colparDone) begin
                    Mem[KCP] = newSlice;
                end
            end
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
                // $fwriteb(outFile, mem);
                // $fdisplay(outFile, "");
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

            for(i = 0; i < 64; i= i+1) begin  
                $fwriteb(outFile, Mem[i]);
                $fdisplay(outFile, "");
            end  

            $fclose(test);
            $fclose(outFile);
        end
        #9000;
        $stop;
    end

endmodule