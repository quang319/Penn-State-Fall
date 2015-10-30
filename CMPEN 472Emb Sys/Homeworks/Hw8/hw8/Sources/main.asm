;*******************************************************************************
;*
;* Title:         RTC using Timer interrupt
;*
;* Objective:     CSE472 Homework 8
;*
;* Revision:      V1.0
;*
;* Date:          10/21/2015
;*
;* Programmer:    Quang Nguyen
;*
;* Company:       The Pennsylvanie State University
;*                Department of Computer Science and Engineering
;*
;* Algorithm:     
;*
;* Register Use:  D,X,Y
;*
;* Memory use:    RAM locations from $3000 for data from $3100 for program.
;*                Space following program used for additional msg Data 
;*
;* Input:         Inputs will be through the terminal
;*
;* Output:        Outputs will be through the terminal
;*
;* Observation:              
;*
;* Comments:      This program is developed and simulated using CodeWarrior
;*                development software.
;*
;*********************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;           additional Notes
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;*******************************************************
;* CMPEN 472, HW8 Real Time Interrupt, MC9S12C128 Program
;* April 9,2015 Kyusun Choi
;* 
;* 10 second timer using Real Time Interrupt.
;* This program is a 10 second count down timer using 
;* a Real Time Interrupt service subroutine (RTIISR).  This program
;* displays the time remaining on the Hyper Terminal screen every 1 second.  
;* That is, this program displays '987654321098765432109876543210 . . . ' on the 
;* Hyper Terminal connected to MC9S12C128 chip on CSM-12C128 board.  
;* User may enter 'stop' command followed by an enter key to stop the timer 
;* and re-start the timer with 'run' command followed by an enter key.
;*
;* Please note the new feature of this program:
;* RTI vector, initialization of CRGFLG, CRGINT, RTICTL, registers for the
;* Real Time Interrupt.
;* We assumed 24MHz bus clock and 4MHz external resonator clock frequency.  
;* This program evaluates user input (command) after the enter key hit and allow 
;* maximum five characters for user input.  This program ignores the wrong 
;* user inputs, and continue count down.
;* 
;*******************************************************
; export symbols
            XDEF Entry               ; export 'Entry' symbol
            ABSENTRY Entry           ; for assembly entry point

SCISR1            EQU     $00cc            ; Serial port (SCI) Status Register 1
SCIDRL            EQU     $00cf            ; Serial port (SCI) Data Register

;following is for the TestTerm debugger simulation only
;SCISR1        EQU     $0203            ; Serial port (SCI) Status Register 1
;SCIDRL        EQU     $0204            ; Serial port (SCI) Data Register

CRGFLG            EQU         $0037        ; Clock and Reset Generator Flags
CRGINT            EQU         $0038        ; Clock and Reset Generator Interrupts
RTICTL            EQU         $003B        ; Real Time Interrupt Control

CR                equ         $0D          ; carriage return, ASCII 'Return' key
LF                equ         $0A          ; line feed, ASCII 'next line' characters
NULL              equ         $00

;*******************************************************
; variable/data section
                  ORG  $3000               ; RAMStart defined as $3000
                                     ; in MC9S12C128 chip

ctr2p5m           DS.W  1                  ; 16bit interrupt counter for 2.5 mSec. of time
CharBufCntr       dc.b  0                  ; user input character buffer fill count
CharBuf           DS.B  10                 ; user input character buffer

time              DS.W  1

lineCntr          dc.b        $0          

StackSP                              ; Stack space reserved from here to
                                     ; StackST

                  ORG  $3FF0               ; Real Time Interrupt (RTI) interrupt vector setup
                  DC.W RTIISR

                  ORG  $3100
StackST

;*******************************************************
; code section
Entry
                  LDS     #StackST      ; initialize the stack pointer
            
                  jsr     OnStartup

looop             jsr     NewCommand         ; check command buffer for a new command entered.

loop2             jsr     UpdateDisplay          ; update display, each 1 second 

                  jsr     getchar            ; user may enter command
                  tsta                     ;  save characters if typed
                  beq     loop2

                  staa    1,x+               ; save the user input character
                  inc     CharBufCntr
                  jsr     putchar            ; echo print, displayed on the terminal window

                  cmpa    #CR
                  beq     looop              ; if Enter/Return key is pressed, move the
            

loop3             ldaa    CharBufCntr             ; if user typed 5 character, it is the maximum, reset command
                  cmpa    #11                ;   is in error, ignore the input and continue timer
                  blo     loop2

                  bra     looop


;subroutine section below

;****************displayClk***********************
;* Program: Clears Terminal Screen
;* Input:   None
;* Output:  Clear Terminal  
;**********************************************

displayClk        psha
                  pshb
                  pshx
            
                  ; Save cursor position
                  ldaa    #$1B         ; esc character
                  jsr     putchar
                  ldaa    #'['
                  jsr     putchar
                  ldaa    #'s'
                  jsr     putchar
            
                  ; Move cursor to Spot
                  ldaa    #$1B         ; esc character
                  jsr     putchar
                  ldaa    #'['
                  jsr     putchar
                  ldaa    #'5'
                  jsr     putchar
                  ldaa    #';'
                  jsr     putchar
                  ldaa    #'4'
                  jsr     putchar
                  ldaa    #'4'
                  jsr     putchar
                  ldaa    #'H'
                  jsr     putchar
            
                  ldd     time
                  ldx     #10
                  idiv    
                  ldaa    #$30
                  aba
                  jsr     putchar
            
                  cmpb    #0    
                  lbne    clkQuit
            
                  ldaa    #$1B         ; esc character
                  jsr     putchar
                  ldaa    #'['
                  jsr     putchar
                  ldaa    #'2'         
                  jsr     putchar
                  ldaa    #'D'
                  jsr     putchar
            
                  xgdx
                  ldx     #6
                  idiv
                  ldaa    #$30
                  aba
                  jsr     putchar
                  cmpb    #0    
                  lbne    clkQuit
            
                  ; Move cursor back 3
                  ldaa    #$1B         ; esc character
                  jsr     putchar
                  ldaa    #'['
                  jsr     putchar
                  ldaa    #'3'         
                  jsr     putchar
                  ldaa    #'D'
                  jsr     putchar
            
                  xgdx
                  ldx     #10
                  idiv
                  ldaa    #$30
                  aba
                  jsr     putchar
                  ldaa    #':'
                  jsr     putchar
            
                  cmpb    #0    
                  lbne    clkQuit
            
                  ; Move cursor back 2
                  ldaa    #$1B         ; esc character
                  jsr     putchar
                  ldaa    #'['
                  jsr     putchar
                  ldaa    #'3'         
                  jsr     putchar
                  ldaa    #'D'
                  jsr     putchar
            
                  xgdx
                  ldx     #6
                  idiv
                  ldaa    #$30
                  aba
                  jsr     putchar
                  cmpb    #0    
                  lbne    clkQuit
            
                  ; Move cursor back 3
                  ldaa    #$1B         ; esc character
                  jsr     putchar
                  ldaa    #'['
                  jsr     putchar
                  ldaa    #'3'         
                  jsr     putchar
                  ldaa    #'D'
                  jsr     putchar
            
                  xgdx
                  ldx     #10
                  idiv
                  ldaa    #$30
                  aba
                  jsr     putchar
                  ldaa    #':'
                  jsr     putchar
                  cmpb    #0    
                  lbne    clkQuit
            
                  ; Move cursor back 2
                  ldaa  #$1B         ; esc character
                  jsr   putchar
                  ldaa  #'['
                  jsr   putchar
                  ldaa  #'3'         
                  jsr   putchar
                  ldaa  #'D'
                  jsr   putchar
            
                  xgdx
                  ldx     #2
                  idiv
                  ldaa    #$30
                  aba
                  jsr     putchar
            
clkQuit           ; Restore cursor position
                  ldaa  #$1B         ; esc character
                  jsr   putchar
                  ldaa  #'['
                  jsr   putchar
                  ldaa  #'u'
                  jsr   putchar
            
                  ;jsr nextLine

                  pulx
                  pulb  
                  pula
            
                  rts
;****************end of displayClk****************

;****************display1stClk***********************
;* Program: Clears Terminal Screen
;* Input:   None
;* Output:  Clear Terminal      
;**********************************************

display1stClk 
                  psha
                  pshb
                  pshx
            
                  ; Save cursor position
                  ldaa    #$1B         ; esc character
                  jsr     putchar
                  ldaa    #'['
                  jsr     putchar
                  ldaa    #'s'
                  jsr     putchar
            
                  ; Move cursor to Spot
                  ldaa    #$1B         ; esc character
                  jsr     putchar
                  ldaa    #'['
                  jsr     putchar
                  ldaa    #'5'
                  jsr     putchar
                  ldaa    #';'
                  jsr     putchar
                  ldaa    #'3'
                  jsr     putchar
                  ldaa    #'7'
                  jsr     putchar
                  ldaa    #'H'
                  jsr     putchar
            
                  ldd     time
                  ldx     #10
                  idiv    
                  ldaa    #$30
                  aba
                  psha
            
                  xgdx
                  ldx     #6
                  idiv
                  ldaa    #$30
                  aba
                  psha
            
                  xgdx
                  ldx     #10
                  idiv
                  ldaa    #$30
                  aba
                  psha
            
                  xgdx
                  ldx     #6
                  idiv
                  ldaa    #$30
                  aba
                  psha

                  xgdx
                  ldx     #10
                  idiv
                  ldaa    #$30
                  aba
                  psha

                  xgdx
                  ldx     #2
                  idiv
                  ldaa    #$30
                  aba
            
                  jsr     putchar
                  pula
                  jsr     putchar
                  ldaa    #':'
                  jsr     putchar
            
                  pula
                  jsr     putchar
                  pula    
                  jsr     putchar
                  ldaa    #':'
                  jsr     putchar
            
                  pula
                  jsr     putchar
                  pula    
                  jsr     putchar
            
                  ; Restore cursor position
                  ldaa  #$1B         ; esc character
                  jsr   putchar
                  ldaa  #'['
                  jsr   putchar
                  ldaa  #'u'
                  jsr   putchar
            
                  pulx
                  pulb  
                  pula
            
                  rts
;****************end of display1stClk****************

;****************clearTerminal***********************
;* Program: Clears Terminal Screen
;* Input:   None
;* Output:  Clear Terminal  
;* Registers modified: 
;*          A: Protected        
;**********************************************

clearTerminal         
                  psha
                  ldaa  #$1B
                  jsr   putchar
                  ldaa  #'['
                  jsr   putchar
                  ldaa  #'2'
                  jsr   putchar
                  ldaa  #'J'
                  jsr   putchar
                  ldaa  #CR
                  jsr   putchar
                  pula
            
                  rts
;****************end of clearTerminal****************

;****************OnStartup***********************
;* Program: 
;* Input:       
;* Output:  
;* Registers modified: 
;*            
;**********************************************

OnStartup           
                  jsr     clearTerminal

                  ldx   #msg1            ; print the first message, 'Hello'
                  jsr   printmsg               
                  jsr   nextLine
            
                  ldx   #msg2            ; print the second message
                  jsr   printmsg

                        ; Move cursor to Spot
                  ldaa    #$1B         ; esc character
                  jsr     putchar
                  ldaa    #'['
                  jsr     putchar
                  ldaa    #'9'
                  jsr     putchar
                  ldaa    #';'
                  jsr     putchar
                  ldaa    #'0'
                  jsr     putchar
                  ldaa    #'H'
                  jsr     putchar
            
                  ldx     #CharBuf
                  ldaa    #CR
                  staa    1,x+
                  ldaa    #1
                  staa    CharBufCntr
            
                  clr     ctr2p5m
          
                  bset  RTICTL,%00011001   ; set RTI: dev=10*(2**10)=2.555msec for C128 board
                                     ;      4MHz quartz oscillator clock
                  bset  CRGINT,%10000000   ; enable RTI interrupt
                  bset  CRGFLG,%10000000   ; clear RTI IF (Interrupt Flag)
            
                  rts
;****************end of OnStartup****************

;***********RTI interrupt service routine***************
RTIISR            bset  CRGFLG,%10000000   ; clear RTI Interrupt Flag
                  ldx   ctr2p5m
                  inx
                  stx   ctr2p5m            ; every time the RTI occur, increase interrupt count
rtidone           RTI
;***********end of RTI interrupt service routine********

;***************Update Display**********************
;* Program: Update count down timer display if 1 second is up
;* Input:   ctr2p5m variable
;* Output:  timer display on the Hyper Terminal
;* Registers modified: CCR
;* Algorithm:
;    Check for 1 second passed
;      if not 1 second yet, just pass
;      if 1 second has reached, then update display, toggle LED, and reset ctr2p5m
;**********************************************
UpdateDisplay
                  psha
                  pshx
                  ldx   ctr2p5m          ; check for 1 sec
                  cpx   #399             ; 2.5msec * 400 = 1 sec        0 to 399 count is 400
                  blo   UpDone           ; if interrupt count less than 400, then not 1 sec yet.
                                   ;    no need to update display.

                  ldx         #0               ; interrupt counter reached 400 count, 1 sec up now
                  stx         ctr2p5m          ; clear the interrupt count to 0, for the next 1 sec.

                  ldx     time
                  inx
                  cpx     #46800
                  bne     storeTime
                  ldx     #3600
                  stx     time
                  jsr     display1stClk
                  bra     UpDone
            
storeTime         stx     time

                  jsr     displayClk
            
UpDone            pulx
                  pula
                  rts
;***************end of Update Display***************

;***************New Command Process*******************************
;* Program: Check for 'run' command or 'stop' command.
;* Input:   Command buffer filled with characters, and the command buffer character count
;*             CharBuf, CharBufCntr
;* Output:  Display on Hyper Terminal, count down characters 9876543210 displayed each 1 second
;*             continue repeat unless 'stop' command.
;*          When a command is issued, the count display reset and always starts with 9.
;*          Interrupt start with CLI for 'run' command, interrupt stops with SEI for 'stop' command.
;*          When a new command is entered, cound time always reset to 9, command buffer cleared, 
;*             print error message if error.  And X register pointing at the begining of 
;*             the command buffer.
;* Registers modified: X, CCR
;* Algorithm:
;*     check 'run' or 'stop' command, and start or stop the interrupt
;*     print error message if error
;*     clear command buffer
;*     Please see the flow chart.
;* 
;**********************************************
NewCommand
                  psha

                  ldx   #CharBuf            ; read command buffer, see if 'run' or 'stop' command entered
                  ldaa  1,x+             ;    each command is followed by an enter key
                  cmpa  #CR
                  lbeq   CNexit
                  cmpa  #'q'
                  lbeq   clkquit
                  cmpa  #'s'
                  lbne   CNerror

clkrun            ldaa  CharBufCntr
                  cmpa  #10
                  lble   CNerror

                  ldy     #0
                  ldaa    1,x+
                  cmpa    #' '
                  lbne    CNerror
            
                  ldab    #1
                  ldaa    1,x+
                  jsr     asciiDec2Dec
                  cmpa    #-1
                  lbeq     CNerror
            
                  ldab    #9
                  ldaa    1,x+
                  jsr     asciiDec2Dec
                  cmpa    #-1
                  lbeq     CNerror
            
                  cpy     #24 
                  lbhi     CNerror
            
                  cpy     #13
                  blo     checkzero
                  tfr     y,d
                  tba
                  ldab    #13
                  sba
                  tab
                  ldaa    #0
                  tfr     d,y
                  aby
            
checkzero         cpy     #0
                  bne     loadmin
                  ldy     #12
            
            
            
loadmin           ldaa    1,x+
                  cmpa  #':'
                  bne   CNerror
            
                  ldab    #5
                  ldaa    1,x+
                  jsr     asciiDec2Dec
                  cmpa    #-1
                  beq     CNerror
            
                  ldab    #9
                  ldaa    1,x+
                  jsr     asciiDec2Dec
                  cmpa    #-1
                  beq     CNerror
            
                  ldaa    1,x+
                  cmpa  #':'
                  bne   CNerror
            
                  ldab    #5
                  ldaa    1,x+
                  jsr     asciiDec2Dec
                  cmpa    #-1
                  beq     CNerror
            
                  ldab    #9
                  ldaa    1,x+
                  jsr     asciiDec2Dec
                  cmpa    #-1
                  beq     CNerror
            
                  ldaa    1,x+
                  cmpa  #CR
                  bne   CNerror
            
                  sty     time
                  ldy     #0
                  sty     ctr2p5m
                  jsr     display1stClk
                  cli                     ; Turn on intercept
            
                  bra   CNexit


clkquit           ldaa  1,x+             ; check if 'run' command
                  cmpa  #CR              ;    'r' and 'un' with enter key CR.
                  bne   CNerror
                  sei                    ; it is 'stop' command, turn off interrupt
         
                  jsr     nextLine
                  ldx     #msgexit
                  jsr     printmsg
                  jsr     nextLine
                  jmp     typeWriter
                  bra     CNexit
          
CNerror           jsr   nextLine
                  inc   lineCntr
                  ldaa  lineCntr
                  cmpa  #10
                  ble   CNerror_NoOverflow
                  jsr   goBackHome
CNerror_NoOverflow
                  ldx   #errmsg         ; print the 'Command Error' message
                  jsr   printmsg

CNexit            jsr   nextLine
                  inc   lineCntr
                  ldaa  lineCntr
                  cmpa  #10
                  ble   CNexit_NoOverflow
                  jsr   goBackHome
CNexit_NoOverflow
                  ldx   #msgprompt
                  jsr   printmsg
                  clr   CharBufCntr           ; reset command buffer
                  ldx   #CharBuf
            

                  pula
                  rts
;***************end of New Command Process***************

goBackHome

                  ldaa  #$1B         ; esc character
                  jsr   putchar
                  ldaa  #'['
                  jsr   putchar
                  ldaa  #'1'         ; $38 in hex
                  jsr   putchar
                  ldaa  #'A'
                  jsr   putchar


                  ldaa  #$1B        ; Clear the line
                  jsr   putchar
                  ldaa  #'['
                  jsr   putchar
                  ldaa  #'2'
                  jsr   putchar
                  ldaa  #'K'
                  jsr   putchar

           

                  dec   lineCntr
                  ldaa  lineCntr
                  cmpa  #1
                  bne   goBackHome
                  rts 


;****************asciiDec2Dec***********************
;* Program: Convert valid ASCII Decimal into Decimal
;* Input:   ASCII Decimal character in A  
;* Output:  Binary representation of number in A
;* Registers modified: 
;*              A: Converted to Decimal 
;*              B: Max value of A 
;*              Y: Time being built        
;* Algorithm: Test if char is within range '0-9'
;*              If so, subtract '0'.
;*            Else character is not a decimal in Hex
;*              Set errFlag
;**********************************************
asciiDec2Dec
                  suba    #'0'
                  blo     dec2Fail
                  psha
                        
                  sba
                  bhi     dec2Fail
            
                  clra
                  incb
                  emul
                  xgdy            
            
                  pula
                  tab
                  aby
                  rts

dec2Fail          pula
                  ldaa    #-1

                  rts            
;****************end of asciiDec2Dec****************

;****************typeWriter***********************
;* Program: 
;* Input:       
;* Output:  
;* Registers modified: 
;*            
;**********************************************

typeWriter        jsr     getchar           ; type writer - check the key board
                  cmpa    #$00              ;  if nothing typed, keep checking
                  beq     typeWriter
                                    ;  otherwise - what is typed on key board
                  jsr     putchar           ; is displayed on the terminal window
                  cmpa    #CR
                  bne     typeWriter        ; if Enter/Return key is pressed, move the
                  ldaa    #LF               ; cursor to next line
                  jsr     putchar
                  bra     typeWriter  

;****************end of typeWriter****************


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
printmsg          psha                   ;Save registers
                  pshx
printmsgloop      ldaa    1,X+           ;pick up an ASCII character from string
                                       ;   pointed by X register
                                       ;then update the X register to point to
                                       ;   the next byte
                  cmpa    #NULL
                  beq     printmsgdone   ;end of strint yet?
                  bsr     putchar        ;if not, print character and do next
                  bra     printmsgloop
printmsgdone      pulx 
                  pula
                  rts
;***********end of printmsg********************

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
putchar           brclr SCISR1,#%10000000,putchar   ; wait for transmit buffer empty
                  staa  SCIDRL                      ; send a character
                  rts
;***************end of putchar*****************

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

getchar           brclr SCISR1,#%00100000,getchar7
                  ldaa  SCIDRL
                  rts
getchar7          clra
                  rts
;****************end of getchar**************** 

;****************nextline**********************
nextLine          ldaa  #CR              ; move the cursor to beginning of the line
                  jsr   putchar          ;   Cariage Return/Enter key
                  ldaa  #LF              ; move the cursor to next line, Line Feed
                  jsr   putchar
                  rts
;****************end of nextline***************

msg1            DC.B    'enter the s command in the following format "s hh:mm:ss to start the clock"', NULL
msg2            DC.B    'enter the q command to enter typewriter mode', NULL
msgprompt       DC.B    'Clock> ', NULL
errmsg          DC.B    'Invalid time format. Correct example => hh:mm:ss', NULL
msgexit         DC.B    'You are now in typewriter mode.', NULL


            END                    ; this is end of assembly source file
                                   ; lines below are ignored - not assembled
