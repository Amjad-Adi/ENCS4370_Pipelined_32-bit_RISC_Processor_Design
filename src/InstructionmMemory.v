//-----------------------------------------------------------------------------
//
// Title       : Instructionmmemory
// Design      : SPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/SPA/SPA/src/InstructionmMemory.v
// Generated   : Sat Jun 13 20:56:08 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

module InstructionMemory (
    input  [31:0] Address,      
    output [31:0] Instruction   
);

    reg [31:0] MEM [0 : (2**30) - 1];
    initial begin
        $readmemh("imem.mem", MEM);
    end
    assign Instruction = MEM[Address[31:2]];

endmodule


