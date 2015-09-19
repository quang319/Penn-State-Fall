using System;

namespace ConsoleApplication2
{
    public class Program
    {
        public static int Main(string[] args)
        {
            int NumberOfYears= Convert.ToInt32(Console.ReadLine());
            while (NumberOfYears != 0)
            {
                int Year = Convert.ToInt32(Console.ReadLine());
                DateTime ResultingDate;

                ResultingDate = new DateTime(1992, 1, 1);
                //ResultingDate = new DateTime(Year, 1, 1);

                Console.WriteLine(ResultingDate.ToString("dddddddd"));
                NumberOfYears--;

            }
            return 1;

        }
    }
}
