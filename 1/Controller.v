`timescale 1ns/1ns
module Controller (
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
    readLine

);
    parameter size = 5;
    parameter memsize = 25;
    
    input clk, rst;
    input start, sign3j, signeq, done, sign, eq;

    output reg IJen, ALUop, read, write, initLine;
    output reg writeVal, IJregen, fbeq, fb3j, isArith, enable, update;
    input [memsize-1:0]line;
    output reg readLine;

    parameter [3:0] 
        Start = 4'd0,
        Idle = 4'd1,
        Ydimension = 4'd2,
        Line = 4'd3,
        Shift3 = 4'd4,
        Sub3j = 4'd5,
        Add3j = 4'd6,
        Arithmetic = 4'd7,
        Sub = 4'd8,
        Add = 4'd9,
        Check = 4'd10,
        Prepared = 4'd11,
        Store = 4'd12,
        Updater = 4'd13,
        Next = 4'd14,
        Ready = 4'd15;

    reg enCount=0, loadCount=0;
    reg [5:0]loadInit = 0; // n times count = 5
    wire coutCount;

    reg [3:0] ps, ns = Start;

    Counter #6 cc(.clk(clk), .rst(rst), .en(enCount), .ld(loadCount), .initld(loadInit), .co(coutCount));

    always @(posedge clk, posedge rst) begin
        if(rst)
            ps <= Start;
        else
            ps <= ns;
    end

    always @(ps, start, sign3j, signeq, done, sign, eq) begin
        case (ps)
            Start:      ns = start ? Idle : Start;
            Idle:       ns = Ydimension;
            Ydimension: ns = coutCount ? Ready : Line;
            Line:       ns = Shift3;
            Shift3:     ns = sign3j ? Add3j : Sub3j;
            Sub3j:      ns = sign3j ? Add3j : Sub3j;
            Add3j:      ns = Arithmetic;
            Arithmetic: ns = signeq ? Add : Sub;
            Sub:        ns = signeq ? Add : Sub;
            Add:        ns = Check;
            Check:      ns = eq ? Add : Prepared;
            Prepared:   ns = Store;
            Store:      ns = Updater;
            Updater:    ns = done ? Next : Shift3;
            Next:       ns = Ydimension;
            Ready:      ns = Start;
            default: ns = Start;
        endcase
    end

    always @(ps) begin
        {IJen, ALUop, read, write, initLine, writeVal, IJregen, fbeq, fb3j, isArith, enable, update, readLine} = 0;
        case (ps)
            Start:      begin
                //nothing
            end
            Idle:       begin
                loadCount = 1'd1;
            end
            Ydimension: begin
                //nothing
                readLine = 1'b1;
            end
            Line:       begin
                IJen = 1'b1;
                read = 1'b1;
                initLine = 1'b1;
                writeVal = 1'b1;
            end
            Shift3:     begin
                //nothing
                
            end
            Sub3j:      begin
                ALUop =  1'b0;
                fb3j = 1'b1;
            end
            Add3j:      begin
                ALUop =  1'b1;
                fb3j = 1'b1;

            end
            Arithmetic: begin
                isArith = 1'b1;
            end
            Sub:        begin
                fbeq = 1'b1;
                ALUop =  1'b0;

            end
            Add:        begin
                fbeq = 1'b1;
                ALUop =  1'b1;
                
            end
            Check:      begin
                enable = 1'b1;
            end
            Prepared:   begin
                IJregen = 1'b1;
            end
            Store:      begin // fix algo
                update = 1'b1;
            end
            Updater:    begin
                write = 1'b1;
                
            end
            Next:       begin
                enCount = 1'b1;
            end
            Ready:     begin
                //nothing
            end 
        endcase
    end


endmodule