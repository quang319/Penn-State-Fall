            xdef        pgstart
            absentry    pgstart

DDRB        EQU         $0003
PRTB        EQU         $0001

CRGINT      EQU         $0038
CRGFLG      EQU         $0037
RTICTRL     EQU         $003B

            org         $3ff0
            dc.w        RTISR

            org         $3000
2p5msCtr    dc.b        $0

            org         $3100
pgstart     lds         #pgstart
            
            bset        DDRB,#$10

            ldaa        #%00011001
            staa        RTICTRL
            bset        CRGFLG,#$80
            bset        CRGINT,#$80
            cli 
loop
            jsr         toogleLED
            bra         loop

toogleLED 
            psha
            ldaa        2p5msCtr
            cmpa        #100
            blo         toogleLED_done

            clr         2p5msCtr
            ldaa        PRTB
            eora        #$10
            staa        PRTB
toogleLED_done    
            pula
            rts

RTISR 
            bset        CRGFLG,#$80
            inc         2p5msCtr
            rti 