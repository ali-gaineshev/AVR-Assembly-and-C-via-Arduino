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

	ldi R16, 0b00000000
	; THE RESULT **MUST** END UP IN R25

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
	.def value = r16
	.def mask = r18
		ldi mask,0x01
	.def copy = r17;copy of the value
		mov copy,value
	.def loop_c = r19
		ldi loop_c,0x00
	.def one_found = r20 ; counter if right most bit 1 found
		ldi one_found,0x00

	loop:
		cpi loop_c, 0x08;check if checked all value
		breq result

		mov value,copy ; keep value and copy updated
		AND value,mask;and with mask to find the right bit
		brne found_one ; if found 1 go to found_one

		cpi one_found, 0x00; if found one counter and 0 are not the same then we should stop, since we already reset the rm con set bit
		brne result

		lsl mask; left shift mask
		inc loop_c
		rjmp loop
	found_one: 
		inc loop_c; might do a lot of operations here, so need to check if loop_c is 8 eventually
		inc one_found ; counter
		EOR copy, mask; reset that 1 bit
		lsl mask
		rjmp loop; go back to find more 1 or 0 to stop
	result: 
		mov r25,copy 
		rjmp reset_rightmost_stop
; **** END OF "STUDENT CODE" SECTION ********** 
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
reset_rightmost_stop:
    rjmp reset_rightmost_stop
; ==== END OF "DO NOT TOUCH" SECTION ==========
