using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using WarmupExercises;

namespace Testinging
{
    [TestFixture]
    public class MyNUnitTest
    {

        /*
input 1: 
5
3
6
9
12
15

Output 1: 
555
555555
555555555
555555555555
555555555555555

Input 2: 
5
2194
12002
21965
55140
57634

Output 2: 

        [Test]
        public void test_SherlockAndBeast_Correct_Value()
        {
            List<string> UserInput = new List<string>
            {
                "4","1","3","5","11"
            };
            List<string> Result;
            List<string> ExpectedResult = new List<string>
            {
                "-1","555","33333","33333555555"
            };
            Result = Program.SherlockAndBeast(UserInput);
            Assert.That(Result, Is.EqualTo(ExpectedResult));
        }

        [Test]
        public void test_LibraryFine_Correct_Value()
        {
            List<string> UserInput = new List<string>
            {
                "9", "6", "2015",
                "6", "6", "2015",
            };
            List<string> Result;
            List<string> ExpectedResult = new List<string> { "45" };
            Result = Program.LibaryFine(UserInput);
            Assert.That(Result, Is.EqualTo(ExpectedResult));
        }


        [Test]
        public void test_SimpleArraySum_Correct_Value()
        {
            List<string> UserInput = new List<string>
            {
                "1",
                "1","2","3","4","10","11",
            };

            List<string> Result;
            List<string> ExpectedResult = new List<string> { "31" };

            Result = Program.SimpleArraySum(UserInput);
            Assert.That(Result, Is.EqualTo(ExpectedResult));

        }

        [Test]
        public void test_DiagonalDifference_Correct_Value()
        {
            List<string> UserInput = new List<string>
            {
                "3",
                "11", "2", "4",
                "4", "5", "6",
                "10", "8", "-12",
            };
            List<string> Result;
            List<string> ExpectedResult = new List<string> { "15" };
            Result = Program.DiagonalDifference(UserInput);
            Assert.That(Result, Is.EqualTo(ExpectedResult));
        }
    }
}
