// ============================================================
// hazard_test.bin — Full Hazard Coverage Test
// Project : ENCS4370 - Pipelined 32-bit RISC Processor
// Author  : Amir (1231192)
// Format  : $readmemb — 32 bits per line
// Initial : R1=10, R2=20, R3=3 (set in first 3 instructions)
// ============================================================

// ── SECTION 0: Initialize base registers ─────────────────────
ADDI R1,R0,10       | R1=10 1
ADDI R2,R0,20       | R2=20 2
ADDI R3,R0,3        | R3=3 (shift amount) 3

// ── SECTION 1: EX-EX RAW Hazard (back-to-back dependency) ───
ADD  R4,R1,R2       | R4=10+20=30  [EX writes R4] 4
ADD  R5,R4,R2       | R5=30+20=50  [EX-EX forward R4] 5
SUB  R6,R5,R1       | R6=50-10=40  [EX-EX forward R5] 6

// ── SECTION 2: MEM-EX RAW Hazard (1 gap between writer/reader) ──
ADD  R7,R1,R2       | R7=30        [EX writes R7] 7
AND  R8,R1,R2       | R8=0         [gap] 8
ADD  R9,R7,R2       | R9=30+20=50  [MEM-EX forward R7] 9

// ── SECTION 3: WB-EX (2 gaps — no forwarding needed) ────────
ADD  R10,R1,R2      | R10=30       [WB writes R10] 10
AND  R11,R1,R2      | R11=0        [gap 1] 11
OR   R12,R1,R2      | R12=30       [gap 2] 12
ADD  R13,R10,R2     | R13=50       [no hazard, R10 in WB] 13

// ── SECTION 4: LOAD-USE Hazard (LW then immediate use → STALL) ──
ADDI R14,R0,30      | R14=30 14
SW   R14,0(R0)      | Mem(0)=30 15
LW   R4,0(R0)       | R4=Mem(0)=30 [LW writes R4] 16
ADD  R5,R4,R1       | R5=30+10=40  [LOAD-USE STALL → stall 1 cycle] 17

// ── SECTION 5: LOAD-USE with 1 gap (no stall, MEM-EX forward) ──
LW   R6,0(R0)       | R6=Mem(0)=30 [LW writes R6] 18
AND  R7,R1,R2       | R7=0         [gap — no stall] 19
ADD  R8,R6,R1       | R8=30+10=40  [MEM-EX forward R6] 20

// ── SECTION 6: SW reads forwarded value (EX-EX forward to store data) ──
ADD  R9,R1,R2       | R9=30        [EX writes R9] 21
SW   R9,4(R0)       | Mem(4)=30    [EX-EX forward R9 as store data] 22
LW   R10,4(R0)      | R10=30       [verify SW wrote correctly] 23

// ── SECTION 7: SWAP (R/W + W/R simultaneously, negedge write posedge read) ──
ADDI R11,R0,99      | R11=99 24
SW   R11,8(R0)      | Mem(8)=99 25
ADDI R12,R0,55      | R12=55 26
SWAP R12,8(R0)      | R12=Mem(8)=99, Mem(8)=55 [negedge W, posedge R] 27
LW   R13,8(R0)      | R13=55       [verify Mem(8) was written] 28
ADD  R14,R12,R0     | R14=99       [verify R12 was updated] 29

// ── SECTION 8: WAW — Write After Write (later write must win) ──
ADD  R15,R1,R2      | R15=30       [1st write to R15] 30
ADDI R15,R0,77      | R15=77       [2nd write to R15, must win] 31
ADD  R4,R15,R0      | R4=77        [must read 77, not 30] 32

// ── SECTION 9: R0 write protection ───────────────────────────
ADDI R0,R0,99       | R0 stays 0  [write ignored] 33
ADD  R5,R0,R1       | R5=10        [R0=0 confirmed] 34

// ── SECTION 10: ALU coverage (AND, OR, XOR, NOR, SLL, SRL, CLR) ──
AND  R6,R1,R2       | R6=10&20=0 35
OR   R7,R1,R2       | R7=10|20=30 36
XOR  R8,R1,R2       | R8=10^20=30 37
NOR  R9,R1,R2       | R9=~(10|20)=-31 38
SLL  R10,R1,R3      | R10=10<<3=80 39
SRL  R11,R2,R3      | R11=20>>3=2 40
CLR  R12            | R12=0 41

// ── SECTION 11: I-Type immediate (ANDI, ORI) ─────────────────
ANDI R13,R1,15      | R13=10&15=10 42
ORI  R14,R1,5       | R14=10|5=15 43

// ── SECTION 12: BEQ taken (R1==R4, 10==10) ───────────────────
ADDI R4,R0,10       | R4=10 (==R1) 44
BEQ  R1,R4,3        | TAKEN (10==10) skip 45,46 45
ADDI R5,R0,99       | SKIPPED 46
ADDI R5,R0,99       | SKIPPED 47
ADDI R5,R0,55       | R5=55 [executes] 48

// ── SECTION 13: BEQ not taken (R1!=R2, 10!=20) ───────────────
BEQ  R1,R2,3        | NOT TAKEN (10!=20) 49
ADDI R6,R0,66       | R6=66 [executes]

// ── SECTION 14: BNE taken (R1!=R2, 10!=20) ───────────────────
BNE  R1,R2,3        | TAKEN (10!=20) skip 51,52 50
ADDI R7,R0,99       | SKIPPED 51
ADDI R7,R0,99       | SKIPPED 52
ADDI R7,R0,77       | R7=77 [executes] 53

// ── SECTION 15: BNE not taken (R1==R4, 10==10) ───────────────
BNE  R1,R4,3        | NOT TAKEN (10==10) 54
ADDI R8,R0,88       | R8=88 [executes] 55

// ── SECTION 16: J unconditional ──────────────────────────────
J    3               | jump skip 57,58 56
ADDI R9,R0,99       | SKIPPED 57
ADDI R9,R0,99       | SKIPPED 58
ADDI R9,R0,44       | R9=44 [executes] 59

// ── SECTION 17: JAL + JR ─────────────────────────────────────
JAL  3               | R14=61, jumps to subroutine at 63 60
ADDI R10,R0,99       | Executes AFTER return! 61
J    3               | Jump to 65 (Escapes subroutine!) 62
ADDI R10,R0,33       | [Subroutine entry] R10=33 63
JR   R14             | PC=61 64

// ── SECTION 18: ALU-to-Branch Hazard (Requires 1 Stall + ID Forwarding) ──
ADDI R12,R0,123    | R12=123 (computed in EX) 65
BEQ  R12,R0,3      | Needs R12 in ID! STALL 1 cycle. Not taken (123!=0). 66
ADDI R0,R0,99      | Executes (not skipped) 67

// ── SECTION 19: Load-to-Branch Hazard (Requires 2 Stalls + ID Forwarding) ──
LW   R5,0(R0)      | R5=30 (from earlier SW). Ready after MEM. 68
BEQ  R5,R0,3       | Needs R5 in ID! STALL 2 cycles. Not taken (30!=0). 69
ADDI R0,R0,99      | Executes (not skipped) 70

// ── SECTION 20: Double Forwarding Priority Hazard ──────────────────────
ADDI R13,R0,11     | R13=11 (in MEM/WB stage) 71
ADDI R13,R0,22     | R13=22 (in EX/MEM stage - NEWER) 72
ADD  R14,R13,R0    | R14 MUST be 22. Priority check! 73

// ── SECTION 21: Load-to-Store Forwarding (Zero Stalls ideal) ─────────────
LW   R5,0(R0)      | R5=30 74
SW   R5,12(R0)     | Mem(12)=30. Should ideally not stall. 75
LW   R15,12(R0)    | R15=30 [verify SW wrote correctly] 76

// ── SECTION 22: Halt ─────────────────────────────────────────
J    0             | infinite loop (halt) 77