`timescale 1ns/1ns
module Counter (
    clk,
    rst,
    en,
    ld,
    initld,
    co, 
    out
);
    parameter n = 6;
    
    input clk,rst,en,ld;
    input [n-1:0] initld;
    
    output co;
    output [n-1:0] out;

    reg [n-1:0]PO;
    
    always@(posedge clk,posedge rst)begin
    	if(rst)
    		PO <= {n{1'd0}};
    	if(ld)
    		PO <= initld;
		else
        	PO <= en ? PO+1 : PO;

    end

    assign co = &PO;
    assign out = PO;

endmodule