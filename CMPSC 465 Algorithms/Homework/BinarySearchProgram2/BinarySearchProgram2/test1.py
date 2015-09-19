import unittest
from BinarySearchProgram2 import *

class Test_test1(unittest.TestCase):
    def test_should_return_first_index(self):
        alist = [-10,-7,3,5,10,11,13]
        result  = binarySearch(alist, -10)
        expectedResult = 0
        self.assertEqual(expectedResult,result)

    def test_should_return_second_index(self):
        alist = [-10,-7,3,5,10,11,13]
        result  = binarySearch(alist, -7)
        expectedResult = 1
        self.assertEqual(expectedResult,result)

    def test_should_return_third_index(self):
        alist = [-10,-7,3,5,10,11,13]
        result  = binarySearch(alist, 3)
        expectedResult = 2
        self.assertEqual(expectedResult,result)

    def test_should_return_fourth_index(self):
        alist = [-10,-7,3,5,10,11,13]
        result  = binarySearch(alist, 5)
        expectedResult = 3
        self.assertEqual(expectedResult,result)

    def test_should_return_fifth_index(self):
        alist = [-10,-7,3,5,10,11,13]
        result  = binarySearch(alist, 10)
        expectedResult = 4
        self.assertEqual(expectedResult,result)

    def test_should_return_sixth_index(self):
        alist = [-10,-7,3,5,10,11,13]
        result  = binarySearch(alist, 11)
        expectedResult = 5
        self.assertEqual(expectedResult,result)

    def test_should_return_seventh_index(self):
        alist = [-10,-7,3,5,10,11,13]
        result  = binarySearch(alist, 13)
        expectedResult = 6
        self.assertEqual(expectedResult,result)

        
    def test_not_in_array(self):
        alist = [-10,-7,3,5,10,11]
        result  = binarySearch(alist, -3)
        expectedResult = -1
        self.assertEqual(expectedResult,result)

    def test_out_of_range(self):
        alist = [-10,-7,3,5,10,11]
        result  = binarySearch(alist, -12)
        expectedResult = -1
        self.assertEqual(expectedResult,result)
        

if __name__ == '__main__':
    unittest.main()
