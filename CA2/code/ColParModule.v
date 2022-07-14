`timescale 1ns/1ns
module ColParModule(
    clk,
    rst,
    colparIJrster,
    lineKcp,
    newSlice,
    colparDone,
    ld_ij_par,
    ld_prev
);


    parameter size = 5;
    parameter memsize = 25;
    parameter initValIJ = 3;

    input colparIJrster, ld_ij_par, clk, rst, ld_prev;
    input [memsize-1:0] lineKcp;
        
    output reg [memsize-1:0] newSlice;
    output colparDone;

    wire [2:0] cpI;
    wire [2:0] cpJ;

    wire [2:0] cpI_input;
    wire [2:0] cpJ_input;

    wire [4:0] cpJmult4;
    wire [4:0] cpJmult5;

    wire [4:0] cpIdx; 

    wire [2:0] cpInew;
    wire [2:0] cpJnew;

    wire [memsize-1: 0] linePKcp;

    wire currSlice, prevSlice;

    assign cpI_input = colparIJrster ? 3'd0 : cpInew;
    assign cpJ_input = colparIJrster ? 3'd0 : cpJnew;

    my_register #(3) Ireg(.clk(clk), .rst(rst),  .ld(ld_ij_par), 
        .inputData(cpI_input), .outputData(cpI));
    my_register #(3) Jreg(.clk(clk), .rst(rst),  .ld(ld_ij_par), 
        .inputData(cpJ_input), .outputData(cpJ));

    Shifter #(5) colparMultiplyJ4(.data({2'b00, cpJ}), .coefficient({2'b01}), .shifted(cpJmult4));
    Adder #(5) colparMultiplyJ5(.i1({2'b00, cpJ}), .i2(cpJmult4), .a(cpJmult5));
    Adder #(5) colparIndexAdder(.i1(cpJmult5), .i2({2'b00, cpI}), .a(cpIdx));

    assign currSlice = (cpI == 3'd0) ? 1'b0 : lineKcp[5'd20+cpI-1'd1] ^ lineKcp[5'd15+cpI-1'd1] 
     ^ lineKcp[5'd10+cpI-1'd1] ^ lineKcp[5'd5+cpI-1'd1] ^ lineKcp[cpI-1'd1];
     
    assign prevSlice = (cpI == 3'b100) ? 1'b0 : linePKcp[5'd20+cpI+1'd1] 
    ^ linePKcp[5'd15+cpI+1'd1] ^ linePKcp[5'd10+cpI+1'd1] ^ linePKcp[5'd5+cpI+1'd1] ^ linePKcp[cpI+1'd1];

    my_register #(1) CPnewSliceUpdater(.clk(clk), .rst(rst), .ld(1'd1), 
        .inputData(lineKcp[cpIdx] ^ ( currSlice) ^ ( prevSlice)), 
        .outputData(out_parity));

    my_register #(25) parity_prev_reg(.clk(clk), .rst(rst), .ld(ld_prev), .inputData(lineKcp), 
        .outputData(linePKcp));

    Adder #(3) colparJIndexAdder(.i1(Jincreaser), .i2(1'b1), .a(increasedJ));

    assign cpInew = (cpI == 3'd0) ? 3'd1: (cpI == 3'd1) ? 3'd2: 
        (cpI == 3'd2) ? 3'd3: (cpI == 3'd3) ? 3'd4:
        (cpI == 3'd4) ? 3'd0: 3'd0;
    
    assign cpJnew = (cpI == 3'd4) ? cpJ + 1: cpJ;

    assign colparDone = (cpJnew == 3'd5);

    always @(posedge clk)  begin 
        if(colparIJrster)
            newSlice <= lineKcp;
        else 
            newSlice[cpIdx] <= lineKcp[cpIdx] ^ ( currSlice) ^ ( prevSlice);
    end


endmodule