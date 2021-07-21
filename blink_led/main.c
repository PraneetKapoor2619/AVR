#undef F_CPU
#define F_CPU 1000000UL

#include<avr/io.h>
#include<util/delay.h>

int main(){
	DDRA = 0xff;
	while(1){
		PORTA ^= (1<<0);
		_delay_ms(100);
	}
}
