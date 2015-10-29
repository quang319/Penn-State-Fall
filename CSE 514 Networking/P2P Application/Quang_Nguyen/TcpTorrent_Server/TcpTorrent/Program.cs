using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Threading;

namespace TcpTorrent
{
    class Program
    {

        static void Main(string[] args)
        {

            /************************************************
            *   
            *   This block of code is used to instantiate the server
            *
            ************************************************/
            var tcpServer = new TcpTorrent();
            var serverState = new StateObject();
            serverState.ClientType = false;

            tcpServer.StartListener(serverState).Wait();

        }



        // This function will return whether or not the user's input was a valid command
        public static Tuple<bool,string> IsValidInput(string command, int LengthOfList)
        {
            if (command == "Empty")
            {
                return new Tuple<bool, string>(false, "\nSorry. That was an invalid input. Please try again. \nValid Inputs are 'Listuploadables','Upload-#','ListDownloadables','Download-#','Leave','Help'");
            }

            if (LengthOfList == 0)
            {
                return new Tuple<bool, string>(false, "You must view the files before you can select them");
            }
            string ItemsToUpload = command;
            ItemsToUpload.Replace(" ", "");

            // Loop through the inputs and through an invalid entry if any of the inputs is wrong
            foreach (string item in command.Split(','))
            {
                int number;
                if (int.TryParse(item,out number))
                {
                    // if the user input more than what was presented to them
                    if (number - 1 >= LengthOfList)
                    {
                        return new Tuple<bool, string>(false, "You have inputed an index that was larger than what was presented to you");
                    }
                    // if the user input less than what was presented to them
                    else if (number - 1 < 0)
                    {
                        return new Tuple<bool, string>(false, "You have inputed an index that was less than what was presented to you");
                    }
                }
                else
                {
                    return new Tuple<bool, string>(false, "You have inputed an invalid format");
                }
                
            }
            return new Tuple<bool, string>(true, "");
        }


        public static void commandPrint()
        {
            Console.Write("\nCommand >> ");
        }

        public static Tuple<string,string> getCommand()
        {
            string[] userInput = Console.ReadLine().Split('-');

            if (userInput.Length == 2)
            {
                return new Tuple<string, string>(userInput[0].ToUpper(), userInput[1]);
            }
            else
                return new Tuple<string, string>(userInput[0].ToUpper(), "Empty");

        }


    }
}
