# Pipelined Processor Refactoring and Datapath Integration Tasks

## Objective

Prepare the existing single-cycle processor modules for pipelined integration by standardizing module names, signal names, and interfaces according to the provided pipelined processor datapath diagram. The work is divided into two sequential tasks.

---

# Task 1 — Module Refactoring and Standardization

**Assigned To:** Developer 1

## Description

Refactor the existing Verilog modules to match the naming convention and structure shown in the pipelined processor datapath image.

### Required Changes

#### 1. Standardize Module Names

* Rename all modules to match the names used in the pipelined processor diagram.
* Top-level modules must use exactly the same names shown in the image whenever applicable.

#### 2. Standardize Signal Names

* Rename all inputs, outputs, and internal signals to descriptive names matching the datapath diagram.
* Avoid generic names such as:

  * `A`
  * `B`
  * `In`
  * `Out`
  * `Data`

Use descriptive names instead, for example:

* `Instruction`
* `BranchTarget`
* `JumpTarget`
* `ALUResult`
* `WriteBackData`

#### 3. Pipeline Register Naming

Whenever a register is used to save state between pipeline stages, use stage-based naming.

Examples:

```verilog
Instruction_IFID
Instruction_IDEX
Instruction_EXMEM
Instruction_MEMWB
```

```verilog
ALUResult_EXMEM
ALUResult_MEMWB
```

```verilog
BranchTarget_IDEX
BranchTarget_EXMEM
```

The suffix should clearly indicate the pipeline register boundary:

* `IFID`
* `IDEX`
* `EXMEM`
* `MEMWB`

#### 4. Parameterize Modules

If multiple modules differ only by bit width, replace them with a single parameterized module.

Example:

Instead of:

```verilog
module Register32 (...);
```

```verilog
module Register16 (...);
```

```verilog
module Register4 (...);
```

Create:

```verilog
module Register #(parameter WIDTH = 32)
(
    input clk,
    input reset,
    input enable,
    input [WIDTH-1:0] D,
    output reg [WIDTH-1:0] Q
);
```

Instantiation examples:

```verilog
Register #(32) PC_Register (...);
```

```verilog
Register #(4) Control_Register (...);
```

```verilog
Register #(64) Pipeline_Register (...);
```

### Deliverables

* Refactored Verilog source files.
* Updated module names.
* Updated signal names.
* Parameterized versions of reusable modules.
* Compilation without syntax errors.

---

# Task 2 — Pipelined Datapath Construction

**Assigned To:** Developer 2

## Description

Continue from the refactored code produced in Task 1.

### Required Work

#### 1. Build the Full Pipelined Datapath

Using the newly standardized modules:

* Construct the complete pipelined datapath.
* Connect all pipeline registers:

  * IF/ID
  * ID/EX
  * EX/MEM
  * MEM/WB

#### 2. Use Refactored Module Names

Only use the renamed modules and signals produced in Task 1.

Do not introduce old naming conventions back into the design.

#### 3. Initial Functional Test

Perform one basic execution test using the provided:

```text
test.bin
```

program that was originally designed for the single-cycle processor.

The goal is only to verify:

* Correct datapath connectivity.
* Correct instruction flow through stages.
* Basic execution functionality.

#### 4. Fix Integration Issues

Modify connections and control propagation as necessary until the processor executes the provided test successfully.

### Important

Do **not** spend time creating or running advanced test programs.

Do **not** implement extensive validation or performance testing.

Advanced testing, debugging, and verification will be performed later by **Amjad**.

The objective of this task is only to achieve a working initial pipelined datapath capable of executing the provided single-cycle test program.

### Deliverables

* Complete pipelined datapath implementation.
* Successful execution of the provided `test.bin`.
* Updated top-level processor module.
* Notes describing any temporary assumptions or limitations.

---

# Expected Workflow

1. Developer 1 completes module refactoring and parameterization.
2. Developer 2 uses the refactored modules to build the pipelined datapath.
3. Verify operation using the provided `test.bin`.
4. Leave advanced testing and optimization for Amjad.
