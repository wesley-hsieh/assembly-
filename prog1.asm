;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Wesley Hsieh
;  COMSC-260 Spring 2019
;  Date: 2/11/2019
;  Assignment #2
;  Version of Visual Studio used (2015)(2017):  2017
;  Did program compile? Yes/No : YES 
;  Did program produce correct results? Yes/No: YES 
;  Is code formatted correctly including indentation, spacing and vertical alignment? Yes/No: YES 
;  Is every line of code commented? Yes/No :YES 
;
;  Estimate of time in hours to complete assignment:  3-4 hours
;
;  In a few words describe the main challenge in writing this program:
;  
;  Short description of what program does:
;  utilizes various registers and basic assembly functions to add/sub/mul/div decimal/hexadecimal/binary values
;
;
;  *************************************************************
;  Reminder: each assignment should be the result of your
;  individual effort with no collaboration with other students.
;
;  Reminder: every line of code must be commented and formatted  
;  per the ProgramExpectations.pdf file on the class web site
; *************************************************************;

.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

.STACK 4096            ;allocate 4096 bytes (1000h) for stack

;*************************PROTOTYPES*****************************

ExitProcess PROTO,dwExitCode:DWORD  ;from Win32 api not Irvine

ReadChar PROTO                     ;Irvine code for getting a single char from keyboard
				                   ;Character is stored in the al register.
			                       ;Can be used to pause program execution until key is hit.


WriteHex PROTO                     ;Irvine function to write a hex number in EAX to the console


;************************DATA SEGMENT***************************

.data

    num1    word   123h
    num2    word   0FEDCh

;************************CODE SEGMENT****************************

.code

main PROC

    mov     ebx, 0BBBBFFFFh    ;ebx = 0BBBBFFFFh
    mov     eax, 0AAAAFFFFh    ;eax = 0AAAAFFFFh
    mov     ecx, 0CCCCFFFFh    ;ecx = 0CCCCFFFFh 
	mov     edx, 0F5C8DEEDh    ;edx = 0F5C8DEEDh
	mov     bh, 11110110b      ;bh = 11110110b
	mov		bl, 253d		   ;bl = 253d
    mov		cx, 0FFB9h		   ;cx = 0FFB9h

	;num1 + num2 / (num3 * num4) - num5^2 % num6 + num7
	;can use esi edi registers 

	movzx esi, num2			   ; move the data in num2 to register esi and zero out the top portion
	movzx edi, num1            ; move the data in num1 to register edi and zero out the top portion
	sub esi, edi              ; esi - edi = num2 - num1
	
	movzx edi, cx              ; move cx to di and zero out the top portion 
	add esi, edi               ; esi + edi

	movzx edi, bl              ; move bl to di and zero out the top portion 
	sub esi, edi               ; esi - edi 

	movzx edi, bh              ; move bh to edi and zero out the top portion
	add esi, edi               ; esi + di 

	add esi, edx               ; esi + edx

	mov eax, esi               ; move the final answer to register eax to be displayed 
	
	call WriteHex			   ;print eax to console (should be F5CADC58)
	

    call    ReadChar           ; Pause program execution while user inputs a non-displayed char
	INVOKE	ExitProcess,0      ;exit to dos: like C++ exit(0)

main ENDP
END main