; bcd-addition.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (c). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: Two packed-BCD numbers are provided in R16
; and R17. You are to add the two numbers together, such
; the the rightmost two BCD "digits" are stored in R25
; while the carry value (0 or 1) is stored R24.
;
; For example, we know that 94 + 9 equals 103. If
; the digits are encoded as BCD, we would have
;   *  0x94 in R16
;   *  0x09 in R17
; with the result of the addition being:
;   * 0x03 in R25
;   * 0x01 in R24
;
; Similarly, we know than 35 + 49 equals 84. If 
; the digits are encoded as BCD, we would have
;   * 0x35 in R16
;   * 0x49 in R17
; with the result of the addition being:
;   * 0x84 in R25
;   * 0x00 in R24
;

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).



    .cseg
    .org 0

	; Some test cases below for you to try. And as usual
	; your solution is expected to work with values other
	; than those provided here.
	;
	; Your code will always be tested with legal BCD
	; values in r16 and r17 (i.e. no need for error checking).

	; 94 + 9 = 03, carry = 1
	; ldi r16, 0x94
	; ldi r17, 0x09

	; 86 + 79 = 65, carry = 1
	; ldi r16, 0x86
	; ldi r17, 0x79

	; 35 + 49 = 84, carry = 0
	; ldi r16, 0x35
	; ldi r17, 0x49

	; 32 + 41 = 73, carry = 0
	;ldi r16, 0x32
	;ldi r17, 0x41

	;ldi r16, 0x41
	;ldi r17, 0x32

	ldi r16, 0x86
	ldi r17, 0x79
	
	ldi r23, 0b00000110 
	ldi r19, 0b00001010
	ldi r20, 0b10010000
	ldi r21, 0b00001001
	ldi r22, 0b01100000
	.def lowSix = r23
	.def ten= r19
	.def highNine = r20
	.def lowNine = r21
	.def highSix = r22

	
; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 



bcd_addition:
		add r16, r17	; add values of r16 and r17
		lsr r16
		lsr r16
		lsr r16
		lsr r16
		mov r17, r16 ; store high nybble in r17

		andi r16, 0x0F
		mov r18, r16 ; store low nybble in r18

		brcs fix		; if the carry flag was set the result is incorrect so we branch to carry

						;if therre is no carry during addition than than we need to check whether the sum is < 10 
		cp r16, ten		; if r16 < 10 then carry = 1
		brcs result		; then the result is correct 

						; if it is none of the cases then sum > 9 and c = 0,so we 
		rjmp fix


result:
		mov r25, r16			; move the result to r25
		rjmp bcd_addition_end	; done


fix:
		ldi r26, low(x)
		cp lowNine, r26		; if 9 < low bytes of r16 
		brcs addlow
		ldi r26, high(r16)	; we can reuse r26
		cp highNine, r26	; if 9 < high bytes of r16 
		brcs addHigh
		rjmp result

addlow:
		add r16, lowSix		; r16 + 0b00000110
		brcs finalCarry
		rjmp fix

addHigh:
		add r16, lowSix		; r16 + 0b00000110
		brcs finalCarry 
		rjmp result
	
finalCarry:
		ldi r24, 1
		rjmp fix 

; ////////////////////////////////SECOND TRY////////////////////////////////////////////////

bcd_addition:
		add r16, r17	; add values of r16 and r17
		ldi r18, low(r16)
		brcs fix		; if the carry flag was set the result is incorrect so we branch to carry

						;if therre is no carry during addition than than we need to check whether the sum is < 10 
		cp r16, ten		; if r16 < 10 then carry = 1
		brcs result		; then the result is correct 

						; if it is none of the cases then sum > 9 and c = 0,so we 
		rjmp fix


result:
		mov r25, r16			; move the result to r25
		rjmp bcd_addition_end	; done


fix:
		ldi r26, low(r16)
		cp lowNine, r26		; if 9 < low bytes of r16 
		brcs addlow
		ldi r26, high(r16)	; we can reuse r26
		cp highNine, r26	; if 9 < high bytes of r16 
		brcs addHigh
		rjmp result

addlow:
		add r16, lowSix		; r16 + 0b00000110
		brcs finalCarry
		rjmp fix

addHigh:
		add r16, lowSix		; r16 + 0b00000110
		brcs finalCarry 
		rjmp result
	
finalCarry:
		ldi r24, 1
		rjmp fix 





; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
bcd_addition_end:
	rjmp bcd_addition_end



; ==== END OF "DO NOT TOUCH" SECTION ==========
