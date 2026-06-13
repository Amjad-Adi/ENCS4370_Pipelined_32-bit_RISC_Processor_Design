//-----------------------------------------------------------------------------
//
// Title       : Datamemory
// Design      : SPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/SPA/SPA/src/Datamemory.v
// Generated   : Sat Jun 13 21:06:42 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

module DataMemory (
    input  Clk,          
    input  [31:0] Address,      
    input  [31:0] WriteData,    
    input  MemWrite,     
    input  MemRead,      
    output [31:0] ReadData      
);

    reg [31:0] MEM [0 : (2**30) - 1];
    initial begin
        $readmemh("dmem.mem", MEM);
    end

    assign ReadData = (MemRead) ? MEM[Address[31:2]] : 32'b0;

    always @(posedge Clk) begin
        if (MemWrite) begin
            MEM[Address[31:2]] <= WriteData;
        end
    end

endmodule