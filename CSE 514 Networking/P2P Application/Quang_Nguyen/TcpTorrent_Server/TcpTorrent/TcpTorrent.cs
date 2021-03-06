﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Xml.Serialization;
using System.IO;
using System.Net.NetworkInformation;

namespace TcpTorrent
{
    class TcpTorrent
    {

        // Key is the name of the file 
        public Dictionary<string, dynamic> ServerDict = new Dictionary<string, dynamic>();

        public StringBuilder ServerSb = new StringBuilder();
        public StringBuilder ClientSb = new StringBuilder();
        object _lock = new object(); // sync lock
        List<Task> _connections = new List<Task>();


        // This method instantiate the tcp server
        public async Task StartListener(StateObject tcpState)
        {
            var TcpServer = TcpListener.Create(1000);

            // this if statement differentiates between a server and a client's server
            if (tcpState.ClientType == false)
            {
                Console.WriteLine("Creating server on port {0}", 1000);
                TcpServer = TcpListener.Create(1000);

            }
            else {
                TcpServer = TcpListener.Create(tcpState.Port);
            }

            TcpServer.Start(100);
            while (true)
            {
                var TcpClient = await TcpServer.AcceptTcpClientAsync();
                var task = OnConnectAsync(TcpClient, tcpState);
                if (task.IsFaulted)
                    task.Wait();
            }
            //Console.WriteLine("Server is closing down");

        }

        private async Task OnConnectAsync(TcpClient tcpClient, StateObject tcpState)
        {
            // Start a transfer task
            var transferTask = OnTransferAsync(tcpClient, tcpState);

            // lock it as this is critial path
            lock (_lock)
                _connections.Add(transferTask);

            try
            {
                await transferTask;

            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            finally
            {
                lock (_lock)
                    _connections.Remove(transferTask);
            }

        }

        private async Task OnTransferAsync(TcpClient tcpClient, StateObject tcpState)
        {
            await Task.Yield();

            using (var networkStream = tcpClient.GetStream())
            {
                var buffer = new byte[8192];

                // Receiving and deserialized the serializable object
                var byteCount = await networkStream.ReadAsync(buffer, 0, buffer.Length);
                if (byteCount > 0)
                {
                    ServerSb.Append(Encoding.UTF8.GetString(buffer, 0, byteCount));
                    var StringMsg = ServerSb.ToString();
                    if (StringMsg.IndexOf("</TcpMsg>") > -1)
                    {
                        var xmlSerializer = new XmlSerializer(typeof(ServerClientMsg));
                        var ReceivedMsgObject = new ServerClientMsg();
                        using (var textReader = new StringReader(StringMsg))
                        {
                            ReceivedMsgObject = (ServerClientMsg)xmlSerializer.Deserialize(textReader);
                        }

                        // Clear string builder since we are done with it 
                        ServerSb.Clear();

                        var MsgObjectToReturn = new ServerClientMsg();

                        // If this thread is for the server
                        if (tcpState.ClientType == false)
                        {
                            MsgObjectToReturn = ServerCreateRly(ReceivedMsgObject);
                        }
                        // If this thread if for the client 
                        else
                        {
                            
                            // Now that we have the serializable object, we need to switch through all the commands
                            switch (ReceivedMsgObject.Command)
                            {
                                // Data request command
                                case (int)ServerClientMsg.Commands.DataRq:

                                    byte[] file;
                                    string hash = string.Empty;
                                    //Console.WriteLine("Client Server: received data request for file: {0} segment: {1}", ReceivedMsgObject.NameOfFile,ReceivedMsgObject.SegmentOfFile);

                                    string filepath = tcpState.TempFolderPath + @"/" + Path.GetFileNameWithoutExtension(ReceivedMsgObject.NameOfFile);
                                    filepath += "_temp" + ReceivedMsgObject.SegmentOfFile + Path.GetExtension(ReceivedMsgObject.NameOfFile);
                                    //Console.WriteLine("Client Server: Retreiving file: {0}", filepath);

                                    // See if the client's server actually has the file or not
                                    if (File.Exists(filepath))
                                    {
                                        file = File.ReadAllBytes(filepath);
                                    }
                                    else
                                    {
                                        //Console.WriteLine("Client Server could not find the file {0}", filepath);
                                        file = new byte[2];
                                    }

                                    // Retrieveing the hash to send back with the data segment
                                    foreach (var pair in tcpState.FileDict)
                                    {
                                        if(pair.Key == ReceivedMsgObject.NameOfFile)
                                        {
                                            ObjectForFiledict obj = pair.Value;
                                            hash = obj.Hash;
                                            //Console.WriteLine("Client Server: Hash = {0}", hash);
                                            break;
                                        }
                                    }
                                    
                                    MsgObjectToReturn.DataRly(hash, ReceivedMsgObject.SegmentOfFile, file);

                                    break;
                                default:
                                    Console.WriteLine("Invalid command to the client server");
                                    break;
                            }
                        }

                        // At this point, the serializable object should be popululated with the proper command and info
                        StringBuilder SerializedSb = new StringBuilder();

                        using (var stringWriter = new StringWriter())
                        {
                            xmlSerializer.Serialize(stringWriter, MsgObjectToReturn);
                            SerializedSb.Append(stringWriter.ToString());
                        }

                        var serializedString = SerializedSb.ToString();
                        var MsgToSend = Encoding.UTF8.GetBytes(serializedString);

                        // Sending the serializable response back
                        await networkStream.WriteAsync(MsgToSend, 0, MsgToSend.Length);

                            //Console.WriteLine("[Server] Response has been given");
                        }
                    }
                }
            }
        


        public ServerClientMsg ServerCreateRly(ServerClientMsg ReceivedMsgObject)
        {
            var MsgObjectToReturn = new ServerClientMsg();
            switch (ReceivedMsgObject.Command)
            {
                // If we received a Register Files message from the client
                case (int)ServerClientMsg.Commands.RegisterRq:
                    List<bool> SuccessList = new List<bool>();
                    // Looping through all the messages and add it to the dictionary if possible
                    for (int i = 0; i < ReceivedMsgObject.Files.Count; i++)
                    {
                        if (!ServerDict.ContainsKey(ReceivedMsgObject.Files[i]))
                        {
                            ServerDataObject Sdo = new ServerDataObject();
                            // Store each success and failure in a list for a message back to the client
                            SuccessList.Add(Sdo.AddEndPoint(ReceivedMsgObject.ClientIP, ReceivedMsgObject.ClientPort));
                            Sdo.Length = ReceivedMsgObject.FilesLength[i];
                            ServerDict.Add(ReceivedMsgObject.Files[i], Sdo);
                            Console.WriteLine("Server: Added file: {0} to the server dict for client: {1} , {2}", ReceivedMsgObject.Files[i],
                                ReceivedMsgObject.ClientIP, ReceivedMsgObject.ClientPort);
                        }
                        else
                        {
                            bool successflag = true;
                            foreach (var pair in ServerDict)
                            {
                                if (pair.Key == ReceivedMsgObject.Files[i])
                                {
                                    ServerDataObject ServObj = pair.Value;
                                    for (int k =0; k < ServObj.Addresses.Count; k++)
                                    {
                                        if (ServObj.Ports[k] == ReceivedMsgObject.ClientPort)
                                        {
                                            if (ServObj.Addresses[k] == ReceivedMsgObject.ClientIP)
                                            {
                                                Console.WriteLine("Server: Reject file {0} reg for client: {1} , {2}", ReceivedMsgObject.Files[i],
                                                    ReceivedMsgObject.ClientIP, ReceivedMsgObject.ClientPort);
                                                successflag = false;
                                            }
                                        }
                                    }
                                    if (successflag == true)
                                    {
                                        Console.WriteLine("Server: Added client {0} , {1} to server dict", 
                                            ReceivedMsgObject.ClientIP, ReceivedMsgObject.ClientPort, ReceivedMsgObject.Files[i]);
                                        ServObj.AddEndPoint(ReceivedMsgObject.ClientIP, ReceivedMsgObject.ClientPort);
                                    }
                                    break;
                                }
                            }

                            SuccessList.Add(successflag);

                        }
                    }
                    // Compile the return message for the client
                    MsgObjectToReturn.RegisterRly(SuccessList);

                    break;

                // If we received a file list request from the client
                case (int)ServerClientMsg.Commands.FileListRq:

                    // For a fileName list and a file size list
                    List<string> fileName = new List<string>();
                    List<long> fileSize = new List<long>();

                    foreach (var pair in ServerDict)
                    {
                        bool HasFileAlready = false;
                        ServerDataObject ServObj = pair.Value;
                        for (int k = 0; k < ServObj.Addresses.Count; k++)
                        {
                            if (ServObj.Ports[k] == ReceivedMsgObject.ClientPort)
                            {
                                if (ServObj.Addresses[k] == ReceivedMsgObject.ClientIP)
                                {
                                    Console.WriteLine("Server: client {0} , {1} already has the file {2}", ReceivedMsgObject.ClientIP,
                                        ReceivedMsgObject.ClientPort, pair.Key);
                                    HasFileAlready = true;
                                    break;
                                }
                            }
                        }
                        if (HasFileAlready == false)
                        {
                            fileName.Add(pair.Key);
                            ServerDataObject obj = pair.Value;
                            fileSize.Add(obj.Length);
                        }
                    }
                    MsgObjectToReturn.FileListRly(fileName, fileSize);
                    break;

                // If we received a file location request from the client
                case (int)ServerClientMsg.Commands.FileLocRq:

                    // For a fileName list and a file size list
                    List<string> addresses = new List<string>();
                    List<int> ports = new List<int>();
                    long length = 0;

                    foreach (var pair in ServerDict)
                    {
                        if (pair.Key == ReceivedMsgObject.NameOfFile)
                        {
                            ServerDataObject SObj = pair.Value;
                            addresses = SObj.Addresses;
                            ports = SObj.Ports;
                            length = SObj.Length;

                        }
                    }

                    MsgObjectToReturn.FileLocRly(length, addresses, ports);


                    break;

                // On leave request, the server need to remove all files that has the client's ip address. 
                // if the client is the last address that is associated with that file, then the server needs to remove the file
                case (int)ServerClientMsg.Commands.LeaveRq:

                    List<string> FilestoRemove = new List<string>();

                    foreach (var pair in ServerDict)
                    {
                        List<int> indexToRemove = new List<int>();

                        ServerDataObject objOfFile = pair.Value;
                        for (int i = 0; i < objOfFile.Addresses.Count; i++)
                        {
                            if (objOfFile.Addresses[i] == ReceivedMsgObject.ClientIP)
                            {
                                if (objOfFile.Ports[i] == ReceivedMsgObject.ClientPort)
                                    indexToRemove.Add(i);
                            }
                        }
                        // This allows the removal process to be skipped if the client doesn't have this file 
                        if (indexToRemove.Any())
                        {
                            foreach (var index in indexToRemove)
                            {
                                objOfFile.Addresses.RemoveAt(index);
                                objOfFile.Ports.RemoveAt(index);

                            }
                            if (!objOfFile.Addresses.Any())
                            {
                                FilestoRemove.Add(pair.Key);
                            }
                        }

                    }

                    // Now the server has to remove all the files that doesn't have any clients on it
                    if (FilestoRemove.Any())
                    {
                        foreach (var key in FilestoRemove)
                        {
                            ServerDict.Remove(key);
                        }
                    }


                    MsgObjectToReturn.LeaveRly();
                    break;
                case (int)ServerClientMsg.Commands.DataRly:
                    Console.WriteLine("Requesting Data from server instead of client");
                    break;
                default:
                    break;
            }
            return MsgObjectToReturn;
        }






        /**************************************************
        *
        *   The client part of the class starts here
        *
        **************************************************/


        public async Task ClientStart(ClientPassableObject taskObject)
        {
            string localIP = "127.0.0.1";
            IPEndPoint localEP = new IPEndPoint(IPAddress.Parse(localIP), GetOpenPort());
            using (var tcpclient = new TcpClient(localEP))
            {
                // Determining whether or not this tcp client is suppose to connect to the server or a client's server
                if (taskObject.target == (int)ClientPassableObject.enTarget.Server)
                {
                    await tcpclient.ConnectAsync(IPAddress.Parse("127.0.0.1"), 1000);
                    //Console.WriteLine("Client [{0} , {1}]: Connected to the server", localEP.Address, localEP.Port);
                }

                else
                {
                    await tcpclient.ConnectAsync(IPAddress.Parse(taskObject.ClientServerAddr), taskObject.ClientServerPort);
                    //Console.Write("Client [{0} , {1}]: Connected with ClientServer at address {2} and port {3}", localEP.Address, localEP.Port, taskObject.ClientServerAddr, taskObject.ClientServerPort);

                }
                var task = ClientOnConnectAsync(tcpclient, taskObject);
                if (task.IsFaulted)
                    task.Wait();
                task.Wait();
            }

        }

        private async Task ClientOnConnectAsync(TcpClient tcpclient, ClientPassableObject taskObject)
        {
            var TransferTask = ClientOnTransferAsync(tcpclient, taskObject);

            lock (_lock)
                _connections.Add(TransferTask);
            try
            {
                await TransferTask;
            }
            catch (Exception ex)
            {

                Console.WriteLine(ex.ToString());
            }
            finally
            {
                lock (_lock)
                    _connections.Remove(TransferTask);
            }
        }

        private async Task ClientOnTransferAsync(TcpClient tcpclient, ClientPassableObject taskObject)
        {
            await Task.Yield();

            using (var networkStream = tcpclient.GetStream())
            {
                var objectToClient = new ServerClientMsg();
                // send the proper serializable message depending on the command that was given
                switch (taskObject.command)
                {
                    case (int)ClientPassableObject.enCommands.RegFiles:
                        objectToClient.RegisterRq(taskObject.address, taskObject.port, taskObject.FilesToReg, taskObject.FilesLength);
                        break;

                    case (int)ClientPassableObject.enCommands.PrintDownloadable:
                        objectToClient.FileListRq(taskObject.address, taskObject.port);
                        break;

                    case (int)ClientPassableObject.enCommands.Leave:
                        objectToClient.LeaveRq(taskObject.address, taskObject.port);
                        break;
                    case (int)ClientPassableObject.enCommands.FileLocation:
                        objectToClient.FileLocRq(taskObject.FileToDownload);
                        break;
                    case (int)ClientPassableObject.enCommands.GetFile:
                        objectToClient.DataRq(taskObject.FileToDownload, taskObject.FileSegmentToDownload);
                        break;
                }
                await ClientSend(networkStream, objectToClient);

                // Start receiving reply from the server
                ServerClientMsg ReceivedObject = await ClientReceive(networkStream);
                switch (ReceivedObject.Command)
                {
                    // If it is a Register file reply then tell the user which file was successful. 
                    case (int)ServerClientMsg.Commands.RegisterRly:
                        Console.WriteLine("");
                        for(int i = 0; i < taskObject.FilesLength.Count; i++)
                        {
                            if (ReceivedObject.SuccessCount[i] == true)
                            {
                                Console.WriteLine("You have successfully registered file: {0}", Path.GetFileName(taskObject.FilesToReg[i]));
                            }
                            else
                            {
                                Console.WriteLine("You were not able to registered file: {0}", Path.GetFileName(taskObject.FilesToReg[i]));
                            }
                        }
                        taskObject.FilesRegSuccessCount = ReceivedObject.SuccessCount;

                        taskObject.DoneFlag = true;

                        break;

                    // if it is a file list request then we need to print it all on the screen
                    case (int)ServerClientMsg.Commands.FileListRly:

                        // if the server did not return anything
                        if (!ReceivedObject.Files.Any())
                        {
                            Console.WriteLine("\nNo files are avaialable for download at this point.");
                            taskObject.DoneFlag = true;
                            break;
                        }

                        // If there is files avaiable for download
                        Console.WriteLine("\nThere are {0} files available for download. \nThese are the downloadable files:\n", ReceivedObject.Files.Count);
                        for (int i = 0; i < ReceivedObject.Files.Count; i++)
                        {
                            var file = ReceivedObject.Files[i];
                            var length = ReceivedObject.FilesLength[i];
                            Console.WriteLine("{0}) {1}     Size: {2} bytes", i + 1, file, length);
                            taskObject.DownloadableFiles.Add(file);
                            taskObject.DownloadableFilesLength.Add(length);
                        }
                        taskObject.DoneFlag = true;

                        break;

                    case (int)ServerClientMsg.Commands.FileLocRly:

                        taskObject.FileToDownloadLength = ReceivedObject.SizeOfFile;
                        taskObject.AddressAtFile2Download = ReceivedObject.IPAddresses;
                        taskObject.PortAtFile2Download = ReceivedObject.Ports;

                        taskObject.DoneFlag = true;

                        break;

                    case (int)ServerClientMsg.Commands.DataRly:
                        taskObject.ResultFileSegment = ReceivedObject.ResultingDataSegment;
                        taskObject.ResultFileHash = ReceivedObject.HashOfFile;
                        taskObject.ResultFileSegmentNo = ReceivedObject.SegmentOfFile;

                        taskObject.DoneFlag = true;
                        break;

                    // if it is leave replay then we don't need to do anything
                    case (int)ServerClientMsg.Commands.LeaveRly:
                        Console.WriteLine("\nThe program is ready for shutdown. Press any key to close the program");
                        taskObject.DoneFlag = true;
                        break;
                }
                
            }
        }
        

        // This method is reponsible for getting the all the file segments from the available clients and stitch all the file segments back together
        public async Task GetDownloadFile(StateObject clientState)
        {

            // Requesting the file location file the server
            var getLocationCmd = new ClientPassableObject(clientState);
            getLocationCmd.GetFilesLocation(clientState.FileNameToDownload);
            await ClientStart(getLocationCmd);
            while (getLocationCmd.DoneFlag == false) ;

            Console.WriteLine("Client: File: {0} has a length of {1}", clientState.FileNameToDownload, getLocationCmd.FileToDownloadLength);
            for (int i = 0; i < getLocationCmd.AddressAtFile2Download.Count; i++)
            {
                Console.WriteLine("Client: Address: {0}  Port: {1}", getLocationCmd.AddressAtFile2Download[i],
                    getLocationCmd.PortAtFile2Download[i]);
            }

            var DataOperator = new DataSegmentObject();
            var NoOfSegments = DataOperator.GetNoOfSegments(getLocationCmd.FileToDownloadLength, clientState.MaxChunkSize);
            List<byte[]> bytesResult = new List<byte[]>();
            List<int> ResultSegIndex = new List<int>();
            string hashResult = string.Empty;
            for (int i = 0; i < NoOfSegments; i++)
            {
                //Console.WriteLine("Client: requesting File: {0} segment: {1} from {2}  {3}", clientState.FileNameToDownload, i,
                    //getLocationCmd.AddressAtFile2Download[0], getLocationCmd.PortAtFile2Download[0]);
                var getFileCmd = new ClientPassableObject(clientState);
                getFileCmd.GetFile(getLocationCmd.AddressAtFile2Download[0], getLocationCmd.PortAtFile2Download[0], clientState.FileNameToDownload, i);
                await ClientStart(getFileCmd);
                while (getFileCmd.DoneFlag == false) ;
                //Console.WriteLine("Client: Received segment {0}", i);
                bytesResult.Add(getFileCmd.ResultFileSegment);
                ResultSegIndex.Add(getFileCmd.ResultFileSegmentNo);
                hashResult = getFileCmd.ResultFileHash;
            }
            Console.WriteLine("Received all segments of the file");

            List<string> AvailableAddresses = getLocationCmd.AddressAtFile2Download;
            List<int> AvailablePorts = getLocationCmd.PortAtFile2Download;
            int NoOfAvailableClient = AvailableAddresses.Count;


            string FileToDownload = getLocationCmd.FileToDownload;
            int SegmentDone = 0;
            int SegmentInTransit = 0;
            List<bool> BusyClient = new List<bool>();
            List<Task> task = new List<Task>();
            List<int> indexOfTasks = new List<int>();
            List<ClientPassableObject> cmd = new List<ClientPassableObject>();


            //while (SegmentDone < NoOfSegments)
            //{
            //    for (int q = 0; q < AvailableAddresses.Count; q++)
            //    {
            //        if (SegmentDone < NoOfSegments)
            //        {
            //            var getfileCmd = new ClientPassableObject(clientState);
            //            getfileCmd.GetFile(AvailableAddresses[q], AvailablePorts[q], FileToDownload, SegmentDone);
            //            Console.WriteLine("Requesting segment #{0} from {1}  ,  {2}", SegmentDone + SegmentInTransit, AvailableAddresses[q], AvailablePorts[q]);
            //            task.Add(ClientStart(getfileCmd));
            //            cmd.Add(getfileCmd);
            //            SegmentDone++;
            //            task[0].Wait();
            //        }
            //        else
            //            break;
                    
            //    }
            //    // Wait until all the tasks are complete
            //    while (true)
            //    {
            //        int counter = 0;
            //        foreach (var command in cmd)
            //        {
            //            if (command.DoneFlag)
            //                counter++;
            //        }
            //        if (counter == cmd.Count)
            //            break;
            //    }

            //    for (int k = 0; k < cmd.Count; k++)
            //    {

            //        bytesResult.Add(cmd[k].ResultFileSegment);
            //        ResultSegIndex.Add(cmd[k].ResultFileSegmentNo);
            //        hashResult = cmd[k].ResultFileHash;
            //    }
            //    task.Clear();
            //    indexOfTasks.Clear();
            //    cmd.Clear();
            //}



            //for (int i = 0; i < NoOfAvailableClient; i++)
            //    BusyClient.Add(false);

            //while (SegmentDone < NoOfSegments)
            //{
            //    if ((SegmentInTransit + SegmentDone) <= NoOfSegments)
            //    {
            //        if (BusyClient.IndexOf(false) > -1)
            //        {
            //            int j = BusyClient.IndexOf(false);

            //            var getfileCmd = new ClientPassableObject(clientState);
            //            getfileCmd.GetFile(AvailableAddresses[j], AvailablePorts[j], FileToDownload, SegmentDone + SegmentInTransit);
            //            Console.WriteLine("Requesting segment #{0} from {1}  ,  {2}", SegmentDone + SegmentInTransit, AvailableAddresses[j], AvailablePorts[j]);
            //            task.Add(ClientStart(getfileCmd));
            //            indexOfTasks.Add(j);
            //            BusyClient[j] = true;
            //            cmd.Add(getfileCmd);
            //            SegmentInTransit++;
            //        }
            //        else
            //        {
            //            for (int k = 0; k < indexOfTasks.Count; k++)
            //            {
            //                if (cmd[k].DoneFlag)
            //                {
            //                    bytesResult.Add(cmd[k].ResultFileSegment);
            //                    ResultSegIndex.Add(cmd[k].ResultFileSegmentNo);
            //                    hashResult = cmd[k].ResultFileHash;
            //                    BusyClient[indexOfTasks[k]] = false;

            //                    SegmentDone++;
            //                    SegmentInTransit--;
            //                }
            //            }
            //            for (int f = indexOfTasks.Count -1; f >= 0; f--)
            //            {
            //                if (cmd[f].DoneFlag)
            //                {
            //                    task.RemoveAt(f);
            //                    indexOfTasks.RemoveAt(f);
            //                    cmd.RemoveAt(f);
            //                }

            //            }
            //        }

            //    }

            //}

            // Reordering the info
            List<byte[]> ResultInOrder = new List<byte[]>();
            for (int k = 0; k < bytesResult.Count; k++)
            {
                int indexOfSegment = ResultSegIndex.IndexOf(k);
                ResultInOrder.Add(bytesResult[indexOfSegment]);
            }

            // Combine all the segment and compare the hashcode
            int filesize = 0;
            int accumulativeSize = 0;
            foreach (var seg in ResultInOrder)
                filesize += seg.Length;
            byte[] wholeFile = new byte[filesize];
            foreach (var seg in ResultInOrder)
            {
                System.Buffer.BlockCopy(seg, 0, wholeFile, accumulativeSize, seg.Length);
                accumulativeSize += seg.Length;
            }

            var dataparser = new DataSegmentObject();
            if (dataparser.getHashAndCompare(wholeFile, hashResult) == true)
            {
                Console.WriteLine("File: {0} is finished. You can find the file in the your desktop.");
                var path = Environment.GetFolderPath(Environment.SpecialFolder.Desktop) + @"/" + clientState.FileNameToDownload + "new";

                // Writing the whole file to the desktop 
                using (var bw = new BinaryWriter(File.Open(path, FileMode.OpenOrCreate)))
                {
                    bw.Write(wholeFile);
                }

                FileInfo f = new FileInfo(path);
                clientState.FilePathsToReg.Clear();
                clientState.FilePathsToRegLength.Clear();
                clientState.FilePathsToReg.Add(path);
                clientState.FilePathsToRegLength.Add(f.Length);
                var uploadcmd = new ClientPassableObject(clientState);
                uploadcmd.RegisterFiles();
                await ClientStart(uploadcmd);
                while (uploadcmd.DoneFlag == false) ;

                var DataParser = new DataSegmentObject();

                // splitting the files up and store it in the temp folder
                DataParser.SplitFile(path, clientState.MaxChunkSize, clientState.TempFolderPath);
                var dictObject = new ObjectForFiledict();
                dictObject.Hash = DataParser.GetHash(clientState.FilePathsToReg[0]);
                dictObject.NoOfSegments = DataParser.GetNoOfSegments(clientState.FilePathsToRegLength[0], clientState.MaxChunkSize);
                clientState.FileDict.Add(Path.GetFileName(clientState.FilePathsToReg[0]), dictObject);

            }
            else
            {
                Console.WriteLine("One of the file was corrupt. We need to retry");
            }

            commandPrint();

        }
























        public async Task<ServerClientMsg> ClientReceive(NetworkStream networkStream)
        {
            var ReadBytes = new byte[8192];
            ServerClientMsg ReceivedObject = new ServerClientMsg();

            int BytesRead = await networkStream.ReadAsync(ReadBytes, 0, ReadBytes.Length);
            if (BytesRead > 0)
            {
                ClientSb.Append(Encoding.UTF8.GetString(ReadBytes, 0, BytesRead));
                var ReceivedMsg = ClientSb.ToString();
                if (ReceivedMsg.IndexOf("</TcpMsg>") > -1)
                {
                    XmlSerializer xmlS = new XmlSerializer(typeof(ServerClientMsg));
                    using (var stringReader = new StringReader(ReceivedMsg))
                    {
                        ReceivedObject = (ServerClientMsg)xmlS.Deserialize(stringReader);
                    }
                    ClientSb.Clear();
                }
            }
            return ReceivedObject;
            
        }

        public async Task ClientSend(NetworkStream networkStream ,ServerClientMsg objectToClient)
        {
            var xmlSerializer = new XmlSerializer(objectToClient.GetType());

            StringBuilder SerializedSb = new StringBuilder();

            using (var stringWriter = new StringWriter())
            {
                xmlSerializer.Serialize(stringWriter, objectToClient);
                SerializedSb.Append(stringWriter.ToString());
            }

            var serializedString = SerializedSb.ToString();
            var MsgToSend = Encoding.UTF8.GetBytes(serializedString);
            await networkStream.WriteAsync(MsgToSend, 0, MsgToSend.Length);
        }


        public int GetOpenPort()
        {
            int PortStartIndex = 1001;
            int PortEndIndex = 2000;
            IPGlobalProperties properties = IPGlobalProperties.GetIPGlobalProperties();
            IPEndPoint[] tcpEndPoints = properties.GetActiveTcpListeners();

            List<int> usedPorts = tcpEndPoints.Select(p => p.Port).ToList<int>();
            int unusedPort = 0;

            for (int port = PortStartIndex; port < PortEndIndex; port++)
            {
                if (!usedPorts.Contains(port))
                {
                    unusedPort = port;
                    break;
                }
            }
            return unusedPort;
        }

        public static void commandPrint()
        {
            Console.Write("\nCommand >> ");
        }

        public string GetLocalIPAddress()
        {
            var host = Dns.GetHostEntry(Dns.GetHostName());
            foreach (var ip in host.AddressList)
            {
                if (ip.AddressFamily == AddressFamily.InterNetwork)
                {
                    return ip.ToString();
                }
            }
            throw new Exception("Local IP Address Not Found!");
        }
    }
}
