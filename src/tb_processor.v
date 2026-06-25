
module Processor_TB;

reg clk;
processor uut(
    .CLK(clk)
);													   
always #5 clk = ~clk;
													  
always @(negedge clk) begin					 
    if ($time % 200 == 0) begin
        $display("\n%-10s | %-5s | %-10s | %-10s | %-10s | %-10s", 
                 "Time", "PC", "Opcode", "ALU_Res", "WB_Data", "Stall/Fwd");
        $display("----------------------------------------------------------------------------------");
    end
								
    $display("%-10t | %-5d | %-10b | %-10d | %-10d | S:%b F:%b", 
             $time, 
             uut.Current_PC, 
             uut.ID_opcode, 
             uut.EX_ALU_Result, 
             uut.BusW,
             uut.Stall,
             {uut.ForwardA, uut.ForwardB});
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
    uut.Data_Memory.MEM[0] = 100;
    repeat(2) @(posedge clk);
	
    wait (uut.Current_PC == 77);
   
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