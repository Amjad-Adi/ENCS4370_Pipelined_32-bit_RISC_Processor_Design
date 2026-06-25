`timescale 1ns/1ps

module Processor_Functionallity_TB;

reg clk;		 
processor uut (
    .CLK(clk)
);
											 
always #5 clk = ~clk;							  
integer cycle_num;
initial cycle_num = 0;

always @(negedge clk)
    cycle_num = cycle_num + 1;
											   
always @(negedge clk) begin				   
    if (cycle_num % 20 == 0) begin	
		
        $display("\n%-10s | %-10s | %-10s | %-10s | %-10s", 
                 "Cycle", "PC", "IF/ID", "ID/EX", "EX/MEM");
        $display("------------------------------------------------------------------");
    end
										  
    $display("%-10d | %-10d | %-10h | %-10h | %-10h", 
             cycle_num, 
             uut.Current_PC, 
             uut.Instruction[31:26],
             uut.EX_ALUOperandB,     
             uut.EX_ALU_Result);     
end											   
initial begin

    clk = 0;
    #1;

    uut.Register_File.REG[0]=0;
    uut.Register_File.REG[1]=8;
    uut.Register_File.REG[2]=4;
    uut.Register_File.REG[3]=3;
    uut.Register_File.REG[4]=0;
    uut.Register_File.REG[5]=0;
    uut.Register_File.REG[6]=0;
    uut.Register_File.REG[7]=0;
    uut.Register_File.REG[8]=0;
    uut.Register_File.REG[9]=0;
    uut.Register_File.REG[10]=0;
    uut.Register_File.REG[11]=0;
    uut.Register_File.REG[12]=10;
    uut.Register_File.REG[13]=0;
    uut.Register_File.REG[14]=0;
    uut.Register_File.REG[15]=0;

    uut.Data_Memory.MEM[0]=100;

    repeat(2) @(posedge clk);
    repeat(40) @(negedge clk);

    $display("");
    $display("==============================================================");
    $display("FINAL STATE");
    $display("==============================================================");

    $display("R0 =%0d   R1 =%0d", uut.Register_File.REG[0], uut.Register_File.REG[1]);
    $display("R2 =%0d   R3 =%0d", uut.Register_File.REG[2], uut.Register_File.REG[3]);
    $display("R4 =%0d   R5 =%0d", uut.Register_File.REG[4], uut.Register_File.REG[5]);
    $display("R6 =%0d   R7 =%0d", uut.Register_File.REG[6], uut.Register_File.REG[7]);
    $display("R8 =%0d   R9 =%0d", uut.Register_File.REG[8], uut.Register_File.REG[9]);
    $display("R10=%0d   R11=%0d", uut.Register_File.REG[10], uut.Register_File.REG[11]);
    $display("R12=%0d   R13=%0d", uut.Register_File.REG[12], uut.Register_File.REG[13]);
    $display("R14=%0d   R15=%0d", uut.Register_File.REG[14], uut.Register_File.REG[15]);

    $display("DMEM[0]=%0d", uut.Data_Memory.MEM[0]);

    $finish;

end

endmodule
