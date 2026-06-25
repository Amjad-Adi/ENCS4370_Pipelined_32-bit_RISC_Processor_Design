
module Extender #(
    parameter INPUT_WIDTH = 18
)
(
    input [INPUT_WIDTH-1:0] InputData,
    input ExtOp,
    output [31:0] ExtendedData
);

assign ExtendedData =
    ExtOp ?{{(32-INPUT_WIDTH){1'b0}}, InputData}:
    {{(32-INPUT_WIDTH){InputData[INPUT_WIDTH-1]}}, InputData};

endmodule