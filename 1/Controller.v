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
    update

);
    
    input clk, rst;
    input start, sign3j, signeq, done, sign, eq;

    output reg IJen, ALUop, read, write, initLine;
    output reg writeVal, IJregen, fbeq, fb3j, isArith, enable, update;
    output reg [size-1:0]val;
    output reg [memsize-1:0]line;

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
        Start:      start ? Idle : Start;
        Idle:       Ydimension;
        Ydimension: coutCount ? Ready : Line;
        Line:       Shift3;
        Shift3:     sign3j ? Add3j : Sub3j;
        Sub3j:      sign3j ? Add3j : Sub3j;
        Add3j:      Arithmetic;
        Arithmetic: signeq ? Add : Sub;
        Sub:        signeq ? Add : Sub;
        Add:        Check;
        Check:      eq ? Add : Prepared;
        Prepared:   Store;
        Store:      Updater;
        Updater:    done ? Next : Shift3;
        Next:       Ydimension;
        Ready:      Ready;
    end

    always @(ps) begin
        Start:      begin
            //nothing
        end
        Idle:       begin
            loadCount = 1'd1;
        end
        Ydimension: begin
            //nothing
        end
        Line:       begin
            
        end
        Shift3:     begin
            
        end
        Sub3j:      begin
            
        end
        Add3j:      begin
            
        end
        Arithmetic: begin
            
        end
        Sub:        begin
            
        end
        Add:        begin
            
        end
        Check:      begin
            
        end
        Prepared:   begin
            
        end
        Store:      begin
            
        end
        Updater:    begin
            
        end
        Next:       begin
            
        end
        Ready:     begin
            
        end 
    end


endmodule