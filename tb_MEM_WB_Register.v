//-----------------------------------------------------------------------------
//
// Title       : tb_MEM_WB_Register
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/tb_MEM_WB_Register.v
// Generated   : Tue Jun 16 18:46:57 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ns/1ps
 
module tb_MEM_WB_Register;
 
    // -------------------------
    // DUT signals
    // -------------------------
    reg        Clk, Reset, Flush, Stall;
    reg [31:0] MEM_ALUResult, MEM_ReadData;
    reg [3:0]  MEM_RdAddr;
    reg        MEM_RegWrite, MEM_MemToReg;
 
    wire [31:0] WB_ALUResult, WB_ReadData;
    wire [3:0]  WB_RdAddr;
    wire        WB_RegWrite, WB_MemToReg;
 
    // -------------------------
    // Clock
    // -------------------------
    initial Clk = 0;
    always #5 Clk = ~Clk;
 
    // -------------------------
    // Instantiate DUT
    // -------------------------
    MEM_WB_Register dut (
        .Clk            (Clk),
        .Reset          (Reset),
        .Flush          (Flush),
        .Stall          (Stall),
        .MEM_ALUResult  (MEM_ALUResult),
        .MEM_ReadData   (MEM_ReadData),
        .MEM_RdAddr     (MEM_RdAddr),
        .MEM_RegWrite   (MEM_RegWrite),
        .MEM_MemToReg   (MEM_MemToReg),
        .WB_ALUResult   (WB_ALUResult),
        .WB_ReadData    (WB_ReadData),
        .WB_RdAddr      (WB_RdAddr),
        .WB_RegWrite    (WB_RegWrite),
        .WB_MemToReg    (WB_MemToReg)
    );
 
    // -------------------------
    // Task: check outputs
    // -------------------------
    task check;
        input [31:0] exp_ALU, exp_RD;
        input [3:0]  exp_Rd;
        input        exp_RW, exp_M2R;
        input [63:0] test_num;
        begin
            #2;
            if (WB_ALUResult===exp_ALU && WB_ReadData===exp_RD &&
                WB_RdAddr===exp_Rd && WB_RegWrite===exp_RW && WB_MemToReg===exp_M2R)
                $display("TEST %0d PASSED | ALU=0x%08h RD=0x%08h Rd=%0d RW=%b M2R=%b",
                          test_num, WB_ALUResult, WB_ReadData, WB_RdAddr, WB_RegWrite, WB_MemToReg);
            else
                $display("TEST %0d FAILED | Expected ALU=0x%08h RD=0x%08h | Got ALU=0x%08h RD=0x%08h",
                          test_num, exp_ALU, exp_RD, WB_ALUResult, WB_ReadData);
        end
    endtask
 
    // -------------------------
    // Test stimulus
    // -------------------------
    initial begin
        $display("========================================");
        $display("     MEM/WB Register Testbench");
        $display("========================================");
 
        // Initialize
        Reset=1; Flush=0; Stall=0;
        MEM_ALUResult=0; MEM_ReadData=0;
        MEM_RdAddr=0; MEM_RegWrite=0; MEM_MemToReg=0;
        @(posedge Clk); #1; Reset=0;
 
        // TEST 1: R-type writeback (ADD result)
        // MemToReg=0 ? write ALU result to register
        @(negedge Clk);
        MEM_ALUResult=32'h8; MEM_ReadData=32'h0;
        MEM_RdAddr=4'd8; MEM_RegWrite=1; MEM_MemToReg=0;
        @(posedge Clk);
        check(32'h8, 32'h0, 4'd8, 1, 0, 1);
 
        // TEST 2: LW writeback (memory read data)
        // MemToReg=1 ? write memory data to register
        @(negedge Clk);
        MEM_ALUResult=32'h0; MEM_ReadData=32'h64;
        MEM_RdAddr=4'd11; MEM_RegWrite=1; MEM_MemToReg=1;
        @(posedge Clk);
        check(32'h0, 32'h64, 4'd11, 1, 1, 2);
 
        // TEST 3: SW — no writeback (RegWrite=0)
        @(negedge Clk);
        MEM_ALUResult=32'h0; MEM_ReadData=32'h0;
        MEM_RdAddr=4'd0; MEM_RegWrite=0; MEM_MemToReg=0;
        @(posedge Clk);
        check(32'h0, 32'h0, 4'd0, 0, 0, 3);
 
        // TEST 4: Reset clears everything
        @(negedge Clk);
        MEM_ALUResult=32'hFF; MEM_ReadData=32'hAA;
        MEM_RdAddr=4'd5; MEM_RegWrite=1; MEM_MemToReg=1;
        @(posedge Clk); #1;
        @(negedge Clk); Reset=1;
        @(posedge Clk);
        check(32'h0, 32'h0, 4'd0, 0, 0, 4);
        @(negedge Clk); Reset=0;
 
        // TEST 5: Flush clears everything
        @(negedge Clk);
        MEM_ALUResult=32'hBB; MEM_ReadData=32'hCC;
        MEM_RdAddr=4'd3; MEM_RegWrite=1; MEM_MemToReg=0;
        @(posedge Clk); #1;
        @(negedge Clk); Flush=1;
        MEM_ALUResult=32'hDD; MEM_RegWrite=1;
        @(posedge Clk);
        check(32'h0, 32'h0, 4'd0, 0, 0, 5);
        @(negedge Clk); Flush=0;
 
        // TEST 6: Stall holds current value
        @(negedge Clk);
        MEM_ALUResult=32'hCAFE; MEM_ReadData=32'hBEEF;
        MEM_RdAddr=4'd6; MEM_RegWrite=1; MEM_MemToReg=1;
        @(posedge Clk); #1;
        @(negedge Clk); Stall=1;
        MEM_ALUResult=32'hDEAD; MEM_ReadData=32'h0;
        MEM_RdAddr=4'hF; MEM_RegWrite=0; MEM_MemToReg=0;
        @(posedge Clk);
        check(32'hCAFE, 32'hBEEF, 4'd6, 1, 1, 6);
        @(negedge Clk); Stall=0;
 
        $display("========================================");
        $display("   MEM/WB Register Tests Complete");
        $display("========================================");
        $finish;
    end
 
endmodule