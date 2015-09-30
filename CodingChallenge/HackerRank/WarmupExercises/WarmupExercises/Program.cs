using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WarmupExercises
{
    public class Program
    { 
        static void Main(string[] args)
        {
            List<string> Inputs = new List<string>();
            Inputs.AddRange(Console.ReadLine().Split(' '));
            for (int i = 0; i < Convert.ToInt32(Inputs[0]); i++)
            {
                Inputs.AddRange(Console.ReadLine().Split(' '));
            }

            List<string> Result = new List<string>(SherlockAndBeast(Inputs));
            //Console.WriteLine(Result[0]);
            for (int i = 0; i < Convert.ToInt32(Inputs[0]); i++)
            {
                Console.WriteLine(Result[i]);
            }
            Console.ReadKey();
        }

        public static List<string> SherlockAndBeast(List<string> inputs)
        {
            List<string> Result = new List<string>();
            List<int> InputsInterger = new List<int>();
            foreach (string Item in inputs)
            {
                InputsInterger.Add(Convert.ToInt32(Item));
            }

            for (int i = 1; i <= InputsInterger[0]; i++)
            {
                // If the value that we are receiving is divisible by 5
                if ((InputsInterger[i] % 5) == 0)
                {
                    string TempString = "";
                    for (int j = 0; j < InputsInterger[i]; j++)
                        TempString += "3";
                    Result.Add(TempString);
                }
                // If the value that we are receiving is divisible by 3
                else if ((InputsInterger[i] % 3) == 0)
                {
                    string TempString = "";
                    for (int j = 0; j < InputsInterger[i]; j++)
                        TempString += "5";
                    Result.Add(TempString);
                }
                // 
                else if (((InputsInterger[i] - (5 * (InputsInterger[i] % 5)))%3) == 0)
                {
                    int ModOfFive = InputsInterger[i] % 5;
                    int DigitLeft = (InputsInterger[i] - ((ModOfFive * 5)));
                    string TempString = "";

                    for (int j = 0; j < DigitLeft; j++)
                        TempString += "5";

                    for (int j = 0; j < (5 * ModOfFive); j++)
                        TempString += "3";

                    Result.Add(TempString);
                }
                else
                {
                    Result.Add("-1");
                }

            }
            return Result;
        }

        /// <summary>
        /// Diagonal Difference Problem
        /// https://www.hackerrank.com/challenges/diagonal-difference
        /// </summary>
        /// <param name="inputs"></param>
        /// <returns></returns>

        public static List<string> DiagonalDifference(List<string> inputs)
        {
            int SizeOfArray = Convert.ToInt32(inputs[0]);

            int leftSum = 0;
            int rightSum = 0;
            for (int i = 1; i <= SizeOfArray; i++)
            {
                leftSum += Convert.ToInt32(inputs[(i * SizeOfArray) - (i - 1)]);
                rightSum += Convert.ToInt32(inputs[(i * SizeOfArray) - (SizeOfArray - 1) + (i - 1)]);
            }
            int result = Math.Abs(leftSum - rightSum);
            return new List<string> { result.ToString() };
        }

        /// <summary>
        /// Library Fine problem
        /// https://www.hackerrank.com/challenges/library-fine
        /// </summary>
        /// <param name="inputs"></param>
        /// <returns></returns>

        public static List<string> LibaryFine(List<string> inputs)
        {
            List<int> inputsInterger = new List<int>();
            foreach (string item in inputs)
            {
                inputsInterger.Add(Convert.ToInt32(item));
            }

            if (inputsInterger[2] > inputsInterger[5])
            {
                return new List<string> { "10000" };
            }
            else if ((inputsInterger[2] == inputsInterger[5]) && (inputsInterger[1] > inputsInterger[4]))
            {
                return new List<string> { Convert.ToString(500 * (inputsInterger[1] - inputsInterger[4])) };
            }
            else if ((inputsInterger[2] == inputsInterger[5]) && (inputsInterger[1] == inputsInterger[4]) && (inputsInterger[0] > inputsInterger[3]))
            {
                return new List<string> { Convert.ToString(15 * (inputsInterger[0] - inputsInterger[3])) };
            }
            else
                return new List<string> { "0" };
        }

        /// <summary>
        /// Simpel Array Sum problem
        /// https://www.hackerrank.com/challenges/simple-array-sum
        /// </summary>
        /// <param name="inputs"></param>
        /// <returns></returns>

        public static List<string> SimpleArraySum(List<string> inputs)
        {
            int Result = 0;
            inputs.RemoveAt(0);
            foreach (string item in inputs)
            {
                Result += Convert.ToInt32(item);
            }
            
            return new List<string>() { Convert.ToString(Result) };
        }
       

    }


}
