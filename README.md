# 🏗️ ENCS4370 Pipelined 32-bit RISC Processor Design

A complete five-stage pipelined RISC processor implementation in Verilog with full datapath, control unit, hazard detection, and data forwarding capabilities.

---

## Table of Contents

- [Project Title](#project-title)
- [Overview](#overview)
- [Features](#features)
- [Processor Architecture](#processor-architecture)
- [Datapath](#datapath)
- [Control Unit](#control-unit)
- [Supported Instructions](#supported-instructions)
- [Project Structure](#project-structure)
- [Modules](#modules)
- [Pipeline Registers](#pipeline-registers)
- [Hazard Handling](#hazard-handling)
- [ALU Operations](#alu-operations)
- [Testing](#testing)
- [Simulation](#simulation)
- [How to Run](#how-to-run)
- [Requirements](#requirements)
- [Design Decisions](#design-decisions)
- [Future Improvements](#future-improvements)
- [License](#license)
- [Authors](#authors)
- [References](#references)

---

## Overview

This project implements a **five-stage pipelined 32-bit RISC processor** with advanced features including:

- **Pipelined Architecture**: Five independent execution stages operating in parallel
- **32-bit Processing**: Full 32-bit instruction and data width
- **16 General-Purpose Registers**: R0 through R15, with R0 hardwired to zero
- **20-Instruction Custom ISA**: 10 R-type, 8 I-type, and 2 J-type instructions (see [Supported Instructions](#supported-instructions))
- **Integrated Hazard Detection**: Data hazard detection and stalling mechanism
- **Data Forwarding**: Forwarding unit to minimize pipeline stalls
- **Memory Subsystem**: Separate instruction and data memory, word-addressable, 1024 words each in simulation (architecturally 4 GB / 2³⁰ words)
- **Branch and Jump Support**: Full control-flow instructions, with the branch condition resolved one stage early (in ID) via a dedicated comparator, limiting the branch penalty to a single flushed instruction
- **Atomic Register/Memory Exchange**: SWAP instruction, enabled by writing data memory on the negative clock edge and reading it on the following positive edge within the same cycle
- **Sign/Zero Extension**: Immediate value extension for I-type instructions

The processor executes a custom RISC instruction set with R-type, I-type, and J-type instruction formats, as defined in the course project specification (ENCS4370, Project 2).

---

## Features

### Core Architecture
- ✅ **32-bit Processor** - Full 32-bit data width
- ✅ **Five-Stage Pipelined Architecture** - IF, ID, EX, MEM, WB stages
- ✅ **16 General-Purpose Registers** - 32 bits each
- ✅ **Register File** - Dual-port read, single-port write (4-to-16 decoder for the write port, two 16-to-1 muxes for the two read ports)

### ALU and Computation
- ✅ **ALU with 8 Operations** - ADD, SUB, AND, OR, XOR, NOR, SLL, SRL
- ✅ **Comparator Unit** - 32-bit equality comparison, placed in the **ID stage** so branches resolve one cycle earlier than an EX-stage comparison would allow
- ✅ **Immediate Extension** - Both sign and zero extension support
- ✅ **32-bit Adder** - For PC and address calculations

### Control Flow
- ✅ **Branch Instructions** - BEQ (Branch if Equal), BNE (Branch if Not Equal)
- ✅ **Jump Instructions** - J (Jump), JAL (Jump and Link), JR (Jump Register)
- ✅ **PC Control Logic** - Dynamic PC update based on branch/jump conditions
- ✅ **Early Branch Resolution** - Branch condition evaluated in the ID stage (not EX and not via prediction), reducing the branch penalty to one flushed instruction. Note: this is *not* branch prediction — true prediction (e.g., a branch target buffer) is listed under [Future Improvements](#future-improvements) and is not implemented.

### Memory System
- ✅ **Instruction Memory** - 32-bit word-addressable, 1024 words in simulation (4 GB architecturally)
- ✅ **Data Memory** - 32-bit word-addressable, 1024 words in simulation (4 GB architecturally), supporting LW, SW, and SWAP
- ✅ **Pipelined Memory Access** - Write on negative edge, read on positive edge (enables SWAP to complete an atomic exchange in a single cycle)

### Hazard Management
- ✅ **Forwarding Unit** - Eliminates data hazards in most cases (EX/MEM, MEM/WB, and WB forwarding paths)
- ✅ **Stall Logic** - Detects load-use hazards and stalls pipeline for one cycle
- ✅ **Instruction Flush** - Kills the single incorrectly-fetched instruction on a taken branch/jump

### Multiplexing
- ✅ **2-to-1 Multiplexers** - For PC source, instruction flush, ALU operand selection
- ✅ **4-to-1 Multiplexers** - For PC selection, write-back data selection, forwarding options
- ✅ **16-to-1 Multiplexers** - Integrated in register file for read operations

---

## Processor Architecture

### Five-Stage Pipeline

The processor executes instructions through five distinct stages:

#### **IF Stage (Instruction Fetch)**
- Fetches 32-bit instruction from instruction memory (combinational/asynchronous read)
- Increments program counter (PC) by 1
- **PC Logic**: Selects among (2-bit `PCSrc`):
  - `00`: PC + 1 (normal sequential)
  - `01`: Jump/JAL target address
  - `10`: Branch address (BEQ/BNE taken)
  - `11`: Register value (JR)
- The fetched instruction is replaced with a hardwired NOP (`CLR R0`) whenever `Kill` is asserted (branch taken or jump executed)

#### **ID Stage (Instruction Decode)**
- Decodes 6-bit opcode and instruction fields
- Reads two operands from register file (Rs, Rt/Rs2 as selected by `RegSrc`)
- Generates control signals (10-bit control vector packed as `{ALUOp[2:0], ExtOp, RegWrite, ALUSrc, MemRead, MemWrite, WBData[1:0]}`)
- Computes immediate/offset extension and the branch/jump target addresses
- Evaluates the branch condition via the **Comparator**, resolving BEQ/BNE in this stage
- Applies data forwarding to the operands *before* they reach the comparator and the ID/EX register
- **Control Signal Generation**:
  - `RegDst`: Selects the destination register address — `0` = Rd field of the instruction, `1` = R14 (hardwired link register, asserted only by JAL)
  - `RegSrc`: Selects which instruction field supplies the second register-read address (`0` = R-type Rt field position, `1` = I-type Rt field position; also asserted for JR/JAL)
  - `ExtOp`: Extension operation — `1` = sign-extend, `0` = zero-extend
  - `RegWrite`: Register write enable
  - `ALUSrc`: ALU operand B selection (register vs. immediate)
  - `MemRead`/`MemWrite`: Memory control
  - `WBDataSelect`: Write-back data multiplexer select

#### **EX Stage (Execute)**
- Performs ALU operation on the (already forwarded) operands
- Selects ALU operand B (register or immediate) via `ALUSrc`
- Produces the ALU result (used as a memory address for LW/SW/SWAP, or as the final result for arithmetic/logical instructions)

#### **MEM Stage (Memory Access)**
- Reads from or writes to data memory (LW, SW, SWAP)
- Memory write occurs on the negative clock edge; memory read occurs on the following positive clock edge — this lets SWAP write the register's old value out and read memory's old value back in the same cycle
- Selects write-back data (ALU result, memory data, PC+1, or zero) via `WBDataSelect`

#### **WB Stage (Write Back)**
- Purely combinational: connects the MEM/WB register outputs to the register file's write port
- Destination register from pipeline register (`Rd4`)
- Respects R0 hardwired-to-zero constraint
- Result is also fed back as the oldest forwarding source (WB forwarding path)

### Data Flow

```
IF → IF/ID Register → ID → ID/EX Register → EX → EX/MEM Register → MEM → MEM/WB Register → WB
        (Stall)                        (Forwarding, Branch Resolution)
```

---

## Datapath

### Register File
- **Capacity**: 16 × 32-bit registers (R0-R15)
- **Read Ports**: 2 (simultaneous, combinational/asynchronous reads of BusA and BusB)
- **Write Port**: 1 (writes to RW on the positive clock edge, when `RegWrite` is asserted)
- **R0 Constraint**: Always reads as 0; any write to R0 is silently ignored (enforced by both gating the write and forcing register 0 to zero every cycle)
- **Implementation**: A 4-to-16 decoder drives the single write port; two independent 16-to-1 multiplexers drive the two read ports

### ALU (Arithmetic Logic Unit)
- **Inputs**: 32-bit operands A and B, 3-bit `ALUCtrl`
- **Outputs**: 32-bit `Result`, 1-bit `Zero` flag
- **Operations**:
  - ADD (3'b000): A + B
  - SUB (3'b100): A - B
  - AND (3'b001): A & B
  - OR (3'b010): A | B
  - XOR (3'b011): A ^ B
  - NOR (3'b101): ~(A | B)
  - SLL (3'b110): A << B[4:0] (Shift Left Logical)
  - SRL (3'b111): A >> B[4:0] (Shift Right Logical)
- **Note**: The `Zero` flag is *not* what resolves BEQ/BNE in the pipelined design — branch resolution uses the dedicated ID-stage Comparator's `Equal` signal instead. `Zero` only matters for the (unused, in this ISA) case of an ALU-result-based decision.

### Instruction Memory
- **Addressing**: 32-bit word address (byte address with bits `[31:2]` used, enforcing word alignment)
- **Capacity**: 1024 words in simulation (architecturally 4 GB / 2³⁰ words), initialized from `imem.mem`
- **Access**: Combinational (reads on the same cycle, no clock dependency)

### Data Memory
- **Addressing**: 32-bit word address (byte address with bits `[31:2]` used; for the 1024-word simulation size this is indexed with `Address[11:2]`)
- **Capacity**: 1024 words in simulation (architecturally 4 GB), initialized from `dmem.mem`
- **Supported operations**: LW, SW, and **SWAP** (atomic register↔memory exchange)
- **Write Timing**: Negative clock edge (synchronous write)
- **Read Timing**: Positive clock edge (synchronous read)
- **Dual-edge Operation**: The write-then-read ordering within one cycle is what makes SWAP possible without a temporary register or a second cycle

### Extender Unit
- **Input Width**: Parameterizable (18-bit for immediates, 26-bit for offsets)
- **Operation**:
  - `ExtOp = 1`: Sign extension (MSB replicated) — used for ADDI, LW, SW, SWAP, BEQ, BNE, and (with `ExtOp` tied low, see below) the J/JAL offset
  - `ExtOp = 0`: Zero extension (padded with zeros) — used for ANDI, ORI
  - For the 26-bit J/JAL offset, `ExtOp` is hardwired to `0` (zero-extended, unsigned offset)
- **Output**: 32 bits

### PC and Address Logic
- **PC Adder**: Increments PC by 1 each cycle
- **Branch/Jump Adder**: Adds the sign/zero-extended immediate or offset to PC (using the IF/ID-latched PC+1) to form the branch or jump target
- **PC Multiplexer**: 4-to-1 mux selecting the next PC source based on `PCSrc[1:0]`

### Pipeline Registers
Four synchronous registers separate pipeline stages. Bit widths below are derived directly from the signals each register is documented to carry (see [Pipeline Registers](#pipeline-registers) for the itemized breakdown):

| Register | Width | Signals Carried |
|----------|-------|-----------------|
| **IF/ID** | 64 bits | Instruction (32), PC+1 (32) |
| **ID/EX** | 150 bits | Control bundle (10), BusA (32), BusB (32), Extended Immediate (32), PC+1 (32), Rd (4), Rs1 (4), Rs2 (4) |
| **EX/MEM** | 105 bits | Control bundle (5), ALU Result (32), Data/RtData (32), PC+1 (32), Rd (4) |
| **MEM/WB** | 37 bits | Write-back data (32), Rd (4), RegWrite (1) |

---

## Control Unit

### Main and ALU Control (MainandALUControl)

The `MainandALUControl` module generates all control signals based on the 6-bit opcode, using the five least-significant bits (A4..A0 = opcode[4:0]); opcode bit 5 is always 0 across all 20 instructions and is unused.

#### Control Signal Outputs
- **RegDst** (1 bit): `0` = destination is the Rd field of the instruction, `1` = destination is R14 (asserted only by JAL)
- **RegSrc** (1 bit): Selects which field supplies the second register-read address
- **ExtOp** (1 bit): `1` = sign-extend the immediate, `0` = zero-extend it
- **RegWrite** (1 bit): Register write enable
- **ALUSrc** (1 bit): ALU operand B selection (register vs. immediate)
- **MemRead** (1 bit): Memory read enable
- **MemWrite** (1 bit): Memory write enable
- **ALUOp** (3 bits): ALU operation selection
- **WBDataSelect** (2 bits): Write-back data multiplexer select — `00` = ALU result, `01` = memory read data, `10` = PC+1 (JAL), `11` = zero (CLR)

#### Control Signal Truth Table (Single-Cycle Control Signals)

| OpCode | 6-bit | Instruction | RegDst | RegSrc | ExtOp | RegWrite | ALUSrc | MemRd | MemWr | WBData |
|---|---|---|---|---|---|---|---|---|---|---|
| 0  | 000000 | ADD  | 0 | 0 | X | 1 | 0 | 0 | 0 | 00 |
| 1  | 000001 | SUB  | 0 | 0 | X | 1 | 0 | 0 | 0 | 00 |
| 2  | 000010 | AND  | 0 | 0 | X | 1 | 0 | 0 | 0 | 00 |
| 3  | 000011 | OR   | 0 | 0 | X | 1 | 0 | 0 | 0 | 00 |
| 4  | 000100 | XOR  | 0 | 0 | X | 1 | 0 | 0 | 0 | 00 |
| 5  | 000101 | NOR  | 0 | 0 | X | 1 | 0 | 0 | 0 | 00 |
| 6  | 000110 | SLL  | 0 | 0 | X | 1 | 0 | 0 | 0 | 00 |
| 7  | 000111 | SRL  | 0 | 0 | X | 1 | 0 | 0 | 0 | 00 |
| 8  | 001000 | CLR  | 0 | X | X | 1 | X | 0 | 0 | 11 |
| 9  | 001001 | JR   | X | X | X | 0 | X | 0 | 0 | X  |
| 10 | 001010 | ADDI | 0 | 1 | 1 | 1 | 1 | 0 | 0 | 00 |
| 11 | 001011 | ANDI | 0 | 1 | 0 | 1 | 1 | 0 | 0 | 00 |
| 12 | 001100 | ORI  | 0 | 1 | 0 | 1 | 1 | 0 | 0 | 00 |
| 13 | 001101 | LW   | 0 | 1 | 1 | 1 | 1 | 1 | 0 | 01 |
| 14 | 001110 | SW   | 0 | 1 | 1 | 0 | 1 | 0 | 1 | X  |
| 15 | 001111 | SWAP | 0 | 1 | 1 | 1 | 1 | 1 | 1 | 01 |
| 16 | 010000 | BEQ  | X | 1 | 1 | 0 | 0 | 0 | 0 | X  |
| 17 | 010001 | BNE  | X | 1 | 1 | 0 | 0 | 0 | 0 | X  |
| 18 | 010010 | J    | X | X | X | 0 | X | 0 | 0 | X  |
| 19 | 010011 | JAL  | 1 | X | X | 1 | X | 0 | 0 | 10 |

*(Source: `Control_Signals.xlsx`, single-cycle control signal sheet, cross-checked against the design report's Table 2.)*

#### Boolean Equations (from the control-signal spreadsheet, A = A4A3A2A1A0)

| Control Signal | Logic Equation |
|---|---|
| ALUOp2 | A4'A3'A2A1 + A4'A3'A1'A0 |
| ALUOp1 | A4'A3'A2A0' + A4'A3'A1A0 + A4'A2A1'A0' + A4A3'A2' |
| ALUOp0 | A4'A3'A2A1' + A4'A3'A2A0 + A4'A3A2'A0 + A4A3'A2' + A3'A2'A1A0' |
| RegDst | A4A3'A2' |
| RegSrc | A4'A3 + A4A3'A2' |
| ExtOp | A4 + A2A1 + (A1⊕A0) |
| RegW (RegWrite) | A4'A3' + A4'A3A2'(A1+A0') + A4'A3A2(A1'+A0) + A4A3'A2'A1A0 |
| ALUSrc | A3 |
| MemRd | A3A2A0 |
| MemWr | A3A2A1 |
| Wbdata1 | A4'A3A2'A1' + A4A3'A2' |
| Wbdata0 | A4'A3A2'A1' + A4'A3A2A0 |
| PCSrc1 | A3A2'A1'A0 + A4A1'(Equal⊕A0) |
| PCSrc0 | A3A2'A1'A0 + A4A1 |

### PC Control

The `PCControl` module determines branch/jump behavior:
- **Inputs**: 6-bit opcode, `Equal` flag from the ID-stage Comparator
- **Outputs**: 2-bit `PCSrc` (selects PC source), `Kill` (flushes the fetched instruction)
- **Logic**:
  - `PCSrc = 00`: PC + 1 (sequential — default)
  - `PCSrc = 01`: Jump/JAL target address
  - `PCSrc = 10`: Branch target address (asserted for BEQ when `Equal=1`, or BNE when `Equal=0`)
  - `PCSrc = 11`: Register value from BusA (JR)
- **Kill**: `Kill = PCSrc[1] | PCSrc[0]` — any non-sequential PC update flushes the instruction currently being fetched, replacing it with `CLR R0` (see [Hazard Handling](#hazard-handling))

---

## Supported Instructions

The processor supports **20 instructions** across three types: R-type (register), I-type (immediate), and J-type (jump), as defined by the ENCS4370 Project 2 specification.

| # | Instruction | Type | Opcode (dec) | Opcode (6-bit) | Description |
|---|-------------|------|---|---|---|
| 1  | **ADD**  | R | 0  | 000000 | Rd ← Rs + Rt |
| 2  | **SUB**  | R | 1  | 000001 | Rd ← Rs - Rt |
| 3  | **AND**  | R | 2  | 000010 | Rd ← Rs & Rt |
| 4  | **OR**   | R | 3  | 000011 | Rd ← Rs \| Rt |
| 5  | **XOR**  | R | 4  | 000100 | Rd ← Rs ^ Rt |
| 6  | **NOR**  | R | 5  | 000101 | Rd ← ~(Rs \| Rt) |
| 7  | **SLL**  | R | 6  | 000110 | Rd ← Rs << Rt |
| 8  | **SRL**  | R | 7  | 000111 | Rd ← Rs >> Rt |
| 9  | **CLR**  | R | 8  | 001000 | Rd ← 0 |
| 10 | **JR**   | R | 9  | 001001 | PC ← Reg(Rs) |
| 11 | **ADDI** | I | 10 | 001010 | Rt ← Rs + SignExt(Imm18) |
| 12 | **ANDI** | I | 11 | 001011 | Rt ← Rs & ZeroExt(Imm18) |
| 13 | **ORI**  | I | 12 | 001100 | Rt ← Rs \| ZeroExt(Imm18) |
| 14 | **LW**   | I | 13 | 001101 | Rt ← Mem[Rs + SignExt(Imm18)] |
| 15 | **SW**   | I | 14 | 001110 | Mem[Rs + SignExt(Imm18)] ← Rt |
| 16 | **SWAP** | I | 15 | 001111 | Exchange Reg(Rt) with Mem[Rs + SignExt(Imm18)] |
| 17 | **BEQ**  | I | 16 | 010000 | if (Rt == Rs) PC ← PC + SignExt(Imm18), else PC ← PC + 1 |
| 18 | **BNE**  | I | 17 | 010001 | if (Rt ≠ Rs) PC ← PC + SignExt(Imm18), else PC ← PC + 1 |
| 19 | **J**    | J | 18 | 010010 | PC ← PC + ZeroExt(Offset26) |
| 20 | **JAL**  | J | 19 | 010011 | R14 ← PC + 1; PC ← PC + ZeroExt(Offset26) |

**Notes**:
- CLR and JR are **R-type**, not I-type — they simply leave the Rs/Rt fields (and, for CLR, Rd's operand fields) unused.
- SWAP is an I-type memory instruction and is fully supported by the data memory's dual-edge read/write timing.
- Immediate values are **sign-extended** for arithmetic, memory-address, and branch instructions, and **zero-extended** for logical instructions (ANDI, ORI), matching `ExtOp=1`/`ExtOp=0` respectively.
- The 26-bit J/JAL offset is zero-extended (`ExtOp` hardwired to 0) in this implementation.

---

## Project Structure

```
ENCS4370_Pipelined_32-bit_RISC_Processor_Design/
│
├── README.md                          # This file
├── CONTRIBUTIONS.md                   # Team member responsibilities and design details
│
├── src/                               # Verilog source files
│   ├── processor.v                    # Top-level processor module (5-stage pipeline)
│   ├── ALU.v                          # Arithmetic Logic Unit (8 operations)
│   ├── Comparator.v                   # 32-bit equality comparator for branches (ID stage)
│   ├── DataMemory.v                   # Data memory (synchronous read/write, supports SWAP)
│   ├── Extender.v                     # Sign/zero extension unit
│   ├── ForwardingUnit.v               # Data hazard forwarding logic
│   ├── InstructionmMemory.v           # Instruction memory
│   ├── MainandALUControl.v            # Main and ALU control signal generation
│   ├── Mux2to1.v                      # 2-to-1 multiplexer (parameterizable)
│   ├── Mux4to1.v                      # 4-to-1 multiplexer (32-bit)
│   ├── PCControl.v                    # PC control logic for branches/jumps
│   ├── RegisterFile.v                 # 16×32-bit register file with 16-to-1 muxes
│   ├── SyncRegister.v                 # Synchronous register (updates on neg-edge)
│   ├── SyncRegisterEn.v               # Synchronous register with enable (pipeline registers)
│   ├── imem.mem                       # Instruction memory initialization file
│   ├── dmem.mem                       # Data memory initialization file
│   ├── tb_processor.v                 # Processor testbench (cycle trace)
│   ├── Processor_Functionallity_TB.v  # Detailed functionality testbench
│   └── wave.asdb                      # ModelSim waveform database
│
├── tests/                             # Binary test files
│   ├── functionallity_test.bin        # Compiled functionality test
│   └── hazard_test.bin                # Compiled hazard test
│
├── assembly programs/                 # Assembly test programs
│   ├── TEST.asm                       # ALU and extender verification program
│   ├── test_program.asm               # Comprehensive instruction test
│   ├── funtionallity_program.asm      # Functionality verification program
│   └── hazard_program.asm             # Data hazard and forwarding test
│
├── waveforms/                         # Simulation waveform files
│   ├── functionallity_test_waveform.asdb
│   ├── hazard_test_waveform.asdb
│   └── wave.asdb
│
├── Pipelined Processor.drawio.svg     # Architecture diagram (Draw.io format)
├── Pipeline_Control_Signals.pdf       # Control signal documentation
├── Control Signals.xlsx               # Detailed control signal truth table (single-cycle)
└── Pipelined_Processor_Design_*.pdf   # Design documentation report

```

### Directory Descriptions

- **`src/`**: Contains all Verilog modules for processor implementation. Start with `processor.v` as the top-level module integrating all stages.

- **`tests/`**: Binary-encoded test programs that can be loaded into instruction memory for processor verification.

- **`assembly programs/`**: Human-readable assembly language test programs demonstrating various processor features:
  - `TEST.asm`: Tests ALU operations and sign/zero extension
  - `test_program.asm`: Full instruction set verification
  - `funtionallity_program.asm`: Basic functionality across all instruction types
  - `hazard_program.asm`: Data hazards and forwarding scenarios

- **`waveforms/`**: ModelSim ASDB (ActiveHDL Simulation Database) files containing timing waveforms from test executions. Open with ModelSim/Questa.

---

## Modules

### **processor.v** (Top-Level Module)
**Purpose**: Integrates all processor components into a complete five-stage pipelined architecture.

**Inputs**:
- `CLK`: Clock signal

**Outputs**: None (internal signals for observation/debugging)

**Key Functionality**:
- Instantiates all pipeline stages and registers
- Manages PC logic and instruction flow
- Coordinates forwarding and stall signals
- Synchronizes control signals through pipeline

**Hierarchy**:
```
processor
├── Instruction Memory
├── Register File
├── ALU
├── Data Memory
├── Comparator (ID stage)
├── Forwarding Unit
├── Control Unit (MainandALUControl + PCControl)
├── Pipeline Registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
├── Multiplexers
├── Adders
└── Extenders
```

---

### **ALU.v** (Arithmetic Logic Unit)
**Purpose**: Performs arithmetic and logical operations on 32-bit operands.

**Inputs**:
- `OperandA[31:0]`: First 32-bit operand
- `OperandB[31:0]`: Second 32-bit operand
- `ALUCtrl[2:0]`: 3-bit operation selector

**Outputs**:
- `ALUResult[31:0]`: 32-bit result
- `Zero`: Asserted when `ALUResult == 0` (used only for ALU-result-based decisions; BEQ/BNE resolution uses the ID-stage Comparator instead)

**Operations**:
| Code | Operation | Description |
|------|-----------|---|
| 3'b000 | ADD | A + B |
| 3'b100 | SUB | A - B |
| 3'b001 | AND | A AND B |
| 3'b010 | OR | A OR B |
| 3'b011 | XOR | A XOR B |
| 3'b101 | NOR | NOT(A OR B) |
| 3'b110 | SLL | A << B[4:0] (Shift Left Logical) |
| 3'b111 | SRL | A >> B[4:0] (Shift Right Logical) |

---

### **Comparator.v**
**Purpose**: Performs 32-bit equality comparison for branch instruction evaluation, placed in the **ID stage** (not EX), so BEQ/BNE resolve one cycle earlier and only a single instruction needs to be flushed on a taken branch.

**Inputs**:
- `A[31:0]`: First 32-bit operand (forwarded BusA)
- `B[31:0]`: Second 32-bit operand (forwarded BusB)

**Outputs**:
- `Equal`: 1 if A == B, 0 otherwise

**Implementation**: Combinational comparison using Verilog equality operator; receives forwarded operands so hazards involving branch sources are handled without extra stall cycles in most cases.

---

### **RegisterFile.v**
**Purpose**: 16×32-bit register storage with dual-read, single-write capability.

**Inputs**:
- `Clk`: Clock signal (writes on positive edge)
- `W`: Write enable
- `RA[3:0]`: Read address A (register index)
- `RB[3:0]`: Read address B (register index)
- `RW[3:0]`: Write address (register index)
- `BUSW[31:0]`: Write data

**Outputs**:
- `BUSA[31:0]`: Read data from register RA
- `BUSB[31:0]`: Read data from register RB

**Special Behavior**:
- R0 (register 0) always reads as 0
- Any write to R0 is ignored
- A 4-to-16 decoder drives the write port; two independent 16-to-1 multiplexers drive the read ports

---

### **MainandALUControl.v**
**Purpose**: Generates all main control signals and ALU control codes from opcode.

**Inputs**:
- `opcode[5:0]`: 6-bit instruction opcode (only bits [4:0] are used; bit 5 is always 0)

**Outputs**:
- `ALUOp[2:0]`: ALU operation selector
- `RegDst`: Register destination selection (0 = Rd field, 1 = R14, asserted only for JAL)
- `RegSrc`: Register source selection
- `ExtOp`: Extension operation (1 = sign, 0 = zero)
- `RegWrite`: Register write enable
- `ALUSrc`: ALU operand B source (0 = register, 1 = immediate)
- `MemRead`: Memory read enable
- `MemWrite`: Memory write enable
- `WBDataSelect[1:0]`: Write-back multiplexer select

**Control Logic**: Implements the combinational Boolean equations shown in [Control Unit](#control-unit), derived from the control signal truth table / spreadsheet.

---

### **ForwardingUnit.v**
**Purpose**: Detects data hazards and generates forwarding signals to minimize stalls.

**Inputs**:
- `RA[3:0]`: Read register A address (ID stage)
- `RB[3:0]`: Read register B address (ID stage)
- `Rd2[3:0]`: Destination register from EX stage (Rd, from ID/EX register)
- `Rd3[3:0]`: Destination register from MEM stage (Rd, from EX/MEM register)
- `Rd4[3:0]`: Destination register from WB stage (Rd, from MEM/WB register)
- `EX_RegWr`: Register write from EX stage
- `MEM_RegWr`: Register write from MEM stage
- `WB_RegWr`: Register write from WB stage
- `EX_MemRd`: Memory read from EX stage

**Outputs**:
- `ForwardA[1:0]`: Forwarding source selector for operand A
  - `2'b00`: No forwarding — use the register file value (ID_BusA)
  - `2'b01`: EX-EX forward — ALU result currently in EX/MEM register (one cycle old)
  - `2'b10`: MEM-EX forward — selected write-back data from the MEM/WB mux (two cycles old)
  - `2'b11`: WB forward — value on BusW currently being written (three cycles old)
- `ForwardB[1:0]`: Forwarding source selector for operand B (same codes)
- `Stall`: Asserted when a load-use hazard is detected

**Hazard Detection Logic**:
- **Data Hazard Forwarding**: Priority order is EX/MEM first, then MEM/WB, then WB. Register R0 is never forwarded (it's hardwired to zero).
- **Load-Use Stall**: Triggers a stall when the instruction in EX is a load (`EX_MemRd = 1`) and the instruction in ID needs that value (`ForwardA == 2'b01` or `ForwardB == 2'b01`).

---

### **DataMemory.v**
**Purpose**: 1024-word × 32-bit data memory with pipelined read/write, supporting LW, SW, and SWAP.

**Inputs**:
- `Clk`: Clock signal
- `Address[31:0]`: Word address (uses bits `[11:2]` for the 1024-word simulation size)
- `Data_In[31:0]`: Data to write
- `W`: Write enable
- `R`: Read enable

**Outputs**:
- `Data_Out[31:0]`: Data read (latched on positive edge)

**Timing**:
- **Write**: Negative clock edge (when `W=1`)
- **Read**: Positive clock edge (when `R=1`)
- **Dual-edge operation** enables both pipelined execution and the atomic SWAP instruction: the register's old value is written to memory on the negative edge, and the previous memory contents are read back on the following positive edge, all within one cycle.

---

### **Extender.v** (Sign/Zero Extender)
**Purpose**: Extends immediate values to 32 bits with configurable sign or zero extension.

**Parameters**:
- `INPUT_WIDTH`: Input data width (default 18 for immediates, 26 for offsets)

**Inputs**:
- `InputData[INPUT_WIDTH-1:0]`: Input value to extend
- `ExtOp`: Extension operation selector
  - `1` = Sign extension (MSB replicated)
  - `0` = Zero extension (padded with zeros)

**Outputs**:
- `ExtendedData[31:0]`: 32-bit extended value

**Note**: For the 26-bit J/JAL offset, `ExtOp` is hardwired to `0` (zero extension).

---

### **Mux2to1.v** (2-to-1 Multiplexer)
**Purpose**: Selects between two inputs based on select signal.

**Parameters**:
- `WIDTH`: Data width (default 32)

**Inputs**:
- `Input0[WIDTH-1:0]`, `Input1[WIDTH-1:0]`: Data inputs
- `Select`: Selector (0 selects Input0, 1 selects Input1)

**Output**:
- `OutputData[WIDTH-1:0]`: Selected data

**Usage**: PC source, instruction flush (real instruction vs. `CLR R0` NOP), ALU operand selection, control signal gating.

---

### **Mux4to1.v** (4-to-1 Multiplexer)
**Purpose**: Selects among four 32-bit inputs.

**Inputs**:
- `Input0[31:0]`, `Input1[31:0]`, `Input2[31:0]`, `Input3[31:0]`: Data inputs
- `Select[1:0]`: Selector (0-3)

**Output**:
- `OutputData[31:0]`: Selected data

**Usage**: PC selection (sequential/jump/branch/register), write-back data selection, forwarding selection.

---

### **PCControl.v** (PC Control Logic)
**Purpose**: Determines next PC selection and instruction flushing for branches/jumps.

**Inputs**:
- `opcode[5:0]`: 6-bit instruction opcode
- `Equal`: Equality flag from comparator

**Outputs**:
- `PCSrc[1:0]`: PC source selector
  - `2'b00`: PCPlus1 (sequential)
  - `2'b01`: Jump/JAL address
  - `2'b10`: Branch address (conditional, taken)
  - `2'b11`: Register value (for JR)
- `Kill`: `PCSrc[1] | PCSrc[0]` — flush instruction signal (high when branch/jump taken)

---

### **SyncRegister.v** (Synchronous Register)
**Purpose**: Stores values at negative clock edge for pipeline stages.

**Parameters**:
- `W`: Register width (default 32)

**Inputs**:
- `clk`: Clock signal
- `in[W-1:0]`: Input data

**Outputs**:
- `out[W-1:0]`: Stored data

**Timing**: Updates on negative clock edge (rising of inverted clock).

---

### **SyncRegisterEn.v** (Enabled Synchronous Register)
**Purpose**: Stores values with enable control for stallable pipeline registers (also used for the PC, so it can freeze during a stall).

**Parameters**:
- `WIDTH`: Register width (default 32)

**Inputs**:
- `clk`: Clock signal
- `en`: Enable signal (when 0, register holds value during stall)
- `in[WIDTH-1:0]`: Input data

**Outputs**:
- `out[WIDTH-1:0]`: Stored data

**Timing**: Updates on negative clock edge when `en` is high.

---

### **InstructionMemory.v**
**Purpose**: Read-only 32-bit instruction storage.

**Inputs**:
- `Address[31:0]`: Word address

**Outputs**:
- `Instruction[31:0]`: Fetched instruction

**Initialization**: Loads from `imem.mem` file. 1024 words in simulation (architecturally 4 GB).

---

### **Adder.v** (32-bit Adder)
**Purpose**: Adds two 32-bit values for PC and address calculations.

**Inputs**:
- `OperandA[31:0]`, `OperandB[31:0]`: Operands to add

**Output**:
- `Result[31:0]`: Sum (ignores overflow)

**Usage**: PC increment (PC+1), branch target (PC+offset), jump target (PC+offset).

---

## Pipeline Registers

### **IF/ID Register** (Instruction Fetch → Instruction Decode)

**Signals Stored** (64 bits):
| Signal | Width | Purpose |
|--------|-------|---------|
| `Instruction` | 32 | Full 32-bit instruction from IF stage (post NOP-mux) |
| `PCPlus1` | 32 | Incremented PC (PC+1), used for branch/jump target computation and JAL linking |

**Characteristics**:
- Transfers instruction and PC+1 to the ID stage
- Can be stalled (enable controlled by `~Stall`)
- Updated on negative clock edge
- Cleared to a NOP bubble on `Flush`/`Reset`

---

### **ID/EX Register** (Instruction Decode → Execute)

**Signals Stored** (150 bits):
| Signal | Width | Purpose |
|--------|-------|---------|
| `CtrlSignals` | 10 | Packed bundle: `{ALUOp[2:0], ExtOp, RegWrite, ALUSrc, MemRead, MemWrite, WBData[1:0]}` |
| `BusA` | 32 | Operand A (from register file, forwarded) |
| `BusB` | 32 | Operand B (from register file, forwarded) |
| `ExtImm` | 32 | Extended immediate value |
| `PCPlus1` | 32 | Incremented PC for JAL write-back |
| `Rd` | 4 | Destination register address |
| `Rs1` | 4 | Source register 1 address (for forwarding comparisons) |
| `Rs2` | 4 | Source register 2 address (for forwarding comparisons) |

**Characteristics**:
- Passes decoded instruction information, forwarded operands, and the 10-bit control bundle to the EX stage
- The control bundle is muxed to all-zeros (a NOP bubble) when `Stall` is asserted; otherwise it always updates
- Updated on negative clock edge

---

### **EX/MEM Register** (Execute → Memory)

**Signals Stored** (105 bits):
| Signal | Width | Purpose |
|--------|-------|---------|
| `CtrlSignals` | 5 | Packed bundle: `{RegWrite, MemRead, MemWrite, WBData[1:0]}` |
| `ALUResult` | 32 | Result from ALU execution (also used as the memory address for LW/SW/SWAP) |
| `Data` | 32 | Forwarded BusB value, needed by SW/SWAP as the store data |
| `PCPlus1` | 32 | PC+1 for JAL write-back |
| `Rd` | 4 | Destination register address |

**Characteristics**:
- Passes execution results to the memory stage
- Control signals consumed in EX (`ALUSrc`, `ALUOp`) are not carried forward, since they are no longer needed
- Cleared to zero on `Flush`/`Reset`; holds its value on `Stall`

---

### **MEM/WB Register** (Memory → Write Back)

**Signals Stored** (37 bits):
| Signal | Width | Purpose |
|--------|-------|---------|
| `Data` | 32 | Write-back data, already selected by the MEM-stage write-back mux (ALU result, memory data, PC+1, or zero) |
| `Rd` | 4 | Destination register address |
| `RegWr` | 1 | Register write enable |

**Characteristics**:
- Final pipeline register before write-back
- Carries the smallest signal set, since the write-back data has already been resolved in MEM

---

## Hazard Handling

### **Implemented Hazard Management**

#### **1. Data Hazards (RAW - Read After Write)**

**Problem**: An instruction tries to read a register before a previous instruction has written to it.

**Solution - Forwarding Unit**:
- Compares operand addresses (RA, RB) with destination registers in later pipeline stages (EX, MEM, WB)
- If a match is found and the destination register is being written, selects the forwarded value instead of the register-file output
- Forwarding priority: EX/MEM (newest) → MEM/WB → WB (oldest)
- Forwarding multiplexers sit in the **ID stage**, before the ID/EX register, so both the EX-stage ALU and the ID-stage Comparator see correctly forwarded operands

#### **2. Load-Use Hazard**

**Problem**: A Load instruction (LW/SWAP) is followed immediately by an instruction using the loaded data. The data isn't available until the MEM stage, so forwarding alone cannot resolve it in time.

**Solution - Stall Logic**:
- The Forwarding Unit detects: `EX_MemRd == 1 && (ForwardA == 2'b01 || ForwardB == 2'b01)`
- Asserts `Stall`, which:
  - Disables the PC and IF/ID registers' enable (`~Stall`), freezing IF and re-decoding the same instruction
  - Forces the ID/EX control bundle to all-zeros for one cycle (a NOP bubble)
- One stall cycle is inserted; after it, forwarding resolves the dependency normally

#### **3. Control Hazards (Branch/Jump)**

**Problem**: The PC can change on a taken branch or a jump, so instructions fetched immediately afterward may be on the wrong path.

**Solution - Early Resolution + Single-Instruction Flush**:
- The dedicated ID-stage Comparator resolves BEQ/BNE **in ID**, one stage earlier than resolving them in EX would allow
- `PCControl` asserts `Kill = PCSrc[1] | PCSrc[0]` whenever the PC takes a non-sequential path (branch taken, J, JAL, or JR)
- `Kill` drives a 2-to-1 mux that replaces the instruction just fetched with `CLR R0` (see NOP encoding below)
- **Net effect: only one instruction is flushed per taken branch/jump** (a 1-cycle branch penalty), not two — because the condition is known by the end of ID rather than the end of EX

Simplified timeline for a taken branch:
```
Cycle:   1    2    3    4
BEQ      IF   ID   EX   ...   (condition resolved at end of cycle 2, in ID)
next     -    IF   (killed)         (wrong-path instruction fetched in cycle 2, flushed before it can affect state)
target   -    -    IF    ID   ...   (correct-path instruction fetched in cycle 3)
```

#### **4. Structural Hazards**

**Status**: Not present in this design.
- Single instruction memory accessed only in IF stage
- Single data memory with separate read/write using dual-edge clocking
- No resource conflicts between pipeline stages

---

### **Hazard Not Implemented**

- **Write-after-Write (WAW) Hazard**: Not possible with a 5-stage in-order pipeline (instructions complete in order)
- **Write-after-Read (WAR) Hazard**: Not possible (pipeline is in-order)
- **Out-of-Order Execution**: Not implemented (pipeline is strictly in-order)

---

## NOP Encoding

The pipeline's flush/bubble instruction is **`CLR R0`**, not an all-zero instruction word:

```
opcode = 001000 (CLR)   Rd = 0000 (R0)   Rs = 0000   Rt = 0000   unused = 00000000000000
32'b 001000_0000_0000_0000_00000000000000
```

**Why not an all-zero word?** An all-zero instruction decodes as `ADD R0, R0, R0`, which still asserts `RegWrite` and could create spurious matches in the Forwarding Unit. `CLR R0` has `Rd = 0`; since R0 is hardwired to zero and the Forwarding Unit never forwards from R0, this flush instruction is guaranteed to have no side effects in any pipeline stage.

---

## ALU Operations

The ALU supports 8 different operations selected by a 3-bit control signal:

| ALUCtrl | Operation | Function | Example |
|---------|-----------|----------|---------|
| 3'b000 | **ADD** | Addition | ADD R1, R2, R3 → R1 = R2 + R3 |
| 3'b100 | **SUB** | Subtraction | SUB R1, R2, R3 → R1 = R2 - R3 |
| 3'b001 | **AND** | Bitwise AND | AND R1, R2, R3 → R1 = R2 & R3 |
| 3'b010 | **OR** | Bitwise OR | OR R1, R2, R3 → R1 = R2 \| R3 |
| 3'b011 | **XOR** | Bitwise XOR | XOR R1, R2, R3 → R1 = R2 ^ R3 |
| 3'b101 | **NOR** | Bitwise NOR | NOR R1, R2, R3 → R1 = ~(R2 \| R3) |
| 3'b110 | **SLL** | Shift Left Logical | SLL R1, R2, R3 → R1 = R2 << R3[4:0] |
| 3'b111 | **SRL** | Shift Right Logical | SRL R1, R2, R3 → R1 = R2 >> R3[4:0] |

**Shift Operations**: Only the lower 5 bits of operand B are used as the shift amount (max shift = 31 bits). BEQ/BNE use `ALUOp = 011` (XOR) purely as a legacy/don't-care value in the single-cycle equations table — actual branch resolution in the pipelined design comes from the dedicated Comparator, not the ALU.

---

## Testing

### **Available Testbenches**

#### **1. Processor_Functionallity_TB.v** (Detailed Verification)
**Purpose**: Comprehensive processor-level testbench that verifies all functionality.

**Features**:
- Cycle-by-cycle execution trace
- Displays pipeline signals and ALU operations
- Monitors all 16 registers
- Verifies data memory contents

**Execution**:
- Initializes register file with test values
- Initializes data memory
- Monitors final register state
- Displays detailed execution trace with formatting

#### **2. tb_processor.v** (Cycle Trace Testbench)
**Purpose**: Simpler testbench with periodic status reporting.

**Features**:
- Reports every 10 time units (10 ns clock period)
- Displays PC, opcode, ALU result, write-back data
- Shows stall and forwarding status

### **Test Programs**

#### **TEST.asm** - ALU & Extender Verification
Tests sign/zero extension and all ALU operations, including zero-flag/branch behavior (BEQ).

#### **funtionallity_program.asm** - Full Instruction Set
Comprehensive test covering all arithmetic, logical, shift, memory (LW/SW/SWAP), branch (BEQ/BNE), jump (J/JAL/JR), and CLR instructions.

#### **hazard_program.asm** - Data Hazards & Forwarding
Stress test for data hazard detection and forwarding, including load-use stalls and branch effects.

#### **Binary Test Files**
- `functionallity_test.bin`: Compiled binary of `funtionallity_program.asm`
- `hazard_test.bin`: Compiled binary of `hazard_program.asm`

---

## Simulation

### **Supported Simulators**

The design is compatible with:
- **ModelSim / Questa Sim** (Primary - waveforms provided)
- **Icarus Verilog** (iverilog)
- **Vivado Simulator**
- **Quartus II Simulator**

### **ModelSim / Questa Simulation**

#### **Compilation**
```bash
vlib work
vmap work ./work
vlog src/*.v
```

#### **Simulation (Functionality Test)**
```bash
vsim -c Processor_Functionallity_TB -do "run -all; quit"
```

#### **Waveform Viewing**
```bash
vsim -view waveforms/functionallity_test_waveform.asdb
```

### **Icarus Verilog Simulation**

```bash
iverilog -o sim.vvp src/*.v
vvp sim.vvp
gtkwave dump.vcd &
```

### **Memory File Configuration**

**Instruction Memory**: Load from `imem.mem` (hex-encoded 32-bit instructions, one per line)

**Data Memory**: Load from `dmem.mem`

---

## How to Run

### **Step 1: Obtain the Repository**
```bash
git clone https://github.com/Amjad-Adi/ENCS4370_Pipelined_32-bit_RISC_Processor_Design.git
cd ENCS4370_Pipelined_32-bit_RISC_Processor_Design
```

### **Step 2: Compile**
```bash
# ModelSim
vlib work
vmap work ./work
vlog src/*.v

# or Icarus Verilog
iverilog -o processor_sim.vvp src/*.v
```

### **Step 3: Run**
```bash
# ModelSim
vsim -c Processor_Functionallity_TB -do "run -all; quit"

# Icarus Verilog
vvp processor_sim.vvp
```

### **Step 4: View Waveforms**
```bash
vsim -view waveforms/functionallity_test_waveform.asdb
# or
gtkwave dump.vcd &
```

### **Step 5: Verify Output**

Final register values should match the expected results in the design report (Table 5 for the single-cycle/functionality test, Table 6 for the pipelined test) — note the two tests use different initial register/memory contents and therefore different expected final values, but both confirm correct instruction execution.

---

## Requirements

### **Software Requirements**

| Tool | Version | Purpose |
|------|---------|---------|
| **Verilog Compiler** | 2001/2005/SV2012 | HDL compilation |
| **ModelSim / Questa Sim** | 10.0+ | Simulation & waveform viewing |
| **Icarus Verilog** | v10.0+ | Open-source simulator |
| **GTKWave** | 3.3+ | Waveform viewer (for VCD files) |
| **Text Editor** | Any | Source code editing |

### **System Requirements**

- **OS**: Windows, Linux, or macOS
- **Build Tools**: GCC (for compilation), Make (optional)

---

## Design Decisions

### **1. Five-Stage Pipeline Over Single-Cycle**
Increases instruction throughput and provides educational depth on hazards, forwarding, and control flow, at the cost of added hazard-management complexity.

### **2. Dual-Edge Clocking for Memory**
Data memory reads on the positive edge and writes on the negative edge, enabling pipelined access without a second port — and, critically, letting **SWAP** perform its atomic register/memory exchange within a single cycle (write old register value on negedge, read old memory value back on the following posedge).

### **3. Forwarding Muxes Placed in the ID Stage**
The forwarding multiplexers sit before the ID/EX register, so their outputs feed both the EX-stage ALU and the ID-stage Comparator — the comparator never needs its own separate forwarding hardware.

### **4. Branch Resolution in the ID Stage**
BEQ/BNE are resolved by a dedicated ID-stage Comparator rather than the ALU's `Zero` flag in EX. A taken branch therefore kills only **one** fetched instruction (a 1-cycle penalty) instead of two.

### **5. Stall by Freezing PC and IF/ID Registers**
Load-use hazards are handled by de-asserting the enable of the PC and IF/ID registers (`en = ~Stall`) for one cycle, while the ID/EX control bundle is forced to all-zeros.

### **6. NOP Encoded as `CLR R0`**
Rather than an all-zero word (which would decode as `ADD R0,R0,R0` and assert `RegWrite`), the flush instruction is `CLR R0` — since R0 is hardwired to zero and never forwarded, this produces no side effects anywhere in the pipeline.

### **7. PC+1 Propagated Through All Pipeline Stages**
Needed so JAL can write the correct return address to R14 at the WB stage, several cycles after the instruction was fetched.

### **8. Control Signals Packed into Single Pipeline Registers**
All ID→EX control signals are packed into one 10-bit bundle, and EX→MEM into a 5-bit bundle — this keeps the stall-bubble logic to a single all-zero assignment and keeps stage boundaries unambiguous.

### **9. Destination Register Propagated as Rd2, Rd3, Rd4**
Naming the destination register explicitly at each stage makes the Forwarding Unit's priority (Rd2 highest, then Rd3, then Rd4) unambiguous in the implementation.

### **10. 16 Register Architecture / Word-Addressable Memory / R0 Hardwired to Zero**
Standard RISC design choices: 4-bit register addressing fits the instruction encoding, word addressing simplifies the memory interface, and R0-as-zero is a common MIPS/RISC-V convention that simplifies addressing and default values.

---

## Future Improvements

### **Performance Enhancements**
1. **Branch Prediction**: Implement a branch target buffer (BTB) or static prediction to reduce the branch penalty from 1 cycle to 0 — *not implemented in the current design*, which only performs early (ID-stage) resolution, not prediction
2. **Superscalar Execution**: Allow 2-3 instructions per cycle with multiple ALUs and fetch units
3. **Cache System**: Add L1 instruction and data caches to reduce memory latency
4. **Dynamic Branch Prediction**: Implement Gshare or a tournament predictor for higher accuracy

### **Feature Additions**
5. **Exception Handling**: Add interrupt and exception support with trap handlers
6. **Floating-Point Unit**: Extend the ISA with FPU operations and floating-point registers
7. **Virtual Memory**: Implement an MMU with TLB for address translation
8. **Extended Instruction Set**: Add multiply/divide, bit manipulation, vector operations

### **Memory System**
9. **Wider Memory Bus**: Increase to 64-bit or 128-bit for higher throughput
10. **Memory Controller**: Add a DRAM controller with refresh and timing control
11. **Coherence Protocol**: For a multi-core version (MSI/MESI/MOESI)

### **Design Verification**
12. **Formal Verification**: Prove correctness properties with model checking
13. **Comprehensive Testbenches**: Generate random instruction sequences for stress testing
14. **Power Analysis**: Add power measurement and optimization

### **Educational Enhancements**
15. **Simulator Improvements**: Add a GUI debugger with breakpoint/step-through support
16. **Assembly Compiler**: Develop a simple assembler to compile `.asm` files to `.mem` files
17. **Interactive Visualization**: Real-time visualization of pipeline state and data flow

---

## License

Not specified in the repository. This is a university coursework project (ENCS4370 course at Birzeit University).

**Status**: Open source for educational use. Please refer to the university's policy or contact the authors for licensing information.

---

## Authors

### **Team Members and Responsibilities**

*(Per the design report cover page and Teamwork section — each member holds an equal 33.3% share, split by clean, non-overlapping component ownership across both the single-cycle and pipelined phases.)*

#### **Hanan Alawawda — Student ID: 1230827 (33.3%)**
- The ALU and Extender unit, plus their single-cycle test program
- The complete pipelined processor testbench (every stage, write-back, memory ops, branch behavior)
- Redrew the architecture diagram from single-cycle to five-stage pipeline

#### **Amir Abdel-Jabbar — Student ID: 1231192 (33.3%)**
- Memory units (Instruction Memory, Data Memory), Register File, the 32-bit adder and 2-to-1 mux, and the single-cycle assembly test program
- Extending into the pipeline: synchronizing Data Memory to split-edge read/write, designing all four pipeline registers, building the Comparator unit, and producing the full control-signal spreadsheet

#### **Amjad Qaher — Student ID: 1230800 (33.3%)**
- Control unit design and signal generation, plus system integration and datapath assembly for the single-cycle design
- Assembling and integrating the entire five-stage pipeline, wiring in every component, and supporting final validation against the testbench

---

## References

### **Course Information**
- **Course**: ENCS4370 (Computer Architecture)
- **Institution**: Birzeit University, Faculty of Engineering and Technology, Electrical and Computer Engineering Department
- **Semester**: Spring 2025-2026

### **Documentation Files in Repository**
- `Pipelined_Processor_Design_*.pdf` - Complete design documentation report
- `Pipeline_Control_Signals.pdf` - Control signal definitions and flow
- `Control Signals.xlsx` - Detailed control signal truth table (single-cycle)
- `Pipelined Processor.drawio.svg` - Architecture diagram

### **Textbooks and References**
1. Lucid Software Inc., *Lucidchart* — flowcharts, diagrams, and system visualizations. https://www.lucidchart.com
2. JGraph Ltd., *draw.io (diagrams.net)* — Datapath diagrams and architectural illustrations. https://www.diagrams.net
3. David A. Patterson and John L. Hennessy, *Computer Organization and Design: The Hardware/Software Interface*, Morgan Kaufmann.
4. David A. Patterson and John L. Hennessy, *Computer Architecture: A Quantitative Approach*, Morgan Kaufmann.
5. Morris Mano and Michael D. Ciletti, *Digital Design*, Pearson.
6. Course lecture slides, laboratory materials, and instructor-provided resources.

---

**Repository**: https://github.com/Amjad-Adi/ENCS4370_Pipelined_32-bit_RISC_Processor_Design
