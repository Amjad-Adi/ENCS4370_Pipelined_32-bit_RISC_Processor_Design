`timescale 1ns/1ps

module tb_ALU;

reg [31:0] A;
reg [31:0] B;
reg [2:0] ALUCtrl;

wire [31:0] Result;
wire Zero;

ALU uut(
    .A(A),
    .B(B),
    .ALUCtrl(ALUCtrl),
    .Result(Result),
    .Zero(Zero)
);

initial begin

    // ADD
    A=10; B=5; ALUCtrl=3'b000; #10;
    $display("ADD  = %d", Result);

    // SUB
    A=10; B=5; ALUCtrl=3'b001; #10;
    $display("SUB  = %d", Result);

    // AND
    A=12; B=10; ALUCtrl=3'b010; #10;
    $display("AND  = %d", Result);

    // OR
    A=12; B=10; ALUCtrl=3'b011; #10;
    $display("OR   = %d", Result);

    // XOR
    A=12; B=10; ALUCtrl=3'b100; #10;
    $display("XOR  = %d", Result);

    // NOR
    A=12; B=10; ALUCtrl=3'b101; #10;
    $display("NOR  = %h", Result);

    // SLL
    A=4; B=2; ALUCtrl=3'b110; #10;
    $display("SLL  = %d", Result);

    // SRL
    A=16; B=2; ALUCtrl=3'b111; #10;
    $display("SRL  = %d", Result);

    // Zero Flag
    A=5; B=5; ALUCtrl=3'b001; #10;
    $display("ZERO = %b", Zero);

    $finish;

end

endmodule