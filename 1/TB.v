`timescale 1ns/1ns
`define EOF 32'hFFFF_FFFF 

module TB ();
    
    reg clk=1'b0, rst=1'b1;
    wire IJen, ALUop, read, write, initLine;
    wire writeVal, IJregen, fbeq, fb3j, isArith, enable, update;
    wire [4:0]val;
    wire [24:0]line;
    wire readLine;

    wire sign3j, signeq, done, sign, eq;

    integer test, cc;

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
    update,
    readLine);

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

    always #20 clk = ~clk;

    initial begin
        #30 rst = 1'b0;
        test = $fopen("input_0.txt", "r");

        cc = $fgetc(test);
        while (cc != `EOF) begin
            // if (readLine) begin
            //     $fscanf(test, "%b\n", line);
            // end
            cc = $fgetc(test);
            #300;
        end
        #100;
        $stop;
    end


endmodule