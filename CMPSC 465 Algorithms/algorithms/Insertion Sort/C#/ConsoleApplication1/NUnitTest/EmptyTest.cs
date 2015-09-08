using System;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using QuickTestsFramework;

namespace QuickTestsFramework.Tests
{
    [TestFixture]
    public sealed class EmptyTest
    {
        private Runner _runner;

        [TestFixtureSetUp]
        public void SetUp()
        {
            _runner = RunnerHelper.Create();
            _runner.RunInitializers(this);

            // consolidate data from initializers and execute batch process here
        }

        [Test]
        public void T01()
        {
            _runner.Run(
                inicializer: () =>
                {

                },
                assertion: () =>
                {

                });
        }

        [Test]
        public void T02_parametrized()
        {
            _runner.Run(
                testCaseGenerator: () => Enumerable.Range(0, 10),
                inicializer: testCase =>
                {
                    
                },
                assertion: testCase =>
                {
                    
                });
        }
    }
}
