#undef F_CPU
#define F_CPU 1000000UL

#include<avr/io.h>
#include<util/delay.h>

int shift_left();
int shift_right();

int main()
{
    DDRC = 0b11111111;                   //all port D pins have been set as output
    PORTC = 0x01;
    while(1){
        _delay_ms(50);
        PORTC = (PORTC << 1);
        if(PORTC == 128){
           _delay_ms(50);
           PORTC = 0x01;
        }
    }
    return 0;
}