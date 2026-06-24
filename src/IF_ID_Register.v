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
 
    input  [31:0] PCPlus1_IF,           
    input  [31:0] Instruction_IF,  
 
   
    output reg [31:0] PCPlus1_IFID,           
    output reg [31:0] Instruction_IFID   
);
 
    always @(posedge Clk) begin
        if (Reset || Flush) begin
            PCPlus1_IFID        <= 32'b0;
            Instruction_IFID <= 32'b0;
        end
        else if (Stall) begin
            PCPlus1_IFID        <= PCPlus1_IFID ;
            Instruction_IFID <= Instruction_IFID;
        end
        else begin
            PCPlus1_IFID        <= PCPlus1_IF;
            Instruction_IFID <= Instruction_IF;
        end
    end
 
endmodule
