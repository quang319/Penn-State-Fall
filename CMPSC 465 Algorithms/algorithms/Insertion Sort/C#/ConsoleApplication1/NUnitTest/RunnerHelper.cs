using System.Linq;
using System.Collections.Generic;
using System;
using QuickTestsFramework.Internals;
using QuickTestsFramework.NUnit;

namespace QuickTestsFramework.Tests
{
   public static class RunnerHelper
   {
      public static Runner Create()
      {
         var exceptionFilter = new NUnitExceptionFilter(printStacktrace: false);
         var viewTestFixture = new ViewTestFixture(exceptionFilter);
         var inicjalizerView = new InicjalizerView(exceptionFilter);
         var nUnitAssertionAction = new NUnitAssertionAction();
         var runInExclusiveGroupAttributeFilter = new RunInExclusiveGroupAttributeFilter();
         var traditionalTestAttributeFilter = new TraditionalTestAttributeFilter();
         var testMethodSelector = new TestSelector(
            new NUnitTestMethodSelectorFromTestFixture(), 
            new ITestMethodFilter[] { runInExclusiveGroupAttributeFilter, traditionalTestAttributeFilter }, 
            nUnitAssertionAction);
         var nUnitTestMethodSelectorFromCallStack = new NUnitTestMethodSelectorFromCallStack();

         return new Runner(
            exceptionFilter, viewTestFixture, inicjalizerView, 
            testMethodSelector, nUnitAssertionAction, nUnitTestMethodSelectorFromCallStack);
      }
   }
}