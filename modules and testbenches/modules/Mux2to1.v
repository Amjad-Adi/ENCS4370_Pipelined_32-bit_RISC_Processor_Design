//-----------------------------------------------------------------------------
//
// Title       : Mux2to1
// Design      : SPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/SPA/SPA/src/Mux2to1.v
// Generated   : Sat Jun 13 21:19:41 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

module Mux2to1_32bit (
    input [31:0] In0,
    input [31:0] In1,
    input [31:0] Sel,
    output [31:0] Out
);
    assign Out = Sel ? In1 : In0;
endmodule