            xdef        pgstart
            absentry    pgstart

SCISR1      EQU         $00CC
SCIBDL      EQU         $00C9

            org         $3000
Message     dc.b        "Hello World!",0
            
            org         $3100
pgstart     lds         #pgstart



putchar
            brclr       SCISR1,#$80,putchar
            staa        SCIBDL
            rts

printmsg
            pshx
            psha
printmsg_loop
            ldaa        1,x+
            cmpa        #0
            beq         printmsg_Done
            jsr         putchar
            bra         printmsg_loop
printmsg_Done
            pula
            pulx
            rts     

getchar
            brclr       SCISR1,#$20,getchar_NoChar
            ldaa        SCIBDL
            rts
getchar_NoChar
            ldaa        #0
            rts

            