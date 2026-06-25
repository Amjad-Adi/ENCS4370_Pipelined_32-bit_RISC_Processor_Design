//-----------------------------------------------------------------------------
//
// Title       : SyncRegister
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : C:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/SyncRegister.v
// Generated   : Thu Jun 25 01:49:13 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps
  					   
module SyncRegister #(
    parameter W = 32        // Bit width (default 32)
)(
    input              clk, // Clock — latch on posedge
    input      [W-1:0] in,  // Data input
    output reg [W-1:0] out  // Registered output
);
 
    always @(posedge clk) begin
        out <= in;
    end
 
endmodule