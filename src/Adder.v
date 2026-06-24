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


module Adder #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] OperandA,
    input [WIDTH-1:0] OperandB,
    output [WIDTH-1:0] Result
);

    assign Result = OperandA + OperandB;
 
endmodule