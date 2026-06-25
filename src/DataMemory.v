`timescale 1ps / 1ps

module DataMemory (
    input         Clk,
    input  [31:0] Address,
    input  [31:0] Data_In,
    input         W,
    input         R,
    output reg [31:0] Data_Out
);

    reg [31:0] MEM [0:255];

    initial begin
        $readmemh("dmem.mem", MEM);
        Data_Out = 32'b0;
    end														  
    always @(posedge Clk) begin
        if (R)
            Data_Out <= MEM[Address[9:2]];
        else
            Data_Out <= 32'b0;
    end
												   
    always @(negedge Clk) begin
        if (W)
            MEM[Address[9:2]] <= Data_In;
    end

endmodule
