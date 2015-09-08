from BinarySearchProgram import *
import unittest

class Test_BinarySearchTest(unittest.TestCase):
    def test_should_return_right_key(self):
        TestArray = [i for i in range(50)]
        TestKey = 10
        ExpectedResult = 9
        self.assertEqual(TestKey, BinarySearch(TestArray,TestKey,0,49))

if __name__ == '__main__':
    unittest.main()