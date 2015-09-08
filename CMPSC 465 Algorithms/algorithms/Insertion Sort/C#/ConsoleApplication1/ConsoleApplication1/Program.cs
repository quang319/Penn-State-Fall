using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApplication1
{
    public class Program
    {
        public void InsertionSort(int[] intArray)
        {
            for (int j = 1; j < intArray.Length; j++)
            {
                int Key = intArray[j];
                int i = j - 1;

                while ((i >= 0) && (intArray[i] > Key))
                {
                    intArray[i + 1] = intArray[i];
                    i--;
                }
                intArray[i + 1] = Key;
            }
        }


        public static void Main(string[] args)
        {
            int[] TestArray = new int[] { 2, 1, 5, 3, 4 };
            Console.WriteLine("The original array is :");
            Console.WriteLine(String.Join(",", TestArray));

            Program UUT = new Program();


            UUT.InsertionSort(TestArray);
            Console.WriteLine("The sorted array is :");
            Console.WriteLine(String.Join(",", TestArray));
            Console.Read();


        }

        
    }
}
