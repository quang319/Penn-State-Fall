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
        [Test]
        public void test_SimpleArraySum_Correct_Value()
        {
            List<string> UserInput = new List<string>
            {
                "6",
                "1","2","3","4","10","11",
            };
            Program UUT = new Program();
            List<string> Result;
            List<string> ExpectedResult = new List<string> { "31" };

            Result = UUT.SimpleArraySum(UserInput);
            Assert.That(Result, Is.EqualTo(ExpectedResult));

        }
    }
}
