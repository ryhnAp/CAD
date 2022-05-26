`timescale 1ns/1ns
module Controller (
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
    parameter size = 5;
    parameter memsize = 25;
    
    input clk, rst, next_lane;
    output reg ld_ij_par;

    // col parity
    input colparDone, next_par;
    output reg colparIJrster, en_rotate;
    output [5:0] KCP;

    // col parity

    // rotate
    input finishLane;

    output [4:0] sliceIdx; // index in slice which represent what lane we are 
    output reg initRotate;
    // rotate


    //permutation
    input start, sign3j, signeq, done, sign, eq;
    input [5:0]count;
    input [memsize-1:0]line;

    output reg IJen, ALUop, read, write, initLine, firstread;
    output reg writeVal, IJregen, fbeq, fb3j, isArith, enable, update, waitCalNexti, writeMemReg, ldTillPositive;
    output reg readLine, ok;
    reg [5:0] count2;
    //permutation

    // revaluate
    output reg initReval, ld_prev;

    output [5:0] revalDim;// revaluate dimension
    output reg revalDone;
    // revaluate

    // add rc
    input addRCDone;
    output reg initARC;
    // add rc


    parameter [5:0] 
        Start = 6'd0,
        //col par
        ColBegin = 6'd16,
        ColCal = 6'd40,
        ColDone = 6'd17,
        ColDim = 6'd18, // col parity add 1 to counter cuz next col
        ColNext = 6'd19, // col parity check to go to the next dimension
        //rotate
        RBegin = 6'd20,
        RCal = 6'd21,
        RDone = 6'd22,
        RDim = 6'd35,
        RCell = 6'd23, // rotate add 1 to counter cuz next cell and get lane from testbench then pass it to datapath
        RNext = 6'd24, // rotate check to go to the next cell

        //permut
        Idle = 6'd1,
        Ydimension = 6'd2,
        Line = 6'd3,
        Shift3 = 6'd4,
        Sub3j = 6'd5,
        Add3j = 6'd6,
        Arithmetic = 6'd7,
        Sub = 6'd8,
        Add = 6'd9,
        Check = 6'd10,
        Prepared = 6'd11,
        Store = 6'd12,
        Updater = 6'd13,
        Next = 6'd14,
        Ready = 6'd15,
        
        //reval
        RevalBegin = 6'd25,
        RevalCal = 6'd26,
        RevalDone = 6'd27,
        RevalDim = 6'd36,
        RevalCell = 6'd28, // revaluate add 1 to counter 
        RevalNext = 6'd29, // revaluate check to go to the next z dim
        //add rc
        RCBegin = 6'd30,
        RCCal = 6'd31,
        RCDone = 6'd32,
        RCDim = 6'd37,
        RCCell = 6'd33, // add rc
        RCNext = 6'd34 // add rc
        ;

    reg enCount=0, loadCount=0, first = 0;
    reg [5:0]loadInit = 0;
    wire [5:0]step;
    wire coutCount;

    reg CPenCount=0, CPloadCount=0; // col parity 64 z dimension counter
    wire CPcoutCount; // col parity count is done ?
    wire [6:0]CPstep;


    reg RenCount=0, RloadCount=0; // rotate 64 z dimension counter
    wire RcoutCount; // rotate count is done ?
    wire [4:0]Rstep;

    reg revalEnCount=0, revalLoadCount=0; // reval 64 z dimension counter
    wire revalCoutCount; // reval count is done ?
    wire [5:0]RVstep;

    reg [5:0] ps, ns;

    Counter #(6) cc(.clk(clk), .rst(rst), .en(enCount), .ld(loadCount), .initld(loadInit), .co(coutCount), .out(step));
    Counter #(7) ccCP(.clk(clk), .rst(rst), .en(CPenCount), .ld(CPloadCount), .initld(7'd62), .co(CPcoutCount), .out(CPstep)); // col parity
    Counter #(5) ccR(.clk(clk), .rst(rst), .en(RenCount), .ld(RloadCount), .initld(5'd8), .co(RcoutCount), .out(Rstep)); // rotate
    Counter #(6) ccReval(.clk(clk), .rst(rst), .en(revalEnCount), .ld(revalLoadCount), .initld(loadCount), .co(revalCoutCount), .out(RVstep)); // rotate

    assign KCP = CPstep;
    assign sliceIdx = Rstep - 5'd8; // get slice index value in rotate between 0-24 
    assign revalDim = RVstep;

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

    always @(ps, start, sign3j, signeq, done, sign, eq, tmp, colparDone, CPcoutCount, finishLane, RcoutCount, revalDone, revalCoutCount, addRCDone, ld_ij_par, next_par, next_lane) begin
        case (ps)
            Start:      ns = start ? ColBegin : Start;
            //col par
            ColBegin:   ns = ColCal;
            ColCal:     ns = ColDone;
            ColDone:    ns = colparDone ? ColDim : ColDone;
            ColDim:     ns = ColNext;
            ColNext:    ns = CPcoutCount ? RBegin : next_par? ColBegin: ColNext;
            //rotate
            RBegin:     ns = RCal;
            RCal:       ns = RDone;
            RDone:      ns = finishLane ? RDim : RDone;
            RDim:       ns = RcoutCount ? Idle: next_lane? RNext: RDim;
            RNext:      ns = RcoutCount ? Idle : RBegin;
            
            //permut
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
            Ready:      ns = RevalBegin;

            //reval
            RevalBegin: ns = RevalCal;
            RevalCal:   ns = RevalDone;
            RevalDone:  ns = revalDone ? RevalDim : RevalDone;
            RevalDim:   ns = RevalNext;
            RevalNext:  ns = revalCoutCount ? RCBegin : RevalBegin;
            //addRC
            RCBegin:    ns = RCCal;
            RCCal:      ns = RCDone;
            RCDone:     ns = addRCDone ? RCDim : RCDone;
            RCDim:      ns = RCNext;
            RCNext:     ns = Start;
            default: ns = Start;
        endcase
    end

    always @(ps) begin
        {ok, firstread, ldTillPositive, writeMemReg, first, waitCalNexti, IJen, ALUop, read, write, 
            initLine, writeVal, IJregen, fbeq, fb3j, isArith, enable, update, readLine, loadCount, enCount, 
            colparIJrster, CPenCount, CPloadCount, initRotate, initReval, initARC , ld_ij_par, ld_prev,
            en_rotate, RloadCount} = 0;
        case (ps)
            Start:      begin
                //nothing
                CPloadCount = 1'b1;
            end
            //col par
            ColBegin: begin
                colparIJrster = 1'd1;
                ld_ij_par = 1'b1;
            end
            ColCal: begin
                ld_ij_par = 1'b1;

            end
            ColDone: begin
                ld_ij_par = 1'b1;
            end
            ColDim: begin
                CPenCount = 1'd1;
                ld_prev = 1'b1;
            end
            ColNext: begin

            end
            //rotate
            RBegin: begin
                initRotate = 1'd1;
                RloadCount = 1'b1;
            end
            RCal: begin

            end
            RDone: begin
                en_rotate = 1'b1;
            end
            RDim: begin
                RenCount = 1'd1;
            end
            RNext: begin

            end
            
            //permut
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
            //reval
            RevalBegin: begin
                initReval = 1'd1;
            end
            RevalCal: begin

            end
            RevalDone: begin

            end
            RevalDim: begin
                revalEnCount = 1'd1;
            end
            RevalNext: begin

            end
            // add rc
            RCBegin: begin
                initARC = 1'd1;
            end
            RCCal: begin

            end
            RCDone: begin

            end
            RCDim: begin
                revalEnCount = 1'd1;
            end
            RCNext: begin

            end
            

        endcase
    end


endmodule