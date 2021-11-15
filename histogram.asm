The code given to you here implements the histogram calculation that 
; we developed in class.  In programming lab, we will add code that
; prints a number in hexadecimal to the monitor.
;
; Your assignment for this program is to combine these two pieces of 
; code to print the histogram to the monitor.
;

	.ORIG	x3000		; starting address is x3000


;
; Count the occurrences of each letter (A to Z) in an ASCII string 
; terminated by a NUL character.  Lower case and upper case should 
; be counted together, and a count also kept of all non-alphabetic 
; characters (not counting the terminal NUL).
;
; The string starts at x4000.
;
; The resulting histogram (which will NOT be initialized in advance) 
; should be stored starting at x3F00, with the non-alphabetic count 
; at x3F00, and the count for each letter in x3F01 (A) through x3F1A (Z).
;
; table of register use in this part of the code
;    R0 holds a pointer to the histogram (x3F00)
;    R1 holds a pointer to the current position in the string
;       and as the loop count during histogram initialization
;    R2 holds the current character being counted
;       and is also used to point to the histogram entry
;    R3 holds the additive inverse of ASCII '@' (xFFC0)
;    R4 holds the difference between ASCII '@' and 'Z' (xFFE6)
;    R5 holds the difference between ASCII '@' and '`' (xFFE0)
;    R6 is used as a temporary register
;

	LD R0,HIST_ADDR      	; point R0 to the start of the histogram
	
	; fill the histogram with zeroes 
	AND R6,R6,#0		; put a zero into R6
	LD R1,NUM_BINS		; initialize loop count to 27
	ADD R2,R0,#0		; copy start of histogram into R2

	; loop to fill histogram starts here
HFLOOP	STR R6,R2,#0		; write a zero into histogram
	ADD R2,R2,#1		; point to next histogram entry
	ADD R1,R1,#-1		; decrement loop count
	BRp HFLOOP		; continue until loop count reaches zero

	; initialize R1, R3, R4, and R5 from memory
	LD R3,NEG_AT		; set R3 to additive inverse of ASCII '@'
	LD R4,AT_MIN_Z		; set R4 to difference between ASCII '@' and 'Z'
	LD R5,AT_MIN_BQ		; set R5 to difference between ASCII '@' and '`'
	LD R1,STR_START		; point R1 to start of string

	; the counting loop starts here
COUNTLOOP
	LDR R2,R1,#0		; read the next character from the string
	BRz PRINT_HIST		; found the end of the string

	ADD R2,R2,R3		; subtract '@' from the character
	BRp AT_LEAST_A		; branch if > '@', i.e., >= 'A'
NON_ALPHA
	LDR R6,R0,#0		; load the non-alpha count
	ADD R6,R6,#1		; add one to it
	STR R6,R0,#0		; store the new non-alpha count
	BRnzp GET_NEXT		; branch to end of conditional structure
AT_LEAST_A
	ADD R6,R2,R4		; compare with 'Z'
	BRp MORE_THAN_Z         ; branch if > 'Z'

; note that we no longer need the current character
; so we can reuse R2 for the pointer to the correct
; histogram entry for incrementing
ALPHA	ADD R2,R2,R0		; point to correct histogram entry
	LDR R6,R2,#0		; load the count
	ADD R6,R6,#1		; add one to it
	STR R6,R2,#0		; store the new count
	BRnzp GET_NEXT		; branch to end of conditional structure

; subtracting as below yields the original character minus '`'
MORE_THAN_Z
	ADD R2,R2,R5		; subtract '`' - '@' from the character
	BRnz NON_ALPHA		; if <= '`', i.e., < 'a', go increment non-alpha
	ADD R6,R2,R4		; compare with 'z'
	BRnz ALPHA		; if <= 'z', go increment alpha count
	BRnzp NON_ALPHA		; otherwise, go increment non-alpha

GET_NEXT
	ADD R1,R1,#1		; point to next character in string
	BRnzp COUNTLOOP		; go to start of counting loop



PRINT_HIST

; you will need to insert your code to print the histogram here

; do not forget to write a brief description of the approach/algorithm
; for your implementation, list registers used in this part of the code,
; and provide sufficient comments





; This part of the code prints out the histogram. First, it uploads the
; frequency count from the memory starting at x3F00. Then, it prints the
; corresponding ASCII character. Then, it prints a space. To output the
; frequency in hexadecimal, there are two loops. One loop is for the
; four binary digits in each group. This loop helps copy the first four
; binary digits into another register to print out the number (0-9) or
; letter (A-F) using the count. Another loop is four each of the four
; characters that represent the frequency. Once this loop is done, the
; next line starts printing and the loops start over. Once the counter
; reaches 27, meaning that all 27 lines of the histogram are printed,
; the program halts.
; partners: gtandon3, ddamani2
; R0 = used for printing any ASCII characters to the screen
; R1 = stores frequency of one character at a time
; R2 = stores first 4 bits of frequency
; R3 = counter for 4 bits in one group of hexadecimal
; R4 = stores memory location on histogram
; R5 = counter up to 27 for printing out histogram
; R6 = counter for 4 groups in one hexadecimal
LD R4, HIST_ADDR     ; R4 set to start of histogram  
AND R5, R5, #0       ; R5 set to 0
LD R0, NEW_LINE      ; R0 has newline ascii
OUT                  ; goes to next line
NEXT_LINE
LDR R1, R4, #0       ; R1 has frequency count of character
LD R0, NEW_LINE      ; R0 has newline ascii
OUT                  ; goes to next line
LD R0, ASCII_NUM     ; R0 set to #64
ADD R0, R0, R5       ; R0 added to counter up to 27
OUT                  ; ASCII character printed
LD R0, SPACE         ; R0 has space ascii
OUT                  ; makes a space
; init R2, R3
AND R6, R6, #0       ; R6 set to 0
ADD R6, R6, #4       ; R6 set to 4
NEXT_HEX
AND R2, R2, #0       ; R2 set to 0
AND R3, R3, #0       ; R3 set to 0
ADD R3, R3, #4       ; R3 set to 4
PRINT_HEX
ADD R2, R2, R2       ; left shift R2 (emptying the LSB)      
ADD R1, R1, #0       ; check the MSB of R1
BRzp SHIFT           ; if 0, just shift bits
ADD R2, R2, #1       ; if 1, add 1 to R2
SHIFT
ADD R1, R1, R1       ; left shift R1
ADD R3, R3, #-1      ; R3 decremented
BRp PRINT_HEX        ; if >0, keep calculating hex
; print R2
AND R0, R0, #0       ; R0 set to 0
ADD R0, R2, #-9      ; R2 added to R0
ADD R0, R0, #-1      ; R0 added to #-10          
BRzp LETTER          ; if >=0, its a letter A-F
LD R0, NUM_NUM       ; R0 set to #48
ADD R0, R2, R0       ; R2 added to R0
OUT                  ; number printed
ADD R6, R6, #-1      ; R6 decremented
BRp NEXT_HEX         ; if >0, go to next character
ADD R6, R6, #0       ; check R6
BRz END_LINE         ; if zero, end  line
LETTER
LD R0, LETTER_NUM    ; R0 set to #55
ADD R0, R2, R0       ; R2 added to R0
OUT                  ; letter printed
ADD R6, R6, #-1      ; R6 decremented
BRp NEXT_HEX         ; if >0, go to next character
       
END_LINE
ADD R4, R4, #1       ; R4 incremented
ADD R5, R5, #1       ; R5 incremented
LD R0, NUM_BINS      ; R0 set to 27
NOT R0, R0           ; R0 2s complemented
ADD R0, R0, #1       ; R0 set to -27
ADD R0, R0, R5       ; R5 added to R0
BRn NEXT_LINE        ; if <0, go to next line
DONE HALT     ; done
; the data needed by the program
NUM_BINS .FILL #27 ; 27 loop iterations
NEG_AT .FILL xFFC0 ; the additive inverse of ASCII '@'
AT_MIN_Z .FILL xFFE6 ; the difference between ASCII '@' and 'Z'
AT_MIN_BQ .FILL xFFE0 ; the difference between ASCII '@' and '`'
HIST_ADDR .FILL x3F00 ; histogram starting address
STR_START .FILL x4000 ; string starting address
ASCII_NUM   .FILL #64   ; ascii for "@"
SPACE       .FILL #32   ; ascii for " "
NEW_LINE    .FILL x000A ; ascii for new line
NUM_NUM     .FILL #48   ; ascii for "0"
LETTER_NUM  .FILL #55   ; ascii for "A"
; the directive below tells the assembler that the program is done
; (so do not write any code below it!)
.END
