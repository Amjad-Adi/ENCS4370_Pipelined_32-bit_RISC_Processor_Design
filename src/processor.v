module processor(input CLK);
    wire [31:0] pc, next_pc, pc_plus_1, Instruction, BUSA, BUSB, BUSW, ExtendedImmediate, ExtendedOffset, BranchTarget, JumpTarget, ALU_in_B, ALU_Result, Data_out;
    wire [25:0] Offset = Instruction[31:6];
    wire [17:0] Immediate = Instruction[31:14];
    wire [5:0] opcode = Instruction[5:0];
    wire [3:0] Rs = Instruction[13:10], Rt = Instruction[17:14], Rd = Instruction[9:6], DestRegAddress, RW;
    wire [2:0] ALUOp;
    wire [1:0] Wbdata, PCSrc;
    wire  Z, RegDst, LinkSel, ExtOp, RegW, ALUSrc, MemRd, MemWr; 
    Mux4to1 pc_mux(.in0(pc_plus_1), .in1(BranchTarget), .in2(JumpTarget), .in3(BUSA), .sel(PCSrc), .out(next_pc));
    pc_register PC(.clk(CLK), .reset(1'b0), .in(next_pc), .out(pc));
    Adder32bit pc_adder(.A(pc), .B(32'd1), .Sum(pc_plus_1));
    InstructionMemory inst_mem(.Address(pc), .Instruction(Instruction));
    MainControl main_ctrl(.opcode(opcode[4:0]), .RegDst(RegDst), .LinkSel(LinkSel), .ExtOp(ExtOp), .RegW(RegW), .ALUSrc(ALUSrc), .MemRd(MemRd), .MemWr(MemWr), .Wbdata(Wbdata));
    ALUControl alu_ctrl(.opcode(opcode[4:0]), .ALUOp(ALUOp));
    PCControl pc_ctrl(.opcode(opcode[4:0]), .Z(Z), .PCSrc(PCSrc));
    Mux2to1  #(.N(4)) RegDstMux(.In0(Rt), .In1(Rd), .Sel(RegDst), .Out(DestRegAddress));
    Mux2to1  #(.N(4)) LinkSelMux(.In0(DestRegAddress), .In1(4'b1110), .Sel(LinkSel), .Out(RW));
	RegisterFile reg_file (.Clk(CLK),.RegWrite(RegW),.RdAddr(RW),.RsAddr(Rs),.RtAddr(Rt),.WriteData(BUSW),.RsData(BUSA),.RtData(BUSB));
	Extender18bit immediateExtender (.Imm(Immediate),.ExtOp(ExtOp),.ExtImm(ExtendedImmediate));
	Extender26bit offsetExtender (.Imm(Offset),.ExtImm(ExtendedOffset));
    Adder32bit branch_adder(.A(pc_plus_1), .B(ExtendedImmediate), .Sum(BranchTarget));
    Adder32bit jump_adder(.A(pc_plus_1), .B(ExtendedOffset), .Sum(JumpTarget));
    Mux2to1 ALUSrcMux(.In0(BUSB), .In1(ExtendedImmediate), .Sel(ALUSrc), .Out(ALU_in_B));
    ALU alu(.A(BUSA), .B(ALU_in_B), .ALUCtrl(ALUOp), .Result(ALU_Result), .Zero(Z));
	DataMemory data_mem (.Clk(CLK),.Address(ALU_Result),.WriteData(BUSB),.MemWrite(MemWr),.MemRead(MemRd),.ReadData(Data_out));
    Mux4to1 WbdataMux(.in0(ALU_Result), .in1(Data_out), .in2(pc_plus_1), .in3(32'b0), .sel(Wbdata), .out(BUSW));

endmodule