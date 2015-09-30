**********************************************************************************
*
* Title:        LED Transition
*
* Objective:    CSE472 Homework 4
*
* Revision:     V1.0
*
* Date:         9/21/2015
*
* Programmer:   Quang Nguyen
*
* Company:      PSU CMPEN472
*
* Purpose:      To transition LED 1 from 0% to 100% in 5 seconds and vice versa
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

NULL              EQU         $00
*********** Registers for SCI Configuration *****
SCIDRH            EQU         $000E  
SCIDRL            EQU         $000F             
SCISR1            EQU         $000A             ; SCI Status Reg 1
            **** bits of SCISR1 *****
TDRE              EQU         $80
TC                EQU         $40
RDRF              EQU         $20


***********************************************************
* Data Section
*
                  ORG         $3000             ; reserve RAM memory starting addresses 
                                                ; memory $3000 to $30FF are for data

StackSP                                         ; remaining memory space for stack data
                                                ; initial stack pointer position set
                                                ; to $3100 (pgstart)

*
************************************************************
* Program Section
*
                  org         $3100             ; Program start address, in RAM
pgstart           lds         #pgstart          ; initialize the stack pointer
                  
                  ldaa        #%00010000        ; set PORTB bit 7,6,5,4,as output. 3,2,1,0 as input
                  staa        DDRB              ; Led 1,2,3,4 on PORTB bit 0,1,2,3.
                                                ;     DIP switch 1,2,3,4 on the bits 0,1,2,3.

                  
                  ldaa        #%00000000        ; Turn all LEDs off
                  staa        PORTB             

mainLoop    



* if(L2) --> Turn on LED2
* Else if ("L4") --> Turn on LED4
* Else if ("F2") --> Turn off LED2
* Else if ("F4") --> turn off LED4
* Else if ("L1") --> LED1 = Increasing transition in 4 seconds
* Else if ("F1") --> LED1 = Decreasing transition in 4 seconds
* Else if ("QUIT") --> Run Type writer program 


                  ******************** Transition LED from 0% to 100% *****************
                  ldab        #40               ; Parameter: the # of millisecond per iteration
                  ldaa        #$00              ; Parameter: Increasing brightness
                  jsr         TransitionLED

                  ******************** Transition LED from 100% to 0% *****************
                  ldab        #40               ; Parameter: the # of millisecond per iteration
                  ldaa        #$01              ; Parameter: Increasing brightness
                  jsr         TransitionLED

                  BRA         mainLoop          ; loop forever


*************************************************************************
*
* Subroutine Section
*
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

* read TDRE bit of SCISR1, If 1, empty, data can be transmitted on SCIDRH/L. If 0, full, do nothing
putchar
                  brclr       SCISR1,#TDRE,putchar
                  staa        SCIDRL
                  rts 

* Read bit 5 (RDRF) of SCISR1. If 1, retrieve data from SCIDRL (8 bits). If 0, do nothing. 
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
*                 ldd        #$000A
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


