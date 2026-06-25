//-----------------------------------------------------------------------------
//
// Title       : RAW_Hazard_Detection
// Design      : ENCS4370_Pipelined_32bit_RISC
// Author      : Hanan Alawawda
// Company     : Birzeit  University
//
//-----------------------------------------------------------------------------
//
// File        : C:/Users/97059/OneDrive/Desktop/Arc_pro/Arch_pro/ENCS4370_Pipelined_32bit_RISC/src/RAW_Hazard_Detection.v
// Generated   : Tue Jun 23 18:53:31 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1 ns / 1 ps

//{{ Section below this comment is automatically maintained
//    and may be overwritten
//{module {RAW_Hazard_Detection}}
module ForwardingUnit(
    input  wire [3:0] RA,
    input  wire [3:0] RB,
    input  wire [3:0] Rd2,
    input  wire [3:0] Rd3,
    input  wire [3:0] Rd4,
    input  wire       EX_RegWr,
    input  wire       MEM_RegWr,
    input  wire       WB_RegWr,
    input  wire       EX_MemRd,
    output reg  [1:0] ForwardA,
    output reg  [1:0] ForwardB,
    output wire       Stall
);

    always @(*) begin
        if      ((RA != 4'b0) && (RA == Rd2) && EX_RegWr)  ForwardA = 2'd1;
        else if ((RA != 4'b0) && (RA == Rd3) && MEM_RegWr) ForwardA = 2'd2;
        else if ((RA != 4'b0) && (RA == Rd4) && WB_RegWr)  ForwardA = 2'd3;
        else                                                  ForwardA = 2'd0;

        if      ((RB != 4'b0) && (RB == Rd2) && EX_RegWr)  ForwardB = 2'd1;
        else if ((RB != 4'b0) && (RB == Rd3) && MEM_RegWr) ForwardB = 2'd2;
        else if ((RB != 4'b0) && (RB == Rd4) && WB_RegWr)  ForwardB = 2'd3;
        else                                                  ForwardB = 2'd0;
    end

    assign Stall = (EX_MemRd == 1'b1) && ((ForwardA == 2'd1) || (ForwardB == 2'd1));

endmodule

