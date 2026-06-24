`timescale 1ns/1ps

module Processor_TB;

reg clk;
reg reset;

processor uut(
    .CLK(clk),
    .reset(reset)
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
    $display("PC=%0d  NextPC=%0d", uut.pc, uut.next_pc);
    $display("Instruction=%032b", uut.Instruction);

    $display("Opcode=%06b inst1=%0d Rs=%0d inst3=%0d Rt=%0d Rw=%0d",
        uut.opcode,
        uut.inst1,
        uut.Rs,
        uut.inst3,
        uut.Rt,uut.Rw);

    $display("RegDst=%b RegSrc=%b ALUSrc=%b RegW=%b, ALUOp=%b",
        uut.RegDst,
        uut.RegSrc,
        uut.ALUSrc,
        uut.RegW,uut.ALUOp);

    $display("MemRd=%b MemWr=%b Wbdata=%02b",
        uut.MemRd,
        uut.MemWr,
        uut.Wbdata);

    $display("PCSrc=%02b Zero=%b",
        uut.PCSrc,
        uut.Z);

    $display("BUSA=%0d BUSB=%0d",
        uut.BUSA,
        uut.BUSB);

    $display("ALUResult=%0d", uut.ALU_Result);
    $display("BUSW=%0d", uut.BUSW);

    $display("DMEM[0]=%0d", uut.data_mem.MEM[0]);

    $display("--------------------------------------------");

    $display("R0=%0d  R1=%0d  R2=%0d  R3=%0d",
        uut.reg_file.REG[0],
        uut.reg_file.REG[1],
        uut.reg_file.REG[2],
        uut.reg_file.REG[3]);

    $display("R4=%0d  R5=%0d  R6=%0d  R7=%0d",
        uut.reg_file.REG[4],
        uut.reg_file.REG[5],
        uut.reg_file.REG[6],
        uut.reg_file.REG[7]);

    $display("R8=%0d  R9=%0d  R10=%0d  R11=%0d",
        uut.reg_file.REG[8],
        uut.reg_file.REG[9],
        uut.reg_file.REG[10],
        uut.reg_file.REG[11]);

    $display("R12=%0d R13=%0d R14=%0d R15=%0d",
        uut.reg_file.REG[12],
        uut.reg_file.REG[13],
        uut.reg_file.REG[14],
        uut.reg_file.REG[15]);

    $display("==================================================");
end
 initial begin

    clk = 0;
    reset = 1;

    // Initialize Register File	  
	  #1;
    uut.reg_file.REG[0]  = 0;
    uut.reg_file.REG[1]  = 8;
    uut.reg_file.REG[2]  = 4;
    uut.reg_file.REG[3]  = 3;
    uut.reg_file.REG[4]  = 0;
    uut.reg_file.REG[5]  = 0;
    uut.reg_file.REG[6]  = 0;
    uut.reg_file.REG[7]  = 0;
    uut.reg_file.REG[8]  = 0;
    uut.reg_file.REG[9]  = 0;
    uut.reg_file.REG[10] = 0;
    uut.reg_file.REG[11] = 0;
    uut.reg_file.REG[12] = 10;
    uut.reg_file.REG[13] = 0;
    uut.reg_file.REG[14] = 0;
    uut.reg_file.REG[15] = 0;

    // Optional: initialize data memory
    uut.data_mem.MEM[0] = 100;

    // Keep reset asserted for two cycles
    repeat(2) @(posedge clk);

    reset = 0;

    // Run processor
    repeat(40)
        @(negedge clk);

    $display("");
    $display("================ FINAL STATE ================");

    $display("R0  = %0d", uut.reg_file.REG[0]);
    $display("R1  = %0d", uut.reg_file.REG[1]);
    $display("R2  = %0d", uut.reg_file.REG[2]);
    $display("R3  = %0d", uut.reg_file.REG[3]);
    $display("R4  = %0d", uut.reg_file.REG[4]);
    $display("R5  = %0d", uut.reg_file.REG[5]);
    $display("R6  = %0d", uut.reg_file.REG[6]);
    $display("R7  = %0d", uut.reg_file.REG[7]);
    $display("R8  = %0d", uut.reg_file.REG[8]);
    $display("R9  = %0d", uut.reg_file.REG[9]);
    $display("R10 = %0d", uut.reg_file.REG[10]);
    $display("R11 = %0d", uut.reg_file.REG[11]);
    $display("R12 = %0d", uut.reg_file.REG[12]);
    $display("R13 = %0d", uut.reg_file.REG[13]);
    $display("R14 = %0d", uut.reg_file.REG[14]);
    $display("R15 = %0d", uut.reg_file.REG[15]);

    $display("DMEM[0] = %0d", uut.data_mem.MEM[0]);

    $display("=============================================");

    $finish;

end

endmodule