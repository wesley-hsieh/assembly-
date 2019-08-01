;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Wesley Hsieh
;  COMSC-260 Spring 2019
;  Date: 2/19/2019
;  Assignment #2
;  Version of Visual Studio used (2015)(2017):  2017
;  Did program compile? Yes/No : YES 
;  Did program produce correct results? Yes/No: YES 
;  Is code formatted correctly including indentation, spacing and vertical alignment? Yes/No: YES 
;  Is every line of code commented? Yes/No :YES 
;
;  Estimate of time in hours to complete assignment:  4 hours
;
;  In a few words describe the main challenge in writing this program:
;  Reviewing the properties of mul/div, LF
;  Understanding when it is not necessary to move things in/out of eax for mul/div, when to zero out edx
;  Finding a calculator online that does hex division as well as give the remainder
;      Windows Calc on programmer mode only gives the quotient to my knowledge
;
;  *************************************************************
;  Reminder: each assignment should be the result of your
;  individual effort with no collaboration with other students.
;
;  Reminder: every line of code must be commented and formatted  
;  per the ProgramExpectations.pdf file on the class web site
; *************************************************************

.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

.STACK 4096            ;allocate 4096 bytes (1000h) for stack

;*************************PROTOTYPES*****************************

ExitProcess PROTO,dwExitCode:DWORD ;from Win32 api not Irvine

ReadChar PROTO                     ;Irvine code for getting a single char from keyboard
				                   ;Character is stored in the al register.
			                       ;Can be used to pause program execution until key is hit.


WriteHex PROTO                     ;Irvine function to write a hex number in EAX to the console

WriteString PROTO				   ; write null-terminated string to output, edx points to string

WriteChar PROTO					   ;Irvine code for printing a single char to the console.
								   ;Character to be printed must be in the al register.

;************************ Constants ***************************

    LF      equ     0Ah                   ; ASCII Line Feed


;************************DATA SEGMENT***************************

.data

    num1		dword   0CB7FB84h
    num2		dword   0FFDD2547h
	num3		dword	0C57h
	num4		dword	05A9h
	num5		dword	0B46Bh
	num6		dword	0D3494h
	num7		dword	01F514ABCh
	num8		dword   0AAAAFFFFh ;placeholder for answer

	NameMsg     byte    "Program 2 by Wesley Hsieh", LF, LF, 0
	ExitMsg     byte    "Hit any key to exit!", LF, LF, 0
	HPlus		byte	"h+", 0
	HDivide		byte	"h/(", 0
	HMul		byte	"h*", 0
	HMinus		byte	"h)-", 0 
	HPower		byte	"h^2%", 0 
	HEqual		byte	"h=", 0 


;************************CODE SEGMENT****************************

.code

main PROC

    mov  ebx,  0BBBBFFFFh    ;ebx = 0BBBBFFFFh
    mov  eax,  0AAAAFFFFh    ;eax = 0AAAAFFFFh
    mov  ecx,  0CCCCFFFFh    ;ecx = 0CCCCFFFFh 
	mov  edx,  0F5C8DEEDh    ;edx = 0F5C8DEEDh

	;num1 + num2 / (num3 * num4) - num5^2 % num6 + num7
	;1. num5^2 (num5 squared)
	;2. num3 * num4
	;3. num2 / result from step 2 (quotient in eax)
	;4. result from step 1 % num 6 (Remainder is in edx after div)
	;5. num1+ result from step 3
	;6. result from step 5- result from step 4
	;7. result from step 6 + num7

	mov  edx,  offset NameMsg		;transfer address of NameMsg to edx
	call WriteString				;print string 

	;1. num5^2 (num5 squared)
	mov  eax,  num5					;Move num5 to eax
	mul  num5						;num5*num5
	mov  ebx,  eax					;Since we are going to be using eax again for multiplying
									;Move the value in eax to ebx
									;num5^2 = 07F26A4B9h

	;2. num3 * num4
	mov  eax,  num3					;Move num3 to eax
	mul  num4						;num3*num4
	mov  ecx,  eax					;Move value in eax which is num3*num4 into ecx
									;Num3*num4 = 045D86Fh

	;3. num2 / result from step 2 (quotient in eax)
	mov  eax,  num2					;move num2 to eax 
	div  ecx						;num2/ (num3*num4)
	mov  esi,  eax					;Move value in eax to esi, the value is num2/(num3*num4)
									;num2/(num3*num4) = 000003A9h

	;4. result from step 1 % num 6 (Remainder is in edx after div)
	mov  eax,  ebx					;move the value in num5 (num5^2) to eax
	mov  edx,  0					;zero out edx as there are may be remainders from the last division/mul
	div  num6						;num5^2/num6 = 9A0 r C9439

	;5. num1+ result from step 3
	mov  eax,  num1					;move num1 to ebx
	add  eax,  esi					;eax + num2 = CB7FF2Dh
	
	;6. result from step 5- result from step 4
	sub  eax,  edx					;eax - edx =  CAB6AF4h

	;7. result from step 6 + num7
	add  eax,  num7					;eax + num7  = 2BFCB5B0h
	mov  num8, eax					;store value for later printing

	;printing equation and answer
	;num1 + num2 / (num3 * num4) - num5^2 % num6 + num7

	mov  eax,  num1					;move num1 to eax
	call WriteHex					;print num1
	mov  edx,  offset HPlus			;move address of HPlus to edx
	call WriteString				;print "h+"

	mov  eax,  num2					;move num2 to eax
	call WriteHex					;print num2
	mov  edx,  offset HDivide		;move address of HDivide to edx
	call WriteString				;print "h/("

	mov  eax,  num3					;move num3 to eax
	call WriteHex					;print num3
	mov  edx,  offset HMul			;move address of HMul to edx
	call WriteString				;print "h*"

	mov  eax,  num4					;move num4 to eax
	call WriteHex					;print num4
	mov  edx,  offset HMinus		;move address of HMinus ot edx
	call WriteString				;print "h)-"

	mov  eax,  num5					;move num5 to eax
	call WriteHex					;print num5
	mov  edx,  offset HPower		;move address of HPower to edx
	call WriteString				;print "h^2%"

	mov  eax,  num6					;move num6 to eax	
	call WriteHex					;print num6
	mov  edx,  offset HPlus			;move address of HPlus to edx
	call WriteString				;print "h+"

	mov  eax,  num7					;move num7 to eax
	call WriteHex					;print num7
	mov  edx,  offset HEqual		;move address of HEqual to edx
	call WriteString				;print "h="

	mov  eax,  num8					;move num8(or final answer) to eax
	call WriteHex					;print eax
	mov  al,  'h'					;move 'h' to al register
	call WriteChar					;print 'h'
	

	mov  al,   LF					;move LF to al
	call WriteChar					;print two LF as one ends the line one creates the blank line
	call WriteChar

	mov  edx,  offset ExitMsg		;move address of ExitMsg to edx
	call WriteString				;print ExitMsg

    call    ReadChar           ; Pause program execution while user inputs a non-displayed char
	INVOKE	ExitProcess,0      ;exit to dos: like C++ exit(0)

main ENDP
END main