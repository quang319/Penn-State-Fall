import sys
from math import floor

#main function
# n is the number of vertices
# weights is a list of their weights, v_1, ..., v_n
def mwis (n, weights):
    
    # Create a empty list contain the opt weight
    opt = []
    sol_items = []
    tot_weight = 0

    # Check if base case is less than zero, set the base case to zero if it is.
    opt.append(weights[0])
    opt.append(max(opt[0],weights[1]))

    for j in range(2,n):
        opt.append(max (weights[j] + opt[j-2] , opt[j-1]) )


    tot = sol_tot_weight = opt[len(opt)-1]

    l = len(opt)
    weights.reverse()
    opt.reverse()

    for i in range(0,l):
        if tot == opt[i]:
            if i+2 < l:
                if opt[i] - weights[i] == opt[i+2]:
                    tot = tot - weights[i]
                    sol_items.append(len(opt) - 1 - i)
            else:
                if tot - weights[i] == 0:
                    tot = tot - weights[i]
                    sol_items.append(len(opt) - 1 - i)

    opt.reverse()

    return (opt, sol_tot_weight, sorted(sol_items))
    

def main():
    
    input = [8,3,7,10,4]

    #call mwis
    (opt, sol_tot_weight, sol_items) = mwis(len(input), input)

    return 0

if __name__ == "__main__":
    sys.exit(int(main() or 0))