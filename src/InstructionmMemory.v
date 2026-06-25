`timescale 1ps / 1ps

module InstructionMemory (
    input  [31:0] Address,
    output [31:0] Instruction
);

    reg [31:0] memory_array [0:1023];

    initial begin
        $readmemb("tests/hazard_test.bin", memory_array);
    end

    assign Instruction = memory_array[Address];

endmodule