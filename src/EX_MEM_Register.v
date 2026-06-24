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
 
    input  [31:0] PCPlus1_IDEX,        
    input  [31:0] ALUResult_IDEX,     
    input  [31:0] BusB_IDEX,        
    input  [3:0]  WriteRegister_IDEX,       
    input         Equal_IDEX,        
 
  
    input         RegWrite_IDEX,
    input         MemRead_IDEX,
    input         MemWrite_IDEX,
    input         MemToReg_IDEX,
    input         Branch_IDEX,
    input         Jump_IDEX,

    output reg [31:0] PCPlus1_EXMEM,
    output reg [31:0] ALUResult_EXMEM,
    output reg [31:0] BusB_EXMEM,
    output reg [3:0]  WriteRegister_EXMEM,
    output reg        Equal_EXMEM,

    output reg        RegWrite_EXMEM,
    output reg        MemRead_EXMEM,
    output reg        MemWrite_EXMEM,
    output reg        MemToReg_EXMEM,
    output reg        Branch_EXMEM,
    output reg        Jump_EXMEM
);
 
    always @(posedge Clk) begin
        if (Reset || Flush) begin
          
            PCPlus1_EXMEM       <= 32'b0;
            ALUResult_EXMEM <= 32'b0;
            BusB_EXMEM    <= 32'b0;
            WriteRegister_EXMEM    <= 4'b0;
            Equal_EXMEM     <= 1'b0;
         
            RegWrite_EXMEM  <= 1'b0;
            MemRead_EXMEM   <= 1'b0;
            MemWrite_EXMEM  <= 1'b0;
            MemToReg_EXMEM  <= 1'b0;
            Branch_EXMEM    <= 1'b0;
            Jump_EXMEM      <= 1'b0;
        end
        else if (Stall) begin
        
            PCPlus1_EXMEM       <= PCPlus1_EXMEM;
            ALUResult_EXMEM <= ALUResult_EXMEM;
            BusB_EXMEM    <= BusB_EXMEM;
            WriteRegister_EXMEM    <= WriteRegister_EXMEM;
            Equal_EXMEM     <= Equal_EXMEM;
            RegWrite_EXMEM  <= RegWrite_EXMEM;
            MemRead_EXMEM   <= MemRead_EXMEM;
            MemWrite_EXMEM  <= MemWrite_EXMEM;
            MemToReg_EXMEM  <= MemToReg_EXMEM;
            Branch_EXMEM    <= Branch_EXMEM;
            Jump_EXMEM      <= Jump_EXMEM;
        end
        else begin
        
            PCPlus1_EXMEM       <= PCPlus1_IDEX ;
            ALUResult_EXMEM <=  ALUResult_IDEX;
            BusB_EXMEM    <= BusB_IDEX;
            WriteRegister_EXMEM    <= WriteRegister_IDEX;
            Equal_EXMEM     <= Equal_IDEX;
            RegWrite_EXMEM  <= RegWrite_IDEX;
            MemRead_EXMEM <= MemRead_IDEX;
            MemWrite_EXMEM <= MemWrite_IDEX;
            MemToReg_EXMEM  <= MemToReg_IDEX;
           Branch_EXMEM <= Branch_IDEX;
            Jump_EXMEM      <= Jump_IDEX;
        end
    end
 
endmodule