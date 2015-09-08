import unittest
from Insertion_Sort_Project import *

class Test_test1(unittest.TestCase):
    def test_InsertionSortTest(self):
        TestArray = [5, 1, 3, 4, 10, 2, 11]
        ExpectedResult = [1,2,3,4,5,10,11]

        Result = InsertionSort(TestArray)
        self.assertEqual(Result,ExpectedResult)

if __name__ == '__main__':
    unittest.main()
