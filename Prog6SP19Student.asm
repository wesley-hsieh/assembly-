;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Wesley Hsieh
;  COMSC-260 Spring 2019
;  Date: 4/21/2019	
;  Assignment 6
;  Version of Visual Studio used (2015)(2017):  2017
;  Did program compile? Yes/No : YES 
;  Did program produce correct results? Yes/No: YES 
;  Is code formatted correctly including indentation, spacing and vertical alignment? Yes/No: YES 
;  Is every line of code commented? Yes/No :YES 
;
;  Estimate of time in hours to complete assignment:  10 hours
;
;  In a few words describe the main challenge in writing this program:
;  understanding how to better use shld shrd
;  figuring out where specifically I had to add certain push/pop/xor statements 
;  to keep the values I wanted, i.e. in Shifter/DoLeftRotates
;
;  *************************************************************
;  Reminder: each assignment should be the result of your
;  individual effort with no collaboration with other students.
;
;  Reminder: every line of code must be commented and formatted  
;  per the ProgramExpectations.pdf file on the class web site
; *************************************************************


.386                    ;identifies minimum CPU for this program

.MODEL flat,stdcall     ;flat - protected mode program
                        ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096              ;allocate 4096 bytes (1000h) for stack

mPrtChar  MACRO  arg1    ;arg1 is replaced by the name of character to be displayed
         push eax        ;save eax
         mov al, arg1    ;character to display should be in al
         call WriteChar  ;display character in al
         pop eax         ;restore eax
ENDM


mPrtStr macro   arg1          ;arg1 is replaced by the name of character to be displayed
         push edx             ;save eax
         mov edx, offset arg1 ;character to display should be in al
         call WriteString     ;display character in al
         pop edx              ;restore eax
ENDM

;*************************PROTOTYPES*****************************

ExitProcess PROTO,
    dwExitCode:DWORD    ;from Win32 api not Irvine to exit to dos with exit code

ReadChar PROTO          ;Irvine code for getting a single char from keyboard
				        ;Character is stored in the al register.
			            ;Can be used to pause program execution until key is hit.

WriteChar PROTO         ;Irvine code to write character stored in al to console

WriteString proto
WriteDec proto

;************************  Constants  ***************************

LF       equ     0Ah                   ; ASCII Line Feed
$parm1 equ dword ptr [ebp + 8]
$parm2 equ dword ptr [ebp + 12]

;************************DATA SEGMENT***************************

.data

    ;inputs for testing the Shifter function
    inputA  byte 0,1,0,1,0,1,0,1
    inputB  byte 0,0,1,1,0,0,1,1
    inputC  byte 1,1,1,1,0,0,0,0
    ARRAY_SIZE equ $ - inputC         

    ;numbers for testing DoLeftRotate
    nums   dword 10101010101010101010101010101101b
           dword 01010101010101010101010101010101b
           dword 11010101011101011101010101010111b
    NUM_SIZE EQU $-nums               ;total bytes in the nums array

    NUM_OF_BITS EQU SIZEOF(DWORD) * 8 ;Total bits for a dword

    ;You can add LFs to the strings below for proper output line spacing
    ;but do not change anything between the quotes "do not change".
    ;You can also combine messages where appropriate.

    ;I will be using a comparison program to compare your output to mine and
    ;the spacing must match exactly.

    endingMsg           byte "Hit any key to exit!",0

    ;Change my name to your name
    titleMsg            byte "Program 6 by Wesley Hsieh",LF,LF , 0

    testingShifterMsg   byte "Testing Shifter",LF, 0
    enabledMsg          byte "(Shifting enabled C = 1, Disabled C = 0)",LF, 0

    testingDoLeftRotateMsg byte "Testing DoLeftRotate",LF, 0

    header       byte  "A B C | Output",LF, 0

    original     byte " Original",LF, 0
    disableShift byte " Disable Rotate",LF, 0
    enableShift  byte " Enable Rotate",LF, 0
    shiftInst    byte " Rotate Instruction",LF, 0
    blankLine    byte LF,LF,0   ;blankLine may not be necessary

    dashes byte "------------------------------------",LF, 0
	spdashsp byte " | ", 0
	space	byte	" ", 0
	line	byte	LF,0

;************************CODE SEGMENT****************************

.code

Main PROC
	;start student code here
	;See the pdf file for the pseudo code for the main function
	mPrtStr	titleMsg				;print titleMsg
	mPrtStr	testingShifterMsg		;print testingShiftMsg
	mPrtStr enabledMsg				;print enableMsg
	mPrtStr	dashes					;print dashes
	mPrtStr	header					;print header

	mov		esi, 0					;establish counter for shifter 
	mov		edi, 0					;establish counter for DoLeftRotate

loopTop:
	cmp		esi, ARRAY_SIZE			;compare esi to ARRAY_SIZE
	je		sndLoop					;if equal jump to sndloop

	movzx	eax, inputA[esi]		;move inputA[esi] into eax and zero out the top
	movzx	ebx, inputB[esi]		;move inputB[esi] into ebx and zero out the top
	movzx	ecx, inputC[esi]		;move inputC[esi] into ecx and zero out the top

	;print the values
	call	WriteDec				;call WriteDec
	mPrtStr	space					;print space
	push	eax						;push eax onto stack
	mov		eax, ebx				;move ebx into eax
	call	WriteDec				;call WriteDec
	mPrtStr	space					;print space
	mov		eax, ecx				;move ecx into eax	
	call	WriteDec				;call WriteDec
	pop		eax						;return eax from stack
	mPrtStr	spdashsp				;print spdashsp

	;call shifter and print value
	call	Shifter					;call Shifter
	call	WriteDec				;call WriteDec to print al
	mPrtStr	line					;print an empty line
	
	inc		esi						;increment esi
	jmp		loopTop					;jump back to loopTop

sndLoop:
	mPrtStr	line					;print an empty line
	mPrtStr testingDoLeftRotateMsg	;print testingDoLeftRotateMsg
	mPrtStr	dashes					;print dashes

sndInnerLoop:
	cmp		edi, NUM_SIZE			;compare edi to NUM_SIZE
	je		done					;if equal jump to done

	;print original 
	mov		eax, nums[edi]			;move nums[edi] into eax
	push	eax						;push eax onto stack
	call	DspBin					;call DspBin
	mPrtStr original				;print original

	;print disable shift
	push	0						;push 0 onto stack to disable rotate
	mov		eax, nums[edi]			;move nums[edi]
	push	eax						;no need to reassign a register with nums[edi]
	call	DoLeftRotate			;call DoLeftRotate
	push	eax						;push eax onto stack
	call	DspBin					;call DspBin
	mPrtStr	disableShift			;print disableShift

	;print enable shift
	push	1						;push 0 onto stack to disable rotate
	mov		eax, nums[edi]			;move nums[edi] into eax
	push	eax						;no need to reassign a register with nums[edi]
	call	DoLeftRotate			;call DoLeftRotate
	push	eax						;push eax onto stack
	call	DspBin					;call DspBin
	mPrtStr	enableShift				;print disableShift

	;print rotate 
	mov		eax, nums[edi]			;move nums[edi] onto stack
	rol		eax, 1					;rotate eax by 1 
	push	eax						;push eax onto stack
	call	DspBin					;call DspBin
	mPrtStr	shiftInst				;print shiftInst

	mPrtStr	line					;print a line
	add		edi, 4					;increment edi by 4
	jmp		sndinnerLoop			;jump to sndInnerLoop	

done:
	mPrtStr endingMsg				;print endingMsg
    call    ReadChar                ;pause execution
	INVOKE  ExitProcess,0           ;exit to dos: like C++ exit(0)

Main ENDP


;************** DoLeftRotate - Shift a dword left by 1 and rotate leftmost bit into the right end
;
;       ENTRY – operand 2 (enable,disable rotate) and operand 1 (number to rotate) are on the stack
;                         
;       EXIT  - EAX = rotated or non rotated number
;       REGS  - List registers you use
;
;       note: Before calling DoLeftRotate push operand 2 onto the stack and then push operand 1.
;
;	    note: DoLeftRotate calls the Shifter function to shift 1 bit.
;
;       to call DoLeftRotate in main function:
;                                   push  0 or 1             ;1 to rotate, 0 to disable rotate
;                                   push  numberToRotate     ;32 bit operand1
;                                   call DoLeftRotate        ;result in eax
;
;       Note; at the end of this function use ret 8 (instead of just ret) to remove the parameters from the stack.
;                 Do not use add esp, 8 in the main function.
;--------------
;Do not access the arrays in main directly in the DoLeftRotate function. 
;The data must be passed into this function via the stack.
;Note: the DoLeftRotate function does not do any output. All the output is done in the main function
;
;Note: if rotating is disabled ($parm2 = 0) do not hardcode the return value to be
;equal to $parm1. If rotating is disabled you must still process all the bits
;through your Shifter function.
;
;In this function you will examine the bits from operand 1 in order from right to left using the BT instruction.

;See BT.asm on the class web site.

;You will use the BT instruction to copy the bits from operand 1 to the carry flag.
    
;Before the loop you will hardcode AL to bit 31 of the number to rotate 
;to account for the leftmost bit being rotated into the right end during a left rotate. 
    
;Before the loop you will also set bl to the value of bit 0 of the number to rotate by using the following method:

;You will use the BT instruction to copy bit 0 to the carry flag then use a rotate instruction to copy the
;carry flag to the right end of bl.

;Then you will populate ecx with operand 2 which is the enable (1) or disable bit(1) then call the shifter function.

;Then copy the the bit returned in al from the shifter function to the left end
;of the register used to accumulate the shifted or non shifted bits by using one of the 3 operand double shift instructions.

;Warning, The double shift instruction can only be used on 16 (ax) or 32 (eax) bits.

;See pages 3-4 in shiftAndRotate32.pdf on the class web site for information about the double shift instructions.

;after calling the shifter function you will transfer the return value from al to 
;the left end of the register you are using to accumulate shifted or non shifted bits which should have been initialized to 0.

;Then you will have a loop that will execute (NUM_OF_BITS - 1) times(31 times).
;You should use the NUM_OF_BITS constant - 1 as the terminating loop condition and not hard code it.

;The counter for the loop begins at 0
;NOTE: you cannot use ecx for the counter since it contains the enable or disable bit.

;In the loop you will do the following:
;clear al and bl
;Use the BT instruction to copy the bit at position of the counter to the carry flag 
;and from the carry flag to the right end of al.

;Then use the BT instruction to copy the bit at position of the counter + 1 to the carry flag 
;and from the carry flag to the right end of bl.

;ecx should still be populated with the value of operand2 assigned before the loop.

;Then call the shifter function which returns the shifted or non shifted bit in al.

;Then copy the the bit returned in al from the shifter function to the left end
;of the register used to accumulate the shifted or non shifted bits by using one of the 3 operand double shift instructions.

;Warning, The double shift instruction can only be used on 16 (ax) or 32 (eax) bits.

;See pages 3-4 in shiftAndRotate32.pdf on the class web site for information about the double shift instructions.

;after the loop exits make sure the shifted or non shifted bits are in eax

;Each iteration of the loop should process the bits as follows:
    
;al = bit at position counter (shifted bit)
;bl = bit a position counter + 1 (original bit)
;
;		  Bit #	
;	counter | al  bl
;	    0	|  31  0 (leftmost bit rotated into right end)
;    Above is before loop
;    Below is in loop
;	    0	|  0  1
;	    1	|  1  2
;	    2	|  2  3
;	    3	|  3  4
;	    4	|  4  5
; etc up to bit 31 (when counter is 31, the loop is done)
;       30  | 30 31
;       31  |  done   

;You should save any registers whose values change in this function 
;using push and restore them with pop.
;
;The saving of the registers should
;be done at the top of the function and the restoring should be done at
;the bottom of the function.
;
;Note: do not save any registers that return a value (eax).
;
;Each line of the Shifter function must be commented and you must use the 
;usual indentation and formating like in the main function.
;
;Don't forget the "ret 8" instruction at the end of the function
;
;Do not delete this comment block. Every function should have 
;a comment block before it describing the function. SP19

DoLeftRotate proc
	push	ebp					;save ebp to stack
	mov		ebp,	esp			;save stack pointer
	mov		edx,	0			;move 0 into edx
	mov		ecx,	$parm2		;populate ecx with our enable/disable bit

	xor		eax,	eax			;clear eax as it previously had our nums[edi]
	xor		ebx,	ebx			;clear ebx

	bt		$parm1, 31			;copy the (31st) digit of $parm1 to carry flag
	rcl		al,		1			;rotate it into al
	bt		$parm1, 0			;copy the 0th digit of $parm1 to carry flafg
	rcl		bl,		1			;rotate it into bl

	call	Shifter				;call Shifter

	shl		eax,	31			;shift the return bit from shifter 31 times, so its the leftmost bit 
	shld	edx,	eax, 1		;double shift the left most bit of ax into the right side of dx
	shl		edx,	31			;shift edx left 31 times

	mov		esi,	0			;esi was used for the offset of shifter and is no longer 
								;needed so no need to push it, this will be the counter for
								;the loop

	push	edi					;edi still has the value of the current loop for sndLoop in main
	mov		edi,	NUM_OF_BITS	;our end condition
	dec		edi					;the loop shoudl only loop one less than the size of the array

loopTop:
	cmp		esi,	edi			;compare esi, edi
	je		done				;if equal jump to done

	xor		eax,	eax			;clear eax
	xor		ebx,	ebx			;clear ebx

	bt		$parm1, esi			;copy bit at position esi of parm1 to carry flag
	rcl		al,		1			;rotate it into al
	inc		esi					;inc esi
	bt		$parm1, esi			;copy bit at position esi of parm1 to carry flag
	rcl		bl,		1			;rotate it into bl

	call	Shifter				;call Shifter

	shrd	edx,	eax, 1		;double shift one bit from eax to the right side of edx
	jmp		loopTop				;jump to loopTop

done:

	mov		eax,	edx			;move the new number into eax
	pop		edi					;return the value of edi from stack
	pop		ebp					
	ret 8

DoLeftRotate endp
;************** Shifter – Simulate a partial shifter circuit per the circuit diagram in the pdf file.  
;  Shifter will simulate part of a shifter circuit that will input 
;  3 bits and output a shifted or non-shifted bit.
;
;
;   CL--------------------------
;              |               |
;              |               |
;             NOT    BL        |     AL
;              |     |         |     |
;              --AND--         --AND--
;                 |                |
;                 --------OR--------
;                          |
;                          AL
;
; NOTE: To implement the NOT gate use XOR to flip a single bit.
;
; Each input and output represents one bit.
;
;  Note: do not access the arrays in main directly in the Adder function. 
;        The data must be passed into this function via the required registers below.
;
;       ENTRY - AL = input bit A 
;               BL = input bit B
;               CL = enable (1) or disable (0) shift
;       EXIT  - AL = shifted or non-shifted bit
;       REGS  -  (list registers you use)
;
;       For the inputs in the input columns you should get the 
;       output in the output column below.
;
;The chart below shows the output for 
;the given inputs if shifting is enabled (cl = 1)
;If shift is enabled (cl = 1) then output should be the shifted bit (al).
;In the table below shifting is enabled (cl = 1)
;
;        input      output
;     al   bl  cl |   al 
;--------------------------
;      0   0   1  |   0 
;      1   0   1  |   1 
;      0   1   1  |   0 
;      1   1   1  |   1   
;
;The chart below shows the output for 
;the given inputs if shifting is disabled (cl = 0)
;If shift is disabled (cl = 0) then the output should be the non-shifted bit (B).

;        input      output
;     al   bl  cl |   al 
;--------------------------
;      0   0   0  |   0 
;      1   0   0  |   0 
;      0   1   0  |   1 
;      1   1   0  |   1   

;
;Note: the Shifter function does not do any output to the console.All the output is done in the main function
;
;Do not access the arrays in main directly in the shifter function. 
;The data must be passed into this function via the required registers.
;
;Do not change the name of the Shifter function.
;
;See additional specifications for the Shifter function on the 
;class web site.
;
;You should use AND, OR and XOR to simulate the shifter circuit.
;
;Note: to flip a single bit use XOR do not use NOT.
;
;You should save any registers whose values change in this function 
;using push and restore them with pop.
;
;The saving of the registers should
;be done at the top of the function and the restoring should be done at
;the bottom of the function.
;
;Note: do not save any registers that return a value (eax).
;
;Each line of this function must be commented and you must use the 
;usual indentation and formating like in the main function.
;
;Don't forget the "ret" instruction at the end of the function
;
;Do not delete this comment block. Every function should have 
;a comment block before it describing the function. FA17


Shifter proc
	push    ebp                     ;save ebp to stack
    mov     ebp, esp				;save stack pointer 
	push	ebx						;push ebx onto stack to save 
	push	ecx						;push ecx onto stack to save

	;startstudent code here
	and		al , cl					;eax and ecx
	xor		cl , 1					;flip ecx
	and		bl , cl					;and ebx ecx
	or		al , bl					;or eax, ebx

	pop		ecx						;restore the value of ecx
	pop		ebx						;restore the value of ebx
	pop		ebp						;restore ebp
	ret
Shifter endp

;************** DspBin - display a Dword in binary including leading zeros
;
;       ENTRY –operand1, the number to print in binary, is on the stack
;
;       For Example if parm1 contained contained AC123h the following would print:
;                00000000000010101100000100100011
;       For Example if parm1 contained 0005h the following would print:
;                00000000000000000000000000000101
;
;       EXIT  - None
;       REGS  - List registers you use
;
; to call DspBin:
;               push 1111000110100b    ;number to print in binary is on the stack
;               call DspBin            ; 00000000000000000001111000110100 should print
;     
;       Note: leading zeros do print
;       Note; at the end of this function use ret 4 (instead of just ret) to remove the parameter from the stack
;                 Do not use add esp, 4 in the main function.
;--------------

    ;You should have a loop that will do the following:
    ;The loop should execute NUM_OF_BITS times(32 times) times so that all binary digits will print including leading 0s.
    ;You should use the NUM_OF_BITS constant as the terminating loop condition and not hard code it.
    
    ;You should start at bit 31 down to and including bit 0 so that the digits will 
    ;   print in the correct order, left to right.
    ;Each iteration of the loop will print one binary digit.

    ;Each time through the loop you should do the following:
    
    ;You should use the BT instruction to copy the bit starting at position 31 to the carry flag 
    ;   then use a rotate command to copy the carry flag to the right end of al.

    ;then convert the 1 or 0 to a character ('1' or '0') and print it with WriteChar.
    ;You should keep processing the number until all 32 bits have been printed from bit 31 to bit 0. 
    
    ;Efficiency counts.

    ;DspBin just prints the raw binary number.

    ;No credit will be given for a solution that uses mul, imul, div or idiv. 
    ;
    ;You should save any registers whose values change in this function 
    ;using push and restore them with pop.
    ;
    ;The saving of the registers should
    ;be done at the top of the function and the restoring should be done at
    ;the bottom of the function.
    ;
    ;Each line of this function must be commented and you must use the 
    ;usual indentation and formating like in the main function.
    ;
    ;Don't forget the "ret 4" instruction at the end of the function
    ;
    ;
    ;Do not delete this comment block. Every function should have 
    ;a comment block before it describing the function. FA17


DspBin proc
	push	ebp
	mov		ebp, esp 

	;start student code here
	mov		ebx, 0				;initialize ebx to 0
	push	ecx					;push ecx onto stack
	mov		ecx, $parm1			;move $parm1 into ecx

loopTop:
	cmp     ebx, NUM_OF_BITS	;compare bx to the total bits of the number
    je      done				;if we have processed all the bits then done
    xor     eax, eax			;clear eax
    bt      ecx, 31				;copy bit in num at position 31 to carry flag
    rcl     eax, 1				;copy carry flag to right end of al
	rol		ecx, 1				;rotate ecx
	or		eax, 00110000b		;change the binary digit into a character
    call    WriteChar			;Print digit to screen
    inc     ebx					;increment counter   
    jmp     loopTop				;repeat
    
done:      
	pop		ecx					;restore ecx
	mov     esp,ebp				;restore stack pointer which removes local byte array
	pop		ebp					;restore ebp
	ret		4

DspBin endp

END Main