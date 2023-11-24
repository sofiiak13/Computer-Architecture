;
; a3part-C.asm
;
; Part C of assignment #3
;
;
; Student name: Sofiia Khutorna
; Student ID: v00999227
; Date of completed work:
;
; **********************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2022-Nov-05)
;
; This skeleton of an assembly-language program is provided to help you 
; begin with the programming tasks for A#3. As with A#2 and A#1, there are
; "DO NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes announced on
; Brightspace or in written permission from the course instruction.
; *** Unapproved changes could result in incorrect code execution
; during assignment evaluation, along with an assignment grade of zero. ***
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
;
; In this "DO NOT TOUCH" section are:
; 
; (1) assembler direction setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants that may be used later in
;     the program
;
; (4) code for initial setup of the Analog-to-Digital Converter
;     (in the same manner in which it was set up for Lab #4)
;
; (5) Code for setting up three timers (timers 1, 3, and 4).
;
; After all this initial code, your own solutions's code may start
;

.cseg
.org 0
	jmp reset

; Actual .org details for this an other interrupt vectors can be
; obtained from main ATmega2560 data sheet
;
.org 0x22
	jmp timer1

; This included for completeness. Because timer3 is used to
; drive updates of the LCD display, and because LCD routines
; *cannot* be called from within an interrupt handler, we
; will need to use a polling loop for timer3.
;
; .org 0x40
;	jmp timer3

.org 0x54
	jmp timer4

.include "m2560def.inc"
.include "lcd.asm"

.cseg
#define CLOCK 16.0e6
#define DELAY1 0.01
#define DELAY3 0.1
#define DELAY4 0.5

#define BUTTON_RIGHT_MASK 0b00000001	
#define BUTTON_UP_MASK    0b00000010
#define BUTTON_DOWN_MASK  0b00000100
#define BUTTON_LEFT_MASK  0b00001000

#define BUTTON_RIGHT_ADC  0x032
#define BUTTON_UP_ADC     0x0b0   ; was 0x0c3
#define BUTTON_DOWN_ADC   0x160   ; was 0x17c
#define BUTTON_LEFT_ADC   0x22b
#define BUTTON_SELECT_ADC 0x316

.equ PRESCALE_DIV=1024   ; w.r.t. clock, CS[2:0] = 0b101

; TIMER1 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))
.if TOP1>65535
.error "TOP1 is out of range"
.endif

; TIMER3 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

; TIMER4 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif

reset:
; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

; Anything that needs initialization before interrupts
; start must be placed here.

	.def temp1 = r21
	.def temp3 = r22

	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

	.def DATAH=r25  ;DATAH:DATAL  store 10 bits data from ADC
	.def DATAL=r24
	.def BOUNDARY_H=r1  ;hold high byte value of the threshold for button
	.def BOUNDARY_L=r0  ;hold low byte value of the threshold for button, r1:r0
	.def BOUNDARY2_H=r3  ;hold high byte value of the threshold for button
	.def BOUNDARY2_L=r2  ;hold low byte value of the threshold for button, r1:r0

; ***************************************************
; ******* END OF FIRST "STUDENT CODE" SECTION *******
; ***************************************************

; =============================================
; ====  START OF "DO NOT TOUCH" SECTION    ====
; =============================================

	; initialize the ADC converter (which is needed
	; to read buttons on shield). Note that we'll
	; use the interrupt handler for timer 1 to
	; read the buttons (i.e., every 10 ms)
	;
	ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, temp
	ldi temp, (1 << REFS0)
	sts ADMUX, r16

	; Timer 1 is for sampling the buttons at 10 ms intervals.
	; We will use an interrupt handler for this timer.
	ldi r17, high(TOP1)
	ldi r16, low(TOP1)
	sts OCR1AH, r17
	sts OCR1AL, r16
	clr r16
	sts TCCR1A, r16
	ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
	sts TCCR1B, r16
	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16

	; Timer 3 is for updating the LCD display. We are
	; *not* able to call LCD routines from within an 
	; interrupt handler, so this timer must be used
	; in a polling loop.
	ldi r17, high(TOP3)
	ldi r16, low(TOP3)
	sts OCR3AH, r17
	sts OCR3AL, r16
	clr r16
	sts TCCR3A, r16
	ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
	sts TCCR3B, r16
	; Notice that the code for enabling the Timer 3
	; interrupt is missing at this point.

	; Timer 4 is for updating the contents to be displayed
	; on the top line of the LCD.
	ldi r17, high(TOP4)
	ldi r16, low(TOP4)
	sts OCR4AH, r17
	sts OCR4AL, r16
	clr r16
	sts TCCR4A, r16
	ldi r16, (1 << WGM42) | (1 << CS42) | (1 << CS40)
	sts TCCR4B, r16
	ldi r16, (1 << OCIE4A)
	sts TIMSK4, r16

	sei

; =============================================
; ====    END OF "DO NOT TOUCH" SECTION    ====
; =============================================

; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

rcall lcd_init 

start:
	
	in temp3, TIFR3
	sbrs temp3, OCF3A
	rjmp start

	ldi temp3, 1<<OCF3A ;clear bit 1 in TIFR3 by writing logical one to its bit position, P163 of the Datasheet
	out TIFR3, temp3


	rjmp timer3

stop:
	rjmp stop


timer1:

	lds r16, SREG
	push r16
	push r20 
	push DATAL
	push DATAH
	

	lds	r20, ADCSRA
	ori r20, 0x40 
	sts	ADCSRA, r20	

wait:
	lds r20, ADCSRA ; current timer 
	andi r20, 0x40
	brne wait

	lds DATAL, ADCL
	lds DATAH, ADCH


	ldi r16, low(BUTTON_SELECT_ADC)
	mov BOUNDARY_L, r16
	ldi r16, high(BUTTON_SELECT_ADC)
	mov BOUNDARY_H, r16


	cp DATAL, BOUNDARY_L
	cpc DATAH, BOUNDARY_H
	brsh btn_not_pressed	
	
	ldi temp1, 1
	sts BUTTON_IS_PRESSED, temp1
	rjmp check_R
	


check_R:
	ldi r16, low(BUTTON_RIGHT_ADC)
	mov BOUNDARY2_L, r16
	ldi r16, high(BUTTON_RIGHT_ADC)
	mov BOUNDARY2_H, r16

	cp DATAL, BOUNDARY2_L
	cpc DATAH, BOUNDARY2_H
	brlo set_R ; branch if lower
	
	

check_U:
	ldi r16, low(BUTTON_UP_ADC)
	mov BOUNDARY2_L, r16
	ldi r16, high(BUTTON_UP_ADC)
	mov BOUNDARY2_H, r16

	cp DATAL, BOUNDARY2_L
	cpc DATAH, BOUNDARY2_H
	brlo set_U
	

check_D:
	ldi r16, low(BUTTON_DOWN_ADC)
	mov BOUNDARY2_L, r16
	ldi r16, high(BUTTON_DOWN_ADC)
	mov BOUNDARY2_H, r16

	cp DATAL, BOUNDARY2_L
	cpc DATAH, BOUNDARY2_H
	brlo set_D

check_L:
	ldi r16, low(BUTTON_LEFT_ADC)
	mov BOUNDARY2_L, r16
	ldi r16, high(BUTTON_LEFT_ADC)
	mov BOUNDARY2_H, r16

	cp DATAL, BOUNDARY2_L
	cpc DATAH, BOUNDARY2_H
	brlo set_L

set_R:
	ldi r30, 'R'
	sts LAST_BUTTON_PRESSED, r30
	rjmp end_1

set_U:
	ldi r30, 'U'
	sts LAST_BUTTON_PRESSED, r30
	rjmp end_1

set_D:
	ldi r30, 'D'
	sts LAST_BUTTON_PRESSED, r30
	rjmp end_1

set_L:
	ldi r30, 'L'
	sts LAST_BUTTON_PRESSED, r30
	rjmp end_1


btn_not_pressed:	
	
	ldi temp1, 0	
	sts BUTTON_IS_PRESSED, temp1

end_1:

	pop DATAL
	pop DATAH
	pop r20
	pop r16
	sts SREG, r16

	reti

timer3:
	ldi r16, 1
	ldi r17, 15
	push r16 ;row
	push r17 ;column
	rcall lcd_gotoxy
	pop r17
	pop r16

	clr r27
	lds r27, BUTTON_IS_PRESSED	     
	cpi r27, 0x01                   
	breq display_asterisk
            

display_dash:	
	
	ldi r16, '-'
	push r16
	rcall lcd_putchar
	pop r16
	rjmp start

display_asterisk:

	ldi r16, '*'
	push r16
	rcall lcd_putchar
	pop r16

display_letter:
	ldi r16, 1
	ldi r17, 0
	push r16 ;row
	push r17 ;column 
	rcall lcd_gotoxy
	pop r17
	pop r16

	clr r28
	lds r28, LAST_BUTTON_PRESSED 
	ldi r29, ' '
	
	push r28 
	push r29
	
	
	cpi r28, 'L'
	breq write_L
	
	cpi r28, 'D'
	breq write_D
	
	cpi r28, 'U'
	breq write_U
	
	cpi r28, 'R'
	breq write_R

	rjmp start
	
write_L:
	push r28
	rcall lcd_putchar
	pop r28
	
	push r29
	rcall lcd_putchar
	pop r29
	
	push r29
	rcall lcd_putchar
	pop r29
	
	push r29
	rcall lcd_putchar
	pop r29
	
	rjmp end_3
	
write_D:
	push r29
	rcall lcd_putchar
	pop r29
	
	push r28
	rcall lcd_putchar
	pop r28
	
	push r29
	rcall lcd_putchar
	pop r29
	
	push r29
	rcall lcd_putchar
	pop r29

	rjmp display_top

write_U:
	push r29
	rcall lcd_putchar
	pop r29
	
	push r29
	rcall lcd_putchar
	pop r29
	
	push r28
	rcall lcd_putchar
	pop r28
	
	push r29
	rcall lcd_putchar
	pop r29

	rjmp display_top

write_R:
	push r29
	rcall lcd_putchar
	pop r29
	
	push r29
	rcall lcd_putchar
	pop r29
	
	push r29
	rcall lcd_putchar
	pop r29
	
	push r28
	rcall lcd_putchar
	pop r28
	rjmp end_3


display_top:
	ldi r16, 0
	ldi r17, 0
	push r16 ;row
	push r17 ;column 
	rcall lcd_gotoxy
	pop r17
	pop r16
	
	clr r23
	lds r23, TOP_LINE_CONTENT

	push r23
	rcall lcd_putchar
	pop r23
	
end_3:

	pop r29
	pop r28
	rjmp start



; timer3:
;
; Note: There is no "timer3" interrupt handler as you must use
; timer3 in a polling style (i.e. it is used to drive the refreshing
; of the LCD display, but LCD functions cannot be called/used from
; within an interrupt handler).


timer4:
	clr temp1
	lds temp1, LAST_BUTTON_PRESSED	

	cpi temp1, 'U'
	breq increase_indx

	cpi temp1, 'D'
	breq decrease_indx

	reti


;IN THE LOOP YOUR VALUE SHOULD BE 0 + CHAR_INDEX
;USE TOP_LINE TO SAVE THE VALUE THAT YOU NEED TO DISPLAY AND DISPLAY IT IN TIMER 3
increase_indx:
; if doesn't work replace temp1 

	lds temp1, CURRENT_CHARSET_INDEX 	; load cur index 
	inc temp1				; update it by increasing by one
	sts CURRENT_CHARSET_INDEX, temp1

	rjmp search

decrease_indx:

	lds temp1, CURRENT_CHARSET_INDEX	; load cur index 
	dec temp1				; update it by decreasing by one
	sts CURRENT_CHARSET_INDEX, temp1

search:
	clr r17		; clear everything we are going to use
	clr r22
	clr r18

	push ZL		; push everything we are going to use
	push ZH
	push r18
	push r17

	in ZH, SPH ; make zh a stack pointer to high byte
	in ZL, SPL ; make zl a stack pointer to low byte

	ldi ZH, high(AVAILABLE_CHARSET<<1) ; access first letter
	ldi ZL, low(AVAILABLE_CHARSET<<1)

	lds r22, CURRENT_CHARSET_INDEX
	
loop:
	lpm r18, Z+			; start looping through AVAILABLE_CHARSET
	cpi r18, 0x00		
	breq end_search			

	dec r22
	tst r22
	breq store_top

	rjmp loop			; else continue looping
	
store_top:

	sts TOP_LINE_CONTENT, r18
	
end_search:

	pop r17
	pop r18
	pop ZH
	pop ZL
	
	reti




; ****************************************************
; ******* END OF SECOND "STUDENT CODE" SECTION *******
; ****************************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; r17:r16 -- word 1
; r19:r18 -- word 2
; word 1 < word 2? return -1 in r25
; word 1 > word 2? return 1 in r25
; word 1 == word 2? return 0 in r25
;
compare_words:
	; if high bytes are different, look at lower bytes
	cp r17, r19
	breq compare_words_lower_byte

	; since high bytes are different, use these to
	; determine result
	;
	; if C is set from previous cp, it means r17 < r19
	; 
	; preload r25 with 1 with the assume r17 > r19
	ldi r25, 1
	brcs compare_words_is_less_than
	rjmp compare_words_exit

compare_words_is_less_than:
	ldi r25, -1
	rjmp compare_words_exit

compare_words_lower_byte:
	clr r25
	cp r16, r18
	breq compare_words_exit

	ldi r25, 1
	brcs compare_words_is_less_than  ; re-use what we already wrote...

compare_words_exit:
	ret

.cseg
AVAILABLE_CHARSET: .db "0123456789abcdef_", 0


.dseg

BUTTON_IS_PRESSED: .byte 1			; updated by timer1 interrupt, used by LCD update loop
LAST_BUTTON_PRESSED: .byte 1        ; updated by timer1 interrupt, used by LCD update loop

TOP_LINE_CONTENT: .byte 16			; updated by timer4 interrupt, used by LCD update loop ; current char displayed on the board
CURRENT_CHARSET_INDEX: .byte 16		; updated by timer4 interrupt, used by LCD update loop  ; current char's index displayed on the board
CURRENT_CHAR_INDEX: .byte 1			; ; updated by timer4 interrupt, used by LCD update loop


; =============================================
; ======= END OF "DO NOT TOUCH" SECTION =======
; =============================================


; ***************************************************
; **** BEGINNING OF THIRD "STUDENT CODE" SECTION ****
; ***************************************************

.dseg

; If you should need additional memory for storage of state,
; then place it within the section. However, the items here
; must not be simply a way to replace or ignore the memory
; locations provided up above.


; ***************************************************
; ******* END OF THIRD "STUDENT CODE" SECTION *******
; ***************************************************
