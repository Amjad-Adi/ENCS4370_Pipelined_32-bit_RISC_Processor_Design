//-----------------------------------------------------------------------------
//
// Title       : Comparator
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/Comparator.v
// Generated   : Tue Jun 16 18:00:46 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps


module Comparator (
    input  [31:0] A,        
    input  [31:0] B,       
    output        Equal    
);
   
    assign Equal = (A == B) ? 1'b1 : 1'b0;
 
endmodule