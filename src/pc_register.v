module pc_register(input clk,input disable_reg,input [31:0] in, output reg [31:0] out);

initial begin
    out = 32'b0;
end

always @(posedge clk) begin
    if (!disable_reg)
        out <= in;
end

endmodule