//-----------------------------------------------------------------------------
//
// Title       : \_IF_ID_Register\ 
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/IF_ID_Register.v
// Generated   : Tue Jun 16 18:30:45 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps


module IF_ID_Register (
    input         Clk,              
    input         Reset,            
    input         Flush,          
    input         Stall,           
 
    input  [31:0] IF_PC1,           
    input  [31:0] IF_Instruction,  
 
   
    output reg [31:0] ID_PC1,           
    output reg [31:0] ID_Instruction   
);
 
    always @(posedge Clk) begin
        if (Reset || Flush) begin
            ID_PC1        <= 32'b0;
            ID_Instruction <= 32'b0;
        end
        else if (Stall) begin
            ID_PC1        <= ID_PC1;
            ID_Instruction <= ID_Instruction;
        end
        else begin
            ID_PC1        <= IF_PC1;
            ID_Instruction <= IF_Instruction;
        end
    end
 
endmodule
