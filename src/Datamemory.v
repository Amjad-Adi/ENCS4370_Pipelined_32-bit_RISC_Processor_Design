`timescale 1ps / 1ps

module DataMemory (
    input  Clk,
    input  [31:0] Address,
    input  [31:0] WriteData,
    input  MemWrite,
    input  MemRead,
    output [31:0] ReadData
);

    // 256 words = 1024 bytes (1 KB)
    reg [31:0] MEM [0:255];

    initial begin
        $readmemh("dmem.mem", MEM);
    end

    // Word-aligned addressing
    assign ReadData = (MemRead) ? MEM[Address[9:2]] : 32'b0;

    always @(posedge Clk) begin
        if (MemWrite)
            MEM[Address[9:2]] <= WriteData;
    end

endmodule