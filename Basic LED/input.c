#undef F_CPU
#define F_CPU 1000000UL

#include<avr/io.h>
#include<util/delay.h>

int main()
{
    DDRA = 0xFF;
    DDRD = 0x00;
    PORTD = 0xFF;
    while(1){
        PORTA = PIND;
    }
    return 0;
}