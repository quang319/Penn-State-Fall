import sys

def binarySearch(alist, item):
  TargetReceived = False
  MinTerm = 0
  MaxTerm = len(alist) -1 
  MidTerm = 0
 
  while MinTerm <= MaxTerm:
      MidTerm = (MinTerm + MaxTerm) // 2
      if (item == alist[MidTerm]):
          return MidTerm
      elif (item < alist[MidTerm]):
          MaxTerm = MidTerm - 1
      else:
          MinTerm = MidTerm + 1

  return -1

def main():
    alist = [-10,-7,3,5,10,11,13]
    result  = binarySearch(alist, 3)
    expectedResult = 3

if __name__ == "__main__":
    sys.exit(int(main() or 0))