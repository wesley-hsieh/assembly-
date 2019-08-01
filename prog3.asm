;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Wesley Hsieh
;  COMSC-260 Spring 2019
;  Date: 3/2/2019
;  Assignment #3
;  Version of Visual Studio used (2015)(2017):  2017
;  Did program compile? Yes/No : YES 
;  Did program produce correct results? Yes/No: YES 
;  Is code formatted correctly including indentation, spacing and vertical alignment? Yes/No: YES 
;  Is every line of code commented? Yes/No :YES 
;
;  Estimate of time in hours to complete assignment:  10 hours
;
;  In a few words describe the main challenge in writing this program:
;  Figuring out the compiling problems took a brunt of the time, but I did not add that time in the 
;  time needed to complete the program
;
;  main difficulties was just outlining the jumps in an orderly manner to make sense 
;  and understanding there's a difference between comparing a register to a character versus a number
;  otherwise I just referenced the files you put on the course website to refresh my memory
;  at how I should do some operations. 
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

;************************ MACROS ***************************

mPrtStr  MACRO  arg1    ;arg1 is replaced by the name of string to be displayed
		 push edx				;save edx
         mov  edx, offset arg1  ;address of str to display should be in edx
         call WriteString       ;display 0 terminated string
         pop  edx				;restore edx
ENDM

;*************************PROTOTYPES*****************************

ExitProcess PROTO,dwExitCode:DWORD ;from Win32 api not Irvine

ReadChar PROTO                     ;Irvine code for getting a single char from keyboard
				                   ;Character is stored in the al register.
			                       ;Can be used to pause program execution until key is hit.


WriteHex PROTO                     ;Irvine function to write a hex number in EAX to the console

WriteString PROTO				   ; write null-terminated string to output, edx points to string

WriteChar PROTO					   ;Irvine code for printing a single char to the console.
								   ;Character to be printed must be in the al register.

MessageBoxA PROTO,      ;MessageBoxA takes 4 parameters:
      handleOwn:DWORD,      ;1. window owner handle
         msgAdd:DWORD,      ;2. message address (zero terminated string)
     captionAdd:DWORD,      ;3. title address(zero terminated string)
        boxType:DWORD       ;4. which button(s) to display

;************************ Constants ***************************

    LF      equ     0Ah                   ; ASCII Line Feed
	CR		equ		0Dh					  ; Carriage Return
	BS		equ		8h					  ; Backspace 

;************************DATA SEGMENT***************************
.data

    OpeningMsg		byte		"Program 3 by Wesley Hsieh", LF, LF, 0
	PromptMsg		byte		"Please input a decimal number with 4 digits of less.", LF, 0
	Prompt2Msg		byte		"(Hit Enter to finish, Backspace to edit)", LF, 0
	Prompt3Msg		byte		"(Illegal decimal digits and digits over 4 ignored).", LF, 0
	RepeatMsg		byte		"Do another?", LF, 0
	WaitMsg			byte		LF, ">", 0
	BackspaceMsg	byte		BS, " ", BS, 0


;************************CODE SEGMENT****************************

.code

main PROC

	mov		eax, 0			    ;eax = 0, just to clear the register of anything

	;Opening Messages
	mPrtStr	OpeningMsg		    ;print "Program 3 by Wesley Hsieh"
	mPrtStr PromptMsg		    ;print first prompt
	mPrtStr Prompt2Msg		    ;print second prompt
	mPrtStr	Prompt3Msg			;print third prompt

	;outer loop

outerLoopTop:
	mPrtStr WaitMsg				;Print ">" to console
	jmp		innerLoopTop		;start inner loop
	mov		ebx, 0				;initialize ebx to 0, ebx will represent the number of valid digits printed
								;initiliazing here is better because you won't have to repeat it anywhere else

innerLoopTop:

	call	ReadChar			;wait for user to input a character

	cmp		al, CR				;compare the inputted char in al to CR (or enter key)
	je		exit				;jump to exit function

	cmp		al, BS				;compare the inputted char in al to BS (or backspace key)
	je		backspace			;jump to backspace function

	cmp		al, "0"				;compare the inputted char in al to the CHARACTER 0 not the number 0
	jb		innerLoopTop		;jump back to innerLoopTop if under the character 0

	cmp		al, "9"				;compare the inputted char in al to the CHARACTER 0 not the number 9
	ja		innerLoopTop		;if the value is above 9, jump back to innerLoopTOp and don't print the char

	cmp		ebx, 4				;compare ebx to 4, ebx being the number of valid digits printed
	jae		innerLoopTop		;if there are 4 or more valid digits printed, jump back to innerLoopTop
	inc		ebx					;else, increment ebx by 1 to keep track of how many valid digits are on the console
	call	WriteChar			;print the digit in al to console
	jmp		innerLoopTop		;jump back to innerLoopTop

backspace:
	cmp		ebx, 0				;compare ebx to 0, ebx being the number of valid digits printedd
	je		innerLoopTop		;if ebx == 0, or no valid numbers printed, jump back to innerLoopTop
	mPrtStr BackspaceMsg		;else, print BackspaceMsg, moving the cursor back one, then rewriting the digit with
								;" " and then moving the cursor back one 
	sub		ebx, 1				;subtract one from ebx to keep track of valid digits printed
	jmp		innerLoopTop		;jump back to innerLoopTop
	
exit:
	cmp		ebx, 0				;compare ebx to 0, ebx being the number of valid digits printed
	je		innerLoopTop		;if ebx == 0, jump back to innerLoopTop
	invoke  MessageBoxA,		;else invoke MessageBoxA, 
					  0,		;no message box owner
		 addr RepeatMsg,		;print "Do another?"
		addr OpeningMsg,		;print "Program 3 by Wesley Hsieh"
					  4			;add options of "yes" or "no" buttons

	cmp		eax, 6				;compare eax to 6, eax being the register that holds the return value from 
								;MessageBoxA, and 6 being the value if the yes button was pressed 
	je		outerLoopTop		;if the "yes" button was pressed, jump to outerLoopTop

	invoke	ExitProcess, 0		;else, the user hit "no" and invoke ExitProcess

main ENDP
END main