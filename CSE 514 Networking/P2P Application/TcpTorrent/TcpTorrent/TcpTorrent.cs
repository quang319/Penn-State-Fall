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

namespace TcpTorrent
{
    class TcpTorrent
    {
        public StringBuilder sb = new StringBuilder();
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
                var buffer = new byte[1024];
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
                    sb.Append(Encoding.UTF8.GetString(buffer, 0, byteCount));
                    var IncomingMsg = sb.ToString();
                    if (IncomingMsg.IndexOf("</TcpMsg>") > -1)
                    {
                        var xmlSerializer = new XmlSerializer(typeof(ServerClientMsg));
                        var ReceivedMsgObject = new ServerClientMsg();
                        using (var textReader = new StringReader(IncomingMsg))
                        {
                            ReceivedMsgObject = (ServerClientMsg)xmlSerializer.Deserialize(textReader);
                        }

                        var ReturnBytes = Encoding.UTF8.GetBytes("This is the server");
                        await networkStream.WriteAsync(ReturnBytes, 0, ReturnBytes.Length);
                        Console.WriteLine("[Server] Response has been given");
                    }
                }


            }
        }


        ////////////////////////////////////////////////////////
        public async Task ClientStart()
        {
            IPEndPoint localEP = new IPEndPoint(IPAddress.Parse("127.0.0.1"), 1002);
            var tcpclient = new TcpClient(localEP);
            await tcpclient.ConnectAsync(IPAddress.Parse("127.0.0.1"), 1000);
            Console.WriteLine("Connected to the server");
            var task = ClientOnConnectAsync(tcpclient);
            if (task.IsFaulted)
                task.Wait();


        }

        private async Task ClientOnConnectAsync(TcpClient tcpclient)
        {
            var TransferTask = ClientOnTransferAsync(tcpclient);

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

        private async Task ClientOnTransferAsync(TcpClient tcpclient)
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
                objectToClient.Command = (int) ServerClientMsg.Commands.RegisterRq;
                objectToClient.Message = "Hello World!";
                var xmlSerializer = new XmlSerializer(objectToClient.GetType());

                StringBuilder SerializedSb = new StringBuilder();
                //using (var memoryStream = new MemoryStream())
                //{
                //    xmlSerializer.Serialize(memoryStream, objectToClient);
                //    SerializedSb.Append(memoryStream.ToString());
                //}
                using (var stringWriter = new StringWriter())
                {
                    xmlSerializer.Serialize(stringWriter, objectToClient);
                    SerializedSb.Append(stringWriter.ToString());
                }

                var serializedString = SerializedSb.ToString();
                var MsgToSend = Encoding.UTF8.GetBytes(serializedString);
                await networkStream.WriteAsync(MsgToSend, 0, MsgToSend.Length);
                var ReceivedBytes = new byte[1024];
                await networkStream.ReadAsync(ReceivedBytes, 0, ReceivedBytes.Length);
                Console.WriteLine(Encoding.UTF8.GetString(ReceivedBytes));
            }
        }
    }
}
