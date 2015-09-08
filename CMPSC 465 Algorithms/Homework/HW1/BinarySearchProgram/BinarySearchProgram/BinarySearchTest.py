import unittest
from BinarySearchProgram import *

class Test_BinarySearchTest(unittest.TestCase):

    def test_should_return_right_key(self):
        TestArray = [i for i in range(50)]
        TestKey = 10
        ExpectedResult = 10
        self.assertEqual(ExpectedResult, BinarySearch(TestArray,TestKey,0,51))
        
    def test_target_is_not_in_array(self):
        TestArray = [i for i in range(50)]
        TestKey = 55
        ExpectedResult = "Invalid Target"
        self.assertEqual(ExpectedResult, BinarySearch(TestArray, TestKey, 0 , 51))

    """def test_array_is_empty(self):
        TestArray = []
        testKey = 5
        ExpectedResult = "Key is empty"
        MaxIndex = len(TestArray)
        self.assertEqual(ExpectedResult, BinarySearch(TestArray, 0, 0))"""
        

    if __name__ == '__main__':
        unittest.main()