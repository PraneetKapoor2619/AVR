#undef F_CPU
#define F_CPU 16000000UL

#include<avr/io.h>
#include<util/delay.h>

#define A (1 << 6)
#define B (1 << 7)
#define C (1 << 0)
#define D (1 << 1)
#define E (1 << 2)
#define F (1 << 3)
#define G (1 << 4)
#define DP (1 << 5)

int main(void){
	DDRD = 0xFF;
	DDRB = 0xFF;
	DDRC = 0xFF;
	while(1){
		PORTD = (1 << 2) | A;
		PORTD &= ~B;
		PORTB = ~(C | DP);
		PORTC = G;
		_delay_us(50);

		PORTD = (1 << 3) | A | B;
		PORTB = ~(C | D | E | DP);
		PORTC = ~G;
		_delay_us(50);

		PORTD = (1 << 4) | A | B;
		PORTB = ~(D | E | F | G | DP);
		_delay_us(50);
		
		PORTD = (1 << 5) | A | B;
		PORTB = ~(DP);
		PORTC = G;
		_delay_us(50);
	}
	return 0;
}
