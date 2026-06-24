`timescale 1ns/1ps

module Processor_TB;

reg clk;
processor uut(
    .CLK(clk)
);

//----------------------------------------------------
// Clock
//----------------------------------------------------
always #5 clk = ~clk;

//----------------------------------------------------
// Monitor processor after everything settles
//----------------------------------------------------
always @(negedge clk) begin

    $display("==================================================");
    $display("PC=%0d  NextPC=%0d", uut.Current_PC, uut.Next_PC);
    $display("Instruction=%032b", uut.Instruction);

    $display("Opcode=%06b inst1=%0d Rs1=%0d inst3=%0d Rs2=%0d Rd=%0d",
        uut.opcode,
        uut.inst1,
        uut.Rs1,
        uut.inst3,
        uut.Rs2,
        uut.Rd);

    $display("RegDst=%b RegSrc=%b ALUSrc=%b RegWr=%b ALUOp=%b",
        uut.RegDst,
        uut.RegSrc,
        uut.ALUSrc,
        uut.RegWr,
        uut.ALUOp);

    $display("MemRd=%b MemWr=%b WBData=%02b",
        uut.MemRd,
        uut.MemWr,
        uut.WBData);

    $display("PCSrc=%02b EQ=%b",
        uut.PCSrc,
        uut.EQ);

    $display("BUSA=%0d BUSB=%0d",
        uut.BusA,
        uut.BusB);

    $display("ALUResult=%0d", uut.ALU_Result);
    $display("BUSW=%0d", uut.BusW);

    $display("DMEM[0]=%0d", uut.Data_Memory.MEM[0]);

    $display("--------------------------------------------");

    $display("R0=%0d  R1=%0d  R2=%0d  R3=%0d",
        uut.Register_File.REG[0],
        uut.Register_File.REG[1],
        uut.Register_File.REG[2],
        uut.Register_File.REG[3]);

    $display("R4=%0d  R5=%0d  R6=%0d  R7=%0d",
        uut.Register_File.REG[4],
        uut.Register_File.REG[5],
        uut.Register_File.REG[6],
        uut.Register_File.REG[7]);

    $display("R8=%0d  R9=%0d  R10=%0d  R11=%0d",
        uut.Register_File.REG[8],
        uut.Register_File.REG[9],
        uut.Register_File.REG[10],
        uut.Register_File.REG[11]);

    $display("R12=%0d R13=%0d R14=%0d R15=%0d",
        uut.Register_File.REG[12],
        uut.Register_File.REG[13],
        uut.Register_File.REG[14],
        uut.Register_File.REG[15]);

    $display("==================================================");
end
 initial begin

    clk = 0;	

    // Initialize Register File	  
	  #1;
    uut.Register_File.REG[0]  = 0;
    uut.Register_File.REG[1]  = 8;
    uut.Register_File.REG[2]  = 4;
    uut.Register_File.REG[3]  = 3;
    uut.Register_File.REG[4]  = 0;
    uut.Register_File.REG[5]  = 0;
    uut.Register_File.REG[6]  = 0;
    uut.Register_File.REG[7]  = 0;
    uut.Register_File.REG[8]  = 0;
    uut.Register_File.REG[9]  = 0;
    uut.Register_File.REG[10] = 0;
    uut.Register_File.REG[11] = 0;
    uut.Register_File.REG[12] = 10;
    uut.Register_File.REG[13] = 0;
    uut.Register_File.REG[14] = 0;
    uut.Register_File.REG[15] = 0;

    // Optional: initialize data memory
    uut.Data_Memory.MEM[0] = 100;

    // Keep reset asserted for two cycles
    repeat(2) @(posedge clk);
				

    // Run processor
    repeat(40)
        @(negedge clk);

    $display("");
    $display("================ FINAL STATE ================");

    $display("R0  = %0d", uut.Register_File.REG[0]);
    $display("R1  = %0d", uut.Register_File.REG[1]);
    $display("R2  = %0d", uut.Register_File.REG[2]);
    $display("R3  = %0d", uut.Register_File.REG[3]);
    $display("R4  = %0d", uut.Register_File.REG[4]);
    $display("R5  = %0d", uut.Register_File.REG[5]);
    $display("R6  = %0d", uut.Register_File.REG[6]);
    $display("R7  = %0d", uut.Register_File.REG[7]);
    $display("R8  = %0d", uut.Register_File.REG[8]);
    $display("R9  = %0d", uut.Register_File.REG[9]);
    $display("R10 = %0d", uut.Register_File.REG[10]);
    $display("R11 = %0d", uut.Register_File.REG[11]);
    $display("R12 = %0d", uut.Register_File.REG[12]);
    $display("R13 = %0d", uut.Register_File.REG[13]);
    $display("R14 = %0d", uut.Register_File.REG[14]);
    $display("R15 = %0d", uut.Register_File.REG[15]);

    $display("DMEM[0] = %0d", uut.Data_Memory.MEM[0]);

    $display("=============================================");

    $finish;

end

endmodule