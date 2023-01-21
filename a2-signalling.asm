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

	ldi r16, high(0x21ff)
	out SPH, r16
	ldi r16, low(0x21ff)
	out SPL, r16

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
	ldi r25, HIGH(WORD05 << 1)
	ldi r24, LOW(WORD05 << 1)
	rcall display_message
	rjmp end
end:
    rjmp end






; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

;------------------------------------PART 1----------------------------------
set_leds:
	//CLEARING just in case
	clr r2
	clr r22
	clr r23
	clr r24
	cbi PortB,PINB3
	cbi PortB,PINB1

	mov r2,r16; copy of original r16
	clr r19;result for port B
	ldi r21, 0x00;result fpr port L
	ldi r22, 0x01;masking value
	ldi r23, 0; counter

	ldi r24,0xFF; for ports
	sts DDRL,r24
	out DDRB,r24
	//PORT B STUFF
	pin_b_1:
		ANDI r16,0b00100000
		;cpi r16,0
		breq pin_b_3
		ldi r19,0b00000010
	pin_b_3:
		mov r16,r2
		ANDI r16,0b00010000

		cpi r16,0
		breq loop
		ori r19, 0b00001000
	//PORT L stuff
	loop:
		mov r16,r2
		inc r23
		cpi r23, 5;need to check only 4 bits + 1 extra counting
		breq display

		AND r16, r22 ;either set or unset
		brne conditions; there is 1

		lsl r22
		rjmp loop
	
	conditions:// will set a bit depending on a counter value for port L
		lsl r22
		mov r16,r2

		cpi r23,1
		breq L_b7

		cpi r23,2
		breq L_b5

		cpi r23,3
		breq L_b3

		cpi r23,4
		breq L_b1

		rjmp loop
	L_b7:
		ori r21,0b10000000
		rjmp loop
	L_b5:
		ori r21, 0b00100000
		rjmp loop
	L_b3:
		ori r21, 0b00001000
		rjmp loop
	L_b1:
		ori r21, 0b00000010
		rjmp display
	display://port L and B are done, time to display
		mov r16,r2
		sts PORTL, r21
		out PORTB,	r19
		ret


;------------------------------------PART 2----------------------------------
slow_leds:
	mov r16,r17; copy r17 valut to r16, to use it in set_leds
	rcall set_leds
	rcall delay_long
	;rcall delay_long
	ldi r16,0x00
	rcall set_leds
	ret


fast_leds:
	mov r16,r17
	rcall set_leds
	;rcall delay_long
	rcall delay_short
	ldi r16,0x00
	rcall set_leds
	ret


;------------------------------------PART 3----------------------------------
leds_with_speed:
	clr r0
	push YH
	push YL
	push r0
	in YH,SPH
	in YL,SPL

	ldd r0,Y+7;value on top of the stack
	;mov r24, r0
	pop YL
	pop YL
	pop YH

	mov r16,r0
	mov r17,r0
	ANDI r16,0b11000000;r16 is updated later
	breq do_fast ;z flag is set if r16 is 0x00

	rcall slow_leds
	ret

do_fast:
	rcall fast_leds
	ret
	

; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.

;------------------------------------PART 4----------------------------------
encode_letter:
	clr r24
	clr r25
	clr r19
	clr r18
	clr r21
	ldi r23,0x02; mask for the last value encoded(1 or 2)
	ldi r25,0x00;return value*
	ldi r22,0x00;loop counter
	ldi r20, 0b00100000;mask
	push r18
	in ZH,SPH
	in ZL,SPL;stack pointer

	;ldd r18, Z+5 
	ldd r21, Z+5; get the letter that needs to be displayed

	; get where Z pointer should be
	ldi ZH,HIGH(PATTERNS << 1)
	ldi ZL,LOW(PATTERNS<< 1)

loop_letters:// try to find the letter needed
	lpm r18, Z+
	cp r18,r21;
	breq detail//found letter, if not iterate to the next letter
	lpm r18, Z+ 
	lpm r18, Z+
	lpm r18, Z+
	lpm r18, Z+
	lpm r18, Z+
	lpm r18, Z+
	lpm r18, Z+
	rjmp loop_letters// will keep iterating until the letter is found

detail:
	inc r22
	lpm r18, Z+;iterate through patterns of a letter
	cpi r22, 7; should find 6 values, the last one shows the duration;
	breq change_first_2

	//0x6f means o which means the LED is on
	cpi r18,0x6f//
	breq change_to_one

	lsr r20;masking value left shift
	rjmp detail
change_to_one:
	or r25, r20// update r25, which is the final value
	lsr r20
	rjmp detail; go to the next symbol in pattern of letter

change_first_2:// set the duration.
	cpse r18,r23; skip the next line if the pattern equals to 2
	ori r25, 0b11000000; last pattern equals to 1, then set to long delay

	pop r18
	ret;done




;------------------------------------PART 5----------------------------------
display_message:
	mov ZH,r25//get the Z pointer to find the location of the address
	mov ZL,r24
next_char:
	lpm r24, Z ;r24 iteraties between letters
	tst r24// check if r24 = 0. 0 will mean we went through all the letters
	breq done

	lpm r24, Z+;go to the next letter
	mov XH,ZH; POINTER MUST TO BE COPIED somewhere else, because 'encode letters'
	mov XL,ZL; uses Z pointer too. COPY to X register for now.

	;find the letter and encode it to work properly
	push r24
	rcall encode_letter
	pop r24
	;the value stored in r25 from encode letter, now time to display
	push r25
	rcall leds_with_speed
	pop r25
	;TAKEN FROM ROCKET.csc.uvic.ca MIKE ZASTRE said use 2 delay short between letters
	rcall delay_short
	rcall delay_short
	
	//original pointer for letters in word is stored in X, now copy back to Z
	mov ZH,XH
	mov ZL,XL
	rjmp next_char
	;clr r24

	done:
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
.cseg
.org 0x600

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

