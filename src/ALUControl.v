module ALUControl(input wire [4:0] opcode, output wire [2:0] ALUOp);

    wire A4 = opcode[4]; wire A3 = opcode[3]; wire A2 = opcode[2]; wire A1 = opcode[1]; wire A0 = opcode[0];

    assign ALUOp[2] = (~A4 & ~A3 & ~A1 & A0) | (~A1 & A2 & A3);
    assign ALUOp[1] = A4 | (~A3 & A2 & ~A0) | ((~A3 | A2) & ~(A1 ^ A0));
    assign ALUOp[0] = A4 | (~A3 & ~A2 & A1 & ~A0) | (~A3 & A2 & ~A1) | (A0 & (A3 ^ A2));

endmodule