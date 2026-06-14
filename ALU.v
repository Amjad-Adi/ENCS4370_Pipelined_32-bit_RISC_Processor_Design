module ALU(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUCtrl,
    output reg [31:0] Result,
    output Zero
);

always @(*) begin
    case(ALUCtrl)
        3'b000: Result = A + B;
        3'b001: Result = A - B;
        3'b010: Result = A & B;
        3'b011: Result = A | B;
        3'b100: Result = A ^ B;
        3'b101: Result = ~(A | B);
        3'b110: Result = A << B[4:0];
        3'b111: Result = A >> B[4:0];
        default: Result = 0;
    endcase
end

assign Zero = (Result == 0);

endmodule