.include "C:\Program Files\avrassembler\include\m8Adef.inc"
MAIN:	
		LDI R16, 12
		OUT DDRB, R16
		OUT PORTB, R16
		RJMP MAIN