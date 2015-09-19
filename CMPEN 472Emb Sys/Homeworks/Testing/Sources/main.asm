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

***********************************************************
* Data Section
*
                  ORG         $3000             ; reserve RAM memory starting addresses 
                                                ; memory $3000 to $30FF are for data
PwmOnCounter      DC.b        $00               ; initialize counter for SetPWMDutyCycle Subroutine
pwmOffCounter     DC.b        $00               ; initialize counter for SetPWMDutyCycle Subroutine
CounterDly10US    DC.w        $0000             ; initialize counter for delay_MS 

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
                  
                  ldaa        #%10110000        ; LED 3 is on, and LED 1,2, & 4 are off 
                  staa        PORTB             

mainLoop
                  ldaa        PTIP              ; read push button SW1 at PORTP0
                  anda        #%00000001        ; Check the bit 0 only
                  beq         sw1notpushed         


                  *******************************************************************
                  *     if sw1 is pressed then we need to set LED 2 to 12% duty cycle
                  *******************************************************************
sw1pushed         
                  ldab        #$5A              ; Load 12 into RegA 
                  jsr         SetPWMDutyCycle   ; Run the SetPWMDutyCycle subroutine

                  bra         mainLoop


                  *******************************************************************
                  *     if sw1 is not pressed then we need to set LED 2 to 21% duty cycle
                  *******************************************************************
sw1notpushed      
                  ldab        #$15              ; Load 21 into RegA 
                  jsr         SetPWMDutyCycle   ; Run the SetPWMDutyCycle subroutine

                  BRA         mainLoop          ; loop forever


*************************************************************************
*
* Subroutine Section
*

************************************************************************
*
* Name:           SetPWMDutyCycle
*
* Fuction:        This Subroutine turn LED 2 on and off by the duty cycle specifies
*                 in RegB 
*
* Variables:      pwmOffCounter, PwmOnCounter - These must be declared before using this Subroutine
*
* Parameters:     - RegB: This contains the % of time that the LED should be on (aka. duty cycle)
*
* Registers Used: - RegD 
*                 - RegX
*
* Example:        *The code below will set LED 2 to 60% duty cycle
*                 ldab        #$3C
*                 jsr         SetPWMDutyCycle
*
* Comments:       This Subroutine does not use interupts for the delay. It uses
*                 NOP as a way to delay the program. 
*
*************************************************************************
SetPWMDutyCycle
                  *******************************************************
                  * Calculate the on and off duty cycles
                  *******************************************************

                  stab        PwmOnCounter      ; store regB into PWMCounter
                  ldaa        #$64              ; load 100 into RegA
                  suba        PwmOnCounter      ; REgA = 100 - PwmOnCounter 
                  staa        pwmOffCounter     ; This subtraction is the off duty

                  *******************************************************
                  * Turn on LED 2 for the duration of the on duty cycle
                  *******************************************************

                  bclr        PORTB, $20        ; Turn on LED 2
                  ldab        PwmOnCounter      ; load PwmOnCounter into RegB
                  clra                          ; clear RegA because the subroutine delay_MS
                                                ; reads the whole entire D register 
                  jsr         delay_10US        ; Keep LED 2 on for the duration of PwmOnCounter in mS 

                  *******************************************************
                  * Turn off LED 2 for the duration of the off duty cycle
                  *******************************************************

                  bset        PORTB, $20        ; Turn off LED 2
                  ldab        pwmOffCounter     ; load pwmOffCounter into RegB
                  clra                          ; clear be for the same reason as above
                  jsr         delay_10US                      

                  rts                           ; We have completed a whole duty cycle (100 ms) we can return back
                                                ; to the caller



************************************************************************
*
* Name:           delay_10US
*
* Fuction:        This Subroutine will delay the program by the value specifies in
*                 register A. Time(10uS) = RegD
*
* Variables:      CounterDly10US - must be declared before using this Subroutine
*
* Parameters:     - RegD: The number of uS to delay for
*
* Registers Used: - RegD - for the Parameter 
*                 - RegX - For the delay for the delay_10US_LOOP
*
* Example:        *The code below will delay the program by 100 uS
*                 ldd        #$000A
*                 jsr         delay_10US
*
* Comments:       This Subroutine does not use interupts for the delay. It uses
*                 NOP as a way to delay the program. 
*
*************************************************************************
delay_10US     
                  std        CounterDly10US      ; store RegD into the counter for the delay_10US
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

                  ldx         CounterDly10US    ; load value of CounterDly10US into RegX
                  dex                           ; Decrement RegX by 1
                  stx         CounterDly10US    ; store the of RegX back into CounterDly10US
                  bne         delay_10US_LOOP_2 ; Branch back to the loop if not == 0
                  rts                           ; Return to the caller


            