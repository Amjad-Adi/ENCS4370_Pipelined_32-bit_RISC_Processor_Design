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
    input  [3:0] Rs,
    input  [3:0] Rt,

    input  [3:0] EX_Rd,
    input        EX_RegWr,

    input  [3:0] MEM_Rd,
    input        MEM_RegWr,

    input  [3:0] WB_Rd,
    input        WB_RegWr,

    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

always @(*) begin
    // Default values
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    // ForwardA Logic
    if ((Rs != 4'b0000) && (Rs == EX_Rd) && EX_RegWr)
        ForwardA = 2'b01;
    else if ((Rs != 4'b0000) && (Rs == MEM_Rd) && MEM_RegWr)
        ForwardA = 2'b10;
    else if ((Rs != 4'b0000) && (Rs == WB_Rd) && WB_RegWr)
        ForwardA = 2'b11;
    else
        ForwardA = 2'b00;

    // ForwardB Logic
    if ((Rt != 4'b0000) && (Rt == EX_Rd) && EX_RegWr)
        ForwardB = 2'b01;
    else if ((Rt != 4'b0000) && (Rt == MEM_Rd) && MEM_RegWr)
        ForwardB = 2'b10;
    else if ((Rt != 4'b0000) && (Rt == WB_Rd) && WB_RegWr)
        ForwardB = 2'b11;
    else
        ForwardB = 2'b00;
end

endmodule