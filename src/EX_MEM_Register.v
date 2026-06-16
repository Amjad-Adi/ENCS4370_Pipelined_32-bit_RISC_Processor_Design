//-----------------------------------------------------------------------------
//
// Title       : EX_MEM_Register
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/EX_MEM_Register.v
// Generated   : Tue Jun 16 18:36:11 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps


module EX_MEM_Register (
    input         Clk,
    input         Reset,
    input         Flush,
    input         Stall,
 
    input  [31:0] EX_PC1,        
    input  [31:0] EX_ALUResult,     
    input  [31:0] EX_RtData,        
    input  [3:0]  EX_RdAddr,       
    input         EX_Equal,        
 
  
    input         EX_RegWrite,
    input         EX_MemRead,
    input         EX_MemWrite,
    input         EX_MemToReg,
    input         EX_Branch,
    input         EX_Jump,

    output reg [31:0] MEM_PC1,
    output reg [31:0] MEM_ALUResult,
    output reg [31:0] MEM_RtData,
    output reg [3:0]  MEM_RdAddr,
    output reg        MEM_Equal,

    output reg        MEM_RegWrite,
    output reg        MEM_MemRead,
    output reg        MEM_MemWrite,
    output reg        MEM_MemToReg,
    output reg        MEM_Branch,
    output reg        MEM_Jump
);
 
    always @(posedge Clk) begin
        if (Reset || Flush) begin
          
            MEM_PC1       <= 32'b0;
            MEM_ALUResult <= 32'b0;
            MEM_RtData    <= 32'b0;
            MEM_RdAddr    <= 4'b0;
            MEM_Equal     <= 1'b0;
         
            MEM_RegWrite  <= 1'b0;
            MEM_MemRead   <= 1'b0;
            MEM_MemWrite  <= 1'b0;
            MEM_MemToReg  <= 1'b0;
            MEM_Branch    <= 1'b0;
            MEM_Jump      <= 1'b0;
        end
        else if (Stall) begin
        
            MEM_PC1       <= MEM_PC1;
            MEM_ALUResult <= MEM_ALUResult;
            MEM_RtData    <= MEM_RtData;
            MEM_RdAddr    <= MEM_RdAddr;
            MEM_Equal     <= MEM_Equal;
            MEM_RegWrite  <= MEM_RegWrite;
            MEM_MemRead   <= MEM_MemRead;
            MEM_MemWrite  <= MEM_MemWrite;
            MEM_MemToReg  <= MEM_MemToReg;
            MEM_Branch    <= MEM_Branch;
            MEM_Jump      <= MEM_Jump;
        end
        else begin
        
            MEM_PC1       <= EX_PC1;
            MEM_ALUResult <= EX_ALUResult;
            MEM_RtData    <= EX_RtData;
            MEM_RdAddr    <= EX_RdAddr;
            MEM_Equal     <= EX_Equal;
            MEM_RegWrite  <= EX_RegWrite;
            MEM_MemRead   <= EX_MemRead;
            MEM_MemWrite  <= EX_MemWrite;
            MEM_MemToReg  <= EX_MemToReg;
            MEM_Branch    <= EX_Branch;
            MEM_Jump      <= EX_Jump;
        end
    end
 
endmodule