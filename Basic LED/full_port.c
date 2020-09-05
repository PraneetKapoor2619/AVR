#undef F_CPU
#define F_CPU 1000000UL

#include<avr/io.h>
#include<util/delay.h>

int main()
{
    uint8_t value = 0;
    DDRD = 0xFF;                    //all port D pins have been set as output
    for(;;){                        //create an infinite loop
       PORTD = value;
       value = value + 1;
       _delay_ms(100);
    }
    return 0;
}