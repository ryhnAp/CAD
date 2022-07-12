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
    input [5:0]count;
    input [memsize-1:0]line;

    output reg ldTillPositive;
    output reg fb3j, waitCalNexti;
    output readLine;
    output ok, firstread, writeMemReg, IJen, ALUop, read, write, initLine;
    output update, enable, isArith, fbeq, IJregen, writeVal;

    parameter [3:0] 
        Start = 4'd0,       //0000
        Idle = 4'd1,        //0001
        Ydimension = 4'd2,  //0010
        Line = 4'd3,        //0011
        Shift3 = 4'd4,      //0100
        Sub3j = 4'd5,       //0101
        Add3j = 4'd6,       //0110
        Arithmetic = 4'd7,  //0111
        Sub = 4'd8,         //1000
        Add = 4'd9,         //1001
        Check = 4'd10,      //1010
        Prepared = 4'd11,   //1011
        Store = 4'd12,      //1100
        Updater = 4'd13,    //1101
        Next = 4'd14,       //1110
        Ready = 4'd15;      //1111

    reg first = 0;
    reg [5:0]loadInit = 0;
    wire [5:0]prevCounter, currCounter;
    wire [5:0]count2, newCount2;
    wire coutCount, coutCount2;
    wire valBitxx01, valBitxx00, valBitxx10, xorBit0and1, andBit0and1;
    wire enCount, loadCount;
    wire [5:0] sig;
    wire tmp;

    wire [3:0] ps, ns;

    S2 #(6) update_counter_s2(.D0(prevCounter),.D1(currCounter),.D2(loadInit),.D3(loadInit),.A1(loadCount),.B1(loadCount),.A0(enCount),.B0(enCount),.CLR(rst),.clk(clk),.out(prevCounter));
    C2Adder #(6) increase_counter_c2(.i1(prevCounter), .i2(6'd1), .o({coutCount, currCounter}));

    // Counter #6 cc(.clk(clk), .rst(rst), .en(enCount), .ld(loadCount), .initld(loadInit), .co(coutCount));

    S2 #(6) update_counte2_s2(.D0(count2),.D1(newCount2),.D2(loadInit),.D3(loadInit),.A1(rst),.B1(rst),.A0(ps[0]&ps[1]&~ps[2]&~ps[3]),.B0(ps[0]&ps[1]&~ps[2]&~ps[3]),.CLR(rst),.clk(clk),.out(count2)); //A0(ps[0]&ps[1]&~ps[2]&~ps[3]) means it is line state and count2 needs to update
    C2Adder #(6) increase_counter2_c2(.i1(count2), .i2(6'd1), .o({coutCount2, newCount2}));

    assign valBitxx10 = ps[1]&(~ps[0]);
    assign valBitxx01 = (~ps[1])&ps[0];
    assign valBitxx00 = (~ps[1])&(~ps[0]);
    assign xorBit0and1 = ps[0]^ps[1];
    assign andBit0and1 = ps[0]&ps[1];

    S2 #(1) ns0_s2(.D0(~ps[0]),.D1(done&valBitxx01),.D2(((~ps[0])&(~valBitxx00))|(start&(valBitxx00))),.D3((~ps[0])|(sign&valBitxx01)),.A1(~ps[3]),.B1(1'b0),.A0(ps[2]),.B0(ps[2]),.CLR(rst),.clk(clk),.out(ps[0])); //
    S2 #(1) ns1_s2(.D0(ps[0]),.D1(((xorBit0and1)&~(valBitxx01))|(done&(valBitxx01))),.D2(xorBit0and1),.D3(((xorBit0and1)&~(valBitxx01))|((~sign)&(valBitxx01))),.A1(~ps[3]),.B1(1'b0),.A0(ps[2]),.B0(ps[2]),.CLR(rst),.clk(clk),.out(ps[1])); //
    S2 #(1) ns2_s2(.D0(ps[1]),.D1(((~done)&valBitxx01)|((~tmp)&valBitxx10)|(valBitxx00)),.D2((ps[1]&~(valBitxx10))|(coutCount&valBitxx10)),.D3(~andBit0and1),.A1(~ps[3]),.B1(1'b0),.A0(ps[2]),.B0(ps[2]),.CLR(rst),.clk(clk),.out(ps[2])); //
    S2 #(1) ns3_s2(.D0(1'b1),.D1((done&valBitxx01)|((~tmp)&valBitxx10)),.D2((ps[1]&~(valBitxx10))|(coutCount&valBitxx10)),.D3(andBit0and1),.A1(~ps[3]),.B1(1'b0),.A0(ps[2]),.B0(ps[2]),.CLR(rst),.clk(clk),.out(ps[3])); //

    // always @(posedge clk, posedge rst) begin
    //     if(rst)begin
    //         ps <= Start;
    //         // count2 <= 6'b000000;
    //     end
    //     else
    //         ps <= ns;
    // end

    assign sig = ~(count + ~count2 + 6'b000001);
    assign tmp = sig[5] & sig[4] & sig[3] & sig[2] & sig[1] & sig[0];

    // always @(ps, start, sign3j, signeq, done, sign, eq, tmp) begin
    //     case (ps)
    //         Start:      ns = start ? Idle : Start;
    //         Idle:       ns = Ydimension;
    //         Ydimension: ns = coutCount ? Ready : Line;
    //         Line:       ns = Store;
    //         Store:      ns = Shift3;
    //         Shift3:     ns = Sub3j;
    //         Sub3j:      ns = ~sign ? Add3j : Sub3j;
    //         Add3j:      ns = Arithmetic;
    //         Arithmetic: ns = Sub;
    //         Sub:        ns = Add;
    //         Add:        ns = Check;
    //         Check:      ns = Updater;
    //         Prepared:   ns = Next;
    //         Updater:    ns = ~done ? Shift3 : Prepared;
    //         Next:       ns = (~tmp) ? Next: Ydimension;
    //         Ready:      ns = Start;
    //         default: ns = Start;
    //     endcase
    // end

    C2 #(1) ok_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[3]&((~ps[2])|(ps[2]&ps[1]&(~ps[0])))),.B0(1'b1),.out(ok)); //A0(ps[3]&((~ps[2])|(ps[2]&ps[1]&(~ps[0])))) means it is sub|add|check|prepared|next state and ok needs to update
    C2 #(1) firstread_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[3]&ps[2]&(~ps[1])&(~ps[0])),.B0(1'b1),.out(firstread)); //A0(ps[3]&ps[2]&~ps[1]&~ps[0]) means it is store state and firstread needs to update
    // C2 #(1) ldTillPositive_c2(.D0(1'b1),.D1(sign),.D2(1'b0),.D3(1'b0),.A1(~ps[2]|ps[3]|ps[1]),.B1(rst),.A0(ps[0]),.B0(1'b1),.out(ldTillPositive)); //A0(ps[0]) if it is one means it is sub3j otherwise it is shift3 if it isnt these states we have zero and ldTillPositive needs to update
    C2 #(1) writeMemReg_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0((~ps[3])&ps[2]&(~ps[1])&(~ps[0])),.B0(1'b1),.out(writeMemReg)); //A0((~ps[3])&ps[2]&(~ps[1])&(~ps[0])) means it is shift3 state and writeMemReg needs to update
    // C2 #(1) waitCalNexti_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0((~ps[3])&ps[2]&(~ps[1])&ps[0]),.B0(1'b1),.out(waitCalNexti)); //A0((~ps[3])&ps[2]&(~ps[1])&ps[0]) means it is sub3j state and waitCalNexti needs to update
    C2 #(1) IJen_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[1]&ps[0]&(~ps[3])&(~ps[2])),.B0(1'b1),.out(IJen)); //A0(ps[1]&ps[0]&~ps[3]&~ps[2]) means it is line state and IJen needs to update
    C2 #(1) ALUop_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[3]&ps[0]&(~ps[2])&(~ps[1])),.B0(1'b1),.out(ALUop)); //A0(ps[3]&ps[0]&~ps[2]&~ps[1]) means it is add state and ALUop needs to update
    C2 #(1) read_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[3]&(~ps[0])&(~ps[2])&(~ps[1])),.B0(1'b1),.out(read)); //A0(ps[3]&(~ps[0])&(~ps[2])&(~ps[1])) means it is sub state and read needs to update
    C2 #(1) write_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[3]&ps[0]&(~ps[2])&(~ps[1])),.B0(1'b1),.out(write)); //A0(ps[3]&ps[0]&~ps[2]&~ps[1]) means it is add state and write needs to update
    C2 #(1) initLine_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[1]&ps[0]&(~ps[3])&(~ps[2])),.B0(1'b1),.out(initLine)); //A0(ps[1]&ps[0]&~ps[3]&~ps[2]) means it is line state and initLine needs to update
    C2 #(1) writeVal_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[3]&ps[2]&(~ps[1])&(~ps[0])),.B0(1'b1),.out(writeVal)); //A0(ps[3]&ps[2]&~ps[1]&~ps[0]) means it is store state and writeVal needs to update
    C2 #(1) IJregen_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[1]&(~ps[3])),.B0(1'b1),.out(IJregen)); //A0(ps[1]&(~ps[3])) means it is line|add3j state and IJregen needs to update
    C2 #(1) fbeq_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[3]&(~ps[2])&(~ps[1])),.B0(1'b1),.out(fbeq)); //A0(ps[3]&(~ps[2])&(~ps[1])) means it is add|sub state and fbeq needs to update
    C2 #(1) isArith_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[0]&ps[1]&ps[2]&(~ps[3])),.B0(1'b1),.out(isArith)); //A0(ps[0]&ps[1]&ps[2]&(~ps[3])) means it is arithmetic state and isArith needs to update
    C2 #(1) enable_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[3]&ps[1]&(~ps[2])&(~ps[0])),.B0(1'b1),.out(enable)); //A0(ps[3]&ps[1]&(~ps[2])&(~ps[0])) means it is check state and enable needs to update
    C2 #(1) update_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[2]&ps[0]&(~ps[3])&(~ps[1])),.B0(1'b1),.out(update)); //A0(ps[2]&ps[0]&(~ps[3])&(~ps[1])) means it is sub3j state and update needs to update
    C2 #(1) readLine_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[1]&(~ps[3])&(~ps[2])&(~ps[0])),.B0(1'b1),.out(readLine)); //A0(ps[1]&(~ps[3])&(~ps[2])&(~ps[0])) means it is ydimension state and readLine needs to update
    C2 #(1) loadCount_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0(ps[0]&(~ps[3])&(~ps[2])&(~ps[1])),.B0(1'b1),.out(loadCount)); //A0(ps[0]&(~ps[3])&(~ps[2])&(~ps[1])) means it is idle state and loadCount needs to update
    C2 #(1) enCount_c2(.D0(1'b0),.D1(1'b1),.D2(1'b0),.D3(1'b0),.A1(rst),.B1(rst),.A0((~ps[2])&ps[3]&ps[1]&ps[0]),.B0(1'b1),.out(enCount)); //A0(ps[0]&(~ps[3])&(~ps[2])&(~ps[1])) means it is idle state and enCount needs to update


    always @(ps) begin
        {ldTillPositive, waitCalNexti} = 0;
        case (ps)
            Start:      begin
                //nothing
            end
            Idle:       begin
                // loadCount = 1'd1;
            end
            Ydimension: begin
                //nothing
                // readLine = 1'b1;
            end
            Line:       begin
                // IJen = 1'b1;
                // initLine = 1'b1;
                // IJregen = 1'b1;
                // count2 = count2 + 1;
            end
            Store:     begin
                // writeVal = 1'b1;
                // firstread = 1'b1;
            end
            Shift3:     begin
                // writeMemReg = 1'b1;
                ldTillPositive =1 'b1;
            end
            Sub3j:      begin
                waitCalNexti = 1'b1;
                ldTillPositive = sign;
                // update = 1'b1;
            end
            Add3j:      begin
                // IJregen = 1'b1;

            end
            Arithmetic: begin
                // isArith = 1'b1;
            end
            Sub:        begin
                // read = 1'b1;
                // fbeq = 1'b1;
                // ALUop =  1'b0;
                // ok = 1'b1;
            end
            Add:        begin
                // fbeq = 1'b1;
                // ALUop =  1'b1;
                // write = 1'b1;
                // ok = 1'b1;
            end
            Check:      begin
                // enable = 1'b1;
                // ok = 1'b1;
            end
            Prepared:   begin
                // ok = 1'b1;
                // enCount = 1'b1;
            end
            Store:      begin // fix algo
            end
            Updater:    begin
                
            end
            Next:       begin
                // ok = 1'b1;
            end
            Ready:     begin
                //nothing
            end 
        endcase
    end


endmodule