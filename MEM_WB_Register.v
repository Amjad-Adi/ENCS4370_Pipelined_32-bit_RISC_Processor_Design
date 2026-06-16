//-----------------------------------------------------------------------------
//
// Title       : MEM_WB_Register
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/MEM_WB_Register.v
// Generated   : Tue Jun 16 18:39:59 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

module MEM_WB_Register (
    input         Clk,
    input         Reset,
    input         Flush,
    input         Stall,
 
    
    input  [31:0] MEM_ALUResult,    
    input  [31:0] MEM_ReadData,     
    input  [3:0]  MEM_RdAddr,       
 

    input         MEM_RegWrite,    
    input         MEM_MemToReg,   
 

    output reg [31:0] WB_ALUResult,
    output reg [31:0] WB_ReadData,
    output reg [3:0]  WB_RdAddr,
 
   
    output reg        WB_RegWrite,
    output reg        WB_MemToReg
);
 
    always @(posedge Clk) begin
        if (Reset || Flush) begin
            WB_ALUResult <= 32'b0;
            WB_ReadData  <= 32'b0;
            WB_RdAddr    <= 4'b0;
            WB_RegWrite  <= 1'b0;
            WB_MemToReg  <= 1'b0;
        end
        else if (Stall) begin
            WB_ALUResult <= WB_ALUResult;
            WB_ReadData  <= WB_ReadData;
            WB_RdAddr    <= WB_RdAddr;
            WB_RegWrite  <= WB_RegWrite;
            WB_MemToReg  <= WB_MemToReg;
        end
        else begin
            WB_ALUResult <= MEM_ALUResult;
            WB_ReadData  <= MEM_ReadData;
            WB_RdAddr    <= MEM_RdAddr;
            WB_RegWrite  <= MEM_RegWrite;
            WB_MemToReg  <= MEM_MemToReg;
        end
    end
 
endmodule