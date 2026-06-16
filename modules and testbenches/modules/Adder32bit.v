//-----------------------------------------------------------------------------
//
// Title       : Adder32bit
// Design      : SPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/SPA/SPA/src/Adder32bit.v
// Generated   : Sat Jun 13 21:23:15 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps


module Adder32bit (
    input  [31:0] A,        
    input  [31:0] B,        
    output [31:0] Sum       
);

    assign Sum = A + B;
 
endmodule