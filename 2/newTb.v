`timescale 1ns/1ns

module newTB ();
    
    reg [24:0] Mem [0:63];

    reg [5:0]line;

    integer i;

    initial begin
        $readmemb("input_0.txt",Mem);

        #30
        for(i = 0; i < 6; i= i+1) begin  
            line[i] = Mem[i][0];
        end  
        #90;
        $stop;
    end

endmodule