; ==========================================
; ALU & Extender Verification Program
; ==========================================

; Test Sign Extension
ADDI R1, R0, -5

; Test Zero Extension
ANDI R2, R0, 15
ORI  R3, R0, 7

; Test AND
AND R4, R2, R3

; Test OR
OR  R5, R2, R3

; Test XOR
XOR R6, R2, R3

; Test SLL
ADDI R7, R0, 2
SLL R8, R3, R7

; Test SRL
SRL R9, R8, R7

; Test Zero Flag
SUB R10, R2, R2

; Simple Branch Test
BEQ R10, R0, PASS

FAIL:
J FAIL

PASS:
J PASS