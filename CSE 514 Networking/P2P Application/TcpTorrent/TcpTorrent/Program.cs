using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TcpTorrent
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("hit Ctrl-C to exit.");
            var tcpTorrent = new TcpTorrent();
            // start the server 
            var task1 = tcpTorrent.StartListener();
            // Start the client
            var task2 = tcpTorrent.ClientStart();
            Console.ReadKey();
        }
    }
}
