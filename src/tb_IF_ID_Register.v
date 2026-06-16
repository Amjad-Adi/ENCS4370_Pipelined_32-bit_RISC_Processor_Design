//-----------------------------------------------------------------------------
//
// Title       : tb_IF_ID_Register
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/tb_IF_ID_Register.v
// Generated   : Tue Jun 16 18:43:48 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------


`timescale 1ns/1ps
 
module tb_IF_ID_Register;

    reg         Clk, Reset, Flush, Stall;
    reg  [31:0] IF_PC1, IF_Instruction;
    wire [31:0] ID_PC1, ID_Instruction;
 
   
    initial Clk = 0;
    always #5 Clk = ~Clk;
 
   
    IF_ID_Register dut (
        .Clk            (Clk),
        .Reset          (Reset),
        .Flush          (Flush),
        .Stall          (Stall),
        .IF_PC1         (IF_PC1),
        .IF_Instruction (IF_Instruction),
        .ID_PC1         (ID_PC1),
        .ID_Instruction (ID_Instruction)
    );
 
    
    task check;
        input [31:0] exp_PC1;
        input [31:0] exp_Instr;
        input [63:0] test_num;
        begin
            #2;
            if (ID_PC1 === exp_PC1 && ID_Instruction === exp_Instr)
                $display("TEST %0d PASSED | PC1=0x%08h Instr=0x%08h",
                          test_num, ID_PC1, ID_Instruction);
            else
                $display("TEST %0d FAILED | Expected PC1=0x%08h Instr=0x%08h | Got PC1=0x%08h Instr=0x%08h",
                          test_num, exp_PC1, exp_Instr, ID_PC1, ID_Instruction);
        end
    endtask
 
    
    initial begin
        $display("========================================");
        $display("      IF/ID Register Testbench");
        $display("========================================");
 

        Reset = 1; Flush = 0; Stall = 0;
        IF_PC1 = 0; IF_Instruction = 0;
        @(posedge Clk); #1;
        Reset = 0;
 
    
        @(negedge Clk);
        IF_PC1 = 32'h00000001; IF_Instruction = 32'h28400001;
        @(posedge Clk);
        check(32'h00000001, 32'h28400001, 1);
 	 
        @(negedge Clk);
        IF_PC1 = 32'h00000002; IF_Instruction = 32'h28800002;
        @(posedge Clk);
        check(32'h00000002, 32'h28800002, 2);
 	
        @(negedge Clk);
        Reset = 1;
        IF_PC1 = 32'hDEADBEEF; IF_Instruction = 32'hCAFEBABE;
        @(posedge Clk);
        check(32'h00000000, 32'h00000000, 3);
        @(negedge Clk); Reset = 0;

        @(negedge Clk);
        IF_PC1 = 32'h00000005; IF_Instruction = 32'h40410002;
        @(posedge Clk); #1;

        @(negedge Clk); Flush = 1;
        IF_PC1 = 32'h00000006; IF_Instruction = 32'hDEADBEEF;
        @(posedge Clk);
        check(32'h00000000, 32'h00000000, 4);
        @(negedge Clk); Flush = 0;
 
   
        @(negedge Clk);
        IF_PC1 = 32'h0000000A; IF_Instruction = 32'h01848000;
        @(posedge Clk); #1;
       
        @(negedge Clk); Stall = 1;
        IF_PC1 = 32'hFFFFFFFF; IF_Instruction = 32'hFFFFFFFF;
        @(posedge Clk);
        check(32'h0000000A, 32'h01848000, 5); 
        @(negedge Clk); Stall = 0;
 
     
        @(negedge Clk);
        IF_PC1 = 32'h0000000B; IF_Instruction = 32'h03C48000;
        @(posedge Clk);
        check(32'h0000000B, 32'h03C48000, 6);
 
        $display("========================================");
        $display("    IF/ID Register Tests Complete");
        $display("========================================");
        $finish;
    end
 
endmodule
