module processor(input CLK);
    wire [31:0] pc, next_pc, pc_plus_1, Instruction, BUSA, BUSB, BUSW, ExtendedImmediate, ExtendedOffset, BranchTarget, JumpTarget, ALU_in_B, ALU_Result, Data_out;
    wire [25:0] Offset = Instruction[31:6];
    wire [17:0] Immediate = Instruction[31:14];
    wire [5:0] opcode = Instruction[5:0];
    wire [3:0] Rs = Instruction[13:10], Rt = Instruction[17:14], Rd = Instruction[9:6], DestRegAddress, RW;
    wire [2:0] ALUOp;
    wire [1:0] Wbdata, PCSrc;
    wire  Z, RegDst, LinkSel, ExtOp, RegW, ALUSrc, MemRd, MemWr; 
    Mux4to1_32bit pc_mux(.in0(pc_plus_1), .in1(BranchTarget), .in2(JumpTarget), .in3(BUSA), .sel(PCSrc), .out(next_pc));
    program_counter PC(.clk(CLK), .reset(1'b0), .in(next_pc), .out(pc));
    Adder32 pc_adder(.A(pc), .B(32'd1), .Result(pc_plus_1));
    InstructionMemory inst_mem(.Address(pc), .Instruction(Instruction));
    MainControl main_ctrl(.opcode(opcode[4:0]), .RegDst(RegDst), .LinkSel(LinkSel), .ExtOp(ExtOp), .RegW(RegW), .ALUSrc(ALUSrc), .MemRd(MemRd), .MemWr(MemWr), .Wbdata(Wbdata));
    ALUControl alu_ctrl(.opcode(opcode[4:0]), .ALUOp(ALUOp));
    PCControl pc_ctrl(.opcode(opcode[4:0]), .Z(Z), .PCSrc(PCSrc));
    Mux2to1_4bit RegDstMux(.in0(Rt), .in1(Rd), .sel(RegDst), .out(DestRegAddress));
    Mux2to1_4bit LinkSelMux(.in0(DestRegAddress), .in1(4'b1110), .sel(LinkSel), .out(RW));
    RegisterFile reg_file(.CLK(CLK), .W(RegW), .RA(Rs), .RB(Rt), .RW(RW), .BusW(BUSW), .BusA(BUSA), .BusB(BUSB));
    Extender_18to32 immediateExtender(.in(Immediate), .ExtOp(ExtOp), .out(ExtendedImmediate));
    Extender_26to32 offsetExtender(.in(Offset), .out(ExtendedOffset));
    Adder32 branch_adder(.A(pc_plus_1), .B(ExtendedImmediate), .Result(BranchTarget));
    Adder32 jump_adder(.A(pc_plus_1), .B(ExtendedOffset), .Result(JumpTarget));
    Mux2to1_32bit ALUSrcMux(.in0(BUSB), .in1(ExtendedImmediate), .sel(ALUSrc), .out(ALU_in_B));
    ALU alu(.A(BUSA), .B(ALU_in_B), .ALUOp(ALUOp), .Result(ALU_Result), .Z(Z));
    DataMemory data_mem(.Address(ALU_Result), .Data_in(BUSB), .MemWr(MemWr), .MemRd(MemRd), .clk(CLK), .Data_out(Data_out));
    Mux4to1_32bit WbdataMux(.in0(ALU_Result), .in1(Data_out), .in2(pc_plus_1), .in3(32'b0), .sel(Wbdata), .out(BUSW));

endmodule