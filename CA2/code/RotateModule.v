module RotateModule(
    clk, 
    rst,
    lane, 
    laneid,
    newLane,
    finishLane,
    initRotate,
    en_rotate
);

    input clk, rst, initRotate, en_rotate;

    input [63:0] lane;

    output reg [63:0] newLane;

    output finishLane;

    input [4:0] laneid;

    reg [5:0] tTable [0:24];

    wire [6:0] zCounter; // z dimention counter
    wire [6:0] zCounterInput; // z dimention counter
    wire [6:0] zCal; // z dimention calculation
    wire [6:0] zMod; // z - tTable is negative or more than 63 then remode
    wire laneInput;

    wire co_temp;
    assign zCounterInput = initRotate ? 7'd0 : zCounter + 7'd1;

    Counter #(7) z_counter_ins(.clk(clk), .rst(rst),
    .en(en_rotate), .ld(initRotate), 
    .initld(7'd0), .co(co_temp), .out(zCounter)); // rotate

    assign zCal = zCounter - tTable[laneid]; 
    assign zMod = zCal[6] ? zCal + 7'd64 : zCal;
 
    assign laneInput = (laneid == 5'd0) ? lane[zCounter] : lane[zMod];

    assign finishLane = zCounter == 7'd64;

    
    initial begin
        tTable[0] = 6'd21;
        tTable[1] = 6'd8;
        tTable[2] = 6'd41;
        tTable[3] = 6'd45;
        tTable[4] = 6'd15;
        tTable[5] = 6'd56;
        tTable[6] = 6'd14;
        tTable[7] = 6'd18;
        tTable[8] = 6'd2;
        tTable[9] = 6'd61;
        tTable[10] = 6'd28;
        tTable[11] = 6'd27;
        tTable[12] = 6'd0;
        tTable[13] = 6'd1;
        tTable[14] = 6'd62;
        tTable[15] = 6'd55;
        tTable[16] = 6'd20;
        tTable[17] = 6'd36;
        tTable[18] = 6'd44;
        tTable[19] = 6'd6;
        tTable[20] = 6'd25;
        tTable[21] = 6'd39;
        tTable[22] = 6'd3;
        tTable[23] = 6'd10;
        tTable[24] = 6'd43;
    end

    always @(posedge clk) begin 
        if(initRotate)  
            newLane <= lane;
        else begin 
            newLane[zCounter] <= lane[zMod];
        end
    end

endmodule