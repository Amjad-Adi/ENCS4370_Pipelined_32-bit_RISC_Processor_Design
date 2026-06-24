module ALU(
    input [31:0] OperandA,
    input [31:0] OperandB,
    input [2:0] ALUCtrl,
    output reg [31:0] ALUResult,
    output Equal
);

always @(*) begin
    case(ALUCtrl)
        3'b000: ALUResult = OperandA + OperandB;          // ADD
        3'b001: ALUResult = OperandA & OperandB;          // AND
        3'b010: ALUResult = OperandA | OperandB;          // OR
        3'b011: ALUResult = OperandA ^ OperandB;          // XOR
        3'b100: ALUResult = OperandA - OperandB;          // SUB
        3'b101: ALUResult = ~(OperandA | OperandB);       // NOR
        3'b110: ALUResult = OperandA << OperandB[4:0];    // SLL
        3'b111: ALUResult = OperandA >> OperandB[4:0];    // SRL
        default: ALUResult = 32'b0;
    endcase
end

assign Equal = (ALUResult == 0);

endmodule