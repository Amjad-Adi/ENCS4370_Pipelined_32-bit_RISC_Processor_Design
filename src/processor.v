module processor(input CLK);

wire [31:0] Current_PC, Next_PC, PCPlus1, Instruction, BusA, BusB, BusW, ExtendedImmediate, ExtendedOffset, Branch_Address, Jump_Address, ALUOperandB, ALU_Result, Data_Out;
wire [5:0] opcode = Instruction[31:26];
wire [3:0] inst1 = Instruction[25:22];
wire [3:0] Rs1 = Instruction[21:18], Rs2, Rd;
wire [3:0] inst3 = Instruction[17:14];
wire [17:0] Immediate = Instruction[17:0];
wire [25:0] Offset = Instruction[25:0];
wire [3:0] WriteRegister;
wire [2:0] ALUOp;
wire [1:0] WBData, PCSrc;
wire EQ, RegDst, ExtOp, RegWr, ALUSrc, MemRd, MemWr, RegSrc;

wire disable_pc;
wire kill_instruction;
wire [31:0] Instruction_MuxOut;
wire [31:0] IFID_PC_Out, IFID_PCPlus1_Out, IFID_Instruction_Out;

Mux4to1 pc_mux(.Input0(PCPlus1), .Input1(Jump_Address), .Input2(Branch_Address), .Input3(BusA), .Select(PCSrc), .OutputData(Next_PC));

SyncRegisterEn #(32) pc_register(.clk(CLK), .en(~disable_pc), .in(Next_PC), .out(Current_PC));

Adder #(32) pc_adder(.OperandA(Current_PC), .OperandB(32'd1), .Result(PCPlus1));

InstructionMemory Instruction_Memory(.Address(Current_PC), .Instruction(Instruction));

Mux2to1_32bit instruction_mux(.In0(Instruction), .In1(32'b00100000000000000000000000000000), .Sel(kill_instruction), .Out(Instruction_MuxOut));

SyncRegisterEn #(32) IFID_Instruction(.clk(CLK), .en(~disable_pc), .in(Instruction_MuxOut), .out(IFID_Instruction_Out));

SyncRegisterEn #(32) IFID_PC(.clk(CLK), .en(~disable_pc), .in(Current_PC), .out(IFID_PC_Out));

SyncRegister #(32) IFID_PCPlus1(.clk(CLK), .in(PCPlus1), .out(IFID_PCPlus1_Out));

// -- ID Stage ------------------------------------------------------------------

wire [5:0]  ID_opcode    = IFID_Instruction_Out[31:26];
wire [3:0]  ID_inst1     = IFID_Instruction_Out[25:22];
wire [3:0]  ID_inst3     = IFID_Instruction_Out[17:14];
wire [3:0]  ID_Rs1       = IFID_Instruction_Out[21:18];
wire [17:0] ID_Immediate = IFID_Instruction_Out[17:0];
wire [25:0] ID_Offset    = IFID_Instruction_Out[25:0];

wire [3:0]  ID_Rs2, ID_Rd;
wire [31:0] ID_BusA, ID_BusB, ID_ExtendedImmediate, ID_ExtendedOffset;
wire [9:0]  CtrlSignals_Raw, CtrlSignals_Muxed;
wire        ID_RegDst, ID_RegSrc;
wire        Stall;
wire [1:0]  ForwardA, ForwardB;
wire [3:0]  EX_Rd, MEM_Rd, WB_Rd;
wire        EX_RegWr, MEM_RegWr, WB_RegWr, EX_MemRd;

// Unpack muxed control signals for ID stage use
wire [2:0] ID_ALUOp  = CtrlSignals_Muxed[9:7];
wire       ID_ExtOp  = CtrlSignals_Muxed[6];
wire       ID_RegWr  = CtrlSignals_Muxed[5];
wire       ID_ALUSrc = CtrlSignals_Muxed[4];
wire       ID_MemRd  = CtrlSignals_Muxed[3];
wire       ID_MemWr  = CtrlSignals_Muxed[2];
wire [1:0] ID_WBData = CtrlSignals_Muxed[1:0];

MainandALUControl main_alu_contrl(.opcode(ID_opcode), .ALUOp(CtrlSignals_Raw[9:7]), .RegDst(ID_RegDst), .RegSrc(ID_RegSrc), .ExtOp(CtrlSignals_Raw[6]), .RegWrite(CtrlSignals_Raw[5]), .ALUSrc(CtrlSignals_Raw[4]), .MemRead(CtrlSignals_Raw[3]), .MemWrite(CtrlSignals_Raw[2]), .WBDataSelect(CtrlSignals_Raw[1:0]));

Mux2to1 #(.WIDTH(10)) CtrlSignalsMux(.Input0(CtrlSignals_Raw), .Input1(10'b0000000000), .Select(Stall), .OutputData(CtrlSignals_Muxed));

Mux2to1 #(.WIDTH(4)) RegDstMux(.Input0(ID_inst1), .Input1(4'b1110), .Select(ID_RegDst), .OutputData(ID_Rd));

PCControl pc_ctrl(.opcode(ID_opcode), .Equal(EQ), .PCSrc(PCSrc), .Kill(kill_instruction));

Mux2to1 #(.WIDTH(4)) RegSrcMux(.Input0(ID_inst3), .Input1(ID_inst1), .Select(ID_RegSrc), .OutputData(ID_Rs2));

RegisterFile Register_File(.Clk(CLK), .W(ID_RegWr), .RA(ID_Rs1), .RB(ID_Rs2), .RW(WB_Rd), .BUSW(BusW), .BUSA(ID_BusA), .BUSB(ID_BusB));

Extender #(.INPUT_WIDTH(18)) ImmediateExtender(.InputData(ID_Immediate), .ExtOp(ID_ExtOp), .ExtendedData(ID_ExtendedImmediate));

Extender #(.INPUT_WIDTH(26)) OffsetExtender(.InputData(ID_Offset), .ExtOp(1'b0), .ExtendedData(ID_ExtendedOffset));

Adder #(32) branch_adder(.OperandA(IFID_PC_Out), .OperandB(ID_ExtendedImmediate), .Result(Branch_Address));

Adder #(32) jump_adder(.OperandA(IFID_PC_Out), .OperandB(ID_ExtendedOffset), .Result(Jump_Address));

ForwardingUnit forwarding_unit(.RA(ID_Rs1), .RB(ID_Rs2), .Rd2(EX_Rd), .Rd3(MEM_Rd), .Rd4(WB_Rd), .EX_RegWr(EX_RegWr), .MEM_RegWr(MEM_RegWr), .WB_RegWr(WB_RegWr), .EX_MemRd(EX_MemRd), .ForwardA(ForwardA), .ForwardB(ForwardB), .Stall(Stall));

// -- ID/EX Pipeline Registers --------------------------------------------------

wire [9:0]  IDEX_CtrlSignals_Out;
wire [31:0] IDEX_BusA_Out, IDEX_BusB_Out, IDEX_ExtImm_Out, IDEX_PCPlus1_Out;
wire [3:0]  IDEX_Rd_Out, IDEX_Rs1_Out, IDEX_Rs2_Out;

SyncRegister #(10) IDEX_CtrlSignals(.clk(CLK), .in(CtrlSignals_Muxed),    .out(IDEX_CtrlSignals_Out));
SyncRegister #(32) IDEX_BusA       (.clk(CLK), .in(ID_BusA),              .out(IDEX_BusA_Out));
SyncRegister #(32) IDEX_BusB       (.clk(CLK), .in(ID_BusB),              .out(IDEX_BusB_Out));
SyncRegister #(32) IDEX_ExtImm     (.clk(CLK), .in(ID_ExtendedImmediate), .out(IDEX_ExtImm_Out));
SyncRegister #(32) IDEX_PCPlus1    (.clk(CLK), .in(IFID_PCPlus1_Out),     .out(IDEX_PCPlus1_Out));
SyncRegister #(4)  IDEX_Rd         (.clk(CLK), .in(ID_Rd),                .out(IDEX_Rd_Out));
SyncRegister #(4)  IDEX_Rs1        (.clk(CLK), .in(ID_Rs1),               .out(IDEX_Rs1_Out));
SyncRegister #(4)  IDEX_Rs2        (.clk(CLK), .in(ID_Rs2),               .out(IDEX_Rs2_Out));

assign EX_Rd    = IDEX_Rd_Out;                  // Rd2 ? forwarding unit
assign EX_RegWr = IDEX_CtrlSignals_Out[5];
assign EX_MemRd = IDEX_CtrlSignals_Out[3];

// -- EX Stage ------------------------------------------------------------------

wire [2:0]  EX_ALUOp  = IDEX_CtrlSignals_Out[9:7];
wire        EX_ALUSrc = IDEX_CtrlSignals_Out[4];
wire        EX_MemWr  = IDEX_CtrlSignals_Out[2];
wire [1:0]  EX_WBData = IDEX_CtrlSignals_Out[1:0];

wire [31:0] EX_ForwardA_Out, EX_ForwardB_Out, EX_ALUOperandB, EX_ALU_Result;
wire        EX_Zero;

Mux4to1 #(32) ForwardAMux(.Input0(IDEX_BusA_Out), .Input1(BusW), .Input2(ALU_Result), .Input3(Data_Out), .Select(ForwardA), .OutputData(EX_ForwardA_Out));

Mux4to1 #(32) ForwardBMux(.Input0(IDEX_BusB_Out), .Input1(BusW), .Input2(ALU_Result), .Input3(Data_Out), .Select(ForwardB), .OutputData(EX_ForwardB_Out));

Mux2to1 #(.WIDTH(32)) ALUSrcMux(.Input0(EX_ForwardB_Out), .Input1(IDEX_ExtImm_Out), .Select(EX_ALUSrc), .OutputData(EX_ALUOperandB));

ALU alu(.OperandA(EX_ForwardA_Out), .OperandB(EX_ALUOperandB), .ALUCtrl(EX_ALUOp), .ALUResult(EX_ALU_Result));	  

// -- EX/MEM Pipeline Registers -------------------------------------------------

// Control signals: {RegWr, MemRd, MemWr, WBData[1:0]} = 5 bits
wire [4:0]  EXMEM_CtrlPacked_In  = {EX_RegWr, EX_MemRd, EX_MemWr, EX_WBData};
wire [4:0]  EXMEM_CtrlPacked_Out;
wire [31:0] EXMEM_R_Out, EXMEM_D_Out, EXMEM_PCPlus1_Out;
wire [3:0]  EXMEM_Rd3_Out;

SyncRegister #(5)  EXMEM_CtrlSignals(.clk(CLK), .in(EXMEM_CtrlPacked_In),  .out(EXMEM_CtrlPacked_Out));
SyncRegister #(32) EXMEM_R         (.clk(CLK), .in(EX_ALU_Result),         .out(EXMEM_R_Out));
SyncRegister #(32) EXMEM_D         (.clk(CLK), .in(EX_ForwardB_Out),       .out(EXMEM_D_Out));
SyncRegister #(32) EXMEM_PCPlus1   (.clk(CLK), .in(IDEX_PCPlus1_Out),      .out(EXMEM_PCPlus1_Out));
SyncRegister #(4)  EXMEM_Rd3       (.clk(CLK), .in(IDEX_Rd_Out),           .out(EXMEM_Rd3_Out));

assign MEM_Rd    = EXMEM_Rd3_Out;               // Rd3 ? forwarding unit
assign MEM_RegWr = EXMEM_CtrlPacked_Out[4];

// -- MEM Stage -----------------------------------------------------------------

wire MEM_MemRd = EXMEM_CtrlPacked_Out[3];
wire MEM_MemWr = EXMEM_CtrlPacked_Out[2];
wire [1:0] MEM_WBData = EXMEM_CtrlPacked_Out[1:0];

DataMemory Data_Memory(.Clk(CLK), .Address(EXMEM_R_Out), .Data_In(EXMEM_D_Out), .W(MEM_MemWr), .R(MEM_MemRd), .Data_Out(Data_Out));

Mux4to1 WbdataMux(.Input0(ALU_Result), .Input1(Data_Out), .Input2(PCPlus1), .Input3(32'b0), .Select(WBData), .OutputData(BusW));

// -- MEM/WB Pipeline Registers -------------------------------------------------

// Control signals: {RegWr, WBData[1:0]} = 3 bits
wire [2:0]  MEMWB_CtrlPacked_In  = {MEM_RegWr, MEM_WBData};
wire [2:0]  MEMWB_CtrlPacked_Out;
wire [31:0] MEMWB_Data_Out, MEMWB_PCPlus1_Out;
wire [3:0]  MEMWB_Rd4_Out;

SyncRegister #(3)  MEMWB_CtrlSignals(.clk(CLK), .in(MEMWB_CtrlPacked_In),  .out(MEMWB_CtrlPacked_Out));
SyncRegister #(32) MEMWB_Data       (.clk(CLK), .in(Data_Out),              .out(MEMWB_Data_Out));
SyncRegister #(32) MEMWB_PCPlus1    (.clk(CLK), .in(EXMEM_PCPlus1_Out),     .out(MEMWB_PCPlus1_Out));
SyncRegister #(4)  MEMWB_Rd4        (.clk(CLK), .in(EXMEM_Rd3_Out),         .out(MEMWB_Rd4_Out));

assign WB_Rd    = MEMWB_Rd4_Out;                // Rd4 ? forwarding unit + register file
assign WB_RegWr = MEMWB_CtrlPacked_Out[2];

// -- WB Stage ------------------------------------------------------------------

wire [1:0] WB_WBData = MEMWB_CtrlPacked_Out[1:0];

assign WBData    = WB_WBData;
assign ALU_Result = EXMEM_R_Out;

Mux4to1 WB_WbdataMux(.Input0(EXMEM_R_Out), .Input1(MEMWB_Data_Out), .Input2(MEMWB_PCPlus1_Out), .Input3(32'b0), .Select(WB_WBData), .OutputData(BusW));

endmodule

   
  