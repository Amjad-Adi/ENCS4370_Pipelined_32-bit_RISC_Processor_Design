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

`timescale 1ps / 1ps


module SyncRegisterEn #(
    parameter W = 32        // Bit width (default 32)
)(
    input              clk, // Clock — latch on posedge
    input              en,  // Enable: 1=latch, 0=hold (disable/stall)
    input      [W-1:0] in,  // Data input
    output reg [W-1:0] out  // Registered output
);
 
    always @(posedge clk) begin
        if (en) begin
            out <= in;      // Normal: latch new value
        end
        // else: hold current value (stall)
    end
 
endmodule
