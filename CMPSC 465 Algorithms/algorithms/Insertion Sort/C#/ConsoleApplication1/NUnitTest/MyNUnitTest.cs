using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using ConsoleApplication1;

namespace NUnitTest
{
    [TestFixture]
    public class MyNUnitTest
    {
        [Test]
        public void TestIfArrayIsSorted()
        {
            Program UnitUnderTest = new Program();
            int[] TestArray = new int[] { 2, 1, 5, 3, 4 };
            int[] AnsArray = new int[] { 1, 2, 3, 4, 5 };
            UnitUnderTest.InsertionSort(TestArray);
            Assert.That(TestArray, Is.EqualTo(AnsArray));
        }
    }
}
