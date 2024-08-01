;
; a3part-D.asm
;
; Part D of assignment #3
;
;
; Student name: Luke Thomas		
; Student ID: V00976989
; Date of completed work: March 26th 2024
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

.def DH=r25  ;data high and data low storage
.def DL=r24
.def BH = r1 ;boundary high and boundary low
.def BL = r0
.def BBH = r3 ;secondary boundary high and boundary low
.def BBL = r2

ldi r16, low(RAMEND)
mov BL, r21 
ldi r16, high(RAMEND)
mov BH, r21 

.equ ADCSRA_BTN=0x7A
.equ ADCSRB_BTN=0x7B
.equ ADMUX_BTN=0x7C
.equ ADCL_BTN=0x78
.equ ADCH_BTN=0x79

clear_index: ;clears index and sets all top characters to ' ' 
	ldi r18, 0
	ldi XL, LOW(CURRENT_CHARSET_INDEX)	
	ldi XH, HIGH(CURRENT_CHARSET_INDEX)
	sts CURRENT_CHARSET_INDEX, r18
	sts CURRENT_CHAR_INDEX, r18
	ldi r19, ' '
	clr r24
	ldi YL, LOW(TOP_LINE_CONTENT)
	ldi YH, HIGH(TOP_LINE_CONTENT)
	sts TOP_LINE_CONTENT, r19
	ldi r25, 16

clear_loop:	
	st X+, r18
	st Y+, r19
	dec r25
	brne clear_loop
	
access_letter:
	ldi ZL, LOW(AVAILABLE_CHARSET << 1)	;first letter
	ldi ZH, HIGH(AVAILABLE_CHARSET << 1)

get_length:
	lpm r16, Z+
	cpi r16, 0x00
	breq store_length
	inc r24
	rjmp get_length

store_length:
	sts LENGTH, r24

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

start: ;polling
	in r16, TIFR3
	sbrs r16, OCF3A
	rjmp start

	ldi r16, (1 << OCF3A)
	out TIFR3, r16
	rjmp timer3

stop:
	rjmp stop

timer1:		;partA
	push r16
	lds r16, SREG
	push r16
	push DL
	push DH
	push BL
	push BH
	push r23
	push BBL
	push BBH
	push r17
	lds	r16, ADCSRA_BTN	
	ori r16, 0x40
	sts	ADCSRA_BTN, r16

wait:	
	lds r16, ADCSRA_BTN
	andi r16, 0x40
	brne wait
	;load data to r24:r25
	lds DL, ADCL_BTN
	lds DH, ADCH_BTN
	ldi r16, low(BUTTON_SELECT_ADC)
	mov BL, r16
	ldi r16, high(BUTTON_SELECT_ADC)
	mov BH, r16	
	clr r23
	cp DL, BL
	cpc DH, BH
	brsh btn_pressed	
	ldi r23,1

btn_pressed:	
		sts BUTTON_IS_PRESSED, r23


checkR:		 ;check if R is pressed
		ldi r16, low(BUTTON_RIGHT_ADC)
		mov BBL, r16
		ldi r16, high(BUTTON_RIGHT_ADC)
		mov BBH, r16
		cp DL, BBL
		cpc DH, BBH
		brlo lcd_right

checkU:		;check if U is pressed
		ldi r16, low(BUTTON_UP_ADC)
		mov BBL, r16
		ldi r16, high(BUTTON_UP_ADC)
		mov BBH, r16
		cp DL, BBL
		cpc DH, BBH
		brlo lcd_up

checkD:		;check if D is pressed
		ldi r16, low(BUTTON_DOWN_ADC)
		mov BBL, r16
		ldi r16, high(BUTTON_DOWN_ADC)
		mov BBH, r16
		cp DL, BBL
		cpc DH, BBH
		brlo lcd_down

checkL:		;check if L is pressed
		ldi r16, low(BUTTON_LEFT_ADC)
		mov BBL, r16
		ldi r16, high(BUTTON_LEFT_ADC)
		mov BBH, r16
		cp DL, BBL
		cpc DH, BBH
		brlo lcd_left

lcd_right:;loads R to last button pressed
		ldi r17, 'R'
		sts LAST_BUTTON_PRESSED, r17
		rjmp epilogueT1

lcd_up:;loads U to last button pressed
		ldi r17, 'U'
		sts LAST_BUTTON_PRESSED, r17
		rjmp epilogueT1

lcd_down:;loads D to last button pressed
		ldi r17, 'D'
		sts LAST_BUTTON_PRESSED, r17
		rjmp epilogueT1

lcd_left:;loads L to last button pressed
		ldi r17, 'L'
		sts LAST_BUTTON_PRESSED, r17
		rjmp epilogueT1
;T1 epilogue
epilogueT1:
	pop r17
	pop BBH
	pop BBL
	pop r23
	pop BH
	pop BL
	pop DH
	pop DL
	pop r16
	sts SREG, r16
	pop r16

	reti

timer3:
	push r16
	push r17
	push r18
	push r19
	push r20
	push r23
	push YH
	push YL

	ldi r16, 1
	ldi r17, 15
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	clr r18
	lds r18, BUTTON_IS_PRESSED
	cpi r18, 0x01
	breq star_on

dash_on:
	ldi r18, '-'
	push r18
	rcall lcd_putchar
	pop r18
	rjmp epilogueT3

star_on:
	ldi r18, '*'
	push r18
	rcall lcd_putchar
	pop r18


direction_on:
	ldi r16, 1
	ldi r17, 0
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	clr r19
	lds r19, LAST_BUTTON_PRESSED
	ldi r20, ' '

	cpi r19, 'L'
	breq left_on

	cpi r19, 'D'
	breq down_on

	cpi r19, 'U'
	breq up_on

	cpi r19, 'R'
	breq right_on

left_on:
	push r19	;L
	rcall lcd_putchar
	pop r19
	push r20	;D
	rcall lcd_putchar
	pop r20
	push r20	;U
	rcall lcd_putchar
	pop r20
	push r20	;R
	rcall lcd_putchar
	pop r20
	rjmp hexdigit_on	

down_on:
	push r20	;L
	rcall lcd_putchar
	pop r20
	push r19	;D
	rcall lcd_putchar
	pop r19
	push r20	;U
	rcall lcd_putchar
	pop r20
	push r20	;R
	rcall lcd_putchar
	pop r20
	rjmp hexdigit_on	

up_on:
	push r20	;L
	rcall lcd_putchar
	pop r20
	push r20	;D
	rcall lcd_putchar
	pop r20
	push r19	;U
	rcall lcd_putchar
	pop r19
	push r20	;R
	rcall lcd_putchar
	pop r20
	rjmp hexdigit_on	

right_on:
	push r20	;L
	rcall lcd_putchar
	pop r20
	push r20	;D
	rcall lcd_putchar
	pop r20
	push r20	;U
	rcall lcd_putchar
	pop r20
	push r19	;R
	rcall lcd_putchar
	pop r19
	rjmp hexdigit_on	


;partC
hexdigit_on: ;inputs hexdigit into LCD screen at appropriate point
	ldi r16, 0
	lds r17, CURRENT_CHAR_INDEX	;partD: load CURRENT_CHAR_INDEX instead of 0
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	clr r23
	ldi YL, LOW(TOP_LINE_CONTENT)
	ldi YH, HIGH(TOP_LINE_CONTENT)

	ld r23, Y

	push r23
	rcall lcd_putchar
	pop r23

	
epilogueT3:
	pop YL
	pop YH
	pop r23
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	rjmp start

; timer3:
;
; Note: There is no "timer3" interrupt handler as you must use
; timer3 in a polling style (i.e. it is used to drive the refreshing
; of the LCD display, but LCD functions cannot be called/used from
; within an interrupt handler).


timer4:
	push r27
	push r22
	push ZL
	push ZH
	lds r27, SREG
	push r27
	push r23
	push ZL
	push ZH
	push r29
	push r28
	push r30

	lds r22, BUTTON_IS_PRESSED	;check if the button is pressed
	cpi r22, 0
	breq epilogueT4

	lds r22, LAST_BUTTON_PRESSED
	
	cpi r22, 'U'
	breq go_up

	cpi r22, 'D'
	breq go_down

	cpi r22, 'R'	
	breq go_right

	cpi r22, 'L'
	breq go_left

go_down:
	lds r27, CURRENT_CHARSET_INDEX
	dec r27
	rjmp check_boundary

go_up:
	lds r27, CURRENT_CHARSET_INDEX
	
	inc r27
	rjmp check_boundary

go_right:	
	lds r27, CURRENT_CHAR_INDEX
	inc r27		;increase the index
	call check_boundary2		
	sts CURRENT_CHAR_INDEX, r27
	
	rjmp clear_charset

go_left:	
	lds r27, CURRENT_CHAR_INDEX
	dec r27		;decrease the index
	call check_boundary2
	sts CURRENT_CHAR_INDEX, r27
	
	rjmp clear_charset

check_boundary:
	lds r23, LENGTH		;make sure the index to stay in the boundary of the length
	cp r27, r23
	brsh epilogueT4
	sts CURRENT_CHARSET_INDEX, r27
	rjmp index_to_charset
check_boundary2:
	lds r23, LENGTH		;make sure the index to stay in the boundary of the LCD
	cp r27, r23			;this part doesn't actually really work because when it reaches the end it resets the top line to all spaces
	brsh epilogueT4		;other than that it the rest works fine.
	sts CURRENT_CHAR_INDEX, r27
	ret
index_to_charset:
	ldi ZL, LOW(AVAILABLE_CHARSET << 1)	;address of first letter
	ldi ZH, HIGH(AVAILABLE_CHARSET << 1)
	lds r28, CURRENT_CHARSET_INDEX	;load index to r28
	clr r29
	add ZL, r28
	adc ZH, r29		;add with carry
	lpm r30, Z
	sts TOP_LINE_CONTENT, r30
	rjmp epilogueT4

epilogueT4:
	pop r30
	pop r28
	pop r29
	pop ZH
	pop ZL
	pop r23
	pop r27
	sts SREG, r27
	pop ZH
	pop ZL
	pop r22
	pop r27

	reti
	rjmp next

clear_charset:	;added here because the branch was too long to epilogueT4
	ldi r18, 0	; clears charset and makes sure that when you change columns you don't copy the same number from the last one.
	ldi ZL, LOW(CURRENT_CHARSET_INDEX)	
	ldi ZH, HIGH(CURRENT_CHARSET_INDEX)
	sts CURRENT_CHARSET_INDEX, r18
	sts CURRENT_CHARSET_INDEX, r18

	ldi r19, ' '
	clr r24
	ldi YL, LOW(TOP_LINE_CONTENT)	;make all byte of TOP_LINE_CONTENT space
	ldi YH, HIGH(TOP_LINE_CONTENT)
	sts TOP_LINE_CONTENT, r19
	ldi r25, 16

clear_loop2:
	st X+, r18
	st Y+, r19;
	dec r25
	brne clear_loop2
	rjmp epilogueT4
next:

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

TOP_LINE_CONTENT: .byte 16			; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHARSET_INDEX: .byte 16		; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHAR_INDEX: .byte 1			; ; updated by timer4 interrupt, used by LCD update loop


; =============================================
; ======= END OF "DO NOT TOUCH" SECTION =======
; =============================================


; ***************************************************
; **** BEGINNING OF THIRD "STUDENT CODE" SECTION ****
; ***************************************************

.dseg

LENGTH: .byte 1		;length of AVAILABLE_CHARSET

; If you should need additional memory for storage of state,
; then place it within the section. However, the items here
; must not be simply a way to replace or ignore the memory
; locations provided up above.


; ***************************************************
; ******* END OF THIRD "STUDENT CODE" SECTION *******
; ***************************************************