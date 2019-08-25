.nolist
.include "C:\Program Files\avrassembler\include\m8Adef.inc"
.list
;NEW PROJECT
;STARTED ON 15.08.2019
;CODING BEGAN ON 18.09.2019


.macro DELAY
					LDI R18, 0
		LOOP:
					LDI R19, 0
		CHECKPOINT:
					CPI R19, 255
					BRNE LOOP1
					BREQ LOOP2
		COMPARE:
					CPI R18, @0
					BRLO LOOP
					BREQ CHAKA
		LOOP1:
					INC R19
					RJMP CHECKPOINT
		LOOP2:
					INC R18
					RJMP COMPARE
		CHAKA:
.endmacro


STACKINT:												;SETS STACK FOR THE ADDRESS OF CALLING FUNCTION
					LDI R16, LOW(RAMEND)				;RAMEND IS EQUAL TO 0x45F
					OUT SPL, R16						;RAMEND HIGH BYTE IS 0000 0100->SPL
					LDI R16, HIGH(RAMEND)				;RAMEND LOW BYTE IS  0101 1111->SPH
					OUT SPH, R16
			
			
RESETVARINT:
					LDI R16, 0	
					LDI R17, 0							;RAM LOC. 0x00 TO 0x01F ARE MAPPED TO 32 GENERAL REG. BANK
					LDI R30, $60						;RAM LOC. 0x020 TO 0x05F ARE MAPPED TO 64 I/O REG. BANK
					LDI R31, 00						;DATA STORING THEREFORE STARTS FROM 0x060 
														;LEAVE 0x40F TO 0x45F FOR FUNCTION CALL ADDRESS STACK
													
					
RESET1:
					ST Z+, R16							;LOADS 00 TO RAM ADDRESS Z. THEN INCREMENTS Z POINTER
					OUT DDRB, R17						;DISPLAY OFF
					OUT PORTB, R17
					DELAY 1
					INC R17								;INCREMENTS R17 WITH EVERY WRITE
					CPI ZL, 95							;COMPARE ZL WITH 95 = LOW(RAMEND)
					BRNE RESET1						;IF LOWER GO TO RESET1
					BREQ RESET2						;IF EQUAL, POINTER MIGHT BE AT 0x45F. SO GOTO RESET2
					
					
RESET2:
					CPI ZH, 4							;COMPARE ZH WITH 4 = HIGH(RAMEND)
					BRNE RESET1						;IF NOT EQUAL GOTO RESET1 TO CLEAR MORE MEMORY
					BREQ RESET_TEST					;IF EQUAL GO TO RESET_TEST TO DISPLAY THE VALUES 
														;FROM LOC. $60 TO $FF
					
					
RESET_TEST:											;INITIALIZES FOR RESET_TEST
					LDI ZL, $60						;SET ZL TO $60
					LDI ZH, 0							;SET ZH TO 0
					LDI R16, 255
					OUT DDRB, R16						;SET TO OUTPUT
					
					
DISPLAY_RAM:
					LD R16, Z+							;LOAD R16 FROM MEMORY LOCATION POINTED BY Z REG.
					OUT PORTB, R16						;OUTPUT R16
					DELAY 10				
					COM R16								;COMPLEMENT R16. IF R16 = RAM(Z) = 00, COM R16 = R16 = 255
					OUT PORTB, R16						;OUTPUT R16
					DELAY 15
					CPI ZL, $FF						;COMPARE ZL AND $FF
					BRLO DISPLAY_RAM					;IF LESS THAN, GOTO DISPLAY_RAM
					BREQ MAIN							;IF EQUAL, TEST IS COMPLETED AND GO TO MAIN SUBROUTINE
					

;================================================================================================================

					
MAIN:
					LDI R16, 0                         
					OUT PORTB, R16						;DISPLAY GOES BLANK
					LDI R20, 0
					
;PC0 = GO
;ITER1 = ZH
;ITER2 = ZL
;PC3 = D   WHICH IS FOR DATA


PINSET:
					OUT DDRC, R16						;SET DATA DIRECTION REGISTER C TO INPUT BY SETTING ALL BITS TO 0
					OUT PORTC, R16						;DISABLE INTERNAL PULL-UP RESISTORS IN PORTC. CONNECT TO SCHMITT
					OUT DDRD, R16						;SET DATA DIRECTION REGISTER D TO INPUT BY SETTING ALL BITS TO 0
					COM R16								;COMPLEMENT R16, R16 = 0xFF
					OUT PORTD, R16						;ENABLE PULL-UP RESISTORS IN PORTD BY SETTING ALL BITS TO 1
					OUT DDRB, R16						;SETS DATA DIRECTION REGISTER B TO OUPUT BY SETTING ALL BITS TO 1
					COM R16								;COMPLEMENT R16, R16 = 0x00
														;DISPLAY IS ALREADY SET TO BLANK
														
;===================================================================================================														

					;X = PROGRAM COUNTER (PC)
										
					
					;Y = POINTER 1 (P1)
					
					
					;Z = POINTER 2 (P2)
					
					
					.def DF1 = R16						;R16 = DATAFETCH 1 
					.def DF2 = R17						;R17 = DATAFETCH 2
					.def DF3 = R18						;R18 = DATAFETCH 3
					.def DF4 = R19						;R19 = DATAFETCH 4
					.def DF5 = R20 					;R20 = DATAFETCH 5
								
					.def AC = R0						;R0 = ACCUMULATOR
					.def ER = R1						;R1 = EXTENSION REGISTER
					.def FAKE = R2						;R2 = FAKE REGISTER. HELPS IN 
														;OPERATING ON VALUES FROM RAM
					.def AF = R21						;FAKE ACCUMULATOR									
					.def ITER1 = R22
					.def ITER2 = R23
					LDI ITER1, 0
					LDI ITER2, 0
;===================================================================================================================

CONCHECK:												;CHECKS THE CONTROL KEYS OF COMPUTER
					SBIC PINC, 0						;SKIP NEXT INSTRUCTION IF GO IS NOT SET
					RCALL GO
					SBIC PINC, 1						;SKIP NEXT INSTRUCTION IF ZH IS NOT SET
					RCALL ZHENT
					SBIC PINC, 2						;SKIP NEXT INSTRUCTION IF ZL IS NOT SET
					RCALL ZLENT
					SBIC PINC, 3						;SKIP NEXT INSTRUCTION IF DATA IS NOT SET
					RCALL DATAENT
					SBIS PINC, 3						;SKIP NEXT INSTRUCTION IF DATA IS SET
					RCALL DATACHECK
					RJMP CONCHECK
					
		
		
ZHENT:
					IN ZH, PIND
					OUT PORTB, ZH
					RET
					

ZLENT:
					IN ZL, PIND
					OUT PORTB, ZL
					RET
					
					
DATAENT:
					SBRC R20, 0
					RET
					INC R20
					IN R16, PIND
					OUT PORTB, R16
					ST Z+, R16
					RET


DATACHECK:
					LDI R20, 0
					RET
					
					
GO:
					MOV XL, ZL
					MOV XH, ZH
GOMAIN:
					LD DF1, X+
					
					MOV ITER2, ITER1
					
					LI:
					CPI DF1, 0b11000001
					BREQ LOADY
					BRNE L2		
					LOADY:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV YH, DF2
					MOV YL, DF3
					LD AC, Y
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L2:
					CPI DF1, 0b11000010
					BREQ LOADZ
					BRNE L3
					LOADZ:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV ZH, DF2
					MOV ZL, DF3
					LD AC, Z
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					
					L3:
					CPI DF1, 0b11001001
					BREQ STOREY
					BRNE L4
					STOREY:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV YH, DF2
					MOV YL, DF3
					ST Y, AC
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L4:
					CPI DF1, 0b11001010
					BREQ STOREZ
					BRNE L5
					STOREZ:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV ZH, DF2
					MOV ZL, DF3
					ST Z, AC
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L5:
					CPI DF1, 0b11010001
					BREQ ANDY
					BRNE L6
					ANDY:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV YH, DF2
					MOV YL, DF3
					LD FAKE, Y
					AND AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L6:
					CPI DF1, 0b11010001
					BREQ ANDZ
					BRNE L7
					ANDZ:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV ZH, DF2
					MOV ZL, DF3
					LD FAKE, Z
					AND AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L7:
					CPI DF1, 0b11011001
					BREQ ORY
					BRNE L8
					ORY:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV YH, DF2
					MOV YL, DF3
					LD FAKE, Y
					OR AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L8:
					CPI DF1, 0b11011010
					BREQ ORZ
					BRNE L9
					ORZ:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV ZH, DF2
					MOV ZL, DF3
					LD FAKE, Z
					OR AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L9:
					CPI DF1, 0b11100001
					BREQ XORY
					BRNE L10
					XORY:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV YH, DF2
					MOV YL, DF3
					LD FAKE, Y
					EOR AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					
					L10:
					CPI DF1, 0b11100010
					BREQ XORZ
					BRNE L11
					XORZ:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV ZH, DF2
					MOV ZL, DF3
					LD FAKE, Z
					EOR AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L11:
					CPI DF1, 0b11110001
					BREQ ADDY
					BRNE L12
					ADDY:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV YH, DF2
					MOV YL, DF3
					LD FAKE, Y
					ADC AC, FAKE 
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L12:
					CPI DF1, 0b11110010
					BREQ ADDZ
					BRNE L13
					ADDZ:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV ZH, DF2
					MOV ZL, DF3
					LD FAKE, Z
					EOR AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L13:
					CPI DF1, 0b11111001
					BREQ CADY
					BRNE L14
					CADY:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV YH, DF2
					MOV YL, DF3
					LD FAKE, Y
					COM FAKE
					ADC AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L14:
					CPI DF1, 0b11111010
					BREQ CADZ
					BRNE L15
					CADZ:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV ZH, DF2
					MOV ZL, DF3
					LD FAKE, Z
					COM FAKE
					ADC AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L15:
					CPI DF1, 0b10101001
					BREQ ILDY
					BRNE L16
					ILDY:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV YH, DF2
					MOV YL, DF3
					LD FAKE, Y
					INC FAKE
					MOV AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L16:
					CPI DF1, 0b10101010
					BREQ ILDZ
					BRNE L17
					ILDZ:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV ZH, DF2
					MOV ZL, DF3
					LD FAKE, Z
					INC FAKE
					MOV AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					L17:
					CPI DF1, 0b10111001
					BREQ DLDY
					BRNE L18
					DLDY:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV YH, DF2
					MOV YL, DF3
					LD FAKE, Y
					DEC FAKE
					MOV AC, FAKE
					MOV XH, DF4
					MOV XL, DF5
					INC ITER1
					
					
					L18:
					CPI DF1, 0b11000100
					BREQ LDIAC
					BRNE L19
					LDIAC:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					MOV AC, DF2
					MOV XH, DF3
					MOV XL, DF4
					INC ITER1
					
					L19:
					CPI DF1, 0b11010100
					BREQ ANIAC
					BRNE L20
					ANIAC:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					AND AC, DF2
					MOV XH, DF3
					MOV XL, DF4
					INC ITER1
					
					L20:
					CPI DF1, 0b11011100
					BREQ ORIAC
					BRNE L21
					ORIAC:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					OR AC, DF2
					MOV XH, DF3
					MOV XL, DF4
					INC ITER1
					
					L21:
					CPI DF1, 0b11100100
					BREQ XRIAC
					BRNE L22
					XRIAC:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					EOR AC, DF2
					MOV XH, DF3
					MOV XL, DF4
					INC ITER1
					
					L22:
					CPI DF1, 0b11110100
					BREQ ADIAC
					BRNE L23
					ADIAC:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					ADC AC, DF2
					MOV XH, DF3
					MOV XL, DF4
					INC ITER1
					
					L23:
					CPI DF1, 0b11111100
					BREQ CAIAC
					BRNE L24
					CAIAC:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					COM DF2
					ADC AC, DF2
					MOV XH, DF3
					MOV XL, DF4
					INC ITER1
					
					L24:
					CPI DF1, 0b10010001
					BREQ JMPY
					BRNE L25
					JMPY:
					LD DF2, X+
					LD DF3, X+
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L25:
					CPI DF1, 0b10010101
					BREQ JP
					BRNE L26
					JP:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV AF, AC
					CPI AF, 1
					BRGE L251
					BRLO L252
						L251:
						MOV XH, DF2
						MOV XL, DF3
						L252:
						NOP
						MOV XH, DF4
						MOV XL, DF5
						INC ITER1
					
					L26:
					CPI DF1, 0b10011000
					BREQ JZ
					BRNE L27
					JZ:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV AF, AC
					CPI AF, 0
					BREQ L261
					BRNE L262
						L261:
						MOV XH, DF2
						MOV XL, DF3
						L262:
						NOP
						MOV XH, DF4
						MOV XL, DF5
						INC ITER1
						
					L27:
					CPI DF1, 0b10011100
					BREQ JNZ
					BRNE L28
					JNZ:
					LD DF2, X+
					LD DF3, X+
					LD DF4, X+
					LD DF5, X+
					MOV AF, AC
					CPI AF, 0
					BRNE L271
					BREQ L272
						L271:
						MOV XH, DF2
						MOV XL, DF3
						L272:
						NOP
						MOV XH, DF4
						MOV XL, DF5
						INC ITER1
						
					L28:
					CPI DF1, 0b01000000
					BREQ LDE
					BRNE L29
					LDE:
					LD DF2, X+
					LD DF3, X+
					MOV AC, ER
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					
					L29:
					CPI DF1, 0b00000001
					BREQ XAE
					BRNE L30
					XAE:
					LD DF2, X+
					LD DF3, X+
					MOV FAKE, AC
					MOV AC, ER
					MOV ER, FAKE
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L30:
					CPI DF1, 0b01010000
					BREQ ANE
					BRNE L31
					ANE:
					LD DF2, X+
					LD DF3, X+
					AND AC, ER
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					
					L31:
					CPI DF1, 0b01011000
					BREQ ORE
					BRNE L32
					ORE:
					LD DF2, X+
					LD DF3, X+
					OR AC, ER
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L32:
					CPI DF1, 0b01100000
					BREQ XRE
					BRNE L33
					XRE:
					LD DF2, X+
					LD DF3, X+
					EOR AC, ER
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L33:
					CPI DF1, 0b01110000
					BREQ ADE
					BRNE L34
					ADE:
					LD DF2, X+
					LD DF3, X+
					ADC AC, ER
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L34:
					CPI DF1, 0b01111000
					BREQ CAE
					BRNE L35
					CAE:
					LD DF2, X+
					LD DF3, X+
					COM ER
					ADC AC, ER
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L35:
					CPI DF1, 0b00110001
					BREQ XPALY
					BRNE L36
					XPALY:
					LD DF2, X+
					LD DF3, X+
					MOV AF, AC
					MOV AC, YL
					MOV YL, AF
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					
					L36:
					CPI DF1, 0b00110010
					BREQ XPALZ
					BRNE L37
					XPALZ:
					LD DF2, X+
					LD DF3, X+
					MOV AF, AC
					MOV AC, ZL
					MOV ZL, AF
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L37:
					CPI DF1, 0b00110101
					BREQ XPAHY
					BRNE L38
					XPAHY:
					LD DF2, X+
					LD DF3, X+
					MOV AF, AC
					MOV AC, YH
					MOV YH, AF
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L38:
					CPI DF1, 0b00110110
					BREQ XPAHZ
					BRNE L39
					XPAHZ:
					LD DF2, X+
					LD DF3, X+
					MOV AF, AC
					MOV AC, ZH
					MOV ZH, AF
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L39:
					CPI DF1, 0b00111101
					BREQ XPPCY
					BRNE L40
					XPPCY:
					LD DF2, X+
					LD DF3, X+
					MOV AF, XL
					MOV XL, YL
					MOV YL, AF
					MOV AF, XH
					MOV XH, YH
					MOV YH, AF
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L40:
					CPI DF1, 0b00111110
					BREQ XPPCZ
					BRNE L41
					XPPCZ:
					LD DF2, X+
					LD DF3, X+
					MOV AF, XL
					MOV XL, ZL
					MOV ZL, AF
					MOV AF, XH
					MOV XH, ZH
					MOV ZH, AF
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L41:
					CPI DF1, 0b00011000
					BREQ SIND
					BRNE L42
					SIND:
					LD DF2, X+
					LD DF3, X+
					IN AC, PIND
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L42:
					CPI DF1, 0b00011001
					BREQ SINC
					BRNE L43
					SINC:
					LD DF2, X+
					LD DF3, X+
					IN AC, PINC
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L43:
					CPI DF1, 0b00011010
					BREQ SONC
					BRNE L44
					SONC:
					LD DF2, X+
					LD DF3, X+
					OUT DDRC, AC
					OUT PORTC, AC
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					
					L44:
					CPI DF1, 0b00011011
					BREQ SOND
					BRNE L45
					SOND:
					LD DF2, X+
					LD DF3, X+
					OUT PORTB, AC
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L45:
					CPI DF1, 0b00011100
					BREQ SR
					BRNE L46
					SR:
					LD DF2, X+
					LD DF3, X+
					ASR AC
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L46:
					CPI DF1, 0b00011110
					BREQ RR
					BRNE L47
					RR:
					LD DF2, X+
					LD DF3, X+
					ROR AC
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					
					L47:
					CPI DF1, 0b00000010
					BREQ CCL
					BRNE L48
					CCL:
					LD DF2, X+
					LD DF3, X+
					CLC
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L48:
					CPI DF1, 0b00000011
					BREQ SCL
					BRNE L49
					SCL:
					LD DF2, X+
					LD DF3, X+
					SEC
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L49:
					CPI DF1, 0b00000100
					BREQ DINT
					BRNE L50
					DINT:
					LD DF2, X+
					LD DF3, X+
					CLI
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					
					L50:
					CPI DF1, 0b00000101
					BREQ IEN
					BRNE L51
					IEN:
					LD DF2, X+
					LD DF3, X+
					SEI
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					
					L51:
					CPI DF1, 0b00000110
					BREQ CSA
					BRNE L52
					CSA:
					LD DF2, X+
					LD DF3, X+
					IN AC, SREG
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L52:
					CPI DF1, 0b00000111
					BREQ CAS
					BRNE L53
					CAS:
					LD DF2, X+
					LD DF3, X+
					OUT SREG, AC
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					L53:
					CPI DF1, 0b00001000
					BREQ NOPETY
					BRNE LN
					NOPETY:
					LD DF2, X+
					LD DF3, X+
					NOP
					MOV XH, DF2
					MOV XL, DF3
					INC ITER1
					
					
					
					CPI XH, 0b01000101
					BREQ LN
					BRNE LN0
					LN:
					RJMP MAIN
					LN0:
					RJMP GOMAIN
		