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
- **Integrated Hazard Detection**: Data hazard detection and stalling mechanism
- **Data Forwarding**: Forwarding unit to minimize pipeline stalls
- **Memory Subsystem**: Separate instruction and data memory with word-addressable organization
- **Branch and Jump Support**: Full control flow instructions with proper branch prediction through comparator
- **Sign/Zero Extension**: Immediate value extension for I-type instructions

The processor is designed to execute a custom RISC instruction set with R-type, I-type, and J-type instruction formats.

---

## Features

### Core Architecture
- ✅ **32-bit Processor** - Full 32-bit data width
- ✅ **Five-Stage Pipelined Architecture** - IF, ID, EX, MEM, WB stages
- ✅ **16 General-Purpose Registers** - 32 bits each
- ✅ **Register File** - Dual-port read, single-port write

### ALU and Computation
- ✅ **ALU with 8 Operations** - ADD, AND, OR, XOR, SUB, NOR, SLL, SRL
- ✅ **Comparator Unit** - 32-bit equality comparison for branch instructions
- ✅ **Immediate Extension** - Both sign and zero extension support
- ✅ **32-bit Adder** - For PC and address calculations

### Control Flow
- ✅ **Branch Instructions** - BEQ (Branch if Equal), BNE (Branch if Not Equal)
- ✅ **Jump Instructions** - J (Jump), JAL (Jump and Link), JR (Jump Register)
- ✅ **PC Control Logic** - Dynamic PC update based on branch/jump conditions
- ✅ **Branch Prediction** - Instruction flush on taken branches

### Memory System
- ✅ **Instruction Memory** - 32-bit word-addressable
- ✅ **Data Memory** - 32-bit word-addressable with 4GB capacity (256 words in simulation)
- ✅ **Pipelined Memory Access** - Write on negative edge, read on positive edge

### Hazard Management
- ✅ **Forwarding Unit** - Eliminates data hazards in most cases
- ✅ **Stall Logic** - Detects load-use hazards and stalls pipeline
- ✅ **Instruction Flush** - Kills instructions on branch/jump taken

### Multiplexing
- ✅ **2-to-1 Multiplexers** - For PC source, instruction flush, ALU operand selection
- ✅ **4-to-1 Multiplexers** - For PC selection, write-back data selection, forwarding options
- ✅ **16-to-1 Multiplexers** - Integrated in register file for read operations

---

## Processor Architecture

### Five-Stage Pipeline

The processor executes instructions through five distinct stages:

#### **IF Stage (Instruction Fetch)**
- Fetches 32-bit instruction from instruction memory
- Increments program counter (PC) by 1
- Computes next PC for branches/jumps
- **PC Logic**: Selects among:
  - PC + 1 (normal sequential)
  - Jump address (J instruction)
  - Branch address (BEQ/BNE taken)
  - Register value (JR instruction)

#### **ID Stage (Instruction Decode)**
- Decodes 6-bit opcode and instruction fields
- Reads two operands from register file (Rs1, Rs2)
- Generates control signals (10-bit control vector)
- Computes immediate and offset extensions
- Performs branch address calculation
- Applies data forwarding to bypass operands
- **Control Signal Generation**:
  - RegDst: Register destination selection
  - RegSrc: Register source selection
  - ExtOp: Extension operation (sign/zero)
  - RegWrite: Register write enable
  - ALUSrc: ALU operand B selection
  - MemRead/MemWrite: Memory control
  - WBDataSelect: Write-back data multiplexer select

#### **EX Stage (Execute)**
- Performs ALU operation on operands
- Selects ALU operand B (register or immediate)
- Computes address calculations
- Passes data for memory operations

#### **MEM Stage (Memory Access)**
- Reads from or writes to data memory
- Memory write occurs on negative clock edge
- Memory read occurs on positive clock edge
- Selects write-back data (ALU result, memory data, or PC+1)

#### **WB Stage (Write Back)**
- Writes computation results to register file
- Destination register from pipeline register
- Respects R0 hardwired-to-zero constraint
- Results available for forwarding in next cycles

### Data Flow

```
IF → IFID Register → ID → IDEX Register → EX → EXMEM Register → MEM → MEMWB Register → WB
          (Stall)                    (Forwarding)
```

---

## Datapath

### Register File
- **Capacity**: 16 × 32-bit registers (R0-R15)
- **Read Ports**: 2 (simultaneous reads of RA and RB)
- **Write Port**: 1 (writes to RW on positive clock edge)
- **R0 Constraint**: Always reads as 0, writes are ignored
- **Implementation**: 16-to-1 multiplexers for each read port

### ALU (Arithmetic Logic Unit)
- **Inputs**: 32-bit operands A and B, 3-bit control signal
- **Operations**:
  - ADD (3'b000): A + B
  - AND (3'b001): A & B
  - OR (3'b010): A | B
  - XOR (3'b011): A ^ B
  - SUB (3'b100): A - B
  - NOR (3'b101): ~(A | B)
  - SLL (3'b110): A << B[4:0] (Shift Left Logical)
  - SRL (3'b111): A >> B[4:0] (Shift Right Logical)

### Instruction Memory
- **Addressing**: 32-bit word address
- **Capacity**: Initialized from `imem.mem` file
- **Access**: Combinational (reads on same cycle)

### Data Memory
- **Addressing**: 32-bit word address (byte address with [9:2] index)
- **Capacity**: 256 words (initialized from `dmem.mem`)
- **Write Timing**: Negative clock edge (synchronous write)
- **Read Timing**: Positive clock edge (synchronous read)
- **Dual-edge Operation**: Enables pipelined read/write

### Extender Unit
- **Input Width**: Parameterizable (18-bit for immediates, 26-bit for offsets)
- **Operation**:
  - ExtOp = 0: Sign extension (MSB replicated)
  - ExtOp = 1: Zero extension (padded with zeros)
- **Output**: 32 bits

### PC and Address Logic
- **PC Adder**: Increments PC by 1 each cycle
- **Branch Adder**: Adds immediate offset to PC for branch target
- **Jump Adder**: Adds offset to PC for jump target
- **PC Multiplexer**: 4-to-1 mux selecting next PC source based on instruction type

### Pipeline Registers
Four synchronous registers separate pipeline stages:

| Register | Width | Signals Carried |
|----------|-------|-----------------|
| **IF/ID** | 64 bits | Instruction (32), PC (32) |
| **ID/EX** | 85 bits | Control signals (10), BusA (32), BusB (32), Immediate (32), PCPlus1 (32), Rd/Rs1/Rs2 (4) |
| **EX/MEM** | 74 bits | Control signals (5), ALU Result (32), Data (32), PCPlus1 (32), Rd (4) |
| **MEM/WB** | 37 bits | Write-back data (32), Rd (4), RegWrite (1) |

---

## Control Unit

### Main Control and ALU Control Module

The `MainandALUControl` module generates all control signals based on the 6-bit opcode:

#### Control Signal Outputs
- **RegDst** (1 bit): Register destination selection
- **RegSrc** (1 bit): Register source (Rs2) selection
- **ExtOp** (1 bit): Extension operation (sign/zero)
- **RegWrite** (1 bit): Register write enable
- **ALUSrc** (1 bit): ALU operand B selection (register vs. immediate)
- **MemRead** (1 bit): Memory read enable
- **MemWrite** (1 bit): Memory write enable
- **ALUOp** (3 bits): ALU operation selection
- **WBDataSelect** (2 bits): Write-back data multiplexer select

#### Control Signal Generation Logic
Control signals are generated using combinational logic based on opcode bits:

```verilog
// Example signal generation
RegDst = A4 & ~A3 & ~A2
RegWrite = (~A4 & ~A3) | (~A4 & A3 & ~A2 & (A1 | ~A0)) | ...
ALUSrc = A3
MemRead = A3 & A2 & A0
MemWrite = A3 & A2 & A1
```

### PC Control

The `PCControl` module determines branch/jump behavior:
- **Inputs**: 6-bit opcode, equality flag from comparator
- **Outputs**: 2-bit PCSrc (selects PC source), Kill signal (flushes instruction)
- **Logic**:
  - PCSrc[1:0] = 00: PC + 1 (sequential)
  - PCSrc[1:0] = 01: Jump address
  - PCSrc[1:0] = 10: Branch address
  - PCSrc[1:0] = 11: Register value (JR)
- **Kill**: Asserted when branch/jump taken to flush next instruction

---

## Supported Instructions

The processor supports 16 instructions across three types: R-type (register), I-type (immediate), and J-type (jump).

| Instruction | Type | Opcode (6-bit) | Funct (if R-type) | Description |
|-------------|------|---|---|---|
| **ADD** | R | 000000 | - | Rd ← Rs1 + Rs2 |
| **SUB** | R | 000000 | - | Rd ← Rs1 - Rs2 |
| **AND** | R | 000000 | - | Rd ← Rs1 & Rs2 |
| **OR** | R | 000000 | - | Rd ← Rs1 \| Rs2 |
| **XOR** | R | 000000 | - | Rd ← Rs1 ^ Rs2 |
| **NOR** | R | 000000 | - | Rd ← ~(Rs1 \| Rs2) |
| **SLL** | R | 000000 | - | Rd ← Rs1 << Rs2 |
| **SRL** | R | 000000 | - | Rd ← Rs1 >> Rs2 |
| **ADDI** | I | 001010 | - | Rd ← Rs1 + SignExt(Imm18) |
| **ANDI** | I | 100010 | - | Rd ← Rs1 & ZeroExt(Imm18) |
| **ORI** | I | 100110 | - | Rd ← Rs1 \| ZeroExt(Imm18) |
| **CLR** | I | 001000 | - | Rd ← 0 |
| **LW** | I | 100011 | - | Rd ← Mem[Rs1 + SignExt(Imm18)] |
| **SW** | I | 101001 | - | Mem[Rs1 + SignExt(Imm18)] ← Rd |
| **BEQ** | I | 010000 | - | if (Rs1 == Rs2) PC ← PC + SignExt(Offset18) |
| **BNE** | I | 010001 | - | if (Rs1 ≠ Rs2) PC ← PC + SignExt(Offset18) |
| **J** | J | 010010 | - | PC ← PC + ZeroExt(Offset26) |
| **JAL** | J | 010011 | - | R14 ← PC + 1; PC ← PC + ZeroExt(Offset26) |
| **JR** | J | 010100 | - | PC ← R[Rd] |

**Note**: Exact opcode values are derived from the control unit logic. R-type instructions share opcode 000000 and are differentiated by function code (3-bit ALUOp field).

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
│   ├── Comparator.v                   # 32-bit equality comparator for branches
│   ├── DataMemory.v                   # Data memory (synchronous read/write)
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
├── Control Signals.xlsx               # Detailed control signal spreadsheet
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
├── Comparator
├── Forwarding Unit
├── Control Unit
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

**Operations**:
| Code | Operation | Description |
|------|-----------|---|
| 3'b000 | ADD | A + B |
| 3'b001 | AND | A AND B |
| 3'b010 | OR | A OR B |
| 3'b011 | XOR | A XOR B |
| 3'b100 | SUB | A - B |
| 3'b101 | NOR | NOT(A OR B) |
| 3'b110 | SLL | A << B[4:0] (Shift Left Logical) |
| 3'b111 | SRL | A >> B[4:0] (Shift Right Logical) |

---

### **Comparator.v**
**Purpose**: Performs 32-bit equality comparison for branch instruction evaluation.

**Inputs**:
- `A[31:0]`: First 32-bit operand
- `B[31:0]`: Second 32-bit operand

**Outputs**:
- `Equal`: 1 if A == B, 0 otherwise

**Implementation**: Combinational comparison using Verilog equality operator.

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
- Dual 16-to-1 multiplexers for read operations

---

### **MainandALUControl.v**
**Purpose**: Generates all main control signals and ALU control codes from opcode.

**Inputs**:
- `opcode[5:0]`: 6-bit instruction opcode

**Outputs**:
- `ALUOp[2:0]`: ALU operation selector
- `RegDst`: Register destination selection (0=inst1, 1=inst3)
- `RegSrc`: Register source selection
- `ExtOp`: Extension operation (0=sign, 1=zero)
- `RegWrite`: Register write enable
- `ALUSrc`: ALU operand B source (0=register, 1=immediate)
- `MemRead`: Memory read enable
- `MemWrite`: Memory write enable
- `WBDataSelect[1:0]`: Write-back multiplexer select

**Control Logic**: Implements combinational logic equations derived from the control signal truth table.

---

### **ForwardingUnit.v**
**Purpose**: Detects data hazards and generates forwarding signals to minimize stalls.

**Inputs**:
- `RA[3:0]`: Read register A address (ID stage)
- `RB[3:0]`: Read register B address (ID stage)
- `Rd2[3:0]`: Destination register from EX stage (Rd)
- `Rd3[3:0]`: Destination register from MEM stage (Rd)
- `Rd4[3:0]`: Destination register from WB stage (Rd)
- `EX_RegWr`: Register write from EX stage
- `MEM_RegWr`: Register write from MEM stage
- `WB_RegWr`: Register write from WB stage
- `EX_MemRd`: Memory read from EX stage

**Outputs**:
- `ForwardA[1:0]`: Forwarding source selector for operand A
  - 2'b00: No forwarding (use RA)
  - 2'b01: Forward from EX (ALU result)
  - 2'b10: Forward from MEM (computed/memory data)
  - 2'b11: Forward from WB (final result)
- `ForwardB[1:0]`: Forwarding source selector for operand B (same codes)
- `Stall`: Asserted when load-use hazard detected

**Hazard Detection Logic**:
- **Data Hazard Forwarding**: Compares operand addresses with destination registers of pending instructions
- **Load-Use Stall**: Triggers stall when EX stage produces memory read that ID stage immediately needs

---

### **DataMemory.v**
**Purpose**: 256-word×32-bit data memory with pipelined read/write.

**Inputs**:
- `Clk`: Clock signal
- `Address[31:0]`: Word address (uses bits [9:2])
- `Data_In[31:0]`: Data to write
- `W`: Write enable
- `R`: Read enable

**Outputs**:
- `Data_Out[31:0]`: Data read (latched on positive edge)

**Timing**:
- **Write**: Negative clock edge (when W=1)
- **Read**: Positive clock edge (when R=1)
- **Dual-edge operation** enables pipelined execution

---

### **Extender.v** (Sign/Zero Extender)
**Purpose**: Extends immediate values to 32 bits with configurable sign or zero extension.

**Parameters**:
- `INPUT_WIDTH`: Input data width (default 18 for immediates, 26 for offsets)

**Inputs**:
- `InputData[INPUT_WIDTH-1:0]`: Input value to extend
- `ExtOp`: Extension operation selector
  - 0 = Sign extension (MSB replicated)
  - 1 = Zero extension (padded with zeros)

**Outputs**:
- `ExtendedData[31:0]`: 32-bit extended value

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

**Usage**: PC source, instruction flush, ALU operand selection, control signal gating.

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
  - 2'b00: PCPlus1 (sequential, next PC = PC + 1)
  - 2'b01: Jump address
  - 2'b10: Branch address (conditional)
  - 2'b11: Register value (for JR)
- `Kill`: Flush instruction signal (high when branch/jump taken)

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
**Purpose**: Stores values with enable control for stallable pipeline registers.

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

**Initialization**: Loads from `imem.mem` file.

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
| `Instruction` | 32 | Full 32-bit instruction from IF stage |
| `PC` | 32 | Program counter value from IF stage |
| `PCPlus1` | 32 | Incremented PC (PC+1) from IF stage |

**Characteristics**:
- Transfers instruction and PC information to ID stage
- Can be stalled (enable controlled by `~Stall` signal)
- Updated on negative clock edge
- Allows ID stage to decode instruction while IF fetches next

---

### **ID/EX Register** (Instruction Decode → Execute)

**Signals Stored** (85 bits):
| Signal | Width | Purpose |
|--------|-------|---------|
| `CtrlSignals` | 10 | Control signals: ALUOp(3), ExtOp(1), RegWr(1), ALUSrc(1), MemRd(1), MemWr(1), WBData(2) |
| `BusA` | 32 | Operand A (from register file, possibly forwarded) |
| `BusB` | 32 | Operand B (from register file, possibly forwarded) |
| `ExtImm` | 32 | Extended immediate value |
| `PCPlus1` | 32 | Incremented PC for JAL instruction |
| `Rd` | 4 | Destination register address |
| `Rs1` | 4 | Source register 1 address |
| `Rs2` | 4 | Source register 2 address |

**Characteristics**:
- Passes decoded instruction information and operands to EX stage
- All control signals and data needed for execution
- Does not stall (always updates)
- Allows ID stage to move to next instruction while EX executes

---

### **EX/MEM Register** (Execute → Memory)

**Signals Stored** (74 bits):
| Signal | Width | Purpose |
|--------|-------|---------|
| `CtrlSignals` | 5 | Compressed control: RegWr(1), MemRd(1), MemWr(1), WBData(2) |
| `ALUResult` | 32 | Result from ALU execution |
| `Data` | 32 | Data to write to memory (from register file) |
| `PCPlus1` | 32 | PC+1 for JAL write-back |
| `Rd` | 4 | Destination register address |

**Characteristics**:
- Passes execution results to memory stage
- Only necessary control signals (memory and write-back)
- ALU result used as memory address
- Write data prepared for memory operation

---

### **MEM/WB Register** (Memory → Write Back)

**Signals Stored** (37 bits):
| Signal | Width | Purpose |
|--------|-------|---------|
| `Data` | 32 | Write-back data (ALU result, memory read, or PC+1) |
| `Rd` | 4 | Destination register address |
| `RegWr` | 1 | Register write enable |

**Characteristics**:
- Final stage register before write-back to register file
- Carries computed/loaded data to write-back
- Minimal control signals (only RegWr needed)
- Destination register address for proper write location

---

## Hazard Handling

### **Implemented Hazard Management**

#### **1. Data Hazards (RAW - Read After Write)**

**Problem**: An instruction tries to read a register before a previous instruction has written to it.

**Example**:
```
Cycle:  1  2  3  4  5
ADD R1...   IF ID EX MEM
ADD R2,R1   -  IF ID  EX
```
In cycle 4, ID reads R1 while ADD still hasn't written to it (WB in cycle 5).

**Solution - Forwarding Unit**:
- Compares operand addresses (RA, RB) with destination registers in later pipeline stages (EX, MEM, WB)
- If match found and destination register is being written, selects forwarded value
- **Forwarding Sources**:
  - ForwardA[1:0] = 2'b01: Use EX_ALU_Result (result about to complete)
  - ForwardA[1:0] = 2'b10: Use WB_SelectedData (result from previous instruction)
  - ForwardA[1:0] = 2'b11: Use BusW (result from two previous instruction)
  - ForwardA[1:0] = 2'b00: Use register file (no hazard)

**Forwarding Multiplexers**:
```
ForwardAMux selects between: {ID_BusA, EX_ALU_Result, WB_SelectedData, BusW}
ForwardBMux selects between: {ID_BusB, EX_ALU_Result, WB_SelectedData, BusW}
```

#### **2. Load-Use Hazard**

**Problem**: A Load instruction (LW) is followed immediately by an instruction using that loaded data. Data won't be available from memory until MEM stage.

**Example**:
```
Cycle:  1  2  3  4  5  6
LW R1...    IF ID EX MEM WB
ADD R2,R1   -  IF ID  EX MEM
                        ↑ Still reading R1, but data from memory arrives in cycle 5
```

**Solution - Stall Logic**:
- Forwarding Unit detects: `EX_MemRd == 1 && (ForwardA == 2'd1 || ForwardB == 2'd1)`
- Asserts `Stall` signal to pause pipeline
- **Stall Effects**:
  - PC register enable: `~Stall` (PC doesn't advance when stalled)
  - IF/ID register enable: `~Stall` (instruction doesn't progress)
  - Control signals muxed to zeros (next instruction sees no control signals)
  - One NOP cycle inserted

**After Stall**:
```
Cycle:  1  2  3  4  5  6  7
LW R1...    IF ID EX MEM WB
(stall)     -  IF ID  ID  EX
ADD R2,R1   -  -  IF  ID  ID EX
                             ↑ Data now available for forwarding
```

#### **3. Control Hazards (Branch/Jump)**

**Problem**: PC changes on branch/jump, causing fetched instructions to be incorrect.

**Example**:
```
Cycle:  1  2  3  4  5
BEQ (taken)     IF ID EX
next inst (WRONG) - IF ID
target (CORRECT)   -  -  IF
                           ↑ Two cycles of bubble
```

**Solution - Branch Flush**:
- PCControl determines branch taken in ID stage
- Asserts `Kill` signal to flush instruction in IF stage
- Mux replaces instruction with NOP (opcode = 20'h00000000)
- PC immediately updates to branch/jump target

**Flush Instruction**: `32'b00100000000000000000000000000000` (NOP opcode)

#### **4. Structural Hazards**

**Status**: Not present in this design.
- Single instruction memory accessed only in IF stage
- Single data memory with separate read/write using dual-edge clocking
- No resource conflicts between pipeline stages

---

### **Hazard Not Implemented**

- **Write-after-Write (WAW) Hazard**: Not possible with 5-stage pipeline (instructions must complete in order)
- **Write-after-Read (WAR) Hazard**: Not possible (pipeline is in-order)
- **Out-of-Order Execution**: Not implemented (pipeline is strictly in-order)

---

## ALU Operations

The ALU supports 8 different operations selected by a 3-bit control signal:

| ALUCtrl | Operation | Function | Example |
|---------|-----------|----------|---------|
| 3'b000 | **ADD** | Addition | ADD R1, R2, R3 → R1 = R2 + R3 |
| 3'b001 | **AND** | Bitwise AND | AND R1, R2, R3 → R1 = R2 & R3 |
| 3'b010 | **OR** | Bitwise OR | OR R1, R2, R3 → R1 = R2 \| R3 |
| 3'b011 | **XOR** | Bitwise XOR | XOR R1, R2, R3 → R1 = R2 ^ R3 |
| 3'b100 | **SUB** | Subtraction | SUB R1, R2, R3 → R1 = R2 - R3 |
| 3'b101 | **NOR** | Bitwise NOR | NOR R1, R2, R3 → R1 = ~(R2 \| R3) |
| 3'b110 | **SLL** | Shift Left Logical | SLL R1, R2, R3 → R1 = R2 << R3[4:0] |
| 3'b111 | **SRL** | Shift Right Logical | SRL R1, R2, R3 → R1 = R2 >> R3[4:0] |

**Shift Operations**: Only lower 5 bits of operand B are used as shift amount (max shift = 31 bits).

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
- 40-cycle execution window

**Execution**:
- Initializes register file with test values
- Initializes data memory
- Monitors final register state
- Displays detailed execution trace with formatting

**Output Example**:
```
Cycle  |    PC     | IF/ID | ID/EX | EX/MEM
    20 |        20 | 0xa4  | 0x32  | 0x1000
    40 |        40 | 0xb2  | 0xff  | 0x2000
```

#### **2. tb_processor.v** (Cycle Trace Testbench)
**Purpose**: Simpler testbench with periodic status reporting.

**Features**:
- Reports every 200 time units
- Displays PC, opcode, ALU result, write-back data
- Shows stall and forwarding status
- Shorter execution window (5 cycles after test completion)

**Output Format**:
```
Time   | PC    | Opcode    | ALU_Res   | WB_Data   | Stall/Fwd
0      | 00000 | 001010    | 0000000001| 0000000001| S:0 F:00
```

### **Test Programs**

#### **TEST.asm** - ALU & Extender Verification
Tests sign/zero extension and all ALU operations.

**Coverage**:
- Sign extension (ADDI with negative)
- Zero extension (ANDI, ORI)
- AND, OR, XOR operations
- Shift Left Logical (SLL)
- Shift Right Logical (SRL)
- Zero flag detection (SUB R10, R2, R2 → 0)
- Branch instruction (BEQ)

#### **funtionallity_program.asm** - Full Instruction Set
Comprehensive test covering most instructions.

**Coverage**:
- All arithmetic operations (ADD, SUB, AND, OR, XOR, NOR, SLL, SRL)
- Immediate operations (ADDI, ANDI, ORI)
- Clear instruction (CLR)
- Memory operations (SW, LW)
- Branch instructions (BEQ, BNE)
- Jump instructions (J, JAL, JR)

#### **hazard_program.asm** - Data Hazards & Forwarding
Stress test for data hazard detection and forwarding unit.

**Coverage**:
- Back-to-back RAW hazards
- Load-use hazards (LW followed by ADD using loaded register)
- Multiple forwarding paths (EX, MEM, WB)
- Stall scenarios
- Branch delay effects

#### **Binary Test Files**
- `functionallity_test.bin`: Compiled binary of funtionallity_program.asm
- `hazard_test.bin`: Compiled binary of hazard_program.asm

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
# Compile all Verilog files
vlib work
vmap work ./work
vlog src/*.v

# Or compile specific files in order (resolving dependencies)
vlog src/ALU.v
vlog src/Comparator.v
vlog src/RegisterFile.v
vlog src/DataMemory.v
vlog src/Extender.v
vlog src/Mux2to1.v
vlog src/Mux4to1.v
vlog src/PCControl.v
vlog src/SyncRegister.v
vlog src/SyncRegisterEn.v
vlog src/MainandALUControl.v
vlog src/ForwardingUnit.v
vlog src/Adder.v
vlog src/InstructionmMemory.v
vlog src/processor.v
vlog src/tb_processor.v
vlog src/Processor_Functionallity_TB.v
```

#### **Simulation (Functionality Test)**
```bash
# Launch ModelSim and run testbench
vsim -c Processor_Functionallity_TB -do "run -all; quit"

# Or interactive mode
vsim Processor_Functionallity_TB
run -all
```

#### **Waveform Viewing**
```bash
# View previously captured waveform
vsim -view waveforms/functionallity_test_waveform.asdb
```

### **Icarus Verilog Simulation**

#### **Compilation & Simulation**
```bash
# Compile
iverilog -o sim.vvp src/processor.v src/tb_processor.v \
  src/*.v 2>&1 | grep -v "Warning"

# Run
vvp sim.vvp

# With VCD waveform output
iverilog -o sim.vvp src/processor.v src/Processor_Functionallity_TB.v \
  src/*.v
vvp sim.vvp
gtkwave dump.vcd &
```

### **Memory File Configuration**

**Instruction Memory**: Load from `imem.mem`
```verilog
InstructionMemory Instruction_Memory(
    .Address(Current_PC), 
    .Instruction(Instruction)
);
// imem.mem contains hex-encoded 32-bit instructions
// Each line: 32-bit hex value (e.g., 28400001 for ADDI R1,R0,1)
```

**Data Memory**: Load from `dmem.mem`
```verilog
DataMemory Data_Memory(
    .Clk(CLK), 
    .Address(EXMEM_R_Out), 
    .Data_In(EXMEM_D_Out), 
    .W(MEM_MemWr), 
    .R(MEM_MemRd), 
    .Data_Out(Data_Out)
);
```

---

## How to Run

### **Step 1: Obtain the Repository**
```bash
git clone https://github.com/Amjad-Adi/ENCS4370_Pipelined_32-bit_RISC_Processor_Design.git
cd ENCS4370_Pipelined_32-bit_RISC_Processor_Design
```

### **Step 2: Set Up Simulation Environment**

#### **Option A: Using ModelSim**
```bash
# Create working library
vlib work
vmap work ./work

# Compile all source files
vlog src/ALU.v src/Comparator.v src/RegisterFile.v src/DataMemory.v \
     src/Extender.v src/Mux2to1.v src/Mux4to1.v src/PCControl.v \
     src/SyncRegister.v src/SyncRegisterEn.v src/MainandALUControl.v \
     src/ForwardingUnit.v src/Adder.v src/InstructionmMemory.v \
     src/processor.v src/Processor_Functionallity_TB.v
```

#### **Option B: Using Icarus Verilog**
```bash
# Compile all files
iverilog -o processor_sim.vvp src/*.v

# No build step needed, files auto-resolved by iverilog
```

### **Step 3: Run Simulation**

#### **With ModelSim**
```bash
# Non-interactive (batch mode)
vsim -c Processor_Functionallity_TB -do "run -all; quit"

# Interactive mode
vsim Processor_Functionallity_TB
ModelSim> run -all
ModelSim> quit
```

#### **With Icarus Verilog**
```bash
# Run simulation
vvp processor_sim.vvp

# Run with output redirection
vvp processor_sim.vvp > simulation_output.txt

# View timing with GTKWave
gtkwave dump.vcd
```

### **Step 4: View Waveforms**

#### **ModelSim**
```bash
# Within ModelSim GUI
File → Open → waveforms/functionallity_test_waveform.asdb

# Or command line
vsim -view waveforms/functionallity_test_waveform.asdb
```

#### **GTKWave (Icarus)**
```bash
# View VCD file
gtkwave dump.vcd &

# Or with specific signals
gtkwave -a signals.gtkw dump.vcd &
```

### **Step 5: Verify Output**

**Expected Console Output** (Processor_Functionallity_TB):
```
==============================================================
FINAL STATE
==============================================================
R0 =0      R1 =8
R2 =4      R3 =3
R4 =?      R5 =?
... (all registers)
DMEM[0]=<value>
```

**Interpretation**:
- R0 must always be 0 (hardwired)
- Other registers should match instruction execution results
- DMEM values reflect successful memory operations

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

### **Hardware Requirements**

- **Processor**: Any modern CPU (Intel/AMD/ARM)
- **RAM**: 2 GB minimum
- **Storage**: 100 MB (includes waveform files)
- **Display**: Required for waveform viewing

### **System Requirements**

- **OS**: Windows, Linux, or macOS
- **Build Tools**: GCC (for compilation), Make (optional)
- **Clock**: System clock for accurate timing

### **Verilog Language Features Used**

| Feature | Usage |
|---------|-------|
| `module` | All component definitions |
| `reg`, `wire` | Data storage and connectivity |
| `input`, `output` | Port definitions |
| `always` | Sequential and combinational logic |
| `assign` | Continuous assignment |
| `case` | Multiplexing and ALU operations |
| `parameter` | Configurable widths (multiplexers) |
| `$readmemh` | Memory initialization from file |
| `#(32)` | Parameterized instantiation |

---

## Design Decisions

### **1. Five-Stage Pipeline Over Single-Cycle**
**Decision**: Implement a five-stage pipeline instead of single-cycle processor.

**Rationale**:
- Increases instruction throughput (ideally 1 instruction/cycle vs. 5+ cycles/instruction)
- Allows deeper analysis of hazards, forwarding, and control flow
- Educational value for understanding modern processor architecture
- Trade-off: Increased complexity and hazard management overhead

---

### **2. Dual-Edge Clocking for Memory**
**Decision**: Data memory reads on positive edge, writes on negative edge.

**Rationale**:
- Enables pipelined memory access without requiring separate read/write ports
- Reduces memory latency from MEM stage (data available same cycle for WB)
- Simplifies memory design while maintaining synchronization
- Alternative would require write-after-read sequencing or separate memory blocks

---

### **3. Forwarding Unit for Hazard Mitigation**
**Decision**: Use forwarding to bypass data hazards before stall detection.

**Rationale**:
- Eliminates stalls for most RAW hazards (forwarding covers 90%+ of cases)
- Only load-use hazards require actual pipeline stall
- Improves throughput significantly compared to always-stall approach
- Hardware cost is reasonable (multiplexers and comparators)

---

### **4. In-Order Execution Pipeline**
**Decision**: Maintain strict instruction order (no out-of-order execution).

**Rationale**:
- Simplifies hazard detection and control flow handling
- Reduces design complexity significantly
- Still achieves good IPC with forwarding and pipelining
- Out-of-order execution would require complex dependency tracking

---

### **5. Instruction Flush vs. Stall for Branches**
**Decision**: Flush (kill) instruction in IF stage on branch taken, rather than stall.

**Rationale**:
- Flush achieves correct control flow faster than predicting/stalling
- Branch decisions made in ID stage provide sufficient time
- Introduces minimal branch penalty (1 cycle bubble)
- Simpler than implementing branch prediction

---

### **6. 16 Register Architecture**
**Decision**: Use 16 general-purpose registers (R0-R15) instead of 32 or 8.

**Rationale**:
- 4-bit register addresses fit naturally in instruction encoding
- Sufficient for test programs and typical algorithms
- Reduces register file size compared to 32-register systems
- Hardware cost is manageable (16-to-1 muxes)

---

### **7. Word-Addressable Memory**
**Decision**: Use word (32-bit) addressing instead of byte addressing.

**Rationale**:
- Simplifies memory indexing for 32-bit data
- Reduces address decoder complexity
- Instruction and data fetches are word-aligned by design
- Standard approach for RISC architectures

---

### **8. Synchronous Control Signal Generation**
**Decision**: Generate all control signals from opcode combinationally in ID stage.

**Rationale**:
- No propagation delay penalty (generated from opcode immediately)
- Control signals available same cycle as instruction decode
- Simplifies pipeline register design (control signals propagate with instruction)
- Alternative (ROM-based) would add memory access latency

---

### **9. R0 Hardwired to Zero**
**Decision**: Prevent writes to R0; always return 0 on reads.

**Rationale**:
- Standard RISC convention (MIPS, RISC-V)
- Provides zero constant without explicit register
- Common base register for addressing (0 + offset = offset)
- Simplifies register file logic

---

## Future Improvements

### **Performance Enhancements**
1. **Branch Prediction**: Implement branch target buffer (BTB) or static prediction to reduce branch penalty from 1 to 0 cycles
2. **Superscalar Execution**: Allow 2-3 instructions per cycle with multiple ALUs and fetch units
3. **Cache System**: Add L1 instruction and data caches to reduce memory latency
4. **Dynamic Branch Prediction**: Implement Gshare or tournament predictor for higher accuracy

### **Feature Additions**
5. **Exception Handling**: Add interrupt and exception support with trap handlers
6. **Floating-Point Unit**: Extend ISA with FPU operations and floating-point registers
7. **Virtual Memory**: Implement MMU with TLB for address translation
8. **Extended Instruction Set**: Add multiply/divide, bit manipulation, vector operations

### **Memory System**
9. **Wider Memory Bus**: Increase to 64-bit or 128-bit for higher throughput
10. **Memory Controller**: Add DRAM controller with refresh and timing control
11. **Coherence Protocol**: For multi-core version (MSI/MESI/MOESI)

### **Design Verification**
12. **Formal Verification**: Prove correctness properties with model checking
13. **Comprehensive Testbenches**: Generate random instruction sequences for stress testing
14. **Power Analysis**: Add power measurement and optimization
15. **Design Documentation**: Auto-generate from RTL comments

### **Implementation Targets**
16. **FPGA Synthesis**: Target Xilinx Vivado or Intel Quartus for FPGA deployment
17. **Physical Implementation**: Standard cell design and layout in 5nm/7nm process
18. **Timing Closure**: Optimize for maximum clock frequency

### **Educational Enhancements**
19. **Simulator Improvements**: Add GUI debugger with breakpoint and step-through support
20. **Assembly Compiler**: Develop simple assembler to compile `.asm` files to `.mem` files
21. **Interactive Visualization**: Real-time visualization of pipeline state and data flow

---

## License

Not specified in the repository. This is a university coursework project (ENCS4370 course at Birzeit University).

**Status**: Open source for educational use. Please refer to the university's policy or contact the authors for licensing information.

---

## Authors

### **Team Members and Responsibilities**

#### **Amir — Student ID: 1231192**

**Single-Cycle Processor Responsibilities**:
- Memory Units (Instruction Memory, Data Memory)
- Register File design and implementation
- Additional components (multiplexers, adders)
- Verification and testing

**Pipelined Processor Responsibilities**:
- Memory system modifications for pipelined operation
- Pipeline register design and implementation (IF/ID, ID/EX, EX/MEM, MEM/WB)
- 32-bit comparator unit for branch comparison
- Individual module testbenches
- Control signal spreadsheet and documentation

#### **Hanan — Student ID: 1230827**

**Single-Cycle Processor Responsibilities**:
- Arithmetic Logic Unit (ALU) with 8 operations
- Extender unit (sign and zero extension)
- Verification and testing
- Assembly test programs

**Pipelined Processor Responsibilities**:
- Complete pipelined processor testbench
- Pipeline validation for all instruction types
- Architecture diagram update (Draw.io)
- System verification and debugging support

#### **Amjad — Student ID: 1230800**

**Single-Cycle Processor Responsibilities**:
- Control unit design and signal generation
- System integration and datapath assembly
- Verification and testing

**Pipelined Processor Responsibilities**:
- Full pipelined processor integration
- Complete five-stage pipeline assembly
- Control signal propagation through pipeline registers
- Integration debugging and datapath verification

---

## References

### **Course Information**
- **Course**: ENCS4370 (Computer Architecture)
- **Institution**: Birzeit University
- **Semester**: 2025-2026 Academic Year

### **Documentation Files in Repository**
- `Pipelined_Processor_Design_*.pdf` - Complete design documentation report
- `Pipeline_Control_Signals.pdf` - Control signal definitions and flow
- `Control Signals.xlsx` - Detailed control signal truth table
- `Pipelined Processor.drawio.svg` - Architecture diagram

### **Related Concepts and References**
- MIPS ISA (Patterson & Hennessy, "Computer Organization & Design")
- 5-Stage RISC Pipeline Architecture
- Hazard Detection and Forwarding Units
- Synchronous Memory Design
- Verilog Hardware Description Language

### **Textbooks and References**
- "Computer Organization and Design: The Hardware/Software Interface" - Patterson & Hennessy
- "Digital Design" - Morris Mano
- "Verilog HDL" - Samir Palnitkar
- IEEE Std 1364-2005 (Verilog Language Reference)

---

## Acknowledgments

This processor design was developed as part of the ENCS4370 Computer Architecture course at Birzeit University. The team expresses gratitude to the course instructors and the computer architecture community for guidance and educational resources.

---

**Last Updated**: July 8, 2026  
**Repository**: https://github.com/Amjad-Adi/ENCS4370_Pipelined_32-bit_RISC_Processor_Design
