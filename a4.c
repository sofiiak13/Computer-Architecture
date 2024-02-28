/* a4.c
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

void led_state(uint8_t LED, uint8_t state) {
	DDRL = 0xff;  
	
	switch (LED) {
		case 0:
		if (state == 0){
			PORTL &= 0b01111111; //turn off
			}else{
			PORTL |= 0b10000000; //turn on
		}
		break;
		case 1:
		if (state == 0){
			PORTL &= 0b11011111; //turn off
			}else{
			PORTL |= 0b00100000; //turn on
		}
		break;
		case 2:
		if (state == 0){
			PORTL &= 0b11110111; //turn off
			}else{
			PORTL |= 0b00001000; //turn on
		}
		break;
		case 3:
		if (state == 0){
			PORTL &= 0b11111101; //turn off
			}else{
			PORTL |= 0b00000010; //turn on
		}
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

	int length = 19;
	
	  
	  // loop through the whole light sequence
	  for (int i = 0; i < length; i++) {
		  
		if (light[i] == 0x1){	//if light is 1, turn led 0 on
			led_state(0, 1);
		}else if (light[i] == 0xf){	//if light is 0xf, turn led 0 on
			  led_state(0, 1);
			  led_state(1, 1);
			  led_state(2, 1);
			  led_state(3, 1);
		}
		    _delay_ms(duration[i]);		 //at the end of the loop wait specified amount of time 
		    led_state(0, 0);			// and turn off ALL LED
		    led_state(1, 0);
		    led_state(2, 0);
		    led_state(3, 0);
		  
		  
	  }
}


void glow(uint8_t LED, float brightness) {
	long int threshold = PWM_PERIOD * brightness;
	
	for (;;) {
		if (count < threshold){
			led_state(LED, 1);		//turn on the led	
			
		}else if (count < PWM_PERIOD){
			led_state(LED, 0);		//turn off the led
			
		}else{
			count = 0;
			led_state(LED, 1);		//turn on the led
		}
	}
}



void pulse_glow(uint8_t LED) {
	
	int high_or_low = 0;		// either 0 or 1 which indicates if our brightness is low or high
	long int threshold = PWM_PERIOD * 0.1;
	int led_status = 0;			//right now led is turned off
	
	for (;;){
		 if (high_or_low == 1 && slow_count > 5) { // if the brightness is at its max and 10ms has passed
			 threshold++;						// then increment the threshold to decrease the brightness
			 slow_count = 0;
		 }else if (high_or_low == 0 && slow_count > 5) { // if the brightness is at its min and 10ms has passed
			 threshold--;						// then decrement the threshold to increase the brightness
			 slow_count = 0;
		 }
		 
		 if (threshold < 0){ // if statement for if the LED has reached its lowest brightness 
			 high_or_low = 1; // then we set the brightness to high
		 }else if (threshold >= PWM_PERIOD){ // if statement for if the LED has reached its highest brightness 
			 high_or_low = 0;				// then we set the brightness to low
		 }
		 
		 
		 if (count < threshold && !led_status) { // if the LED is off and count is less than threshold, turn it on
			 led_state(LED, 1);
			 led_status = 1;
		 }else if (count < PWM_PERIOD && led_status) { // if LED is on and count is less than PWN_PERIOD, turn it off
			 led_state(LED, 0);
			  led_status = 0;
		 }else if (count > PWM_PERIOD){ // if one cycle is completed and count > PWM_PERIOD, reset count to 0 and then turn led on
			 count = 0;
			 led_state(LED, 1);
			 led_status = 1;
		 }
	}
}


void light_show() {
	 uint8_t light[] = { 
		 0xf, 0, 0xf, 0, 0xf, 0, 0x6, 0, 0x9, 0, 0xf, 0, 0xf, 0, 0xf, 0, 0x9, 0, 0x6,  
		 0x8, 0xC, 0x6, 0x3, 0x1, 0x3, 0x6, 0xC, 0x8,
		 0x8, 0xC, 0x6, 0x3, 0x1, 0x3, 0x6,
		 0xf, 0, 0xf, 0, 0xf, 0, 
		 0x6, 0, 0x6, 0
		 };
		 
	 int duration[] = {
		 200, 100, 200, 100, 200, 100, 300, 100, 300, 100, 200, 100, 200, 100, 200, 100, 300, 100, 300, 
		 500, 500, 500, 500, 500, 500, 500, 500, 500,
		 500, 500, 500, 500, 500, 500, 500,
		 200, 100, 200, 100, 200, 100,
		 300, 100, 300, 100
		 };
	 
	 int length = 45;
	 
	  for (int i = 0; i < length; i++) {
		 
		 if (light[i] == 0x1){	//if light is 1, turn led 0 on
			led_state(0, 1);
		  }else if (light[i] == 0xf){	//if light is 0xf, turn led 0 on
			led_state(0, 1);
			led_state(1, 1);
			led_state(2, 1);
			led_state(3, 1);
		  }else if (light[i] == 0x6){
			  led_state(1, 1);
			  led_state(2, 1);
		  } else if (light[i] == 0xC){
			  led_state(2, 1);
			  led_state(3, 1);
		  } else if (light[i] == 0x3){
			  led_state(0, 1);
			  led_state(1, 1);
		  }else if (light[i] == 0x8){
			  led_state(3,1);
		  }else if (light[i] == 0x9){
			  led_state(0, 1);
			  led_state(3, 1);
		  }
		  
		  _delay_ms(duration[i]);
		  led_state(0, 0);
		  led_state(1, 0);
		  led_state(2, 0);
		  led_state(3, 0);
		  
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

/* This code could be used to test your work for part A.

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
	_delay_ms(1000); */


/* This code could be used to test your work for part B.
 */
	//SOS();


/* This code could be used to test your work for part C. */

	//glow(2, .01);
	//glow(3, .1);
	//glow(2, .5);
	//glow(0, .94);



/* This code could be used to test your work for part D. */
	
	pulse_glow(2);



/* This code could be used to test your work for the bonus part. */

	//light_show();


/* ****************************************************
 * **** END OF SECOND "STUDENT CODE" SECTION **********
 * ****************************************************
 */
}
