
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

    $display("\n========================================================");
    $display("Cycle @ %0t", $time);

    //---------------- IF ----------------
    $display("\n[IF]");
    $display("PC          = %0d", uut.Current_PC);
    $display("NextPC      = %0d", uut.Next_PC);
    $display("Instruction = %032b", uut.Instruction);

    //---------------- ID ----------------
    $display("\n[ID]");
    $display("Opcode      = %06b", uut.ID_opcode);
    $display("Rs1         = %0d", uut.ID_Rs1);
    $display("Rs2         = %0d", uut.ID_Rs2);
    $display("Rd          = %0d", uut.ID_Rd);

    $display("BusA        = %0d", uut.ID_BusA);
    $display("BusB        = %0d", uut.ID_BusB);

    $display("ForwardA    = %02b", uut.ForwardA);
    $display("ForwardB    = %02b", uut.ForwardB);
    $display("Fwd BusA    = %0d", uut.ID_ForwardA_Out);
    $display("Fwd BusB    = %0d", uut.ID_ForwardB_Out);

    $display("PCSrc       = %02b", uut.PCSrc);
    $display("EQ          = %b", uut.EQ);
    $display("Stall       = %b", uut.Stall);

    // NEW
    $display("ID_WBData   = %02b", uut.ID_WBData);

    //---------------- EX ----------------
    $display("\n[EX]");
    $display("ALUOp       = %03b", uut.EX_ALUOp);
    $display("OperandA    = %0d", uut.IDEX_BusA_Out);
    $display("OperandB    = %0d", uut.EX_ALUOperandB);
    $display("ALUResult   = %0d", uut.EX_ALU_Result);

    // NEW
    $display("EX_WBData   = %02b", uut.EX_WBData);

    //---------------- MEM ----------------
    $display("\n[MEM]");
    $display("ALUResult   = %0d", uut.EXMEM_R_Out);
    $display("MemData     = %0d", uut.Data_Out);

    // NEW
    $display("EXMEM_Ctrl  = %05b", uut.EXMEM_CtrlPacked_Out);

    $display("WB_Select   = %02b", uut.MEM_WBSelector);
    $display("WB_Data     = %0d", uut.WB_SelectedData);

    //---------------- WB ----------------
    $display("\n[WB]");
    $display("BusW        = %0d", uut.BusW);
    $display("RegWrite    = %b", uut.WB_RegWr);
    $display("WriteReg    = %0d", uut.WB_Rd);

    //---------------- Memory ----------------
    $display("\n[Memory]");
    $display("DMEM[0]     = %0d", uut.Data_Memory.MEM[0]);

    //---------------- Registers ----------------
    $display("\n[Registers]");
    $display("R0=%0d  R1=%0d  R2=%0d  R3=%0d",
        uut.Register_File.REG[0], uut.Register_File.REG[1],
        uut.Register_File.REG[2], uut.Register_File.REG[3]);

    $display("R4=%0d  R5=%0d  R6=%0d  R7=%0d",
        uut.Register_File.REG[4], uut.Register_File.REG[5],
        uut.Register_File.REG[6], uut.Register_File.REG[7]);

    $display("R8=%0d  R9=%0d  R10=%0d  R11=%0d",
        uut.Register_File.REG[8], uut.Register_File.REG[9],
        uut.Register_File.REG[10], uut.Register_File.REG[11]);

    $display("R12=%0d R13=%0d R14=%0d R15=%0d",
        uut.Register_File.REG[12], uut.Register_File.REG[13],
        uut.Register_File.REG[14], uut.Register_File.REG[15]);

    $display("========================================================");

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
				
    // ---------------------------------------------------------
    // FIX: Wait for the program to finish instead of a hard limit
    // ---------------------------------------------------------
    // Wait until the PC reaches the final halt instruction at ADDR 65
    wait (uut.Current_PC == 77);
    
    // Give the pipeline 5 extra cycles to let the final instructions 
    // propagate through the EX, MEM, and WB stages
    repeat(5) @(negedge clk);

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