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
	ldi r16, 0x52
	ldi r17, 0x51

; ==== END OF "DO NOT TOUCH" SECTION ==========
	
; **** BEGINNING OF "STUDENT CODE" SECTION **** 
	
	.def n1_h = r16 
	.def n1_l = r18
		mov n1_l, r16
		cbr n1_l, 0b11110000 
		cbr n1_h, 0b00001111;number 1 high nibble only eg 11110000 |same for the rest of nums & nibbles
		swap n1_h ;swap to low nibble to get addition right eg 00001111

	.def n2_h = r17
	.def n2_l = r19
		mov n2_l, r17
		cbr n2_l, 0b11110000
		cbr n2_h, 0b00001111
		swap n2_h ;eg 00000111
	.def adder = r20 ;have to add 6 if sum is bigger than 9.
		ldi r20, 0b00000110
	
	.def h_nib_carry =r24 ;final carry for high nibble

	ADD n1_l,n2_l ;add low nibbles
	cpi n1_l,0b00001010 ; check if 10 or bigger if yes then 
	brsh more_than9;	  go to more_than9 to get the low nibble carry


high_nib_addition:; just to go back here eventually
	ADD n1_h,n2_h
	cpi n1_h,0b00001010
	brsh more_than9_high

	cpi adder, 0b00000111; check if adder is 7 ,if so just add one to high_nibble, 
	;then you get 2 cases -> 1) there is no final carry and 1 lower nibble carry, so just add 1 to high nibble value 
	;                        2)there is a final carry and 1 lower nibble carry, add one and then get final carry 
	breq  add_one

	cpi adder, 0b00000110 ;another case where there is no lower nibble carry and no final carry,
	;					   so just swap high nibble (which is in low nibble position at the moment) back to original place
	breq swap_high

result:
	ADD n1_h, n1_l ;add both nibbles together
	mov r25,n1_h
	;mov r24,h_nib_carry
	rjmp bcd_addition_end

more_than9:;for low nibble
	ADD n1_l,adder ; add 6 to get the right value
	inc adder ;set to 7 for upper nibble addition , just in case
	cbr n1_l, 0b11110000 ;reset upper nibble , n1_l is the result value for lower nibble
	rjmp high_nib_addition

more_than9_high:; for high nibble
	ADD n1_h,adder
	ldi h_nib_carry,0x01 ;set final carry to 1
	cbr n1_h, 0b11110000 ;clear the upper nibble which has extra 1
	swap n1_h; swap back to get the result
	rjmp result
;cases were specified before for the rest of them
add_one:
	inc n1_h
	cpi n1_h,0b00001010 ;if result is 10 then need to subtract one and add adder
	brsh reduce_one

	cbr n1_h, 0b11110000; clear all carrys
	swap n1_h
	rjmp result
reduce_one:
	dec n1_h
	rjmp more_than9_high

swap_high:
	swap n1_h
	rjmp result
; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
bcd_addition_end:
	rjmp bcd_addition_end

; ==== END OF "DO NOT TOUCH" SECTION ==========
