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
    opt.append(0)
    opt.append(0)
    sol_items.append(0)
    sol_items.append(2)

    for j in range(2,n):

        # If the inclusive
        if (weights[j] + opt[j-2]) > opt[j-1]:
            

            solLenDif = j - sol_items[ len(sol_items) - 1]
            if  (solLenDif > 1):
                sol_items.append(j)

            opt.append(weights[j] + opt[j-2])

        # if exclusive
        else:
            if opt[j-2] == opt[j-1]:
                sol.items[len(sol_items) -1 ] = j
            opt.append(opt[j -1])
    
    # opt(i) = max(v_i + opt(i -2), opt(i - 1))

    
    sol_tot_weight = opt[len(opt) - 1 ]

    return (opt, sol_tot_weight, sorted(sol_items))
    

def main():
    inputs = [31997,6146,28997,16102, 17552, 8379, 15478,18320,6912,28872, 12816, 8097, 25014]
    (opt, sol_tot_weight,sol_items) = mwis(len(inputs) , inputs)
    return 0

if __name__ == "__main__":
    sys.exit(int(main() or 0))