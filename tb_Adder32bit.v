//-----------------------------------------------------------------------------
//
// Title       : tb_Adder32bit
// Design      : SPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/SPA/SPA/src/tb_Adder32bit.v
// Generated   : Sun Jun 14 00:27:33 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps
module tb_Adder32bit;
    reg  [31:0] A;
    reg  [31:0] B;
    wire [31:0] Sum;
 
    Adder32bit dut (.A(A),.B(B),.Sum(Sum));
 
    task check;
        input [31:0] expected;
        input [63:0] test_num;
        begin
            #5; 
            if (Sum === expected)
                $display("TEST %0d PASSED | A=0x%08h B=0x%08h | Sum=0x%08h", 
                          test_num, A, B, Sum);
            else
                $display("TEST %0d FAILED | A=0x%08h B=0x%08h | Expected=0x%08h Got=0x%08h", 
                          test_num, A, B, expected, Sum);
        end
    endtask
 	 
    initial begin
        $display("========================================");
        $display("       Adder32bit Testbench");
        $display("========================================");
 
        A = 32'd0; B = 32'd1;
        check(32'd1, 1);

        A = 32'd100; B = 32'd1;
        check(32'd101, 2);
  
        A = 32'd50; B = 32'd10;
        check(32'd60, 3);

        A = 32'd0; B = 32'd0;
        check(32'd0, 4);

        A = 32'd20; B = 32'hFFFFFFFB; 
        check(32'd15, 5);

        A = 32'd1; B = 32'hFFFFFFFF;
        check(32'd0, 6);

        A = 32'h000FFFFF; B = 32'd1;
        check(32'h00100000, 7);

        A = 32'hFFFFFFFF; B = 32'd1;
        check(32'h00000000, 8);
 
        $display("========================================");
        $display("       Adder32bit Tests Complete");
        $display("========================================");
        $finish;
    end
endmodule
