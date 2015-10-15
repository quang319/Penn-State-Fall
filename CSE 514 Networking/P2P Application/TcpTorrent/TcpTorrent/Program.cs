using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace TcpTorrent
{
    class Program
    {

        static void Main(string[] args)
        {
            //Console.WriteLine("hit Ctrl-C to exit.");
            //var tcpTorrent = new TcpTorrent();
            //// start the server 
            //var task1 = tcpTorrent.StartListener();
            //// Start the client
            //var task2 = tcpTorrent.ClientStart();

            //DataSegmentObject Segment = new DataSegmentObject(new ClientDataObject());
            //Segment.BreakFile(@"/Users/quang/Desktop/JetBrains.ReSharper.2015.2.web.exe");
            //Console.ReadKey();

            using (var sr = new StreamReader(@"../../Intro.txt"))
            {
                while(!sr.EndOfStream)
                    Console.WriteLine(sr.ReadLine());
            }
            using (var sr = new StreamReader(@"../../Example.txt"))
            {
                while (!sr.EndOfStream)
                    Console.WriteLine(sr.ReadLine());
            }
            commandPrint();

            Tuple<string, int> userCommand;

            var tcpServer = new TcpTorrent();
            var serverTask = tcpServer.StartListener();

            StateObject clientState = new StateObject();
            clientState.Address = "127.0.0.1";
            clientState.Port = tcpServer.GetOpenPort();

            List<string> availableFile = new List<string>();
            List<int> availableFileSize = new List<int>();

            while (true)
            {
                userCommand = getCommand();
                switch(userCommand.Item1)
                {
                    case "LISTUPLOADS":
                        string path = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
                        int i = 1;
                        Console.WriteLine("\nThe following files are available for download");
                        foreach (var file in Directory.GetFiles(path))
                        {
                            Console.WriteLine("{0}) {1}", i, Path.GetFileName(file));
                            availableFile.Add(Path.GetFileName(file));
                            availableFileSize.Add(file.Length);
                            
                            i++;
                        }
                        commandPrint();
                        break;

                    case "UPLOAD":
                        var uploadcmd = new ClientPassableObject(clientState);
                        uploadcmd.RegisterFiles(availableFile, availableFileSize);
                        var uploadclient = new TcpTorrent();
                        var clienttask = uploadclient.ClientStart(uploadcmd);
                        break;

                    case "LISTDOWNLOADS":
                        var printCmd = new ClientPassableObject(clientState);
                        printCmd.PrintDownloadable();
                  

                        var tcpClient = new TcpTorrent();
                        var task = tcpClient.ClientStart(printCmd);
                        while (!printCmd.DoneFlag)
                        {
                            ;
                        }
                        commandPrint() ;

                        break;


                    case "DOWNLOAD":
                        break;
                    case "HELP":
                        using (var sr = new StreamReader(@"../../Intro.txt"))
                        {
                            while (!sr.EndOfStream)
                                Console.WriteLine(sr.ReadLine());
                        }
                        break;
                    default:
                        Console.WriteLine("\nSorry. That was an invalid input. Please try again. \nValid Inputs are 'Listuploads','Upload-#','ListDownloads','Download-#','Help'");
                        commandPrint();
                        break;
                }

            }

        }



        public static void commandPrint()
        {
            Console.Write("\nCommand >> ");
        }

        public static Tuple<string,int> getCommand()
        {
            string[] userInput = Console.ReadLine().Split('-');

            if (userInput.Length == 2)
            {
                return new Tuple<string, int>(userInput[0].ToUpper(), Convert.ToInt32(userInput[1]));
            }
            else
                return new Tuple<string, int>(userInput[0].ToUpper(), 0);

        }


    }
}
