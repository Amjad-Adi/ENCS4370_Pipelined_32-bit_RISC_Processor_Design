//-----------------------------------------------------------------------------
//
// Title       : tb_ID_EX_Register
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/tb_ID_EX_Register.v
// Generated   : Tue Jun 16 18:44:52 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------


`timescale 1ns/1ps
 
module tb_ID_EX_Register;
 
  
    reg        Clk, Reset, Flush, Stall;
 	 
    reg [31:0] ID_PC1, ID_BusA, ID_BusB, ID_Imm;
    reg [3:0]  ID_RsAddr, ID_RtAddr, ID_RdAddr;
 
    reg        ID_RegWrite, ID_RegDst, ID_ALUSrc;
    reg        ID_MemRead, ID_MemWrite, ID_MemToReg;
    reg        ID_Branch, ID_Jump, ID_ExtOp;
    reg [2:0]  ID_ALUOp;
 	
    wire [31:0] EX_PC1, EX_BusA, EX_BusB, EX_Imm;
    wire [3:0]  EX_RsAddr, EX_RtAddr, EX_RdAddr;
 	 
    wire        EX_RegWrite, EX_RegDst, EX_ALUSrc;
    wire        EX_MemRead, EX_MemWrite, EX_MemToReg;
    wire        EX_Branch, EX_Jump, EX_ExtOp;
    wire [2:0]  EX_ALUOp;
 				 
    initial Clk = 0;
    always #5 Clk = ~Clk;
 	   
    ID_EX_Register dut (
        .Clk          (Clk),
        .Reset        (Reset),
        .Flush        (Flush),
        .Stall        (Stall),
        .ID_PC1       (ID_PC1),
        .ID_BusA      (ID_BusA),
        .ID_BusB      (ID_BusB),
        .ID_Imm       (ID_Imm),
        .ID_RsAddr    (ID_RsAddr),
        .ID_RtAddr    (ID_RtAddr),
        .ID_RdAddr    (ID_RdAddr),
        .ID_RegWrite  (ID_RegWrite),
        .ID_RegDst    (ID_RegDst),
        .ID_ALUSrc    (ID_ALUSrc),
        .ID_MemRead   (ID_MemRead),
        .ID_MemWrite  (ID_MemWrite),
        .ID_MemToReg  (ID_MemToReg),
        .ID_Branch    (ID_Branch),
        .ID_Jump      (ID_Jump),
        .ID_ExtOp     (ID_ExtOp),
        .ID_ALUOp     (ID_ALUOp),
        .EX_PC1       (EX_PC1),
        .EX_BusA      (EX_BusA),
        .EX_BusB      (EX_BusB),
        .EX_Imm       (EX_Imm),
        .EX_RsAddr    (EX_RsAddr),
        .EX_RtAddr    (EX_RtAddr),
        .EX_RdAddr    (EX_RdAddr),
        .EX_RegWrite  (EX_RegWrite),
        .EX_RegDst    (EX_RegDst),
        .EX_ALUSrc    (EX_ALUSrc),
        .EX_MemRead   (EX_MemRead),
        .EX_MemWrite  (EX_MemWrite),
        .EX_MemToReg  (EX_MemToReg),
        .EX_Branch    (EX_Branch),
        .EX_Jump      (EX_Jump),
        .EX_ExtOp     (EX_ExtOp),
        .EX_ALUOp     (EX_ALUOp)
    );
 			
    task set_inputs;
        input [31:0] pc1, busA, busB, imm;
        input [3:0]  rs, rt, rd;
        input        rw, rdst, alusrc, memr, memw, mem2reg, br, jmp, ext;
        input [2:0]  aluop;
        begin
            ID_PC1      = pc1;
            ID_BusA     = busA;
            ID_BusB     = busB;
            ID_Imm      = imm;
            ID_RsAddr   = rs;
            ID_RtAddr   = rt;
            ID_RdAddr   = rd;
            ID_RegWrite = rw;
            ID_RegDst   = rdst;
            ID_ALUSrc   = alusrc;
            ID_MemRead  = memr;
            ID_MemWrite = memw;
            ID_MemToReg = mem2reg;
            ID_Branch   = br;
            ID_Jump     = jmp;
            ID_ExtOp    = ext;
            ID_ALUOp    = aluop;
        end
    endtask
 				 
    initial begin
        $display("========================================");
        $display("      ID/EX Register Testbench");
        $display("========================================");
 
   
        Reset = 1; Flush = 0; Stall = 0;
        set_inputs(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3'b000);
        @(posedge Clk); #1; Reset = 0;
 				 
        @(negedge Clk);
        set_inputs(
            32'h00000001,   
            32'h00000001,   
            32'h00000002,   
            32'h00000000,   
            4'd1, 4'd2, 4'd3,
            1,0,0,0,0,0,0,0,0,
            3'b000         
        );
        @(posedge Clk); #2;
        if (EX_BusA===32'h1 && EX_BusB===32'h2 && EX_RdAddr===4'd3 && EX_RegWrite===1)
            $display("TEST 1 PASSED | ADD datapath latched correctly");
        else
            $display("TEST 1 FAILED | Datapath latch error");
 
      
        @(negedge Clk);
        set_inputs(
            32'h00000002,   
            32'h00000000,   
            32'h00000000,   
            32'h00000004,   
            4'd0, 4'd11, 4'd11, 
            1,0,1,1,0,1,0,0,1, 
            3'b000
        );
        @(posedge Clk); #2;
        if (EX_ALUSrc===1 && EX_MemRead===1 && EX_MemToReg===1 && EX_RegWrite===1)
            $display("TEST 2 PASSED | LW control signals latched correctly");
        else
            $display("TEST 2 FAILED | Control signal latch error");
 
        // TEST 3: Reset clears everything
        @(negedge Clk); Reset = 1;
        @(posedge Clk); #2;
        if (EX_PC1===0 && EX_BusA===0 && EX_RegWrite===0 && EX_ALUOp===0)
            $display("TEST 3 PASSED | Reset cleared all signals");
        else
            $display("TEST 3 FAILED | Reset did not clear signals");
        @(negedge Clk); Reset = 0;
 
        // TEST 4: Flush inserts bubble
        @(negedge Clk);
        set_inputs(32'h5,32'hAA,32'hBB,32'hCC,4'd5,4'd6,4'd7,1,1,1,1,1,1,1,1,1,3'b111);
        @(posedge Clk); #1;
        @(negedge Clk); Flush = 1;
        set_inputs(32'hFF,32'hFF,32'hFF,32'hFF,4'hF,4'hF,4'hF,1,1,1,1,1,1,1,1,1,3'b111);
        @(posedge Clk); #2;
        if (EX_RegWrite===0 && EX_MemRead===0 && EX_MemWrite===0 && EX_Branch===0)
            $display("TEST 4 PASSED | Flush inserted bubble correctly");
        else
            $display("TEST 4 FAILED | Flush did not clear control signals");
        @(negedge Clk); Flush = 0;
 
        // TEST 5: Stall holds value
        @(negedge Clk);
        set_inputs(32'hA,32'h1,32'h2,32'h0,4'd1,4'd2,4'd3,1,0,0,0,0,0,0,0,0,3'b001);
        @(posedge Clk); #1;
        @(negedge Clk); Stall = 1;
        set_inputs(32'hFF,32'hFF,32'hFF,32'hFF,4'hF,4'hF,4'hF,0,0,0,0,0,0,0,0,0,3'b000);
        @(posedge Clk); #2;
        if (EX_PC1===32'hA && EX_BusA===32'h1 && EX_RdAddr===4'd3)
            $display("TEST 5 PASSED | Stall holds current value");
        else
            $display("TEST 5 FAILED | Stall did not hold value");
        @(negedge Clk); Stall = 0;
 
        // TEST 6: Normal after flush
        @(negedge Clk);
        set_inputs(32'hB,32'h5,32'h3,32'h0,4'd1,4'd2,4'd6,1,0,0,0,0,0,0,0,0,3'b000);
        @(posedge Clk); #2;
        if (EX_PC1===32'hB && EX_BusA===32'h5 && EX_RdAddr===4'd6)
            $display("TEST 6 PASSED | Normal operation after flush");
        else
            $display("TEST 6 FAILED | Normal operation error after flush");
 
        $display("========================================");
        $display("    ID/EX Register Tests Complete");
        $display("========================================");
        $finish;
    end
 
endmodule
