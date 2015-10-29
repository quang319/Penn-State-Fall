            xdef        StackSt
            absentry    StackSt
            org         $3100
StackSt
            lds         #Done
            ldaa        StackSt
mainLoop
            staa        200
            eora        2,-x 
            bhs         mainLoop
Done        swi