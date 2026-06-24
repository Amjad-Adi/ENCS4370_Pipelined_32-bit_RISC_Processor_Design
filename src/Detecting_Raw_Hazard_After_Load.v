//-----------------------------------------------------------------------------
//
// Title       : Detecting_Raw_Hazard_After_Load
// Design      : ENCS4370_Pipelined_32bit_RISC
// Author      : Hanan Alawawda
// Company     : Birzeit  University
//
//-----------------------------------------------------------------------------
//
// File        : C:/Users/97059/OneDrive/Desktop/Arc_pro/Arch_pro/ENCS4370_Pipelined_32bit_RISC/src/Detecting_Raw_Hazard_After_Load.v
// Generated   : Tue Jun 23 18:55:36 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps

module PC_Control_For_Pipelined_Jump_And_Branch(

    input  BEQ,
    input  BNE,
    input  J,
    input  Zero,

    output Br,
    output Jmp,
    output Kill1,
    output Kill2,
    output [1:0] PCSrc

);

    // Branch is taken for:
    // BEQ when Zero = 1
    // BNE when Zero = 0
    assign Br = (BEQ & Zero) | (BNE & ~Zero);

    // Jump only if branch is not taken
    assign Jmp = J & ~Br;

    // Flush signals
    assign Kill1 = J | Br;
    assign Kill2 = Br;

    // PC Source
    // 00 : PC + 1
    // 01 : Jump
    // 10 : Branch
    assign PCSrc = {Br, Jmp};

endmodule
