module MainControl(input wire [4:0] opcode, output wire RegDst, output wire LinkSel, output wire ExtOp, output wire RegW, output wire ALUSrc, output wire MemRd, output wire MemWr, output wire [1:0] Wbdata);

    wire A4 = opcode[4]; wire A3 = opcode[3]; wire A2 = opcode[2]; wire A1 = opcode[1]; wire A0 = opcode[0];
    
    assign RegDst = ~A4 & (~A3 | (~A2 & ~A1));
    assign LinkSel = A4;
    assign ExtOp = A4 | (A2 & A1) | (A1 ^ A0);
    assign RegW = (~A4 & ~A3) | (~A4 & ~A1 & ~A0) | (A2 ^ A1) | (A1 & A0);
    assign ALUSrc = A3;
    assign MemRd = A3 & A2 & A0;
    assign MemWr = A3 & A2 & A1;
    assign Wbdata[1] = A4 | (A3 & ~A2 & ~A1);
    assign Wbdata[0] = (A3 & ~(A2 ^ A1)) | (~A1 & A0);

endmodule