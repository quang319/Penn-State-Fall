using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SolveMeFirst
{
    class Program
    {
        static void Main(string[] args)
        {
        }
    }

    public class MockConsole
    {
        public virtual string ReadFromConsole()
        {
            return Console.ReadLine();
        }
        public virtual void WriteToConsole(string Message)
        {
            Console.WriteLine(Message);
        }
    }

    public class TestMockConsole : MockConsole
    {
        public string[] OutputMessage {
            get
            {

            }
            set; }
        public override void WriteToConsole(string Message)
        {
            base.WriteToConsole(Message);
        }
    }

}
