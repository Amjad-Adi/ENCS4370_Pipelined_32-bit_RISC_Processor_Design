; ============================================================
; Assembly Test Program
; Project  : ENCS4370 - Single-Cycle 32-bit RISC Processor
; Author   : Amir (1231192)
; Purpose  : Verify Amir's hardware modules:
;              - Instruction Memory (IM)
;              - Data Memory (DM)
;              - Register File (with Decoder + MUX)
;              - 2-to-1 MUX (ALUSrc / MemToReg)
;              - 32-bit Adder (PC+1, branch target)
; ============================================================

; ============================================================
; INSTRUCTION FORMAT REMINDER
; R-Type: [31:26]=opcode [25:22]=Rd [21:18]=Rs [17:14]=Rt [13:0]=unused
; I-Type: [31:26]=opcode [25:22]=Rt [21:18]=Rs [17:0]=Imm18
; J-Type: [31:26]=opcode [25:0]=Offset26
;
; Opcodes:
;   ADD=0  SUB=1  AND=2  OR=3   XOR=4  NOR=5  SLL=6  SRL=7
;   CLR=8  JR=9   ADDI=10 ANDI=11 ORI=12
;   LW=13  SW=14  SWAP=15 BEQ=16 BNE=17 J=18  JAL=19
; ============================================================

; ============================================================
; SECTION 1: Test Register File — Write & Read
; Expected: R1=1, R2=2, R3=3, R4=4, R5=5
; Tests   : RegWrite, Decoder, MUX read ports (Rs, Rt)
; ============================================================

ADDI R1, R0, 1      ; R1 = R0 + 1 = 1   (write to R1 via RegFile)
ADDI R2, R0, 2      ; R2 = R0 + 2 = 2   (write to R2 via RegFile)
ADDI R3, R0, 3      ; R3 = R0 + 3 = 3   (write to R3 via RegFile)
ADDI R4, R0, 4      ; R4 = R0 + 4 = 4   (write to R4 via RegFile)
ADDI R5, R0, 5      ; R5 = R0 + 5 = 5   (write to R5 via RegFile)

; ============================================================
; SECTION 2: Test 32-bit Adder and MUX (Register path)
; Expected: R6 = R1 + R2 = 3
;           R7 = R3 + R4 = 7
;           R8 = R5 + R6 = 8
; Tests   : Adder (ALU add), MUX Sel=0 (register input path)
; ============================================================

ADD  R6, R1, R2     ; R6 = 1 + 2 = 3    (register path through MUX)
ADD  R7, R3, R4     ; R7 = 3 + 4 = 7    (register path through MUX)
ADD  R8, R5, R6     ; R8 = 5 + 3 = 8    (register path through MUX)

; ============================================================
; SECTION 3: Test MUX (ALUSrc — Immediate path)
; Expected: R9  = R0 + 100 = 100
;           R10 = R9 + 50  = 150
; Tests   : MUX Sel=1 (immediate input path to ALU)
; ============================================================

ADDI R9,  R0, 100   ; R9  = 0 + 100 = 100  (immediate through MUX)
ADDI R10, R9, 50    ; R10 = 100 + 50 = 150  (immediate through MUX)

; ============================================================
; SECTION 4: Test Data Memory — SW then LW
; Expected: Mem(R0+0) = R8 = 8
;           R11 = Mem(R0+0) = 8
; Tests   : DM write (SW), DM read (LW), MemToReg MUX Sel=1
; ============================================================

SW   R8,  0(R0)     ; Mem(0) = R8 = 8       (DM write, MemWrite=1)
LW   R11, 0(R0)     ; R11 = Mem(0) = 8      (DM read, MemToReg MUX Sel=1)

; ============================================================
; SECTION 5: Test Data Memory — SW then LW at offset
; Expected: Mem(R1+4) = Mem(5) = R10 = 150
;           R12 = Mem(R1+4) = 150
; Tests   : Address = Rs + Imm (Adder computes memory address)
; ============================================================

SW   R10, 4(R1)     ; Mem(1+4) = Mem(5) = 150
LW   R12, 4(R1)     ; R12 = Mem(5) = 150

; ============================================================
; SECTION 6: Test R0 Hardwired to Zero
; Expected: R0 = 0 always (write must be ignored)
; Tests   : RegFile R0 write protection
; ============================================================

ADDI R0, R0, 99     ; Attempt to write 99 to R0 — must be IGNORED
ADD  R13, R0, R1    ; R13 = R0 + R1 = 0 + 1 = 1 (R0 still 0)

; ============================================================
; SECTION 7: Test CLR instruction
; Expected: R5 = 0 (cleared)
; Tests   : CLR opcode, RegFile write
; ============================================================

CLR  R5             ; R5 = 0
ADD  R14, R5, R2    ; R14 = 0 + 2 = 2 (confirm R5 was cleared)

; ============================================================
; SECTION 8: Test PC Adder — BEQ branch (taken)
; Expected: If R1 == R1 → branch taken → PC jumps
;           R15 should NOT be written (instruction after BEQ skipped)
; Tests   : Adder (PC + offset), PCSrc MUX Sel=1
; ============================================================

BEQ  R1, R1, 2      ; Branch taken: PC = PC + 2 (skip next 2 instructions)
ADDI R15, R0, 99    ; SKIPPED — should never execute
ADDI R15, R0, 99    ; SKIPPED — should never execute
ADDI R15, R0, 55    ; R15 = 55 (this executes after branch)

; ============================================================
; SECTION 9: Test BNE branch (not taken)
; Expected: R1 != R2 → branch taken → skip next instruction
; Tests   : BNE opcode, branch condition
; ============================================================

BNE  R1, R2, 1      ; Branch taken (R1=1 != R2=2): skip next instruction
ADDI R15, R0, 0     ; SKIPPED
ADD  R15, R1, R2    ; R15 = 1 + 2 = 3 (executes after branch)

; ============================================================
; SECTION 10: Infinite Loop — keeps processor stable
; Tests   : J instruction (J-Type), PC jump via Adder
; ============================================================

J    0              ; Jump to offset 0 (infinite loop — processor halts here)

; ============================================================
; EXPECTED FINAL REGISTER STATE
; ============================================================
; R0  = 0          (hardwired zero, write ignored in Section 6)
; R1  = 1          (ADDI Section 1)
; R2  = 2          (ADDI Section 1)
; R3  = 3          (ADDI Section 1)
; R4  = 4          (ADDI Section 1)
; R5  = 0          (CLR Section 7)
; R6  = 3          (ADD Section 2)
; R7  = 7          (ADD Section 2)
; R8  = 8          (ADD Section 2)
; R9  = 100        (ADDI Section 3)
; R10 = 150        (ADDI Section 3)
; R11 = 8          (LW Section 4)
; R12 = 150        (LW Section 5)
; R13 = 1          (ADD Section 6, R0+R1)
; R14 = 2          (ADD Section 7, R5+R2 after CLR)
; R15 = 3          (ADD Section 9, R1+R2)
;
; EXPECTED MEMORY STATE
; Mem(0)  = 8      (SW Section 4)
; Mem(5)  = 150    (SW Section 5)
; ============================================================