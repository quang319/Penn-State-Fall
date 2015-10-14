using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace ClientTestingFromScratch
{
    class Program
    {
        static void Main(string[] args)
        {
            StartClient();
        }

        public static ManualResetEvent connectDone = new ManualResetEvent(false);
        public static ManualResetEvent sendDone = new ManualResetEvent(false);
        public static ManualResetEvent receiveDone = new ManualResetEvent(false);

        private const int BufferSize = 1024;
        public static byte[] buffer = new byte[BufferSize];

        public static StringBuilder ReceivedMsg = new StringBuilder();

        public static void StartClient()
        {
            string strHostName = string.Empty;
            strHostName = Dns.GetHostName();
            IPAddress ipAddress = IPAddress.Parse("127.0.0.1");
            IPEndPoint LocalEP = new IPEndPoint(ipAddress, 1002);
            IPEndPoint RemoteEP = new IPEndPoint(ipAddress, 1000);

            Socket Client = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            Client.Bind(LocalEP);

            Client.BeginConnect(RemoteEP, new AsyncCallback(OnConnect), Client);
            connectDone.WaitOne();

            // Sending data to remoteEP
            byte[] sendMsg = Encoding.UTF8.GetBytes("This is the client<EOF>");
            Client.BeginSend(sendMsg, 0, sendMsg.Length, 0, new AsyncCallback(OnSend), Client);
            sendDone.WaitOne();

            // Receive data from remoteEP
            Client.BeginReceive(buffer, 0, buffer.Length, 0, new AsyncCallback(OnConnect), Client);
            receiveDone.WaitOne();

            Client.Shutdown(SocketShutdown.Both);
            Client.Close();
            Console.ReadKey();

        }

        private static void OnReceive(IAsyncResult ar)
        {
            Socket client = (Socket)ar.AsyncState;
            int BytesRead = client.EndReceive(ar);
            ReceivedMsg.Append(Encoding.UTF8.GetString(buffer, 0, BytesRead));
            string content = ReceivedMsg.ToString();
            if (content.IndexOf("<EOF>") > -1)
            {
                Console.WriteLine("Just got data from the server");
                Console.WriteLine(content);
                receiveDone.Set();
            }
            else
            {
                client.BeginReceive(buffer, 0, BufferSize, 0, new AsyncCallback(OnReceive), client);
            }

        }

        private static void OnSend(IAsyncResult ar)
        {
            Socket Client = (Socket)ar.AsyncState;
            Client.EndSend(ar);
            Console.WriteLine("Successfully sent data to server");
            sendDone.Set();
        }

        private static void OnConnect(IAsyncResult ar)
        {
            Socket client = (Socket)ar.AsyncState;
            client.EndConnect(ar);
            Console.WriteLine("Connected to {0}",client.RemoteEndPoint.ToString());
            connectDone.Set();

        }
    }
}
