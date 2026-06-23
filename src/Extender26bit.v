`timescale 1ns/1ps

module Extender26bit(
    input [25:0] Imm,
    output [31:0] ExtImm
);

assign ExtImm ={16'b0, Imm};

endmodule