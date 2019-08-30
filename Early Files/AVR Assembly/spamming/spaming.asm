.include "C:\Program Files\avrassembler\include\m8Adef.inc"

;PROGRAM TO EXPERIMENT WITH SPM INSTRUCTION AND TO KNOW 
;WHETHER I KNOW IT OR NOT.




					.def SPMBITCON = R16
					.def LOOP = R17

					
					
					.org 0x0F80
					LDI ZH, 0
					LDI ZL, 0
					LDI SPMBITCON, 3
					LDI LOOP, 0
LOOP1:				CPI LOOP, 4
                    BRLO PGER
					BREQ CONT1
PGER:				CPI ZL, 64
					BRLO PGER2
					BRGE PGER1
PGER1:				ADIW ZH:ZL, 63
					ADIW ZH:ZL, 1
PGER2:				RCALL DO_SPM
					INC LOOP
					RJMP LOOP1
CONT1:				LDI SPMBITCON, 1
					LDI R21, 0b11100000
					LDI R20, 0b00000111
					MOV R0, R20
					MOV R1, R21
					LDI ZL, 0
					RCALL DO_SPM
					LDI R21, 0b10111011
					LDI R20, 0b00000111
					MOV R0, R20
					MOV R1, R21
					ADIW ZH:ZL, 2
					RCALL DO_SPM
					LDI R21, 0b10111011
					LDI R20, 0b00001000
					MOV R0, R20
					MOV R1, R21
					ADIW ZH:ZL, 2
					RCALL DO_SPM
					LDI R21, 0b11000000
					LDI R20, 0b00000000
					LDI R17, 32
					OUT DDRB, R17
					OUT PORTB, R17
					MOV R0, R20
					MOV R1, R21
					ADIW ZH:ZL, 2
					RCALL DO_SPM
CONT2:				LDI SPMBITCON, 5
					LDI ZH, 0
					LDI ZL, 0
					RCALL DO_SPM
CONT3:				RJMP 0x0000


DO_SPM:			
WAIT_SPM:			IN R18, SPMCR
					SBRC R18, SPMEN
					RJMP WAIT_SPM
					IN R19, SREG
					CLI
WAIT_EE:			SBIC EECR, EEWE
					RJMP WAIT_EE
					OUT SPMCR, SPMBITCON
					SPM
					OUT SREG, R19
					RET
