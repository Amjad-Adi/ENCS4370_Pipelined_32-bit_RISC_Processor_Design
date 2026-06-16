//-----------------------------------------------------------------------------
//
// Title       : tb_Comparator
// Design      : PPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/PPA/PPA/src/tb_Comparator.v
// Generated   : Tue Jun 16 18:01:49 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------


`timescale 1ns/1ps
 
module tb_Comparator;
 
    
    reg  [31:0] A;
    reg  [31:0] B;
    wire        Equal;
 
    Comparator dut (
        .A     (A),
        .B     (B),
        .Equal (Equal)
    );
 
    
    task check;
        input        expected;
        input [63:0] test_num;
        begin
            #5;
            if (Equal === expected)
                $display("TEST %0d PASSED | A=0x%08h B=0x%08h | Equal=%b",
                          test_num, A, B, Equal);
            else
                $display("TEST %0d FAILED | A=0x%08h B=0x%08h | Expected=%b Got=%b",
                          test_num, A, B, expected, Equal);
        end
    endtask
   
    initial begin
        $display("========================================");
        $display("         Comparator Testbench");
        $display("========================================");
 
       
        A = 32'h000000FF; B = 32'h000000FF;
        check(1'b1, 1);
 		
        A = 32'h000000FF; B = 32'h000000FE;
        check(1'b0, 2);
 
        
        A = 32'h00000000; B = 32'h00000000;
        check(1'b1, 3);
 
      
        A = 32'hFFFFFFFF; B = 32'hFFFFFFFF;
        check(1'b1, 4);
 
       
        A = 32'hFFFFFFFF; B = 32'h00000000;
        check(1'b0, 5);
 
       
        A = 32'hFFFFFFFB; B = 32'hFFFFFFFB;
        check(1'b1, 6);
 
        
        A = 32'hFFFFFFFB; B = 32'h00000005;
        check(1'b0, 7);
 
       
        A = 32'h00000001; B = 32'h00000001;
        check(1'b1, 8);
 
       
        A = 32'h00000001; B = 32'h00000002;
        check(1'b0, 9);
 
        
        A = 32'h80000000; B = 32'h00000000;
        check(1'b0, 10);
 
        $display("========================================");
        $display("       Comparator Tests Complete");
        $display("========================================");
        $finish;
    end
 
endmodule

