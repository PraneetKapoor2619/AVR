.include "C:\Program Files\avrassembler\include\m8Adef.inc"
;PRGM NO.:4/O
;CREATED ON: 30.07.2019
;PROGRAMMER P.K.
		

MAIN:
				
				LDI R16, 0
				OUT DDRD, R16
				LDI R16, 255
				OUT PORTD, R16
MAIN1:	
				IN R17, PIND
				LDI R18, 244
				ADD R18, R17
				OUT DDRB, R17
				OUT PORTB, R17
				RJMP 0x00

