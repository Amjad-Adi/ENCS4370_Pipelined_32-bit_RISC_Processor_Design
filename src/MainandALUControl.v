module MainandALUControl(input wire [5:0] opcode, output wire [2:0] ALUOp,output wire RegDst, output wire RegSrc,output wire ExtOp, output wire RegWrite, output wire ALUSrc, output wire MemRead, output wire MemWrite, output wire [1:0] WBDataSelect);

    wire A4 = opcode[4]; wire A3 = opcode[3]; wire A2 = opcode[2]; wire A1 = opcode[1]; wire A0 = opcode[0];
    
    assign RegDst = A4;	 
	assign RegSrc = (~A4 & A3) | (A4 & ~A3 & ~A2);
    assign ExtOp = A4 | (A2 & A1) | (A1 ^ A0);
    assign RegWrite = (~A4 & ~A3) | (~A4 & ~A1 & ~A0) | (A2 ^ A1) | (A1 & A0);
    assign ALUSrc = A3;
    assign MemRead = A3 & A2 & A0;
    assign MemWrite = A3 & A2 & A1;
    assign WBDataSelect[1] =(~A4 & A3 & ~A2 & ~A1) |( A4 & ~A3 & ~A2);
    assign WBDataSelect[0] = (~A4 & A3 & ~A2 & ~A1) |(~A4 & A3 &  A2 &  A0);
	assign ALUOp[2] = (~A4 & ~A3 & A2 & A1) |(~A4 & ~A3 & ~A1 & A0);
	assign ALUOp[1] =(~A4 & ~A3 &  A2 & ~A0) |(~A4 & ~A3 &  A1 &  A0) |(~A4 &  A2 & ~A1 & ~A0) |( A4 & ~A3 & ~A2);
    assign ALUOp[0] = (~A4 & ~A3 &  A2 & ~A1) |(~A4 & ~A3 &  A2 &  A0) |(~A4 &  A3 & ~A2 &  A0) |( A4 & ~A3 & ~A2) |(~A3 & ~A2 &  A1 & ~A0);
endmodule