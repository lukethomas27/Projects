; reset-rightmost.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (b). In this and other
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
; Your task: You are to take the bit sequence stored in R16,
; and to reset the rightmost contiguous sequence of set
; by storing this new value in R25. For example, given
; the bit sequence 0b01011100, resetting the right-most
; contigous sequence of set bits will produce 0b01000000.
; As another example, given the bit sequence 0b10110110,
; the result will be 0b10110000.
;
; Your solution must work, of course, for bit sequences other
; than those provided in the example. (How does your
; algorithm handle a value with no set bits? with all set bits?)

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========

	;ldi R16, 0b01011100
	ldi R16, 0b10110110


	; THE RESULT **MUST** END UP IN R25

; **** BEGINNING OF "STUDENT CODE" SECTION **** 

_start:
    

    mov r17, r16         ; Copy the value of R16 to R17
    ldi r18, 1           ; Initialize mask to check each bit
    
check_set_bit_first:
	mov r16, r17		;copy the byte back to R16
	and r16, r18		;checks if r16 contains the value in R18 (the bit in that position)
	tst r16				;part of above
	breq check_next_bit	;sends to next bit ie shifts the bit in R18 over to the left
	rjmp clear_bit


clear_bit:
	eor r17, r18			;clears all bits until a 0 bit is found then stores value in r25
	mov r16, r17			;
	lsl r18
	and r16, r18
	tst r16
	breq store_result
	rjmp clear_bit

check_next_bit:
    lsl r18              ; Shift the mask to the left
    rjmp check_set_bit_first   ; Check the next bit

store_result:
    mov r25, r17         ; Store the modified value in R25

    



; **** END OF "STUDENT CODE" SECTION ********** 



; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
reset_rightmost_stop:
    rjmp reset_rightmost_stop


; ==== END OF "DO NOT TOUCH" SECTION ==========
