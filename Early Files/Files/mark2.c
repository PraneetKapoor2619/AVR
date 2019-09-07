/*
CREATED ON 02.09.2019
CREATED BY P.K.
MODIFIED ON 03.09.2019
*/

/*
Byte to be tranferred to the slave is read from PIND. PORTD pull up resistors are enabled. 
PC0 is the control key. If pressed, the master sends the byte to slave bit by bit by 
controlling the MOSI and SCK lines of the slave.
PB0 is connected to MOSI pin of slave.
PB1 is connected to SCK pin of slave.
PC1 is the MISO pin. Keep i grounded if you wish.
*/
#undef F_CPU
#define F_CPU 1000000UL

#include<avr/io.h>
#include<util/delay.h>

#define HIGH 1
#define LOW 0

uint8_t transfer(uint8_t);
uint8_t E, address_counter = 0;

int main()
{
	DDRB = 0xFF;		//output pins
	PORTB = 0x00;		//output set to 0x00
	DDRD = 0x00;		//input pins
	PORTD = 0xFF;		//enable pull-up resistors
	DDRC = 0x00;		//input pins
	PORTC = 0x00;		//disable pull up resistors
	for(;;)
	{
		E = PIND;			//read the state of PORTD pins
		if(bit_is_set(PINC, PC0))
		{
			transfer(E);		//send state a data to slave
		}
		else if(bit_is_set(PINC, PC1))
		{
			transfer(0b01000000);		//byte 4//low byte
			transfer(0b00000000);		//byte 3
			transfer(address_counter);	//send address of word in page
			transfer(E);				//send data low byte
		}
		else if(bit_is_set(PINC, PC2))
		{
			transfer(0b01001000);		//byte 4//high byte
			transfer(0b00000000);		//byte 3
			transfer(address_counter);	//send address of word in page
			transfer(E);				//send data high byte
			if(address_counter == 31)	//if address is eqaul to 31, 
				address_counter = 0x00;	//reset address_counter
			else
				++address_counter;		//else increment address counter
		}
		else if(bit_is_set(PINC, PC3))
		{
			address_counter = 0x00;		//hard reset of address_counter
			PORTB = 0x00;				//set PORTB to 0x00, for using OR operator does no change unless both bits are 0
		}
		PORTB |= (address_counter<<2);	//display address_counter. Shift it by 2 bits to protect MOSI and SCK
	}
	return 0;
}

uint8_t transfer (uint8_t b) 
{
    for (unsigned int i = 0; i < 8; ++i) 
	{
		PORTB |= (((b & 0x80) ? HIGH : LOW)<<0);
		_delay_ms(10);
        PORTB |= (HIGH<<1);
        _delay_ms(10);
        b = (b << 1);			//The question is: what will happen if I remove this PIN_MISO. IMO bit shift will still happen.
		PORTB &= (LOW<<1);					//If you keep it as OR, the changes in MOSI and SCk due to bit shift won't happen.
        _delay_ms(10);
    }
	PORTB = 0x00;
      return b;
}