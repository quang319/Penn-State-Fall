using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;

namespace AsyncAwaitServer
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("hit Ctrl-C to exit.");
            var TcpServer = new TCPTorrent();
            TcpServer.StartListener().Wait();

            
            
        }

        
    }

    public class StateObject
    {
        public Socket WorkSocket = null;
        public const int BufferSize = 1024;
        public Byte[] Buffer = new Byte[BufferSize];
        public StringBuilder sb = new StringBuilder();
    }
}
