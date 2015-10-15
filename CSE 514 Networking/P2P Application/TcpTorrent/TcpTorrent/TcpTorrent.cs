using System;
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
        public async Task StartListener()
        {
            var TcpServer = TcpListener.Create(1000);
            TcpServer.Start(3);
            while (true)
            {
                var TcpClient = await TcpServer.AcceptTcpClientAsync();
                Console.WriteLine("[Server] Connect to a client");
                var task = OnConnectAsync(TcpClient);
                if (task.IsFaulted)
                    task.Wait();
            }

        }

        private async Task OnConnectAsync(TcpClient tcpClient)
        {
            // Start a transfer task
            var transferTask = OnTransferAsync(tcpClient);

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

        private async Task OnTransferAsync(TcpClient tcpClient)
        {
            await Task.Yield();

            using (var networkStream = tcpClient.GetStream())
            {
                var buffer = new byte[8192];
                Console.WriteLine("[Server] Reading from client");
                //var byteCount = await networkStream.ReadAsync(buffer, 0, buffer.Length);
                //var ClientMsg = Encoding.UTF8.GetString(buffer, 0, byteCount);
                //Console.WriteLine("The client wrote: {0}", ClientMsg);
                //var ReturnBytes = Encoding.UTF8.GetBytes("This is the server");
                //await networkStream.WriteAsync(ReturnBytes, 0, ReturnBytes.Length);
                //Console.WriteLine("[Server] Response has been given");

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
                                    }
                                    else
                                        SuccessList.Add(false);
                                }
                                // Compile the return message for the client
                                MsgObjectToReturn.RegisterRly(SuccessList);

                                break;
                            
                            // If we received a file list request from the client
                            case (int)ServerClientMsg.Commands.FileListRq:

                                // For a fileName list and a file size list
                                List<string> fileName = new List<string>();
                                List<int> fileSize = new List<int>();

                                foreach(var pair in ServerDict)
                                {
                                    fileName.Add(pair.Key);
                                    ServerDataObject obj = pair.Value;
                                    fileSize.Add(obj.Length);
                                }
                                MsgObjectToReturn.FileListRly(fileName,fileSize);
                                break;

                            // If we received a file list request from the client
                            case (int)ServerClientMsg.Commands.FileLocRq:

                                // For a fileName list and a file size list
                                List<string> addresses = new List<string>();
                                List<int> ports = new List<int>();
                                int length = 0;
                                ServerDataObject Result;
                                string name = ReceivedMsgObject.NameOfFile;
                                if (ServerDict.ContainsKey(name)) 
                                {
                                    Result = ServerDict[name];
                                    addresses = Result.Addresses;
                                    ports = Result.Ports;
                                    length = Result.Length;

                                }
                                MsgObjectToReturn.FileLocRly(length,addresses,ports);
                                break;
                            case (int)ServerClientMsg.Commands.LeaveRq:
                                MsgObjectToReturn.LeaveRly();
                                break;
                            default:
                                break;
                        }

                        StringBuilder SerializedSb = new StringBuilder();

                        using (var stringWriter = new StringWriter())
                        {
                            xmlSerializer.Serialize(stringWriter, MsgObjectToReturn);
                            SerializedSb.Append(stringWriter.ToString());
                        }

                        var serializedString = SerializedSb.ToString();
                        var MsgToSend = Encoding.UTF8.GetBytes(serializedString);
                        await networkStream.WriteAsync(MsgToSend, 0, MsgToSend.Length);

                        Console.WriteLine("[Server] Response has been given");
                    }
                }


            }
        }


        ////////////////////////////////////////////////////////


        public async Task ClientStart(ClientPassableObject taskObject)
        {
            // Notice that we don't care about what port we are using as it will be destroyed at the end of the connection
            IPEndPoint localEP = new IPEndPoint(IPAddress.Parse("127.0.0.1"), GetOpenPort());
            var tcpclient = new TcpClient(localEP);


            if (taskObject.target == (int)ClientPassableObject.enTarget.Server)
            {
                await tcpclient.ConnectAsync(IPAddress.Parse("127.0.0.1"), 1000);
                //Console.WriteLine("Connected to the server");
            }
            
            else
            {
                // Need to implement this to go to an actual client
                await tcpclient.ConnectAsync(IPAddress.Parse("127.0.0.1"), 1000);
            }
            var task = ClientOnConnectAsync(tcpclient,taskObject);
            if (task.IsFaulted)
                task.Wait();

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
                //var SendBytes = Encoding.UTF8.GetBytes("Hello this is the Client");
                //await networkStream.WriteAsync(SendBytes, 0, SendBytes.Length);
                //var ReceivedBytes = new byte[1024];
                //await networkStream.ReadAsync(ReceivedBytes, 0, ReceivedBytes.Length);
                //Console.WriteLine(Encoding.UTF8.GetString(ReceivedBytes));

                var objectToClient = new ServerClientMsg();
                switch (taskObject.command)
                {
                    case (int)ClientPassableObject.enCommands.RegFiles:
                        objectToClient.RegisterRq(new IPEndPoint(IPAddress.Parse(taskObject.address), taskObject.port), taskObject.FilesToReg, taskObject.FilesLength);
                        break;
                }
                await ClientSend(networkStream, objectToClient);

                // Start receiving reply from the server
                ServerClientMsg ReceivedObject = await ClientReceive(networkStream);
                string emptystring = string.Empty;
                //////// I'm not sure why this is here. delete when this is ran successfully
                //var ReceivedBytes = new byte[1024];
                //await networkStream.ReadAsync(ReceivedBytes, 0, ReceivedBytes.Length);
                //Console.WriteLine(Encoding.UTF8.GetString(ReceivedBytes));
            }
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
    }
}
