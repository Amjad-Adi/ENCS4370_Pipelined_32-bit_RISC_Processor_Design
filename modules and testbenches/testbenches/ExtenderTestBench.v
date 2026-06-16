`timescale 1ns/1ps

module tb_Extender;

reg [17:0] Imm;
reg ExtOp;

wire [31:0] ExtImm;

Extender uut(
    .Imm(Imm),
    .ExtOp(ExtOp),
    .ExtImm(ExtImm)
);

initial begin

    // Sign Extension
    Imm   = 18'b100000000000000001;
    ExtOp = 1;
    #10;

    $display("Sign Extend = %h", ExtImm);

    // Zero Extension
    Imm   = 18'b100000000000000001;
    ExtOp = 0;
    #10;

    $display("Zero Extend = %h", ExtImm);

    $finish;

end

endmodule