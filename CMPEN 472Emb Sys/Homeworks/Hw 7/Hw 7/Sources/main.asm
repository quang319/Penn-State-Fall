**********************************************************************************
*
* Title:        SCI program
*
* Objective:    CSE472 Homework 5
*
* Revision:     V1.0
*
* Date:         9/30/2015
*
* Programmer:   Quang Nguyen
*
* Company:      PSU CMPEN472
*
* Purpose:      To use the SCI interface to control the microcontroller. Below are the ASCII commands that the program takes to control everything
*                       - L1 = Fade LED1 to 100%
*                       - F1 = Fade LED1 to 0%
*                       - L2 = Turn on LED2
*                       - F2 = Turn off LED2
*                       - S####
*                             Read an address from the controller. (Note: the address needs to be in Hex)
*                       - W#### ###
*                             Write a value to an address. Value to be writen to the controller can be Hex or Decimal. If hex, user must add a $ in front of the number
*                       - QUIT = this will allow the user to enter the typewriter program
*                       - Any other inputs are Invalid
*                       * Note: uppercase and lowercase does not matter
*
* Register use: 
*               D,X,Y
*
* Memory use:   RAM Locations from $3000 for data 
*                                  $3100 for program
*
* Input:        Parameters hard coded in the program.
*
* Output:       LED 1,2,3,4 at PORTB bit 4,5,6,7
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
VarOperand1       dc.w        $00
VarOperand2       dc.w        $00
Operator          dc.b        $00
TypeOfErrorFlag   dc.b        $00               ; 0 = InvalidFormat , 1 = Overflow


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





                  ldd         #MsgQueue         ; initialize the MsgQueuePointer to the address of the MsgQueue
                  std         MsgQueuePointer
loop 
                  ldaa        #'7'
                  jsr         OperateOnInput
                  ldaa        #'h'
                  jsr         OperateOnInput
                  ldaa        #'6'
                  jsr         OperateOnInput
                  ldaa        #'*'
                  jsr         OperateOnInput
                  ldaa        #'1'
                  jsr         OperateOnInput
                  ;ldaa        #'7'
                  ;jsr         OperateOnInput
                  ;ldaa        #'2'
                  ;jsr         OperateOnInput
                  ldaa        #CR
                  jsr         OperateOnInput

                  

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
*                 Below are the possible inputs from the user
*                       - L2 = Turn on LED2
*                       - F2 = Turn off LED2
*                       - L4 = Turn on LED4
*                       - F4 = Turn off LED4
*                       - S#### = Read from a register
*                       - W#### ### = Write to a register
*                       - QUIT = this will set the FlgTypeWrite variable
*                       - Any other inputs are Invalid
*                       * Note: uppercase and lowercase does not matter                       
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
                  




                  ;jsr         putchar








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
                  inx         
                  jsr         OperateOnInput_InvalidInput

OperateOnInput_Calculate
                  ; Load the output queue with everything minus the result 
                  ldx         #MsgQueue 
                  ; message queue needs to be the queue address + 7 
                  ldd         #OutputQueue
                  addd        #7
                  tfr         d,y

OperateOnInput_Calculate_QueueLoop
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

OperateOnInput_Calculate_Add_Thoundsandth
                  puld        
                  cmpa        #$30
                  beq         OperateOnInput_Calculate_Add_Hundreth
                  staa        1,x+

OperateOnInput_Calculate_Add_Hundreth 
                  cmpb        #$30
                  beq         OperateOnInput_Calculate_Add_Tenth
                  stab        1,x+

OperateOnInput_Calculate_Add_Tenth
                  puld        
                  cmpa        #$30
                  beq         OperateOnInput_Calculate_Add_Hundreth
                  staa        1,x+

OperateOnInput_Calculate_Add_Oneth       
                  stab        1,x+
                  puld 

                  lbra         OperateOnInput_ResetAfterCR


OperateOnInput_Calculate_Sub
                  ldaa        #'-'
                  cmpa        Operator 
                  bne         OperateOnInput_Calculate_Mult

                  ldd         VarOperand1
                  subd        VarOperand2
                  bge         OperateOnInput_Calculate_Add_Output

                  pshd  
                  ldaa        #'-'
                  staa        1,y+
                  puld 
                  eora        #$ff 
                  eorb        #$ff 
                  addd        #1
                  std         VarOperand2
                  ldd         VarOperand2

                  bra         OperateOnInput_Calculate_Add_Output



OperateOnInput_Calculate_Mult
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
                  cpd         #$7fff
                  bgt         OperateOnInput_Calculate_Mult_Overflow
                  puly
                  std         VarOperand2

                  bra         OperateOnInput_Calculate_Add_Output

OperateOnInput_Calculate_Mult_Overflow
                  ldaa        #1
                  staa        TypeOfErrorFlag
                  lbra        OperateOnInput_InvalidInput

OperateOnInput_Calculate_Div
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
                  ldab        1,x+ 
                  stab        1,y+
                  tfr         x,d 
                  subd        sp 
                  lbls         OperateOnInput_InvalidInput_QueueLoop
                  pulx

                  brset       TypeOfErrorFlag,1,OperateOnInput_InvalidInput_Overflow
                  ;
                  ; Print the InvalidFormat string
                  ;
                  lbra        OperateOnInput_ResetAfterCR
                  ;
OperateOnInput_InvalidInput_Overflow
                  ;
                  ;     
                  ;Print the overflow string 
                  ;

                  lbra        OperateOnInput_ResetAfterCR


OperateOnInput_ResetAfterCR                     ; clearing MsgQueue and MsgQueuePointer
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
   
                  ldd         #MsgQueue
                  std         MsgQueuePointer 
                  ldd         #0
                  std         VarOperand1
                  std         VarOperand2
                  staa        Operator 
                  staa        TypeOfErrorFlag
                  bra         OperateOnInput_EndOfSR

OperateOnInput_NotEqualCR

                        ;     if (RegA > 96)                // Checking if it a lowercase
                  ldaa        sp
                  cmpa        #96
                  bls         OperateOnInput_NotAChar
                        ;           if (RegA < 123)
                  cmpa        #123
                  bhs         OperateOnInput_NotAChar
                        ;                 RegA = RegA - 32  // Converting to uppercase
                  suba        #32
                  ;           store RegA and increment pointer
OperateOnInput_NotAChar
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


; Inputs: 
;           REgX : The address of the queue of ASCII char that the function should operate on 
;           RegA : Flags registers
;                 - 1st bit = First operand state
;                 - 2nd bit = Operator State 
;                 - 3nd bit = Second operator State
; Outputs:
;           RegY : The result of the operation. 16 bit number if it was in operator1 or operator1 state
;                       - The value of the ASCII char - $30 if it is an operator
;           RegA : Flag registers 
;                 - 1st bit  = The result was successful that that the program should move onto the next state 
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

; Input: Higher 2 bytes in RegX, Lower 2 bytes in RegD
CvrtASCIIHexStringToBin
                  pshx
                  pshd
                  ; Convert the smallest byte to binary
                  jsr CvrtASCIIHexToBin
                  stab        1,sp
                  ; Convert the 2nd smallest byte to binary
                  ldab        sp 
                  jsr CvrtASCIIHexToBin
                  stab        sp 
                  ; Convert the 2nd largest byte to binary
                  ldab        3,sp 
                  jsr CvrtASCIIHexToBin
                  stab        3,sp 
                  ; convert the largest byte to binary 
                  ldab        2,sp
                  jsr CvrtASCIIHexToBin
                  stab        2,sp

                  ; Pull the results from the stack
                  puld
                  pulx

                  rts

; Input: binary # in regB
; Result = RegA(The larger hex), RegB(The smaller hex)
CvrtBinToASCIIHex
                  ; Get the value for the larger hex place
                  clra         
                  ldx         #16
                  idiv
                  pshb                          ; Push B
                  cpx         #10
                  blo         CvrtBinToASCIIHex_1stHigher
                  ldab        #7
                  abx         
CvrtBinToASCIIHex_1stHigher
                  ldab        #$30
                  abx
                  pulb                          ; Pull B
                  pshx                          ; Push X
                  ; Get the value for the smaller place 
                  cmpb        #10
                  blo         CvrtBinToASCIIHex_2ndHigher
                  addb        #7
CvrtBinToASCIIHex_2ndHigher
                  addb        #$30
                  pshb                          ; Push B

                  ; shuffle stuff around so that RegA has the larger half and RegB has the smallest half
                   
                  ldd         1,sp              ; Transfer the higher half onto RegD
                  tba                           ; transfer B to A 
                  pulb 
                  pulx

                  rts 

; Value of ASCII hex to convert to is in RegA
CvrtASCIIHexToBin

                  subb        #$30               ; Number representation of Hex starts at 30
                  ; Check to see if the ASCII char is "A" or higher
                  cmpb        #10               ; If hex is "A" then the value will be higher than 9
                  bls         CvrtASCIIHexToBin_NotAbove9
                  subb        #16                ; $30 = 48, and "A" = 65. 65 - 48 - 16 = 1
                  addb        #9
CvrtASCIIHexToBin_NotAbove9
                  rts
; This function returns the concatination of the X and the D registers in RegD
; RegD should contain the lower half and RegX should contain the upper half
ConcatinateDnX
                  pshx
                  pshd
                  ; Combine RegA and RegB
                  jsr         Concatinate2Hex
                  staa        1,sp
                  ldd         2,sp
                  jsr         Concatinate2Hex
                  staa        3,sp 
                  tab        
                  clra 
                  lsld         
                  lsld        
                  lsld        
                  lsld        
                  lsld        
                  lsld        
                  lsld        
                  lsld        
                  addd        sp 
                  ldx         4,sp+
                  rts 

; This function receive the upper nibble in RegA and lower nibble in RegB
; It outputs the result in RegA                 
Concatinate2Hex
                  lsla 
                  lsla
                  lsla
                  lsla      
                  aba         
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


************************************************************************
*
* Name:           TransitionLED
*
* Fuction:        This subroutine transiton LED 1 from 0% to 100% (or vice versa) for 5 seconds 
*
* Parameters:     - RegA: this contains the direction 
*                       0 = Brighten      1 = dimming
*
* Registers Used:
*
* Stack Pointer:  sp = the value of the current pwm duty cycle 
*
* Example:        *The code below will transiton LED 1 from 0% to 100% brightness  
*                 ldaa        #$00
*                 jsr         TransitionLED
*
* Comments:       
*
*************************************************************************

TransitionLED
                  pshb                          ; push RegB into the sp
                  anda        #$01              ; see if we need to brighten or dim the LED

                  beq         TransitionLED_Brightening_Setup   
                                                ; Brighten the LED if RegA == 0
                  ldaa        #$64              ; We will need to go from 100% bright to 0%
                  psha                          ; push this into the sp

TransitionLED_Dimming
                  ldab        sp                ; setting up the parameters for the SetTimePerPWM subroutine
                  ldaa        1,sp              ; Parameter: The number of millisecond per iteration
                  jsr         SetTimePerPWM     ;
                  ldaa        sp                
                  deca                          ; Decreasing the % duty cycle (aka dimming the light)
                  staa        sp                
                  bne         TransitionLED_Dimming
                                                ; continue until the % duty cycle == 0 
                  bra         TransitionLED_End

TransitionLED_Brightening_Setup
                  clra                          ; We will need to go from 0% bright to 100%
                  psha                          ; push this into the sp

TransitionLED_Brightening 
                  ldab        sp                ; setting up the parameters for the SetTimePerPWM subroutine
                  ldaa        1,sp              ; Parameter: The number of millisecond per iteration
                  jsr         SetTimePerPWM     ;
                  ldaa        sp                
                  inca                          ; Increasing the % duty cycle
                  staa        sp                
                  cmpa        #$64              ; Check to see if it is at %100 duty cycle 
                  bne         TransitionLED_Brightening
                                                ; branch if it is 

TransitionLED_End 
                  pula                          ; pop RegA and RegB from sp so that the program can return to the right place 
                  pulb
                  rts 

************************************************************************
*
* Name:           SetTimePerPWM
*
* Fuction:        This subroutine will hold the pwm duty cycle for the specified period of time in ms 
*
* Parameters:     - RegB: This contains the % of time that the LED should be on (aka. duty cycle)
*                 - RegA: This contains the period that the pwm should hold for in ms 
*
* Registers Used: - RegD 
*                 - RegX 
*
* Stack Pointer:  sp = period to hold the pwm for
*                 sp + 1 = the duty cycle of the pwm 
*
* Example:        *The code below will set LED 1 to 60% duty cycle for 9 millisecond 
*                 ldab        #$3C
*                 ldaa        #$09
*                 jsr         SetTimePerPWM
*
* Comments:       
*
*************************************************************************
SetTimePerPWM 
                  pshd                          ; store RegD onto the sp 
SetTimePerPWMLoop
                  ldab        1,sp                ; load the duty cycle for the sub rt.
                  jsr         SetPWMDutyCycle   ; Call the sub rt.
                  ldaa        sp              ; Load the pwm period into RegA 
                  deca                          
                  staa        sp              ; decrement and then store it back to the sp
                  bne         SetTimePerPWMLoop ; loop back if the pwm period != 0
                  puld                          ; pop the sp so that we can return to the right place
                  rts  
                  





************************************************************************
*
* Name:           SetPWMDutyCycle
*
* Fuction:        This Subroutine turn LED 1 on and off by the duty cycle specifies
*                 in RegB
*
* Parameters:     - RegB: This contains the % of time that the LED should be on (aka. duty cycle)
*
* Registers Used: - RegD 
*                 - RegX
*
* Stack Pointer:  sp = the off duty cycle 
*                 sp + 1 = the on duty cycle 
*
* Example:        *The code below will set LED 1 to 60% duty cycle
*                 ldab        #$3C
*                 jsr         SetPWMDutyCycle
*
* Comments:       A single duty cycle takes 1000 us 
*
*************************************************************************
SetPWMDutyCycle
                  *******************************************************
                  * Calculate the on and off duty cycles
                  *******************************************************

                  pshb                          ; store regB into the sp
                  ldaa        #$64              ; load 100 into RegA
                  suba        sp                ; REgA = 100 - PwmOnCounter 
                  psha                          ; This subtraction is the off duty
                                                ; push the result onto the sp 

                  *******************************************************
                  * Turn on LED 2 for the duration of the on duty cycle
                  *******************************************************

                  bclr        PORTB, $10        ; Turn on LED 1
                  ldab        1,sp              ; load PwmOnCounter into RegB
                  clra                          ; clear RegA because the subroutine delay_MS
                                                ; reads the whole entire D register 
                  cba                           ; skip the delay if the LED is suppose to be off for 100% of the time
                  beq         SetTimePerPWM_off
                  jsr         delay_10US        ; Keep LED 2 on for the duration of PwmOnCounter in mS 

                  *******************************************************
                  * Turn off LED 2 for the duration of the off duty cycle
                  *******************************************************
SetTimePerPWM_off
                  bset        PORTB, $10        ; Turn off LED 1
                  ldab        sp                ; load pwmOffCounter into RegB
                  clra                          ; clear be for the same reason as above
                  cba                           ; skip the delay if the LED is suppose to be on for 100% of the time
                  beq         SetTimePerPWM_end
                  jsr         delay_10US

SetTimePerPWM_end
                  pula                          ; Restore the content of the registers the way it originally was
                  pulb                          
                  rts                           ; We have completed a whole duty cycle (100 ms) we can return back
                                                ; to the caller



************************************************************************
*
* Name:           delay_10US
*
* Fuction:        This Subroutine will delay the program by the value specifies in
*                 register A. Time(10uS) = RegD
*
* Parameters:     - RegD: The number of uS to delay for
*
* Registers Used: - RegD - for the Parameter 
*                 - RegX - For the delay for the delay_10US_LOOP
*
* Example:        *The code below will delay the program by 100 uS
*                 ldd        #$0000
*                 jsr         delay_10US
*
* Comments:       This Subroutine does not use interupts for the delay. It uses
*                 NOP as a way to delay the program. 
*
*************************************************************************
delay_10US     
                  pshd                          ; push RegD onto the stack
delay_10US_LOOP_2

                  *******************************************************
                  * this section will delay the program by 10 uS
                  * 
                  * Value for ldx = ((10us * 24MHz) -3) / 5 
                  *******************************************************

                  ldx         #$002F            ; load the amount of time the loop needs to
                                                ; run to produce 10 mS into RegX
delay_10US_LOOP 
                  NOP 
                  dex                           ; Decrement RegX
                  bne         delay_10US_LOOP   ; jump back to delay_US_LOOP if != 0

                  *******************************************************
                  * end 
                  *******************************************************

                  ldx         sp                ; the stack pointer contains the value of parameter that was passed in by RegD
                  dex                           ; Decrement RegX by 1
                  stx         sp                ; store RegX
                  bne         delay_10US_LOOP_2 ; Branch back to the loop if not == 0
                  puld                          ; Restore the original content of regD
                  rts                           ; Return to the caller



;OPTIONAL
;more variable/data section below
; this is after the program code section
; of the RAM.  RAM ends at $3FFF
; in MC9S12C128 chip

MsgIntro1         dc.b        'Welcome! The followings are the commands for the program',CR,LF,'L2 = LED2 ON, F2 = LED2 OFF, L4 = LED4 ON,  F4 = LED4 OFF',CR,LF,NULL
MsgIntro2         dc.b        'S#### to read to a register and W#### ### to write to a register ',CR,LF,NULL
MsgIntro3         dc.b        'QUIT = enable the program to enter typewriter mode.',CR,LF,NULL
InvalidFormat     dc.b        'Invalid input format',CR,LF,NULL
                  END               ; this is end of assembly source file
                              ; lines below are ignored - not assembled/compiled


