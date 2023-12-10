; main.asm for edit-distance assignment
;
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (a). In this and other
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
;
; Your task: To compute the edit distance between two byte values,
; one in R16, the other in R17. If the first byte is:
;    0b10101111
; and the second byte is:
;    0b10011010
; then the edit distance -- that is, the number of corresponding
; bits whose values are not equal -- would be 4 (i.e., here bits 5, 4,
; 2 and 0 are different, where bit 0 is the least-significant bit).
; 
; Your solution must, of course, work for other values than those
; provided in the example above.
;
; In your code, store the computed edit distance value in R25.
;
; Your solution is free to modify the original values in R16
; and R17.
;
; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========


	;ldi r16, 0xa7
	;ldi r17, 0x9a
	;so far gave 5

	ldi r16, 0b10011010
	ldi r17, 0b10101111
	;should be 4

 
; **** BEGINNING OF "STUDENT CODE" SECTION **** 

	; Your solution in here.

	eor r16, r17 ; check for different bits 
	ldi r18, 0b00000001 ; load 0b00000001 to r18
	.def compare_to = r18 ; label r18 since this is the value that we will compare to

comparison:
	mov r19, r16 ; store the original result of eor in separate register
	and r19, compare_to ; AND original result and comapre_to, storing this value in r19
	brne distance ; if the result of comparison is not zero, than there is a different bit and we need to increase our distance

continue:
	lsl compare_to ;shift compare_to to the left, so we can check for the next bit
	breq edit_distance_stop ; if compare_to is 0, then we reached the end of the loop
	rjmp comparison ; if it is not zero continue comparing 

distance:
	inc r25 ; increment r25 because this is our distance
	rjmp continue ; 

	; THE RESULT **MUST** END UP IN R25




; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
edit_distance_stop:
    rjmp edit_distance_stop



; ==== END OF "DO NOT TOUCH" SECTION ==========
