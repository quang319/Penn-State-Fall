            xdef        pgstart
            absentry    pgstart

            org         $3000
TEN         dc.b        $39
ONE         dc.b        $31


            org         $3100
pgstart     lds         #pgstart
            jsr         Dec2Bin
            NOP
Dec2Bin
            pshb
            ldaa        TEN
            suba        #$30
            ldab        #10
            mul   
            pshb

            ldaa        ONE
            suba        #$30
            pulb
            aba         
            pulb
            rts 

