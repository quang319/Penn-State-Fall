**********************************************************************************
*
* Title:        SCI program
*
* Objective:    CSE472 Homework 7
*
* Revision:     V1.0
*
* Date:         10/12/2015
*
* Programmer:   Quang Nguyen
*
* Company:      PSU CMPEN472
*
* Purpose:      To use the SCI interface to use the microcontroller as a calculator. Below are restrictions regarding the inputs
*                       - Inputs must be positive decimal number
*                       - Input must have a maximum of 3 digits
*                       - Valid operators are: +,-,*, and /
*                       - Only 2 operands and one operator are allow. Spaces may not be used

*
* Register use: 
*               D,X,Y
*
* Memory use:   RAM Locations from $3000 for data 
*                                  $3100 for program
*
* Input:        Parameters hard coded in the program.
*
* Output:       SCI outputs
*
* Observation:  
*
* Note:         N/A
*
* Comments:     This program is developed and simulated using Codewarrior development software
*               and targeted for Axion Manufacturing's APS12C128 board (CSM-12C128)
*               board running at 24MHz bus clock. The program was also tested on the targeted 
*               board.
*
***********************************************************************************************
*
* Parameter Declearation section
*
* Export Symbols
                  XDEF          pgstart         ; export 'pgstart' symbol
                  ABSENTRY      pgstart         ; FOR assembly entry point

* Symbols and macros
*
PORTA             EQU         $0000             ; I/O port addresses (port A not used)
DDRA              EQU         $0002             

PORTB             EQU         $0001             ; Port B is connected with LEDs
DDRB              EQU         $0003             
PUCR              EQU         $000C             ; to enable pull0up mode for PORT A, B, E, K

EQUAL             EQU         $3D
SPACE             EQU         $20
DOLLAR            EQU         $24
NULL              EQU         $00
CR                EQU         $0D 
LF                EQU         $0A
*********** Registers for SCI Configuration *****
SCIDRH            EQU         $00cE  
SCIDRL            EQU         $00cf             
SCISR1            EQU         $00cc             ; SCI Status Reg 1
            **** bits of SCISR1 *****
TDRE              EQU         $80
TC                EQU         $40
RDRF              EQU         $20







***********************************************************
* Data Section
*
                  ORG         $3000             ; reserve RAM memory starting addresses 
                                                ; memory $3000 to $30FF are for data
testing           dc.b        14

MsgQueue          DC.B        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   ; Queue to store the user inputs
MsgQueuePointer   Dc.w        $0000             ; Pointer to keep track of where we are in the queue
OutputQueue       Dc.b        32,32,32,32,32,32,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   ; queue to store the output message 
OutputQueuePointer Dc.b       $00
FlgTypeWrite      dc.b        $00               ; Flag for the typewriter program 
                                                ; 0 = normal program , 1 = typewriter program
MsgInvalidInput   DC.b        'Invalid Input. Please try again.',$00
VarOperand1       dc.w        $00               ; variable use to store the value of operand 1
VarOperand2       dc.w        $00               ; variable use to store the value of operand 2
Operator          dc.b        $00               ; variable use to store the value of the operator
TypeOfErrorFlag   dc.b        $00               ; 0 = InvalidFormat , 1 = Overflow
NegativeFlag      dc.b        $00               ; If one then should put a negative sign onto the screen


StackSP                                         ; remaining memory space for stack data
                                                ; initial stack pointer position set
                                                ; to $3100 (pgstart)

*
************************************************************
* Program Section
*
                  org         $3100             ; Program start address, in RAM
pgstart           lds         #pgstart          ; initialize the stack pointer
                  

                  ldaa        #%11110000        ; set PORTB bit 7,6,5,4,as output. 3,2,1,0 as input
                  staa        DDRB              ; Led 1,2,3,4 on PORTB bit 0,1,2,3.
                                                ;     DIP switch 1,2,3,4 on the bits 0,1,2,3.
                  ldaa        #$f0              ; keep all leds off to begin with
                  staa        PORTB    


                  ldx         #MsgIntro1        ; Print the introduction messages
                  jsr         printmsg
                  
                  ldx         #MsgIntro2        
                  jsr         printmsg

                  ldx         #MsgIntro3        
                  jsr         printmsg

                  ldx         #Ecalc        
                  jsr         printmsg

                  ldd         #MsgQueue         ; initialize the MsgQueuePointer to the address of the MsgQueue
                  std         MsgQueuePointer

loop 
                  jsr         getchar           ; type writer - check the key board
                  cmpa        #$00              ;  if nothing typed, keep checking
                  beq         loop

                  jsr         putchar           ; is displayed on the terminal window
                  jsr         OperateOnInput    ; This is where we perform the majority of the program
                  Bra         loop

                  

                  bra         loop


*************************************************************************
*
* Subroutine Section
*


************************************************************************
*
* Name:           OperateOnInput
*
* Fuction:        this subroutine takes in the user's input in RegA and output the proper result
*                 Below are restrictions that the function will impose
*                       - Inputs must be positive decimal number
*                       - Input must have a maximum of 3 digits
*                       - Valid operators are: +,-,*, and /
*                       - Only 2 operands and one operator are allow. Spaces may not be used                      
*
*
* Parameters:     - RegA: this contains the user's input
*
* Registers Used: - RegD and RegX
*
*
*************************************************************************
OperateOnInput
                  pshx
                  pshd
                  ; At this point, RegA contains the newest character
                  ; If (RegA == CR)
                  cmpa        #13
                  lbne         OperateOnInput_NotEqualCR

                  ; Moving the cursor to the next line
                  ldaa        #LF               ; cursor to next line
            
                  jsr         putchar

                  ; Get Operand1 
                  ldx         #MsgQueue 
                  ldaa        #1
                  jsr         CalculatorConverter
                  ; If invalid print until invalid character 
                  cmpa        #0
                  lbeq         OperateOnInput_InvalidInput

                  ldaa        #2
                  jsr         CalculatorConverter
                  ; If invalid print until invalid character 
                  cmpa        #0
                  lbeq         OperateOnInput_InvalidInput

                  ldaa        #4
                  jsr         CalculatorConverter
                  ; If invalid print until invalid character 
                  cmpa        #0
                  lbeq         OperateOnInput_InvalidInput

                  ; Check if this is the end of the queue, if not then the rest of the queue is invalid 
                  tfr         x,d 
                  subd        MsgQueuePointer
                  beq         OperateOnInput_Calculate
                  lbra        OperateOnInput_InvalidInput

OperateOnInput_Calculate
                  ; Load the output queue with everything minus the result 
                  ldx         #MsgQueue 
                  ; message queue needs to be the queue address + 7 
                  ldd         #OutputQueue
                  addd        #7
                  tfr         d,y

OperateOnInput_Calculate_QueueLoop
                  ; Loop through and copy the MsgQueue onto the OutputQueue
                  ldab         1,x+ 
                  stab         1,y+

                  tfr         x,d 
                  subd        MsgQueuePointer 
                  bne         OperateOnInput_Calculate_QueueLoop


                  ; Check if we need to do '+'
                  ldaa        #'+'
                  cmpa        Operator
                  bne         OperateOnInput_Calculate_Sub

                  ldd         VarOperand1
                  addd        VarOperand2

OperateOnInput_Calculate_Add_Output
                  ; Now load the output onto the OutputQueue
                  pshd
                  ldab        #'='
                  stab        1,y+
                  ; check if we need to put a negative to the scree 
                  brclr       NegativeFlag,1,OperateOnInput_Calculate_Add_Output_NoNegative
                  ldab        #'-'
                  stab        1,y+
OperateOnInput_Calculate_Add_Output_NoNegative
                  puld
                  pshy 
                  jsr         CvrtBinToASCIIDec
                  pshb
                  psha
                  pshx
                  tfr         y,d 
                  ; load the address the position of the output queue back out 
                  ldx         4,sp 
                  ; Test if it is zero. We don't need to print zeros
                  cmpb        #$30
                  beq         OperateOnInput_Calculate_Add_Thoundsandth
                  stab        1,x+
                  puld 
                  staa        1,x+
                  stab        1,x+
                  puld
                  staa        1,x+
                  stab        1,x+
                  puld
                  lbra         OperateOnInput_ResetAfterCR

OperateOnInput_Calculate_Add_Thoundsandth
                  ; Prevent leading zeros
                  puld        
                  cmpa        #$30
                  beq         OperateOnInput_Calculate_Add_Hundreth
                  staa        1,x+
                  stab        1,x+
                  puld
                  staa        1,x+
                  stab        1,x+
                  puld
                  lbra         OperateOnInput_ResetAfterCR

OperateOnInput_Calculate_Add_Hundreth 
                  ; Prevent leading zeros
                  cmpb        #$30
                  beq         OperateOnInput_Calculate_Add_Tenth
                  stab        1,x+
                  puld
                  staa        1,x+
                  stab        1,x+
                  puld
                  lbra         OperateOnInput_ResetAfterCR

OperateOnInput_Calculate_Add_Tenth
                  ; Prevent leading zeros
                  puld        
                  cmpa        #$30
                  beq         OperateOnInput_Calculate_Add_Oneth
                  staa        1,x+
                  stab        1,x+
                  puld
                  lbra        OperateOnInput_ResetAfterCR

OperateOnInput_Calculate_Add_Oneth       
                  stab        1,x+
                  puld 

                  lbra         OperateOnInput_ResetAfterCR


OperateOnInput_Calculate_Sub
                  ; If we have to do subtraction
                  ldaa        #'-'
                  cmpa        Operator 
                  bne         OperateOnInput_Calculate_Mult
                  ; perform the subtraction
                  ldd         VarOperand1
                  subd        VarOperand2
                  bge         OperateOnInput_Calculate_Add_Output

                  ; If if the result is negative, set the NegativeFlag
                  pshd  
                  ldaa        #1
                  staa        NegativeFlag
                  puld 
                  eora        #$ff 
                  eorb        #$ff 
                  addd        #1
                  std         VarOperand2
                  ldd         VarOperand2

                  lbra         OperateOnInput_Calculate_Add_Output



OperateOnInput_Calculate_Mult
                  ; If we have to perform multiplication
                  ldaa        #'*'
                  cmpa        Operator 
                  bne         OperateOnInput_Calculate_Div

                  pshy
                  ldd         VarOperand1
                  ldy         VarOperand2
                  emul
                  ; Check if the upper half is zero 
                  cpy         #0
                  bne         OperateOnInput_Calculate_Mult_Overflow
                  ; the lower half should be less than than 2^15 -1 
                  cpd         #$7fff
                  bgt         OperateOnInput_Calculate_Mult_Overflow
                  puly
                  std         VarOperand2

                  lbra         OperateOnInput_Calculate_Add_Output

OperateOnInput_Calculate_Mult_Overflow
                  ; Overflow handler
                  puly
                  ldaa        #1
                  staa        TypeOfErrorFlag
                  lbra        OperateOnInput_InvalidInput

OperateOnInput_Calculate_Div
                  ; If we have to perform division
                  pshx
                  ldd         VarOperand1
                  ldx         VarOperand2
                  idiv
                  tfr         x,d
                  pulx
                  std         VarOperand2

                  lbra         OperateOnInput_Calculate_Add_Output


OperateOnInput_InvalidInput   
                  pshx
                  ; Load the output queue with everything minus the result 
                  ldx         #MsgQueue 
                  ; message queue needs to be the queue address + 7 
                  ldd         #OutputQueue
                  addd        #7
                  tfr         d,y

OperateOnInput_InvalidInput_QueueLoop
                  ; Copy the MsgQueue to the OutputQueue
                  ldab        1,x+ 
                  stab        1,y+
                  tfr         x,d
                  ; We only want to print until where the invalid format was 
                  subd        sp 
                  lbls         OperateOnInput_InvalidInput_QueueLoop
                  pulx

                  ; Printing the OutputQueue
                  ldx         #OutputQueue        
                  jsr         printmsg
                  ldaa        #CR 
                  jsr         putchar
                  ldaa        #LF 
                  jsr         putchar

                  ; Check the flag to see what kind of error we have
                  brset       TypeOfErrorFlag,1,OperateOnInput_InvalidInput_Overflow
                  ; Print the InvalidFormat string
                  ldx         #InvalidFormat 
                  jsr         printmsg

                  lbra        OperateOnInput_ResetAfterCR_Ecalc
                  ;
OperateOnInput_InvalidInput_Overflow
                  ;Print the overflow string 
                  ldx         #OverflowError 
                  jsr         printmsg

                  lbra        OperateOnInput_ResetAfterCR_Ecalc


OperateOnInput_ResetAfterCR                     ; clearing MsgQueue and MsgQueuePointer
                  
                  ; Printing the OutputQueue
                  ldx         #OutputQueue        
                  jsr         printmsg
                  ldaa        #CR 
                  jsr         putchar
                  ldaa        #LF 
                  jsr         putchar

OperateOnInput_ResetAfterCR_Ecalc

                  ; Print the Ecalc> on the screen 
                  ldx         #Ecalc 
                  jsr         printmsg

                  ; Clearing the MsgQueue
                  ldd         #MsgQueue
                  addd        #15
                  pshd
                  
                  ldy         #MsgQueue

OperateOnInput_ResetAfterCR_MsgQueueLoop
                  ldab        #0 
                  stab        1,y+
                  tfr         y,d 
                  subd        sp 
                  lbls         OperateOnInput_ResetAfterCR_MsgQueueLoop
                  puld

                  ; Clearing the OutputQueue
                  ldd         #OutputQueue
                  addd        #22
                  pshd
                  ; message queue needs to be the queue address + 7 
                  ldd         #OutputQueue
                  addd        #7
                  tfr         d,y

OperateOnInput_ResetAfterCR_OutputQueueLoop
                  ldab        #0 
                  stab        1,y+
                  tfr         y,d 
                  subd        sp 
                  lbls        OperateOnInput_ResetAfterCR_OutputQueueLoop
                  puld
                  
                  ; Clear all the global variables
                  ldd         #MsgQueue
                  std         MsgQueuePointer 
                  ldd         #0
                  std         VarOperand1
                  std         VarOperand2
                  staa        Operator 
                  staa        TypeOfErrorFlag
                  staa        NegativeFlag
                  bra         OperateOnInput_EndOfSR

OperateOnInput_NotEqualCR
                  
                  ; If the input wasn't a CR then we can just save it
                  ldx         MsgQueuePointer
                  staa        x
                  inx 
                  stx         MsgQueuePointer
                  lbra        OperateOnInput_EndOfSR  
                  ;     else 

                  
                  ; return from subroutine   
OperateOnInput_EndOfSR  
                  puld
                  pulx
                  rts




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Function: This function acts as a state machine. The current state of it is set by regA. On Operand1 and Operand2 state 
;           it will convert the queue referenced by RegX to the proper VarOperand1 or VarOperand2 variables. 
;           On Operator state, it will check to ensure that the operator is one of the 4 allowable operators. 
;
; Inputs: 
;           REgX : The address of the queue of ASCII char that the function should operate on 
;           RegA : Flags registers
;                 - 1st bit = First operand state
;                 - 2nd bit = Operator State 
;                 - 3nd bit = Second operator State
; Outputs:
;           RegY : The result of the operation. 16 bit number if it was in operator1 or operator2 state
;                       - The value of the ASCII char - $30 if it is an operator
;           RegA : Flag registers 
;                 - 1st bit  = 1 if the result was successful. 0 if an invalid input was found
;           RegX : 
;                 - This points to the address of the invalid char if the result was invalid 
;                 - This points to the address of the last conversion
CalculatorConverter
                  pshx
                  psha
                  ; Check if we are on 1st operand state
                  cmpa        #2
                  lbeq         CalculatorConverter_Opter
                  cmpa        #4
                  lbeq         CalculatorConverter_Opnd2
CalculatorConverter_Opnd1
                  ldab        x
                  jsr         CvrtASCIIDecToBin
                  ; check if the operand is valid or not 
                  cmpb        #$FF 
                  beq         CalculatorConverter_Opnd1_test

                  ; Test if this is the 100th place. If so multiply by 100 and add to y
                  pshb  
                  tfr         x,d
                  subd        2,sp
                  bne         CalculatorConverter_Opnd1_10th
                  ldaa        #100
                  pulb
                  mul 
                  addd        VarOperand1
                  std         VarOperand1
                  inx         
                  bra         CalculatorConverter_Opnd1
                  ; Test if this is the 10th place. If so multiply by 10 and add to y
CalculatorConverter_Opnd1_10th
                  cpd         #1
                  bne         CalculatorConverter_Opnd1_1th
                  ldaa        #10
                  pulb
                  mul 
                  addd        VarOperand1
                  std         VarOperand1
                  inx         
                  bra         CalculatorConverter_Opnd1
CalculatorConverter_Opnd1_1th
                  pulb
                  clra        
                  addd        VarOperand1
                  std         VarOperand1
                  inx         
                  lbra         CalculatorConverter_Done


CalculatorConverter_Opnd1_test    
                  ; if Operand1 is 0 than this means that this is an invalid input
                  ; If Operand1 != 0 then this must means that this is an operator 
                  ldd         VarOperand1
                  cpd         #0
                  lbeq         CalculatorConverter_Invalid

                  tfr         x,d
                  subd        1,sp
                  cpd         #2
                  beq         CalculatorConverter_Opnd1_test_div10th
                  cpd         #1
                  beq         CalculatorConverter_Opnd1_test_div100th

                  lbra         CalculatorConverter_Done
CalculatorConverter_Opnd1_test_div10th
                  pshx 
                  ldd         VarOperand1 
                  ldx         #10
                  idiv
                  stx         VarOperand1
                  pulx 
                  lbra         CalculatorConverter_Done
CalculatorConverter_Opnd1_test_div100th
                  pshx 
                  ldd         VarOperand1 
                  ldx         #100
                  idiv
                  stx         VarOperand1
                  pulx 
                  lbra         CalculatorConverter_Done


                  ; Verify that the operator is valid
CalculatorConverter_Opter
                  ldab        x 
                  cmpb        #'+'
                  beq         CalculatorConverter_Opter_Valid
                  cmpb        #'-'
                  beq         CalculatorConverter_Opter_Valid
                  cmpb        #'*'
                  beq         CalculatorConverter_Opter_Valid
                  cmpb        #'/'
                  beq         CalculatorConverter_Opter_Valid
                  bra         CalculatorConverter_Invalid
CalculatorConverter_Opter_Valid
                  stab        Operator
                  inx
                  bra         CalculatorConverter_Done

                  ; Operand2 state
CalculatorConverter_Opnd2
                  ldab        x
                  jsr         CvrtASCIIDecToBin
                  ; check if the operand is valid or not 
                  cmpb        #$FF 
                  beq         CalculatorConverter_Opnd2_test

                  ; Test if this is the 100th place. If so multiply by 100 and add to y
                  pshb  
                  tfr         x,d
                  subd        2,sp
                  bne         CalculatorConverter_Opnd2_10th
                  ldaa        #100
                  pulb
                  mul 
                  addd        VarOperand2
                  std         VarOperand2
                  inx         
                  bra         CalculatorConverter_Opnd2
                  ; Test if this is the 10th place. If so multiply by 10 and add to y
CalculatorConverter_Opnd2_10th
                  cpd         #1
                  bne         CalculatorConverter_Opnd2_1th
                  ldaa        #10
                  pulb
                  mul 
                  addd        VarOperand2
                  std         VarOperand2
                  inx         
                  bra         CalculatorConverter_Opnd2
CalculatorConverter_Opnd2_1th
                  pulb
                  clra        
                  addd        VarOperand2
                  std         VarOperand2
                  inx         
                  bra         CalculatorConverter_Done

CalculatorConverter_Opnd2_test
                  ; if Operand2 is 0 than this means that this is an invalid input
                  ; If Operand2 != 0 then this must means that this is an operator 
                  ldd         VarOperand2
                  cpd         #0
                  lbeq         CalculatorConverter_Invalid


                  tfr         x,d
                  subd        1,sp
                  cpd         #2
                  beq         CalculatorConverter_Opnd2_test_div10th
                  cpd         #1
                  beq         CalculatorConverter_Opnd2_test_div100th

                  bra         CalculatorConverter_Done
CalculatorConverter_Opnd2_test_div10th
                  pshx 
                  ldd         VarOperand2 
                  ldx         #10
                  idiv
                  stx         VarOperand2
                  pulx 
                  bra         CalculatorConverter_Done
CalculatorConverter_Opnd2_test_div100th
                  pshx 
                  ldd         VarOperand2 
                  ldx         #100
                  idiv
                  stx         VarOperand2
                  pulx 
                  bra         CalculatorConverter_Done




CalculatorConverter_Invalid
                  ldaa        #0
                  ldab        3,sp+
                  rts

CalculatorConverter_Done
                  ldaa        #1
                  ldab        3,sp+
                  rts 



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Input:    RegB: The ascii Dec 
; Output:   RegB: The binary output of the decimal or 0xFF if the result is not
CvrtASCIIDecToBin 
                  subb        #$30
                  ; Test if the answer is greater than or equal to 10
                  cmpb        #10
                  bhs         CvrtASCIIDecToBin_NotBin
                  rts 
CvrtASCIIDecToBin_NotBin
                  ldab        #$FF
                  rts 

; Inputs: Top 2 block in RegX and the last block in RegB
; Output: The binary representation on RegB
CvrtASCIIDecStringToBin

                  pshx

                  ; Convert the smallest block to binary
                  subb        #$30
                  pshb                          ; push B

                  ; Convert the second smallest block to binary
                  ; Multiply the result by 10 because is it the tenth place
                  ldab        2,sp 
                  subb        #$30
                  ldaa        #10
                  mul
                  pshb                          ; The lower part of the Multiply is in RegB

                  ; Convert the largest block to binary
                  ; Multiply the result by 100 because it is the Hundreth place 
                  ldab        2,sp 
                  subb        #$30
                  ldaa        #100
                  mul

                  ; Now we just need to add all the results together
                  addb        sp
                  addb        1,sp

                  ldaa        4,sp+

                  rts

; Result = Regb(oneth place), RegA(tenth place), RegX(hundreth place), RegY(thousandth place)
CvrtBinToASCIIDec
                  ; Get the value for the ten thousandth place        
                  ldx         #10000
                  idiv
                  pshd
                  ldab        #$30
                  abx
                  puld
                  pshx
                  ; Get the value for the thousandth place 
                  ldx         #1000
                  idiv
                  pshd
                  ldab        #$30
                  abx
                  puld
                  pshx
                  ; Get the value for the Hundreth place 
                  ldx         #100
                  idiv
                  pshd
                  ldab        #$30
                  abx
                  puld
                  pshx
                  ; Get the value for the tenth place 
                  ldx         #10
                  idiv
                  pshd
                  ldab        #$30
                  abx
                  puld
                  pshx
                  ; Get the value for the oneth place
                  addb        #$30
                  pulx 
                  tfr         x,a 
                  pshd
                  ldd         2,sp 
                  ldx         4,sp
                  tfr         x,a
                  tfr         d,x
                  puld
                  puly   
                  puly     
                  puly
                  rts 




;***********printmsg***************************
;* Program: Output character string to SCI port, print message
;* Input:   Register X points to ASCII characters in memory
;* Output:  message printed on the terminal connected to SCI port
;* 
;* Registers modified: CCR
;* Algorithm:
;     Pick up 1 byte from memory where X register is pointing
;     Send it out to SCI port
;     Update X register to point to the next byte
;     Repeat until the byte data $00 is encountered
;       (String is terminated with NULL=$00)
;**********************************************
printmsg
                  pshd
                  pshy
                  pshx                          ; save registers

printmsg_Loop     ldaa        1,x+
                  cmpa        #NULL
                  beq         printmsg_EndOfMsg
                  jsr         putchar
                  bra         printmsg_Loop

printmsg_EndOfMsg
                  pulx
                  puly                          ; return registers to previous values
                  puld
                  rts 

;***************putchar************************
;* Program: Send one character to SCI port, terminal
;* Input:   Accumulator A contains an ASCII character, 8bit
;* Output:  Send one character to SCI port, terminal
;* Registers modified: CCR
;* Algorithm:
;    Wait for transmit buffer become empty
;      Transmit buffer empty is indicated by TDRE bit
;      TDRE = 1 : empty - Transmit Data Register Empty, ready to transmit
;      TDRE = 0 : not empty, transmission in progress
;**********************************************
putchar
                  brclr       SCISR1,#TDRE,putchar
                  staa        SCIDRL
                  rts 

;****************getchar***********************
;* Program: Input one character from SCI port (terminal/keyboard)
;*             if a character is received, other wise return NULL
;* Input:   none    
;* Output:  Accumulator A containing the received ASCII character
;*          if a character is received.
;*          Otherwise Accumulator A will contain a NULL character, $00.
;* Registers modified: CCR
;* Algorithm:
;    Check for receive buffer become full
;      Receive buffer full is indicated by RDRF bit
;      RDRF = 1 : full - Receive Data Register Full, 1 byte received
;      RDRF = 0 : not full, 0 byte received
;**********************************************
getchar
                  brclr       SCISR1,#RDRF, getchar_NoInput
                  ldaa        SCIDRL
                  rts 
getchar_NoInput   ldaa        #0
                  rts         


;OPTIONAL
;more variable/data section below
; this is after the program code section
; of the RAM.  RAM ends at $3FFF
; in MC9S12C128 chip

MsgIntro1         dc.b        'Welcome! You are entering a program that will use the HC12 as a calculator.',CR,LF,'Operand inputs must be positive decimal numbers and have maximum of 3 digits limit.',CR,LF,NULL
MsgIntro2         dc.b        'Leading zeros are valid inputs, but spaces are not allowable.',CR,LF,'The four valid operators are: +,-,*, and /',CR,LF,NULL
MsgIntro3         dc.b        'Enjoy!.',CR,LF,NULL
InvalidFormat     dc.b        '       Invalid input format',CR,LF,NULL
Ecalc             dc.b        'Ecalc> ',NULL
OverflowError     dc.b        '       Overflow error',CR,LF,NULL 
                  END               ; this is end of assembly source file
                              ; lines below are ignored - not assembled/compiled


