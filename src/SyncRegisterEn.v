//-----------------------------------------------------------------------------
//
// Title       : SyncRegisterEn
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : C:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/SyncRegisterEn.v
// Generated   : Thu Jun 25 01:51:21 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------


module SyncRegisterEn #(parameter WIDTH=32)
(
    input clk,
    input en,
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
);

initial
    out = 0;

always @(negedge clk) begin
    if(en)
        out <= in;
	end
endmodule
