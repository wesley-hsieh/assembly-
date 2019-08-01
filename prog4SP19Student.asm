;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Wesley Hsieh
;  COMSC-260 Spring 2019
;  Date: 
;  Assignment 
;  Version of Visual Studio used (2015)(2017):  2017
;  Did program compile? Yes/No : YES 
;  Did program produce correct results? Yes/No: YES 
;  Is code formatted correctly including indentation, spacing and vertical alignment? Yes/No: YES 
;  Is every line of code commented? Yes/No :YES 
;
;  Estimate of time in hours to complete assignment:  3 hours
;
;  In a few words describe the main challenge in writing this program:
;
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

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack


;*******************MACROS********************************
mPrtStr  MACRO  arg1			 ;arg1 is replaced by the name of string to be displayed
         push edx
         mov edx, offset arg1    ;address of str to display should be in dx
         call WriteString        ;display 0 terminated string
         pop edx
ENDM

mPrtChar  MACRO  arg1			;arg1 is replaced by the name of character to be displayed
         push eax				;save eax
         mov al, arg1			;character to display should be in al
         call WriteChar			;display character in al
         pop eax				;restore eax
ENDM



;*************************PROTOTYPES*****************************

ExitProcess PROTO,
    dwExitCode:DWORD    ;from Win32 api not Irvine to exit to dos with exit code


WriteDec PROTO          ;Irvine code to write number stored in eax
                        ;to console in decimal

ReadChar PROTO          ;Irvine code for getting a single char from keyboard
				        ;Character is stored in the al register.
			            ;Can be used to pause program execution until key is hit.

WriteChar PROTO         ;write the character in al to the console

WriteString PROTO		;Irvine code to write null-terminated string to output
                        ;EDX points to string

                     
;************************  Constants  ***************************

    LF         equ     0Ah                   ; ASCII Line Feed
    
;************************DATA SEGMENT***************************

.data
    operand1 dword   -2147483600,-2147483648,-2147482612,-5, -2147483648,1062741823,2147483647,2147483547, 0, -94567 ,4352687,-2147483648,-249346713,-678, -2147483643,32125, -2147483648, -2147483648
	operators byte    '-','-', '+','*','*', '*', '+', '%', '/',  '/', '+', '-','/', '%','-','*','/', '+'
	operand2 dword    -200,545,12, 2, -8, 2, 10, -5635, 543,   383, 19786, 150,43981, 115,5,31185,365587,-10
	ARRAY_SIZE    equ     ($ - operand2)
  
	posOF  byte    "+++Positive Overflow Error+++",0
	negOF  byte    "---Negative Overflow Error---",0
	multOF byte    "***Multiplication Overflow***",0

;************************CODE SEGMENT****************************

.code

main PROC

;write code for main function here. See the program specifications
;pdf on the class web site for more info.

mov			esi, 0				;initialize offset

mPrtStr		titleMsg
mPrtStr		dashes
mPrtStr		testingAdderMsg
mPrtStr		dashes


loopTop: 
	
	cmp			esi, ARRAY_SIZE
	jae			loopEnd

	movzx		eax, inputAnum[esi]
	movzx		ebx, inputBnum[esi]
	movzx		ecx, carryInNum[esi]

	;input text
	mPrtStr		inputA
	call		WriteDec

	mPrtStr		inputB
	mov			eax, ebx
	call		WriteDec

	mPrtStr		carryin
	mov			eax, ecx
	call		WriteDec

	movzx		eax, inputAnum[esi]

	call		Adder

	;output text
	mPrtStr		dashes
	mPrtStr		sum
	call		WriteDec

	mPrtStr		carryout
	mov			eax, ecx
	call		WriteDec

	inc			esi

	jmp			loopTop

loopEnd:
	mPrtStr		endingMsg
	call		ReadChar
	invoke		ExitProcess, 0

main ENDP


;************** Adder – Simulate a full Adder circuit  
;  Adder will simulate a full Adder circuit that will add together 
;  3 input bits and output a sum bit and a carry bit
;
;    Each input and output represents one bit.
;
;  Note: do not access the arrays in main directly in the Adder function. 
;        The data must be passed into this function via the required registers below.
;
;       ENTRY - EAX = input bit A 
;               EBX = input bit B
;               ECX = Cin (carry in bit)
;       EXIT  - EAX = sum bit
;               ECX = carry out bit
;       REGS  -  (list registers you use)
;
;       For the inputs in the input columns you should get the 
;       outputs in the output columns below:
;
;        input                  output
;     eax  ebx   ecx   =      eax     ecx
;      A  + B +  Cin   =      Sum     Cout
;      0  + 0 +   0    =       0        0
;      0  + 0 +   1    =       1        0
;      0  + 1 +   0    =       1        0
;      0  + 1 +   1    =       0        1
;      1  + 0 +   0    =       1        0
;      1  + 0 +   1    =       0        1
;      1  + 1 +   0    =       0        1
;      1  + 1 +   1    =       1        1
;
;   Note: the Adder function does not do any output. 
;         All the output is done in the main function.
;
;Do not change the name of the Adder function.
;
;See additional specifications for the Adder function on the 
;class web site.
;
;You should use AND, OR and XOR to simulate the full adder circuit.
;
;You should save any registers whose values change in this function 
;using push and restore them with pop.
;
;The saving of the registers should
;be done at the top of the function and the restoring should be done at
;the bottom of the function.
;
;Note: do not save any registers that return a value (ecx and eax).
;
;Each line of the Adder function must be commented and you must use the 
;usual indentation and formating like in the main function.
;
;Don't forget the "ret" instruction at the end of the function
;
;Do not delete this comment block. SP19 Every function should have 
;a comment block before it describing the function. 


Adder proc
	;Write code for the "Adder" procedure here. 
	push esi		;push the value of esi onto stack to make sure it isn't changed 
	push edx		;push value of edx onto stack

	mov  esi, eax   ;psuedo eax
	xor  eax, ebx   ;a xor b 
	and  esi, ebx	;a and b 
	mov  edx, eax	;placeholder for a xor b 

	xor  eax, ecx	;(a xor b) xor c
	and  ecx, edx	;c and (a xor b)

	or   ecx, esi   ;(c and (a xor b)) or (a and b)

	pop  edx		;restore original edx value
	pop  esi		;restore original esi value (this is the important one)

	ret
Adder endp

END main