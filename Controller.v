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
    ok
);
    parameter size = 5;
    parameter memsize = 25;
    
    input clk, rst;
    input start, sign3j, signeq, done, sign, eq;
    reg [5:0] count2;
    input [5:0]count;

    output reg IJen, ALUop, read, write, initLine, firstread;
    output reg writeVal, IJregen, fbeq, fb3j, isArith, enable, update, waitCalNexti, writeMemReg, ldTillPositive;
    input [memsize-1:0]line;
    output reg readLine, ok;

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
        Check = 4'D2,
        Prepared = 4'D3,
        Store = 4'd12,
        Updater = 4'd13,
        Next = 4'd14,
        Ready = 4'd15;

    reg enCount=0, loadCount=0, first = 0;
    reg [5:0]loadInit = 0; // n times count = 5
    wire coutCount;


    reg [3:0] ps, ns;

    Counter #6 cc(.clk(clk), .rst(rst), .en(enCount), .ld(loadCount), .initld(loadInit), .co(coutCount));

    always @(posedge clk, posedge rst) begin
        if(rst)begin
            ps <= Start;
            count2 <= 6'b000000;
        end
        else
            ps <= ns;
    end

    wire [5:0] sig;
    wire tmp;
    assign sig = ~(count + ~count2 + 6'b000001);
    assign tmp = sig[5] & sig[4] & sig[3] & sig[2] & sig[1] & sig[0];

    always @(ps, start, sign3j, signeq, done, sign, eq, tmp) begin
        case (ps)
            Start:      ns = start ? Idle : Start;
            Idle:       ns = Ydimension;
            Ydimension: ns = coutCount ? Ready : Line;
            Line:       ns = Store;
            Store:      ns = Shift3;
            Shift3:     ns = Sub3j;
            Sub3j:      ns = ~sign ? Add3j : Sub3j;
            Add3j:      ns = Arithmetic;
            Arithmetic: ns = Sub;
            Sub:        ns = Add;
            Add:        ns = Check;
            Check:      ns = Updater;
            Prepared:   ns = Next;
            Updater:    ns = ~done ? Shift3 : Prepared;
            Next:       ns = (~tmp) ? Next: Ydimension;
            Ready:      ns = Start;
            default: ns = Start;
        endcase
    end

    always @(ps) begin
        {ok, firstread, ldTillPositive, writeMemReg, first, waitCalNexti, IJen, ALUop, read, write, initLine, writeVal, IJregen, fbeq, fb3j, isArith, enable, update, readLine, loadCount, enCount} = 0;
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
                initLine = 1'b1;
                IJregen = 1'b1;
                count2 = count2 + 1;
            end
            Store:     begin
                writeVal = 1'b1;
                firstread = 1'b1;
            end
            Shift3:     begin
                writeMemReg = 1'b1;
                ldTillPositive =1 'b1;
            end
            Sub3j:      begin
                waitCalNexti = 1'b1;
                ldTillPositive = sign;
                update = 1'b1;
            end
            Add3j:      begin
                IJregen = 1'b1;

            end
            Arithmetic: begin
                isArith = 1'b1;
            end
            Sub:        begin
                read = 1'b1;
                fbeq = 1'b1;
                ALUop =  1'b0;
                ok = 1'b1;
            end
            Add:        begin
                fbeq = 1'b1;
                ALUop =  1'b1;
                write = 1'b1;
                ok = 1'b1;
            end
            Check:      begin
                enable = 1'b1;
                ok = 1'b1;
            end
            Prepared:   begin
                ok = 1'b1;
                enCount = 1'b1;
            end
            Store:      begin // fix algo
            end
            Updater:    begin
                
            end
            Next:       begin
                ok = 1'b1;
            end
            Ready:     begin
                //nothing
            end 
        endcase
    end


endmodule