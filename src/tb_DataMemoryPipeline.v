//-----------------------------------------------------------------------------
//
// Title       : tb_DataMemory_Pipeline
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/tb_DataMemoryPipeline.v
// Generated   : Tue Jun 16 17:42:25 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------
 
`timescale 1ns/1ps
 
module tb_DataMemory_Pipeline;

    reg  Clk;
    reg  [31:0] Address;
    reg  [31:0] WriteData;
    reg  MemWrite;
    reg  MemRead;
    wire [31:0] ReadData;

    initial Clk = 0;
    always #5 Clk = ~Clk;

    DataMemory_Pipeline dut (
        .Clk       (Clk),
        .Address   (Address),
        .WriteData (WriteData),
        .MemWrite  (MemWrite),
        .MemRead   (MemRead),
        .ReadData  (ReadData)
    );

    task mem_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge Clk); 
            #1;           
            Address   = addr;
            WriteData = data;
            MemWrite  = 1;
            MemRead   = 0;
            @(negedge Clk); 
            #1;
            MemWrite = 0;
        end
    endtask

    task mem_read;
        input [31:0] addr;
        begin
            @(negedge Clk); 
            #1;
            Address  = addr;
            MemRead  = 1;
            MemWrite = 0;
            @(posedge Clk);
            #1;            
        end
    endtask
 
    task check;
        input [31:0] expected;
        input [63:0] test_num;
        begin
            #2;
            if (ReadData === expected)
                $display("TEST %0d PASSED | Addr=0x%08h | ReadData=0x%08h",
                          test_num, Address, ReadData);
            else
                $display("TEST %0d FAILED | Addr=0x%08h | Expected=0x%08h Got=0x%08h",
                          test_num, Address, expected, ReadData);
        end
    endtask
 

    initial begin
        $display("================================================");
        $display("      DataMemory_Pipeline Testbench");
        $display("================================================");

        Address   = 0;
        WriteData = 0;
        MemWrite  = 0;
        MemRead   = 0;
        #10;

        $display("-- TEST 1: Write 0xDEADBEEF to Addr 0, read back --");
        mem_write(32'h00000000, 32'hDEADBEEF);
        mem_read(32'h00000000);
        check(32'hDEADBEEF, 1);
 			 
        $display("-- TEST 2: Write 0xCAFEBABE to Addr 4, read back --");
        mem_write(32'h00000004, 32'hCAFEBABE);
        mem_read(32'h00000004);
        check(32'hCAFEBABE, 2);
 											 
        $display("-- TEST 3: Write 0x12345678 to Addr 8, read back --");
        mem_write(32'h00000008, 32'h12345678);
        mem_read(32'h00000008);
        check(32'h12345678, 3);
 										
        $display("-- TEST 4: MemRead=0 should output 0 --");
        @(negedge Clk); #1;
        Address  = 32'h00000000;
        MemRead  = 0;
        MemWrite = 0;
        @(posedge Clk); #2;
        if (ReadData === 32'b0)
            $display("TEST 4  PASSED | MemRead=0 output is 0x%08h", ReadData);
        else
            $display("TEST 4  FAILED | MemRead=0 Expected=0x00000000 Got=0x%08h", ReadData);
 														
        $display("-- TEST 5: MemWrite=0 should not overwrite --");
        @(posedge Clk); #1;
        Address   = 32'h00000000;
        WriteData = 32'hFFFFFFFF;
        MemWrite  = 0;         
        MemRead   = 0;
        @(negedge Clk); #1;
        MemWrite = 0;
     
        mem_read(32'h00000000);
        check(32'hDEADBEEF, 5);
 
        $display("-- TEST 6: Multiple address independence --");
        mem_read(32'h00000004);
        check(32'hCAFEBABE, 6);
 
 
        $display("-- TEST 7: Overwrite address 0 with new value --");
        mem_write(32'h00000000, 32'h000000FF);
        mem_read(32'h00000000);
        check(32'h000000FF, 7);
 
        $display("-- TEST 8: Word address alignment check --");
        mem_read(32'h00000008);
        check(32'h12345678, 8);
 
        $display("================================================");
        $display("   DataMemory_Pipeline Tests Complete");
        $display("================================================");
        $finish;
    end
 
endmodule


