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

module Decoder4to16 (
    input   [3:0]  in,       
    input	enable,   
    output reg [15:0] out       
);
    always @(*) begin
        out = 16'b0;            
        if (enable) begin
            out = 16'b1 << in;  
        end
    end
endmodule


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
    input  RegWrite,     
    input  [3:0] RdAddr,       
    input  [3:0] RsAddr,      
    input  [3:0] RtAddr,       
    input  [31:0] WriteData,    
    output [31:0] RsData,       
    output [31:0] RtData       
);

    reg [31:0] REG [0:15];

    
    integer i;
    initial begin
        for (i = 0;i < 16; i = i + 1)
            REG[i] = 32'b0;
    end

   
    wire [15:0] decode_out;    

    Decoder4to16 decoder (
        .in(RdAddr),
        .enable(RegWrite),
        .out(decode_out)
    );

    
    always @(posedge Clk) begin
        if (RegWrite && RdAddr != 4'd0) begin
            
            REG[RdAddr] <= WriteData;
        end
        
        REG[0] <= 32'b0;
    end

    
    Mux16to1_32bit mux_Rs (
        .in0  (REG[0]),  .in1  (REG[1]),  .in2  (REG[2]),  .in3  (REG[3]),
        .in4  (REG[4]),  .in5  (REG[5]),  .in6  (REG[6]),  .in7  (REG[7]),
        .in8  (REG[8]),  .in9  (REG[9]),  .in10 (REG[10]), .in11 (REG[11]),
        .in12 (REG[12]), .in13 (REG[13]), .in14 (REG[14]), .in15 (REG[15]),
        .sel  (RsAddr),
        .out  (RsData)
    );

    Mux16to1_32bit mux_Rt (
        .in0  (REG[0]),  .in1  (REG[1]),  .in2  (REG[2]),  .in3  (REG[3]),
        .in4  (REG[4]),  .in5  (REG[5]),  .in6  (REG[6]),  .in7  (REG[7]),
        .in8  (REG[8]),  .in9  (REG[9]),  .in10 (REG[10]), .in11 (REG[11]),
        .in12 (REG[12]), .in13 (REG[13]), .in14 (REG[14]), .in15 (REG[15]),
        .sel  (RtAddr),
        .out  (RtData)
    );

endmodule