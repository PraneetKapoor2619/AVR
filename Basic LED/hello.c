#undef F_CPU
#define F_CPU 16000000UL

#include<avr/io.h>
#include<util/delay.h>

int main()
{
    DDRB = 0xFF;                   //all port D pins have been set as output
    while(1){                        //create an infinite loop
        PORTB = 0b00000001;
        _delay_ms(1000);
        PORTB = 0b00000000;
        _delay_ms(1000);
    }
    return 0;
}