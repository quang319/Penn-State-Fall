import sys
from math import floor

def BinarySearch(Array, Key, MinIndex, MaxIndex):

    if (Key > Array[ len(Array) - 1]) or (Key < Array[0 ]):
        return "Invalid Target"
    
    # Main body of the BinarySearch
    MidIndex = (MaxIndex + MinIndex) >> 1
    if (Key > Array[MidIndex]):
        return BinarySearch(Array,Key, MidIndex + 1, MaxIndex)
    elif (Key < Array[MidIndex]):
        return BinarySearch(Array,Key, MinIndex , MidIndex - 1)
    else:
        return MidIndex
    

def main():
    TestArray = [i for i in range(15)]
    TestKey = 10
    TestResult = BinarySearch(TestArray,TestKey,0,14)
    print("hello")

if __name__ == "__main__":
    sys.exit(int(main() or 0))