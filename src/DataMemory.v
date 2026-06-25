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

    // READ: synchronous on positive clock edge
    // Registered read ensures correct pipeline timing
    // MEM stage reads on posedge, result available for WB next cycle
    always @(posedge Clk) begin
        if (R)
            Data_Out <= MEM[Address[9:2]];
        else
            Data_Out <= 32'b0;
    end

    // WRITE: synchronous on negative clock edge
    // negedge write + posedge read means for SWAP:
    //   negedge ? writes new value (Data_In) to memory
    //   posedge ? reads OLD value that was there before negedge
    // This correctly implements atomic exchange behavior
    always @(negedge Clk) begin
        if (W)
            MEM[Address[9:2]] <= Data_In;
    end

endmodule
