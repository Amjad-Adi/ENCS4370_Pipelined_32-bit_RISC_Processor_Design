//-----------------------------------------------------------------------------
//
// Title       : tb_EX_MEM_Register
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/tb_EX_MEM_Register.v
// Generated   : Tue Jun 16 18:46:31 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------


`timescale 1ns/1ps
 
module tb_EX_MEM_Register;
 
    // -------------------------
    // DUT signals
    // -------------------------
    reg        Clk, Reset, Flush, Stall;
    reg [31:0] EX_PC1, EX_ALUResult, EX_RtData;
    reg [3:0]  EX_RdAddr;
    reg        EX_Equal;
    reg        EX_RegWrite, EX_MemRead, EX_MemWrite;
    reg        EX_MemToReg, EX_Branch, EX_Jump;
 
    wire [31:0] MEM_PC1, MEM_ALUResult, MEM_RtData;
    wire [3:0]  MEM_RdAddr;
    wire        MEM_Equal;
    wire        MEM_RegWrite, MEM_MemRead, MEM_MemWrite;
    wire        MEM_MemToReg, MEM_Branch, MEM_Jump;
 
    // -------------------------
    // Clock
    // -------------------------
    initial Clk = 0;
    always #5 Clk = ~Clk;
 
    // -------------------------
    // Instantiate DUT
    // -------------------------
    EX_MEM_Register dut (
        .Clk           (Clk),
        .Reset         (Reset),
        .Flush         (Flush),
        .Stall         (Stall),
        .EX_PC1        (EX_PC1),
        .EX_ALUResult  (EX_ALUResult),
        .EX_RtData     (EX_RtData),
        .EX_RdAddr     (EX_RdAddr),
        .EX_Equal      (EX_Equal),
        .EX_RegWrite   (EX_RegWrite),
        .EX_MemRead    (EX_MemRead),
        .EX_MemWrite   (EX_MemWrite),
        .EX_MemToReg   (EX_MemToReg),
        .EX_Branch     (EX_Branch),
        .EX_Jump       (EX_Jump),
        .MEM_PC1       (MEM_PC1),
        .MEM_ALUResult (MEM_ALUResult),
        .MEM_RtData    (MEM_RtData),
        .MEM_RdAddr    (MEM_RdAddr),
        .MEM_Equal     (MEM_Equal),
        .MEM_RegWrite  (MEM_RegWrite),
        .MEM_MemRead   (MEM_MemRead),
        .MEM_MemWrite  (MEM_MemWrite),
        .MEM_MemToReg  (MEM_MemToReg),
        .MEM_Branch    (MEM_Branch),
        .MEM_Jump      (MEM_Jump)
    );
 
    // -------------------------
    // Test stimulus
    // -------------------------
    initial begin
        $display("========================================");
        $display("     EX/MEM Register Testbench");
        $display("========================================");
 
        // Initialize
        Reset=1; Flush=0; Stall=0;
        EX_PC1=0; EX_ALUResult=0; EX_RtData=0;
        EX_RdAddr=0; EX_Equal=0;
        EX_RegWrite=0; EX_MemRead=0; EX_MemWrite=0;
        EX_MemToReg=0; EX_Branch=0; EX_Jump=0;
        @(posedge Clk); #1; Reset=0;
 
        // TEST 1: Normal latch — ADD result
        @(negedge Clk);
        EX_PC1=32'h3; EX_ALUResult=32'h8; EX_RtData=32'h0;
        EX_RdAddr=4'd8; EX_Equal=0;
        EX_RegWrite=1; EX_MemRead=0; EX_MemWrite=0;
        EX_MemToReg=0; EX_Branch=0; EX_Jump=0;
        @(posedge Clk); #2;
        if (MEM_ALUResult===32'h8 && MEM_RdAddr===4'd8 && MEM_RegWrite===1)
            $display("TEST 1 PASSED | ADD result latched correctly");
        else
            $display("TEST 1 FAILED | ADD result latch error");
 
        // TEST 2: SW instruction signals
        @(negedge Clk);
        EX_PC1=32'h4; EX_ALUResult=32'h0; EX_RtData=32'h8;
        EX_RdAddr=4'd0; EX_Equal=0;
        EX_RegWrite=0; EX_MemRead=0; EX_MemWrite=1;
        EX_MemToReg=0; EX_Branch=0; EX_Jump=0;
        @(posedge Clk); #2;
        if (MEM_RtData===32'h8 && MEM_MemWrite===1 && MEM_RegWrite===0)
            $display("TEST 2 PASSED | SW control signals latched correctly");
        else
            $display("TEST 2 FAILED | SW control signal error");
 
        // TEST 3: BEQ with Equal=1
        @(negedge Clk);
        EX_PC1=32'h5; EX_ALUResult=32'h0; EX_RtData=32'h0;
        EX_RdAddr=4'd0; EX_Equal=1;
        EX_RegWrite=0; EX_MemRead=0; EX_MemWrite=0;
        EX_MemToReg=0; EX_Branch=1; EX_Jump=0;
        @(posedge Clk); #2;
        if (MEM_Equal===1 && MEM_Branch===1)
            $display("TEST 3 PASSED | BEQ Equal signal latched correctly");
        else
            $display("TEST 3 FAILED | BEQ Equal signal error");
 
        // TEST 4: Reset clears everything
        @(negedge Clk); Reset=1;
        @(posedge Clk); #2;
        if (MEM_ALUResult===0 && MEM_RegWrite===0 && MEM_Equal===0 && MEM_Branch===0)
            $display("TEST 4 PASSED | Reset cleared all signals");
        else
            $display("TEST 4 FAILED | Reset did not clear signals");
        @(negedge Clk); Reset=0;
 
        // TEST 5: Flush inserts bubble
        @(negedge Clk);
        EX_ALUResult=32'hFF; EX_RdAddr=4'd5;
        EX_RegWrite=1; EX_MemWrite=1; EX_Branch=1;
        @(posedge Clk); #1;
        @(negedge Clk); Flush=1;
        EX_ALUResult=32'hAA; EX_RegWrite=1; EX_Branch=1;
        @(posedge Clk); #2;
        if (MEM_RegWrite===0 && MEM_MemWrite===0 && MEM_Branch===0)
            $display("TEST 5 PASSED | Flush inserted bubble correctly");
        else
            $display("TEST 5 FAILED | Flush did not clear control signals");
        @(negedge Clk); Flush=0;
 
        // TEST 6: Stall holds value
        @(negedge Clk);
        EX_ALUResult=32'hCAFE; EX_RdAddr=4'd7; EX_RegWrite=1;
        EX_MemRead=0; EX_MemWrite=0; EX_Branch=0;
        @(posedge Clk); #1;
        @(negedge Clk); Stall=1;
        EX_ALUResult=32'hDEAD; EX_RdAddr=4'hF; EX_RegWrite=0;
        @(posedge Clk); #2;
        if (MEM_ALUResult===32'hCAFE && MEM_RdAddr===4'd7 && MEM_RegWrite===1)
            $display("TEST 6 PASSED | Stall holds current value");
        else
            $display("TEST 6 FAILED | Stall did not hold value");
        @(negedge Clk); Stall=0;
 
        $display("========================================");
        $display("   EX/MEM Register Tests Complete");
        $display("========================================");
        $finish;
    end
 
endmodule