import sys
from math import floor

#main function
# n is the number of vertices
# weights is a list of their weights, v_1, ..., v_n
def ComputeP(n,x,f,p):
    for i in range(n,-1,-1):
        p[i] = GetMutualCompatible(0,i,x,f)
    

def GetMutualCompatible(s,e,x,f):
    if s == e:
        return s

    mid = (s+e)//2
    if f[mid] > x[e]:
        if mid == 0:
            return 0
        return GetMutualCompatible(s,mid -1,x,f)

    elif f[mid] < x[e]:
        if mid == 0:
            return 0
        return GetMutualCompatible(mid,e,x,f)
    else:
        return mid 

def main():
    
    x = [1,4,5,6]
    f = []
    p = []
    for i,val in enumerate(x):
        f.append(val+5)
        p.append(0)
    ComputeP(len(x) -1, x, f, p)

    return 0

if __name__ == "__main__":
    sys.exit(int(main() or 0))