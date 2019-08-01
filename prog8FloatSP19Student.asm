;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Wesley Hsieh
;  COMSC-260 Spring 2019
;  Date: 5/12/2019
;  Assignment #8
;  Version of Visual Studio used (2015)(2017):  2017
;  Did program compile? Yes/No : YES 
;  Did program produce correct results? Yes/No: YES 
;  Is code formatted correctly including indentation, spacing and vertical alignment? Yes/No: YES 
;  Is every line of code commented? Yes/No :YES 
;
;  Estimate of time in hours to complete assignment:  8 hours
;
;  In a few words describe the main challenge in writing this program:
;  formatting the output 
;  and just getting used to using fmul/fadd/fidiv 
;  I did for some reason use edx as my offset which caused me to write a few extra 
;  lines of code when doing integer multiplication in order not to have an 
;  infinite loop, which I later realized coudl just be remedied by  using a different reg for the offset
;
;  Short description of what program does:
;  uses fadd/fidiv/fmul to perform a simple expression and print the float to the console
;
; *************************************************************
; Reminder: each assignment should be the result 
;
;  *************************************************************
;  Reminder: each assignment should be the result of your
;  individual effort with no collaboration with other students.
;
;  Reminder: every line of code must be commented and formatted  
;  per the ProgramExpectations.pdf file on the class web site
; *************************************************************

;Due Date: Monday May 13, 11:59pm
;25 points

;NOTE: program will not compile until you define the CD struct below

;You should include kennedyDspFloat.lib and Irvine32.lib in your project
;For examples of using DspFloat see DspFloat.asm

;**************************************************
; This program will evaluate a formula for calculating the compound interest on an investment for a certain number of years.

      ;formula
      ;A = P (1 + r/n)^nt
      ;where
      ;A = ending balance
      ;P = initial principal
      ;r = annual interest rate as a float 5% = 0.05
      ;n = number of compounding periods. Compounded monthly = 12, daily = 365
      ;t = number of years to compound interest

      ;order of operations
      ;1. r/n (float/ int: fidiv)
      ;2. step 1 + 1.0 (float addition: fadd)
      ;3. n * t (integer multiplication: mul)
      ;4. step 2 to the step 3 power (call Power function)
      ;5. P * step 4 



.586      ;identifies minimum CPU for this program

.MODEL flat,stdcall             ;flat - protected mode program
                                ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096                     ;allocate 4096 bytes (1000h) for stack

;*******************MACROS********************************

;NOTE: Use the macros below to print strings, single chars and decimal numbers
;Do not define any other macros.

;mPrtStr will print a zero terminated string to the console
mPrtStr  MACRO  arg1            ;arg1 is replaced by the name of string to be displayed
         push edx               ;save edx
         mov edx, offset arg1   ;address of str to display should be in dx
         call WriteString       ;display 0 terminated string
         pop edx                ;restore edx
ENDM

;mPrtChar will print a single char to the console
mPrtChar MACRO  arg1            ;arg1 is replaced by char to be displayed
         push eax               ;save eax
         mov  al, arg1          ;al = char to display
         call WriteChar         ;display char to console
         pop  eax               ;restore eax
ENDM

;mPrtDec will print a dec number to the console
mPrtDec  MACRO  arg1            ;arg1 is replaced by the name of string to be displayed
         push eax               ;save eax
         mov  eax, arg1         ;eax = dec num to print
         call WriteDec          ;display dec num to console
         pop  eax               ;restore eax
ENDM

;*************************PROTOTYPES*****************************

ExitProcess PROTO,
    dwExitCode:DWORD    ;from Win32 api not Irvine to exit to dos with exit code

ReadChar PROTO          ;Irvine code for getting a single char from keyboard
				        ;Character is stored in the al register.
			            ;Can be used to pause program execution until key is hit.

WriteDec PROTO          ;Irvine code to write number stored in eax
                        ;to console in decimal

WriteString PROTO		;Irvine code to write null-terminated string to output
                        ;EDX points to string

WriteChar PROTO         ;write the character in al to the console

;To call SetFloatPlaces, SetFieldWidth or DspFloat in your program you must first include
;kennedyDspFloat.lib in your project

SetFloatPlaces PROTO    ;sets the number of places a float should round to while printing 
                        ;The default place is 1.
                        ;populate ecx with the number of places to round a floating point num to
                        ;then call SetFloatPlaces.
                        ;If the places to round to  is 2 then 7.466
                        ;would display as 7.47 after calling DspFloat
                        ;The places to round to does not change unless
                        ;you call SetFloatPlaces again.

DspFloat PROTO          ;prints a float in st(0) to the console formatted to a field width and rounding places.
                        ;DspFloat does not pop the floating point stack.

DspFloatP PROTO         ;prints a float in st(0) to the console formatted to a field width and rounding places.
                        ;DspFloat pops the floating point stack.


SetFieldWidth PROTO     ;Set the space a float should occupy when printed.
                        ;Populate ecx with the total space you want want a displayed float to occupy.
                        ;Use this to help right justify a displayed float to line up a column of numbers vertically
                        ;The default field width is 0.
                        ;To change the field width from the default call SetFieldWidth before calling DspFloat.

Power PROTO             ;calculate operand^exponent. Populate st(0) with the operand and ecx with the exponent. Exponent must be an integer.
                        ;result is returned in st(0)

TSeparatorOn proto      ;Print a comma to separate thousands when calling DspFloat or DspFloatP. 10,000.00 will print instead of 10000.00.
                        ;To turn on the thousands separator call TSeparatorOn before calling DspFloat.
                        ;The thousands separator will remain on until TSeparatorOff is called.
                        ;The default is no thousands separator.

TSeparatorOff proto     ;Turn off thousands separator. Since the default is no thousands separator you only need to call TSeparatorOff
                        ;if TSeparatorOn was previously called.
                        ;To turn off the thousands separator call TSeparatorOff before calling DspFloat.

;************************  Constants  ***************************

    LF       equ     0Ah                   ; ASCII Line Feed


;************************  Structs  ***************************

    ;NOTE: before you do anything else you must define the CD struct
    ;as described below.

    ;The CD struct contains information for one CD
    ;
    ;
    ;Define an CD struct with the following data in the following order.
    ;Be sure and align the data.
    ;
    ; principal uninitialized real8
    ; rate uninitialized real8
    ; compoundingPeriods uninitialized dword
    ; period uninitialized dword

CD struct 
	principal				real8 ?
	rate					real8 ?
	compoundingPeriods		dword ?
	period					dword ?
CD ends 

.data

    ;NOTE: do not change the strings below except to add LFs for line spacing
    ;and to change my name to your name.

    heading         byte   "Program 8 by Wesley Hsieh",LF, LF, 0
    heading2        byte   "   PRINCIPAL        RATE    CMP    YEARS   BALANCE",LF,0
    monthly         byte   "     M      ",0
    daily           byte   "     D      ",0
    hundred         real8  100.00
    increment       real8   1.0
    
    ;CDs is an array of CD structs initialized with data
    ;The order in the struct is principal, rate, compounding periods, years
    ;NOTE: Do not change the data in the array.

align real8    ;array of CDs: 
;              principal,  rate, cmpPer, period
        CDs CD{10000.00,   0.05,   12,    10},
              {10000.00,   0.05,  365,    10},
              {10000.00, 0.0675,   12,    10},
              {10000.00, 0.0675,  365,    10}

       TOTAL_SIZE equ sizeof CDs  ;total bytes in CDs array
								  ;24 bytes per struct, 2 real8 = 2 qword == 16, 2 dword = 8

;************************CODE SEGMENT****************************

.code

Main PROC

    ;NOTE: Before compiling this program for the first time you need to define the CD struct as described in the structs section above

    ;Write a main function that will produce output in the form
    ;given in the sample output at the end of this file.

    ;NOTE: this program has no user defined functions.

    ;NOTE: use DspFloatP to print floats
    ;NOTE: use mPrtChar to print single characters like 'M' or 'D'
    ;NOTE: use mPrtStr to print strings
    ;NOTE: use mPrtDec to print decimal numbers
    
    ;Program the following:
	;Before the loop you need to set the thousands separator on, the place rounding to 2 and the field width to 12.
    ;You only need to do this once since it won't change.
    
    ;You should code a while loop similar to the one in structs.asm that will keep going until you have 
    ;processed all the CD structs in the expressions array.
    ;You should use TOTAL_SIZE as the termination condition for the loop in main

    ;Each time through the loop you are to evaluate and print the row for one CD in the format
    ;given the the sample outout at the end of this file.  

    ;For example the first row after the column heading should look as follows:
    ;    10000.00        5.00     M      10    16470.09

    ;In the above 10000.00 is the beginning principal balance, 5.00 is the interest rate, 'M' means the interest is compounded monthly,
    ;10 is the number of years for the interest to accumulate and 16470.09 is the ending balance

    ;The interest rate is stored in the CD struct as a dec fraction that you will have to multiple by 100.00 to get a percent:
    ;for example .05 * 100.00 = 5.00. 
    ;Use the hundred real8 for 100.00.

    ;For the CMP column print 'M' for monthly if the compounding period is 12 otherwise print 'D' for daily (compounding period is 365).

    ;You should use the following formula to calculate the ending balance:

    ;A = P (1 + r/n)^nt

    ;where
    ;A = ending balance
    ;P = initial principal
    ;r = annual interest rate as a float 5% = 0.05
    ;n = number of compounding periods. Compounded monthly = 12, daily = 365
    ;t = number of years to compound interest

    ;You should use the following order of operations
    ;1. r/n (float/ int: fidiv)
    ;2. step 1 + 1.0 (float addition: fadd)(use increment var for 1.0)

    ;3. calculate exponent with n * t (integer multiplication: mul)
    ;4. step 2 to the step 3 exponent (call Power function)(st(0) should already be populated with step 2)(ecx gets exponent from step 3)
    ;5. calculate ending balance P * step 4 
    
    ;Floating point instructions Like fadd, fmul, and fidiv can take on many forms
    ;as to where the operands have to be.

    ;In this program we will be using the ONE OPERAND version of fadd, fmul and fidiv.
    ;which means you should push operand1 onto the floating point stack then execute the floating point math instruction.
    ;(see fadd.asm for an example of pushing data onto the floating point stack)

    ;for example:
    ;
    ;fld operand1
    ;fadd operand2 ;result in st(0)

    ;NOTE: none of the floating point math instructions below pop the stack

    ;fadd operand2 : st(0) = st(0) + operand2
    ;fmul operand2: st(0) = st(0) * operand2 (float * float)
    ;fidiv operand2: st(0) = st(0) / oprand2 (float/ integer)

    ;NOTE: use mul (not fmul) for n * t since both are integers
    ;NOTE: use fidiv for r/n since r is a float and n is an integer
    ;(fidiv converts operand2 to a float then does the division)

    ;After you call any of the above math functions the result should be 
    ;in st(0)

    ;NOTE: you will be graded partly on efficiency which means do not
    ;repeat code unnecessarily and only jump back up in the code to repeat a loop

	;code starts here

	call		TSeparatorOn						;turn the commas on 
	mov			ecx, 2								;move 2 into ecx
	call		SetFloatPlaces						;set rounding to 2 
	mov			ecx, 12								;move 12 into ecx
	call		SetFieldWidth						;set field width to 12

	mPrtStr		heading								;print heading
	mPrtStr		heading2							;print heading2

	mov			ebx, 0								;set offset

loopTop: 
	cmp			ebx, TOTAL_SIZE						;compare ebx to TOTAL_SIZE
	jae			done								;if equal/above, jump to done

	;print the principal
	fld			CDS[ebx].principal					;push CDS[ebx].principal to float stack
	call		DspFloatP							;call DspFloatP
	
	;print the rate
	fld			CDS[ebx].rate						;push CDS[ebx].rate to float stack
	fmul		hundred								;fmul by hundred
	call		DspFloatP							;call DspFloatP

	;figure out whether to print "D" or "M"
	cmp			CDS[ebx].compoundingPeriods,12		;compare CDS[ebx].compoundingPeriods to 12
	je			printMonth							;if equal jump to printMOnth
	mPrtStr		daily								;else print daily
	jmp			endLoop								;jump to endLoop

printMonth:
	mPrtStr		monthly								;print monthly

endLoop:
	;calculate (1+ r/n)
	fld			CDS[ebx].rate						;push CDS[ebx].rate to float stack
	fidiv		CDS[ebx].compoundingPeriods			;fidiv by CDS[ebx].compoundingPeriods
	fadd		increment							;add increment
	
	;calculate n*t
	mov			eax, CDS[ebx].compoundingPeriods	;move CDS[ebx].compoundingPeriods into eax		
	mul			CDS[ebx].period						;integer multipliaction of eax, CDS[ebx].period
	mov			ecx, eax							;move eax into ecx for later use
			
	;calculate (1+rn)^nt
	call		Power								;call Power
	fmul		CDS[ebx].principal					;float multiply st(0) by CDS[edx].principal and 
													;store in st(0)
	;print the period
	mPrtDec		CDS[ebx].period						;call mPrtDec on CDS[edx].period

	;print the ending result
	call		DspFloatP							;print out the result on st(0)

	;increment to next array
	mPrtChar	LF									;print LF	
	add			ebx, 24								;increment by 24
	jmp			loopTop								;jump back to loopTop

done: 
	call    ReadChar								;pause execution
	INVOKE  ExitProcess,0							;exit to dos: like C++ exit(0)

Main ENDP

END Main


;Sample output (Substitute your name for my name)
;Your output should match the output below with a blank line after the title and no more blank lines.

;Program 8 by Fred Kennedy

;   PRINCIPAL        RATE    CMP    YEARS   BALANCE
;   10,000.00        5.00     M      10   16,470.09
;   10,000.00        5.00     D      10   16,486.65
;   10,000.00        6.75     M      10   19,603.22
;   10,000.00        6.75     D      10   19,639.10

;NOTE: to print floats you should use the DspFloatP function.
;NOTE: to print decimal numbers you should use the mPrtDec macro.
;NOTE: to print strings you should use the mPrtStr macro
;NOTE: to print single chars you should use the mPrtChar macro
;
;Submission
;  Email the instructor the following item as an email attachment:  
;
;  prog8FloatSP19Student.asm (use exact file name)
