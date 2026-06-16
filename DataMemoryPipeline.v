//-----------------------------------------------------------------------------
//
// Title       : DataMemory_Pipeline
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/DataMemoryPipeline.v
// Generated   : Tue Jun 16 17:24:11 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps
 
module DataMemory_Pipeline (
    input         Clk,        
    input  [31:0] Address,     
    input  [31:0] WriteData,   
    input         MemWrite,    
    input         MemRead,     
    output reg [31:0] ReadData  
);
 

    reg [31:0] MEM [0:1023];

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            MEM[i] = 32'b0;
        $readmemh("dmem.mem", MEM);
    end
 

    always @(posedge Clk) begin
        if (MemRead) begin
            ReadData <= MEM[Address[31:2] & 32'h000003FF]; 
        end else begin
            ReadData <= 32'b0;
        end
    end
 
    always @(negedge Clk) begin
        if (MemWrite) begin
            MEM[Address[31:2] & 32'h000003FF] <= WriteData;
        end
    end
 
endmodule