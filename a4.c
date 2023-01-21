/* a4.c
 * CSC Fall 2022
 * 
 * Student name:
 * Student UVic ID:
 * Date of completed work:
 *
 *
 * Code provided for Assignment #4
 *
 * Author: Mike Zastre (2022-Nov-22)
 *
 * This skeleton of a C language program is provided to help you
 * begin the programming tasks for A#4. As with the previous
 * assignments, there are "DO NOT TOUCH" sections. You are *not* to
 * modify the lines within these section.
 *
 * You are also NOT to introduce any new program-or file-scope
 * variables (i.e., ALL of your variables must be local variables).
 * YOU MAY, however, read from and write to the existing program- and
 * file-scope variables. Note: "global" variables are program-
 * and file-scope variables.
 *
 * UNAPPROVED CHANGES to "DO NOT TOUCH" sections could result in
 * either incorrect code execution during assignment evaluation, or
 * perhaps even code that cannot be compiled.  The resulting mark may
 * be zero.
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

#define __DELAY_BACKWARD_COMPATIBLE__ 1
#define F_CPU 16000000UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define DELAY1 0.000001
#define DELAY3 0.01

#define PRESCALE_DIV1 8
#define PRESCALE_DIV3 64
#define TOP1 ((int)(0.5 + (F_CPU/PRESCALE_DIV1*DELAY1))) 
#define TOP3 ((int)(0.5 + (F_CPU/PRESCALE_DIV3*DELAY3)))

#define PWM_PERIOD ((long int)500)

volatile long int count = 0;
volatile long int slow_count = 0;


ISR(TIMER1_COMPA_vect) {
	count++;
}


ISR(TIMER3_COMPA_vect) {
	slow_count += 5;
}

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */
void led_state(uint8_t LED, uint8_t state)
{
	DDRL = 0xFF;//set as output
	
	uint8_t l_on = 0b10000000;// start with bit 7 for port l
	l_on = l_on >> (LED*2);// shift Led*2 times depending on what led to turn on
	
	switch(state)
	{
		case 1:
			    PORTL |= l_on;// turn on only specific led
			    break;
		case 0:
			    PORTL &= ~l_on;// turn off only specific led
			    break;
	}
}


void SOS() {
    uint8_t light[] = {
        0x1, 0, 0x1, 0, 0x1, 0,
        0xf, 0, 0xf, 0, 0xf, 0,
        0x1, 0, 0x1, 0, 0x1, 0,
        0x0
    };

    int duration[] = {
        100, 250, 100, 250, 100, 500,
        250, 250, 250, 250, 250, 500,
        100, 250, 100, 250, 100, 250,
        250
    };
	uint8_t length = 19;
	
	int mask = 0b00000001;
	uint8_t this_l = 0x00;// pointer to each value in light[] to know what led to to turn on
	uint8_t LED = 0x00;// to know if led( 0 -3) to turn on
	for(int i = 0;i< length;i++)
	{
		mask = 0b00000001;
		this_l = light[i];// pointer
		for(int bit = 0; bit <= 3; bit++)// check each bit of each value in light 
		{
			LED = this_l & mask;//masking to check each bit
			mask = mask << 1;//shift left
			if(LED == 0x00)//means is off
			{
				led_state(bit,0);	
			}else//on
			{
				led_state(bit,1);
			}
		}
		_delay_ms(duration[i]);//delay
	}
}


void glow(uint8_t LED, float brightness) {
	float threshold = PWM_PERIOD * brightness; //threshold value
	if(brightness != 0.0)// so when brightness == 0 then don't dod anything
	{
		while(1)// infinite loop
		{
			if(count < threshold)
			{
				led_state(LED,1);//turn on
			}else if(count < PWM_PERIOD)
			{
				led_state(LED,0);//turn off
			}else//Count is greater than PWM_period
			{
				count = 0;//restart the counter
				led_state(LED,1);//turn on
			}
		}	
	}
}



void pulse_glow(uint8_t LED) {
			 //threshold value
			 float threshold = 0;
			while(1)// infinite loop
			{
				threshold = 0;
				slow_count = 0;
				/*TURN ON*/
				while(threshold < PWM_PERIOD)
				{
					threshold = slow_count*0.2;//random values, Had to play with it a lot
					if(count < threshold)
					{
						led_state(LED,1);//turn on
					}else if(count < PWM_PERIOD)
					{
						led_state(LED,0);//turn off
					}else//Count is greater than PWM_period
					{
						count = 0;//restart the counter
						led_state(LED,1);//turn on
					}
					
				}
				
				threshold = PWM_PERIOD+50;//random value for threshold
				slow_count = 0;
				count = 0;
				/*TURN OFF*/
				while(threshold > 0)
				{
					threshold = PWM_PERIOD - slow_count*0.09;
					if(count < threshold)
					{
						led_state(LED,1);//turn on
					}else if(count < PWM_PERIOD)
					{
						led_state(LED,0);//turn off
					}else//Count is greater than PWM_period
					{
						count = 0;//restart the counter
						led_state(LED,1);//turn on
					}
					
				}
				
			}
}
//FOR FUN
void always_show()
{
while(1)
{
		uint8_t light[] = {											         //s          done//start        done//start  done//start  done/
		0xf,0, 0xf,0, 0xf,0, 0x6,0, 0x9,0, 0xf,0, 0xf,0, 0xf,0, 0x9,0, 0x6,0, 0x8,0xC,0x6,0x3,0x1,0x3,0x6,0xC,0x8,0XC,0X6,0X3,0X1,0X3, 0X6,0,0XF,0,0XF,0,0X6,0,0X6,0};
		uint8_t length = 44;
		/*same as S0S, only above code was changed*/
		int mask = 0b00000001;
		uint8_t this_l = 0x00;// pointer to each value in light[] to know what led to to turn on
		uint8_t LED = 0x00;// to know if led( 0 -3) to turn on
		for(int i = 0;i< length;i++)
		{
			mask = 0b00000001;
			this_l = light[i];// pointer
			for(int bit = 0; bit <= 3; bit++)// check each bit of each value in light
			{
				LED = this_l & mask;//masking to check each bit
				mask = mask << 1;//shift left
				if(LED == 0x00)//means is off
				{
					led_state(bit,0);
				}else//on
				{
					led_state(bit,1);
				}
			}
				if(this_l == 0)
				{
					_delay_ms(100);
				}else
				{
					_delay_ms(10);//delay
				}
		}	
}
}

void light_show() {
	uint8_t light[] = {											         //s          done//start        done//start  done//start  done/
	0xf,0, 0xf,0, 0xf,0, 0x6,0, 0x9,0, 0xf,0, 0xf,0, 0xf,0, 0x9,0, 0x6,0, 0x8,0xC,0x6,0x3,0x1,0x3,0x6,0xC,0x8,0XC,0X6,0X3,0X1,0X3, 0X6,0,0XF,0,0XF,0,0X6,0,0X6,0};

	int duration[] = {
	150,150, 150,150, 150,150, 150,150, 150,150, 150,150, 150,150, 150,150, 150,150, 150,150, 100,100, 100,100, 100,100, 100,100, 100,100, 100,100, 100,100, 150,150, 150,150, 150,150, 150,150, 150,150, 150,150, 150,150, 150,150, 150,150, 150,150, 150,150, 150,150 };
	uint8_t length = 44;
	
	/*same as S0S, only above code was changed*/
    int mask = 0b00000001;
    uint8_t this_l = 0x00;// pointer to each value in light[] to know what led to to turn on
    uint8_t LED = 0x00;// to know if led( 0 -3) to turn on
    for(int i = 0;i< length;i++)
    {
	    mask = 0b00000001;
	    this_l = light[i];// pointer
	    for(int bit = 0; bit <= 3; bit++)// check each bit of each value in light
	    {
		    LED = this_l & mask;//masking to check each bit
		    mask = mask << 1;//shift left
		    if(LED == 0x00)//means is off
		    {
			    led_state(bit,0);
		    }else//on
		    {
			    led_state(bit,1);
		    }
	    }
	    _delay_ms(duration[i]);//delay
    }
}


/* ***************************************************
 * **** END OF FIRST "STUDENT CODE" SECTION **********
 * ***************************************************
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

int main() {
    /* Turn off global interrupts while setting up timers. */

	cli();

	/* Set up timer 1, i.e., an interrupt every 1 microsecond. */
	OCR1A = TOP1;
	TCCR1A = 0;
	TCCR1B = 0;
	TCCR1B |= (1 << WGM12);
    /* Next two lines provide a prescaler value of 8. */
	TCCR1B |= (1 << CS11);
	TCCR1B |= (1 << CS10);
	TIMSK1 |= (1 << OCIE1A);

	/* Set up timer 3, i.e., an interrupt every 10 milliseconds. */
	OCR3A = TOP3;
	TCCR3A = 0;
	TCCR3B = 0;
	TCCR3B |= (1 << WGM32);
    /* Next line provides a prescaler value of 64. */
	TCCR3B |= (1 << CS31);
	TIMSK3 |= (1 << OCIE3A);


	/* Turn on global interrupts */
	sei();

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */

/* This code could be used to test your work for part A.*/
	/*
	led_state(0, 1);
	_delay_ms(1000);
	led_state(2, 1);
	_delay_ms(1000);
	led_state(1, 1);
	_delay_ms(1000);
	led_state(2, 0);
	_delay_ms(1000);
	led_state(0, 0);
	_delay_ms(1000);
	led_state(1, 0);
	_delay_ms(1000);
 */

/* This code could be used to test your work for part B.*/

	//SOS();
 

/* This code could be used to test your work for part C. */

	//glow(2, 1.00);




/* This code could be used to test your work for part D.*/

	//pulse_glow(3);
 


/* This code could be used to test your work for the bonus part.*/

	//light_show();
 
	always_show();
/* ****************************************************
 * **** END OF SECOND "STUDENT CODE" SECTION **********
 * ****************************************************
 */
}
