; a2-signalling.asm
; CSC 230: Fall 2022
;
; Student name:
; Student ID:
; Date of completed work:
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2022-Oct-15)
;
 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are "DO
; NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes changes
; announced on Brightspace or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****

.include "m2560def.inc"
.cseg
.org 0

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

	; initializion code will need to appear in this
    ; section
	ldi r17, high(RAMEND)
	out SPH, r17
	ldi r17, low(RAMEND)
	out SPL, r17

	;setting portL and portB as an output
	ldi r17, 0xFF 
	sts DDRL, r17 
	out DDRB, r17

	.def tempMask = r23
	

; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION **********
; ***************************************************

; ---------------------------------------------------
; ---- TESTING SECTIONS OF THE CODE -----------------
; ---- TO BE USED AS FUNCTIONS ARE COMPLETED. -------
; ---------------------------------------------------
; ---- YOU CAN SELECT WHICH TEST IS INVOKED ---------
; ---- BY MODIFY THE rjmp INSTRUCTION BELOW. --------
; -----------------------------------------------------

	rjmp test_part_e
	; Test code


test_part_a:
	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000

test_part_c_loop:
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop

	rjmp end


test_part_d:
	ldi r21, 'E'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'M'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'H'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	rjmp end


test_part_e:
	ldi r25, HIGH(WORD02 << 1)
	ldi r24, LOW(WORD02 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end






; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

set_leds:

	clr tempMask ; clear registers that we are going to use
	clr r22
	clr r21

	checkL1:
		ldi tempMask, 0b00000001	; check if the bit is set in the input value
		and tempMask, r16
		breq checkL2
		ori r22, 0b10000000			; if the bit is set, set the corresponding bit of the output value
	
	checkL2:
		ldi tempMask, 0b00000010	; same proccess
		and tempMask, r16
		breq checkL3
		ori r22, 0b00100000		
	
	checkL3:
		ldi tempMask, 0b00000100	; same proccess
		and tempMask, r16
		breq checkL4
		ori r22, 0b00001000
	

	checkL4:
		ldi tempMask, 0b00001000	; same proccess
		and tempMask, r16
		breq checkB1
		ori r22, 0b00000010

	checkB1:
		ldi tempMask, 0b00010000	; same proccess
		and tempMask, r16
		breq checkB2
		ori r21, 0b00001000
	
	checkB2:
		ldi tempMask, 0b00100000	; same proccess
		and tempMask, r16
		breq output
		ori r21, 0b00000010


	output:
	
		sts PORTL, r22		; store values in ports
		out PORTB, r21

		ret


slow_leds:
	mov r16, r17		; move the input value to r16, so that the leds can be set correctly
	rcall set_leds		; set leds before creating delay
	rcall delay_long
	clr r16				; clear r16 so that the lights are turned off at the end
	rcall set_leds
	ret


fast_leds:
		mov r16, r17	; move the input value to r16, so that the leds can be set correctly
		rcall set_leds	; set leds before creating delay
		rcall delay_short
		clr r16			; clear r16 so that the lights are turned off at the end
		rcall set_leds
		ret


leds_with_speed:

	clr r21		; clear everything we are going to use

	push ZL		; push everything we are going to use
	push ZH
	push r21

	
	in ZH, SPH ; make zh a stack pointer to high byte
	in ZL, SPL ; make zl a stack pointer to low byte

	ldd r21, Z+7	; load value from the stack to r21
	mov r17, r21	; for slow/fast leds we need to copy original value to r17


	ldi tempMask, 0b11000000 
	and tempMask, r17	; and tempMask and r16 value and store it in r16
	breq fast			; if the result is zero, than 2 top-most bits are not set and we branch to fast_leds
	rjmp slow			; else jump to slow_leds (since the only other value tested will have 2 top-most bits set)

fast:
	rcall fast_leds
	rjmp clear_stack

slow:
	rcall slow_leds
	rjmp clear_stack

clear_stack:
	pop r21	
	pop ZH
	pop ZL

	ret



; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.

encode_letter:

	clr r17  ; clear everything we are going to use
	clr r22
	clr r18

	push ZL		; push everything we are going to use
	push ZH
	push r22
	push r18
	push r17

	in ZH, SPH ; make zh a stack pointer to high byte
	in ZL, SPL ; make zl a stack pointer to low byte

	ldd r22, Z+9 ; load original value from the stack to r22

	ldi tempMask, 0b01000000

	ldi ZH, high(PATTERNS<<1) ; access first letter
	ldi ZL, low(PATTERNS<<1)
	cp ZL, r22				; check if it is the first letter
	breq define_pattern		; if true branch to define the lights pattern
	
search:
	lpm r18, Z+			; start looping through PATTERNS
	cp r22, r18			; check if it is equal to our value
	breq define_pattern	; if true branch to define the lights pattern
	cpi r18, 0x2D		; 2D = '-', so if we get to dash that we have invalid character
	breq clear_stack2	; and we branch to clear the stack
	rjmp search			; else continue looping


define_pattern:
	lpm r18, Z+			; start looping through light pattern
	lsr tempMask		; shift tempMask
	breq define_delay	; if tempMask = 0, then we terminate the loop
	cpi r18, 0x6F		; check if it is "o"
	brne define_pattern ; if false, keep looping
	rcall set_bit		; else set corresponding bit
	rjmp define_pattern	; and continue looping

set_bit:
	add r17, tempMask
	ret

define_delay:
	cpi r18, 1			; check if pattern has delay = 1
	breq slow_delay		; if true it is a slow delay
	rjmp fast_delay		; else fast

slow_delay:
	ldi r25, 0b11000000 ; set first two bits
	add r25, r17		; add everything to get a final value
	rjmp clear_stack2

fast_delay:
	clr r25			; don't need to set anything
	add r25, r17	; add everything to get a final value

clear_stack2:
	pop r17
	pop r18
	pop r22
	pop ZH
	pop ZL

	ret

display_message:
	
	push ZH ; push everything we are going to use
	push ZL
	push r28
	push r25
	push r24

	mov ZL, r24 ; store word adress in z
	mov ZH, r25

wordLoop:

	lpm r28, Z+		; loop through each character
	cpi r28, 0x00	; if we reached zero = terminate
	breq end_of_word

	mov r21, r28
	push r21
	rcall encode_letter ; push r21 and call encode letter
	pop r21

	push r25
	rcall leds_with_speed ; push r25 and call leds with speed
	pop r25

	rcall delay_long	; call delay so we can see when same letters are in a row

	rjmp wordLoop	; else continue looping


end_of_word:
	pop r24
	pop r25
	pop r28
	pop ZL
	pop ZH
	
	ret


; ****************************************************
; **** END OF SECOND "STUDENT CODE" SECTION **********
; ****************************************************




; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop

	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code. Really this is
; nothing other than a specially-tuned triply-nested
; loop. It provides the delay it does by virtue of
; running on a mega2560 processor.
;


delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08

delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables
;.cseg
;.org 0x600

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 1
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "W", "oo....", 2
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "HELLOWORLD", 0, 0
WORD01: .db "THE", 0
WORD02: .db "QUICK", 0
WORD03: .db "BROWN", 0
WORD04: .db "FOX", 0
WORD05: .db "JUMPED", 0, 0
WORD06: .db "OVER", 0, 0
WORD07: .db "THE", 0
WORD08: .db "LAZY", 0, 0
WORD09: .db "DOG", 0

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

