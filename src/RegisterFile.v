//-----------------------------------------------------------------------------
//
// Title       : RegisterFile
// Design      : SPA
// Author      : 1231192@birzeit.student.edu
// Company     : BZU
//
//-----------------------------------------------------------------------------
//
// File        : c:/Users/ameer/OneDrive/Desktop/AHDL_Design/SPA/SPA/src/RegisterFile.v
// Generated   : Sat Jun 13 21:13:37 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps




module Mux16to1_32bit (
    input  [31:0] in0,  in1,  in2,  in3,
    input  [31:0] in4,  in5,  in6,  in7,
    input  [31:0] in8,  in9,  in10, in11,
    input  [31:0] in12, in13, in14, in15,
    input  [3:0]  sel,          
    output reg [31:0] out       
);
    always @(*) begin
        case (sel)
            4'd0  : out = in0;
            4'd1  : out = in1;
            4'd2  : out = in2;
            4'd3  : out = in3;
            4'd4  : out = in4;
            4'd5  : out = in5;
            4'd6  : out = in6;
            4'd7  : out = in7;
            4'd8  : out = in8;
            4'd9  : out = in9;
            4'd10 : out = in10;
            4'd11 : out = in11;
            4'd12 : out = in12;
            4'd13 : out = in13;
            4'd14 : out = in14;
            4'd15 : out = in15;
            default: out = 32'b0;
        endcase
    end
endmodule


module RegisterFile (
    input  Clk,          
    input  W,     
    input  [3:0] RA,       
    input  [3:0] RB,      
    input  [3:0] RW,       
    input  [31:0] BUSW,    
    output [31:0] BUSA,       
    output [31:0] BUSB       
);

    reg [31:0] REG [0:15];

    
    integer i;
    initial begin
        for (i = 0;i < 16; i = i + 1)
            REG[i] = 32'b0;
    end

   
 
    
    always @(posedge Clk) begin
        if (W && RW != 4'd0) begin
            
            REG[RW] <= BUSW;
        end
        
        REG[0] <= 32'b0;
    end

    
    Mux16to1_32bit mux_RA (
        .in0  (REG[0]),  .in1  (REG[1]),  .in2  (REG[2]),  .in3  (REG[3]),
        .in4  (REG[4]),  .in5  (REG[5]),  .in6  (REG[6]),  .in7  (REG[7]),
        .in8  (REG[8]),  .in9  (REG[9]),  .in10 (REG[10]), .in11 (REG[11]),
        .in12 (REG[12]), .in13 (REG[13]), .in14 (REG[14]), .in15 (REG[15]),
        .sel  (RA),
        .out  (BUSA)
    );

    Mux16to1_32bit mux_RB (
        .in0  (REG[0]),  .in1  (REG[1]),  .in2  (REG[2]),  .in3  (REG[3]),
        .in4  (REG[4]),  .in5  (REG[5]),  .in6  (REG[6]),  .in7  (REG[7]),
        .in8  (REG[8]),  .in9  (REG[9]),  .in10 (REG[10]), .in11 (REG[11]),
        .in12 (REG[12]), .in13 (REG[13]), .in14 (REG[14]), .in15 (REG[15]),
        .sel  (RB),
        .out  (BUSB)
    );

endmodule