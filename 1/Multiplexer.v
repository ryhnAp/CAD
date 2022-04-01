`timescale 1ns/1ns
module Multiplexer (
   res,
   enable,
   o1,
   o2,
   o3,
   o4
);
   parameter size = 5;

   input [size-1:0]res;
   input enable;

   output [size-1:0]o1;
   output [size-1:0]o2;
   output [size-1:0]o3;
   output [size-1:0]o4;

   parameter one = 1;
   parameter three = 3;
   parameter z_ = z;

   case (res)
      one: begin
         o1 = enable ? one : z_;
         o2 = z_;
         o3 = z_;
         o4 = res;
      end
      three: begin
         o1 = z_;
         o2 = enable ? one : z_;
         o3 = z_;
         o4 = res;
      end
      z_: begin
         o1 = z_;
         o2 = z_;
         o3 = z_;
         o4 = res;
      end
      default: begin
         o1 = z_;
         o2 = z_;
         o3 = z_;
         o4 = res;    
      end
   endcase

endmodule