**********************************************************************************
*
* Title:        StarFill (in Memory lane)
*
* Objective:    CSE472 Homework 1 
*
* Revision:     V1.4
*
* Date:         8/28/2015
*
* Programmer:   Quang Nguyen
*
* Company:      PSU CMPEN
*
* Algorithm:    Simple while-loop demo
*
* Register use: 
*               A: character data to be filled
*
*               B: counter, number of filled locations
*
*               X: memory address pointer
*
* Memory use:   RAM Locations from $3000 to $3009
*
* Input:        Parameters hard coded in the program
*
* Output:       Data filled in memory locations from $3000 to $3009 changed
*
* Observation:  This program is designed for instructional purpose.
*               This program can be used as a loop template
*
* Note:         N/A
*
* Comments:     This program is developed and simulated using Codewarrior development software
*
***********************************************************************************************
*
* Parameter Declearation section
*
* Export symbols
                  XDEF          pgstart         ; export 'pgstart' symbol
                  ABSENTRY      pgstart     ; FOR assembly entry point

* Symbols and macros
*
PORTA             EQU         $0000       ;i/o port addresses
PORTB             EQU         $0001       
DDRA              EQU         $0002
DDRB              EQU         $0003

***********************************************************
* Data Section
*
                  ORG         $3000       ; reserved memory starting address, in RAM
here              rmb         $0e         ; 14 meory locations reserved for stars
count             fcb         $0e         ; constant, star count = 14 (stored in $300a)

*
************************************************************
* Program Section
*
                  ORG         $3100       ; Program start address, in RAM
pgstart           ldaa        #$2a        ; load '*' ($2a) into accumulator A
                  ldab        count       ; load star count into B
                  ldx         #$3000      ; load starting address into x

loop              staa        0,x         ; put a star
                  inx                     ; point to next location
                  decb                    ; decrease counter
                  bne         loop        ; if not done, repeat

done              bra         done        ; task finish
                                          ;     do nothing

*
* Add any subroutines here
*

                  end                     ; last line of a file






*************************************************************************
*
* Program Section
*




*************************************************************************
*
* Subroutine Section
*


