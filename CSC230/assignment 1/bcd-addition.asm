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

	;86 + 79 = 65, carry = 1
	 ldi r16, 0x86
	 ldi r17, 0x79

	; 35 + 49 = 84, carry = 0
	 ;ldi r16, 0x35
	; ldi r17, 0x49

	; 32 + 41 = 73, carry = 0
;ldi r16, 32
;ldi r17, 41

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
_start:
	ldi r22, 0
	ldi r18, 0b00001111 ; mask for lower nybble
	mov r19, r16
	and r19, r18	;finds the value of the lower nybbles
	mov r20, r17	;
	and r20, r18	;
	add r20, r19
	cpi r20, 10		;compares r20 with 10, if lower than there is no decimal carry flag, eg. 3+4 = 7 so no carry flag, but 5+6 = 11 so there is a 1 carry flag
	brlo deci
	inc r22		;carry flag for decimal only if r20 is greater than 10
	subi r20, 10	;first digit result 
	rjmp deci

deci:
	ldi r24, 0
	ldi r18, 0b11110000 ;mask for upper nybble
	mov r19, r16
	and r19, r18
	mov r21, r17
	and r21, r18
	swap r19		;swap to add 
	swap r21
	add r21, r19
	add r21, r22
	cpi r21, 10
	brlo no_carry	;if no carry flag then move to inputting into final position
	inc r24			;increment if carry flag is drawn
	subi r21, 10
	swap r21
	mov r25, r21		;input into destination if there is carry flag
	add r25, r20
	rjmp bcd_addition_end

no_carry:
	swap r21		;input into destination if no carry flag
	mov r25, r21
	add r25, r20


	





; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
bcd_addition_end:
	rjmp bcd_addition_end



; ==== END OF "DO NOT TOUCH" SECTION ==========
