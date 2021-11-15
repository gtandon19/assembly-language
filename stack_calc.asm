; This program is a stack calculator. It evaluates postfix
; expressions through a stack. The user is prompted for input.
; Whenever the user enters a positive integer, it is pushed
; into the stack. Whenever the user enters an operation symbol,
; the program enters the subroutine of the operation and does
; the operation on the last two numbers. When the user enters
; the equal sign, the final output is printed in hexadecimal as
; long as the stack is empty at the end.
; partners: gtandon3, ddamani2
; Register Table:
; R0: stores ASCII values of characters to print and acts as
;     input and output of many subroutines
; R1: counter for 4 bits in each hexadecimal group
; R2: stores value to be printed and used to check input
; R3: stores total hexadecimal value to be printed
; R4: used as input to some of the operation subroutines
; R5: stores final result of operations at the end
; R6: counter for 4 groups in hexadecimal
; R7: not used

.ORIG x3000        ; starting memory
INPUT IN           ; asks for user input
JSR EVAlUATE       ; evaluates expression using subroutine EVALUATE
RES_PR            
JSR PRINT_HEX      ; moves to subroutine to print the ans
OVER HALT          ; end program
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R3- value to print in hexadecimal
PRINT_HEX
; USE CODE FROM LAST TIME
AND R6, R6, #0     ; R6 set to 0
ADD R6, R6, #4     ; R6 set to 4
NEXT_HEX
AND R2, R2, #0     ; R2 set to 0
AND R1, R1, #0     ; R3 set to 0
ADD R1, R1, #4     ; R3 set to 4
PR_HEX
ADD R2, R2, R2     ; left shift R2 (emptying the LSB)
ADD R3, R3, #0     ; check the MSB of R3
BRzp SHIFT         ; if 0, just shift bits
ADD R2, R2, #1     ; if 1, add 1 to R2
SHIFT
ADD R3, R3, R3     ; left shift R3
ADD R1, R1, #-1    ; R1 decremented
BRp PR_HEX
AND R0, R0, #0     ; R0 set to 0
ADD R0, R2, #-9    ; R2 added to R0
ADD R0, R0, #-1    ; R0 added to #-10
BRzp LETTER        ; if >=0, its a letter A-F
LD R0, NUM_NUM     ; R0 set to #48
ADD R0, R2, R0     ; R2 added to R0
OUT                ; number printed
ADD R6, R6, #-1    ; R6 decremented
BRp NEXT_HEX
ADD R6, R6, #0     ; check R6
BRz DONE           ; if zero, done
LETTER
LD R0, LETTER_NUM  ; R0 set to #55
ADD R0, R2, R0     ; R2 added to R0
OUT                ; letter printed
ADD R6, R6, #-1    ; R6 decremented
BRp NEXT_HEX
DONE
ADD R6, R6, #0
BRnzp OVER
NUM_NUM     .FILL #48     ; ascii for "0"
LETTER_NUM  .FILL #55     ; ascii for "A"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R0 - character input from keyboard
;R6 - current numerical output
;
;
EVALUATE
;your code goes here
IS_EQ LD R6, ASC_EQ        ; R6 now holds neg val of eq sign
ADD R2, R6, R0             ; (input-asc_eq) stored to R2
BRnp IS_SP                 ; if not equal, check if space
; if equal, then enter code
JSR POP                    ; pop value
AND R3, R3, #0             ; R3 set to 0
ADD R3, R3, R0             ; R3 is pop value
JSR POP                    ; pop value
ADD R5, R5, #0             ; R5 checked
BRz INVAL                  ; if pop successful, invalid
AND R5, R5, #0             ; R5 set to 0
ADD R5, R3, #0             ; R5 stores result
BRnzp RES_PR               ; go print result
IS_SP LD R6, ASC_SP        ; R6 is space ascii
ADD R2, R6, R0             ; (input-asc_sp) stored to R2
BRz INPUT                  ; user input
IS_NUM LD R6, ASC_0        ; R6 is 0 ascii
ADD R2, R6, R0             ; check if num >= 0
BRn IS_PL                  ; transfers to checking the plus if less than 0
LD R6, ASC_9               ; R6 is 9 ascii
ADD R2, R6, R0             ; check if num <= 9
BRp IS_PL                  ; transfers to checking plus if more than 9
; if it is between 0 and 9
LD R6, ASC_0               ; R6 is 0 ascii
ADD R0, R6, R0             ; subtract the number to get beginning ascii
JSR PUSH                   ; store to the stack
BRnzp INPUT                ; user input
IS_PL LD R6, ASC_PL        ; R6 is plus ascii
ADD R2, R6, R0             ; (input-asc_pl) stored to R2
BRnp NOTADD                ; jump post the code
JSR POP                    ; popped val in R0
ADD R5, R5, #0             ; R5 has result
BRp INVAL                  ; if 1 we know it is invalid so we escape and print error message
AND R4, R4, #0             ; clear R4
ADD R4, R4, R0             ; R0 (popped val) stored in R4
JSR POP                    ; pop value
ADD R5, R5, #0             ; R5 has result
BRp INVAL                  ; if 2 we know it is invalid so we escape and print result
AND R3, R3, #0             ; clear R4
ADD R3, R3, R0             ; R0 stored in R3
JSR PLUS                   ; now we do addition
JSR PUSH                   ; result is stored back
BRnzp INPUT                ; now that we are done, we go back and fetch another char
NOTADD                     ; done adding / skipping add
IS_MIN LD R6, ASC_MIN      ; R6 is minus ascii
ADD R2, R6, R0             ; check if minus
BRnp NOTMIN                ; not minus
JSR POP                    ; pop value
ADD R5, R5, #0             ; check R5
BRp INVAL                  ; if 1, invalid
AND R4, R4, #0             ; R4 is 0
ADD R4, R4, R0             ; R4 is pop value
JSR POP                    ; pop value
ADD R5, R5, #0             ; check R5
BRp INVAL                  ; if 1, invalid
AND R3, R3, #0             ; R3 is 0
ADD R3, R3, R0             ; R3 is pop value
JSR MIN                    ; go to minus subroutine
JSR PUSH                   ; push value
BRnzp INPUT                ; user input
NOTMIN
IS_MUL LD R6, ASC_MUL      ; R6 is * value
ADD R2, R6, R0             ; check if *
BRnp NOTMUL                ; not *
JSR POP                    ; pop value
ADD R5, R5, #0             ; check R5
BRp INVAL                  ; if 1, invalid
AND R4, R4, #0             ; R4 is 0
ADD R4, R4, R0             ; R4 is pop value
JSR POP                    ; pop value
ADD R5, R5, #0             ; check R5
BRp INVAL                  ; if 1, invalid
AND R3, R3, #0             ; R3 is 0
ADD R3, R3, R0             ; R3 is pop value
JSR MUL                    ; go to multiply subroutine
JSR PUSH                   ; push value
BRnzp INPUT                ; user input
NOTMUL
IS_DIV LD R6, ASC_DIV      ; R6 is / ascii
ADD R2, R6, R0             ; check if /
BRnp NOTDIV                ; not /
JSR POP                    ; pop value
ADD R5, R5, #0             ; check R5
BRp INVAL                  ; if 1, invalid
AND R4, R4, #0             ; R4 is 0
ADD R4, R4, R0        ; R4 is pop value
JSR POP   ; pop value
ADD R5, R5, #0   ; check R5
BRp INVAL   ; if 1, invalid
AND R3, R3, #0   ; R3 is 0
ADD R3, R3, R0   ; R3 is pop value
JSR DIV   ; go to division subroutine
JSR PUSH   ; push value
BRnzp INPUT   ; user input
NOTDIV
IS_EXP
LD R6, ASC_EXP   ; R6 is exp ascii
ADD R2, R6, R0        ; check if ^
BRnp NOTEXP   ; not ^
JSR POP   ; pop value
ADD R5, R5, #0   ; check R5
BRp INVAL   ; if 1, invalid
AND R4, R4, #0   ; R4 is 0
ADD R4, R4, R0   ; R4 is pop value
JSR POP   ; pop value
ADD R5, R5, #0   ; check R5
BRp INVAL   ; if 1, invalid
AND R3, R3, #0   ; R3 is 0
ADD R3, R3, R0   ; R3 is pop value
JSR EXP   ; go to exponent subroutine
EXP_RET JSR PUSH   ; push value
BRnzp INPUT   ; user input
NOTEXP
INVAL LEA R0, INV_STR      ; obtain the string stored in mem
PUTS                       ; prints string
BRnzp OVER                 ; finished prog
RET   ; return
ASC_EQ .FILL #-61   ; neg ascii value for =
ASC_SP .FILL #-32   ; neg ascii value for space
ASC_PL .FILL #-43   ; neg ascii value for +
ASC_MIN .FILL #-45   ; neg ascii value for -
ASC_MUL .FILL #-42   ; neg ascii value for *
ASC_DIV .FILL #-47   ; neg ascii value for /
ASC_EXP .FILL #-94   ; neg ascii value for ^
ASC_0 .FILL #-48   ; neg ascii value for 0
ASC_9 .FILL #-57   ; neg ascii value for 9
INV_STR .STRINGZ "Invalid Input."   ; string for invalid input
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
PLUS
ADD R0, R3, R4 ; addition ; R0 = R3 + R4
RET  ; return to main subroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MIN
NOT R4, R4  ; R4 = not R4
ADD R4, R4, 1   ; 2s complement subtraction
ADD R0, R3, R4                        ; R0 = R3 - R4
RET   ; return to main subtroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MUL
AND R0, R0, #0 ; clearing R0 to let it store op
ST R2, SAVE_R2 ; will use R2 for calculation, will be restored
AND R2, R2, #0 ; R2 is 0
ADD R2, R2, R3 ; to do the countdown of R2
LOOPM BRz FINMUL ; escapes if R2 is 0 (mult over)
ADD R0, R0, R4 ; repeated addition
ADD R2, R2, #-1 ; R2 decremented
BRnzp LOOPM     ; start loop
FINMUL LD R2, SAVE_R2 ; restore R2 value
RET ; done, so return from subroutine
SAVE_R2 .BLKW #1     ; save R2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
DIV
;division is continuous subtraction
AND R0, R0, #0 ; clearing R0
NOT R1, R4 ; getting 2s comp
ADD R1, R1, #1   ; R1 incremented
LOOPD ADD R3, R3, R1 ; R3 = R3-R1
BRn FINDIV   ; division done
ADD R0, R0, #1   ; R0 incremented
BRnzp LOOPD   ; go to loop
FINDIV RET    ; return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
EXP
AND R0, R0, #0 ; R0 is 0
ADD R0, R0, #1 ; multiplying need init val=
AND R1, R1, #0 ; R1 is 0
ADD R1, R1, R4 ; using R4 for multiplication
BRz DONEEX     ; exp done
AND R4, R4, #0 ; R4 is 0
ADD R4, R4, R3; R3 moved to R4
AND R3, R3, #0 ; R3 is 0
ADD R3, R3, R0 ; R3, R4 now has the input values
LOOPE JSR MUL ; R0 sotres mul of R3, R4
AND R3, R3, #0 ; R3 is 0
ADD R3, R3, R0 ; store R0 to R3
ADD R1, R1, #-1 ; R1 keeps reducing until it becomes 0 or -1
BRz DONEEX ; leave once counter is done
BRnzp LOOPE ; continue multiplying
DONEEX BRnzp EXP_RET   ; return
;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH
ST R3, PUSH_SaveR3 ;save R3
ST R4, PUSH_SaveR4 ;save R4
AND R5, R5, #0 ;
LD R3, STACK_END ;
LD R4, STACk_TOP ;
ADD R3, R3, #-1 ;
NOT R3, R3    ;
ADD R3, R3, #1 ;
ADD R3, R3, R4 ;
BRz OVERFLOW ;stack is full
STR R0, R4, #0 ;no overflow, store value in the stack
ADD R4, R4, #-1 ;move top of the stack
ST R4, STACK_TOP ;store top of stack pointer
BRnzp DONE_PUSH ;
OVERFLOW
ADD R5, R5, #1 ;
DONE_PUSH
LD R3, PUSH_SaveR3 ;
LD R4, PUSH_SaveR4 ;
RET
PUSH_SaveR3 .BLKW #1 ;
PUSH_SaveR4 .BLKW #1 ;
;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP
ST R3, POP_SaveR3 ;save R3
ST R4, POP_SaveR4 ;save R3
AND R5, R5, #0 ;clear R5
LD R3, STACK_START ;
LD R4, STACK_TOP ;
NOT R3, R3 ;
ADD R3, R3, #1 ;
ADD R3, R3, R4 ;
BRz UNDERFLOW ;
ADD R4, R4, #1 ;
LDR R0, R4, #0 ;
ST R4, STACK_TOP ;
BRnzp DONE_POP ;
UNDERFLOW
ADD R5, R5, #1 ;
DONE_POP
LD R3, POP_SaveR3 ;
LD R4, POP_SaveR4 ;
RET
POP_SaveR3 .BLKW #1 ;
POP_SaveR4 .BLKW #1 ;
STACK_END .FILL x3FF0 ;
STACK_START .FILL x4000 ;
STACK_TOP .FILL x4000 ;
.END
