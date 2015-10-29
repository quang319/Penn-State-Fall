            xdef        pgstart
            absentry    pgstart

            org         $3000
N1          dc.b        1,2,200
N2          dc.b        1,2,57
            
            org         $3100
pgstart     lds         #pgstart
            jsr         Add24bits
            nop
Add24bits
            pshx
            pshy
            pshd

            ldx         #N1
            ldaa        2,x
            adda        5,x 
            staa        2,x
            ldaa        1,x
            adca        4,x 
            staa        1,x
            ldaa        x
            adca        3,x 
            staa        x 

            puld
            puly
            pulx
            rts       