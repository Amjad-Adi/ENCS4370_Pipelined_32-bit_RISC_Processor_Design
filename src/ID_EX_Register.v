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
 
    input  [31:0] PCPlus1_IFID,       
    input  [31:0] BusA_IFID,     
    input  [31:0] BusB_IFID,      
    input  [31:0] Immediate_IFID,      
    input  [3:0]  ReadRegisterA_IFID,   
    input  [3:0]  ReadRegisterB_IFID,    
    input  [3:0]  WriteRegister_IFID,   
 
    
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
 
    output reg [31:0] PCPlus1_IDEX,
    output reg [31:0] BusA_IDEX,
    output reg [31:0] BusB_IDEX,
    output reg [31:0] Immediate_IDEX,
    output reg [3:0]  ReadRegisterA_IDEX,
    output reg [3:0]  ReadRegisterB_IDEX,
    output reg [3:0]  WriteRegister_IDEX,

    output reg  	  EX_RegWrite,
    output reg        EX_RegDst,
    output reg        EX_ALUSrc,
    output reg        EX_MemRead,
    output reg        EX_MemWrite,
    output reg        EX_MemToReg,
    output reg        EX_Branch,
    output reg        EX_Jump,
    output reg        EX_ExtOp,
    output reg [2:0]  ALUOp_IDEX
);
 
    always @(posedge Clk) begin
        if (Reset || Flush) begin
           
            PCPlus1_IDEX      <= 32'b0;
            BusA_IDEX     <= 32'b0;
            BusB_IDEX     <= 32'b0;
            Immediate_IDEX      <= 32'b0;
            ReadRegisterA_IDEX   <= 4'b0;
            ReadRegisterB_IDEX   <= 4'b0;
            WriteRegister_IDEX   <= 4'b0;
            EX_RegWrite <= 1'b0;
            EX_RegDst   <= 1'b0;
            EX_ALUSrc   <= 1'b0;
            EX_MemRead  <= 1'b0;
            EX_MemWrite <= 1'b0;
            EX_MemToReg <= 1'b0;
            EX_Branch   <= 1'b0;
            EX_Jump     <= 1'b0;
            EX_ExtOp    <= 1'b0;
            ALUOp_IDEX    <= 3'b0;
        end
        else if (Stall) begin
            PCPlus1_IDEX      <= PCPlus1_IDEX;
            BusA_IDEX     <= BusA_IDEX;
            BusB_IDEX     <= BusB_IDEX;
            Immediate_IDEX      <= Immediate_IDEX;
            ReadRegisterA_IDEX   <= ReadRegisterA_IDEX;
            ReadRegisterB_IDEX   <= ReadRegisterB_IDEX;
            WriteRegister_IDEX   <= WriteRegister_IDEX;
            EX_RegWrite <= EX_RegWrite;
            EX_RegDst   <= EX_RegDst;
            EX_ALUSrc   <= EX_ALUSrc;
            EX_MemRead  <= EX_MemRead;
            EX_MemWrite <= EX_MemWrite;
            EX_MemToReg <= EX_MemToReg;
            EX_Branch   <= EX_Branch;
            EX_Jump     <= EX_Jump;
            EX_ExtOp    <= EX_ExtOp;
            ALUOp_IDEX    <= ALUOp_IDEX;
        end
        else begin
            PCPlus1_IDEX      <= PCPlus1_IFID;
            BusA_IDEX     <= BusA_IFID;
            BusB_IDEX     <= BusB_IFID;
            Immediate_IDEX      <= Immediate_IFID;
            ReadRegisterA_IDEX   <= ReadRegisterA_IFID;
            ReadRegisterB_IDEX   <=ReadRegisterB_IFID;
            WriteRegister_IDEX   <= WriteRegister_IFID;
            EX_RegWrite <= ID_RegWrite;
            EX_RegDst   <= ID_RegDst;
            EX_ALUSrc   <= ID_ALUSrc;
            EX_MemRead  <= ID_MemRead;
            EX_MemWrite <= ID_MemWrite;
            EX_MemToReg <= ID_MemToReg;
            EX_Branch   <= ID_Branch;
            EX_Jump     <= ID_Jump;
            EX_ExtOp    <= ID_ExtOp;
            ALUOp_IDEX    <= ID_ALUOp;
        end
    end
 
endmodule