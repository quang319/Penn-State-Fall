import sys

def InsertionSort(Array):
    for j in range(1,len(Array)):
        key = Array[j]
        i = j - 1
        while (i >= 0) and (Array[i] > key):
            Array[i+1] = Array[i]
            i = i - 1
        Array[i + 1] = key
    return Array

def main():

    TestArray = [5, 1, 3, 4, 10, 2, 11]

    print("The test array is")
    print(str(TestArray))

    TestArray = InsertionSort(TestArray)
    print("The sorted array is")
    print(str(TestArray))

    testing = input("enter your name")

if __name__ == "__main__":
    sys.exit(int(main() or 0))


