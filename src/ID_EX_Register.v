//-----------------------------------------------------------------------------
//
// Title       : ID_EX_Register
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/ID_EX_Register.v
// Generated   : Tue Jun 16 18:33:09 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps


module ID_EX_Register (
    input Clk,
    input Reset,
    input Flush,       
    input Stall,   
 
    input  [31:0] ID_PC1,       
    input  [31:0] ID_BusA,     
    input  [31:0] ID_BusB,      
    input  [31:0] ID_Imm,      
    input  [3:0]  ID_RsAddr,   
    input  [3:0]  ID_RtAddr,    
    input  [3:0]  ID_RdAddr,   
 
    
    input  ID_RegWrite,
    input  ID_RegDst,
    input  ID_ALUSrc,
    input  ID_MemRead,
    input  ID_MemWrite,
    input  ID_MemToReg,
    input  ID_Branch,
    input  ID_Jump,
    input  ID_ExtOp,
    input  [2:0]  ID_ALUOp,
 
    output reg [31:0] EX_PC1,
    output reg [31:0] EX_BusA,
    output reg [31:0] EX_BusB,
    output reg [31:0] EX_Imm,
    output reg [3:0]  EX_RsAddr,
    output reg [3:0]  EX_RtAddr,
    output reg [3:0]  EX_RdAddr,

    output reg  	  EX_RegWrite,
    output reg        EX_RegDst,
    output reg        EX_ALUSrc,
    output reg        EX_MemRead,
    output reg        EX_MemWrite,
    output reg        EX_MemToReg,
    output reg        EX_Branch,
    output reg        EX_Jump,
    output reg        EX_ExtOp,
    output reg [2:0]  EX_ALUOp
);
 
    always @(posedge Clk) begin
        if (Reset || Flush) begin
           
            EX_PC1      <= 32'b0;
            EX_BusA     <= 32'b0;
            EX_BusB     <= 32'b0;
            EX_Imm      <= 32'b0;
            EX_RsAddr   <= 4'b0;
            EX_RtAddr   <= 4'b0;
            EX_RdAddr   <= 4'b0;
            EX_RegWrite <= 1'b0;
            EX_RegDst   <= 1'b0;
            EX_ALUSrc   <= 1'b0;
            EX_MemRead  <= 1'b0;
            EX_MemWrite <= 1'b0;
            EX_MemToReg <= 1'b0;
            EX_Branch   <= 1'b0;
            EX_Jump     <= 1'b0;
            EX_ExtOp    <= 1'b0;
            EX_ALUOp    <= 3'b0;
        end
        else if (Stall) begin
            EX_PC1      <= EX_PC1;
            EX_BusA     <= EX_BusA;
            EX_BusB     <= EX_BusB;
            EX_Imm      <= EX_Imm;
            EX_RsAddr   <= EX_RsAddr;
            EX_RtAddr   <= EX_RtAddr;
            EX_RdAddr   <= EX_RdAddr;
            EX_RegWrite <= EX_RegWrite;
            EX_RegDst   <= EX_RegDst;
            EX_ALUSrc   <= EX_ALUSrc;
            EX_MemRead  <= EX_MemRead;
            EX_MemWrite <= EX_MemWrite;
            EX_MemToReg <= EX_MemToReg;
            EX_Branch   <= EX_Branch;
            EX_Jump     <= EX_Jump;
            EX_ExtOp    <= EX_ExtOp;
            EX_ALUOp    <= EX_ALUOp;
        end
        else begin
            EX_PC1      <= ID_PC1;
            EX_BusA     <= ID_BusA;
            EX_BusB     <= ID_BusB;
            EX_Imm      <= ID_Imm;
            EX_RsAddr   <= ID_RsAddr;
            EX_RtAddr   <= ID_RtAddr;
            EX_RdAddr   <= ID_RdAddr;
            EX_RegWrite <= ID_RegWrite;
            EX_RegDst   <= ID_RegDst;
            EX_ALUSrc   <= ID_ALUSrc;
            EX_MemRead  <= ID_MemRead;
            EX_MemWrite <= ID_MemWrite;
            EX_MemToReg <= ID_MemToReg;
            EX_Branch   <= ID_Branch;
            EX_Jump     <= ID_Jump;
            EX_ExtOp    <= ID_ExtOp;
            EX_ALUOp    <= ID_ALUOp;
        end
    end
 
endmodule