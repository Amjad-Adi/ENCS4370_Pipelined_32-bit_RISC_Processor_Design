

module Mux4to1 #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] Input0,
    input [WIDTH-1:0] Input1,
    input [WIDTH-1:0] Input2,
    input [WIDTH-1:0] Input3,
    input [1:0] Select,
    output [WIDTH-1:0] OutputData
);
	
	wire [WIDTH - 1:0] MuxOut0;
    wire [WIDTH -1:0] MuxOut1;
				  
    Mux2to1 #(WIDTH) MUX0 (.Input0(Input0),.Input1(Input1),.Select(Select[0]),.OutputData(MuxOut0));
    Mux2to1 #(WIDTH) MUX1 (.Input0(Input2),.Input1(Input3),.Select(Select[0]),.OutputData(MuxOut1));
				   
    Mux2to1  #(WIDTH) MUX2 (.Input0(MuxOut0),.Input1(MuxOut1),.Select(Select[1]),.OutputData(OutputData));

endmodule