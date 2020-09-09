/*
Write a program in C from scratch which turns on the pins of port B in the following order: 7, 6, 5, 4, 3, 2, 1, 0 , 1, 2, 3, 4, 5, 6, 7, 6... ad infinitum. And please use functions; it makes the code beautiful to look at
*/
#undef F_CPU
#define F_CPU 1000000UL

#include<avr/io.h>
#include<util/delay.h>

int main()
{
    DDRB = 0xFF;
    /*1. Set bit 7, then shift right, 
      2. if have reached bit 1, then start going left
       3. if bit 7 has been reached, go to step 1
    */
    PORTB = 0b10000000;
    while(1){
        while(1){
            PORTB = (PORTB >> 1);  //0b01000000
            _delay_ms(50);
            if (PORTB == 0b00000001)
                break;
        }
        while(1){
            PORTB = (PORTB << 1);
            _delay_ms(50);
            if(PORTB == 0b10000000)
                break;
        }
    }
    return 0;
}