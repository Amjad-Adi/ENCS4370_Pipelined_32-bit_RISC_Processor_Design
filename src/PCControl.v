module PCControl(
    input  wire [5:0] opcode,
    input  wire       Equal,
    output wire [1:0] PCSrc,
    output wire       Kill
);

    wire A4 = opcode[4]; wire A3 = opcode[3]; wire A2 = opcode[2]; wire A1 = opcode[1]; wire A0 = opcode[0];

    assign PCSrc[1] = (A3 & ~A2 & ~A1 & A0) | (A4 & ~A1 & (Equal ^ A0));
    assign PCSrc[0] = (A3 & ~A2 & ~A1 & A0) | (A4 & A1);

    assign Kill = PCSrc[1] | PCSrc[0];

endmodule

