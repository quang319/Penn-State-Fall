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
        }

        public List<string> SimpleArraySum(List<string> inputs)
        {
            int Result = 0;
            for (int i = 1; i < inputs.Count; i++)
            {
                Result += Convert.ToInt32(inputs[i]);
            }
            return new List<string>() { Convert.ToString(Result) };
        }

    }


}
