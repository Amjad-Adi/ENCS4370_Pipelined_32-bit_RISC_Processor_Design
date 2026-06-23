`timescale 1ns/1ps

module Extender18bit(
    input [17:0] Imm,
    input ExtOp,
    output [31:0] ExtImm
);

assign ExtImm =
       (ExtOp) ?
       {{14{Imm[17]}}, Imm} :
       {14'b0, Imm};

endmodule