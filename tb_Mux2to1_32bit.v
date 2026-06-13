//-----------------------------------------------------------------------------
//
// Title       : tb_Mux2to1_32bit
// Design      : SPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/SPA/SPA/src/tb_Mux2to1_32bit.v
// Generated   : Sun Jun 14 00:29:37 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps
module tb_Mux2to1_32bit;
   
    reg  [31:0] In0;
    reg  [31:0] In1;
    reg         Sel;
    wire [31:0] Out;
 	
    Mux2to1_32bit dut (.In0(In0),.In1(In1),.Sel (Sel),.Out (Out));
  
    task check;
        input [31:0] expected;
        input [63:0] test_num;
        begin
            #5;
            if (Out === expected)
                $display("TEST %0d PASSED | Sel=%b In0=0x%08h In1=0x%08h | Out=0x%08h",
                          test_num, Sel, In0, In1, Out);
            else
                $display("TEST %0d FAILED | Sel=%b In0=0x%08h In1=0x%08h | Expected=0x%08h Got=0x%08h",
                          test_num, Sel, In0, In1, expected, Out);
        end
    endtask
 
    initial begin
        $display("========================================");
        $display("      Mux2to1_32bit Testbench");
        $display("========================================");
 
        In0 = 32'hAAAAAAAA; In1 = 32'h55555555; Sel = 0;
        check(32'hAAAAAAAA, 1);
 
        In0 = 32'hAAAAAAAA; In1 = 32'h55555555; Sel = 1;
        check(32'h55555555, 2);
 
        In0 = 32'd100;  
        In1 = 32'd5;    
        Sel = 0;       
        check(32'd100, 3);
 
        
        Sel = 1;
        check(32'd5, 4);
 
       
        In0 = 32'h000000FF;
        In1 = 32'h00000064; 
        Sel = 0;           
        check(32'h000000FF, 5);
 
       
        Sel = 1;
        check(32'h00000064, 6);
 
       
        In0 = 32'd0; In1 = 32'd0; Sel = 0;
        check(32'd0, 7);
 
       
        In0 = 32'hFFFFFFFF; In1 = 32'h00000000; Sel = 0;
        check(32'hFFFFFFFF, 8);
 
      
        Sel = 1;
        check(32'h00000000, 9);
 
       
        In0 = 32'hDEADBEEF; In1 = 32'hCAFEBABE;
        Sel = 0; #5;
        Sel = 1; #5;
        if (Out === 32'hCAFEBABE)
            $display("TEST 10 PASSED | Dynamic Sel switch works | Out=0x%08h", Out);
        else
            $display("TEST 10 FAILED | Expected=0xCAFEBABE Got=0x%08h", Out);
 
        $display("========================================");
        $display("     Mux2to1_32bit Tests Complete");
        $display("========================================");
        $finish;
    end
 
endmodule
 
