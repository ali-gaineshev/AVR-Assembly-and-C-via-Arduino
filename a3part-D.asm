;
; a3part-A.asm
;
; Part A of assignment #3
;
;
; Student name:
; Student ID:
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

#define BUTTON_RIGHT_ADC  0x055
#define BUTTON_UP_ADC     0x0d5  ; was 0x0c3
#define BUTTON_DOWN_ADC   0x18c  ; was 0x17c
#define BUTTON_LEFT_ADC   0x23c
#define BUTTON_SELECT_ADC 0x352

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
	/*STACK*/
	ldi r16, low(RAMEND) //stack
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

	.def DATAH=r25  ;DATAH:DATAL  store 10 bits data from ADC
	.def DATAL=r24
	.def BOUNDARY_H=r1  ;hold high byte value of the threshold for button
	.def BOUNDARY_L=r0 

	.def but_H = r2 ; for last button is pressed
	.def but_L = r3

	.equ ADCL_BTN=0x78
	.equ ADCH_BTN=0x79
	
	/*SET EVERYTHIN IN THE MEMORRY TO DEFAULT*/
	ldi r16,0
	sts CURRENT_CHAR_INDEX, r16//start at column 0

	sts LAST_BUTTON_PRESSED,r16
	ldi r16,'-'
	sts BUTTON_IS_PRESSED,r16

	/*CHARSET default all TO 0*/
	ldi r17,0
	ldi r31, HIGH(CURRENT_CHARSET_INDEX << 1)
	ldi r30, LOW(CURRENT_CHARSET_INDEX << 1)
	ldi r16,0
	set_charset:
	st Z+,R16
	inc r17
	cpi r17,16
	brne set_charset

	/*TOP LINE ALL TO BLANK by default!*/
	ldi r17,0
	ldi r31, HIGH(TOP_LINE_CONTENT << 1)
	ldi r30, LOW(TOP_LINE_CONTENT << 1)
	ldi r16,' '
	print_top:
	st Z+,R16
	inc r17
	cpi r17,16
	brne print_top

	leave:
	clr r16
	clr r17
	clr r31
	clr r30
	rcall lcd_init
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


start:
	rjmp timer3



stop:
	rjmp stop


timer1:
	push r0//BOUNDARY
	push r1//BOUNDARY
	push r2//BUTTON BOUNDARY
	push r3//BUTTON BOUDARY
	push r24//DATAh
	push r25//DATAL
	push r18//SREG
	in r18, SREG
	push r23//BUTTON_IS_PRESSED VALUE, either 1 or 0
	push r16// multi purpose register
	push r22//LAST_BUTTON_PRESSED VALUE, from 0 to 4 check below for specific value


check_button:
	; start a2d
	lds	r16, ADCSRA

	ori r16, 0x40 ; 0x40 = 0b01000000
	sts	ADCSRA, r16

wait:	//ADC CODE
		lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		ldi r16, low(BUTTON_SELECT_ADC);
		mov BOUNDARY_L, r16
		ldi r16, high(BUTTON_SELECT_ADC)
		mov BOUNDARY_H, r16

		ldi r23,'-'
		;clr r22
		;sts BUTTON_IS_PRESSED,r23
		LDS R22,LAST_BUTTON_PRESSED
		; read the value, use XH:XL to store the 10-bit result
		lds DATAL, ADCL_BTN
		lds DATAH, ADCH_BTN
		//CHECK IF BUTTON IS PRESSED
		cp DATAL, BOUNDARY_L
		cpc DATAH, BOUNDARY_H
		brsh skip//BUTTON IS NOT PRESSED SO WE ARE DONE
		ldi r23,'*'
		;sts BUTTON_IS_PRESSED,r23
what_button://what button is pressed???
		;0 no button pressed/select
		;1 right
		;2 up
		;3 down
		;4 left
		;LAST_BUTTON_PRESSED WILL HOLD THIS FINAL VALUE
		/*RIGHT*/
		ldi r22, 1
		ldi r16, low(BUTTON_RIGHT_ADC);
		mov but_L, r16
		ldi r16, high(BUTTON_RIGHT_ADC)
		mov but_H, r16

		cp DATAL, but_L
		cpc DATAH, but_H
		brlo skip

		/*UP*/

		ldi r22, 2

		ldi r16, low(BUTTON_UP_ADC);
		mov but_L, r16
		ldi r16, high(BUTTON_UP_ADC)
		mov but_H, r16
		
		cp DATAL, but_L
		cpc DATAH, but_H
		brlo skip

		/*DOWN*/

		ldi r22, 3

		ldi r16, low(BUTTON_DOWN_ADC);
		mov but_L, r16
		ldi r16, high(BUTTON_DOWN_ADC)
		mov but_H, r16

		cp DATAL, but_L
		cpc DATAH, but_H
		brlo skip

		/*LEFT*/
		ldi r22, 4

		ldi r16, low(BUTTON_LEFT_ADC);
		mov but_L, r16
		ldi r16, high(BUTTON_LEFT_ADC)
		mov but_H, r16

		cp DATAL, but_L
		cpc DATAH, but_H
		brlo skip

		/*NOT PRESSED or SELECT*/
		ldi r22,0

skip://ALL DONE HERE, TIME TO LEAVE
	sts LAST_BUTTON_PRESSED, r22
	sts BUTTON_IS_PRESSED,r23
	pop	r22
	pop r16
	pop r23
	out SREG,r18	
	pop r18
	pop r25
	pop r24
	pop r3
	pop r2
	pop r1
	pop r0
	reti;why are there so many registers??

timer3:
	in r5, TIFR3
	sbrs r5, OCF3A
	rjmp timer3//until reached top value

	/*BOTTOM RIGHT LDS*/
	ldi r16, 1;row
	ldi r17, 15 ;column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	/*DISPLAY - or **/
	lds r16,BUTTON_IS_PRESSED
	push r16
	rcall lcd_putchar
	pop r16

	/*BOTTOM LEFT LDS*/
	ldi r16, 1;row
	ldi r17, 0 ;column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16
	rcall but_pressed

	;rjmp timer3

	/*TOP LINE CONTENT*/
	ldi r16, 0;row
	ldi r17, 0 ;column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16
	rcall top_display

	rjmp timer3
top_display:
	push r31
	push r30
	push r16
	push r19

	ldi r19,0
	ldi r31, HIGH(TOP_LINE_CONTENT<<1)
	ldi r30, LOW(TOP_LINE_CONTENT<<1)
	display_all_top:
		ld r16, Z+//iterate through all of them
		push r16
		rcall lcd_putchar
		pop r16

		inc r19//counter
		cpi r19,16
		brne display_all_top
	
	pop r19
	pop r16
	pop r30
	pop r31
	ret

/*THIS CODE UPTADES BOTTOM LEFT DISPLAY WITH LETTER L,D,U,R according to a button pressed*/
but_pressed:
	push r22
	push r23
	push r16
	lds r22, LAST_BUTTON_PRESSED//number 0-4

	/*LEFT*/
	ldi r16, 'L'
	ldi r23, 4
	cpse r22, r23
	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	/*DOWN*/
	ldi r16, 'D'
	ldi r23, 3
	cpse r22, r23
	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	/*UP*/
	ldi r16, 'U'
	ldi r23, 2
	cpse r22, r23
	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	/*RIGHT*/
	ldi r16, 'R'
	ldi r23, 1
	cpse r22, r23
	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16


	pop r16
	pop r23
	pop r22
	ret

timer4:
	push r30
	push r31
	push Yh
	push yl
	push r16;multi purpose regiset
	push r17
	in r17,SREG
	push r18
	push r19
	push r20;length of sequence
	push r21;value of charset
	push r22;multi purpose regiset
	push r23;inDEX OF "ARRAY" + multipurpose register
	push r24

	clr r24
	clr r23
	clr r20
	ldi r31, HIGH(AVAILABLE_CHARSET << 1)
	ldi r30, LOW(AVAILABLE_CHARSET << 1)
	LPM r16, Z
	/*get tHE LENGTH OF THE SEQUENCE*/
	loop:
		inc r20;counter
		LPM r16, Z+
		cpi r16,0
		brne loop
		dec r20; final length

	/*PUT THE Y POINTER OF CHARSET DEPEDNING ON CHAR_INDEX*/
	lds r23, CURRENT_CHAR_INDEX 
	ldi r29, HIGH(CURRENT_CHARSET_INDEX<< 1)
	ldi r28, LOW(CURRENT_CHARSET_INDEX<< 1)
	ld r21, Y
	ldi r16, 0
	find_charset_index:
		cp r23, r16
		breq is_button_even_pressed;?
		inc r16
		ld r21, Y+
		ld r21, Y// value of char 
		rjmp find_charset_index

	is_button_even_pressed:
	ldi r16,0
	lds r23,BUTTON_IS_PRESSED
	cpi r23,'-'
	breq up_down_done//not pressed

	lds r19,LAST_BUTTON_PRESSED;from 1 to 4

	cpi r19,1
	breq right_press

	cpi r19,4
	breq left_press

	cpi r19,2
	breq up_pressed

	cpi r19,3
	breq down_pressed

	rjmp up_down_done;just in case
right_press:
	//increment the index if didn't hit boundary column 15, then leave
	ldi r24,15
	lds r23, CURRENT_CHAR_INDEX 
	cpse r23, r24
	inc r23
	sts CURRENT_CHAR_INDEX, r23//store back
	rjmp up_down_done
left_press:
	//decrement the index if didn't hit boundary column 0, then leave
	ldi r24,0
	lds r23, CURRENT_CHAR_INDEX 
	cpse r23, r24
	dec r23
	sts CURRENT_CHAR_INDEX, r23//store back
	rjmp up_down_done
down_pressed:
	//this part checks if down was pressed first!If so, then do nothing
	cpi r21,0
	breq up_down_done
	//CHECK if i hit the boundary
	ldi r20,1
	cpse r21, r20
	dec r21
	st Y, r21//store back
	rjmp interpret
up_pressed:
	//CHECK if i hit the boundary
	cpse r21, r20//r20 the length of the sequence
	inc r21
	st Y, r21//store back
	rjmp interpret
interpret:
	//CHANGE the number in charset into appropriate letter
	ldi r31, HIGH(AVAILABLE_CHARSET << 1)
	ldi r30, LOW(AVAILABLE_CHARSET << 1)
	ldi r20,0;cur counter
	ld r21, Y//Y is the current_charset_index
next_char_up:
	cp r21,r20
	breq display//found the char, now display,character is in r16
	inc r20
	lpm r16,Z+//iterate between character
	rjmp next_char_up

display:
	ldi r31, HIGH(TOP_LINE_CONTENT << 1)
	ldi r30, LOW(TOP_LINE_CONTENT << 1)
	lds r23, CURRENT_CHAR_INDEX 
	ldi r20,0
	find_the_top:
		cp r23, r20
		breq go
		ld r18,Z+
		ld r18,Z
		inc r20
		RJMP find_the_top
	go:
	st Z,R16;store the final character in Z WHICH POINTS TO TOP LINE BYTE
up_down_done://DONE, POP AND LEAVE
	pop r24
	pop r23
	pop r22
	pop r21
	pop r20
	pop r19
	pop r18
	out SREG,r17
	pop r17
	pop r16
	POP YL
	POP YH
	pop r31
	pop r30
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
AVAILABLE_CHARSET: .db "IHATECSC230", 0


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

; If you should need additional memory for storage of state,
; then place it within the section. However, the items here
; must not be simply a way to replace or ignore the memory
; locations provided up above.


; ***************************************************
; ******* END OF THIRD "STUDENT CODE" SECTION *******
; ***************************************************
