            xdef       pgstart
            absentry    pgstart

            org         $3100
pgstart     lds         #pgstart
            ldd         #$0205
            pshd
            jsr         SORT
            nop
SORT
            psha
            pshb
            ldaa        5,sp
            ldab        4,sp
            cba         
            bls         SORT_Done
            staa        4,sp
            stab        5,sp    
SORT_Done
            pulb
            pula
            rts
