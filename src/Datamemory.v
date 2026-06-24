`timescale 1ps / 1ps

module DataMemory (
    input Clk,
    input [31:0] Address,
    input [31:0] Data_In,
    input W,
    input R,
    output [31:0] Data_Out
);

    reg [31:0] MEM [0:255];

    initial begin
        $readmemh("dmem.mem", MEM);
    end

    assign Data_Out = R ? MEM[Address[9:2]] : 32'b0;

    always @(posedge Clk) begin
        if (W)
            MEM[Address[9:2]] <= Data_In;
    end

endmodule