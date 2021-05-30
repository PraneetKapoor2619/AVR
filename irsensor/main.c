#undef F_CPU
#define F_CPU 16000000UL

#include<avr/io.h>
#include<stdio.h>
#include<util/delay.h>
#include "pinDefines.h"
#include "USART.h"


int main(void)
{
	char string[128];
	DDRB = 0x00;
	PORTB = 0x00;
	initUSART();
	while(1){
		if(PINB == 0x01)
			printString("FAR\n\r");
		else
			printString("CLOSE\n\r");
		_delay_ms(100);
	}
}
