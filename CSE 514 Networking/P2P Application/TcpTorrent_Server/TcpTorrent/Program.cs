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

            //using (var sr = new StreamReader(@"../../Intro.txt"))
            //{
            //    while(!sr.EndOfStream)
            //        Console.WriteLine(sr.ReadLine());
            //}
            //using (var sr = new StreamReader(@"../../Example.txt"))
            //{
            //    while (!sr.EndOfStream)
            //        Console.WriteLine(sr.ReadLine());
            //}
            //commandPrint();

            Console.WriteLine("This is the server. Do not close.");

            //Tuple<string, string> userCommand;

            var tcpServer = new TcpTorrent();
            var serverState = new StateObject();
            serverState.ClientType = false;
            //var serverTask = tcpServer.StartListener(serverState);

            tcpServer.StartListener(serverState).Wait();

            //StateObject clientState = new StateObject();
            //clientState.Address = "127.0.0.1";
            //var clientServer = new TcpTorrent();
            //clientState.Port = clientServer.GetOpenPort();
            //var task = clientServer.StartListener(clientState);

            //while (true)
            //{
            //    userCommand = getCommand();
            //    switch (userCommand.Item1)
            //    {
            //        case "LISTUPLOADABLES":
            //            Clearing the previous file paths since we are repopulating it
            //            clientState.UploadableFilePath.Clear();
            //            clientState.UploadableFileSize.Clear();

            //            string path = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
            //            int i = 1;
            //            Console.WriteLine("\nThe following files are available for download");
            //            foreach (var file in Directory.GetFiles(path))
            //            {
            //                Console.WriteLine("{0}) {1}", i, Path.GetFileName(file));
            //                clientState.UploadableFilePath.Add(file);
            //                clientState.UploadableFileSize.Add(file.Length);

            //                i++;
            //            }
            //            commandPrint();
            //            break;

            //        case "UPLOAD":


            //            Tuple<bool, string> validCheck = IsValidInput(userCommand.Item2, clientState.UploadableFilePath.Count);

            //            If any of the value in the previous loop was invalid, we need to break out of this case.
            //            if (validCheck.Item1 == false)
            //            {
            //                Console.WriteLine(validCheck.Item2);
            //                commandPrint();
            //                break;
            //            }

            //            Now what we know that the user's inputs are valid, we need to store the path of the files that the user wants to upload

            //             Clearing the previous FilestoREg list because we have a new list.
            //            clientState.FilePathsToReg.Clear();
            //            clientState.FilePathsToRegLength.Clear();
            //            foreach (string item in userCommand.Item2.Split(','))
            //            {
            //                clientState.FilePathsToReg.Add(clientState.UploadableFilePath[Convert.ToInt32(item) - 1]);
            //                clientState.FilePathsToRegLength.Add(clientState.UploadableFileSize[Convert.ToInt32(item) - 1]);
            //            }


            //            var uploadcmd = new ClientPassableObject(clientState);
            //            uploadcmd.RegisterFiles();
            //            var uploadclient = new TcpTorrent();
            //            var clienttask = uploadclient.ClientStart(uploadcmd);

            //            while (uploadcmd.DoneFlag == false) ;

            //            Now that we recieved upload on which file can be uploaded, we need to split the files up into segments and store it in memory
            //            for (int j = 0; j < uploadcmd.FilesRegSuccessCount.Count; j++)
            //            {
            //                if (uploadcmd.FilesRegSuccessCount[j] == true)
            //                {
            //                    StringBuilder FileSb = new StringBuilder();
            //                    using (var streamRdr = new StreamReader(clientState.FilePathsToReg[j]))
            //                    {
            //                        while (!streamRdr.EndOfStream)
            //                        {
            //                            FileSb.Append(streamRdr.ReadLine());
            //                        }
            //                    }
            //                    var DataParser = new DataSegmentObject();
            //                    Tuple<string, List<string>> tupleForDict = DataParser.ChunksUpto(FileSb.ToString(), clientState.MaxChunkSize);
            //                    var dictObject = new ObjectForFiledict();
            //                    dictObject.Hash = tupleForDict.Item1;
            //                    dictObject.Segments = tupleForDict.Item2;
            //                    if (!clientState.FileDict.ContainsKey(Path.GetFileName(clientState.FilePathsToReg[j])))
            //                    {
            //                        clientState.FileDict.Add(Path.GetFileName(clientState.FilePathsToReg[j]), dictObject);

            //                    }
            //                }

            //            }

            //            commandPrint();


            //            break;

            //        case "LISTDOWNLOADABLES":

            //            var printcmd = new ClientPassableObject(clientState);
            //            printcmd.PrintDownloadable();
            //            var printListclient = new TcpTorrent();
            //            var printTask = printListclient.ClientStart(printcmd);

            //            while (printcmd.DoneFlag == false) ;

            //            clientState.DownloadableFileName = printcmd.DownloadableFiles;
            //            clientState.DownloadableFileSize = printcmd.DownloadableFilesLength;
            //            commandPrint();

            //            break;


            //        case "DOWNLOAD":
            //            Tuple<bool, string> downloadValidCheck = IsValidInput(userCommand.Item2, clientState.DownloadableFileName.Count);

            //            If any of the value in the previous loop was invalid, we need to break out of this case.
            //            if (downloadValidCheck.Item1 == false)
            //            {
            //                Console.WriteLine(downloadValidCheck.Item2);
            //                commandPrint();
            //                break;
            //            }
            //            We are only going to allow one file to be download at a time
            //            if (userCommand.Item2.Split(',').Length > 1)
            //            {
            //                Console.WriteLine("/nYou can only select one download file at a time");
            //                break;
            //            }

            //            Clearing the previous FilestoREg list because we have a new list.
            //           clientState.FileNameToDownload = string.Empty;
            //            clientState.FileNameToDownloadLength = 0;

            //            clientState.FileNameToDownload = clientState.DownloadableFileName[Convert.ToInt32(userCommand.Item2) - 1];
            //            clientState.FileNameToDownloadLength = clientState.DownloadableFileSize[Convert.ToInt32(userCommand.Item2) - 1];

            //            var downloadClient = new TcpTorrent();
            //            var downloadTask = downloadClient.GetDownloadFile(clientState);

            //            var uploadCmd = new ClientPassableObject(clientState);
            //            var uploadClient = new TcpTorrent();
            //            uploadCmd.GetFilesLocation(clientState.FileNameToDownload);

            //            var uploadTask = uploadClient.ClientStart(uploadCmd);

            //            while (uploadCmd.DoneFlag == false) ;

            //            Console.WriteLine("Name of file: {0}", uploadCmd.FileToDownload);
            //            Console.WriteLine("Size of file: {0}", uploadCmd.FileToDownloadLength);
            //            Console.WriteLine("Address: {0}", uploadCmd.AddressAtFile2Download[0]);
            //            Console.WriteLine("Port: {0}", uploadCmd.PortAtFile2Download[0]);

            //            commandPrint();
            //            break;

            //        case "LEAVE":
            //            var leaveCmd = new ClientPassableObject(clientState);
            //            leaveCmd.LeaveRequest();
            //            var leaveClient = new TcpTorrent();
            //            var leaveTask = leaveClient.ClientStart(leaveCmd);
            //            while (leaveCmd.DoneFlag == false) ;

            //            Console.ReadKey();
            //            Environment.Exit(0);

            //            break;


            //        case "HELP":
            //            using (var sr = new StreamReader(@"../../Intro.txt"))
            //            {
            //                while (!sr.EndOfStream)
            //                    Console.WriteLine(sr.ReadLine());
            //            }
            //            break;
            //        default:
            //            Console.WriteLine("\nSorry. That was an invalid input. Please try again. \nValid Inputs are 'Listuploadables','Upload-#','ListDownloadables','Download-#','Leave','Help'");
            //            commandPrint();
            //            break;
            //    }

            //}

        }


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
                // if the user input more than what was presented to them
                if (Convert.ToInt32(item) - 1 >= LengthOfList)
                {
                    return new Tuple<bool, string>(false, "You have inputed an index that was larger than what was presented to you");
                }
                // if the user input less than what was presented to them
                else if (Convert.ToInt32(item) - 1 < 0)
                {
                    return new Tuple<bool, string>(false, "You have inputed an index that was less than what was presented to you");
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
