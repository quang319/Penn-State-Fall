using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Sockets;
using System.Net;
using System.Threading;

namespace TestServerFromScratch
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Starting Server");
            ServerStart();
            Console.WriteLine("Closing Server");
        }

        public static ManualResetEvent allDone = new ManualResetEvent(false);

        public const int BufferSize = 1024;
        // Receive buffer.
        public static byte[] buffer = new byte[BufferSize];

        public static StringBuilder RecievedMsg = new StringBuilder();

        public static void ServerStart()
        {

            Socket ServerSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            IPEndPoint ipEndpoint = new IPEndPoint(IPAddress.Any, 1000);

            ServerSocket.Bind(ipEndpoint);
            ServerSocket.Listen(4);

            while (true)
            {
                allDone.Reset();
                Console.WriteLine("Waiting for a connection...");
                ServerSocket.BeginAccept(new AsyncCallback(OnAccept), ServerSocket);

                allDone.WaitOne();
            }

        }

        private static void OnAccept(IAsyncResult ar)
        {
            allDone.Set();
            Socket ServerSocket = (Socket)ar.AsyncState;
            Socket ClientSocket = ServerSocket.EndAccept(ar);

            ServerSocket.BeginAccept(new AsyncCallback(OnAccept), ServerSocket);

            ClientSocket.BeginReceive(buffer, 0, BufferSize, 0, new AsyncCallback(OnReceive), ClientSocket);
        }

        private static void OnReceive(IAsyncResult ar)
        {
            Socket ClientSocket = (Socket)ar.AsyncState;
            int bytesRead = ClientSocket.EndReceive(ar);
            if (bytesRead > 0)
            {

                RecievedMsg.Append( Encoding.UTF8.GetString(buffer,0,bytesRead));
                string content = RecievedMsg.ToString();
                if (content.IndexOf("<EOF>") > -1)
                {
                    Console.WriteLine(content);
                    RecievedMsg.Clear();
                    byte[] msg = Encoding.UTF8.GetBytes("Hello I'm a server<EOF>");

                    ClientSocket.BeginSend(msg, 0, msg.Length, 0, new AsyncCallback(OnSend), ClientSocket);
                    ClientSocket.BeginReceive(buffer, 0, BufferSize, 0, new AsyncCallback(OnReceive), ClientSocket);

                }
                else
                {
                    ClientSocket.BeginReceive(buffer, 0, BufferSize, 0, new AsyncCallback(OnReceive), ClientSocket);

                }

            }
                
        }

        private static void OnSend(IAsyncResult ar)
        {
            Socket ClientSocket = (Socket)ar.AsyncState;
            ClientSocket.EndSend(ar);
        }
    }
};
