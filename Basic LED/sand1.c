#undef F_CPU
#define F_CPU 1000000UL

#include<avr/io.h>
#include<util/delay.h>

int main()
{
    DDRD = 0xFF;
    while(1){
        PORTD = PORTD ^ ((1<<PD1)|(1<<PD3)|(1<<PD5)|(1<<PD7));
        _delay_ms(150);
    }
    return 0;
}

        