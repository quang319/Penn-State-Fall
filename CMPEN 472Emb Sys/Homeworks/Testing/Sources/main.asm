**********************************************************************************
*
* Title:        LED PWM
*
* Objective:    CSE472 Homework 3
*
* Revision:     V1.0
*
* Date:         9/15/2015
*
* Programmer:   Quang Nguyen
*
* Company:      PSU CMPEN472
*
* Purpose:      To change the brightness of LED 2 based on the press of SW 1.
*               At initialization: LED 3 is on and the rest are off
*               SW1 not pressed: LED 2 = 21% duty cycle
*               SW1 is pressed:  LED 2 = 12% duty cycle
*
* Register use: 
*               D,X,Y
*
* Memory use:   RAM Locations from $3000 for data 
*                                   $3100 for program
*
* Input:        Parameters hard coded in the program.
*                Switch SW1 at PORTP bit 0
*
* Output:       LED 1,2,3,4 at PORTB bit 4,5,6,7
*
* Observation:  This is a program that controls the brightness of an LED
*               by changing the ON and OFF duty cycle
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

PTP               EQU         $0258             ; PORTP data register, used for push switches
PTIP              EQU         $0259             ; PORTP input register <<===
DDRP              EQU         $025A             ; PORTP data direction register
PERP              EQU         $025C             ; PORTP pull up/down enable
PPSP              EQU         $025D             ; PORTP pull up/down selection 


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
PwmOnCounter      DC.b        $00               ; initialize counter for SetPWMDutyCycle Subroutine
pwmOffCounter     DC.b        $00               ; initialize counter for SetPWMDutyCycle Subroutine
CounterDly10US    DC.w        $0000             ; initialize counter for delay_MS 

MsgQueue          DC.B        $00,$00,$00,$00   ; Queue to store the user inputs
MsgQueuePointer   Dc.w        $0000
FlgTypeWrite      dc.b        $00
MsgInvalidInput   DC.b        'Invalid Input. Please try again.',$00

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

                  bclr        DDRP, %00000011   ; Push button switch 1 and 2 at PORTP bit 0 and 1
                                                ;     set PORTP bit 0 and 1 as input
                  bset        PERP, %00000011   ; enable the pull up/down feature at PORTP
                  bclr        PPSP, %00000011   ; select pull up feature at PORTP bit 0 and 1 for 
                                                ;     Push button switch 1 and 2.
                  
                  ldaa        #0        ; LED 3 is on, and LED 1,2, & 4 are off 
                  staa        PORTB             

mainLoop
                  ldab        #212
                  jsr         CvrtBinToDec




                  BRA         mainLoop          ; loop forever


; Result = RegA(oneth place), RegB(Tenth place), RegX(Hundreth place)
CvrtBinToDec
                  pshb
                  clra        
                  ldx         #100
                  idiv
                  pshb
                  ldab        #30
                  abx
                  pulb
                  pshx 
                  ldx         #10
                  idiv
                  pshb
                  ldab        #30
                  abx
                  pulb
                  pshx
                  addb        #30
                  pulx
                  puly        
                  rts 

