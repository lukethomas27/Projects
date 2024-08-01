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
	.equ S_DDRB=0x24
	.equ S_PORTB=0x25
	.equ S_DDRL=0x10A
	.equ S_PORTL=0x10B

	.def temp1=r18
	.def temp2=r19
	.def temp3=r20

	ldi temp1, 0xFF
	sts DDRL, temp1
	out DDRB, temp1

	ldi r17, low(RAMEND)
	out SPL, r17
	ldi r17, high(RAMEND)
	out SPH, r17


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

	rjmp test_part_c
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
	ldi r25, HIGH(WORD00 << 1)
	ldi r24, LOW(WORD00 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end






; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

;	pretty self explanatory, basically goes through each bit in r16 to check if it is set, 
;	if it is compute that to the appropriate bit in either r19 or r20 which will then set the PORT_L and PORT_B respectfully.

set_leds:
	ldi r19, 0
	ldi r20, 0
	ldi r18, 0b00000001
	and r18, r16
	cpi r18, 0b00000001
	brne bit2
	ldi r21, 0b10000000
	add r19, r21
	rjmp bit2

	bit2:
		ldi r18, 0b00000010
		and r18, r16
		cpi r18, 0b00000010
		brne bit3
		ldi r21, 0b00100000
		add r19, r21
		rjmp bit3
	bit3:
		ldi r18, 0b00000100
		and r18, r16
		cpi r18, 0b00000100
		brne bit4
		ldi r21, 0b00001000
		add r19, r21
		rjmp bit4
	bit4: 
		ldi r18, 0b00001000
		and r18, r16
		cpi r18, 0b00001000
		brne bit5
		ldi r21, 0b00000010
		add r19, r21
		rjmp bit5
	bit5:
		ldi r18, 0b00010000
		and r18, r16
		cpi r18, 0b00010000
		brne bit6
		ldi r21, 0b00001000
		add r20, r21
		rjmp bit6
	bit6: 
		ldi r18, 0b00100000
		and r18, r16
		cpi r18, 0b00100000
		brne led1
		ldi r21, 0b00000010
		add r20, r21
		rjmp led1
	led1:
		sts S_PORTL, r19
	led2:
		sts S_PORTB, r20
	ret

;copy value from r16 to r17 and then run the leds, slow delay, and then turn them off.
slow_leds:
	mov r16, r17
	rcall set_leds
	rcall delay_long
	ldi r16, 0
	rcall set_leds
	ret
;same as slow_leds but fast delay
fast_leds:
	mov r16, r17
	rcall set_leds
	rcall delay_short
	ldi r16, 0
	rcall set_leds
	ret
;initiates stack then loads the value into temp1 which then copies to r17, and then runs slow or fast leds depending on the set of bit 6 and 7
leds_with_speed:
	push ZH
	push ZL ;set up stack
	push temp1
	push temp2
	in ZH, SPH
	in ZL, SPL
	ldd temp1, Z+8 ;load byte into r16/temp1
	mov r17, temp2
	mov r17, temp1
	ldi r18, 0b11000000
	and r18, r17
	cpi r18, 0b11000000 ; test to see if it has bit 6 and 7 set
	breq slow ;branch to slow led if they are set
	rcall fast_leds ; fast leds if no 
	
	pop temp2
	pop temp1
	pop ZL
	pop ZH; clear stack
	ret

	slow:
		rcall slow_leds
		pop temp2
		pop temp1
		pop ZL
		pop ZH ;clear stack
	ret


; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.

;sets up a stack pointer and searches for the value given in the parameter in PATTERNS, then creates a set bit for leds_with_speed.
encode_letter:
	clr r25
	push YH
	push YL
	in YH, SPH
	in YL, SPL
	ldi temp1, HIGH(PATTERNS<<1)	;load byte 
	ldi temp2, LOW(PATTERNS<<1)		
	mov ZH, temp1
	mov ZL, temp2

	clr temp1
	clr temp2
	ldi temp3, 0b00100000

	encode_loop:
		lpm temp1, Z	;load Z to temp1
		adiw Z, 8
		ldd temp2, Y+6
		cp temp1, temp2		
		brne encode_loop
		sbiw Z, 8
		ldi temp2, 0b00000011
		lpm temp1, Z+		
	encode_f_loop:
		lpm temp1, Z+		;increment Z
		cpi temp1, 0x2e		;compare r18
		breq encode2
		encode1:
			cpi temp3, 0
			breq encode3
			or r25, temp3
			lsr temp3 
			rjmp encode_f_loop
		encode2:
			lsr temp3 
			rjmp encode_f_loop
		encode3:
			cpi temp1, 1
			breq encode4
			rjmp encode_f
		encode4:
			ori r25, 0b11000000
			rjmp encode_f

	encode_f:
	pop YL ;clear stack
	pop YH
	ret

;gathers the word given as parametre and runs encode letter based off of the letter pattern given, then runs leds_with_speed based off of the set byte returned by encode_letter
display_message:
	push r24
	push r25
	push temp1
	mov ZH, r25		;copy r25 and r24 into register
	mov ZL, r24
	display_msg_loop:
		lpm temp1, Z+	;increment Z
		tst temp1
		breq display_msg_fin
		push ZH
		push ZL
		mov r21, temp1
		push r21
		rcall encode_letter ;call encode letter to set bit in right place for execution
		pop r21
		push r25
		rcall leds_with_speed ; execute the appropriate LEDs to light up
		pop r25
		rcall delay_long
		pop ZL
		pop ZH
		rjmp display_msg_loop
	display_msg_fin: 
		pop temp1
		pop r25
		pop r24 ;clear stack

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

