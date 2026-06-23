`timescale 1ns / 1ps

module Mux4to1(input  [31:0] in0,input  [31:0] in1,input  [31:0] in2,input  [31:0] in3,input  [1:0]  sel,output [31:0] out);

    wire [31:0] MuxOut0;
    wire [31:0] MuxOut1;

    // First stage
    Mux2to1 MUX0 (.In0(in0),.In1(in1),.Sel(sel[0]),.Out(MuxOut0));
    Mux2to1 MUX1 (.In0(in2),.In1(in3),.Sel(sel[0]),.Out(MuxOut1));

    // Second stage
    Mux2to1 MUX2 (.In0(MuxOut0),.In1(MuxOut1),.Sel(sel[1]),.Out(out));

endmodule