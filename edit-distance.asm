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
; **** BEGINNING OF "STUDENT CODE" SECTION **** 

	; Your solution in here.

	; THE RESULT **MUST** END UP IN R25
	

	ldi r16, 0b00000000
	ldi r17, 0b11111111

	EOR r16,r17 ; to find all different value between them and then count!
	.def XOR_Res = r18 ; result from exclusive-or
		MOV XOR_Res, r16

	.def loop_c = r19;counter
		ldi loop_c, 0x00

	.def dist_c = r20; result
		ldi dist_c, 0x00

	.def mask = r21
		ldi mask, 0b10000000


	loop:
		inc loop_c
		AND XOR_Res, mask
		brne res_one ;found one! zero flag is unset (it's not 0x00)

		cpi loop_c, 0x09; 9 because you get extra inc loop_c
		breq copy ;done counting, copy value to r25

		;zero flag is set, so keep going
		lsr mask ;shift to check other values
		MOV XOR_Res,r16 ;r16 original xor result
		rjmp loop

	res_one:
		inc dist_c;counter for edit distance
		lsr mask;shift masking value right
		MOV XOR_Res,r16
		rjmp loop

	copy:
		MOV r25,dist_c
	
; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
edit_distance_stop:
    rjmp edit_distance_stop



; ==== END OF "DO NOT TOUCH" SECTION ==========

