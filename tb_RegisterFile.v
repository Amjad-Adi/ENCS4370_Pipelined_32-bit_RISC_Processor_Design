//-----------------------------------------------------------------------------
//
// Title       : tb_RegisterFile
// Design      : SPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/SPA/SPA/src/tb_RegisterFile.v
// Generated   : Sun Jun 14 00:31:32 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps
 
module tb_RegisterFile;
 
    reg Clk;
    reg RegWrite;
    reg [3:0] RdAddr;
    reg [3:0] RsAddr;
    reg [3:0] RtAddr;
    reg [31:0] WriteData;
    wire [31:0] RsData;
    wire [31:0] RtData;
  
    initial Clk = 0;
    always #5 Clk = ~Clk;
 
    
    RegisterFile dut (
        .Clk(Clk),
        .RegWrite(RegWrite),
        .RdAddr(RdAddr),
        .RsAddr(RsAddr),
        .RtAddr(RtAddr),
        .WriteData(WriteData),
        .RsData(RsData),
        .RtData(RtData)
    );
  
    task write_reg;
        input [3:0]  addr;
        input [31:0] data;
        begin
            @(negedge Clk); 
            RegWrite  = 1;
            RdAddr    = addr;
            WriteData = data;
            @(posedge Clk); 
            #1;             
            RegWrite  = 0;
        end
    endtask
   
    task check_Rs;
        input [3:0]  addr;
        input [31:0] expected;
        input [63:0] test_num;
        begin
            RsAddr = addr;
            #5;
            if (RsData === expected)
                $display("TEST %0d PASSED | Read R%0d via Rs | Got=0x%08h", 
                          test_num, addr, RsData);
            else
                $display("TEST %0d FAILED | Read R%0d via Rs | Expected=0x%08h Got=0x%08h", 
                          test_num, addr, expected, RsData);
        end
    endtask
 
    task check_Rt;
        input [3:0]  addr;
        input [31:0] expected;
        input [63:0] test_num;
        begin
            RtAddr = addr;
            #5;
            if (RtData === expected)
                $display("TEST %0d PASSED | Read R%0d via Rt | Got=0x%08h", 
                          test_num, addr, RtData);
            else
                $display("TEST %0d FAILED | Read R%0d via Rt | Expected=0x%08h Got=0x%08h", 
                          test_num, addr, expected, RtData);
        end
    endtask

    integer idx;
 
    initial begin
        $display("========================================");
        $display("       RegisterFile Testbench");
        $display("========================================");
 

        RegWrite  = 0;
        RdAddr    = 0;
        RsAddr    = 0;
        RtAddr    = 0;
        WriteData = 0;

        #10;

        check_Rs(4'd0, 32'd0, 1);
 

        write_reg(4'd0, 32'hDEADBEEF);
        check_Rs(4'd0, 32'd0, 2); 

        write_reg(4'd1, 32'h000000FF);
        check_Rs(4'd1, 32'h000000FF, 3);

        write_reg(4'd2, 32'h0000ABCD);
        check_Rt(4'd2, 32'h0000ABCD, 4);

        write_reg(4'd3, 32'hCAFEBABE);
        write_reg(4'd4, 32'h12345678);
        RsAddr = 4'd3;
        RtAddr = 4'd4;
        #5;
        if (RsData === 32'hCAFEBABE && RtData === 32'h12345678)
            $display("TEST 5  PASSED | Simultaneous read R3=0x%08h R4=0x%08h", RsData, RtData);
        else
            $display("TEST 5  FAILED | Rs Expected=0xCAFEBABE Got=0x%08h | Rt Expected=0x12345678 Got=0x%08h",
                      RsData, RtData);
 

        @(negedge Clk);
        RegWrite  = 0;
        RdAddr    = 4'd1;
        WriteData = 32'h00000099;
        @(posedge Clk);
        #1;
        check_Rs(4'd1, 32'h000000FF, 6);

        for (idx = 1; idx <= 15; idx = idx + 1) begin
            write_reg(idx[3:0], idx * 32'h11111111);
        end
        for (idx = 1; idx <= 15; idx = idx + 1) begin
            check_Rs(idx[3:0], idx * 32'h11111111, 6 + idx);
        end

        check_Rs(4'd0, 32'd0, 22);
 
        $display("========================================");
        $display("      RegisterFile Tests Complete");
        $display("========================================");
        $finish;
    end
 
endmodule