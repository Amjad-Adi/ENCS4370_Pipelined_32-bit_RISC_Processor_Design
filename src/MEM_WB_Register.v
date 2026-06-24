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
 
    
    input  [31:0] ALUResult_EXMEM,    
    input  [31:0] ReadData_EXMEM,     
    input  [3:0]  WriteRegister_EXMEM,       
 

    input         RegWrite_EXMEM,    
    input         MemToReg_EXMEM,   
 

    output reg [31:0] ALUResult_MEMWB,
    output reg [31:0] ReadData_MEMWB,
    output reg [3:0]  WriteRegister_MEMWB,
 
   
    output reg        RegWrite_MEMWB  ,
    output reg        MemToReg_MEMWB
);
 
    always @(posedge Clk) begin
        if (Reset || Flush) begin
            ALUResult_MEMWB <= 32'b0;
            ReadData_MEMWB  <= 32'b0;
            WriteRegister_MEMWB    <= 4'b0;
            RegWrite_MEMWB  <= 1'b0;
            MemToReg_MEMWB  <= 1'b0;
        end
        else if (Stall) begin
            ALUResult_MEMWB <= ALUResult_MEMWB;
            ReadData_MEMWB  <= ReadData_MEMWB;
            WriteRegister_MEMWB    <= WriteRegister_MEMWB;
            RegWrite_MEMWB  <= RegWrite_MEMWB;
            MemToReg_MEMWB  <= MemToReg_MEMWB;
        end
        else begin
            ALUResult_MEMWB <= ALUResult_EXMEM;
            ReadData_MEMWB  <= ReadData_EXMEM;
            WriteRegister_MEMWB    <= WriteRegister_EXMEM;
            RegWrite_MEMWB  <= RegWrite_EXMEM;
            MemToReg_MEMWB <= MemToReg_EXMEM;
        end
    end
 
endmodule