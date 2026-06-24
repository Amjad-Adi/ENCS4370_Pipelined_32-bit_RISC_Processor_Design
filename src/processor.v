module processor(input CLK);
    wire [31:0] Current_PC, Next_PC, PCPlus1, Instruction, BusA, BusB, BusW, ExtendedImmediate, ExtendedOffset, Branch_Address, Jump_Address, ALUOperandB, ALU_Result, Data_Out;
    wire [5:0] opcode = Instruction[31:26];
    wire [3:0] inst1 = Instruction[25:22];
    wire [3:0] Rs1 = Instruction[21:18],Rs2,Rd;
    wire [3:0] inst3 = Instruction[17:14];
    wire [17:0] Immediate = Instruction[17:0];
    wire [25:0] Offset = Instruction[25:0];
	wire [3:0] WriteRegister;
    wire [2:0] ALUOp;
    wire [1:0] WBData, PCSrc;
    wire EQ, RegDst, ExtOp, RegWr,ALUSrc, MemRd, MemWr, RegSrc;
    Mux4to1 pc_mux(.Input0(PCPlus1), .Input1(Jump_Address), .Input2(Branch_Address), .Input3(BusA), .Select(PCSrc), .OutputData(Next_PC));
    pc_register PC(.clk(CLK), .disable_reg(1'b0), .in(Next_PC), .out(Current_PC));
    Adder #(32) pc_adder(.OperandA(Current_PC), .OperandB(32'd1), .Result(PCPlus1));
    InstructionMemory Instruction_Memory(.Address(Current_PC), .Instruction(Instruction));
	
    MainandALUControl main_alu_contrl(.opcode(opcode), .ALUOp(ALUOp),.RegDst(RegDst),.RegSrc(RegSrc),.ExtOp(ExtOp),.RegWrite(RegWr),.ALUSrc(ALUSrc),.MemRead(MemRd),.MemWrite(MemWr),.WBDataSelect(WBData));
	Mux2to1  #(.WIDTH(4)) RegDstMux(.Input0(inst1), .Input1(4'b1110), .Select(RegDst), .OutputData(Rd));
    PCControl pc_ctrl(.opcode(opcode), .Equal(EQ), .PCSrc(PCSrc));
    Mux2to1  #(.WIDTH(4)) RegSrcMux(.Input0(inst3), .Input1(inst1), .Select(RegSrc), .OutputData(Rs2));
	RegisterFile Register_File (.Clk(CLK),.W(RegWr),.RA(Rs1),.RB(Rs2),.RW(Rd),.BUSW(BusW),.BUSA(BusA),.BUSB(BusB));
	Extender #(.INPUT_WIDTH(18)) ImmediateExtender (.InputData(Immediate),.ExtOp(ExtOp),.ExtendedData(ExtendedImmediate));

    Extender #(.INPUT_WIDTH(26)) OffsetExtender (.InputData(Offset),.ExtOp(1'b0),.ExtendedData(ExtendedOffset));
	Adder #(32) branch_adder(.OperandA(Current_PC), .OperandB(ExtendedImmediate), .Result(Branch_Address));
    Adder #(32) jump_adder(.OperandA(Current_PC), .OperandB(ExtendedOffset), .Result(Jump_Address));
	
    Mux2to1 ALUSrcMux(.Input0(BusB), .Input1(ExtendedImmediate), .Select(ALUSrc), .OutputData(ALUOperandB));
    ALU ALU(.OperandA(BusA), .OperandB(ALUOperandB), .ALUCtrl(ALUOp), .ALUResult(ALU_Result), .Equal(EQ));
	
	DataMemory Data_Memory (.Clk(CLK),.Address(ALU_Result),.Data_In(BusB),.W(MemWr),.R(MemRd),.Data_Out(Data_Out));
	
    Mux4to1 WbdataMux(.Input0(ALU_Result), .Input1(Data_Out), .Input2(PCPlus1), .Input3(32'b0), .Select(WBData), .OutputData(BusW));
									
endmodule